#!/usr/bin/tclsh

##############################################################################
#                                                                            #
# hae_saatiedot.tcl                                                          #
# v0.4 joep@fury.fi 18.11.2002                                               #
# http://www.fury.fi/~joep/eggdrop-scripts.php                               #
#                                                                            #
# K�yt� ja muuta vapaasti mutta s�ilyt� tiedot tekij�st�                     #
#                                                                            #
# Skripta hakee osoitteesta http://www.tieh.fi/alk/frames/tiesaa-frame.html  #
# 20 eri framea (eri maakuntien tietoja), 30 minuutin v�lein, ja tallettaa   #
# ne tiedostoon eggdrop-scriptaa varten.                                     #
#                                                                            #
# K�ytt� :                                                                   #
#                                                                            #
# 1. varmista ett� tclsh on /usr/bin/ hakemistossa, tai muuta t�m�n          #
#    tiedoston ensimm�ist� rivi� siten ett� polku on oikein.                 #
#    Voit katsoa sijainnin komennolla                                        #
#       which tclsh                                                          #
#                                                                            #
# 2. talleta t�m� skripta esim. samaan hakemistoon eggdropin kanssa ja       #
#    varmista ett� t�ll� tiedostolla on ajo-oikeudet                         #
#    (chmod u+x hae_saatiedot.tcl)                                           #
#                                                                            #
# 3. tee k�ytt�j�kohtainen crontab-tiedosto (tai lis�� nykyiseen)            #
#    seuraava rivi (muista asettaa polku) :                                  #
#                                                                            #
#   0,30 * * * *   /polku/hae_saatiedot.tcl >/dev/null 2>&1                  #
#                                                                            #
# 4. k�ynnist� crontab :                                                     #
#    crontab <crontab-tiedosto>                                              #
#                                                                            #
# 5. configuroi ja aseta eggdrop:iin toimintaan saa.tcl                      #
#                                                                            #
# Taustaa :                                                                  #
# Tiedot haetaan valmiiksi erillisell� skriptalla syyst� ett� t�ll�          #
# tavoin eggdropin ei itse tarvitse hakea mit��n, ja kuormitus v�henee.      #
#                                                                            #
##############################################################################

# Polku ja tiedosto mihin tiedot talletetaan
# T�m� polku tulee my�s itse saa.tcl tiedoston konfiguraatioon
#
set savefilename "/home/rolle/eggdrop/scripts/saa.data"

# WWW proxy
# 1 = kyll�
# 0 = ei
set use_proxy 0

# WWW proxy osoite ja portti (jos ed. optio 1)
set proxy "cache.inet.fi"
set proxyport 800

##############################################################################
#                                                                            #
# �l� muuta mit��n t�st� eteenp�in jos et ymm�rr�                            #
#                                                                            #
##############################################################################


  # avataan save-tiedosto
  set savefile [open $savefilename w 0600]

  # haetaan 22 framea osoitteista 
  # http://www.tieh.fi/alk/tiesaa/tiesaa_maak_1.html -
  # http://www.tieh.fi/alk/tiesaa/tiesaa_maak_22.html
  # ja talletetaan kaikki samaan tiedostoon
  #

for { set i 1 } { $i < 23 } { incr i 1 } {

	if { $use_proxy == 1 } {
			set port $proxyport
			set site $proxy
			set url "http://www.tieh.fi/alk/tiesaa/tiesaa_maak_$i.html"
		} else {
			set site "www.tieh.fi"
			set port 80
			set url "/alk/tiesaa/tiesaa_maak_$i.html"
		}

    puts $i
    set sock [socket $site $port]
    puts $sock "GET $url HTTP/1.1"
    puts $sock "connection: close"
    puts $sock "host: $site\n"
    flush $sock
    set sivu [read $sock]
    close $sock
    set sivu [split $sivu \n]

    foreach idx $sivu {
      puts $savefile $idx
      }

    }

  close $savefile
