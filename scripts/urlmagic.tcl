#! tclsh
# Copyright (c) 2011      by Steve "rojo" Church
#           (c) 2013-2014 by Moritz "ente" Wilhelmy
#
# See the README, INSTALL and LICENSE files for more information.
# Most people will want to skip this file entirely and will only need to modify
# the config file.

# User variables, allow changing the config file that will be loaded by urlmagic:
namespace eval ::urlmagic {

# Don't change this. It points to the directory where urlmagic is located.
set settings(base-path) [file dirname [info script]]

# Specifies the config file which contains all other settings for urlmagic.
# Defaults to the file "urlmagic.conf" in the same directory this script is
# located in.
set settings(config-file) "$settings(base-path)/urlmagic.conf"

# .chanset #channel +urlmagic -- change this if you want to use a different
# flag to enable urlmagic on a channel. Setting this is deprecated because I
# see no good reason to being able to change it. Do not change.
# (If you know a good reason, I'd be willing to de-deprecate it)
set settings(udef-flag) urlmagic

}

################################################################################
#                        End of user variables                                 #
################################################################################


if {[catch {package require Tcl 8.5} err]} {
	putlog "Error loading urlmagic: Tcl too old. Please see README."
	putlog " $err or higher"
	unset err
	return false
}

namespace eval ::urlmagic {

foreach lib {http tls hook} {
	if {[catch {package require $lib}]} {
		putlog "Error loading urlmagic: Library $lib is missing. See README for more information."
		return false
	}
}
unset lib

# Returns a plugin's namespace name with any surrounding ":" characters stripped
# Used as the event identifier for the hook module
proc myself {} {
	string trim [uplevel 1 namespace current] :
}

proc warn {text} {
	putlog "\002(Warning)\002 [myself]: $text"
}

if {! [file exists $settings(config-file)]} {
	warn "Configuration file $settings(config-file) does not exist. Bailing out."
	warn "Make sure to read the README"
	return 1
}

variable VERSION 1.1+hg
variable cookies
variable ns [namespace current]
variable ignores ;# temporary ignores

variable title ;# contains process_title's things, also used for string building by hooks

proc unignore {nick uhost hand chan msg} {
	# HACK: just unignore someone leaving *any* channel
	variable ignores
	catch { unset ignores($uhost) }
}

proc ignore {uhost chan} {
	variable ignores; variable settings

	set now [unixtime]

	if {$settings(seconds-between-user) && [info exists ignores($uhost)]
	&& $ignores($uhost) > $now - $settings(seconds-between-user) } then {
		incr ignores($uhost) $settings(url-flooding-penalty)
		return 1
	}

	if {$settings(seconds-between-channel) && [info exists ignores($chan)]
	&& $ignores($chan) > $now - $settings(seconds-between-channel) } then {
		# introducing a penalty for a noisy channel doesn't seem particularly useful
		return 1
	}

	set ignores($uhost) $now
	set ignores($chan) $now

	return 0
}

proc find_urls {nick uhost hand chan txt} {

	variable settings; variable ns

	if {[matchattr $hand $settings(ignore-flags)] || ![channel get $chan $settings(udef-flag)]} { return }

	if {[regexp -nocase $settings(url-regex) $txt url] && [string length $url] > 7} {

		if {[ignore $uhost $chan]} return

		# FIXME should this be just // to account for URLs like //imgur.com/ where the protocol is implicit?
		# In any case, wouldn't work as expected. rewrite.
		set url_complete [string match *://* $url]
		if {!$url_complete} { set url "http://$url" }

		variable title
		# nuke array
		foreach v [array names title] { unset title($v) }

		array set title [list nick $nick uhost $uhost hand $hand \
			chan $chan text $txt was-complete $url_complete]
		# $title(url, content-length, tinyurl [where $url length > max], title, error [boolean])
		process_title $url

		set title_or_content_type [any $title(title) "Content type: $title(content-type)"]

		# list used for string building
		set title(output) [list \
			[format $settings(nick-format) $nick] \
			[format $settings(title-format) $title_or_content_type]]

		# Pre-String hook: Called before the string builders are invoked.
		hook::call urlmagic <Pre-String> 

		# String hook: Called for all string builders
		hook::call urlmagic <String>

		set chan [chandname2name $chan] ;# support for IRCnet !channels

		# kill all "" instances so we don't get extraneous space
		# characters in case an empty string is inserted somewhere via
		# e.g. $settings(nick-format) or a sloppy plugin.
		set title(output) [lsearch -inline -not -all $title(output) ""]

		if {!$settings(global-silent) && ![channel get $chan urlmagic-silent]} {
			puthelp "PRIVMSG $chan :[join $title(output)]"
		}

		# Post-String hook: Called after everything is done
		hook::call urlmagic <Post-String>
	}
}

# TODO: rewrite cookie code.
# use cron bind to expire both old cookies and ignores
proc update_cookies {tok} {
	variable cookies; variable settings; variable ns

	upvar #0 $tok state
	set domain [lindex [split $state(url) /] 2]
	if {![info exists cookies($domain)]} { set cookies($domain) [list] }
	foreach {name value} $state(meta) {

		if {[string equal -nocase $name "Set-Cookie"]} {

			if {[regexp -nocase {expires=([^;]+)} $value - expires]} {

				if {[catch {expr {([clock scan $expires -gmt 1] - [clock seconds]) / 60}} expires] || $expires < 1 } {
					set expires 15
				} elseif {$expires > $settings(max-cookie-age)} {
					set expires $settings(max-cookie-age)
				}
			} { set expires $settings(max-cookie-age) }

			set value [lindex [split $value \;] 0]
			set cookie_name [lindex [split $value =] 0]

			set expire_command [list ${ns}::expire_cookie $domain $cookie_name]

			if {[set pos [lsearch -glob $cookies($domain) ${cookie_name}=*]] > -1} {
				set cookies($domain) [lreplace $cookies($domain) $pos $pos $value]
				foreach t [timers] {
					if {[lindex $t 1] == $expire_command} { killtimer [lindex $t 2] }
				}
			} else {
				lappend cookies($domain) $value
			}

			timer $expires $expire_command
		}
	}
}

proc expire_cookie {domain cookie_name} {
	variable cookies
	if {![info exists cookies($domain)]} { return }
	if {[set pos [lsearch -glob $cookies($domain) ${cookie_name}=*]] > -1} {
		set cookies($domain) [lreplace $cookies($domain) $pos $pos]
	}
	if {![llength $cookies($domain)]} { unset cookies($domain) }
}

# Lookup table for non-printable characters which need to be URL-encoded
variable enc [list { } +]
for {set i 0} {$i < 256} {incr i} {
	if {$i > 32 && $i < 127} { continue }
	lappend enc [format %c $i] %[format %02x $i]
}
unset i

proc pct_encode_extended {what} {
	variable enc
	return [string map $enc $what]
}

# Interpret an URL fragment relative to a complete URL
proc relative {full partial} {
	if {[string match -nocase http* $partial]} { return $partial }
	set base [join [lrange [split $full /] 0 2] /]
	if {[string equal [string range $partial 0 0] /]} {
		return "${base}${partial}"
	} else {
		return "[join [lreplace [split $full /] end end] /]/$partial"
	}
}

# Extract the charset from a charset=... directive as found in HTTP headers and HTML
# Partially stolen from the http library, but somewhat modified to work with HTML
proc extract_charset {content_type charset} {
	if {[regexp -nocase {charset\s*=\s*\"((?:[^""]|\\\")*)\"} $content_type -> cs]} {
		set charset [string map {{\"} \"} $cs]
	} else {
		regexp -nocase {charset\s*=\s*(\S+?);?} $content_type -> charset
	}
	regsub -all -nocase {[^a-z0-9_-]} $charset "" charset
	return $charset
}

# Fix the charset of an HTTP charset according to
#  * <meta charset> / <meta http-equiv="content-type"> if available
#  * HTTP header
# See http://www.edition-w3.de/TR/2000/REC-xml-20001006/#sec-guessing
proc fix_charset {data charset s_type} {
	# First, Check the data for a BOM
	if {[binary scan $data cucucucu b1 b2 b3 b4] < 4} return

	set stripbytes 0

	# TODO is UCS-4 supported at all?
	# FIXME BOM stripping is currently broken. Decoding of UTF-16BE will
	# fail, decoded UTF-16LE will contain the BOM which will confuse the
	# title parser. I have no idea how to strip bytes from binary Tcl
	# strings. Contact me if you do.
	if {$b1 == 255 && $b2 == 254 || $b1 == 254 && $b2 == 255} {
		set charset "unicode"
		set stripbytes 2
	} elseif {$b1 == 239 && $b2 == 187 && $b3 == 191} {
		set charset "utf-8"
		set stripbytes 3
	} else {

	# Next, try the content type. HTML content may override this.
	set charset [extract_charset $s_type $charset]

	# Next, try the header meta tags, which may override the charset sent
	# via HTTP headers
	# FIXME: this implementation is ugly. Use gumbo for this and parse twice?
	set charset [extract_charset $data $charset]
	}

	set charset [http::CharsetToEncoding $charset]

	if {$charset == "binary"} {return ""}
	set data [encoding convertfrom $charset $data]
	return $data
}

# "if a then a else b"
proc any {a b} {
	return [expr {$a != "" ? $a : $b}]
}

# Progress handler which aborts the download if it turns out to be too large
proc progresshandler {tok total current} {
	variable settings
	if {$current >= $settings(max-download)} {
		::http::reset $tok toobig
	}
}

proc fetch {url {post ""} {headers ""} {iterations 0} {validate 1}} {
	# follows redirects, sets cookies and allows post data
	# sets settings(content-length) if provided by server; 0 otherwise
	# sets settings(url) for redirection tracking
	# sets settings(content-type) so calling proc knows whether to parse data
	# returns data if content-type=text/html; returns content-type otherwise
	variable settings; variable cookies; variable ns
	
	if {[string length $post]} { set validate 0 }

	set url [pct_encode_extended $url]
	set settings(url) $url
	set settings(error) ""

	if {![string length $headers]} {
		set headers [list Referer $url]
		set domain [lindex [split $url /] 2]
		if {[info exists cookies($domain)] && [llength $cookies($domain)]} {
			lappend headers Cookie [join $cookies($domain) {; }]
		}
	}

	# -binary true  is essential here because the page charset sometimes
	# does not match the HTTP header charset, sometimes isn't present at
	# all, then the encoding would be forced to ISO-8859-1 by default and
	# unicode would be broken afterwards.
	set command [list ::http::geturl $url             \
	                  -timeout $settings(timeout)     \
	                  -validate $validate             \
	                  -binary true                    \
	                  -progress ${ns}::progresshandler]

	if {[string length $post]} {
		lappend command -query $post
	}

	if {[string length $headers]} {
		lappend command -headers $headers
	}

	set data ""

	if {[catch $command http]} {
		if {[catch {set settings(error) "Error [::http::ncode $http]: [::http::error $http]"}]} {
			set data "Error: Connection timed out."
		}
		::http::cleanup $http
		return $data
	} else {
		update_cookies $http
		set data [::http::data $http]
	}
	
	upvar #0 $http state
	set data [fix_charset $data $state(charset) $state(type)]
	foreach {name val} $state(meta) { set meta([string tolower $name]) $val }

	# $state(status) == "toobig" in case the file wasn't downloaded completely because it was too big

	::http::cleanup $http

	if {[info exists meta(location)]} {
		set meta(redirect) $meta(location)
	}

	if {[info exists meta(redirect)]} {

		set meta(redirect) [relative $url $meta(redirect)]

		if {[incr iterations] < 10} {
			return [fetch $meta(redirect) "" $headers $iterations $validate]
		} else {
			set settings(error) "Error: too many redirections"
			return ""
		}
	}

	set settings(content-length) 0
	if {[info exists meta(content-length)]} {
		set settings(content-length) [any $meta(content-length) 0]
	}
	set settings(content-type) "unknown"
	if {[info exists meta(content-type)]} {
		set settings(content-type) [any [lindex [split $meta(content-type) ";"] 0] "unknown"]
	}
	if {[string match -nocase $settings(content-type) "text/html"]\
	    || [string match -nocase $settings(content-type) "application/xhtml+xml"]} {
		if {$validate} {
			# It was a HEAD request, redo the request with GET
			return [fetch $url "" $headers [incr iterations] 0]
		} else {
			return $data
		}
	} elseif {$settings(content-type) != ""} {
		return "Content type: $settings(content-type)"
	} else {
		warn "No content type set. Please report a bug and include the URL."
	}
	return
}

proc process_title {url} {
#	returns $ret(url, content-length, tinyurl [where $url length > max], title)
	variable settings
	variable title

	# clean up previous state
	set settings(title) ""
	set settings(content-type) ""
	set settings(url) ""

	set title(data)		  [fetch $url "" $settings(default-headers)]
	set title(url)		  $url
	set title(expanded-url)	  $settings(url)
	set title(error)	  [expr {[string length $settings(error)] > 0}]
	set title(content-length) $settings(content-length)
	set title(content-type)	  $settings(content-type)

	regsub -all {\s+} [string trim [htmltitle $title(data)]] { } title(title)
	if {$title(title) == ""} {
		if {[string length $settings(error)] > 0} {
			set ret(title) $settings(error)
		} else {
			set ret(title) "Content type: $settings(content-type)"
		}
	}

}

namespace eval plugins {
	set settings(plugin-base-path) "$urlmagic::settings(base-path)/plugins"
	namespace path ::urlmagic

	if {![info exists loaded_plugins]} {
		variable loaded_plugins {}
	}

	proc load {plugin} {
		variable settings
		variable loaded_plugins

		set plugns ::urlmagic::plugins::${plugin}
		if {$plugin in $loaded_plugins} {
			warn "Can't load plugin, it is already loaded. Use reload to reload"
			return 0
		}
		init_ns $plugns

		# Two possible locations, check both for existence, source if available.
		set tcl1 "$settings(plugin-base-path)/${plugin}.tcl"
		set tcl2 "$settings(plugin-base-path)/${plugin}/${plugin}.tcl"
		if {
		   ( [file exists $tcl1] &&
		     [catch { namespace eval $plugns source $tcl1 } err] ) 
		|| ( [file exists $tcl2] &&
		     [catch { namespace eval $plugns source $tcl2 } err] )
		} then {
			warn "Unable to load plugin $plugin: $err"
			return 0
		}
		if {![info exists ${plugns}::settings] &&
		    ![info exists ${plugns}::no_settings]} then {
			warn "$plugin plugin has settings. Please add them to your configuration file first."
			return 0
		}
		${plugns}::init_plugin
		lappend loaded_plugins $plugin
		putlog "urlmagic: loaded plugin ${plugin} [set ${plugns}::VERSION]"
		return 1
	}

	proc init_ns {ns} {
		namespace eval $ns {
			variable ns [namespace current]
			namespace path ::urlmagic
		}
	}
		
	proc unload {plugin} {
		variable loaded_plugins

		set plugns ::urlmagic::plugins::${plugin}
		if {$plugns ni [namespace children]} {
			warn "Can't unload plugin $plugin, it does not appear to be loaded"
			return 0
		}
		set backup {}
		if {[info exists ${plugns}::settings]} {
			set backup [array get ${plugns}::settings]
		}
		${plugns}::deinit_plugin
		set loaded_plugins [lsearch -inline -not -all $loaded_plugins $plugin]
		set v [set ${plugns}::VERSION]
		namespace delete $plugns
		init_ns $plugns
		if {$backup != {}} {
			array set ${plugns}::settings $backup
		}
		putlog "urlmagic: unloaded plugin ${plugin} $v"
		return 1
	}
	proc unload_all {} {
		variable loaded_plugins
		foreach plugin $loaded_plugins { unload $plugin }
	}

	proc reload {args} {
		foreach plugin $args { unload $plugin }
		foreach plugin $args {   load $plugin }
	}

	proc load_enabled {} {
		foreach plugin $urlmagic::settings(plugins) {
			load $plugin
		}
	}

	proc reload_all {} {
		unload_all
		load_all
	}

} ;# end namespace "plugins"

plugins::unload_all
source $settings(config-file) ;# read it before initializing everything
  
if {$settings(htmltitle) == "perl"} {
	set settings(pipecmd) "$settings(perl-interpreter) $settings(base-path)/htmltitle_perlhtml5/htmltitle.pl"
	set settings(use-tclx) 0
	if {[catch {package require Tcl 8.6}]} {
		package require Tclx
		set settings(use-tclx) 1
	}
	proc ::htmltitle {data} {
		if {$::urlmagic::settings(use-tclx)} {
			pipe pr pw
		} else {
			lassign [chan pipe] pr pw
		}

		set fd [open "|$::urlmagic::settings(pipecmd) >@ $pw" w]
		puts -nonewline $fd $data
		close $fd
		set title [gets $pr]
		close $pr
		close $pw ;# should happen automatically but what do I know
		return $title
	}
} elseif {$settings(htmltitle) != "dumb"} {
	load $settings(base-path)/htmltitle_$settings(htmltitle)/htmltitle.so
	putlog "urlmagic: loaded $settings(htmltitle) htmltitle module"
} else {
	# "dumb" htmltitle implementation
	proc ::htmltitle {data} {
		set data [string map {\r "" \n ""} $data]
		if {[regexp -nocase {<\s*?title\s*?>\s*?(.*?)\s*<\s*/title\s*>} $data - title]} {
			return [string map {&#x202a; "" &#x202c; "" &rlm; ""} [string trim $title]]; # "for YouTube", says rojo
		}
	}
}

# Initialise eggdrop stuff
setudef flag $settings(udef-flag)
setudef flag urlmagic-silent
bind part - * ${ns}::unignore
bind sign - * ${ns}::unignore
# TODO: cron-bind that automatically deletes stale ignores
bind pubm - * ${ns}::find_urls

# Initialise https
::http::register https 443 "::tls::socket $settings(tls-options)"
::http::config -useragent $settings(user-agent)

putlog "urlmagic.tcl $VERSION loaded."

plugins::load_enabled

}; # end namespace