#############################################################################
#
# Horo(skooppi) v1.21
# (c)cell '2002 (cell@amigafin.org)
# http://cell.isoveli.org/scripts
#
# *LISÄARVOPALVELU* : nyt toimii oikein 'set' parametrin kanssa!
#
# FIXFIX: vaihettu iltalehteen (sama horoskooppi muutti mtv3 -> iltalehti)
# FIXFIX: toimii oikeesti
# FIXFIX: käyttää mtv3:n horoskooppitietoja
#
# käyttö:	.horo jousimies
#
# (käyttäjä-	.horo set jousimies
# kohtainen)	.horo
#
# rolle @ quakenet -muokkaama versio
#
#############################################################################
package require cellgen 2.50
namespace eval ::horo {
set scriptversion 1.3



## HUOM! Kanavat joilla horo toimii, erottele välilyönnillä:
set conf(channels) "#pulina #kuurosokeat #HTK15SI"

## horo toimii privana?
set conf(priv) 1
set conf(privflags) "fo|fo"

## horossa toimii 'set' käyttäjäkohtaisille asetuksille?
set conf(enableset) 1


bind pub - !horo horo::horopub
bind pub - .horo horo::horopub
bind pub - !horoskooppi horo::horopub
bind msg - horo horo::horomsg

proc horomsg {nick uhost handle text} { return [horo::horopub $nick $uhost $handle $nick $text] }
proc horopub {nick uhost handle chan text} { 
	variable conf

	if {$conf(enableset)} {
		if {$handle == "*"} { set handle $nick } else {
			if {[regsub -- " *\\mset\\M *" $text {} text]} {
				horo::sethoro $nick $handle $text
			}
                }
                if {$text == ""} { set text [horo::gethoro $handle] }
        }

	if {$text == ""} {
		putserv "PRIVMSG $chan :!horo: !horo <horoskooppimerkki>"
		return
	}

	if {$nick != $chan} {
		foreach ch $conf(channels) { if {[regexp -nocase -- "^$ch\$" $chan]} { set ok 1 } }
		if {![info exists ok]} { return 0 }
	} else {
		if {$conf(priv) == 0} { return 0 }
		if {$conf(privflags) != "" && ![matchattr $nick $conf(privflags) $chan]} { return 0 }
	}

	set date [clock format [clock seconds] -format "%Y/%m/%d"]
#	cell::geturl "http://www.iltalehti.fi/$date/horoskooppi1_ho.shtml" ::horo::horo_proc [list $text $chan]
        cell::geturl "http://www.iltalehti.fi/viihde/horoskooppi1_ho.shtml" ::horo::horo_proc [list $text $chan]
	cell::wait 2
}

proc sethoro {nick handle horo} {
        ::cell::setvar horoprofile $handle $horo
        putserv "NOTICE $nick :Horoskooppisi on nyt asetettu $horo"
}

proc gethoro {handle} {
        return [::cell::getvar horoprofile $handle]
}

proc horo_proc {token} {
	set data [cell::geturldata $token]
	set args [cell::getcbargs $token]

	set erno [catch { horo::horoskooppi $data $args } error]
	if {$erno != 0} { putlog "horo: $error" }
}


proc horoskooppi {data arg} {

	regsub -all -- {</div>|</p>} $data "\n" data
	regsub -all -- {<div} $data "\n<div" data

	set data [split $data \n]
	foreach line $data {
		if {[regexp "<p" $line] && [info exists merkki]} {
			regsub -all -- {^ +| +$} [::cell::formattext $line] {} texti
			if {$texti != ""} {
				putserv "PRIVMSG [lindex $arg 1] :$merkki: $texti"
				return 1
			}
		}
		if {[regexp -nocase -- "class=\"valiotsikko" $line]} {
			set m [::cell::formattext $line]
			if {[regexp -nocase -- [lindex $arg 0] $m]} { set merkki $m }
		}
	}

	putserv "PRIVMSG [lindex $arg 1] :Iltalehden sivuilla on joku perseellään tai typotit."
}

putlog "Script loaded: \002Horo $scriptversion\002"

}
