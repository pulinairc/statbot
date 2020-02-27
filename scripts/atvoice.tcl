


#-----------------------------------------------Autovoice by ^UnIx_GuY^--------------------------------

#Set your channel name Here
set voicechan "#livehelp"

#Set your maximum idletime here
set maxidle 15

bind join - * join_atvoice
bind time - * idlecheck

proc join_atvoice {nick uhost hand chan} {
	utimer 10 [list voice:delay $nick $chan]
}

proc voice:delay {nick chan} {

	global botnick voicechan
	if {([lsearch -exact [string tolower $voicechan] [string tolower $chan]] != -1)} {
		if {[isop $nick $chan]} {return}
		putserv "MODE $chan +v $nick"
		}

}

proc idlecheck {min hour day month year} {
	global botnick voicechan maxidle
	foreach nick [chanlist $voicechan] {
		if {$nick == $botnick} {continue}
		if {[isop $nick $voicechan]} {continue}
		if {![isvoice $nick $voicechan]} {continue}
		if {[getchanidle $nick $voicechan] > $maxidle } {
			putserv "MODE $voicechan -v-k $nick $maxidle.min.Idle"
			putserv "privmsg $nick : If want Help , Please Leave and Re-enter the Channel"
		}
	}
}
	
	

putlog "Script loaded: \002ATVoice by ^UnIx_GuY^\002"
