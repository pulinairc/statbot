##########################################
#            LAST.FM TRIGGER		 #
#   v2.0rc1 by jesse@teranetworks.de	 #
##########################################
# DESCRIPTION:				 #
#  - grabs last scrobbled tracks and	 #
#    more from last.fm			 #
#  - command overview: type .lastfm	 #
##					##
# DISCLAIMER:				 #
#  - i cannot be held responsible for	 #
#    any damage	this script might cause! #
##					 #
# BUGS:					 #
#  - for newer versions and bug reports	 #
#    check: forum.teranetworks.de	 #
##					##
# CHANGELOG:				 #
#  2.0-rc1				 #
#     - switched php engine		 #
#     - fixed arg splitting		 #
#     - implented new features (modes)	 #
#     - all comments are now in english	 #
#     - fixed some minor bugs		 #
#  1.5					 #
#     - rewrote code			 #
#     - split args: a lot more features	 #
#       coming up :)			 #
#     - added a few comments		 #
#  1.0					 #
#     - wohoo, new idea born		 #
#     - bare implementation ;)		 #
##					##
# PLANNED:				 #
#  - flood protection			 #
#  - fixing bugs? plz report!		 #
#  - version check // autoupdate	 #
##					##
# GREETINGS 2:				 #
#  - siyb, teh tcl g0d <3		 #
#  - the whole teranetworks		 #
#    crew... peace!			 #
##########################################
#     ALL YOUR BASE ARE BELONG 2 US!	 #
##########################################

## CONFIGURATION ##

set lastfm(comchar) "!"
set lastfm(command) "lastfm"


##########################################

## TEH CODE

set lastfm(version) "lastfm.tcl-2.0rc1"

## adding public trigger ##
bind pub - $lastfm(comchar)$lastfm(command) handleit

package require http 

#proc grabit {url} {
## get it on with http package ##
#        http::config -useragent "Mozilla/5.0"
#        set incoming [http::data [http::geturl "$url"] ]
#        http::cleanup $incoming
#        return $incoming
#	upvar $incoming
#}

proc handleit {nick uhost hand chan text} { 
global lastfm

## check syntax ##
if {$text == ""} {
	putserv "PRIVMSG $chan :$nick, käyttö: $lastfm(comchar)$lastfm(command) <nick> \[mode\]"
	putserv "PRIVMSG $chan :$nick, oikeita modeja: recent \[count\], weeklytoptracks, weeklytopartists, topalbums, topartists, toptracks, friends, playcount, info"
} else {
## split args ##
	set x [llength $text]
	if {$x > 2} {
		set arg0 [lindex [split $text] 0]; # nick
		set arg1 [lindex [split $text] 1]; # mode
		set arg2 [lindex [split $text] 2]; # count
        } elseif {$x > 1} {
                set arg0 [lindex [split $text] 0]
                set arg1 [lindex [split $text] 1]
		set arg2 1;			   # count (default)
	} else {
		set arg0 [lindex [split $text] 0];
		set arg1 "recent";		   # mode  (default)
		set arg2 1;			   # count (default)
	}

## we force $count 3 in a few cases
	if {$arg1 != "recent"} {
		set arg2 3;
	}

## prepare url ##
	set url "http://forum.teranetworks.de/lastfm2.php?user=$arg0&anzahl=$arg2&modus=$arg1"


## get it on with http package ##
        http::config -useragent "Mozilla/5.0"
        set incoming [http::data [http::geturl "$url"] ]
        http::cleanup $incoming

## now let's go through the cases ##
	if {$arg0 == "info" || $arg1 == "info"} {
		putserv "PRIVMSG $chan :$lastfm(version) written by jesse@teranetworks.de - check http://forum.teranetworks.de/ for updates"
	} elseif {$incoming == "" || $incoming == "<br />"} {
		putserv "PRIVMSG $chan :No data available :("
	} elseif {$incoming == "Error"} {
		putserv "PRIVMSG $chan :Error: user unknown or wrong syntax (try '$lastfm(comchar)$lastfm(command)') or feed down :("
	} elseif {$arg1 == "weeklytoptracks"} {
		putserv "PRIVMSG $chan :$arg0's weekly top tracks: ${incoming}(more @ http://last.fm/user/$arg0)" 
        } elseif {$arg1 == "playcount"} {
                putserv "PRIVMSG $chan :$arg0 scrobbled ${incoming} tracks already"
        } elseif {$arg1 == "friends"} {
                putserv "PRIVMSG $chan :$arg0 has ${incoming} friends on last.fm"
        } elseif {$arg1 == "topalbums"} {
                putserv "PRIVMSG $chan :$arg0's $arg2 overall top albums: '${incoming}'"
        } elseif {$arg1 == "topartists"} {
                putserv "PRIVMSG $chan :$arg0's $arg2 overall top artists: ${incoming}"
        } elseif {$arg1 == "toptracks"} {
                putserv "PRIVMSG $chan :$arg0's $arg2 overall top tracks: ${incoming}"
        } elseif {$arg1 == "weeklytopalbum"} {
                putserv "PRIVMSG $chan :$arg0's weekly top album: ${incoming}"
        } elseif {$arg1 == "weeklytopartists"} {
                putserv "PRIVMSG $chan :$arg0's $arg2 weekly top artists: ${incoming}"
	} elseif {$arg2 > 1} {
		putserv "PRIVMSG $chan :$arg0's last $arg2 played tracks: ${incoming}(more @ http://last.fm/user/$arg0)" 
	} else {
		putserv "PRIVMSG $chan :$arg0 last played: ${incoming}(more @ http://last.fm/user/$arg0)" 
	}
}
}

putlog "Script loaded: \002$lastfm(version)\002"
