#
#	Proggis v3.01 by (c)cell	(cell@amigafin.org)
#	http://cell.isoveli.org/scripts
#
#	!prog	<hakusana> [nyt] [seur] [spoil] [notify] [sat] [today]
#		<hakusana> [nadd] [ndel] | [nlist]
#		[nyt] [seur]
#
#	!help prog
#
#	Muista konffata skripta (proggis.conf)
#	Ohjelmia haetaan regexp patternin mukaan (.* toimii perinteisenä *-jokerina, esim. 's.*kansiot')
#
#
#
#	3.01		Toimii taas ku olivat ovelukset muuttaneet taas pikkusen sivua
#	3.0		Päivityskellonajat vaihdettu randomiksi ohjalmat.info palvelimen kuorman vähentämiseksi
#	2.25		.prog nadd ei enää hyväksy 'tyhjän' ohjelman lisäämistä, jolloin kaikki ohjelmat
#			ilmoitettaisiin. '.*' ajaa tietysti saman asian jos joku niin _haluaa_ tehdä.
#	(fixed)		No nyt se toimii oikeesti
# 	2.22		Botti napsahti pois irkistä jos nyt ja spoil switchejä käytettiin samaan
#			aikaan.
#  2.19-> 2.20		Cell oli tietysti kämmänny silleen, että case-sensitive skripti ei tajunnu, että
#			ohjelmat.infossa oli välillä SubTV:n nimenä "SubTV" ja toisinaan "Subtv", jolloin
#			jotkut ohjelmat ilmaantuivat listaan kahteen kertaan. Onneksi Cube tuli nahkaisessa
#			kokovartalopuvussaan ja pelasti cellin nololta tilanteelta.
#			Cube korjasi myös telkku.com-viittaukset ohjelmat.info-viittauksiksi.
#			Poistettiin myös kommentit timerien updatessa, nyt nadd:atut ohjelmat ilmoitetaan
#			normaalisti.
#	2.18-> 2.19	nupdate-switchi tehty tarpeettomaksi suorittamalla timerien päivitys automaattisesti
#			today:tä käyttettäessä.
#	2.17-> 2.18	y2k3 bugi korjattu
#	2.16-> 2.17	Ohjelmatiedot bugasivat tietyssä tilanteessa kuun ensimmäisestä päivästä johtuen.
#			HUOM. Jos päivityksen jälkeen homma ei heti toimi, niin tuhoa cellgen
#			cache-dirrikasta kaikki progs-alkuiset tiedostot.
#	2.14-> 2.16	Ohjelmien spoil-tiedoista on nyt mahdollista karsia ohjaaja- ja näyttelijätiedot
#			floodin vähentämiseksi. Configista saa nyt myös säätää spoil-tiedot jaettavaksi
#			parille riville jos ne eivät muuten mahdu.
#	2.12-> 2.14	Elokuvien spoilissa näkyy nyt IMDB linkki, silloinkun se on saatavilla
#	2.10-> 2.12	NYT switchi bugas jos kanavalla oli menossa viiminen ohjelma päivältä
#	2.08-> 2.10	user-konffattavat notify-viestit. esim: ".prog nadd vip :tissejä nelosella! ($ohjelma)"
#			Tarkemmat ohjeet uusimmassa config fileessä.
#	2.06-> 2.08	proggis on nyt namespace independentti, joka tosin Sinun elämääsi ei vaikuta mitenkään.
#	2.04-> 2.06	automaaginen cachedirrikan siivoominen, sinne alko kerääntymään kanaa liikaa
#	2.02-> 2.04	siirryttiin käyttämään ohjelmat.info:a telkku.com:n sijaan, koska sitä tuntuu
#			ylläpitävän hieman ammattitaitoisempi porukka. Tiedä sitten mikä kikkailu
#			homman taustalle on kätketty, ostiko Jadecon Elisalta domainin + tauhkat, mutta
#			niin että elisa saa vielä itse pitää vanhaa telkku.com:ia tuola ohjelmat.info:ssa..
#			NYT tulevien ohjelmien löytämisen logiikkaa tuli taas korjailtua ihmismielelle
#			sopivaksi.
#	2.01-> 2.02	fix fix
#	2.0 -> 2.01	NYT-switchi fiksattu, ei tosin kunnolla testattu :-)
#	1.9 -> 2.0	sivujen annaltahaku (cachetus)
#			erillinen config-tiedosto
#			dcc chatin .nupdate
#			joitain pieniä korjauksia
#	1.844 -> 1.9	aktiiviset kanavat ovat nyt konffattavissa, ja vielä erikseen nyt/seur switcheille
#			päivämäärä on nyt tyyliin '24.3.' (ennen '24.3')
#			korjattu epäloogista toimintaa yön pikkutunneilla
#			case sensitiivisyys toimii nyt kanavalla haettaessa stringeissä jossa on yksikin
#			iso kirjain. notify-listan ohjelmat haetaan aina ei-casesensitiivisesti.
#			Huom muuten 70's show heittomerkki on telkku.com:ssa HÄMYMERKKI
#			telkku.com lisäsi lisää kanavia sivullisen, ja tämä toimii nyt sat-switchillä oikein
#			dcc komennot ovat nyt hieman loogisempia ja ohjeet saa .phelp
#	1.84  -> 1.844	pieni buugi aiheutti notify-listan ohjelmien löytämättömyyden mikäli joidenkin
#			listan ohjelmien määrittelyissä oli käytetty isoja kirjaimia.
#	1.84  -> 1.842	switchien regexpit korjattu bugittomiksi (vaatiit tcl8.2+)
#			24h today switchin limitti oli vahingossa sittenkin 60 päivää :D
#	1.82  -> 1.84	tiivissä tulostusmuodossa voi nyt säätää montako ohjelmaa per kommentti näytetään
#			dcc chatissa uudet käskyt .showprognlist .delprognlist .copyprognlist .prognadd .progndel
#			aliakset (esim. tv1 -> yle1, tv2 -> yle2), tekstien konffattava formatointi,
#			proggis(show_current_prog)
#	1.8   -> 1.82	konffattavat switchit + sälää, ja .prog today joka kertoo päivän parhaat
#			ohjelmat ;) (siis näyttää notify-ohjelmat 24h sisällä). Myöskin yölliset nyt/seur
#			switchien omituiset käyttäytymiset (ei siitä sen enempä...) on korjattu
#			Lisäksi jos käyttäjä hakee sanalla jossa on ISOJA kirjaimia, haku tehdään
#			case-sensitiivisesti
#	1.64  -> 1.8	Kesto-notify-lista komentoineen (nadd, ndel, nupdate)
#			tuplatimereitä ei enää tehdä
#			paljon joitain pieniä yksityiskohtia (joita en muista)
#	1.63 -> 1.64	Skripta vaihtaapi kompaktiin tulostusmoodiin jos ohjelmia löytyy paljon.
#			Ominaisuuden voi kytkeä pois.
#	1.62 -> 1.63	NYT menossa olevan ohjelman spoilaus on mahdollista. Itseasiassa muutos
#			on käytännössä se, ettei ohjelmatietoja näytetä tiiviissä muodossa, jos
#			niitä löytyy vain yksi. esim. '.prog nyt spoil mtv3'
#	1.6  -> 1.62	Elokuvien ohjelmanimissä on nyt lopussa "(Elokuva)", joka mahdollistaa
#			kätevästi ".prog elokuva" -komennon
#	1.156-> 1.6	switchit 'nyt' ja 'seur' lisätty. toimii nyt täydellisenä !tv skriptan
#			korvikkeena.
#	1.154-> 1.156	minuuttilaskurissa oli bugi kuukauden vaihtuessa
#	1.152-> 1.154	bugi minuuttilaskurin kohdalla josta seurasi paikoitellen 10-20 minuutin laskuvirhe
#	1.15 -> 1.152	poistin vanhoista versioista jääneet debuggauskoodit :-)
#	1.12 -> 1.15	'sat' ja 'next'
#	1.1  -> 1.12	minuuttilaskurin _pitäisi_ olla taas vähän parempi
#	1.07 -> 1.1:	tiedot haetaan telkku.com:sta, uusia kanavia tuli, digikanavat meni, cache lähti
#	1.05 -> 1.07:	korjattu buugeja ja osaa ylen digikanavat
#	1.02 -> 1.05:	cachettaa urlit (kuukauden välein cache dellitään [cellgen.tcl])
#
#
#

package require cellgen 2.42
namespace eval ::cell::scripts::proggis {
set scriptversion 3.01
::cell::registerautoupdate $scriptversion http://cell.isoveli.org/scripts/tproggis.tcl
set cnamespace [namespace current]



## bindaukset. Jos muuttelet näitä, kannattaa siirtää rivit samantien config fileeseen,
## jottapa muutokset säilyvät autoupdaten jälkeenkin.

bind pub - !tv ${cnamespace}::preprog
bind pub - .tv ${cnamespace}::preprog
bind pub - !prog ${cnamespace}::preprog
bind pub - .prog ${cnamespace}::preprog
bind pub - .pupdate ${cnamespace}::preprogupdate
bind msg - prog ${cnamespace}::progmsg

# timerit päivitetään nykyään jokaisen today-komennon yhteydessä
bind time - "[rand 60] 02 % % %" ${cnamespace}::nupdate
bind time - "[rand 60] 07 % % %" ${cnamespace}::nupdate
bind time - "[rand 60] 09 % % %" ${cnamespace}::nupdate
bind time - "[rand 60] 12 % % %" ${cnamespace}::nupdate
bind time - "[rand 60] 06 % % %" ${cnamespace}::getprogs

bind dcc m phelp ${cnamespace}::dcc_help
bind dcc m plisttimers ${cnamespace}::dcc_listtimers
bind dcc m pkilltimers ${cnamespace}::dcc_killtimers
bind dcc m pshownlist ${cnamespace}::dcc_shownlist
bind dcc m pcopynlist ${cnamespace}::dcc_copynlist
bind dcc m pdelnlist ${cnamespace}::dcc_delnlist
bind dcc m pnadd ${cnamespace}::dcc_nadd
bind dcc m pndel ${cnamespace}::dcc_ndel
bind dcc m pnupdate ${cnamespace}::nupdate


set erno [catch { 
	set proggis(customnformat) 1
	set proggis(parse_spoil) 0
	set proggis(split_spoil) 1
	set proggis(configfile) "$::cell::conf(confpath)/proggis.conf"
	source $proggis(configfile)
} error]
if {$erno} { putlog "ERROR: (proggis.conf): $error ($erno)" }



# ----------------------------------- #
########### START PURKKA ##############
# ----------------------------------- #

proc progmsg {nick uhost handle args} {
	prog $nick $uhost $handle $nick [lindex $args 0] 1 1
}

proc preprog {nick uhost handle chan args} {
	prog $nick $uhost $handle $chan [lindex $args 0] 1 0
}

proc preprogupdate {nick uhost handle chan args} {
	getprogs
	putserv "PRIVMSG $chan :boing"
}

proc prog {nick uhost handle chan args chancheck privaccess} {

	variable proggis
	variable format
	variable cnamespace

	regsub -all -- {\{|\}|\\[|\\]|"} $args {} args

	if {$privaccess == 0} {
		foreach channel $proggis(channels) { if {[regexp -nocase -- "^$channel\$" $chan]} { set ok 1 } }
		if {![info exists ok]} { return }
	}

	if {$chancheck} { 
		if {$privaccess == 1} { set mod "_private" } else { set mod "" }
		if {![${cnamespace}::checkaccess $handle $nick $proggis(needop$mod) $chan]} { return 1 }
	}

	set chan [string tolower $chan]
	set args [${cnamespace}::applyaliases [${cnamespace}::lowscands $args]]
	set proggis(progsperchannel) 0
	set proggis(show_current_prog_forced) $proggis(show_current_prog)
	set lines $proggis(flood_multiple_lines)
	set compact 0
	set canspoil 0

	if {[regexp -- "$proggis(switch_nadd)|$proggis(switch_ndel)|$proggis(switch_nlist)|$proggis(switch_nupdate)" $args]} {
		if {$privaccess == 0 || $proggis(personal_nlist) == 1} { 
			${cnamespace}::notifylist $args $nick $chan $handle $privaccess
		} else { putserv "$proggis(outtext) $chan :Henkilökohtainen notify-lista ei ole käytössä" }
		return
	}

	if {[::cell::testswitch args $proggis(switch_spoil)]} { set canspoil 1 } else { set canspoil 0 }
	if {[::cell::testswitch args $proggis(switch_notify)]} { set notify 1 } else { set notify 0 }
	if {[::cell::testswitch args $proggis(switch_sat)]} { set proggis(max_subpagestemp) 5 ; set proggis(sat_active) 1 } else { set proggis(sat_active) 0 ; set proggis(max_subpagestemp) $proggis(max_subpages) }
	if {[::cell::testswitch args $proggis(switch_seur)]} { set proggis(show_current_prog_forced) 0 ; incr proggis(progsperchannel) }
	if {[::cell::testswitch args $proggis(switch_nyt)]} { set proggis(show_current_prog_forced) 1 ; incr proggis(progsperchannel) }
	if {$proggis(progsperchannel)>0} { set compact 1 ; if {$args == ""} { set args ".*" } }

	regsub -all -- {^ +| +$} $args {} args
	regsub -all -- {\+} $args {\\+} searchstring

	if {[::cell::testswitch args $proggis(switch_today)]} {
		set canspoil 0
		if {$privaccess} { 	set flood [${cnamespace}::getprogstoday $searchstring "u$handle"] } else {
					set flood [${cnamespace}::getprogstoday $searchstring $chan]
		}
		if {$flood == ""} { putserv "$proggis(outtext) $chan :Tänään ei tule MITÄÄN telkkarista." ; return }
	} else {
	        set flood [${cnamespace}::findprogs $searchstring $canspoil $notify $chan]
	}


        if {$flood == ""} { putserv "$proggis(outtext) $chan :\"$args\". Ei sellaista." } else {
		if {$flood == 1} { return 1 }
		if {[llength $flood] == 1} { set compact 0 }
		if {[llength $flood] > $proggis(flood_multiple_lines) && $proggis(switch_to_compact)} { set compact 1 }
		if {[llength $flood] > 1 && $proggis(switch_to_compact) == 2} { set compact 1 }
		set count 0 ; set outflood "" ; set ccount 0 ; set floodpile ""
		getdate [clock seconds] omonth oday oyear
		set ldate "$oday.$omonth."

		foreach entry $flood {
			if {$count < $lines} { 

				set pvm [format pvm [lindex $entry 1]]
				set kanava [format kanava [lindex $entry 2]]
				set aika [format aika [lindex $entry 3]]
				set ohjelma [format ohjelma [lindex $entry 4]]
				set spoil [format spoil [lindex $entry 5]]
				set aikamaara [format aikamaara [lindex $entry 6]]

				set add 0
				if {$compact} {
					incr ccount
					if {$ccount >= $proggis(compact_progs_per_line)} {
						set ccount 0
						set add 1
					}
		       			if {$pvm == $ldate} { eval "append floodpile \"$format(prog_compact)\"" } else {
						eval "append floodpile \"$format(prog_compact_wdate)\"" }
				} else {
					if {$spoil != ""} {
			       			eval "append floodpile \"$format(prog_normal_spoil)\""
					} else {
			       			eval "append floodpile \"$format(prog_normal)\""
					}
					set add 1
				}
		                if {$notify == 1 && [expr "[lindex $entry 0]-2"] > 0} {
					${cnamespace}::settimer $entry $chan ""
		                        append floodpile " \[notify\]"
		                }
				regsub -all -- {\{|\}} $floodpile {} floodpile
				if {$add} {
					regsub -all -- { \| $} $floodpile {} floodpile
					set newpile ""
					if {$proggis(split_spoil) && [string length $floodpile]>450} {
						foreach k [split $floodpile " "] {
							if {[expr [string length $newpile]+[string length $k]]<450} {
								append newpile "$k "
							} else {
								append newpile "..."
								lappend outflood "$proggis(outtext) $chan :$newpile"
								set newpile "... $k "
							}
						}
						set floodpile $newpile
					}
					lappend outflood "$proggis(outtext) $chan :$floodpile"
					set floodpile ""
					incr count
				} else { lappend floodpile " | " }
			}
		}
		regsub -all -- {\{|\}} $floodpile {} floodpile
		regsub -all -- { \| $} $floodpile {} floodpile
		if {$floodpile != ""} { lappend outflood "$proggis(outtext) $chan :$floodpile" }
		foreach korva $outflood { putserv $korva }
		return 1
	}
}


proc getdate {ctime day month year} {
	upvar $day oday
	upvar $month omonth
	upvar $year oyear
        regsub -all -- "^0" [clock format $ctime -format "%m"] "" omonth
        regsub -all -- "^0" [clock format $ctime -format "%d"] "" oday
        set oyear [clock format $ctime -format "%y"]
}


proc findprogs {ohjelma canspoil notify chan} {

	variable proggis
	variable format
	variable ::cell::conf
	variable cnamespace

	set ctime [expr [clock seconds] - (60*60*24)]

	set proglist ""
	set allchannels ""
	set pagecount 0
	set subpage 0

	if {([string tolower $ohjelma] != $ohjelma) && (![regexp -- "\\|" $ohjelma])} { set casesensitive 1} else { set casesensitive 0}


        while {$pagecount < $proggis(max_days)} {
		set channels ""
		set progfound 0
		set validchan 0

		getdate $ctime oday omonth oyear
		set filename "$::cell::conf(cachepath)/progs-$oday-$omonth-$oyear-$subpage.txt"
		set erno [catch {set hand [open $filename r]} error]

		if {$erno == 0} {
		while {![eof $hand]}  {

			set entry [gets $hand]

			set channelname [lindex $entry 2]
			if {[lsearch $allchannels $channelname] == -1 && $channelname != ""} { lappend allchannels $channelname }
			if {![info exists ppccount($channelname)]} { set ppccount($channelname) 0 }

			if {$proggis(progsperchannel)} {
				if {[regexp -nocase -- $proggis(fav_channels) $channelname]} { set validchan 1} else { set validchan 0 }
			} else {
				if {[regexp -nocase -- $proggis(match_channels) $channelname]} { set validchan 1} else { set validchan 0 }
			}
			if {$proggis(sat_active)} { if {$channelname != "" && $channelname != "-"} { set validchan 1 } }

			if {$validchan} {

				set pyear [lindex $entry end]
				set proggisnimi [lindex $entry 4]
				set aika [lindex $entry 3]
				set day [lindex $entry 0]
				set month [lindex $entry 1]
				set progentry [list $day.$month. $channelname $aika $proggisnimi]

				if {[info exists lwasset($channelname)]} {
					regsub -all -- {-.*} $aika {} daika
					regsub -all -- {.*-} $aika {} lproge($channelname)
					set minutes [${cnamespace}::calcminutes $daika $day $month "" $pyear]
					unset lwasset($channelname)
					if {$minutes > 0} { set nowok($channelname) 1 } else { set lprog($channelname) "" }
				}

				if {([regexp -nocase -- $ohjelma $progentry] && $casesensitive==0) || ([regexp -- $ohjelma $progentry])} { 
					set spoiler [lindex $entry 5]
					set minutes 666
					regsub -all -- {-.*} $aika {} daika
					regsub -all -- {.*-} $aika {} lproge($channelname)
					set minutes [${cnamespace}::calcminutes $daika $day $month $progentry $pyear]
					set progentry "$minutes $progentry"

					if {[llength $proglist] > $proggis(flood_multiple_lines)} { set canspoil 0 }
					set newentry [${cnamespace}::addprog $progentry $minutes $canspoil $aika $spoiler]

					if {$minutes > 0} {

						# add the found program if there's still room
						if {($proggis(progsperchannel)==0 || ($ppccount($channelname) < $proggis(progsperchannel)))} {
						if {$proggis(show_current_prog_forced) != 1 || $proggis(progsperchannel) != 1} {
						if {[expr $ppccount($channelname)+$proggis(show_current_prog_forced)] < $proggis(progsperchannel) || $proggis(progsperchannel)==0} {
							lappend proglist $newentry
							incr ppccount($channelname)
						}
						}
						}
						set nowok($channelname) 1
						if {$proggis(show_current_prog_forced) != 1} { set lprog($channelname) "" }
					} else {
						set lprog($channelname) $newentry
						set lwasset($channelname) 1
					}
				}
			}

		}

		set nonpok 0
		foreach channelname $allchannels {
			# was the previously found program still running and should it be included?
			if {![info exists lprog($channelname)]} { set lprog($channelname) "" }
			if {![info exists mok($channelname)]} { set mok($channelname) 0 }

			if {$lprog($channelname) != "" && $proggis(show_current_prog_forced)} {
				if {[info exists nowok($channelname)]} {
					lappend proglist $lprog($channelname)
					incr ppccount($channelname)
					set lprog($channelname) ""
				}
			}
		}

		close $hand
		}

		incr subpage
		if {$subpage == $proggis(max_subpagestemp)} {

			if {$ohjelma == "" && $allchannels != ""} {
				set out "!tv <hakusana> \[nyt] \[seur] \[spoil\] \[notify\] \[sat\] \[today\] | \[nyt\] \[seur\] | <hakusana> \[nadd\] \[ndel\] | \[nlist\]. Osaan [join $allchannels ", "]"
				putserv "$proggis(outtext) $chan :$out"
				return 1
			}

			if {[llength $proglist] > 0 && $proggis(progsperchannel) == 0} {
				set proglist [lsort -integer -index 0 $proglist]
				return [getspoils $proglist]
			}

			set ctime [expr $ctime + (60*60*24)]
                        set subpage 0
			incr pagecount
		}
	}

	set proglist [lsort -integer -index 0 $proglist]
	return [getspoils $proglist]
}


# tcl8.0 ei osaa lowercasettaa skandeja
proc lowscands {i} {
	regsub -all -- {Ö} $i {ö} i
	regsub -all -- {Ä} $i {ä} i
	return $i
}



proc calcminutes {kello day month foobar year} {

	variable proggis

	set otime [clock scan "$kello $year-$month-$day"]
	set ttime [clock seconds]
	return [expr ($otime - $ttime) / 60]
}


proc getprogstoday {args chan} {
	variable cnamespace
	set flood ""

	${cnamespace}::nupdate
	set t [timers]

	foreach ct $t {
		if {[lindex [lindex $ct 1] 0] == "${cnamespace}::prognotifypre" && [lindex [lindex $ct 1] 1] == $chan} {
			if {[lindex $ct 0] < 60*24} {
				set floodadd [${cnamespace}::addprog [lindex [lindex $ct 1] 2] [lindex $ct 0] 0 0 ""]
				set floodadd [lreplace $floodadd 0 -1 [lindex $ct 0]]
				lappend flood $floodadd
			}
		}
	}

	if {[llength $flood] > 0} { set flood [lsort -integer -increasing -index 0 $flood] }
	return $flood
}


proc getspoils {proglist} {
	variable proggis
	variable cnamespace

	foreach entry $proglist {
		set spoiler "" ; set aok 0
		set spoilerurl [lindex [split [lindex $entry end-1] #] 0]
		if {$spoilerurl != ""} {
			set c [cell_geturl $spoilerurl ""]
			set imdb ""
			foreach l [split $c \n] {
				if {[regexp -- {<hr} $l]} { set aok 1 }
				if {[regexp -- "<br><br>" $l] && $aok == 0} {
					set ll [cell_formattext $l]
					regsub -all -- {^ +| +$} $ll {} ll
					if {$ll != "" && ![regexp [lindex [split [lindex $entry end-1] #] 1] $ll]} { set spoiler $ll }
				}
				if {[regexp -- "imdb.com" $l]} { set imdb [regexp -inline -- {href="([^"]*)"} $l] }
			}
			if {$proggis(parse_spoil)} { regsub -all -- {Ohjaaja:.*|Pääosissa:.*} $spoiler {} spoiler }
			if {$imdb != ""} { append spoiler " [lindex $imdb 1]" }
		}

		lappend newlist [lreplace $entry end-1 end-1 $spoiler]
	}

	if {![info exists newlist]} { set newlist $proglist }
	return $newlist
}


proc addprog {progentry minutes canspoil aika spoilerurl} {
	variable proggis
	variable cnamespace

	set spoiler ""
	if {$canspoil == 1} {
		if {[regexp -- "^http" $spoilerurl]} {
			set spoiler "$spoilerurl#$aika"
		}
	}
	lappend progentry $spoiler

	if {$minutes >= 0} {
		lappend progentry "[${cnamespace}::gettime $minutes] alkuun"
	} else {
		lappend progentry "mennyt jo [${cnamespace}::gettime [expr -$minutes]]"
	}

	return $progentry
}


proc gettime {minutes} {
	set hours [expr $minutes / 60]
	set days "[expr $hours / 24]d"
	set minutes "[expr $minutes % 60]min"
	set hours "[expr $hours % 24]h"

	if {$days != "0d"} {
		return "$days $hours $minutes"
	} elseif {$hours != "0h"} {
		return "$hours $minutes"
	}
	return "$minutes"
}


proc checkaccess {handle nick accesslevel chan} {
	variable proggis

	return 1

	regsub -all -nocase -- "äö" $chan {} channs
	regsub -all -nocase -- "äö" $nick {} nickns

	if {[string tolower $nickns] != [string tolower $channs]} {
		set ok 0
		regsub -all -nocase -- "äö" $proggis(channels) {} pchannelsns
	        foreach i [split $pchannelsns " "] { if {[string tolower $channs] == [string tolower $i]} { set ok 1 } }
	        if {$ok == 0} {
			putserv "NOTICE $nick :$proggis(noaccess_message)"
			putlog "!proggis: no access for $nick ($handle $chan)"
			return 0
		}
	} else { set chan "" }

	if {($chan == "" && ![matchattr $handle "o|o"] && $accesslevel==2) || ($chan != "" && ![matchattr $handle "o|o" $chan] && $accesslevel==2) || ($handle == "*" && $accesslevel==1)} {
		putserv "NOTICE $nick :$proggis(noaccess_message)"
		putlog "!proggis: no access for $nick ($handle $chan)"
		putlog "!proggis: accesslevel:$accesslevel handle:$handle chan:$chan [matchattr $handle "o|o" $chan] [matchattr $handle "o|o"]"
		return 0
	}

	return 1
}

proc settimer {entry chan cformat} {
	variable cnamespace

	set nstring [lrange $entry 1 4]
	regsub -all {[^a-zA-Z0-9]} $nstring {} nstring
	set t [timers]
	set ok 1
	foreach ct $t {
		if {[lindex [lindex $ct 1] 0] == "${cnamespace}::prognotifypre"} {
			regsub -all {[^a-zA-Z0-9]} [lindex [lindex $ct 1] 2] {} tstring
			if {([subst "$nstring"] == [subst "$tstring"]) && [lindex [lindex $ct 1] 1] == $chan} { set ok 0 }
		}
	}
	if {$ok == 0} { return 0 }

	timer [expr "[lindex $entry 0]-2"] "${cnamespace}::prognotifypre $chan [list [lrange $entry 1 4]] [list $cformat]"

	return 1
}


proc prognotifypre {chan entry cformat} {
	variable format
	variable cnamespace

	if {[string index $chan 0] == "u"} {
		set to [hand2nick [string range $chan 1 end]]
		if {$to == ""} { return }
	} else { set to $chan }

	set kanava [format kanava [lindex $entry 1]]
	set pvm [format pvm [lindex $entry 0]]
	set aika [format aika [lindex $entry 2]]
	set ohjelma [format ohjelma [lindex $entry 3]]
	${cnamespace}::prognotify $to $kanava $pvm $aika $ohjelma $cformat
}


proc prognotify {chan kanava pvm aika ohjelma cformat} {
	variable proggis
	variable format
	if {$cformat == ""} { set f $format(notify) } else { set f $cformat }
	regsub -all -- {[|]} $f {} cformat
        eval "putserv \"$proggis(outtext) $chan :$cformat\""
}



proc applyaliases {string} {

	set errcode [catch {
		variable aliases
		set al [array get aliases]
		if {[llength $al] == 0} { return $string }
		foreach {from to} $al {
			regsub -all -- {\+} $from {\\+} from
			regsub -all -- "\\y$from\\y" $string $to string
		}
	} error]

	if {$errcode != 0} {
		putlog "ERROR (proggis.tcl applyaliases): $error"
		putlog "Virhe johtuu todennäköisesti liian vanhasta tcl versiosta (8.2+ vaaditaan)"
	}

	return $string
}


proc format {element text} {
	variable format
	catch { set text "$format($element)$text$format($element)" }
	return $text
}



########################################################
## NOTIFY-LIST funktiot
########################################################

proc notifylist {args nick chan handle privaccess} {
	variable proggis
	variable cnamespace

	if {$privaccess == 1} { 
		set mod "_private"
		set nlistname "u$handle" 
		if {$handle == "*"} { return 1 }
	} else {
		set mod ""
		set nlistname $chan
	}
	if {![${cnamespace}::checkaccess $handle $nick $proggis(needop_notify$mod) $chan]} { return 0 }

	if {[::cell::testswitch args $proggis(switch_nupdate)]} {
		${cnamespace}::nupdate
		putserv "$proggis(outtext) $chan :Notify-listan timerit päivitetty"
		return 1
	}

	if {[::cell::testswitch args $proggis(switch_nlist)]} {
		set bar ""
		${cnamespace}::nload
		catch {foreach foo [getnlistpure $proggis("nlist-$nlistname")] { append bar "'$foo', " }}
		regsub ", $" $bar "" bar
		if {$bar == ""} { set bar "-Ei Mitään-" }
		putserv "$proggis(outtext) $chan :Notify-listassa ($chan): $bar"
		return 1
	}

	if {$args == ""} {
		putserv "$proggis(outtext) $chan :Anna myös ohjelman nimi"
		return 1
	}

	if {[::cell::testswitch args $proggis(switch_nadd)]} {
		if {[${cnamespace}::ndel $args $nlistname]} {
			${cnamespace}::nadd $args $nlistname $handle $privaccess
			putserv "$proggis(outtext) $chan :'$args' Korvattu"
		} else {
			if {![${cnamespace}::nadd $args $nlistname $handle $privaccess]} {
				putserv "$proggis(outtext) $chan :Anna myös lisättävän ohjelman nimi"
			} else {
				regsub -all -- {:.*} $args {} args
				putserv "$proggis(outtext) $chan :'$args' Lisätty muistutettaviin ohjelmiin"
			}
		}
		return 1
	}

	if {[::cell::testswitch args $proggis(switch_ndel)]} {
		if {[${cnamespace}::ndel $args $nlistname]} {
			putserv "$proggis(outtext) $chan :'$args' Poistettu"
		} else {
			putserv "$proggis(outtext) $chan :Ohjelmaa '$args' ei löydy listasta. nlist komennolla näät listan"
		}
		return 1
	}

	return 0
}


proc nadd {args nlistname handle privaccess} {
	variable proggis
	variable cnamespace

	regsub -all "^ " $args "" args
	if {$args == ""} { return 0 }
	lappend proggis("nlist-$nlistname") $args
	if {$privaccess == 1 && [lsearch -exact $proggis(nusers) $handle] == -1 } { lappend proggis(nusers) $handle }
	${cnamespace}::nsave
	${cnamespace}::nload
	${cnamespace}::nupdate
	return 1
}


proc ndel {args nlistname} {
	variable proggis
	variable cnamespace

	if {![info exists proggis("nlist-$nlistname")]} { return 0 }

	regsub -all "^ |:.*" $args "" args
	set num [lsearch -exact [string tolower [getnlistpure $proggis("nlist-$nlistname")]] [string tolower $args]]
	if {$num == -1} {
		return 0
	} else {
		set proggis("nlist-$nlistname") [lreplace $proggis("nlist-$nlistname") $num $num]
		${cnamespace}::nsave
		${cnamespace}::nload
	}
	return 1
}


proc nload {} {
	variable proggis

	foreach foo $proggis(channels) { set proggis("nlist-$foo") "" }
        set virhe [catch "set fiilu [open $proggis(nlistfile)]"]
	set proggis(nusers) ""

        if {$virhe == 0} {
		for {} {![eof $fiilu]} {} {
			set a [gets $fiilu]
			set proggis("nlist-[lindex $a 0]") [lindex $a 1]
			if {[lindex $a 1] == "{}"} { set proggis("nlist-[lindex $a 0]") "" }
			if {[string index [lindex $a 0] 0] == "u"} {
				lappend proggis(nusers) [string range [lindex $a 0] 1 end]
			}
		}
		close $fiilu
	} else {
		putlog "HUOM! proggis ei onnistunut avaamaan notify-list tiedostoa tai se puuttuu"
		return 1
	}

}


proc nsave {} {
	variable proggis

        set virhe [catch "set fiilu [open $proggis(nlistfile) "w" 0770]"]

        if {$virhe == 0} {
		foreach foo $proggis(channels) {
			if {$proggis("nlist-$foo") != ""} {
		                puts $fiilu [list $foo $proggis("nlist-$foo")]
			}
		}
		foreach foo $proggis(nusers) {
			if {$proggis("nlist-u$foo") != ""} {
		                puts $fiilu [list "u$foo" $proggis("nlist-u$foo")]
			} else {
				set num [lsearch $proggis(nusers) $foo]
				set proggis(nusers) [lreplace $proggis(nusers) $num $num]
			}
		}
		close $fiilu
	} else {
		putlog "VIRHE: .prog ei onnistunut tallentamaan notify-listiä"
		return 1
	}
}


proc nupdate { args } {
	variable proggis
	variable cnamespace

	set erno [catch {

	set tlist $proggis(channels)
	foreach t $proggis(nusers) { lappend tlist "u$t" }

	set tcount 0
	foreach chan $tlist { 
		set sstring ""

		set sstring [${cnamespace}::getnlistreg $proggis("nlist-$chan")]
		if {$sstring != ""} {
			set flood [${cnamespace}::findprogs $sstring 0 1 $chan]
			foreach entry $flood { 
				if {[expr "[lindex $entry 0]-2"] > 0} {
					set customformat [${cnamespace}::getnotifyformat $proggis("nlist-$chan") $entry]
					if {[settimer $entry $chan $customformat]} { incr tcount }
				}
			}
		}
 	}

	# pois turha logifloodi
	putlog "proggis: $tcount ajastinta asetettu notify-listan mukaan"

	} error]
	if {$erno != 0} { putlog "proggis: nupdate: $error" }

	if {[lindex $args end] != 1} { ${cnamespace}::nupdate 1 }
}


proc getnotifyformat {nlist entry} {
	variable cnamespace
	variable format
	variable proggis

	if {$proggis(customnformat) == 0} { return $format(notify) }
	set snlist [${cnamespace}::getnlistpure $nlist]
	set idx 0

	foreach nitem $snlist {
		if {[regexp -nocase -- $nitem $entry]} {
			regsub -all -- {.*:} [lindex $nlist $idx] {} cformat
			if {[regexp -- ":" [lindex $nlist $idx]]} { return $cformat }
		}
		incr idx
	}
	return $format(notify)
}

proc getnlistpure {nlist} {
	set sstring ""
	foreach bar $nlist {
		regsub -all -- {:.*} $bar {} bar
		lappend sstring $bar
	}
	return $sstring
}

proc getnlistreg {nlist} { return [join [getnlistpure $nlist] "|"] }


##################################################
## DCC komennot
##################################################

proc dcc_help {hand idx args} {
	putdcc $idx {
	.phelp					- näyttää kaikki proggiksen dcc käskyt
	.plisttimers [regexp]			- listaa notify-ajastimet
	.pkilltimers [regexp]			- poistaa notify-ajastimet
	.pshownlist [kanava/käyttäjä]		- näyttää notify-lista(n/t)
	.pdelnlist <kanava/käyttäjä>		- poistaa notify-lista(n/t)
	.pcopynlist <kanava> <kanava>		- kopioi notify-listan kanavalta toiselle
	.pnadd <kanava/käyttäjä> <ohjelma>	- lisää notify-listaan (.prog <ohjelma> nadd)
	.pndel <kanava/käyttäjä> <ohjelma>	- poistaa notify-listasta (.prog <ohjelm> ndel)
	}
}


proc dcc_shownlist {hand idx args} {
	variable proggis
        set virhe [catch "set fiilu [open $proggis(nlistfile) "r" 0770]"]
	regsub -all -- {\{|\}} $args {} args
        if {$args == ""} { set args ".*" }

        if {!$virhe} {
		set slist ""
                foreach foo $proggis(channels) { lappend slist [list "\"nlist-$foo\"" $foo] }
                foreach foo $proggis(nusers) { lappend slist [list "\"nlist-u$foo\"" $foo] }

		foreach ent $slist {
			if {[regexp -- $args [lindex $ent 0]]} {
				set user [lindex $ent 1]
				if {$proggis([lindex $ent 0]) != ""} {
					putdcc $idx "$user: $proggis([lindex $ent 0])"
				}
			}
		}

                close $fiilu
        } else {
                putlog "VIRHE: .prog ei onnistunut lukemaan notify-listiä"
        }

	return 1
}


proc dcc_copynlist {hand idx args} {
	variable proggis
	variable cnamespace

	regsub -all -- {\{|\}} $args {} args
	if {[catch {set source $proggis("nlist-[lindex $args 0]")}]} {
		putlog "Virheellinen lähde ([lindex $args 0])"
		return 1
	}

	set proggis("nlist-[lindex $args 1]") $source
	${cnamespace}::nsave
	${cnamespace}::nload
	${cnamespace}::dcc_shownlist $hand $idx [lindex $args 1]
	return 1
}


proc dcc_delnlist {hand idx args} {
	variable cnamespace
	variable proggis
	set proggis("nlist-[lindex $args 0]") ""
	${cnamespace}::nsave
	${cnamespace}::nload
	putdcc $idx "$args notify-lista tuhottu"
	return 1
}


proc dcc_nadd {hand idx args} {
	variable proggis
	variable cnamespace
	regsub -all -- {\{|\}} $args {} args

	# channel
	${cnamespace}::nadd [lrange $args 1 end] [lindex $args 0] "" 0
	# user
	${cnamespace}::nadd [lrange $args 1 end] "u[lindex $args 0]" "" 0

	${cnamespace}::dcc_shownlist $hand $idx [lindex $args 0]

	return 1
}


proc dcc_ndel {hand idx args} {
	variable proggis
	variable cnamespace
	regsub -all -- {\{|\}} $args {} args
	# channel
	${cnamespace}::ndel [lrange $args 1 end] [lindex $args 0]
	# user
	${cnamespace}::ndel [lrange $args 1 end] "u[lindex $args 0]"

	${cnamespace}::dcc_shownlist $hand $idx [lindex $args 0]
	return 1
}


proc dcc_listtimers {hand idx args} {
	variable cnamespace

	set args [lindex $args 0]
	if {$args == ""} { set args ".*" }
	set t [timers]
	foreach ct $t {
		set nstring "[lrange [lindex $ct 1] 1 end]"
		if {[lindex [lindex $ct 1] 0] == "${cnamespace}::prognotifypre" && [regexp -nocase -- $args $nstring]} {
			putdcc $idx [lindex $ct 1]
		}
	}
}


proc dcc_killtimers {hand idx args} {
	variable cnamespace
	set args [lindex $args 0]
	if {$args == ""} { set args ".*" }
	set t [timers]
	foreach ct $t {
		set nstring [lrange [lindex $ct 1] 1 end]
		if {[lindex [lindex $ct 1] 0] == "${cnamespace}::prognotifypre" && [regexp -nocase -- $args $nstring]} {
			killtimer [lindex $ct 2]
			putdcc $idx "killed: [lindex $ct 1]"
		}
	}
}


#############################
# Ohjelmatietojen cachetus
#############################

proc getprogs {args} {
	variable cnamespace
	variable proggis

	putlog "Haetaan ohjelmatietoja"
#	cell::geturl "http://ohjelmat.info/tv/index.html" ${cnamespace}::parseprogs [list 0 0]
	cell::geturl "http://elisaviihde.fi/ohjelmaopas/" ${cnamespace}::parseprogs [list 0 0]
}


proc parseprogs { token } {

	variable cnamespace
	variable ::cell::conf
	variable format
	variable proggis

	set erno [catch {

	set foo [split [cell::geturldata $token] \n]
	set args [cell::getcbargs $token]
	set pagecount [lindex $args 0]
	set subpage [lindex $args 1]
	if {$foo == ""} { putlog "proggis: Unable to access progs - rehash manually to update" ; return }

	set channels ""
	set cchannel -1
	set ccount 0
	set progfound 0
	set proglist ""
	set nextlinenimi 0
	set year [clock format [clock seconds] -format "%y"]

        set filename "$::cell::conf(cachepath)/progs-debug-$pagecount-$subpage.html"
	putlog "$filename"
        set hand [open $filename w]
        foreach line $foo { puts $hand $line }
        close $hand

	foreach line $foo  {

		# take year
		if {![info exists gotyear]} {
			if {[regexp -nocase -- {pvm=\d} $line]} {
				set year [string range [lindex [regexp -inline -nocase -- {pvm=(....)} $line] end] 2 3]
				set gotyear 1 ; set oyear $year
			}
		}


		# take date
		if {[regexp -- {<div class="pvm">} $line]} {
			regsub -all -- { } [cell::formattext $line] {} fline
			regsub -- {^0} [string range $fline 2 3] {} day
			regsub -- {^0} [string range $fline 5 6] {} month
			set oday $day ; set omonth $month ; set oyear $year
			putlog "$oday $omonth $oyear"
		}


		# register new channels
		if {[regexp -- {kanava.tv} $line]} {
			set fline [cell::formattext $line]
			if { $fline != "" } {
				regsub -all -- { } $fline {} fline
				regsub -all -- {Subtv} $fline {SubTV} fline
				lappend channels $fline
				set oldaika($ccount) "0"
				set fprog($ccount) 0
				set matchok($ccount) 0
				incr ccount
			}
		}


		# cycle channels
		if {[regexp -- {<table cellspacing="0" cellpadding="1" width="100%">} $line]} {
			if {[incr cchannel] == $ccount} { set cchannel 0 }
			set channelname [lindex $channels $cchannel]
			if {[info exists oday]} {
				set day $oday ; set month $omonth ; set year $oyear
			}
		}


		# take the time
		if {[regexp -nocase -- {class="aika"} $line]} {
			regsub -all -- {\.} "[cell::formattext $line]" {:} fline
			regsub -all -- {^ +| +$} $fline {} aika
			regsub -all -- {:|-.*} $fline {} naika
			regsub -all -- {^[0 ]+} $naika {} naika

			if {$naika < $oldaika($cchannel)} {
				set utime [clock scan "$month/$day/$year"]
				incr utime [expr 60*60*24]
				set day [clock format $utime -format "%d"]
				set month [clock format $utime -format "%m"]
				set year [clock format $utime -format "%y"]
			}
			set oldaika($cchannel) $naika
		}

		if {$nextlinenimi == 1} {
			regsub -all -- {^[ \t]+| +$} $line {} proggisnimi
			if {$ismovie == 1} { append proggisnimi " $format(elokuva)" }
			set progentry [list $day $month $channelname $aika $proggisnimi $spoilurl $year]
			lappend proglist $progentry
			set nextlinenimi 0
		}

		# get spoilerurl and ismovie
		if {[regexp "tiedot.tv" $line]} {
			if {[regexp -- {class="linkbluesmallbold"} $line]} { set ismovie 1 } else { set ismovie 0 }
			regsub -all -- {.*\('|'\).*} $line {} spoilurl
			set nextlinenimi 1
		}
	}

	set filename "$::cell::conf(cachepath)/progs-$oday-$omonth-$oyear-$subpage.txt"
#	putlog "Tallennetaan $filename ([llength $proglist] ohjelmaa)"

	if {[llength $proglist] > 0} {
		set hand [open $filename w]
		foreach p $proglist { puts $hand $p }
		close $hand
	}

	incr subpage ; if {$subpage == 6} { set subpage 0 ; incr pagecount }
	if {$pagecount < $proggis(max_days) } {
		set pvm [clock format [expr [clock seconds] + ($pagecount * 60*60*24)] -format "%Y%m%d"]
		cell::geturl "http://elisa.net/elisatv/tvjaradio/tv/ohjelmat.tv?t=&s=&sivu=[expr $subpage + 1]&pvm=$pvm" ${cnamespace}::parseprogs [list $pagecount $subpage]
		cell::wait 1
		# if {$subpage == 1} { cell::geturl "http://elisa.net/elisatv/tvjaradio/tv/ohjelmat.tv?t=&s=&sivu=[expr $subpage + 1]&pvm=$pvm" ${cnamespace}::parseprogs [list $pagecount $subpage] }
	} else { ${cnamespace}::nupdate }

	catch { exec find "$::cell::conf(cachepath)/progs*" -mtime +3 -exec rm \{\} \\; }

	} error]
	if {$erno != 0} { putlog "ERROR (proggis.tcl getprogs): $erno $error" }

	return 0
}



###########
# INIT
###########

catch {
	::help::newcommand "prog" {<hakusana> [nyt] [seur] [spoil] [notify] [sat] [today] | [nyt] [seur] | <hakusana> [nadd] [ndel] | [nlist]} {Hakee www.ohjelmat.info sivulta ohjelman annetun hakusanan mukaan.}
	::help::extend "prog" "spoil" "Kertoo ohjelmasta hieman laajemmin (sarjoista jaksokuvauksen)"
	::help::extend "prog" "nyt" "Ottaa hakuun mukaan tällä hetkellä menevät ohjelmat"
	::help::extend "prog" "seur" "Ottaa hakuun mukaan seuraavaksi menevät ohjelmat"
	::help::extend "prog" "notify" "Asettaa bottiin ajastimen ja ilmoittaa kanavalla heti kun ohjelma alkaa"
	::help::extend "prog" "sat" "Ottaa hakuun mukaan kaikki ohjelmat.info:n kanavat. \"!prog sat\" näyttää mahdolliset kanavat."
	::help::extend "prog" "today" "Näyttää 24h sisällä tulevat ohjelmat notifylistasta"
	::help::extend "prog" "nadd" "Lisää notify-listaan ohjelman. Esim. !prog salaiset kansiot nadd"
	::help::extend "prog" "ndel" "Poistaa notify-listasta ohjelman. Esim. !prog salaiset kansiot ndel"
	::help::extend "prog" "nlist" "Näyttää notify-listan. Listat ovat kanava-/henkilökohtaisia."

	set proggis(channels) [string tolower $proggis(channels)]
	set proggis(show_current_prog_forced) 0
	set proggis(progsperchannel) 0
	set proggis(max_subpagestemp) $proggis(max_subpages)
	set proggis(nusers) ""
	set proggis(sat_active) 0

	${cnamespace}::getprogs
	${cnamespace}::nload
} error
if {$error != "" && $error != 0} { putlog "ERROR(proggis.tcl -init-): $error" }

putlog "Script loaded: \002proggis v${scriptversion} by cell\002"


################### END PURKKA #######################

}
#end namespace


