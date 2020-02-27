#
#This is a quick tcl fore the Megahal module. now you can set all options on or off with a chan command
#I think the commands explain themself. It is a quick release but it should work :)
#Any comments/bugs/etc may be sent to tiniduske@pandora.be
#I'm alsow on irc.krey.net with the nick Tiniduske
#
#The MegaHAL module is provided by others so any errors ore bugs are not my fault (but it works great with me :p)
#

bind pub - !megahal-off pub_!megahal-off
bind pub - "*shut*up*HABITSOFMAN*" pub_!shutup2
bind pub - !megahal-on pub_!megahal-on
bind pub o|o !learnall-off pub_!learnall-off
bind pub o|o !learnall-on pub_!learnall-on
bind pub o|o !freespeak-off pub_!freespeak-off
bind pub o|o !freespeak-on pub_!freespeak-on
bind pub o|o !megahalall-off pub_!megahalall-off
bind pub o|o !megahalall-on pub_!megahalall-on
bind pub o|o !$botnick-off pub_!megahalall-off
bind pub o|o !$botnick-on pub_!megahalall-on
bind pub - !skynet pub_skynet

proc pub_!megahal-off {nick host hand chan arg} {
  if {[channel get $chan megatalk] == 1} {
    channel set $chan -megatalk
    putchan $chan [string toupper "OK, olen nyt hiljaa."] } {
    puthelp "NOTICE $chan :Tekoäly on jo pois päältä."
  }
}

proc pub_!shutup2 {nick host hand chan arg} {
  if {[channel get $chan megatalk] == 1} {
    channel set $chan -megatalk
    putchan $chan [string toupper "OK, olen nyt hiljaa."] } {
    puthelp "NOTICE $chan :Tekoäly on jo pois päältä."
  }
}

proc pub_skynet {nick host hand chan arg} {
    putchan $chan [string toupper "HELLO, LETHARGIC."]
  }

proc pub_!megahal-on {nick host hand chan arg} {
  if {[channel get $chan megatalk] == 0} {
    channel set $chan +megatalk
    putchan $chan [string toupper "Moi vaan kaikille!"] } {
    puthelp "NOTICE $chan :Tekoäly on jo päällä."
  }
}
proc pub_!learnall-off {nick host hand chan arg} {
  if {[channel get $chan learnall] == 1} {
    channel set $chan -learnall
    puthelp "NOTICE $chan :Tekoälyn oppiminen (learnall) on jo valmiiksi pois päältä." } {
    puthelp "NOTICE $chan :Tekoälyn oppiminen (learnall) on jo valmiiksi pois päältä."
  }
}
proc pub_!learnall-on {nick host hand chan arg} {
  if {[channel get $chan learnall] == 0} {
    channel set $chan +learnall
    puthelp "NOTICE $chan :Tekoälyn oppiminen (learnall) on nyt lykätty päälle." } {
    puthelp "NOTICE $chan :Tekoälyn oppiminen (learnall) on jo valmiiksi päällä."
  }
}
proc pub_!freespeak-off {nick host hand chan arg} {
  if {[channel get $chan freespeak] == 1} {
    channel set $chan -freespeak
    puthelp "NOTICE $chan :Tekoälyn satunnainen yksinään höpöttely on nyt pois päältä." } {
    puthelp "NOTICE $chan :Tekoälyn satunnainen yksinään höpöttely on jo valmiiksi pois päältä."
  }
}
proc pub_!freespeak-on {nick host hand chan arg} {
  if {[channel get $chan freespeak] == 0} {
    channel set $chan +freespeak
    puthelp "NOTICE $chan :Tekoälyn satunnainen yksinään höpöttely on nyt aktivoitu." } {
    puthelp "NOTICE $chan :Tekoälyn satunnainen yksinään höpöttely on jo valmiiksi päällä."
  }
}
proc pub_!megahalall-off {nick host hand chan arg} {
    channel set $chan -freespeak -megahal -learnall
    puthelp "NOTICE $chan :Tekoäly deaktivoitu."
}
proc pub_!megahalall-on {nick host hand chan arg} {
    channel set $chan +freespeak +megahal +learnall
    puthelp "NOTICE $chan :Tekoäly aktivoitu."
}

putlog "Script loaded: \002megahal-helper.tcl Ver: 0.1, Made by Tiniduske\002"
