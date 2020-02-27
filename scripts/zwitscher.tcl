##
# ZWITSCHER.TCL
#
# Update your twitter account by
# posting messages in a channel.
#
# dedicated to teh teranetworks irc network
# visit us at http://geekosphere.org
#
# 2008 by jesse@teranetworks.de
# 2009 by siyb@geekosphere.org
#
# LICENCED UNDER THE GPLv2
##

namespace eval geekosphere::twitter {
	##
	# CONFIGURATION
	##
	variable conf; variable rep
	
	# what will trigger the script (on global twitter and registering)?
	set conf(trigger) "twitter"

	# global twitter username
	set conf(globusername) "yourtwitteracc"

	# global twitter password
	set conf(globpassword) "yourtwitteraccpassword"
	
	# feedback channel
	set conf(feedbackChan) "#test"
	
	# enable feedback?
	set conf(enableFeedback) 1
	
	##
	# No need to modify this part!
	##
	set conf(apibase) "http://twitter.com/"
	set conf(twitterdir) "twitter"
	set conf(apiupdate) [file join statuses update.xml]
	set conf(userdb) [file join $conf(twitterdir) zwitscher.db]
	set conf(url) $conf(apibase)$conf(apiupdate)
	set conf(version) "0.2"

}



# needs tcllibs
package require http
package require base64

# dbfile checks
if {![file exists $geekosphere::twitter::conf(twitterdir)]} {
	file mkdir $geekosphere::twitter::conf(twitterdir)
	set fl [open $geekosphere::twitter::conf(userdb) a+];close $fl
} elseif {![file writable $geekosphere::twitter::conf(twitterdir)] || ![file writable $geekosphere::twitter::conf(userdb)]} {
	geekosphere::twitter::send2feed "geekosphere::twitter: Files not writeable ... exiting"
	die "geekosphere::twitter: Files not writeable ... exiting"
}


# the triggers
bind msg - $geekosphere::twitter::conf(trigger) geekosphere::twitter::pubCom
#bind msg - "$geekosphere::twitter::conf(trigger) del" geekosphere::twitter::userdel
bind ctcp - "ACTION" geekosphere::twitter::action

# handles public commands
proc geekosphere::twitter::pubCom {nick host hand text} {
	set command [lindex [split $text] 0]

	# if user wants to register
	if {$command == "+blacklist"} {
		# check if user exxists
		if {![geekosphere::twitter::addHost $host]} {
			# if user exists say so
			putserv "PRIVMSG $nick :You are already blacklisted"
		} else {
			# else put new user in db
			putserv "PRIVMSG $nick :Added your host to the blacklist"
		}
	} elseif {$command == "-blacklist"} {
		if {[geekosphere::twitter::delHost $host]} {
			putserv "PRIVMSG $nick :Removed your host from the blacklist"
		} else {
			putserv "PRIVMSG $nick :Your host isn't on my blacklist"
		}
	} else {
		putserv "PRIVMSG $nick :OH HAI! To have the bot NOT update our twitter account (wootchan) when you '/me something' in a channel,"
		putserv "PRIVMSG $nick :add your host to the blacklist with /msg $::botnick $geekosphere::twitter::conf(trigger) +blacklist"
		putserv "PRIVMSG $nick :remove your host to the blacklist with /msg $::botnick $geekosphere::twitter::conf(trigger) -blacklist"
	}
}

# send a message to the feedback channel
proc geekosphere::twitter::send2feed {msg} {
	if {!$geekosphere::twitter::conf(enableFeedback)} { return }
	putserv "PRIVMSG $geekosphere::twitter::conf(feedbackChan) :$msg"
}

# check if user exists
proc geekosphere::twitter::userexists {host} {
	set fl [open $geekosphere::twitter::conf(userdb) r]
	set data [read $fl]
	close $fl
	foreach line [split $data \n] {
		if {[lindex [split $line] 0] == [maskhost $host]} {;# if host is already present in file
			return 1
		}
	}
	return 0
}	

# add host to blacklist
proc geekosphere::twitter::addHost {host} {
	if {[geekosphere::twitter::userexists $host]} { return 0 }
	set fl [open $geekosphere::twitter::conf(userdb) a+]
	puts $fl [maskhost $host]
	close $fl
	return 1
}

# remove host from blacklist
proc geekosphere::twitter::delHost {host} {
	set data [read [set fl [open $geekosphere::twitter::conf(userdb) r]]];close $fl
	set search [lsearch $data [maskhost $host]]
	if {$search == -1} { return 0}
	set data [lreplace $data $search $search];# deletes host
	set fl [open $geekosphere::twitter::conf(userdb) w+];puts $fl $data;close $fl
	return 1
}

# map 'em evil chars
proc geekosphere::twitter::mapevil {string} {
	return [string map {\< &lt; \> &gt;} $string]
}

# prepare entry for global account
proc geekosphere::twitter::action {nick host hand chan keyword text} {
	if {[geekosphere::twitter::userexists $host]} { geekosphere::twitter::send2feed "$nick not twittered, is on blacklist"; return }
	set text [geekosphere::twitter::mapevil $text];# map evil chars
	geekosphere::twitter::updateit $host $text
}

# the actual http call
proc geekosphere::twitter::updateit {host text} {
	set auth "Basic [base64::encode $geekosphere::twitter::conf(globusername):$geekosphere::twitter::conf(globpassword)]"

	# in any case, set our useragent to the actual version of this script... advertising ;-)
	::http::config -useragent "zwitscher.tcl/$geekosphere::twitter::conf(version))"

	# now let's do the http call and update the account
	if {[catch {set reply [http::geturl $geekosphere::twitter::conf(url) -query [http::formatQuery status $text] -headers [list Authorization $auth]]} msg]} {
		geekosphere::twitter::send2feed "oh noes! http call didn't succeed: $msg"
	} else {
		set reply2 [http::data $reply]
		geekosphere::twitter::send2feed "yes! zwitschered xD"
	}
	http::cleanup $reply
}

putlog "Script loaded: \002ZWITSCHER.TCL (twitter-channel updater)\002"