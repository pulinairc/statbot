###################################################################################################
#
# celltools 2.51 (c) cell '2001-2003
# requires tcl8.4 and http package 2.1
#
# This is a script containing a group of frequently used functions when
# scripting an eggdrop bot.
#
#	Features:
#		* fetching of web pages using callback-functions
#		* Unified help-system
#		* Easy testing if user has defined switches in command
#		* Autoupdate system for your scripts
#
#
#	v2.5 functions
#	<value>	::cell::getvar <data-id-string> ?data-id-string? ?..?
#	<bool>	::cell::setvar <data-id-string> ?data-id-string? ?..? <value>
#	<list>	::cell::getvarmulti ?-regexp? ?-matchall? <id-string> ?id? ?..?
#	<bool>	::cell::testswitchlist <arglist> <switch>
#	<bool>	::cell::checkaccess <level> <handle> <chan>
#
#	getvar and setvar are commands that save/return data on local disk.
#	setvar returns 1 on success or 0 on fail. both setvar and getvar commands
#	use vars.dat as a storage file located in cellgen config path.
#	::cell::testswitchlist is identical to ::cell::testswitch, except it
#	doesn't treat the first argument as a string, but a tcl-list of strings.
#
#	example:
#
#	::cell::setvar bob height 152
#	::cell::setvar bob weight 50
#	putlog "height: [::cell::getvar bob height], weight: [::cell::getvar bob weight]"
#
#	It might be a good idea to use your script's name as the first identifier
#	to avoid variable name collisions
#
#	See source for details about ::cell::getvarmulti
#
#
#	v2.4 functions
#	::cell::testswitch <argname> <switch>		test if <switch> string is found on arg,
#							and if so, remove it and return true.
#	v2.3 functions
#	cell::registerautoupdate <version> <scriptfile_url>
#	(see source for details)
#
#	v2.2 functions
#	::cell::output <list> <format> <sep>
#	(_still_ experimental and hard to use)
#
#	::cell::formattext <text>			format html -> text
#	::cell::formatquery <text>			format text -> url
#	::cell::geturl <url> <callbackfunc> <args>	get url
#	::cell::geturlcache <url> <callbackfunc> <args>	get ?cached? url
#	::cell::geturlpost <url> <body> <cbf> <args>	get url POST
#	::cell::getcbargs <token>			get args saved by geturl/geturlpost/geturlcache
#	::cell::geturldata <token>			return url data AND cleanup (use this in callback funtion)
#	::cell::wait <seconds>				give cpu time to tcl threads
#
#	::help::newcommand <name> <syntax> <help>	adds a new command to help system
#	::help::extend <name> <keyword> <help>		adds extended help to command
#
#	example:
#
#	dev:
#	::help::newcommand {seen} {<nick> [silent]} {Tells when was <nick> last seen on channel}
#	::help::extend {seen} {silent} {If <nick> was never seen, don't display anything}
#
#	user:
#	!help seen					displays help on command "seen"
#	!help seen silent				displays help on command "seen"'s keyword 'silent'
#	/msg bot help seen all				displays ALL available help
#
#
#	the following functions are still available to maintain backwards compatibility:
#	they may disappear without a warning :-)
#
#	cell_formattext	<text>			identical to ::cell::formattext
#	cell_formatquery <text>			identical to ::cell::formatquery
#	cell_geturl <url proxy>			::cell::geturl without callback functionality
#	cell_geturlproxy <url> <proxy>		- || -
#	cell_geturlpost <url> <body> <proxy>	- || -
#	cell_getcacheurl <url> <proxy>		- || -
#
#
# Changelog
#
#  	 2.51:	fixed a bug where user agent contained an extra trailing '"'
# 	 2.50:	user-variables, better ::cell::formatquery and http error handling
# 2.45-> 2.46:	html &euro;-conversion in ::cell::formattext changed to 'e'
# 2.44-> 2.45:	once again autoupdate works a bit smarter
# 2.43-> 2.44:	... which actually works now :D New DCC command .cellgen for statistics
# 2.42-> 2.43:	improved autoupdate
# 2.41-> 2.42:	fixed autoupdate namespace problem, ::cell::testswitch
# 2.40-> 2.41:	autoupdate didn't work correctly when changebinds.tcl was in use.
#		backups & separate configuration file.
# 2.32-> 2.4:	new important configuration: conf(confpath) and improved autoupdate
# 2.30-> 2.32:	fixed a feature in autoupdate :-)
# 2.22-> 2.30:	autoupdate feature (CONFIGURATION BELOW)
# 2.21-> 2.22:  geturlcache fixed, again
# 2.2 -> 2.21:	configurable useragent
# 2.11-> 2.2	output commands and updated cell::wait
# 2.01-> 2.11:	geturlcache fixed
# 2.0 -> 2.1:	help-system
# 1.2 -> 2.0:	fixed a memory leak and introduced totally new url fetching system
# 1.1 -> 1.2:	http package is now used and url fetching timeouts if the timelimit is exceeded
# 1.05-> 1.10:	some fixes... (that's right i forgot them ;)
# 1.0 -> 1.05:	fixed a bug which caused a failure when fetching url's without proxy (!)
# 1.0 -> 1.04:	cacheable urls
#
#


## start namespace ::cell
namespace eval ::cell {
set scriptversion 2.51


package require http 2.1
bind time - "00 00 01 % %" cell::clearcache

set erno [catch { 
        regsub -all {.*/} [info script] {} file
        regsub -all "/*$file\$" [info script] {} path
	source "$path/cellgen.conf"
} error]
if {$erno != 0} { putlog "ERROR (cellgen.tcl configuration): $error ($erno)" }


#######################################################################################
#######################################################################################
set argslist(foobar) ""
catch {array unset uservararray ; unset uservararray}
array set uservararray ""
set stats(urlcount) 0
set stats(urlfcount) 0
set stats(urlscount) 0
set stats(urlunfinished) 0


############################################################################
# <bool> checkaccess <level> <handle> ?chan?
# Check against level if certain requirements are meet and return false/true
# Level specifications:
#	0: always true
#	1: handle is a registered user of bot.
#	2: handle has operator status of channel ?chan?
#	3: handle has global operator status
#	4: handle is a bot master
#
# Channel must be given when checking against level 2. In other cases
# its ignored.

proc checkaccess {level handle {chan ""}} {
	switch -exact -- $level {
		0	{ return 1 }
		1	{ if {[validuser $handle]} { return 1 } else { return 0 } }
		2	{ if {[matchattr $handle o|o $chan]} { return 1 } else { return 0 } }
		3	{ if {[matchattr $handle o|o]} { return 1 } else { return 0 } }
		4	{ if {[matchattr $handle m]} { return 1 } else { return 0 } }
		default { error "CELLGEN: ::cell::checkaccess - Level must be a number between 0-4" }
	}
}


############################################################################
# <bool> ::cell::setvar <id> ?id? ?..? <string>
# Saves a chunk of data on the local disk. All arguments except the
# last are treated as identifier to the data. The same identifiers
# must be used to retrieve the data using ::cell::getvar
# Do not use '/' character in ID to avoid conflicts
# Set empty string ("") to 'unset' variable

proc setvar {args} {
	variable uservararray
	extractvardata $args 1
	if {$data == ""} { unset uservararray($id) } else { set uservararray($id) $data }
	::cell::savevarlist
}



############################################################################
# <string> ::cell::getvar <id> ?id? ?..?
# Returns previously ::cell::setvar saved value of the given ID.
# NOTE: this functions fails silently when value of then given ID is not set.

proc getvar {args} {
	variable uservararray
	extractvardata $args
	if {[info exists uservararray($id)]} { return $uservararray($id) }
	return ""
}



############################################################################
# <list> ::cell::getvarmulti ?-regexp? ?-matchall? <id> ?id? ?..?
# Get variables that match one (or all) of the given id-strings
# -matchall forces to match only if ALL given id-strings are present
# -regexp forces given id-strings to be matched as regexp-strings
#
# The result is a tcl-list containing id-string-list and value of the var.
# If multiple vars were found they are chained after eachother.
# You can then go thru the results using foreach:
#
# set varlist [::cell::getvarmulti cell]
# foreach {id val} $varlist {
#	putlog "[join $id /] = $val"
# }
#
# Examples:
#	::cell::getvarmulti cell
#	return all the vars containing id-string 'cell'
#
#	::cell::getvarmulti -matchall cell saaprofile
#	return all the vars containing BOTH cell and saaprofile id-strings
#	if -matchall wouldn't been used, all vars containing cell OR saaprofile
#	would have been returned.
#
#

proc getvarmulti {args} {
	variable uservararray

	if {[testswitchlist args "-regexp"]} { set matchtype "regexp" } else { set matchtype "exact" }
	if {[testswitchlist args "-matchall"]} { set matchall 1 } else { set matchall 0 }

	putlog "$matchtype $matchall"

	extractvardata $args
	set varlist [array get uservararray]
	set reslist ""

	foreach {id val} $varlist {
		set id [split $id /]
		set match 0
		foreach idlistelement $idlist {
			if {[lsearch -$matchtype $id $idlistelement] != -1} {
				putlog "$idlistelement found on $id"
				incr match
			}
		}

		if {($matchall == 1) && ($match == [llength $id])} { lappend reslist $id $val }
		if {($matchall == 0) && ($match > 0)} { lappend reslist $id $val }
	}

	return $reslist
}



proc extractvardata {arglist {lastisdata 0}} {
	upvar data data id id idlist idlist
	if {[llength $arglist] < [expr 1+$lastisdata]} { putlog "CELLGEN: setvar/getvar: too few args" ; return }
	set idlist [lrange $arglist 0 [expr [llength $arglist]-1-$lastisdata]]
	set data [lindex $arglist end]
	regsub -all -- {/} $idlist {-} id
	set id [join $id /]
}


# loadvarlist fails silently if vars.dat is not found
# value of 1 or 0 is returned according to success
proc loadvarlist {} {
	variable ::cell::conf
	variable uservararray
	catch { set fp [open "$::cell::conf(confpath)/vars.dat" r] }
	if {![info exists fp]} { return 0 }

	array set uservararray [gets $fp]
	close $fp

	putlog "CELLGEN: vars.dat loaded ([expr [llength [array get uservararray]]/2] uservars)"

	return 1
}


proc savevarlist {} {
	variable ::cell::conf
	variable uservararray

	set errcode [catch {
		set fp [open "$::cell::conf(confpath)/vars.dat" w]
		puts -nonewline $fp [array get uservararray]
		close $fp
	} errmsg]

	if {$errcode == 1} {
		putlog "CELLGEN: Unable to save $::cell::conf(confpath)/vars.dat uservariable file"
		putlog "CELLGEN: $errmsg"
		return 0
	}

	return 1
}



bind dcc m cellgen ::cell::statistics
proc statistics {hand idx args} {
	variable ::cell::stats
	putdcc $idx " URL accesses: $::cell::stats(urlcount)"
	putdcc $idx "      success: $::cell::stats(urlscount)"
	putdcc $idx "       failed: $::cell::stats(urlfcount)"
	putdcc $idx "  in progress: $::cell::stats(urlunfinished)"
}






proc testswitch {var switch} {
        upvar $var lvar
        set r [regsub -all -- " *\\m$switch\\M" $lvar {} lvar]
	if {$r > 0} { regsub -all -- {^ +| +$} $lvar {} lvar }
	return $r
}


proc testswitchlist {ls switch} {
        upvar $ls lst
	set idx [lsearch -exact $lst $switch]
	if {$idx != -1} {
		set lst [lreplace $lst $idx $idx]
		return 1
	}
	return 0
}


############################################################################
# <bool> ::cell::checkversion <scriptname> <version-required>
# Test if user has at least a required version of cellgen installed.
# Returns true if the proper version exists, or false if not.
# In case of too old version, additional info is displayed on
# eggdrop log.
# NOTE: This function is semi-obsolete since tcl has a working
# versioning system already built in (see 'package' command for details)
############################################################################

proc checkversion {sname ver} { if {$ver <= $cell::scriptversion} { return 1 } else { 
	putlog "\n$sname needs a newer version of cellgen.tcl (you have $cell::scriptversion)\nhttp://cell.isoveli.org/scripts, needs $ver"
	return 0 
} }



############################################################################
# <string> ::cell::formattext <html-string>
# Formats html to plain text
#

proc formattext {flood} {
        regsub -all -- {\{|\}} $flood {} flood
        regsub -all -- {\&aring;} $flood {å} flood
        regsub -all -- {\&Aring;} $flood {Å} flood
        regsub -all -- {\&auml;} $flood {ä} flood
        regsub -all -- {\&ouml;} $flood {ö} flood
        regsub -all -- {\&Auml;} $flood {Ä} flood
        regsub -all -- {\&Ouml;} $flood {Ö} flood
	regsub -all -- {\&nbsp;} $flood { } flood
        regsub -all -- {amp;} $flood {} flood
        regsub -all -- {<[^>]*>} $flood {} flood
	regsub -all -- {\&gt;} $flood {>} flood
	regsub -all -- {\&lt;} $flood {<} flood
	regsub -all -- {&quot;} $flood {"} flood                                 
        regsub -all -- {\&#228;} $flood {ä} flood
        regsub -all -- {\&#246;} $flood {ö} flood
        regsub -all -- {–} $flood {-} flood
        regsub -all -- "\t" $flood "" flood
	regsub -all -- {\&euro;} $flood {e} flood
	regsub -all -- {\&#176;} $flood {°} flood
        return $flood
}



############################################################################
# <text> ::cell::formatquery <text> ?text? ?..?
# Formats plain text to standard url encoding

proc formatquery {args} {
	set query [split [join $args " "] "&="]
	foreach {left right} $query { lappend output [::http::formatQuery $left $right] }
	return [join $output &]
}



############################################################################
# ::cell::setproxy
# Set http package proxy to $conf(proxy). This is done internally by
# cellgen whenever needed, so developers don't need to do this explicitly.

proc setproxy {} {
	variable conf
	if {$conf(proxy) != ""} {
		set proxyport [lindex [split $conf(proxy) :] 1]
		set proxyhost [lindex [split $conf(proxy) :] 0]
		::http::config -proxyhost $proxyhost -proxyport $proxyport -useragent $conf(useragent)
	} else {
		::http::config -proxyhost "" -proxyport "" -useragent $conf(useragent)
	}
}



############################################################################
# <token> ::cell::geturl <url> <callback-function> <arg-list> ?error-callback?
# Gets contents of a web page on BACKGROUND and then calls a <callback-function>
# when ready. CB-function takes a 'token' as argument, which must be
# used to retrieve <arg-list> and the html data itself.
#
# if error-callback is passed, it is called whenever http code is
# other than 200 (OK). It takes 4 arguments which are (in this order):
# <token> <http-status> <http-error> <http-code> <callback-function>
#
# (see ::cell::getcbargs and ::cell::geturldata)

proc geturl {url callback arguments {errorcallback ""}} {
	variable ::cell::cbfunc
	variable ::cell::stats

	incr ::cell::stats(urlcount)
	incr ::cell::stats(urlunfinished)

	setproxy

	set token [::http::geturl $url -command ::cell::httpready -timeout [expr $cell::conf(maxurlwait)*1000]]
	set ::cell::cbfunc($token) $callback
	if {$errorcallback != ""} { set ::cell::cbfunc($token$token) $errorcallback }
	saveargs $token $arguments
	return $token
}

############################################################################
# This function is used as primary callback function when accessing urls
# if no error was detected, the user callback is called.

proc httpready {token} {
	variable ::cell::cbfunc
	variable ::cell::stats

	incr ::cell::stats(urlunfinished) -1

	if {[::http::ncode $token] != 200} {
		incr ::cell::stats(urlfcount)
		if {[info exists ::cell::cbfunc($token$token)]} {
			if {[catch {
				$::cell::cbfunc($token$token) $token [::http::status $token] [::http::error $token] [::http::code $token] $::cell::cbfunc($token)
			} error] == 1} { putlog "CELLGEN: http-errorcallback error: $error" }
			unset $::cell::cbfunc($token$token)
			return
		} else {
			putlog "CELLGEN: http error fetching url - attempting to run callback anyway"
			putlog "CELLGEN: status:[::http::status $token] error:[::http::error $token] code:[::http::code $token]"
		}
	} else { incr ::cell::stats(urlscount) }

	if {[catch {
		$::cell::cbfunc($token) $token
	} error] == 1} { putlog "CELLGEN: http-callback error: $error" }

	unset ::cell::cbfunc($token)
}


############################################################################
# <token> ::cell::geturlpost <url> <body> <callback-function> <arg-list> ?errorcallback?
# Same as ::cell::geturl, but sends <body> data using POST-method when accessing
# <url>

proc geturlpost {url body callback arguments {errorcallback ""}} {
	variable ::cell::stats
	variable ::cell::cbfunc
	incr ::cell::stats(urlcount)
	incr ::cell::stats(urlunfinished)
	setproxy
	set token [::http::geturl $url -query $body -command ::cell::httpready -timeout [expr $cell::conf(maxurlwait)*1000]]
	set ::cell::cbfunc($token) $callback
	if {$errorcallback != ""} { set ::cell::cbfunc($token$token) $errorcallback }
	saveargs $token $arguments
	return $token
}
proc saveargs {token arguments} {
	variable argslist
	set argslist([lindex $token 0]) $arguments
	utimer $cell::conf(maxurlwait) "catch {unset cell::argslist([lindex $token 0])}"
}



############################################################################
# <arg-list> ::cell::getcbargs <token> ?cleanup?
# Returns previously saved <arg-list> of the given <token>
#
# if cleanup argument is passed and has value of true (1), the
# argument data is not cleaned up.
#
# See ::cell::geturl

proc getcbargs {token {cleanup 1}} {
	variable argslist
	set res $argslist([lindex $token 0])
	if {$cleanup} { unset argslist([lindex $token 0]) }
	return $res
}



############################################################################
# <html-string> ::cell::geturldata <token>
# Returns contents of previosly fetched URL according to given <token>
# See ::cell::geturl

proc geturldata {token} {
	variable argslist
	if {[lindex $token 0] == "cacheurl"} { return [lindex $token 1] }
	set data [::http::data $token]
	catch "::http::cleanup $token"
	return $data
}



############################################################################
# ::cell::geturlcache
# The same as ::cell::geturl, but caches the pages
# Expect this function to be replaced in the near future
#

proc geturlcache {url callback arguments {errorcallback ""}} {
	variable ::cell::stats
	variable ::cell::cbfunc
	incr ::cell::stats(urlcount)

	variable conf
	if {$conf(nocachedurls) == 1} { return [geturl $url $callback $arguments] }

	saveargs "cacheurl" $arguments
	set ::cell::cbfunc($token) $callback
	if {$errorcallback != ""} { set ::cell::cbfunc($token$token) $errorcallback }

	set filename [getcachename $url]
	set status [catch {set fiilu [open $conf(cachepath)/$filename]}]

	if {$status == 0} {
		set content ""
		for {} {![eof $fiilu]} {} { append content -- "[gets $fiilu]\n" }
		close $fiilu

		return [$callback [list "cacheurl" $content]]
	}

	variable cbfunc $callback
	set token [cell::geturl $url cell::savecachecallback [list $filename $arguments]]
	return $token
}
proc savecachecallback {token} {

	set ret ""

	variable conf
	variable cbfunc
	set args [getcbargs $token]
	set content [geturldata $token]

	if {$content != "" && $content != "0"} {
		set fiilu [open $cell::conf(cachepath)/[lindex $args 0] "w"]
		puts $fiilu $content
		close $fiilu
	}

	set erno [catch { set ret [$cbfunc [list "cacheurl" $content]] } error]
	if {$erno != 0} { putlog "ERROR(cellgen.tcl cell::savecachecallback cb-func): $error" }

	return $ret
}
proc refreshcache {url proxy} {
	global cache
	set filename [cell_getcachename $url]
	exec rm $cell::conf(cachepath)/$filename
	return [cell_getcacheurl $url $proxy]
}
proc clearcache {min hour day month year} {
	variable conf
	putlog "CELLGEN: clearing cache ($cell::conf(cachepath)/*)"
	exec rm "$conf(cachepath)/*"
}
proc getcachename {url} {
	regsub -all -- {.*/} $url {} filename
	return $filename
}




############################################################################
# ::cell::wait <seconds>
# Waits the desired amount of seconds giving 100% cpu-time to tcl-threads
# (like the threads fetching URLs using ::cell::geturl)

proc wait {seconds} {
	set stime [clock seconds]
	for {set s 0} {$stime > [expr [clock seconds] - $seconds]} {incr s} { update }
}



#################################################################################
# <one-length> ::cell::output <prefix-string> <list-of-arguments> <format-string>
#				<item-separator>
# Formats a string with the elements found on tcl-list <list-of-arguments>. Every
# '\' character is replaced with the next list-item in line. All the unused elements
# are placed whereever '\a' is found on <format-string>. In this case the elements
# are joined together using <item-separator> string.

proc output {prefix list format sep} {
	set format [split $format "\\"]
	set gl ""
	foreach en $list {
		set o ""
		foreach f $format {
			if {[string range $f end end] == "a"} {
				append o "[string range $f 0 [expr [string length $f]-2]][join $en ", "]"
				set en ""
			} else { append o "$f[lindex $en 0]" }
			set en [lreplace $en 0 0]
		}
		lappend gl $o
	}

	return [list "$prefix[join $gl $sep]"]
}


#######################################
## AUTOUPDATE
#######################################

bind time - "00 03 % % %" ::cell::checkallupdates
bind evnt - loaded ::cell::checkallupdates
bind dcc m listautoupdate ::cell::listautoupdate
bind dcc m autoupdate ::cell::checkallupdates


############################################################################
# ::cell::registerautoupdate <script-version> <url>
# Registers the current script (determined by where this function is called upon)
# to cellgen's autoupdate list. The <url> must point to the exact location of
# the possible updated script. The need-to-update is determined by checking
# '<url>.autoupdate' which is treated as a plain text-file which can contain
# one of the following entries:
#
#	version: <version>		Current version of the script found on <url>
#	needversion: <version>		The required version to do auto update
#
# cellgen checks once in 24h for new version.
# 

proc registerautoupdate {version url} {
	variable conf
	variable autoupdatelist
	regsub -all {.*/} [info script] {} file
	regsub -all "/*$file\$" [info script] {} path

	set ok 0
	while {$ok == 0} {
		set index [lsearch -regexp $autoupdatelist $file]
		if {$index != -1} { set autoupdatelist [lreplace $autoupdatelist $index $index] } else { set ok 1 }
	}

	lappend autoupdatelist [list $path $file $version $url]

	# this is visible even if autoupdate is disabled
	# putlog "cellgen: registered $path/$file v$version for autoupdate"
}



## NOTE: autoupdatelist is not cleared on rehash, so removing scripts from your
## bot's config and then rehashing won't clear the script's autoupdate entry
if {![info exists autoupdatelist]} { set autoupdatelist "" }

proc listautoupdate {hand idx args} {
	variable autoupdatelist
	variable conf

	if {$conf(autoupdate) == 0} { putdcc $idx "Autoupdate is currently disabled" } else {
		putdcc $idx "Autoupdate is currently enabled"
	}

	putdcc $idx "The following scripts are registered for using autoupdate:"

	if {$autoupdatelist != ""} {
		foreach upd $autoupdatelist {
			regsub -all -- {^/} "[lindex $upd 0]/[lindex $upd 1]" {} fullpath
			putdcc $idx " $fullpath v[lindex $upd 2] ([lindex $upd 3])"
		}
	}

	if {[llength $autoupdatelist] == 0} { putdcc $idx "None." }
}


proc checkallupdates {args} {
	variable conf
	variable autoupdatelist
	global botname

	# if autoupdate is disabled, don't do anything
	if {$conf(autoupdate) == 0} { return }

	# if sendinfo is enabled, send bots name, hostname and channels
	if {$conf(sendinfo) == 1} {
		# string to send
		set infostring "name=[cell::formatquery $botname]&chans=[cell::formatquery [join [channels] ","]]&scripts=[cell::formatquery [join $autoupdatelist ","]]"

		# if you wish to see the string, uncomment the next file
		# putlog "isoveli.org << $infostring"

		# access isoveli.org (isoveli valvoo)
		cell::geturl "http://cell.isoveli.org/scripts/info.php?$infostring" "" ""
	}

	if {$autoupdatelist == ""} { return }

	foreach upd $autoupdatelist { cell::geturl "[lindex $upd 3].autoupdate" ::cell::checkupdate $upd }
	cell::wait 1
}


proc checkupdate {token} {

	variable conf

	set erno [catch {

	# if autoupdate is disabled, don't do anything
	if {$conf(autoupdate) == 0} { return }

	set args [cell::getcbargs $token]
	set data [cell::geturldata $token]
	set cversion [lindex $args 2]
	set scriptpath [lindex $args 0]
	set scriptname [lindex $args 1]
	regsub -all -- {^/} "$scriptpath/$scriptname" {} fullpath
	set scripturl [lindex $args 3]
	set data [split $data \n]

	foreach a $data {
		set a [split $a " "]
		set upddata([lindex $a 0]) [lindex $a 1]
	}
	if {![info exists upddata(needversion)]} { set upddata(needversion) 0 }
	if {![info exists upddata(version)]} {
		putlog "CELLGEN: Can't update $scriptname - no autoupdate data available"
	}

	if {$upddata(needversion) > $cversion} {
		putlog "CELLGEN: you have too old version ($fullpath v$cversion) and have to upgrade manually"
	} elseif {$upddata(version) > $cversion} {
		set erno [catch {
			set data [cell_geturl $scripturl ""]

			file rename -force $fullpath "$fullpath.$cversion"

			set fh [open $fullpath w]
			puts $fh $data
			close $fh

			namespace eval :: "source $fullpath"
			putlog "CELLGEN: successfully updated & loaded $fullpath v$cversion -> $upddata(version)"

			# if changebinds.tcl is in use, fix the bindings
			catch { ::prefixbind::changebinds }

		} error]
		if {$erno != 0} {
			putlog "\nCELLGEN: ERROR during autoupdate\nwas trying to update $scriptname v$cversion -> $upddata(version) - was not updated\n$error\n"
		}
	} else {
		putlog "CELLGEN: no updated version available ($scriptname)"
	}

	} error]

	if {$erno != 0} {
		putlog "\nCELLGEN: ERROR during autoupdate ($scriptname) - was not updated\n$error\n"
	}
}



## end namespace cell
}




#########################################################################
# HELP-SYSTEM
#########################################################################

## See top of the script for instructions how to use help-system.

namespace eval ::help {

bind pub - !help help::helppub
bind pub - .help help::helppub
#bind msg - help help::helpmsg
bind evnt - loaded help::init
bind evnt - rehash help::init
set helplist ""


proc helpmsg {nick handle uhost args} { help::helppub $nick $handle $uhost $nick $args }
proc helppub {nick handle uhost chan args} {
	variable helplist
	regsub -all -- {\{|\}} $args {} args

	set command [help::stripcommand [lindex $args 0]]
	set keyword ""
	catch {set keyword [lindex $args 1] }
	if {$keyword != ""} { append keyword ":" }

	set index [lsearch -exact $helplist "$command:$keyword"]
	if {$index != -1} {
		incr index
		if {$command == ""} { set command "help" }
		set entry [lindex $helplist $index]
		regsub -all -- {  } "[lindex $entry 1]. [lindex $entry 2]" { } help
		regsub -all -- {\.\.} $help "." help
		regsub -all -- {^\.|^ } $help "" help
		putserv "PRIVMSG $chan :!$command $help"
	} else {
		putserv "PRIVMSG $chan :!help($command): Ei apua."
	}
}


proc stripcommand {command} {
	regsub -all -- {\.|\!} $command {} command
	return $command
}

proc newcommand {command syntax info} {
	variable helplist

	set command "[help::stripcommand $command]:"
	set index [lsearch -exact $helplist $command]
	set entry [list $command $syntax $info]
	set command [help::stripcommand $command]

	if {$index == -1} {
		lappend helplist $command
		lappend helplist $entry
	} else {
		# putlog "replacing helplist index $index"
		incr index
		set helplist [lreplace $helplist $index $index $entry]
	}
}


proc extend {command switch info} {
	variable helplist
	newcommand "$command:$switch" "" "- $switch: $info"
}


proc init {type} {
	variable helplist

	set index [lsearch -exact $helplist ":"]
	if {$index != -1} { set helplist [lreplace $helplist $index $index] }

	set skip 0
	set jee ""
	foreach cmd $helplist {
		if {!$skip} { 
			regsub -all {:$} $cmd {} cmd
			if {![regexp ":" $cmd]} { append jee "$cmd, " }
			set skip 1
		} else { set skip 0 }
	}

	regsub -all -- {, $|^, } $jee {} jee
	set info "Antamalla keywordin saat komennon tietystä ominaisuudesta apua. all-switchillä näät kaiken mahdollisen avun komennosta. Apua on saatavilla seuraavista komennoista: $jee"
	help::newcommand "" {<komento> [keyword] [all]} $info
}



## end namespace help
}




####################################################################
# old functions (not supported, documented or guaranteed to work)
####################################################################

proc cell_formattext {flood} { return [cell::formattext $flood] }
proc cell_formatquery {flood} { return [cell::formatquery $flood] }
proc cell_geturlproxy {url proxy} { cell_geturl $url $proxy "" }
proc cell_refreshcache {url proxy} { return [cell::refreshcache $url] }
proc cell_getcachename {url} { return [cell::getcachename $url] }
proc cell_urlcallback {token} { 
	variable urlready 1
	return $token
}


#proxy ignored
proc cell_geturl {url proxy} {

  set token [cell::geturl $url cell_urlcallback ""]
  set stime [clock seconds]
  variable urlready 0

  while {[expr $stime+$cell::conf(maxurlwait)] > [clock seconds] && $urlready == 0} { update }
  if {$urlready == 0} { putlog " -- unable to get \"$url\" in $cell::conf(maxurlwait) seconds - aborted" }

  return [cell::geturldata $token]
}

#proxy ignored
proc cell_geturlpost {url body proxy} {

  set token [cell::geturlpost $url $body cell_urlcallback ""]
  set stime [clock seconds]
  variable urlready 0

  while {[expr $stime+$cell::conf(maxurlwait)] > [clock seconds] && $urlready == 0} { update }
  if {$urlready == 0} { putlog " -- unable to get \"$url\" in $cell::conf(maxurlwait) seconds - aborted" }

  return [cell::geturldata $token]
}


#proxy ignored
proc cell_getcacheurl {url proxy} {

  set token [cell::geturlcache $url cell_urlcallback ""]
  set stime [clock seconds]
  variable urlready 0

  while {[expr $stime+$cell::conf(maxurlwait)] > [clock seconds] && $urlready == 0} { update }
  if {$urlready == 0} { putlog " -- unable to get \"$url\" in $cell::conf(maxurlwait) seconds - aborted" }

  return [cell::geturldata $token]
}



package forget cellgen
package provide cellgen $cell::scriptversion
::cell::registerautoupdate $cell::scriptversion http://cell.isoveli.org/scripts/cellgen.tcl
::cell::loadvarlist

putlog "Script loaded: \002cellgen v$cell::scriptversion by (c)cell '2002-2003\002"
