#!/usr/bin/env tclsh
#
# This is a fairly horrible (made so by the lack of a proper and pretty CGI/HTML
# module for Tcl) CGI script for generating a stats page about the URLs posted
# into a channel. It was written in Tcl because this is guaranteed to be present
# on a machine hosting eggdrop bots, although I might rewrite it in something
# else one day. It does "authentication" by checking your nick against the
# people in the database who already posted an URL, to avoid unauthorized people
# and search engines to snoop through your channel URLs.
#
#
# MIT/X Consortium License
#
# Copyright (c) 2012-2013 by Moritz "ente" Wilhelmy
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.


######### CONFIGURE THESE AS YOU DEEM FIT ######################################
# It's important to use the full path to the urlmagic database here, because the
# HTTP server probably runs CGI scripts under a different user ID.
set dbfile /home/yourusername/eggdrop/urlmagic.db

proc setCookie {} { 
	# You need to fill in your domain and (optionally) a path restriction to which
	# the cookie is sent. Uncomment *only one* of the examples or you might end up
	# sending multiple cookies to the browser.

	# Example 1: Just the domain name (and any subdomain, indicated by the
	# dot before the domain name)
	##ncgi::setCookie -name pnick -value $::nick -domain .example.com ; return
	
	# Example 2: All URLs matching the exact domain example.com under the path of
	# /~eggdrop/ are being sent the cookie. This variant is more secure. Use
	# it if you know the exact path the resource will be available on.
	##ncgi::setCookie -name pnick -value $::nick -domain example.com -path /~eggdrop/ ; return
}

# The name of your eggdrop bot. Additionally, you need to add it to index.html
set botname "LameBot"

# Set this to the domain or common name of the IRC network your bot runs on to
# generate clickable links for channels
set ircnetwork "IRCnet"
######### END OF USER CONFIGURATION SECTION ####################################

set start_time [clock milliseconds]

package require sqlite3
package require html
package require ncgi

proc datetime {sec {time 1}} {
	if $time {
		clock format $sec -format "%Y-%m-%d %R" -gmt 1
	} else {
		clock format $sec -format "%Y-%m-%d" -gmt 1
	}
}

interp alias {} sanitize {} html::html_entities

proc % {args} {
	if {[llength $args]==0} {
		puts [html::closeTag]
	} else {
		puts [html::openTag {*}$args] 
	}
}

proc authfail {} {
	ncgi::redirect .
	exit
}

ncgi::parse

set nick [ncgi::value login]
set cookies [ncgi::cookie pnick]

sqlite3 db $dbfile

if {[llength $cookies] != 0} {
	set nick [lindex $cookies 0]
} elseif {![string length $nick]} {
	authfail
}

db eval {SELECT COUNT(*) AS c FROM urls WHERE last_mentioned_by = :nick} {
	if {$c == 0} authfail
}

if {[llength $cookies] == 0} {
	setCookie
}

proc footer {} {
	set now [clock milliseconds]

	% small style=\"color:#aaa\"
		puts "Page generated in [expr {$now-$::start_time}] ms<br>"
	%

	puts [html::end]
}

proc puttotal {count str} {
	% tr
		% td
			puts $str
		%
		% td style=\"text-align:right\"
			puts $count
		%
	%
}

proc stats {} {
	% table
		% thead
			% tr
				% th
					puts "Description"
				%
				% th style=\"text-align:right\"
					puts "Total"
				%
			%
		%
		% tbody


	# Well, this part could be done prettier, but it is what it is. Patches
	# welcome.
	db eval {SELECT MIN(last_mentioned) AS min, COUNT(*) AS count FROM urls WHERE last_mentioned <> 0} {
		puttotal $count "Total number of unique URLs since [datetime $min no]"
	}

	db eval {SELECT SUM(mention_count) AS count FROM urls} {
		puttotal $count "Same including duplicates"
	}

	db eval {SELECT COUNT(*) AS count FROM urls WHERE url LIKE "%imgur.com/%"} {
		puttotal $count "Total number of unique imgur URLs"
	}

	db eval {SELECT COUNT(*) AS count FROM urls WHERE url LIKE "%youtube.com/%" OR url LIKE "%youtu.be/%"} {
		puttotal $count "Total number of unique youtube URLs"
	}

	db eval {SELECT COUNT(*) AS count FROM urls WHERE url LIKE "%plus.google.com/hangouts/%"} {
		puttotal $count "Total number of google hangout URLs"
	}

	db eval {SELECT COUNT(*) AS count FROM urls WHERE url LIKE "%facebook.com/%" OR url LIKE "%fbcdn.net/%"} {
		puttotal $count "Total number of facebook URLs"
	}

	db eval {SELECT COUNT(*) AS count FROM urls WHERE url LIKE "%tumblr.com/%"} {
		puttotal $count "Total number of tumblr URLs"
	}

	db eval {SELECT COUNT(*) AS count FROM urls WHERE url LIKE "%reddit.com/%" OR url LIKE "%redd.it/%"} {
		puttotal $count "Total number of reddit URLs"
	}

	% ;# tbody
	% ;# table
}

ncgi::header "text/html; charset=utf-8"
set view [ncgi::value view "mostwanted"]
puts "<!DOCTYPE html>"

html::init

html::headTag {link href="table.css" rel="stylesheet" type="text/css"}
html::headTag {link href="main.css" rel="stylesheet" type="text/css"}

puts [html::head "$botname's most wanted"]
puts [html::bodyTag]

proc header {view} {
	global botname
	if {$view eq "mostwanted"} {
		puts [html::h1 "$botname's 50 most wanted links"]
	} elseif {$view eq "recent"} {
		puts [html::h1 "$botname's 50 most recent links"]
	} elseif {$view eq "stats"} {
		puts [html::h1 "Random statistics"]
	}
}

header $view

% ul
	% li
		% a "href=\"?view=recent\""
			puts "most recent"
		%
	%
	% li
		#% a "href=\"?login=[sanitize $nick]&amp;view=mostwanted\""
		% a "href=\"?view=mostwanted\""
			puts "most wanted"
		%
	%
	% li
		#% a "href=\"?login=[sanitize $nick]&amp;view=mostwanted\""
		% a "href=\"?view=stats\""
			puts "statistics"
		%
	%
%

if {$view eq "stats"} {
	stats
	puts [html::end]
	footer
	exit
} else {
	puts "<div class='notice'><p><b>Note: Some of these URLs are NSFW. If you're at work, it might be best to avoid this page entirely.</b></div>"
}
	

% table
	% thead
		% tr
		foreach v {"URL" "how often" "last mentioned by" "channel"} {
			% th
				puts $v
			%
		
		}
			% th style=\"text-align:right\"
				puts "last mentioned (UTC)"
			%
		%
	%
	% tbody


set sql {SELECT * FROM urls WHERE last_mentioned > 0
		ORDER BY mention_count DESC,last_mentioned DESC
		LIMIT 50}
if {$view eq "recent"} {
	set sql {
	SELECT * FROM urls WHERE last_mentioned > 0
		ORDER BY last_mentioned DESC,mention_count DESC
		LIMIT 50}
}

db eval $sql {
	% tr
		% td
			if {[string length $html_title] > 0} {
				set title [sanitize $html_title]
				% a "href=\"[sanitize $url]\" title=\"$title\""
			} elseif {[string length $content_type] > 0} {
				set title "Content Type: [sanitize $content_type]"
				% a "href=\"[sanitize $url]\" title=\"$title\""
			} else {
				% a href=\"[sanitize $url]\"
			}
			if {[string length $url] > 63} {
				puts [sanitize [string range $url 0 60]...]
			} else {
				puts [sanitize $url]
			}
			% ;# a
		%
		% td
			puts [sanitize $mention_count]
		%
		% td
			puts [sanitize $last_mentioned_by]
		%
		% td
			% a href=\"irc://$ircnetwork/[sanitize $last_mentioned_on]\"
			puts [sanitize $last_mentioned_on]
			%
		%
		% td style=\"text-align:right\"
			puts [datetime $last_mentioned]
		%
	%
}

%

% ;# table

footer

# $Id: mostwanted.cgi,v 1.12 2013/02/16 18:42:12 eggderp Exp $
