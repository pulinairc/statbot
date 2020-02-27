# Ohjelmatiedot
set ohjtied(versio) "4.9.2 (Testiversio)"

# Hakee TV-ohjelmatiedot osoitteesta http://www.telkku.com
#
# Skriptin kotisivu http://bot.gospelnet.fi/?ohjtied
# - katso sieltä käyttö- ja asennusohje sekä versiohistoria
#
# Alkuperäinen ohjtied.tcl < 4.2.2 http://fury.fi/~joep/eggdrop-scripts.php


#################### SKRIPTI ON TESTIVERSIO! ##################################

# Jotkut ominaisuudet eivät ole vielä valmiita, eli seuraavat jutut eivät
# _tiettävästi_ toimi. Tämä ei tarkoita sitä, että kaikki muu toimisi!
# Älä käytä skriptiä jos botin kaatuminen pilaa päiväsi.

# * nyt/seur ei toimi
# * Kanavien järjestys on väärä

#################### Käyttöohje ###############################################

#  'aika' tarkoittaa päivän ja ajan määrittelyä

#  Päivä on joku seuraavista:
#   huomenn[a], ylihuom[enna], maanant[aina], tiistai[na], keskivi[ikkona],
#   torstai[na], perjant[aina], lauanta[ina], sunnunt[aina]
#  Eli siitä tarvitsee kirjoittaa vain seitsemän ensimmäistä kirjainta

#  Aika taas tulee syntaksilla "alkaen h[h]" tai "hh:mm"


#  Tavallinen ohjelmalistaus:
# !tv [nyt/seur/aika] [kanava, [kanava2..]]

# !tv alkaen 20:30
#  - Näyttää konfiguraatiossa määritelyillä kanavilla ohjelmia puoli yhdeksän jälkeen

# !tv seur subtv animalplanet
#  - Näyttää seuraavaksi tulevia ohjelmia subtv:llä ja Animal Planetilla

# !tv ylihuomenna mtv3 alkaen 18
#  - Näyttää ylihuomisen ohjelmat mtv3:lla klo 18:sta eteenpäin


# !tv [aika] elokuvat
#  - Elokuvalistaus

# !tv lauantai elokuvat alkaen 0
#  - Näyttää lauantaina puolenyön jälkeen tulevat elokuvat
#    (perjantain ja lauantain välisenä yönä!)

# !tv alkaen 0
#  - HUOM! Jos tämä ajetaan lauantaina vaikka kello 10:00, listataan lauantain
#    ja sunnuntain välisen yön ohjelmia

# !tv hae [kuvauksista] [kaikki_kanavat] <hakusana>
#  - Haku

# !tv hae big brother
#  - Etsitään kaikkia ohjelmia peruskanavilta (yle1, yle2, mtv3, nelonen ja subtv),
#    joiden nimessä esiintyy "big brother"

# !tv hae kuvauksista kaikki_kanavat ihkudaa
#  - Etsitään kaikilta kanavilta ohjelmia, joiden kuvauksissa tai nimissä esiintyy
#    sana "ihkudaa"


# !tv ohj <kanava> <klo>
#  - Tarkempia tietoja ohjelmasta

# !tv ohj nelonen 15:10
#  - "Sue Thomas, FBI" tulee Neloselta 15:10, katsotaan sen tarkemmat ohjelmatiedot


#################### Konfiguraatio ############################################

# Vaaditaanko, että kysyjä on samalla kanavalla kuin bottikin, kun käytetään msg:a
# 1 = vaaditaan
# 0 = ei vaadita (kaikki IRCissä olijat voivat kysellä!)
set ohjtied(vaaditaanko_kanavalle) 1

# Skripti toimii näillä kanavilla (kirjoita kanavanimet pienellä).
# Jätä tyhjäksi, niin skripti toimii oletuksena kaikilla kanavilla..
set ohjtied(sallitut_kanavat) { #pulina #kuurosokeat }

# .. paitsi näillä (pienellä taas):
set ohjtied(kielletyt_kanavat) { }

# Käytetäänkö WWW-proxy:a (1 = kyllä, 0 = ei)
set ohjtied(use_proxy) 0

# WWW-proxyn osoite ja portti
set ohjtied(proxy) "cache.inet.fi"
set ohjtied(proxyport) 800

# Montako TV-ohjelmaa näytetään per rivi
set ohjtied(naytetaan_ohjelmia) 5

# Moneltako kanavalta voidaan maksimissaan näyttää tv-ohjelmia kerralla
set ohjtied(naytetaan_kanavia) 4

# Montako elokuvaa näytetään maksimissaan !tv elokuvat -komennolla
set ohjtied(naytetaan_elokuvia) 5

# Monenko päivän ajalta elokuvia näytetään maksimissaan
set ohjtied(naytetaan_elokuva_paivat) 2

# Montako hakutulosta näytetään maksimissaan
set ohjtied(naytetaan_hakuja) 6

# mitkä kanavat näytetään jos kysytään pelkästään "tv" komennolla (ei ohjelmia)
# Ks. vaihtoehdot alla olevasta "kanavien nimet" -optiosta
# Järjestys vaikuttaa eli tulostuu antamassasi järjestyksessä
set ohjtied(default_kanavat) "yle1 yle2 mtv3 nelonen"

# Näytetäänkö kanavien nimet boldina (vahvistettuna)
set ohjtied(kanavanimet_boldina) 1

# Näytetäänkö kellonajat boldina (vahvistettuna)
set ohjtied(ajat_boldina) 1

# Timeout otettaessa yhteyttä telkku.comiin
# defaultti = 5000 = 5sek
# kasvata tätä tarvittaessa
set ohjtied(timeout) 5000

# Logataanko MSG-kutsut
set ohjtied(log_msg) 1

# Floodiraja. Esim. 10:60 tarkoittaa, että 60 sekunnin sisällä saa tehdä maksimissaan 10
# kyselyä. 0:0 tarkoittaa, että floodisuoja ei ole käytössä
set ohjtied(flood) 10:60

# Jos tapahtuu floodia, laitetaanko floodaaja tilapäiseen ignoreen. (1=kyllä, 0=ei)
# Huom, jos floodaajia on enemmän kuin 1, vain viimeisin laitetaan ignoreen.
# Käytännössä se voi tarkoittaa sitä, että pahimmillaan viaton henkilö joutuu ignoreen.
# Yleisesti kuitenkin hyvä idea.
set ohjtied(ignore) 1

# Tilapäisen ignoren aika minuutteina
set ohjtied(ignore_time) 5

# Seuraavassa listauksessa on kanavien "viralliset" nimet, älä muuta niitä
set ohjtied(kanavat) { YLE1 YLE2 MTV3 NELONEN SUBTV CANAL+ CANAL+FILM1 CANAL+FILM2 CANAL+SPORT CMOREFILM TV1000 TV1000ACTION TV1000NORDIC TV1000FAMILY TV1000CLASSIC SVT1 SVT2 TV3 TV4 KANAL5 SVT24 SVTEUROPA ZTV "" ADVENTUREONE ANIMALPLANET BBCFOOD BBCPRIME BBCWORLD BLOOMBERGTELEVISION CARTOONNETWORK CNBC CNN DEUTSCHEWELLE DISCOVERYCHANNEL DISCOVERYCIVILISATION DISCOVERYSCIENCE DISCOVERYTRAVEL DISNEYCHANNEL "" EUROSPORT EUROSPORT2 EXTREMESPORTS HALLMARKCHANNEL JETIX MTVFINLAND MTV3+ NATIONALGEOGRAPHIC NELONENPLUS MUSICCHOICE NICKELODEON "" "" SKYNEWS STAR TCM TRAVELCHANNEL TVFINLAND TOONDISNEY URHEILUKANAVA VH1 VH1CLASSIC YLE24 YLETEEMA YLEFST CANAL+FILM3 CMOREFILM2 CMOREHD }

# Tässä listauksessa on kanavien "aliakset", eli toiset kutsumanimet kanaville riveittäin.
# Esim: 'TV1 YLE1' tarkoittaa, että !tv tv1 näyttää kanavan "YLE1" ohjelmat.
# Laita aliakset omille riveillensä ja kirjoita ne isolla
# Tähti tarkoittaa mitä tahansa merkkejä
set ohjtied(aliakset) {
 	TV1 YLE1
	TV2 YLE2
	SUB* SUBTV
}

# Kanavien nimet siinä muodossa, missä botti ne sanoo kanavalle.
# Nimiä voi vapaasti muuttaa, mutta älä koske järjestykseen
set ohjtied(kanavanimet) {"YLE1" "YLE2" "MTV3" "Nelonen" "Subtv" "CANAL+" "CANAL+ FILM1" "CANAL+ FILM2" "CANAL+ SPORT" "C MORE FILM" "TV1000" "TV1000 Action" "TV1000 Nordic" "TV1000 Family" "TV1000 Classic" "SVT 1" "SVT 2" "TV3" "TV4" "Kanal5" "SVT24" "SVT Europa" "ZTV" "" "Adventure One" "Animal Planet" "BBC Food" "BBC Prime" "BBC World" "Bloomberg Television" "Cartoon Network" "CNBC" "CNN" "Deutsche Welle" "Discovery Channel" "Discovery Civilisation" "Discovery Science" "Discovery Travel & Living" "Disney Channel" "" "Eurosport" "Eurosport 2" "Extreme Sports" "Hallmark Channel" "Jetix" "MTV Finland" "MTV3+" "National Geographic" "Nelonen Plus" "Music Choice" "Nickelodeon" "" "" "Sky News" "Star" "TCM" "Travel Channel" "TV Finland" "Toon Disney" "Urheilukanava" "VH1" "VH1 Classic" "YLE24" "YLE Teema" "YLE FST" "CANAL+ FILM3" "C MORE FILM2" "C MORE HD"}

# Bindit
# Vakiona public haut toimii kanavalla kaikilla. Vaihda - tilalle +f (friend),
# jos haluat käskyn toimivan vain friendeillä

bind pub - !tv ohjtied:pub
bind msg - !tv ohjtied:msg

#######################################################################
#
# Älä muuta mitään tästä eteenpäin
#
#######################################################################

# Debug-moodi, katso botin partyline
set ohjtied(debug) 0

package require http

proc ohjtied:msg {nick uhost hand query} {
	global ohjtied

	if $ohjtied(log_msg) {putlog "$nick ($uhost) tv $query"}

	# Voidaanko vastata. Oletuksena ei voida
	set ok 0

	# jos ei vaadita kanavalle, niin hyväksytään automaattisesti
	if { $ohjtied(vaaditaanko_kanavalle) == 0 } {
		set ok 1
	# Kaikki kanavat kelpaavat
	} elseif { [llength $ohjtied(sallitut_kanavat)] == 0 } {
		# Jos ei ole määritelty erikseen tutkitaan onko kyselijä samalla kanavalla kuin botti
		foreach kanava [channels] {
			if {[onchan $nick "$kanava"]} {set ok 1}
		}
	} else {
		# katsotaan sallittujen kanavien perusteella
		foreach idx $ohjtied(sallitut_kanavat) {
			if {[onchan $nick "$idx"]} {set ok 1}
		}
	}

	if $ok {
		# Flooditarkistus
		if {[ohjtied:is_flooding uhost]} {
			putlog "Ohjtied flooding, $uhost"
			return 0
		}
		if $ohjtied(debug) {putlog "ohjtied:msg ok"}
		set data [split [ohjtied:hae_ohjelmatiedot $query] "\n"]
		foreach x $data {
			putserv [encoding convertfrom identity "PRIVMSG $nick :$x"]
		}
	}
}


proc ohjtied:pub {nick uhost hand chan query} {
	global ohjtied
	
	# poistutaan jos kanava on kiellettyjen listalla
	if { ([lsearch -exact $ohjtied(kielletyt_kanavat) [string tolower $chan]] != -1) } {
		putlog "Koitettiin ajaa ohjtied-skriptiä $chan -kanavalla, joka on kiellettyjen listalla"
		return 0
	}

	# jatketaan jos kysely on tullut sallitulla kanavalla tai
	# sallitut_kanavat_ohjtied parametri on tyhjä
	# (kaikki kanavat sallittu)
	if { ([lsearch -exact $ohjtied(sallitut_kanavat) [string tolower $chan]] == -1) && ([llength $ohjtied(sallitut_kanavat)] != 0) } {
		putlog "Koitettiin ajaa ohjtied-skriptiä $chan -kanavalla, joka ei ole sallittujen listalla"
		return 0
	}

	# Flooditarkistus
	if {[ohjtied:is_flooding uhost]} {
		putlog "Ohjtied flooding, $uhost"
		return 0
	}

	if $ohjtied(debug) {putlog "ohjtied:pub ok"}
	set data [split [ohjtied:hae_ohjelmatiedot $query] "\n"]
	foreach x $data {
		putserv [encoding convertfrom identity "PRIVMSG $chan :$x"]
	}
}

# Poimii querystä maininnan ajanilmauksesta (alkaen jotain), ja
# palauttaa timestampin, jonka voi lisätä parse_daten antamaan lukuun
# Aika voidaan ilmaista myös hh:mm -muodossa (ilman 'alkaen'-tekstiä)
proc ohjtied:parse_time { query } {
	global ohjtied

	if $ohjtied(debug) {putlog "parse_time"}

	set index [lsearch -regexp $query {[0-2][0-9]:[0-5][0-9]}]
	if { $index != -1 } {
		set time [lindex $query $index]
		set query [lreplace $query $index $index]
		scan $time "%d:%d" hours minutes
		set hours [string trimleft $hours 0]
		if { $hours == "" } { set hours 0 }
		set minutes [string trimleft $minutes 0]
		if { $minutes == "" } { set minutes 0 }
		
		return [list [expr ($hours * 60 + $minutes) * 60] $query]
	}
	
	set index [lsearch -exact $query "alkaen"]
	if { $index != -1 } {
		set time [lindex $query [expr $index +1]]
		if { $time < 0 || $time > 24 } {
			return [list -1 $query]
		}

		set query [lreplace $query $index [expr $index + 1]]
		return [list [expr $time * 60 * 60] $query]
	} else {
		return [list -1 $query]
	}
}

# Parsii aliakset
proc ohjtied:parse_aliases { query } {
	global ohjtied
	
	set tmpquery [string toupper $query]

	if $ohjtied(debug) {putlog "ohjtied:parse_aliases"}
	
	# Korvataan aliakset oikeilla nimillä
	foreach {alias realname} $ohjtied(aliakset) {
		if $ohjtied(debug) {putlog "Etsitään aliasta $alias ja korvataan se $realname:lla"}
		set id [lsearch $tmpquery $alias]
		if { $id >= 0 } {
			set query [lreplace $query $id $id $realname]
		}
	}
	return $query
}

# Poimii querystä maininnan ajanilmauksesta (pvm), ja palauttaa timestampin
proc ohjtied:parse_date { query } {
	global ohjtied

	set date [expr [clock seconds]]
	set today [clock format $date -format "%u"]

	if $ohjtied(debug) {putlog "check x0"}

	array set keywords {
		huomenn -1
		ylihuom -2
		maanant 1
		tiistai 2
		keskivi 3
		torstai 4
		perjant 5
		lauanta 6
		sunnunt 7
	}

	foreach tmp $query {
		foreach {keyword num} [array get keywords] {
			if {$num < 0} {set num [expr 0 - $num] } else { set num [expr $num - $today] }
			if { [string compare -nocase -length 7 $keyword $tmp] == 0 } {
				if {$num < 0} { set num [expr $num + 7] }
				
				set index [lsearch -exact $query $tmp]
				set query [lreplace $query $index $index]

				# Haluttu päivä muodossa YYYY-MM-DD, joka muutetaan takaisin timestampiksi (päästään eroon kellonajasta)
				set tmp [clock format [clock scan "$num days" -base $date] -format "%Y-%m-%d"]
				if $ohjtied(debug) {putlog "Pvm: $tmp ($num days + $date)"}
				return [list [clock scan "$tmp 00:00"] $query]
			}
		}
	}
	return [list 0 $query]
}

proc ohjtied:fetch { url } {
	global ohjtied
	if $ohjtied(debug) {putlog "Haetaan $url"}
	if { $ohjtied(use_proxy) == 1 }	{
		set token [http::config -useragent "Mozilla" -proxyhost $ohjtied(proxy) -proxyport $ohjtied(proxyport)]
	} else {
		set token [http::config -useragent "Mozilla"]
	}

	set token [http::geturl $url -timeout $ohjtied(timeout)]
	set tila [http::status $token]
	if { $tila == "timeout" } {
		return ""
	}
	return [http::data $token]
}


proc ohjtied:parse_channels { data channels datebase starting maxprogs type } {
	global ohjtied
	if $ohjtied(debug) {putlog "parse_channel, $channels"}

	array set counts {}
	array set datas {}
	foreach chanid $channels {
		set counts($chanid) 0
		set datas($chanid) ""
	}
	set cells [regexp -line -all -inline "^<tr><td\[^>\]*ohjelmataulu_solu.*\$" $data]
	for {set i 0} {$i < [llength $cells]} {incr i} {
		set last -1
		set cells2 ""
		while 1 {
			set new [string first "ohjelmataulu_solu" [lindex $cells $i] [expr $last + 1]]
			if {$last != -1 && $new >= 0} {lappend cells2 [string range [lindex $cells $i] $last $new]; if $ohjtied(debug) {putlog [string range [lindex $cells $i] $last $new]}}
#			lappend cells2 [string range [lindex $cells $i] $last $new]
			if {$new < 0} break
			set last $new
		}
		if $ohjtied(debug) { putlog "loppu"}
#		if $ohjtied(debug) {putlog "Luotiin cells2: $cells2"}
#		putlog [lindex $cells $i]
		lappend cells2 [string range [lindex $cells $i] $last end]
#		set cells2 [regexp -all -inline "<table.*?</table>" [lindex $cells $i]]

		foreach chanid $channels {
			if $ohjtied(debug) {putlog "Käsitellään kanavaa $chanid"}
			if {$counts($chanid) >= $maxprogs} {
				if $ohjtied(debug) {putlog "Skipataan kanava $chanid"}
				break
			}
#			if $ohjtied(debug) {putlog [lindex $cells2 4]}
			set rows [regexp -all -inline "<tr>.*?</tr>" [lindex $cells2 $chanid]]
			if {$rows == ""} continue
			foreach prog $rows {
				if $ohjtied(debug) {putlog "Prog: $prog"}
				if {$counts($chanid) >= $maxprogs} {
					if $ohjtied(debug) {putlog "Skipataan ohjelmat kanavalta $chanid"}
					break
				}
				regexp "'tiedot\\?oid=(\\d*)'" $prog nothing telkkuid
				if $ohjtied(debug) {putlog "Telkkuid: $telkkuid"}
				regsub -all "<\[^<>\]*>" $prog "" prog
				regexp "(\\d*):(\\d*)&nbsp;(.*)$" $prog nothing time_h time_m name
				set time_h2 $time_h
				set time_m2 $time_m
				
				set time_h2 [string trimleft $time_h2 "0"]
				if {$time_h2 == ""} {set time_h2 0}
				if {$time_h2 < 4} {set time_h2 [expr $time_h2 + 24]}
				
				set time_m2 [string trimleft $time_m2 "0"]
				if {$time_m2 == ""} {set time_m2 0}
				
				if {[expr $datebase + $time_h2 * 60 * 60 + $time_m2 * 60] < $starting} {
					if $ohjtied(debug) {putlog "Ignored: $chanid $time_h:$time_m: $name"}
					set tmp [expr $datebase + $time_h2 * 60 * 60 + $time_m2 * 60]
					if $ohjtied(debug) {putlog "$starting > $tmp"}
				} else {
					if { $type == "ohj" } {
						return $telkkuid;
					}
					incr counts($chanid)
					set c $counts($chanid)
					set tmp $datas($chanid)
					if {$datas($chanid) != "" } {set tmp "$tmp | "}
					if $ohjtied(ajat_boldina) {
						set datas($chanid) "$tmp\002$time_h:$time_m\002 $name"
					} else {
						set datas($chanid) "$tmp$time_h:$time_m: $name"
					}
					if $ohjtied(debug) {putlog "Added: $chanid $time_h:$time_m: $name"}
				}
			}
		}
	}
	return [array get datas]
}

# Parsitaan tiedot-sivulta ohjelman nimi ja kuvaus
proc ohjtied:parse_ohj { data } {
	global ohjtied
	if $ohjtied(debug) {putlog "parse_ohj"}
	
	regexp {^.*?<span class="perus"><b>(.*?)</b>(.*)$} $data nothing name_a data
	regexp {^.*?(?:&nbsp;)+(.*?)<br />(.*)$} $data nothing name_b data
	regexp {<br />\s*<img [^\n]*?\n(.*?)</td></tr>} $data nothing desc
	regsub -all "<\[^<>\]*>" "$name_a $name_b | $desc" "" data
	regsub -all {\s+} $data " " data
	return $data
}

# Parsitaan hakusivulta tietoja
proc ohjtied:parse_hae { data } {
	global ohjtied
	if $ohjtied(debug) {putlog "parse_hae"}
	
	set notfound [string first {Hakusi ei tuottanut tuloksia.} $data]
	if { $notfound >= 0 } {
		return "Hakusi ei tuottanut tuloksia."
	}

	set count 0
	set days [regexp -all -indices -inline {<span class="otsikko_uusi">.*?</span>} $data]
	set last [lindex [lindex $days 0] 0]

	set final {}
	
	for {set i 1} {$i <= [llength $days]} {incr i} {
		if { $i == [llength $days] } {
			set progs [string range $data $last end]
		} else {
			set new [lindex [lindex $days $i] 0]
			set progs [string range $data $last [expr $new - 1]]
			set last $new
		}
		regexp {<span class="otsikko_uusi">(.*?)</span>} $progs nothing date

		if { $i > 1 } {
			set final "$final| "
		}
		if { $ohjtied(ajat_boldina) } {
			set final "$final\002$date\002:"
		} else {
			set final "$final$date:"
		}

		set proglist [regexp -all -inline {<b>(.*?)</b>\s*(.*?)<br />} $progs]
		for {set x 0} {$x < [llength $proglist]} {incr x 3} {
			set ohjelma [lindex $proglist [expr $x + 1]]
			set aika [lindex $proglist [expr $x + 2]]
			if {$x == 0} {
				set final "$final $ohjelma $aika "
			} else {
				set final "$final| $ohjelma $aika "
			}
			incr count
			if { $count >= $ohjtied(naytetaan_hakuja) } {
				break
			}
		}
		
		if { $count >= $ohjtied(naytetaan_hakuja) } {
			break
		}
	}
	return $final
}

# Parsitaan elokuva-sivulta oleellinen data
proc ohjtied:parse_elokuvat { data timestamp } {
	global ohjtied

	if $ohjtied(debug) {putlog "parse_elokuvat"}
	
	# data jaetaan päiväkohtaisesti days-listaan.
	set days [list]
	set first 1
	for {set place [string first "paksuperus" $data]} {$place > -1} {set place [string first "paksuperus" $data [expr $place+1]]} {
		if {$first == 1} { set last $place; set first 0; continue; }
		if $ohjtied(debug) {putlog "$last-$place"}
		lappend days [string range $data $last $place]
		set last $place
	}
	if {$first == 1} {return "Elokuvia ei löytynyt (1)"}
	
	lappend days [string range $data $last end]

	# Montako ohjelmaa pitää vielä bongata
	set total $ohjtied(naytetaan_elokuvia)
	
	# Palautus
	set tulostus ""

	set day_limit $ohjtied(naytetaan_elokuva_paivat)
	
	# Aika, joita vanhempia leffoja ei näytetä
	if {$timestamp == 0} {set timestamp [expr [clock seconds] - 7200]} else {set day_limit 1}
	set timelimit [clock format $timestamp -format %Y%m%d%H%M]

	#
	set last_inited_date ""
	
	set days_count 0

	# Mennään jokainen päivä läpi
	foreach x $days	{
		# Poimitaan kohta päivämäärästä
		
		regexp -indices "<b>(\[^<\]*)</b>" $x tmp pos

		# Otetaan itse päivämäärä talteen..
		set date [string range $x [lindex $pos 0] [lindex $pos 1]]

		# datenum on date muutettuna muotoon YYYYMMDD
		regexp "(\\d\\d)\\.(\\d\\d)\\.(\\d\\d\\d\\d)" $date nothing day month year
		set datenum "$year$month$day"

		# .. ja poistetaan se käsiteltävästä datasta
		set x [string range $x [expr [lindex $pos 1] + 1] end]

		# 1: ohjelma, 2: klo, 3: kanavan id
#		set reg "<b>(?:\\s|\\n)*(\[^<\\r\\n\]*)(?:\\s|\\r|\\n)*</b><br>(?:\\s|\\n|\\r)*(\[^<\]*).*?kanavalogo(\[0-9\]+)\.gif"
		set reg "<b>(?:\\s|\\n)*(\[^<\\r\\n\]*)(?:\\s|\\r|\\n)*</b><br>(?:\\s|\\n|\\r)*(\[^<\]*)\[^\\n\]*\\n\[^\\n\]*\\n\[^\\n\]*\\n\[^\\n\]*kanavalogo(\[0-9\]+)\.gif"

		# Ohjelmalista
		set showlist [regexp -all -inline -expanded $reg $x]

		if $ohjtied(debug) {putlog [lindex $showlist 0]}
		
		# Kuinka monta eri ohjelmaa
		set showcount [expr [llength $showlist] / 4]

		if $ohjtied(debug) {putlog "Löytyi $showcount elokuvaa"}
		
		# Mennään jokainen ohjelma läpi ja tehdään niistä lopullista tulostusta varten lista
		for {set i 0} {$i<$showcount} {incr i} {
			
			if $ohjtied(debug) {putlog "Käsitellään kohtaa $i"}

			if $ohjtied(debug) {
				set tmpvar [lindex $showlist [expr 4*$i+3]]
				putlog "Kanavaid: $tmpvar"
			}
			set kanava [lindex $ohjtied(kanavanimet) [lindex $showlist [expr 4*$i+3]]]
			set klo [lindex $showlist [expr 4*$i+2]]
			set ohjelma [lindex $showlist [expr 4*$i+1]]

			if $ohjtied(debug) {putlog "$kanava, $klo, $ohjelma"}
			
			# Eihän vaan ole menneisyydessä?
			regexp "(\\d\\d):(\\d\\d)" $klo nothing hour minute
			set klonum "$datenum$hour$minute"

			# Klo 00:00 -> 03:59 on varmaankin seuraavan päivän puolella!
			if {$hour < 4} {
				set klonum [clock format [clock scan "1 day" -base [clock scan "$year-$month-$day $hour:$minute"]] -format %Y%m%d%H%M]
			}
			
			if {$klonum < $timelimit} {
				if $ohjtied(debug) {putlog "Ohitettiin ohjelma (menneisyydessä, $klonum < $timelimit)"}
				continue;
			}

			if {$last_inited_date != $datenum} {
				incr days_count
				set last_inited_date $datenum
				
				if {$tulostus != ""} { set tulostus "$tulostus\n" }
				set tulostus "$tulostus$date - "
			}
			
			if $ohjtied(kanavanimet_boldina) {
				set tulostus "$tulostus\002$kanava\002"
			} else {
				set tulostus "$tulostus$kanava"
			}

			set tulostus "$tulostus $klo: $ohjelma"
			incr total -1
			if {$total <= 0} {return $tulostus } else { set tulostus "$tulostus | " }
		}
		if {$days_count >= $day_limit} { break }
	}
	return $tulostus
}

# proc hae_ohjelmatiedot
proc ohjtied:hae_ohjelmatiedot { query } {
	global ohjtied

	# tv tai ohj
	set type "tv"

	# Korvaa kaikista aliakset oikeiksi
	set query [ohjtied:parse_aliases $query]

	set tmp [ohjtied:parse_date $query]
	set date [lindex $tmp 0]
	set query [lindex $tmp 1]

	set tmp [ohjtied:parse_time $query]
	set time [lindex $tmp 0]
	set query [lindex $tmp 1]

	if {$date == 0} {
		set tmp [clock format [clock seconds] -format "%Y-%m-%d"]
	} else {
		set tmp [clock format $date -format "%Y-%m-%d"]
	}
	set datetime [expr [clock scan $tmp] + $time]

	if $ohjtied(debug) {putlog "Date: $datetime [expr [clock seconds] - 3 * 60 * 60]"}
	
	if { $time == -1 } {
		set datetime [expr $datetime + 1]
		set urldatestr [clock format $datetime -format "%Y%m%d"]
		set urldate [clock scan $urldatestr]
	# Ollaan ilmeisesti haettu esim tänään esim 06:00 alkavia ohjelmia,
	# mutta kello on jo yli kuuden. Haetaan siis huomisia klo 06:00 alkavia
	# Sallitaan muutaman tunnin vanhojen ohjelmien haku kuitenkin
	} elseif { $datetime < [expr [clock seconds] - 3 * 60 * 60] } {
		set datetime [expr $datetime + 24 * 60 * 60]
	
		# Url on muotoa http://www.telkku.com/telkku?p=YYYYMMDD&ks=PAGE
		# Tosin esim. klo 02:00 haetaan eilisen ohjelmista
		set urldate [expr $datetime - 4 * 60 * 60]
		set urldatestr [clock format $urldate -format "%Y%m%d"]
		set urldate [clock scan $urldatestr]
	} else {
		set urldate [expr $datetime - 4 * 60 * 60]
		set urldatestr [clock format $urldate -format "%Y%m%d"]
		set urldate [clock scan $urldatestr]
	}
	
	if $ohjtied(debug) {putlog "Date: [clock format $datetime -format {%d.%m.%Y %H:%M}]"}
	
	# Parsitaan
	foreach tmp $query {
		if { [string compare -nocase $tmp "elokuvat"] == 0 } {
			set index [lsearch -exact $query "elokuvat"]
			set query [lreplace $query $index $index]
			set data [ohjtied:fetch "http://www.telkku.com/telkku?tila=elokuvat"]
			if {$data == ""} { return "Ei saatu yhteyttä www.telkku.com-palvelimeen" }
			
			if {$date != 0} {
				return [ohjtied:parse_elokuvat $data $datetime]
			} else {
				return [ohjtied:parse_elokuvat $data 0]
			}
		}
		if { [string compare -nocase $tmp "hae"] == 0 }	{
			set index [lsearch -exact $query "hae"]
			set query [lreplace $query $index $index]
			
			set kuvauksista [lsearch -exact $query "kuvauksista"]
			if { $kuvauksista >= 0 } {
				set query [lreplace $query $kuvauksista $kuvauksista]
				set kuvauksista "1"
			} else {
				set kuvauksista "0"
			}
			
			set kaikki_kanavat [lsearch -exact $query "kaikki_kanavat"]
			if { $kaikki_kanavat >= 0 } {
				set query [lreplace $query $kaikki_kanavat $kaikki_kanavat]
				set kaikki_kanavat "1"
			} else {
				set kaikki_kanavat "0"
			}

			# Urlencode
			binary scan $query H* tmp
			regsub -all .. $tmp {%\0} tmp 
			set query [string toupper $tmp]
			set data [ohjtied:fetch "http://www.telkku.com/telkku?tila=hakutulokset&hakusana=$query&haetaanLisatiedoista=$kuvauksista&kaikkiKanavat=$kaikki_kanavat"]
			return [ohjtied:parse_hae $data]
		}
		# Haetaan vain yhden ohjelmat tiedot kerrallaan
		if { ([string compare -nocase $tmp "ohj"] == 0) && ([llength $query] == 2) } {
			set index [lsearch -exact $query "ohj"]
			set query [lreplace $query $index $index]
			set type "ohj"
		} elseif { [string compare -nocase $tmp "ohj"] == 0 } {
			if $ohjtied(debug) {putlog $query}
		}
	}
	# Riveittäin kanavaryhmiä, jotka muodostuvat kanavien id-numeroista
	set kanavaryhmat {
		{0 1 2 3 4} 
		{62 63 64 46 48} 
		{40 41 42 59} 
		{5 6 7 65} 
		{8 9 66 67} 
		{10 11 12 13 14} 
		{34 25 47 56} 
		{35 36 37} 
		{30 38 44 50 58} 
		{45 49 60 61} 
		{28 29 31 32 53} 
		{24 26 27 54} 
		{33 43 55 57} 
		{15 16 17 18} 
		{19 20 21 22}
	}

	# Lista kanavista, joita kysytään (lista, jossa on kanavien ID:t)
	set channel_ids ""
	set channel_count 0

	foreach channellist [list $query $ohjtied(default_kanavat)] {
		if $ohjtied(debug) {putlog "Listana toimii: $channellist"}
		# Laitetaan ylös haluttavat kanavat
		foreach channel $channellist {
			set channel [string toupper $channel]
			set idx [lsearch -exact $ohjtied(kanavat) $channel]
			if {$idx >= 0 && $ohjtied(naytetaan_kanavia) > $channel_count} {
				lappend channel_ids $idx
				incr channel_count
			}
		}
		
		if {$channel_ids != ""} {break}
	}
	if $ohjtied(debug) {putlog "Kanavat: $channel_ids"}

	set pageid 0

	set final ""
	# Selvitetään, mitkä sivut (ja mitkä kanavat niiltä sivuilta) täytyy hakea
	foreach page $kanavaryhmat {
		set page_channels ""
		# chanid == monesko kanava listauksessa
		set chanid 0
		foreach channel $page {
			if {[lsearch -exact $channel_ids $channel] != -1} {
				lappend page_channels $chanid
			}
			incr chanid
		}
		if $ohjtied(debug) {putlog "page_channels: $page_channels"}
		if {$page_channels != ""} {
			set data [ohjtied:fetch "http://www.telkku.com/telkku?p=$urldatestr&ks=$pageid"]
			if {$data == ""} { return "Ei saatu yhteyttä www.telkku.com-palvelimeen" }

			if $ohjtied(debug) {putlog "Data haettiin"}
			
			set tmp [ohjtied:parse_channels $data $page_channels $urldate $datetime $ohjtied(naytetaan_ohjelmia) $type]
			if { $type == "ohj" } {
				set data [ohjtied:fetch "http://www.telkku.com/tiedot?oid=$tmp"]
				set kanava [lindex $ohjtied(kanavanimet) [lindex $page $page_channels]]
				set txt [ohjtied:parse_ohj $data]
				if $ohjtied(kanavanimet_boldina) {
					set final "$final\002$kanava\002: $txt\n"
				} else {
					set final "final$kanava: $txt\n"
				}
			} else {
				if $ohjtied(debug) {putlog "parse_channels palautti $tmp"}
				foreach {chanid chandata} $tmp {
					if $ohjtied(debug) {putlog $chandata}
			
					if $ohjtied(debug) {putlog "Ohjelma $chanid"}
					set kanava [lindex $ohjtied(kanavanimet) [lindex $page $chanid]]
					if $ohjtied(kanavanimet_boldina) {
						set final "$final\002$kanava\002: $chandata\n"
					} else {
						set final "$final$kanava: $chandata\n"
					}
				}
			}
		}
		incr pageid
	}
	return $final	
}

proc ohjtied:is_flooding { identhost } {
	global ohjtied
	
	# Uusi/vanhin paikka
	set newindex [expr $ohjtied(flood,index) + 1]
	if {$newindex >= $ohjtied(flood,num)} { set newindex 0 }

	# Tarkistetaan, onko kaukaisin floodievent liian lähellä
	if {[expr [clock seconds] - $ohjtied(flood,events,$newindex)] < $ohjtied(flood,time)} {
		# Laitetaan ignoreen
		if {$ohjtied(ignore)} {
			newignore [maskhost [string trimleft $identhost ~]] Ohjtied-skripti flood $ohjtied(ignore_time)
		}
		return 1
	}
	
	# Lisätään nykyinen event uuteen paikkaan
	set $ohjtied(flood,events,$newindex) [clock seconds]
	set $ohjtied(flood,index) $newindex

	return 0
}

proc ohjtied:ohjtied { } {
	global ohjtied
	
	# Initoidaan flood
	set ohjtied(flood,num) [lindex [split $ohjtied(flood) :] 0]
	set ohjtied(flood,time) [lindex [split $ohjtied(flood) :] 1]
	
	for {set i 0} {$i<$ohjtied(flood,num)} {incr i} {
		set ohjtied(flood,events,$i) 0
	}
	set ohjtied(flood,index) 0

	putlog "\002Ohjelmatiedot $ohjtied(versio)\002 - bot.gospelnet.fi/?ohjtied loaded"
}

ohjtied:ohjtied