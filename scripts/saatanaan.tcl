###############################################################################
#
#	S�� t�n��n skripta v1.34 by (c)cell '2002
#	http://cell.isoveli.org/scripts
#	Vaatii cellgen skriptan, jonka saa yll�olevasta osoitteesta my�skin
#
#	Kopioi saa.conf scripts hakemistoon
#
#	K�ytt�:
#	.s�� helsinki
#	.s�� helsinki|turku
#
#	.s�� set turku			; n�in asetat oman paikkakuntasi s��n
#	.s��				; ja n�in saat sen jatkossa n�kyviin
#
#	YKSIL�LLINEN s�� vaatii rekister�itymisen bottiin.
#
#	Tiedot haetaan tielaitokselta
#	http://www.tiehallinto.fi/alk/tiesaa/tiesaa_maak_XX.html
#
#
#	1.34:	fix
#	1.33:	fix fix
#	1.32:	k�ytt�� cellgen 2.50 var-systeemej� vanhan profile-tiedoston sijaan.
#	1.30:	privabindit /msg botska saa, eli ilman pistett�.
#	1.29:	jos bottiin oli kanava konffittu Isoilla Kirjaimilla, ei k�sky toiminut :9
#	1.28:	profile tiedoston ulkon�k� v�h�n selke�mpi..
#	1.27:	jos tiettyj� mittauksia ei ole saatavilla paikkakunnasta, niin ne j�tet��n n�ytt�m�tt�
#		(eik� tulostus n�yt� kummalliselta)
#	1.26:	konfigfile haetaan nyt cellgeniss� konffatun conf(confpath) hakemistopolun mukaan
#	1.24:	konffiin kaupungin boldaus ja aliakset (imuttele conf-file uusiksi vaikkapa)
#	1.20:	Autoupdate cellgenin kautta
#		YKSIL�LLIST�MME TUOTTEEN lis��m�ll� 'set' parametrin :D Nykyaikana
#		ei riit� en��n riit� yksi massamarkkinoille suunnattu tuote!
#		Markkinatalouden uusinnat kutsuu..
#	1.15:	S��tiedot p�ivitet��n virhetilanteessa niin pitk�lle kuin mahdollista
#	1.14:	Toimivat kanavat voipi nyt m��r�t�
#	1.12:	K�ytt�� cellgeni� tulostuken tekoon
#	1.1:	Fluudirajoituksia ja konffattavuutta
#
#
#
###############################################################################
###############################################################################

namespace eval saa {
package require cellgen 2.50
set scriptversion 1.34

### �L� konffaa t�h�n jos k�yt�t config-filett�, n�m� ovat defaultit

set conf(boldcity) 0
set conf(needop_private) 1
array unset aliases
array set aliases {
        raahe                   "pattijoki"
        rovaniemi               "rovaniemen mlk"
        pieks�m�ki              "pieks�m�en mlk"
        pieksamaki              "pieks�m�en mlk"
        ii                      "ii, olhava"
        lahti                   "hollola"
        kristiinankaupunki      "kristiinankaup"
}

set erno [catch { source "$::cell::conf(confpath)/saatanaan.conf" } error]
if {$erno == 1} { putlog "saatanaan: config fileen lataus ep�onnistui ($::cell::conf(confpath)/saatanaan.conf) ($error)" }

::cell::registerautoupdate $scriptversion "http://cell.isoveli.org/scripts/saatanaan.tcl"

## uudet s��tiedot haetaan 3x tunnissa, k�yt�nn�ss� ne eiv�t
## kuitenkaan p�ivity edes niin usein.

bind pub - !s�� saa::saapub
bind pub - !saa saa::saapub
bind pub - !keli saa::saapub
bind msg - saa saa::saamsg
bind msg - s�� saa::saamsg

bind time - "00 % % % %" saa::update
bind time - "20 % % % %" saa::update
bind time - "40 % % % %" saa::update


### ja sit se itse skripta

proc saamsg {nick uhost handle text} {
	variable conf
	if {![matchattr $handle o|o] && $conf(needop_private)} { return }
	::saa::saapub $nick $uhost $handle $nick $text
}

proc saapub {nick uhost handle chan text} {
	variable conf
	variable aliases
	variable updatecount

	foreach ch [split $conf(kanavat) " "] { if {[string equal -nocase $ch $chan]} { set jee 1 } }
	if {![info exist jee] && ($nick != $chan)} { return }

	if {![matchattr $handle o|o $chan] && $conf(needop)} { return }

	set erno [catch { set fi [open $conf(file)] } error]
	if {$erno} { 
		if {$updatecount == 0} { 	putserv "PRIVMSG $chan :S��tietoja ei saatavilla" } else {
						putserv "PRIVMSG $chan :S��tietojen haku on viel� kesken" }
		return
	}
	set tiedot ""

	if {$conf(enableset)} {
		if {$handle == "*"} { set handle $nick } else {
			if {[regsub -- " *\\mset\\M *" $text {} text]} { saa::setcity $nick $handle $text }
		}
		if {$text == ""} { set text [saa::getcity $handle] }
	}
	if {$text == ""} { set text $conf(default_search) }

	set text [saa::applyaliases $text]
	if {$text == ""} { set text "��li� puikoissa" }

	for {} {![eof $fi]} {} {
		set line [gets $fi]
		if {[regexp -nocase -- $text [lindex $line 0]]} { lappend tiedot $line }
	}

	set lista ""
	foreach s $tiedot {
		if {[regexp -nocase -- "$text\[^,\]*" [lindex $s 0]]} { set lista [linsert $lista 0 $s] } else { lappend lista $s }
	}

	close $fi

	saa::showresults $lista $text $chan
}


proc showresults {tiedot text chan} {
	variable conf

	if {[llength $tiedot] == 0} { putserv "PRIVMSG $chan :\002$text\002: S��t� ei l�ytynyt. Tsekkaa l�ytyyk� listasta: http://www2.liikennevirasto.fi/alk/tiesaa/" ; return }
	set out "" ; set seena ""

	foreach entry $tiedot {
		if {![regexp -nocase -- $entry $seena]} {
			lappend seena $entry
			regsub -all -- {.*; } [lindex $entry 0] {} city
			if {$conf(sijainti) != 1} { regsub -all -- {, .*|Tie [0-9 ]+} $city {} city }

			regsub -all -- "\002" $out {} tout
			if {[lsearch -regexp $tout "^$city*"] == -1 && [llength $out] < $conf(maxlen)} {
				set lampo "[lindex $entry 2]�C"
				if {$conf(boldcity) == 1} { set city "\002$city\002" }

				set info [list $city $lampo]

				if {$conf(kello) == 1} { lappend info [lindex $entry 1] }
				if {$conf(keli) == 1} { set i [lindex $entry 4] ; if {$i != ""} { if {$i != "Pouta"} { append i " sade" } ; lappend info $i } }
				if {$conf(tie) == 1 && [lindex $entry 5] != ""} { lappend info [lindex $entry 5] }

				lappend out $info
			}
		}
	}

	set o [cell::output "" $out "\\ \\ (a\\)" " | "]
	foreach i $o { putserv "PRIVMSG $chan :$i" }
}


proc update {args} {
	variable updatecount 0
	variable ::cell::conf

	for {set korva 1} {$korva<23} {incr korva} {
		cell::geturl "http://alk.tiehallinto.fi/alk/tiesaa/tiesaa_maak_$korva.html" ::saa::getpage ""
		# annetaan aikaisemmille requesteille aikaa p��st� edelle
		if {$korva == 10} { cell::wait 2 }
	}

	cell::wait 3
	utimer $::cell::conf(maxurlwait) saa::errorska
}


proc errorska {args} {
	variable updatecount
	variable conf

	catch { [file rename -force $conf(tempfile) $conf(file)] }
	# jos kaikki s��tiedot saatiin, logiin ei kirjoiteta mit��n
	if {$updatecount == 0} { return }
	putlog "S��tietojen haku valmis, $updatecount/22 sivua saatiin"
}


proc getpage {token} {

	set erno [catch {

	variable conf
	variable updatecount

	set data [split [cell::geturldata $token] \n]
	set pox 0
	set all ""
	set entry ""

	foreach line $data {
		if {$pox == 1 && [string range $line 0 9] == "<TD WIDTH="} {
			regsub -all -- {^ +| +$} [cell::formattext $line] {} line
			lappend entry $line
		}
		if {$line == "</TR>"} {
			set pox 1
			if {$entry != ""} { append all "$entry\n" }
			set entry ""
		}
	}

	set kikkeli [open $conf(tempfile) "a"]
	puts $kikkeli $all
	close $kikkeli

	incr updatecount
	if {$updatecount > 31} { set updatecount 0 ; file rename -force $conf(tempfile) $conf(file) }

	} error]

	if {$erno != 0} { putlog "ERROR (saatanaan.tcl::getpage): $error ($erno)" }
}


proc setcity {nick handle city} {
	::cell::setvar saaprofile $handle $city
	putserv "NOTICE $nick :Paikkakunnaksesi on nyt asetettu $city"
}


proc getcity {handle} {
	return [::cell::getvar saaprofile $handle]
}


proc applyaliases {text} {
	variable aliases
	set pox [array get aliases]
	foreach {e t} $pox { regsub -all -- "\\m$e\\M" $text $t text }
	return $text
}


catch { if {$conf(autocache)} { saa::update } }


putlog "Script loaded: \002saatanaan v$scriptversion by (c)cell '2002\002"
}
#end namespace


