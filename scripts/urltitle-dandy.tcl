# Script to grab titles from webpages - Copyright C.Leonhardt (rosc2112 at yahoo com) Aug.11.2007 
# http://members.dandy.net/~fbn/urltitle.tcl.txt
# Loosely based on the tinyurl script by Jer and other bits and pieces of my own..

################################################################################################################

# Usage: 

# 1) Set the configs below
# 2) .chanset #channelname +urltitle        ;# enable script
# 3) .chanset #channelname +logurltitle     ;# enable logging
# Then just input a url in channel and the script will retrieve the title from the corresponding page.

# When reporting bugs, PLEASE include the .set errorInfo debug info! 
# Read here: http://forum.egghelp.org/viewtopic.php?t=10215

################################################################################################################

# Configs:

set urltitle(ignore) "bdkqr|dkqr" 	;# User flags script will ignore input from
set urltitle(pubmflags) "-|-" 		;# user flags required for channel eggdrop use
set urltitle(length) 5	 		;# minimum url length to trigger channel eggdrop use
set urltitle(delay) 1 			;# minimum seconds to wait before another eggdrop use
set urltitle(timeout) 60000 		;# geturl timeout (1/1000ths of a second)

################################################################################################################
# Script begins:

package require http			;# You need the http package..
set urltitle(last) 111 			;# Internal variable, stores time of last eggdrop use, don't change..
setudef flag urltitle			;# Channel flag to enable script.
setudef flag logurltitle		;# Channel flag to enable logging of script.

set urltitlever "0.01a"
bind pubm $urltitle(pubmflags) {*://*} pubm:urltitle
proc pubm:urltitle {nick host user chan text} {
	global urltitle
	if {([channel get $chan urltitle]) && ([expr [unixtime] - $urltitle(delay)] > $urltitle(last)) && \
	(![matchattr $user $urltitle(ignore)])} {
		foreach word [split $text] {
			if {[string length $word] >= $urltitle(length) && \
			[regexp {^(f|ht)tp(s|)://} $word] && \
			![regexp {://([^/:]*:([^/]*@|\d+(/|$))|.*/\.)} $word]} {
				set urltitle(last) [unixtime]
				set urtitle [urltitle $word]
				if {[string length $urtitle]} {
					puthelp "PRIVMSG $chan :\002$urtitle\002"
				}
				break
			}
		}
        }
	if {[channel get $chan logurltitle]} {
		foreach word [split $text] {
			if {[string match "*://*" $word]} {
				putlog "<$nick:$chan> $word -> $urtitle"
			}
		}
	}
	# change to return 0 if you want the pubm trigger logged additionally..
	return 1
}

proc urltitle {url} {
	if {[info exists url] && [string length $url]} {
		catch {set http [::http::geturl $url -timeout $::urltitle(timeout)]} error
		if {[string match -nocase "*couldn't open socket*" $error]} {
			return "Virhe yhteydessä. Otsikkoa ei saatu."
		}
		if { [::http::status $http] == "timeout" } {
			return "Yhteys aikakatkaistiin urlista $url"
		}
		set data [split [::http::data $http] \n]
		::http::cleanup $http
		set title ""
		if {[regexp -nocase {<title>(.*?)</title>} $data match title]} {
			return [string map { {href=} "" \" "" } $title]
		} else {
#			return "Otsikkoa ei löytynyt / ei otsikkoa."
		}
	}
}

putlog "Script loaded: \002Url Title Grabber $urltitlever (rosc)\002"
