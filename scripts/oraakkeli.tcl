# oraakkeli.tcl
# (C) Ville Koskinen 2004
# Hyvin yksinkertainen skripti Kaisaniemen Oraakkelin h‰rn‰‰miseen (oraakkelin
# tehnyt Aapo Puskala @ http://www.lintukoto.net).

# Artistic Licence, toisin sanoen voit kopioida ja levitt‰‰ t‰t‰ vapaasti
# sek‰ muokata haluamallasi tavalla, kunhan muistat merkata muuttamasi
# kohdat.

package require http

# URL
set baseurl "http://www.lintukoto.net/viihde/oraakkeli/index.php?html=1&"
set kysymys "&kysymys="
set kysyja "&kysyja="

#######

bind pubm - * oraakkeli_handler

proc oraakkeli_handler {nick uhost hand chan text} {
	# nick
	# userhost
	# bothandle
	# channel
	# text

	global baseurl
	global kysymys
	global kysyja
	global botnick

	if {[regexp -nocase -- ^$botnick $text] != 1} {
		return 0
	}

	regsub $botnick $text {} text
	regsub -all { +} $text {+} text
	regsub -all {[^a-zA-ZÂ‰ˆ≈ƒ÷0-9+]} $text {} text

	set token [::http::geturl $baseurl$kysymys$text$kysyja$nick]
	upvar #0 $token state
	set response $state(body)

	regsub -all {\n} $response {} response

	putserv "privmsg $chan :$nick: $response"

	return 1
}

putlog "Script loaded: \002Oraakkeli\002"
