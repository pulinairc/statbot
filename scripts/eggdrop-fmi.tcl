# eggdrop-fmi.tcl - FMI-sääscript for eggdrop IRC bot
# by Roni "rolle" Laukkarinen
# rolle @ irc.quakenet.org
# Fetches finnish weather from ilmatieteenlaitos.fi
# API querys: http://ilmatieteenlaitos.fi/tallennetut-kyselyt

# Updated when:
set versio "4.6.20160531"
#------------------------------------------------------------------------------------
package require Tcl 8.5
package require http 2.1
package require tdom

bind pub - !fmi pub:fmi
bind pub - !saa pub:fmi
bind pub - !keli pub:fmi
bind pub - !sää pub:fmi

set systemTime [clock seconds]
set starttime [expr { $systemTime - 10800 }]
set timestamp [clock format $starttime -format %Y-%m-%dT%H:%M:%S]
set fmiurl "http://data.fmi.fi/fmi-apikey/0218711b-a299-44b2-a0b0-a4efc34b6160/wfs?request=getFeature&storedquery_id=fmi::observations::weather::timevaluepair&place=jyv%C3%A4skyl%C3%A4&timezone=Europe/Helsinki"
set fmiurlhtml "http://ilmatieteenlaitos.fi/saa/Helsinki"

proc pub:fmi { nick uhost hand chan text } {

  set systemTime [clock seconds]
  set starttime [expr { $systemTime - 10800 }]
  set timestamp [clock format $starttime -format %Y-%m-%dT%H:%M:%S]

  if {[string trim $text] ne ""} {

       set text [string toupper $text 0 0]
       set fmiurl "http://data.fmi.fi/fmi-apikey/0218711b-a299-44b2-a0b0-a4efc34b6160/wfs?request=getFeature&storedquery_id=fmi::observations::weather::timevaluepair&place=$text&timezone=Europe/Helsinki"
       set fmiurlhtml "http://ilmatieteenlaitos.fi/saa/$text"

    } else {
       global fmiurl
       global fmiurlhtml
    }

set fmisivu [::http::data [::http::geturl $fmiurl]]
set fmidata [dom parse $fmisivu]
set fmi [$fmidata documentElement]

set fmisivuhtml [::http::data [::http::geturl $fmiurlhtml]]
set fmihtmlsrc [dom parse -html $fmisivuhtml]
set fmihtml [$fmihtmlsrc documentElement]

#------------------------------------------------------------------------------------
# Kaupunki:
#------------------------------------------------------------------------------------

set kaupunkihaku [$fmi selectNodes {(//target:Location[1]/gml:name[@codeSpace="http://xml.fmi.fi/namespace/locationcode/name"])[1]}]
set kaupunki [$kaupunkihaku asText]

#------------------------------------------------------------------------------------
# Lämpötila:
#------------------------------------------------------------------------------------

set lampotilahaku [$fmi selectNodes {(//om:result[1]/wml2:MeasurementTimeseries/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[1]}]
set lampotila [$lampotilahaku asText]

#------------------------------------------------------------------------------------
# Mittausaika:
#------------------------------------------------------------------------------------

set mittausaikahaku [$fmi selectNodes {(//om:result[1]/wml2:MeasurementTimeseries/wml2:point[last()]/wml2:MeasurementTVP/wml2:time)[2]}]
set aika [$mittausaikahaku asText]
set aikahieno [lindex [split $aika "T"] 1]
set aikahienoformatted [lindex [split $aikahieno "+"] 0]
set tunnit [lindex [split $aikahienoformatted ":"] 0]
set minuutit [lindex [split $aikahienoformatted ":"] 1]

#------------------------------------------------------------------------------------
# Säätila:
#------------------------------------------------------------------------------------

# Lähituntien ennuste -välilehti ja ensimmäisen sarakkeen kuvake
set saatilahaku [$fmihtml selectNodes {//*[@id="p_p_id_localweatherportlet_WAR_fmiwwwweatherportlets_"]/div/div/div/div[2]/div/div[1]/div/div[1]/table/tbody/tr[1]/td[1]/div}]
set saatilaHtml [$saatilahaku asHTML]
regexp {title="(.*?)"} $saatilaHtml saatilaMatch saatila1
set saatila [lindex [split $saatila1 "."] 0]

#------------------------------------------------------------------------------------
# Sade:
#------------------------------------------------------------------------------------

# Edeltävän tunnin sateen määrä:
set sademaarahaku [$fmi selectNodes {(//om:result[1]/wml2:MeasurementTimeseries/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[8]}]
set sademaara [$sademaarahaku asText]

#------------------------------------------------------------------------------------
# Mañana:
#------------------------------------------------------------------------------------

# Tämä on "Lähipäivien ennuste" kohdan sarakkeesta kellonajan 14 tai 15 kohdalla oleva lämpötilasolu
set huomennahaku [$fmihtml selectNodes {//*[@id="p_p_id_localweatherportlet_WAR_fmiwwwweatherportlets_"]/div/div/div/div[2]/div/div[1]/div/div[2]/table/tbody/tr[2]/td[7]/div}]
set huomenna [$huomennahaku asText]

# Klo 15 seuraavan päivän sarakkeen kuvake
set saatilahakuhuomenna [$fmihtml selectNodes {//*[@id="p_p_id_localweatherportlet_WAR_fmiwwwweatherportlets_"]/div/div/div/div[2]/div/div[1]/div/div[2]/table/tbody/tr[1]/td[8]/div}]
set saatilahuomennaHtml [$saatilahakuhuomenna asHTML]
regexp {title="(.*?)"} $saatilahuomennaHtml saatilahuomennaMatch saatilahuomenna1
set saatilahuomenna [lindex [split $saatilahuomenna1 "."] 0]

#------------------------------------------------------------------------------------
# Auringon nousu ja -lasku ja päivän pituus:
#------------------------------------------------------------------------------------

# Tälle on oma palkkinsa, jossa vasemmalla oranssi aurinko-kuvake (19.11.2015)
set paivahaku [$fmihtml selectNodes {//*[@id="p_p_id_localweatherportlet_WAR_fmiwwwweatherportlets_"]/div/div/div/div[2]/div/div[1]/div/div[6]/div[2]}]
set paiva [$paivahaku asText]

#------------------------------------------------------------------------------------
# Tulostetaan palikat alle
# Malli: Tie 4 Jyväskylä, Puuppola -8.4°C (09:55, Heikko sade)
#
# Simsalabim:

putserv "PRIVMSG $chan :\002$kaupunki\002: $lampotila\°C ($tunnit:$minuutit). Sademäärä (<1h): $sademaara mm. \Huomispäiväksi luvattu \002$huomenna\002C, $saatilahuomenna."
putlog "PRIVMSG $chan :\002$kaupunki\002: $lampotila\°C ($tunnit:$minuutit). Sademäärä (<1h): $sademaara mm. \Huomispäiväksi luvattu \002$huomenna\002C, $saatilahuomenna."

# Output:
# 09:55:28 <rolle> !sää jyväskylä
# 09:55:29 <kummitus> Jyväskylä -13,4 °C (pilvistä, valoisaa, mitattu 13.1.2014 9:40 Suomen aikaa). Auringonnousu tänään 9:28.
#           Auringonlasku tänään 15:25. Päivän pituus on 5 h 57 min. Huomiseksi luvattu -14°.

}

# Kukkuluuruu.
putlog "Rolle's weatherscript (version $versio) LOADED!"
