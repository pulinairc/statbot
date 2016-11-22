# Välimatkat v1.3.2
# matka.tcl http://fury.fi/~joep/eggdrop-scripts.php
# Ilmoittaa kaupunkien välimatkan sekä (optiona) matkan kestoajan.
#
# Muokannut mm. [tonttu ät gospelnet piste äf ii]
# Uusin versio: http://bot.gospelnet.fi/?matka
#
# Käyttö : !matka <kaupunki 1> <kaupunki 2> <nopeus>
#          /msg botnick matka <kaupunki 1> <kaupunki 2> <nopeus>
#
# Esimerkkejä : !matka espoo helsinki
#               !matka tampere oulu 230 
#
# Lukema 230 (ei pakollinen) on keskinopeus km/h, jolloin skripta palauttaa
# myös matkan kestoajan.
#
# Haku tehdään osoitteesta http://www.tieh.fi/valim2.htm
#
# Feel free to use & modify, but please keep the info about
# original author
#
#   joep@fury.fi
#
#############################################################################

# Konfiguroi seuraavat :

# Kanavat, joilla botin sallitaan tai ei sallita matkatietoja näyttävän
# Tähän siis vain kanavia joilla botti itse on!
#
# Jätä sallitut_kanavat_matka tyhjäksi jos haluat että toimii automaattisesti
# kaikilla kanavilla joilla botti on (oletuksena näin).
#
# Jos kanavan nimessä on skandeja niin jätä sallitut_kanavat_matka tyhjäksi,
# skandit voivat aiheuttaa ongelmia ja tällä voi kiertää moisen ongelman.
#
# Esimerkki1: sallitaan vain kanavat #pastilli ja #peelotus
# set sallitut_kanavat_matka { pastilli peelotus }
# set kielletyt_kanavat_matka { }
#
# Esimerkki2: sallitaan kaikki paitsi #palle ja #tumplaus
# set sallitut_kanavat_matka { }
# set kielletyt_kanavat_matka{ palle tumplaus }
#
# Vakio-optioilla (molemmat tyhjiä) on sallittu kaikki kanavat.
# Optio kielletyt_kanavat_matka ei vaikuta msg-kyselyihin.
#
set sallitut_kanavat_matka { }
set kielletyt_kanavat_matka { }

# vaaditaanko että kysyjä on sallituilla kanavilla (ks lista yllä) että
# toimii messagella
# 1 = vaaditaan
# 0 = ei vaadita (kaikki IRCissä olijat voivat kysellä!)
set vaaditaanko_kanavalle_matka 0

# komento jolla skripta aktivoituu
set matka_command "matka"

# Ilmoitustyyppi
# 1 = botti kertoo NOTICE:na
# 0 = botti kertoo "normaali" kommenttina (PRIVMSG)
set botti_ilmtyyppi_matka 0

# Ilmoitetaanko public haun jälkeen mahdollisuus käyttää messagea
# 1 = ilmoitetaan
# 0 = ei ilmoiteta
set ilmoitetaanko_public_matka 0

# Bindit
# Vakiona toimii public kysely (kanavalla) jos userilla +f (friend) lippu.
# Jos haluat että kaikilla toimii publiccina, laita pelkkä - (ks. msg-rivit mallia).
#
bind pub - !$matka_command pub_matka
bind msg - $matka_command msg_matka
bind msg - !$matka_command msg_matka

############################################################################
#                                                                          #
# Älä muuta mitään tästä eteenpäin                                         #
#                                                                          #
############################################################################

proc msg_matka {nick uhost hand lause} {
	global floodi sallitut_kanavat_matka vaaditaanko_kanavalle_matka
	global botti_ilmtyyppi_matka
	putlog [encoding convertfrom identity "$nick $uhost matka $lause"]
	set on_channel 0

	if { [llength $sallitut_kanavat_matka] == 0 } {
			# tutkitaan onko kyselijä samalla kanavalla kuin botti
			foreach kanava [channels] {
				if { [onchan $nick "$kanava"] } { set on_channel 1 }
				}
		} else {
			# katsotaan sallituiden kanavien perusteella
			foreach idx $sallitut_kanavat_matka {
				if { [onchan $nick "#$idx"] } { set on_channel 1 }
				}
		}

	# jos ei vaadita kanavalle niin joka tapauksessa ok
	if { $vaaditaanko_kanavalle_matka == 0 } { set on_channel 1 }

	if { $on_channel } {
		hae_matka $lause
		if { $botti_ilmtyyppi_matka == 0 } {
				putserv [encoding convertfrom identity "PRIVMSG $nick :$floodi"]
			} else {
				putserv [encoding convertfrom identity "NOTICE $nick :$floodi"]
			}
		}
}

proc pub_matka {nick uhost hand chan lause} {
	global floodi botnick sallitut_kanavat_matka kielletyt_kanavat_matka
	global botti_ilmtyyppi_matka ilmoitetaanko_public_matka

	# poistutaan jos kanava on kiellettyjen listalla
	if { ([lsearch -exact $kielletyt_kanavat_matka [string trimleft [string tolower $chan] "#"]] != -1) } {
		return 0
		}

	set channel [string trimleft [strlwr $chan] "#"]

	# jatketaan jos kysely on tullut sallitulla kanavalla tai
	# sallitut_kanavat_matka parametri on tyhjä
	# (kaikki kanavat sallittu)
	if { ([lsearch -exact $sallitut_kanavat_matka $channel] != -1) || ([llength $sallitut_kanavat_matka] == 0)} {
		hae_matka $lause
		if { $botti_ilmtyyppi_matka == 0 } {
				putserv [encoding convertfrom identity "PRIVMSG $chan :$floodi"]
				if { $ilmoitetaanko_public_matka == 1 } { putserv [encoding convertfrom identity "PRIVMSG $nick :Toimii myös /msg $botnick matka <kaupunki 1> <kaupunki 2>"] }
			} else {
				putserv [encoding convertfrom identity "NOTICE $chan :$floodi"]
				if { $ilmoitetaanko_public_matka == 1 } { putserv [encoding convertfrom identity "NOTICE $nick :Toimii myös /msg $botnick matka <kaupunki 1> <kaupunki 2>"] }
			}
		}
}

proc hae_matka { lause } {
global floodi

	set lause_list [split $lause " "]

	set lahto [strupr [string range [lindex $lause_list 0] 0 0]]
	append lahto [strlwr [string range [lindex $lause_list 0] 1 end]]

	set paamaara [strupr [string range [lindex $lause_list 1] 0 0]]
	append paamaara [strlwr [string range [lindex $lause_list 1] 1 end]]

	set nopeus [lindex $lause_list 2]

	if { $lahto == $paamaara } {
		set floodi "0 km, eh ?"
		return
		}

	# erikoistapauksia
	if { $lahto == "Heinola" } { append lahto " (yhdistetty)" }
	if { $paamaara == "Heinola" } { append paamaara " (yhdistetty)" }
	if { $lahto == "Porvoo" } { append lahto " (yhdistetty)" }
	if { $paamaara == "Porvoo" } { append paamaara " (yhdistetty)" }
	if { $lahto == "Lohja" } { append lahto " (yhdistetty)" }
	if { $paamaara == "Lohja" } { append paamaara " (yhdistetty)" }
	if { $lahto == "Suomussalmi" } { append lahto ", kko." }
	if { $paamaara == "Suomussalmi" } { append paamaara ", kko." }
	if { $lahto == "Utsjoki" } { append lahto ", Utsjoki" }
	if { $paamaara == "Utsjoki" } { append paamaara ", Utsjoki" }
	if { $lahto == "Värtsilä" } { append lahto " kko" }
	if { $paamaara == "Värtsilä" } { append paamaara " kko" }

	# lisää erikoistapauksia [t o n t t u ät gospelnet piste äf ii]
	array set aliases {
		"Kaaresuvanto" "Enontekiö, Kaaresuvanto"
		"Kilpisjärvi" "Enontekiö, Kilpisjärvi"
		"Kivilompolo" "Enontekiö, Kivilompolo"
		"Palojoensuu" "Enontekiö, Palojoensuu"
		"Inari" "Inari kko"
		"Ivalo" "Inari, Ivalo"
		"Näätämö" "Inari, Näätämö"
		"Raja-jooseppi" "Inari, Raja-Jooseppi"
		"Repojoki" "Inari, Repojoki"
		"Säynätsalo" "Jyväskylä, Säynätsalo"
		"Palokka" "Jyväskylän mlk, Palokka"
		"Tikkakoski" "Jyväskylän mlk, Tikkakoski"
		"Vaajakoski" "Jyväskylän mlk, Vaajakoski"
		"Kaipola" "Jämsä, Kaipola"
		"Haapamäki" "Keuruu, Haapamäki"
		"Vartius" "Kuhmo, Vartius, raja"
		"Riistavesi" "Kuopio, Riistavesi"
		"Nuijamaa" "Lappeenranta, Nuijamaa"
		"Lappi" "Lappi tl"
		"Lievestuore" "Laukaa, Lievestuore"
		"Koli" "Lieksa, Koli"
		"Otava" "Mikkeli, Otava"
		"Raippaluoto" "Mustasaari, Raippaluoto"
		"Meri-pori" "Pori, Meri-Pori"
		"Meltaus" "Rovaniemen mlk, Meltaus"
		"Pirttikoski" "Rovaniemen mlk, Pirttikoski"
		"Vuojärvi" "Sodankylä, Vuojärvi"
		"Vuotso" "Sodankylä, Vuotso"
		"Sukeva" "Sonkajärvi, Sukeva"
		"Ämmänsaari" "Suomussalmi, Ämmänsaari"
		"Tenhola" "Tammisaari, Tenhola"
		"Tuuri" "Töysä, Tuuri"
		"Karigasniemi" "Utsjoki, Karigasniemi"
		"Nuorgam" "Utsjoki, Nuorgam"
		"Kalanti" "Uusikaupunki, Kalanti"
		"Vaalimaa" "Virolahti, Vaalimaa, raja"
		"Niirala" "Värtsilä, Niirala, raja"
		"Konginkangas" "Äänekoski, Konginkangas"
	}
	foreach {written toreplace} [array get aliases] {
		if {$lahto == $written} { set lahto $toreplace }
		if {$paamaara == $written} { set paamaara $toreplace }
	}

	if { [string first "ä" $lahto] == 0 } {
		set lahtoapu "Ä"
		append lahtoapu [string range $lahto 1 end]
		set lahto $lahtoapu
		}
	if { [string first "ä" $paamaara] == 0 } {
		set paamaaraapu "Ä"
		append paamaaraapu [string range $paamaara 1 end]
		set paamaara $paamaaraapu
		}

	set haku "HTTP/1.1\n"
	append haku "Accept: */*\n"
	append haku "Referer: http://www.tiehallinto.fi\n"
	append haku "Accept-Language: fi\n"
	append haku "Content-Type: application/x-www-form-urlencoded\n"
	append haku "Accept-Encoding: gzip, deflate\n"
	append haku "User-Agent: Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)\n"
	append haku "Host: alk.tiehallinto.fi\n"
	append haku "Content-Length: 57\n"
	append haku "Proxy-Connection: Keep-Alive\n"
	append haku "Pragma: No-Cache\n\n"
	append haku "MISTÄ="
	append haku $lahto
	append haku "&MIHIN="
	append haku $paamaara
	append haku "&NOPEUS="
	if { $nopeus == "" } {
			append haku "80"
		} else {
			append haku $nopeus
		}
	append haku "\n"

	set portti 80
	set site "alk.tiehallinto.fi"
	set url "/cgi-bin/pq9.cgi"

	set sock [socket $site $portti]
	puts $sock "POST $url $haku"
	puts $sock "GET $url HTTP/1.1"
	puts $sock "connection: close"
	puts $sock "host: $site\n"
	flush $sock
	set foo [read $sock]
	close $sock

	set foo [split $foo \n]

	set valimatka 0

	foreach i $foo {
		set valistart [string first "Välimatka on" $i]
		set matkaaikastart [string first "Ajoaika on" $i]
		if { $valistart != -1 } {
			set valimatka [string range $i [expr $valistart +13] [expr [string first "km" $i] -2]]
			}
		if { $matkaaikastart != -1 } {
			set matkaaika [string range $i [expr $matkaaikastart +11] [expr [string first "min" $i] -2]]
			if { $matkaaika == "" } {
				set matkaaika "60"
				}
			}
		}

	if { $valimatka == 0 || $valimatka == 2 } {
			set floodi "Välimatka $lahto - $paamaara 0km. Virheelliset kaupunkinimet (tai ei tuettu)?"
		} else {
			if { $nopeus == "" } {
					set floodi "Välimatka $lahto - $paamaara on $valimatka km"
				} else {
					if { $nopeus > 199 } {
							set floodi "Välimatka $lahto - $paamaara on $valimatka km, ajoaika $nopeus km/h matalalentomeiningillä $matkaaika minuuttia"
						} else {
							set floodi "Välimatka $lahto - $paamaara on $valimatka km, ajoaika $nopeus km/h vauhdilla $matkaaika minuuttia"
						}
				}
		}
}

putlog [encoding convertfrom identity "Script loaded: \002Välimatkat 1.3.2\002"]
