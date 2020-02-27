namespace eval durltitle {
##################################################################################
# Copyright ©2011 lee8oi@gmail.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# http://www.gnu.org/licenses/
#
# Durltitle v0.1.9(10.26.11)
# by: <lee8oiAtgmail><lee8oiOnfreenode>
# github link: https://github.com/lee8oi/durltitle/blob/master/durltitle.tcl
#
# Forked from urltitle script.
#
##################################################################################
# Original 'urltitle' header.                                                    #
#--------------------------------------------------------------------------------#
# Script to grab titles from webpages Copyright C.Leonhardt (rosc2112 at yahoo   #
# com) Aug.11.2007                                                               #
# http://members.dandy.net/~fbn/urltitle.tcl.txt                                 #
# Loosely based on the tinyurl script by Jer and other bits and pieces of my own.#
##################################################################################
#
# Description:
# Durltitle is a title grabbing script that monitors channels with the urltitle
# flag set. When a user posts a url in channel the script attempts to get the
# title information from the url and return it to the channel.
#
# Initial channel setup:
# (Starts monitoring channel for urls)
# 	.chanset #channel +urltitle
#
# (Starts logging on channel)
# 	.chanset #channel +logurltitle
#
# Example Usage:
# (public)
# 	<lee8oi> http://forum.egghelp.org/viewtopic.php?t=18677
# 	<dukelovett> URL Title: egghelp.org community :: View topic - Durltitle -
#                Modern fork of 'urltitle'. Latest version: 0.1.3
#
#
################################################################################
#
# Configs:
#
set urltitle(ignore) "bdkqr|dkqr" 	;# User flags script will ignore input from
set urltitle(pubmflags) "-|-" 		;# user flags required for channel eggdrop use
set urltitle(length) 5	 		;# minimum url length to trigger channel eggdrop use
set urltitle(delay) 1 			;# minimum seconds to wait before another eggdrop use
set urltitle(timeout) 60000 		;# geturl timeout (1/1000ths of a second)

################################################################################
# Fixes by lee8oi@gmail.com
#
# 1.Modified urltitle proc to check if http variable was created. 'https' url
# type causes error and http variable doesn't get created. This allows the script
# to at least offer a generic reply in that event.
# 2.Modified urltitle to grab meta Location from urls that have "Moved Permanently"
# and rerun urltitle using the new url.
# 3.Added Regsubs to urltitle proc to clean up title info. Also added htmlparse
# require to help further clean up html markups from title info.
# 4.Attempted a fix to get utf-8 to correctly output.
# 5.stripped script back down to 'near original' and reimplemented utf-8 fix in
# the urltitle proc instead of the pubm_urltitle proc.
# 6.Added redirect fix which checks for meta(Location) and recursively calls itself
# with the new url.
# 7.Implemented 'durltitle' namespace. For the benefits of namespaces.
# 8.Added another piece 'encoding' code to try to solve the utf-8 issues. Testing
# is needed.
# 9.Further added to the encoding code in hopes to see some results on the encoding
# front. This may or may not work. But it should be a step in the right direction.
#
################################################################################
# Script begins:
set urltitle(last) 111 			;# stores time of last eggdrop use, don't change..
}

package require http			;# You need the http package..
package require htmlparse	;# You need htmlparse package.
package require tls
::http::register https 443 [list ::tls::socket -require 0 -request 1]
setudef flag urltitle			;# Channel flag to enable script.
setudef flag logurltitle		;# Channel flag to enable logging of script.
set urltitlever "0.1.9"

bind pubm ::durltitle::urltitle(pubmflags) {*://*} ::durltitle::pubm:urltitle
namespace eval durltitle {
	proc pubm:urltitle {nick host user chan text} {
		variable ::durltitle::urltitle
		if {([channel get $chan urltitle]) && ([expr {[unixtime] - $urltitle(delay)}] > \
		$urltitle(last)) && (![matchattr $user $urltitle(ignore)])} {
			foreach word [split $text] {
				set word [encoding convertfrom $word]
				if {[string length $word] >= $urltitle(length) && \
				[regexp {^(f|ht)tp(s|)://} $word] && \
				![regexp {://([^/:]*:([^/]*@|\d+(/|$))|.*/\.)} $word]} {
					set urltitle(last) [unixtime]
					set urtitle [::durltitle::urltitle $word]
					if {[string length $urtitle]} {
						#puthelp "PRIVMSG $chan :URL Title for $word - \002$urtitle\002"
						puthelp "PRIVMSG $chan :URL Title: \002$urtitle\002"
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
			variable ::durltitle::urltitle
			catch {set http [::http::geturl $url -timeout $urltitle(timeout)]} error
			if {[string match -nocase "*couldn't open socket*" $error]} {
				return "Error: couldn't connect..Try again later"
			}
			if {![info exists http]} {
				return "None or unsupported URL type."
			} else {
				if { [::http::status $http] == "timeout" } {
					return "Error: connection timed out while trying to contact $url"
				}
				upvar #0 $http state
				array set meta $state(meta)
				set data [split [::http::data $http] \n]
				# ENCODING - This is just an attempt to get encoding to work generally
				# There are still character maps that do not display correctly.
				if {[lsearch -exact [encoding names] $state(charset)] != -1} {
					set data [encoding convertfrom $state(charset) $data]
				}
				# END ENCODING
				::http::cleanup $http
				set title ""
				if {[regexp -nocase {<title>(.*?)</title>} $data match title]} {
					set output [string map { {href=} "" \" "" } $title]
					if {[info exists meta(Location)]} {
						return [::durltitle::urltitle $meta(Location)]
					} else {
						regsub -all -- {(?:<b>|</b>)} $output "\002" output
						regsub -all -- {<.*?>} $output "" output
						regsub -all -- {(?:<b>|</b>)} $output "\002" output
						regsub -all -- {<.*?>} $output "" output
						regsub -all \{ $output {\&ob;} output
						regsub -all \} $output {\&cb;} output
						return [htmlparse::mapEscapes $output]
					}
				} else {
					return "No title found."
				}
			}
		}
	}
}
putlog "Url Title Grabber $urltitlever (lee8oi) script loaded.."