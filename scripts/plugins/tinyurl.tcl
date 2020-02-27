# This plugin creates a tinyurl at tinyurl.com if the URL is longer than a
# certain threshold.

package require http

set VERSION 1.1+hg

proc tinyurl {url} {
	variable settings
	set result {}
	set query [::http::formatQuery $settings(tinyurl-post-field) $url compact 1]
	catch {
		set tok [::http::geturl $settings(tinyurl-service) -query $query -timeout $settings(timeout)]
		upvar #0 $tok state
		if {[string match -nocase "* 200 OK" $state(http)]
		&&  [string match -nocase "text/plain*" $state(type)]} {
			set result [lindex [split $state(body) \n] 0]
		}
		::http::cleanup $tok
	}
	return $result
}

proc add_tiny {} {
	upvar #0 ::urlmagic::title t
	if {[info exists t(tinyurl)] && $t(tinyurl) != ""} {
		lappend t(output) "->" $t(tinyurl)
	}
}

# FIXME: tinyurl the expanded url or the original URL?
proc make_tiny {} {
	upvar #0 ::urlmagic::title t
	variable settings

	if {[string length $t(url)] >= $settings(maxlength)} {
		set t(tinyurl) [tinyurl $t(url)]
	}
}

proc init_plugin {} {
	variable ns
	hook::bind urlmagic <Pre-String> [myself] ${ns}::make_tiny
	hook::bind urlmagic <String> [myself] ${ns}::add_tiny
}

proc deinit_plugin {} {
	hook::forget [myself]
}
