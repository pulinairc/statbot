##
## Nimpparit v1.2.1 by (c)cell '2002
## http://cell.isoveli.org/scripts/
##
## versiossa 1.2-> 1.2.1
## Korjattu astro.com urli oikein kaupungin astelukujen selvittämiseksi
##
## versiossa 1.2
## Auringonnousu & laskuajat (näyttämiseen vaaditaan cellgen.tcl)
##
##
##	.pvm [nimi | päivämäärä | juhlapyhä] [seur]
##	!pvm [nimi | päivämäärä | juhlapyhä] [seur]
##	.sd
##
##	Käskyt .nimpparit ja .nd toimivat synonyymeinä
##
##	.pvm
##	.pvm 29.9
##	.pvm mikko
##	.pvm pääsiäinen
##	.pvm pääsiäinen seur
##	.pvm pääsiäinen seur seur
##
##	seur switchejä voi änkeä mukaan niin paljon kuin hyvältä tuntuu
##
##
##	BONUS-OMINAISUUS!!! (kludge ;) >>
##	.pvm +		huomisen nimpparit
##	.pvm ++		ylihuomisen nimpparit (jne.)
##
##
##############################################################################################

namespace eval ::nimpparit {
set scriptversion 1.2.1
catch { ::cell::registerautoupdate $scriptversion http://cell.isoveli.org/scripts/pvm.tcl }


##############################################################################################

## kanavat joille fluuditaan keskiyöllä nimpparit, välilyönnillä eroteltuina
set kanavat "#pulina"

## näytetäänkö auringonnousu- ja laskuajat? (0/1) ja minkä kaupungin mukaan? (kokeile onneasi..)
## tämä ominaisuus ei toimi jos sinulta ei löydy cellgen.tcl:ää
set aurinko 0
set city "Jyväskylä"

##############################################################################################







## here be dragons konffit loppu

bind pub - .nimpparit ::nimpparit::nimpub
bind pub - !nimpparit ::nimpparit::nimpub
bind pub - .pvm ::nimpparit::nimpub
bind pub - !pvm ::nimpparit::nimpub
bind pub - !nd ::nimpparit::nimpub
bind pub - .nd ::nimpparit::nimpub
bind pub - .sd ::nimpparit::sdpub
bind time - "01 00 % % %" ::nimpparit::announce

set paivat {Sunnuntai Maanantai Tiistai Keskiviikko Torstai Perjantai Lauantai}


## Keräilty sieltä täältä.. Yksittäisiä päiviä voi lisäillä kuka tahansa TONKO,
## mutta juhlapäivät jotka osuvat tietyn aikavälin aikana olevalle tietylle
## viikonpäivälle, tai jotka lasketaan suhteessa pääsiäiseen, vaativat aivojen
## käyttöä. Alempaa tutkimalla asia kuitenkin selvinnee..

set juhlapaivat {
1.1.: Uudenvuodenpäivä
6.1.: Loppiainen
5.2.: Runebergin päivä
14.2.: Ystävänpäivä
28.2.: Kalevalan päivä
8.3.: Naistenpäivä
1.4.: Aprillipäivä
9.4.: Mikael Agricolan päivä, suomen kielen päivä
27.4.: Kansallinen veteraanipäivä
1.5.: Suomalaisen työn päivä eli Vappu
9.5: Eurooppa-päivä
12.5.: J.V. Snellmanin päivä, suomalaisuuden päivä
4.6.: Puolustusvoimain lippujuhla
9.6.: Ahvenanmaan itsehallintopäivä
6.7.: Runon ja suven päivä, Eino Leinon päivä
17.7.: Kansanvallan päivä
23.7.: Mätäkuu alkaa
27.7.: Unikeonpäivä
20.8.: Kansallinen tykityspäivä
23.8.: Mätäkuu loppuu
4.10.: Maailman eläinten päivä
10.10.: Aleksis Kiven päivä, suomalaisen kirjallisuuden päivä
24.10.: Yhdistyneiden kansakuntien (YK:n) päivä
6.11.: Svenska dagen eli ruotsalaisuuden päivä
6.12.: Suomen itsenäisyyspäivä
13.12.: Lucian päivä
24.12.: Jouluaatto
25.12.: Joulupäivä
26.12.: 2. joulupäivä, Tapaninpäivä
28.12.: Viattomien lasten päivä
25.3-31.3.|Sunnuntai:Kesäaika alkaa
25.10-31.10.|Sunnuntai:Kesäaika päättyy
20.6.-26.6.|Perjantai:Juhannusaatto
21.6.-27.6.|Lauantai:Juhannuspäivä
8.5.-14.5.|Sunnuntai:Äitienpäivä
15.5.-21.5.|Sunnuntai:Kaatuneiden muistopäivä
31.10.-6.11.|Lauantai:Pyhäinpäivä
8.11.-14.11.|Sunnuntai:Isänpäivä
ps-49|Sunnuntai:Laskiaissunnuntai
ps-47|Tiistai:Laskiaistiistai
ps-7|Sunnuntai:Palmusunnuntai
ps-3|Torstai:Kiirastorstai
ps-2|Perjantai:Pitkäperjantai
ps-1|Lauantai:Lankalauantai
ps+0|Sunnuntai:Pääsiäinen
ps+1|Maanantai:2. Pääsiäispäivä
ps+39|Torstai:Helatorstai
ps+49|Sunnuntai:Helluntai
}


## Jotain nimiä kun puuttuu niin ilmoitelkaa cell@amigafin.org

set nimet {
!
"TONKO"
"Aapeli"
"Elmo, Elmer, Elmeri"
"Ruut"
"Lea, Leea"
"Harri"
"August, Aukusti, Aku"
"Hilppa, Titta"
"Veikko, Veli, Veijo"
"Nyyrikki"
"Kari, Karri"
"Toini, Anton, Anttoni, Antto"
"Nuutti"
"Sakari, Saku"
"Solja"
"Ilmari, Ilmo"
"Toni, Anttoni"
"Laura"
"Heikki, Henri, Henrik, Henrikki"
"Henna, Henni"
"Aune, Oona, Auni"
"Visa"
"Eine, Eini, Enni"
"Senja"
"Paavali, Paavo, Pauli, Paul"
"Joonatan"
"Viljo"
"Kaarlo, Kaarle, Kalle, Mies"
"Valtteri"
"Irja"
"Alli"
!
"Riitta"
"Aamu"
"Valo"
"Armi"
"Asser"
"Terhi, Teija, Tiia"
"Riku, Rikhard"
"Laina"
"Raija, Raisa"
"Elina, Elna, Ellen"
"Talvikki"
"Elma, Elmi"
"Sulo, Sulho"
"Voitto, Tino, Valentin"
"Sipi, Sippo"
"Kai"
"Väinö, Väinämö"
"Kaino"
"Eija"
"Heli, Helinä"
"Keijo"
"Tuulikki, Tuuli"
"Aslak"
"Matti, Matias, Mattias"
"Tuija, Tuire"
"Nestori"
"Torsti"
"Onni"
"TONKO"
!
"Alpo, Alvi, Alpi"
"Virve, Virva"
"Kauko"
"Ari, Arsi, Atro"
"Laila, Leila"
"Tarmo"
"Tarja, Taru"
"Vilppu"
"Auvo"
"Aurora, Aura, Auri"
"Kalervo"
"Reijo, Reko"
"Erno, Ernesti, Tarvo"
"Matilda, Tilda"
"Risto"
"Ilkka"
"Kerttu, Kerttuli"
"Eetu, Edvard"
"Jooseppi, Juuso, Joosef"
"Aki, Joakim, Kim, Jaakkima"
"Pentti"
"Vihtori"
"Akseli"
"Kaapo, Kaappo, Kaapro, Gabriel"
"Aija"
"Manu, Immanuel, Immo, Manne"
"Sauli, Saul"
"Armas"
"Joonas, Jouni, Joni, Jonne, Jonni, Joona, Joonatan"
"Usko, Tage"
"Irma, Irmeli"
!
"Raita, Pulmu"
"Pellervo"
"Sampo"
"Ukko"
"Irene, Irina"
"Vilho, Vilhelm, Vili, Viljami, Ville, Jami"
"Allan, Ahvo"
"Suoma, Suometar"
"Elias, Eelis, Eljas"
"Tero"
"Verna"
"Julius, Julia"
"Tellervo"
"Taito"
"Linda, Tuomi"
"Jalo, Patrik"
"Otto"
"Valto, Valdemar"
"Pälvi, Pilvi"
"Lauha"
"Anssi, Anselmi"
"Alina"
"Yrjö, Yrjänä, Jyrki, Jyri, Jori"
"Pertti, Albert, Altti"
"Markku, Markus, Marko"
"Terttu, Teresa"
"Merja"
"Ilpo, Ilppo, Tuure"
"Teijo"
"Mirja, Mirva, Mira, Miia"
!
"Vappu, Valpuri"
"Vuokko, Viivi"
"Outi"
"Ruusu, Roosa"
"Maini"
"Ylermi"
"Helmi, Kastehelmi"
"Heino"
"Timo"
"Aino, Aina, Aini"
"Osmo"
"Lotta"
"Kukka, Floora"
"Tuula"
"Sofia, Sonja"
"Esteri, Essi"
"Maila, Maili"
"Eerikki, Erkki, Eero"
"Emilia, Milja, Emma"
"Lilja, Karoliina"
"Kosti, Kosta, Konsta, Konstantin"
"Hemminki, Hemmo"
"Lyydia, Lyyli"
"Tuukka, Touko"
"Urpo"
"Minna, Vilma"
"Ritva"
"Alma"
"Oiva, Oivi"
"Pasi"
"Helka, Helga"
!
"Teemu, Nikodemus"
"Venla"
"Orvokki"
"Toivo"
"Sulevi"
"Kustaa, Kyösti"
"Suvi, Roope, Robert"
"Salomo, Salomon"
"Ensio"
"Seppo"
"Impi, Immi"
"Esko"
"Raili, Raila"
"Kielo"
"Vieno, Viena"
"Päivi, Päivikki, Päivä"
"Urho"
"Tapio"
"Siiri"
"Into"
"Ahti, Ahto"
"Paula, Liina, Pauliina"
"Aatto, Aatu, Aadolf"
"Johannes, Juhani, Juha, Juhana, Janne, Jani, Juho, Jukka, Jussi"
"Uuno"
"Jorma, Jarmo, Jarkko, Jarno, Jere, Jeremias"
"Elviira, Elvi"
"Leo"
"Pietari, Pekka, Pekko, Petri, Petra, Petteri"
"Päiviö, Päivö"
!
"Aaro, Aaron"
"Maria, Mari, Maija, Meeri, Maaria"
"Arvo"
"Ulla, Upu"
"Unto, Untamo"
"Esa, Esaias"
"Klaus, Launo"
"Turo, Turkka"
"Ilta, Jasmin"
"Saima, Saimi"
"Elli, Noora, Nelli"
"Herman, Hermanni, Herkko"
"Ilari, Lari, Joel"
"Aliisa"
"Rauni, Rauna"
"Reino"
"Ossi, Ossian"
"Riikka"
"Saara, Sari, Salli, Salla"
"Marketta, Maarit, Reeta"
"Johanna, Hanna, Jenni"
"Leena, Leeni, Lenita"
"Oili, Olga"
"Kirsti, Tiina, Kirsi, Kristiina"
"Jaakko, Jaakoppi, Jaakob"
"Martta"
"Heidi"
"Atso"
"Olavi, Olli, Uolevi, Uoti"
"Asta"
"Helena, Elena"
!
"Maire"
"Kimmo"
"Linnea, Nea, Vanamo"
"Veera"
"Salme, Sanelma"
"Toimi, Keimo"
"Lahja"
"Sylvi, Sylvia, Silva"
"Erja, Eira"
"Lauri, Lasse, Lassi"
"Sanna, Susanna, Sanni"
"Klaara"
"Jesse"
"Onerva, Kanerva"
"Marjatta, Marja, Jaana"
"Aulis"
"Verneri"
"Leevi"
"Mauno, Maunu"
"Samuli, Sami, Samuel, Samu"
"Soini, Veini"
"Iivari, Iivo"
"Varma, Signe"
"Perttu"
"Loviisa"
"Ilma, Ilmi, Ilmatar"
"Rauli"
"Tauno"
"Iines, Iina, Inari"
"Eemil, Eemeli"
"Arvi"
!
"Pirkka"
"Sinikka, Sini"
"Soili, Soile, Soila"
"Ansa"
"Mainio, Roni"
"Asko"
"Arho, Arhippa, Miro"
"Taimi"
"Eevert, Isto"
"Kalevi, Kaleva"
"Santeri, Santtu, Ali, Ale, Aleksanteri"
"Valma, Vilja"
"Orvo"
"Iida"
"Sirpa"
"Hellevi, Hillevi, Hille, Hilla"
"Aili, Aila"
"Tyyne, Tytti, Tyyni"
"Reija"
"Varpu, Vaula"
"Mervi"
"Mauri"
"Mielikki"
"Alvar, Auno"
"Kullervo"
"Kuisma"
"Vesa"
"Arja"
"Mikko, Mika, Mikael, Miika, Miikka, Miska"
"Sorja, Sirja"
!
"Rauno, Rainer, Raine, Raino"
"Valio"
"Raimo"
"Saila, Saija"
"Inkeri, Inka"
"Minttu, Pinja"
"Pirkko, Pirjo, Piritta, Pirita"
"Hilja"
"Ilona"
"Aleksi, Aleksis"
"Otso, Ohto"
"Aarre, Aarto"
"Taina, Tanja, Taija"
"Elsa, Else, Elsi"
"Helvi, Heta"
"Sirkka, Sirkku"
"Saini, Saana"
"Satu, Säde"
"Uljas"
"Kauno, Kasperi"
"Ursula"
"Anja, Anita, Anniina, Anitta"
"Severi"
"Asmo, Rasmus"
"Sointu"
"Amanda, Niina, Manta"
"Helli, Hellä, Hellin, Helle"
"Simo"
"Alfred, Urmas"
"Eila"
"Artturi, Arto, Arttu"
!
"Pyry, Lyly"
"Topi, Topias"
"Terho"
"Hertta"
"Reima"
"Kustaa, Kustavi, Kyösti, Kustaa Aadolf"
"Taisto"
"Aatos"
"Teuvo"
"Martti"
"Panu"
"Virpi"
"Ano, Kristian"
"Iiris"
"Janika, Janita, Janina"
"Aarne, Aarno, Aarni"
"Eino, Einar, Einari"
"Tenho, Jousia"
"Liisa, Eliisa, Elisa, Elisabet"
"Jalmari, Jari"
"Hilma"
"Silja, Selja"
"Ismo"
"Lempi, Lemmikki, Sivi"
"Katri, Kaisa, Kaija, Katja"
"Sisko"
"Hilkka"
"Heini"
"Aimo"
"Antti, Antero, Atte"
!
"Oskari"
"Anelma, Unelma"
"Vellamo, Meri"
"Airi, Aira"
"Selma"
"Niilo, Niko, Niklas, Nikolai"
"Sampsa"
"Kyllikki, Kylli"
"Anna, Anne, Anni, Anu, Annikki"
"Jutta"
"Taneli, Tatu, Daniel"
"Tuovi"
"Seija"
"Jouko"
"Heimo"
"Auli, Aulikki"
"Raakel"
"Aapo, Aappo, Rami"
"Iikka, Iiro, Iisakki, Isko"
"Benjamin, Kerkko"
"Tuomas, Tuomo, Tomi, Tommi"
"Raafael"
"Senni"
"Aatami, Eeva, Eevi, Eveliina"
"TONKO"
"Tapani, Tahvo, Teppo"
"Hannu, Hannes"
"Piia"
"Rauha"
"Daavid, Taavetti, Taavi"
"Sylvester, Silvo"
}


proc announce { args } { variable kanavat ; foreach chan $kanavat { fluudnimpparit $chan "" } }
proc nimpub {nick uhost handle chan text} { ::nimpparit::fluudnimpparit $chan $text }

proc fluudnimpparit { chan search } {
	variable nimet
	variable paivat
	variable timezone
	variable city

#	if {[catch {

	set names [split $nimet !]
	set sday [regsub -all -- "\\+" $search {} search]
	set day [clock format [expr $sday*60*60*24+[clock seconds]] -format %e]
	set month [clock format [expr $sday*60*60*24+[clock seconds]] -format %m]
	set year [clock format [expr $sday*60*60*24+[clock seconds]] -format %Y]
	set week [clock format [clock seconds] -format %V]
	set seur [regsub -all -nocase -- " *\\mseur\\M *" $search {} search]

	set lista [regexp -inline -- {^([0123456789]+).([0123456789]+)\.*([0123456789]*)} $search]
	if {[string is digit [lindex $lista 2]] && $lista != ""} {
		set day [lindex $lista 1]
		set month [lindex $lista 2]
		if {[lindex $lista 3] != "" && [string is digit [lindex $lista 3]]} {
			if {[lindex $lista 3]<100} {
				set year [expr [lindex $lista 3]+2000]
			} else {
				set year [lindex $lista 3]
			}
		}
		set mn 0
	} elseif {$search != ""} {
		set mn 0
		foreach m $names {
			set m [split $m \n] ; set dn 0
			foreach n $m {
				if {[regexp -nocase -- "\[\", \]$search\[\"\$, \]" $n]} { set day $dn ; set month $mn ; set f 1 }
				incr dn
			}
			incr mn
		}

		if {![info exists f]} {
       		        incr year $seur
			set lista [getjuhlapaiva [clock scan "$year-1-1"] "" $search]
			if {$lista != ""} { set day [lindex $lista 0] ; set month [lindex $lista 1] }
			incr year [expr 0-$seur]
		}
	}

	regsub -all -- {^[0 ]+} $month {} month
	regsub -all -- {^[0 ]+} $day {} day
	incr year $seur
	if {[catch {set timestamp [clock scan "$year-$month-$day 00:01"]}]} { putserv "PRIVMSG $chan :Järjenkäyttö sallittu" ; return 0 }
	set weekday [lindex $paivat [clock format $timestamp -format %w]]
	set juhlapaiva [getjuhlapaiva $timestamp $weekday]

	if {$search == ""} {
		set nimi [lindex [split [lindex $names $month] \n] $day]
		regsub -all -- {"} $nimi {} nimi
		putserv "PRIVMSG $chan :Tänään on $weekday $day.$month.$year (Viikko $week) ja nimipäivää viettää $nimi.[getsunrise $day $month $year $timezone $city]$juhlapaiva"
	} elseif {[info exists mn]} {
		set erno [catch {
			set nimi [lindex [split [lindex $names $month] \n] $day]
			regsub -all -- {"} $nimi {} nimi
			if {$timestamp > [expr [clock seconds]-(60*60*24)]} { set aikamuoto "viettää" } else { set aikamuoto "vietti" }
			putserv "PRIVMSG $chan :${weekday}na $day.$month.$year nimipäivää $aikamuoto $nimi.[getsunrise $day $month $year $timezone $city]$juhlapaiva"
		} error]
		if {$erno != 0} { putserv "PRIVMSG $chan :Ime säkkiäs" ; putlog $error }
	} else {
		putserv "PRIVMSG $chan :Emmä löytäny"
	}

#	}]} { putserv "PRIVMSG $chan :Ensin leikitään, sitten syödään Vasta." }
}


proc getjuhlapaiva {timestamp weekday {search ""}} {
	variable juhlapaivat
	variable paivat

	set year [clock format $timestamp -format %Y]
	set jp [split $juhlapaivat \n]
	set ps [getpaasiainen $year]
	set jpp ""

	foreach paiva $jp {
		if {$paiva != ""} {
			set paiva [split $paiva :]
			set ehdot [split [lindex $paiva 0] \|]

			if {[string range [lindex $ehdot 0] 0 1] == "ps"} {
				catch "unset pvm"
				set minstamp [eval "expr \$[lindex $ehdot 0]*86400-3600"]
				set maxstamp [expr $minstamp+7200]
			} else {
				set pvm [split [lindex $ehdot 0] -]
				set minstamp [clock scan "$year-[lindex [split [lindex $pvm 0] .] 1]-[lindex [split [lindex $pvm 0] .] 0] 00:01"]
				set maxstamp [expr $minstamp+1]
				catch {set maxstamp [clock scan "$year-[lindex [split [lindex $pvm 1] .] 1]-[lindex [split [lindex $pvm 1] .] 0] 00:01"]}
			}

			if {([regexp -nocase -- $search [lindex $paiva 1]] && $search != "")} {
				if {$maxstamp > $minstamp+1 && [info exists pvm]} {
					set idx [expr [lsearch -regexp $paivat [lindex $ehdot 1]] - [clock format $minstamp -format %w]]
					if {$idx < 0} { set idx [expr $idx + 7] }
					set maxstamp [expr $minstamp+($idx*86400)]
				}
				return [list [clock format $maxstamp -format %e] [clock format $maxstamp -format %m]]
			}

			if {([regexp -nocase -- [lindex $ehdot 1] $weekday] && $timestamp >= $minstamp && ($timestamp <= $maxstamp || $maxstamp == ""))} {
				regsub -all -- {^ +} [lindex $paiva 1] {} juhlapaiva
				lappend jpp $juhlapaiva
			}
		}
	}
	if {$jpp != ""} { return " ([join $jpp ", "])" }
}


## semmonen kaava..

proc getpaasiainen {yr} {
   set a [expr $yr % 19]
   set b [expr int($yr / 100)]
   set c [expr $yr % 100]
   set d [expr int($b / 4)]
   if {[expr $b / 4] < 1} { set d 0 }

   set e [expr $b % 4]
   set f [expr int(($b+8)/25)];
   if {[expr ($b+8)/25] < 1} { set f 0 }
   set g [expr int(($b-$f+1)/3)];
   if {[expr ($b-$f+1)/3] < 1} { set g 0 }
   set h [expr (19*$a+$b-$d-$g+15) % 30]
   set i [expr int($c/4)]
   if {[expr ($c/4)] < 1} { set i 0 }
   set k [expr $c % 4]
   set l [expr int(32+2*$e+2*$i-$h-$k) % 7]

   set m [expr int(($a+11*$h+22*$l)/451)]
   if {[expr (($a+11*$h+22*$l)/451)] < 1} { set m 0 }
   set emonth [expr int(($h+$l-7*$m+114)/31)]
   set r [expr ($h+$l-7*$m+114) % 31]
   set edate [expr $r+1];

   return [clock scan "$yr-$emonth-$edate 00:01"]
}


proc getlongitudes {token} {
	if {[catch {
	set arg [::cell::getcbargs $token]
	set data [split [::cell::geturldata $token] \n]
	foreach line $data {
		if {[regexp -- "ade.cgi" $line]} {
			set lista [regexp -all -nocase -inline -- "<b>(\[^<\]*)</b>" $line]
			::nimpparit::getsunrisetable [lindex $lista 1] [lindex $lista 3] $arg
		}
	}	
	} error]} { putlog "getlongitudes: $error" }
}


proc getsunrisetable { north east arg} {
	if {[catch {
	variable timezone
	set yy1 [lindex [split $north n] 0]
	set yy2 [lindex [split $north n] 1]
	set xx1 [lindex [split $east e] 0]
	set xx2 [lindex [split $east e] 1]
	::cell::geturl "http://mach.usno.navy.mil/cgi-bin/aa_rstablew.pl?year=$arg&type=0&xxplace=taulu&xx0=1&xx1=$xx1&xx2=$xx2&yy0=1&yy1=$yy1&yy2=$yy2&zz1=$timezone&zz0=1" ::nimpparit::parsesunrisetable [list $timezone $arg]
	::cell::wait 2
	} error]} { putlog "getsunrisetable: $error" }
}


proc gettimezone {} {
	return [string range [strftime %z] 2 2]
}


proc parsesunrisetable {token} {
	variable timezone
	variable city

	if {[catch {
	variable ::cell::conf
	set arg [::cell::getcbargs $token]
	set timezone [lindex $arg 0]
	set year [lindex $arg 1]
	set data [split [::cell::geturldata $token] \n]
	if {$year == ""} { set year [clock format [clock seconds] -format %Y] }
	set taulu ""

	foreach line $data {
		if {[regsub -- {^[0123456789][0123456789]  } $line {} line]} {
			regsub -all -- {           } $line {  } line
			regsub -all -- {  } $line {+} line
			set line [split $line +]
			lappend taulu $line
		}
	}

	if {[catch {
	set fh [open "$::cell::conf(cachepath)/pvm_timetable-$year-$timezone-$city.txt" w]
	puts $fh $taulu
	close $fh
	} error]} { putlog "Aurinkotiedoston luominen epäonnistui: $error" }
	} error]} { putlog "parsesunrisetable: $error" }
}


proc sdpub {nick uhost handle chan text} {
	set sd [getstardate [clock seconds]]
	putserv "PRIVMSG $chan :Stardate $sd"
}


proc getstardate {ts} {
}


proc getsunrise {day month year timezone city} {
	variable aurinko
	variable sunrise

	if {$aurinko == 0} { return "" }
	if {![file exists $::cell::conf(cachepath)/pvm_timetable-$year-$timezone-$city.txt]} {
		::cell::geturl "http://www.astro.com/atlas/horoscope?country_list=&expr=$city&submit=Search" ::nimpparit::getlongitudes $year
		::cell::wait 3
		if {![file exists $::cell::conf(cachepath)/pvm_timetable-$year-$timezone-$city.txt]} { return }
	}
	if {$sunrise == ""} {
		set fh [open "$::cell::conf(cachepath)/pvm_timetable-$year-$timezone-$city.txt" r]
		set sunrise [gets $fh]
		close $fh
	}

	incr day -1 ; incr month -1
	set srise [lindex [lindex [lindex $sunrise $day] $month] 0]
	set sset [lindex [lindex [lindex $sunrise $day] $month] 1]
	incr day 1 ; incr month 1

	set nousee [string range $srise 0 1]:[string range $srise 2 3]
	set laskee [string range $sset 0 1]:[string range $sset 2 3]
	if {[clock scan "$year-$month-$day $nousee"] > [clock seconds]} { set naika "nousee" } else { set naika "nousi" }
	if {[clock scan "$year-$month-$day $laskee"] > [clock seconds]} { set laika "laskee" } else { set laika "laski" }
	return " Aurinko $naika $nousee ja $laika $laskee."
}


## toivottavasti palvelimesi timezone on konffattu oikein. Tuohon voi kyllä
## hutkaista suoraan numeronkin, mutta silloin kesäaikaa ei oteta huomioon
## -> huono asia

set ::nimpparit::timezone [gettimezone]
set ::nimpparit::sunrise ""

if {[catch {
	if {$aurinko == 1 && ![file exists $::cell::conf(cachepath)/pvm_timetable-[clock format [clock seconds] -format %Y]-$timezone-$city.txt]} {
		::cell::geturl "http://www.astro.com/atlas/horoscope?country_list=&expr=$city&submit=Search" ::nimpparit::getlongitudes ""
		::cell::wait 2
	}
} error]} { putlog $error }

}
## end namespace