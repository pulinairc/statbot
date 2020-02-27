# Tissit. Nuff said.

# Updated:
set versijonummero "2013-12-09"
#------------------------------------------------------------------------------------
# Elä herran tähen mäne koskemaan tai taivas putoaa niskaas!
# Minun reviiri alkaa tästä.

package require http
package require tdom

bind pub - !tissit pub:random

proc pub:random { nick uhost hand chan text } { 

set randomurl "http://apina.biz/random/big%20boobs" 

set randomsivu [::http::data [::http::geturl $randomurl]] 
set randomdata [dom parse -html $randomsivu] 
set random [$randomdata documentElement] 

# Haetaan eri osasia:
# Note to self: Chromen devaustyökalulla saa kopsattua helposti Copy XPath jos sorsa muuttuu!

set kuvake [$random selectNodes {//*[@id="big_image"]/a/img}]
set kuvahtml [$kuvake asHTML]
regexp {src="(.*?)"} $kuvahtml kuvamatch kuvaurl
# Alt-tagihan on siis "Lämpötila, Helsinki Rautatientori", joten hankkiudutaan eroon "Lämpötila" -tekstistä splittaamalla se
set kuva $kuvaurl

# Simsalabim:
putserv "PRIVMSG $chan :$kuva" 
}

# Kukkuluuruu.
putlog "tissit mainittu"