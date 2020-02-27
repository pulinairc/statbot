#! tclsh

# This plugin adds the size of a document behind an URL to the title sent to
# the channel.
# There are no configurable settings for it.
# It binds on urlmagic's <String> string builder hook.

package require hook

set VERSION 1.1+hg
set no_settings 1

proc size {} {
	upvar #0 ::urlmagic::title t

	if {$t(content-length)} {
		lappend t(output) "([bytes_to_human $t(content-length)])"
	}
}


proc bytes_to_human {bytes} {
	if {$bytes > 1073741824} {
		return "[make_round $bytes 1073741824] GB"
	} elseif {$bytes > 1048576} {
		return "[make_round $bytes 1048576] MB"
	} elseif {$bytes > 1024} {
		return "[make_round $bytes 1024] KB"
	} else { return "$bytes B" }
}

proc make_round {num denom} {
	return [format "%.2f" [expr {$num / $denom}]]
}

proc init_plugin {} {
	hook::bind urlmagic <String> [myself] [namespace current]::size
}

proc deinit_plugin {} {
	hook::forget [myself]
}
