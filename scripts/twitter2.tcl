#
# 0.1 - Feb 6 2010
#
# Created by fedex and cd. www.summercat.com for updates
#
# Requirements: Tcl 8.5+ and tcllib of some version (for base64, json)
#
# Essentially a twitter client for IRC. Follow updates from tweets of all
# those you follow on the given account.
#
# Usage notes:
#  - Stores states in variable $idfile file in eggdrop root directory
#  - Default time between tweet fetches is 10 minutes. Alter the "bind time"
#    option below to change to a different setting. Right now there is only
#    options for 1 minute or 10 minutes.
#  - Accepts commands issued by anyone right now! Perhaps if you wish to use
#    in a channel with untrusted people, have one channel for output and one
#    for controlling the script client style (+twitter)
#
# Setup:
#  - Place your username and pass in the variables user and pas
#  - Set the channel variable as the channel where tweets will be output
#  - .chanset #channel +twitter to provide access to !commands in #channel
#
# Commands:
#  - !twit - send a tweet
#  - !twit_msg
#  - !twit_trends
#  - !follow
#  - !unfollow
#  - !twit_updates
#  - !twit_msgs
#  - !twit_search
#  - !followers
#  - !following
#  - !retweet
#
# TODO:
#

package require http
# tcllib packages
package require base64
package require json

namespace eval twitter {
	variable user "pulinainfo"
	variable pass "lk3kRBk6i"
	variable channel "#pulina"

	# Only have one of these uncommented
	# Check for tweets every 1 min
	#bind time - "* * * * *" twitter::update
	# Check for tweets every 10 min
	bind time - "?0 * * * *" twitter::update

	variable idfile "twitter.last_id"

	#variable output_cmd "cd::putnow"
	variable output_cmd "putserv"

	variable last_id
	variable last_update
	variable last_msg

	variable status_url "https://twitter.com/statuses/update.json"
	variable home_url "https://api.twitter.com/statuses/home_timeline.json"
	variable msg_url "https://twitter.com/direct_messages/new.xml"
	variable msgs_url "https://twitter.com/direct_messages.json"
	variable trends_curr_url "https://search.twitter.com/trends/current.json"
	variable follow_url "https://twitter.com/friendships/create.json"
	variable unfollow_url "https://twitter.com/friendships/destroy.json"
	variable search_url "https://search.twitter.com/search.json"
	variable followers_url "https://twitter.com/statuses/followers.json"
	variable following_url "https://twitter.com/statuses/friends.json"
	variable retweet_url "https://api.twitter.com/statuses/retweet/"

	bind pub	o|o "!twit" twitter::tweet
	bind pub	o|o "!twit_msg" twitter::msg
	bind pub	o|o "!twit_trends" twitter::trends
	bind pub	o|o "!follow" twitter::follow
	bind pub	o|o "!unfollow" twitter::unfollow
	bind pub	o|o "!twit_updates" twitter::updates
	bind pub	o|o "!twit_msgs" twitter::msgs
	bind pub	o|o "!twit_search" twitter::search
	bind pub	o|o "!followers" twitter::followers
	bind pub	o|o "!following" twitter::following
	bind pub	o|o "!retweet" twitter::retweet
	bind evnt	o|o "save" twitter::write_states

	setudef flag twitter
}


# Output decoded/split string to given channel
proc twitter::output {chan str} {
	set str [twitter::decode_html $str]
	foreach line [twitter::split_line 400 $str] {
		$twitter::output_cmd "PRIVMSG $chan :$line"
	}
}


# Format status updates and output
proc twitter::output_update {chan name id text} {
	twitter::output $chan "\[\002$name\002\] $text ($id)"
}


# Retweet given id
proc twitter::retweet {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[string length $argv] < 1 || ![regexp {^\d+$} $argv]} {
		$twitter::output_cmd "PRIVMSG $chan :Usage: !retweet <id>"
		return
	}

	# Setup url since id is not given as params for some reason...
	set url "${twitter::retweet_url}${argv}.json"

	if {[catch {twitter::query $url {} POST} result]} {
		$twitter::output_cmd "PRIVMSG $chan :Retweet failure. ($argv) (You can't retweet your own updates!)"
		return
	}

	$twitter::output_cmd "PRIVMSG $chan :Retweet sent."
}


# Follow a user (by screen name)
proc twitter::follow {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[string length $argv] < 1} {
		$twitter::output_cmd "PRIVMSG $chan :Usage: !follow <screen name>"
		return
	}

	if {[catch {twitter::query $twitter::follow_url [list screen_name $argv]} result]} {
		$twitter::output_cmd "PRIVMSG $chan :Twitter failed or already friends with $argv!"
		return
	}

	if {[dict exists $result error]} {
		twitter::output $chan "Follow failed ($argv): [dict get $result error]"
		return
	}

	twitter::output $chan "Now following [dict get $result screen_name]!"
}


# Unfollow a user (by screen name)
proc twitter::unfollow {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[string length $argv] < 1} {
		$twitter::output_cmd "PRIVMSG $chan :Usage: !unfollow <screen name>"
		return
	}

	if {[catch {twitter::query $twitter::unfollow_url [list screen_name $argv]} result]} {
		$twitter::output_cmd "PRIVMSG $chan :Unfollow failed. ($argv)"
		return
	}

	if {[dict exists $result error]} {
		twitter::output $chan "Unfollow failed ($argv): [dict get $result error]"
		return
	}

	twitter::output $chan "Unfollowed [dict get $result screen_name]."
}


# Get last n, n [1, 20] updates
proc twitter::updates {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[string length $argv] < 1 || ![string is integer $argv] || $argv > 20 || $argv < 1} {
		$twitter::output_cmd "PRIVMSG $chan :Usage: !twit_updates <#1 to 20>"
		return
	}

	if {[catch {twitter::query $twitter::home_url [list count $argv]} result]} {
		$twitter::output_cmd "PRIVMSG $chan :Retrieval error."
		return
	}

	if {[llength $result] == 0} {
		$twitter::output_cmd "PRIVMSG $chan :No updates."
		return
	}

	set result [lreverse $result]
	foreach status $result {
		dict with status {
#			twitter::output $chan "\[\002[dict get $user screen_name]\002\] $text"
			twitter::output_update $chan [dict get $user screen_name] $id $text
		}
	}
}


# Return top 5 results for query $argv
proc twitter::search {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[string length $argv] < 1 || [string length $argv] > 140} {
		$twitter::output_cmd "PRIVMSG $chan :Usage: !twit_search <string 140 chars or less>"
		return
	}

	if {[catch {twitter::query $twitter::search_url [list q $argv]} data]} {
		$twitter::output_cmd "PRIVMSG $chan :Search error ($argv)"
		return
	}

	if {[dict exists $data error]} {
		twitter::output $chan "Search failed ($argv): [dict get $result error]"
		return
	}

	set results [dict get $data results]
	set count 0
	foreach result $results {
		twitter::output $chan "#[incr count] \002[dict get $result from_user]\002 [dict get $result text]"
		if {$count > 4} {
			break
		}
	}
}


# Return latest followers (up to 100)
proc twitter::followers {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[catch {twitter::query $twitter::followers_url} result]} {
		$twitter::output_cmd "PRIVMSG $chan :Error fetching followers."
	}

	# Make first followers -> last followers
	set result [lreverse $result]

	set followers []
	foreach user $result {
		set followers "$followers[dict get $user screen_name] "
	}

	twitter::output $chan "Followers: $followers"
}


# Returns the latest users following acct is following (up to 100)
proc twitter::following {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[catch {twitter::query $twitter::following_url} result]} {
		$twitter::output_cmd "PRIVMSG $chan :Error fetching friends."
		return
	}

	# Make first following -> last following
	set result [lreverse $result]

	set following []
	foreach user $result {
		set following "$following[dict get $user screen_name] "
	}

	twitter::output $chan "Following: $following"
}


# Get trends
proc twitter::trends {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[catch {twitter::query $twitter::trends_curr_url} result]} {
		$twitter::output_cmd "PRIVMSG $chan :Trend fetch failed!"
		return
	}

	set trends [dict get $result trends]
	set output []
	set count 0
	foreach day [dict keys $trends] {
		foreach trend [dict get $trends $day] {
			set output "$output\002#[incr count]\002 [dict get $trend name] "
		}
	}

	twitter::output $chan $output
}


# Direct messages
# Get last n, n [1, 20] messages or new if no argument
proc twitter::msgs {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[string length $argv] == 1 && [string is integer $argv] && $argv < 20} {
		set params [list count $argv]
	} else {
		set params [list since_id $twitter::last_msg]
	}

	if {[catch {twitter::query $twitter::msgs_url $params GET} result]} {
		$twitter::output_cmd "PRIVMSG $chan :Messages retrieval failed."
		return
	}

	if {[llength $result] == 0} {
		$twitter::output_cmd "PRIVMSG $chan :No new messages."
		return
	}

	foreach msg $result {
		dict with msg {
			if {$id > $twitter::last_msg} {
				set twitter::last_msg $id
			}
			twitter::output $chan "\002From\002 $sender_screen_name: $text ($created_at)"
		}
	}
}


# Send direct message to a user
proc twitter::msg {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[llength [split $argv]] < 2 || [string length [join [lrange [split $argv] 1 end]]] > 140} {
		$twitter::output_cmd "PRIVMSG $chan :Usage: !twit_msg <username> <msg 140 chars or less>"
		return
	}

	set l [list screen_name [lindex $argv 0] text [lrange $argv 1 end]]

	if {[catch {twitter::query $twitter::msg_url $l} data]} {
		$twitter::output_cmd "PRIVMSG $chan :Message to \002$argv\002 failed! (Are they following you?)"
	} else {
		twitter::output $chan "Message sent."
	}
}


# Send status update (tweet)
proc twitter::tweet {nick uhost hand chan argv} {
	if {![channel get $chan twitter]} { return }

	if {[string length $argv] > 140 || $argv == ""} {
		$twitter::output_cmd "PRIVMSG $chan :Usage: !tweet <less than 140 characters>"
	}

	if {[catch {twitter::query $twitter::status_url [list status $argv]} result]} {
		$twitter::output_cmd "PRIVMSG $chan :Tweet failed! HTTP error. ($argv)"
		return
	}

	set update_id [dict get $result id]
	if {$update_id == $twitter::last_update} {
		$twitter::output_cmd "PRIVMSG $chan :Tweet failed: Duplicate of tweet #$update_id. ($argv)"
		return
	}
	set twitter::last_update $update_id

	twitter::output $chan "Tweet sent."
}


# Grab unseen status updates
proc twitter::update {min hour day month year} {
	if {[catch {twitter::query $twitter::home_url [list since_id $twitter::last_id]} result]} {
		putlog "Twitter is busy."
		return
	}

	set result [lreverse $result]

	foreach status $result {
		dict with status {
#			twitter::output $twitter::channel "\[\002[dict get $user screen_name]\002\] $text"
			twitter::output_update $twitter::channel [dict get $user screen_name] $id $text

			if {$id > $twitter::last_id} {
				set twitter::last_id $id
			}
		}
	}
}


# Twitter http query
proc twitter::query {url {query_list {}} {http_method {}}} {
	set auth [base64::encode "${twitter::user}:${twitter::pass}"]
	set header [list Authorization [concat "Basic" $auth]]

	# Set http mode of query
	if {$http_method eq "" && $query_list ne ""} {
		set method POST
	} elseif {$http_method eq "" && $query_list eq ""} {
		set method GET
	} else {
		set method $http_method
	}

	set query [http::formatQuery {*}$query_list]
	set token [http::geturl $url -headers $header -query $query -method $method]

#	if {$query_list ne ""} {
#		set query [http::formatQuery {*}$query_list]
#		set token [http::geturl $url -headers $header -query $query]
#	} else {
#		set token [http::geturl $url -headers $header]
#	}

	set data [http::data $token]
	set ncode [http::ncode $token]
	http::cleanup $token

	if {$ncode != 200} {
		putlog "HTTP query failed: $ncode (URL: $url) (QUERY_LIST: $query_list) (QUERY: $query) (METHOD: $http_method) (USED METHOD: $method)"
		error "HTTP query failed: $ncode"
	}

	return [json::json2dict $data]
}


# Get saved ids/state
proc twitter::get_states {} {
	if {[catch {open $twitter::idfile r} fid]} {
		set twitter::last_id 1
		set twitter::last_update 1
		set twitter::last_msg 1
		return
	}

	set data [read -nonewline $fid]
	set states [split $data \n]

	close $fid

	set twitter::last_id [lindex $states 0]
	set twitter::last_update [lindex $states 1]
	set twitter::last_msg [lindex $states 2]
}


# Save states to file
proc twitter::write_states {args} {
	set fid [open $twitter::idfile w]
	puts $fid $twitter::last_id
	puts $fid $twitter::last_update
	puts $fid $twitter::last_msg
	close $fid
}


# Split long line into list of strings for multi line output to irc
# Splits into strings of ~max
# by fedex
proc twitter::split_line {max str} {
	set last [expr {[string length $str] -1}]
	set start 0
	set end [expr {$max -1}]

	set lines []

	while {$start <= $last} {
		if {$last >= $end} {
			set end [string last { } $str $end]
		}

		lappend lines [string trim [string range $str $start $end]]
		set start $end
		set end [expr {$start + $max}]
	}

	return $lines
}

# From perpleXa's urbandictionary script
# Replaces html special chars with their hex equivalent
proc twitter::decode_html {str} {
	set escapes {
		&nbsp; \x20 &quot; \x22 &amp; \x26 &apos; \x27 &ndash; \x2D
		&lt; \x3C &gt; \x3E &tilde; \x7E &euro; \x80 &iexcl; \xA1
		&cent; \xA2 &pound; \xA3 &curren; \xA4 &yen; \xA5 &brvbar; \xA6
		&sect; \xA7 &uml; \xA8 &copy; \xA9 &ordf; \xAA &laquo; \xAB
		&not; \xAC &shy; \xAD &reg; \xAE &hibar; \xAF &deg; \xB0
		&plusmn; \xB1 &sup2; \xB2 &sup3; \xB3 &acute; \xB4 &micro; \xB5
		&para; \xB6 &middot; \xB7 &cedil; \xB8 &sup1; \xB9 &ordm; \xBA
		&raquo; \xBB &frac14; \xBC &frac12; \xBD &frac34; \xBE &iquest; \xBF
		&Agrave; \xC0 &Aacute; \xC1 &Acirc; \xC2 &Atilde; \xC3 &Auml; \xC4
		&Aring; \xC5 &AElig; \xC6 &Ccedil; \xC7 &Egrave; \xC8 &Eacute; \xC9
		&Ecirc; \xCA &Euml; \xCB &Igrave; \xCC &Iacute; \xCD &Icirc; \xCE
		&Iuml; \xCF &ETH; \xD0 &Ntilde; \xD1 &Ograve; \xD2 &Oacute; \xD3
		&Ocirc; \xD4 &Otilde; \xD5 &Ouml; \xD6 &times; \xD7 &Oslash; \xD8
		&Ugrave; \xD9 &Uacute; \xDA &Ucirc; \xDB &Uuml; \xDC &Yacute; \xDD
		&THORN; \xDE &szlig; \xDF &agrave; \xE0 &aacute; \xE1 &acirc; \xE2
		&atilde; \xE3 &auml; \xE4 &aring; \xE5 &aelig; \xE6 &ccedil; \xE7
		&egrave; \xE8 &eacute; \xE9 &ecirc; \xEA &euml; \xEB &igrave; \xEC
		&iacute; \xED &icirc; \xEE &iuml; \xEF &eth; \xF0 &ntilde; \xF1
		&ograve; \xF2 &oacute; \xF3 &ocirc; \xF4 &otilde; \xF5 &ouml; \xF6
		&divide; \xF7 &oslash; \xF8 &ugrave; \xF9 &uacute; \xFA &ucirc; \xFB
		&uuml; \xFC &yacute; \xFD &thorn; \xFE &yuml; \xFF
	}

	return [string map $escapes $str]
}

# Read states on load
twitter::get_states

putlog "Script loaded: \002twitter 0.1 (c) fedex\002"
