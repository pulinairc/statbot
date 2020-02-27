# This plugin adds a bright red "(NSFW)" tag before an URL if:
#
#  * A user is a known NSFW poster who doesn't tag their NSFW urls as such and
#    thus has user mode +N set (always force NSFW)
#  * Such a user can however tag their URLs as SFW and make the warning go
#    away.
#  * Otherwise, if the URL was tagged as NSFW by making either the word NSFW or
#    NSFL appear on the same line, it will also be tagged NSFW
#  * If none of the above applies, it is SFW and the warning will be omitted.
#
# It also sets title(nsfw) to either true or false depending on what the
# outcome was, so that this can be used by other plugins, e.g. sqlite.
#
# Note that this probably isn't 100% accurate :)

set VERSION 1.1+hg
set no_settings 1

proc mark_nsfw {} {
	upvar #0 ::urlmagic::title t
	if {[is_nsfw $t(hand) $t(text)]} {
		set t(output) [linsert $t(output) 1 "\002\0034(NSFW)\003\002"]
	}
}

proc is_nsfw {hand txt} {
	# first off, anybody can tag their message as SFW.
	if {[regexp -nocase {\ysfw\y} $txt]} {
		return 0
	}
	# for people who don't have the +N(SFW) attribute set, assume SFW by
	# default, unless the text matches nsfw.
	if {[regexp -nocase {\ynsf[wl]\y} $txt] || [matchattr $hand +N]} {
		return 1
	}
	# sfw otherwise.
	return 0
}

proc init_plugin {} {
	hook::bind urlmagic <String> [myself] [namespace current]::mark_nsfw
}

proc deinit_plugin {} {
	hook::forget [myself]
}
