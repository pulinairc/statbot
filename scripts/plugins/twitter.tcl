# Tweet URLs mentioned on the channel, or their tinyurl the tinyurl plugin is
# loaded. Can be used by other Tcl scripts to just tweet anything.
# Uses tdom to parse the mobile twitter website, i.e. works by screen scraping,
# not by using the API (Patches welcome, btw, but if you're just tweeting, this
# works fine.)
# See twitter.conf for the settings (append them to your urlmagic config)

set VERSION 1.1+hg

package require tdom

proc logged_in {} {
	variable cookies
	if {![info exists cookies(mobile.twitter.com)]} { return 0 }
	set idx [lsearch -glob $cookies(mobile.twitter.com) oauth_token*]
	if {$idx < 0} { return 0 }
	set oauth_token [lindex $cookies(mobile.twitter.com) $idx]
	set token [lindex [split $oauth_token =] 1]
	if {[string length $token]} { return 1 } { return 0 }
}

proc twitter_login {{tries 0}} {
	variable settings
	variable cookies

	set data [fetch "https://mobile.twitter.com/session/new"]

	set dom [dom parse -html $data]
	set root [$dom documentElement]
	set forms [$root selectNodes {//form}]
	set form [lindex $forms 0]
	set inputs [$form selectNodes {//input}]
	set url [$form getAttribute action]

	foreach input $inputs {
		catch { set post([$input getAttribute name]) [$input getAttribute value] }
	}

	$dom delete

	set post(username) $settings(username)
	set post(password) $settings(password)

	foreach {name value} [array get post] {
		lappend postdata [::http::formatQuery $name $value]
	}

	fetch $url [join $postdata "&"]
	
	if {[logged_in]} { return }

	if {[incr tries] < 3} { twitter_login $tries } { putlog "Twitter login failed.  Tried $tries times." }

}

proc tweet {what} {
	variable settings
	variable cookies

	set what [string range $what 0 139]

	if {![logged_in]} { twitter_login }

	set twitter_url "https://mobile.twitter.com/compose/tweet"
	set data [fetch $twitter_url]

	if {[catch {
		set dom [dom parse -html $data]
		set root [$dom documentElement]
		set forms [$root selectNodes {//form[@class='tweetform']}]
		set form [lindex $forms 0]
		set inputs [$form selectNodes {//input}]
		set url [$form getAttribute action]
		set textareas [$form selectNodes {//textarea[@class='tweetbox']}]
		set textarea [lindex $textareas 0]
	} err]} { putlog "Damn dom.  $err"; foreach l [split $data \n] { putlog $l } }

	foreach input $inputs {
		catch { set post([$input getAttribute name]) [$input getAttribute value] }
	}

	set post([$textarea getAttribute name]) $what

	$dom delete

	foreach {name value} [array get post] {
		lappend postdata [::http::formatQuery $name $value]
	}

	fetch [relative $twitter_url $url] [join $postdata "&"]
}

proc tweet_url {} {
	upvar #0 ::urlmagic::title t

	set text $t(url)
	if {[info exists t(tinyurl)] && $t(tinyurl) != ""} {
		set text $t(tinyurl)
	}

	lappend text $t(title)
	tweet "<$t(nick)> [join $text]"
}

proc init_plugin {} {
	variable settings
	variable ns
	setudef flag $settings(udef-flag)

	if {$settings(tweet-urls-at-all)} {
		hook::bind urlmagic <Post-String> [myself] ${ns}::tweet_url
	}
}

proc deinit_plugin {} {
	hook::forget [myself]
}
