# This plugin for urlmagic logs all URLs posted on a channel into a SQLite 3
# database. The cgi script in the cgi/ subdirectory can be used to provide a
# web frontend for this database.

## SETTINGS
# See urlmagic/plugins/sqlite.conf. Append the content of this file to your
# conf/urlmagic.tcl, e.g. by doing
#  cat ~/eggdrop/urlmagic/plugins/sqlite.conf >> ~/eggdrop/conf/urlmagic.tcl
# if you installed your eggdrop into ~/eggdrop.

## IMPORTANT
# For this to work you will need to install sqlite3 for Tcl.
# Use the following commands:
#
# Debian / Ubuntu:
#    apt-get install libsqlite3-tcl
#
# Red Hat / CentOS
#    yum install sqlite-tcl
#
# Gentoo:
#    emerge -v sqlite
#
# FreeBSD / NetBSD:
#    pkg_add -r sqlite3-tcl

## PROGRAMMER DOCUMENTATION
# Eggdrop binds:
# * This plugin does not bind to any eggdrop events.
#
# Hooks:
# * This plugin binds to the following hooks:
#   - urlmagic: <Post-Fetch>   
#
# * This plugin exports the following hooks:
#   None.

# hook (from tcllib) provides a registry for hooks, effectively implementing a
# monitor/observer pattern. A plugin can observe urlmagic/another plugin and
# provide a hook at the same time. A plugin's subject object name should
# generally be the namespace name minus leading or trailing ":" characters. In
# our case, this is urlmagic::plugins::sqlite. 
package require hook

# Plugin version. sqlite ships with urlmagic, therefore its version number
# should be equal to that of an urlmagic release. If you ship third party
# plugins, this is not necessarily the case.
variable VERSION 1.1+hg

variable skip_sqlite3 [catch {package require sqlite3}]
if {$skip_sqlite3} {
	warn "Plugin loaded but sqlite3 library not installed, plugin won't do anything."
}

proc reopen_db { } {
	# This procedure must be manually invoked via 
	#   .tcl urlmagic::plugins::sqlite::reopen_db
	# if the database is moved.
	#
	# While messing with the database, use
	#   .set urlmagic::skip_sqlite3 1 
	# to disable writes to the database until you're done.
	variable skip_sqlite3
	variable settings
	variable ns

	if {$settings(urlmagic-db) == ""} {
		set skip_sqlite3 1
	}

	if {$skip_sqlite3} return

	if {[info commands ${ns}::db] != {}} {
		db close
	}

	if {[catch {sqlite3 ${ns}::db $settings(urlmagic-db)} err]} {
		warn "Error opening database file: $settings(urlmagic-db). Does the directory exist?"
		warn "Disabling sqlite. Use .tcl urlmagic::plugins::reload sqlite if you fixed the issue."
		set skip_sqlite3 1
		return false
	}
	init_db
}

proc init_db {} {
	variable skip_sqlite3
	if {$skip_sqlite3} {return false}

	db eval {
	CREATE TABLE IF NOT EXISTS
		urls( id                INTEGER PRIMARY KEY AUTOINCREMENT
		    , url               TEXT UNIQUE NOT NULL -- the URL that was mentioned
		    , last_mentioned_by TEXT                 -- who mentioned it the last time
		    , last_mentioned    INTEGER DEFAULT 0    -- unix time when it was last mentioned
		    , last_mentioned_on TEXT DEFAULT ""      -- channel the URL was last mentioned on
		    , mention_count     INTEGER DEFAULT 0    -- number of times it was mentioned
		    , content_type      TEXT
		    , html_title        TEXT
		    );
	}
}

# This proc is called after each time an URL is found on a channel
proc record_history {} {
	variable skip_sqlite3
	if {$skip_sqlite3} return

	upvar #0 urlmagic::title utitle

	set title $utitle(title)
	if {$title == ""} {
		unset title ;# HACK: insert NULL in case there is no title
	}

	# FIXME use expanded url here?
	db eval { -- initialise if it doesn't yet exist
		INSERT OR IGNORE INTO urls(url, mention_count) VALUES(:utitle(url), 0);
	        UPDATE urls SET
	                last_mentioned_by = :utitle(nick),
	                last_mentioned_on = :utitle(chan),
	                content_type      = :utitle(content-type),
	                html_title        = :title,
	                last_mentioned    = strftime('%s','now'),
	                mention_count     = mention_count + 1
	        WHERE url = :utitle(url);
	}
}

proc init_plugin {} {
	variable ns
	# Bind an event to which to react. Post-String will be executed after
	# the title detection string builders are finished.
	hook::bind urlmagic <Post-String> [myself] ${ns}::record_history

	# Open the database for the first time
	reopen_db
}

proc deinit_plugin {} {
	# Forget all hooks previously bound by this plugin.
	hook::forget [myself]
	# Close the database. Can fail if opening the database failed, or
	# something else happened that shouldn't have happened
	catch {db close}
}
