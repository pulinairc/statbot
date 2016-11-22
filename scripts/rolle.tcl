# rolle 2.0,
# tehnyt rolle

#bind pub - !päivänquote pub:quote
bind pub - !säännöt pub:saannot
bind pub - !saannot pub:saannot
bind pub - !statsit pub:statsit
bind pub - !statsit2 pub:statsit2
bind pub - !kuukausistatsit2 pub:kuukausistatsit2
bind pub - !kuukausistatsit pub:kuukausistatsit
bind pub - !tilastot pub:statsit
bind pub - !ohje pub:ohje
bind pub - !apua pub:ohje
bind pub - !haamu pub:ohje
bind pub - !komennot pub:ohje
bind pub - !logit pub:logit
bind pub - !kotisivu pub:kotisivu
bind pub - !muistuttaja pub:muistuttaja
bind pub - !urlit pub:urlit
bind pub - !urls pub:urlit
bind pub - !linkit pub:linkit
bind pub - !kuvat pub:urlit
bind pub - !randomkuvat pub:urlit
bind pub - !ircpics pub:urlit
bind pub - !keskustelu pub:keskustelu
bind pub - !foorumi pub:keskustelu
bind pub - !miitit pub:miitit
bind pub - !diagrammi pub:piespy
bind pub - !kuvastatsit pub:piespy
bind pub - !pics pub:pics
bind pub - !uutiset pub:uutiset
bind pub - !etiketti pub:etiketti
bind pub - !ircetiketti pub:etiketti
proc pub:uutiset {nick host hand chan arg} { if {$chan == "#pulina"} { puthelp "PRIVMSG $chan :$nick\: http://rolle.tux.fi/pulina-uutiset.txt" } }

#bind pub - !sää pub:asdsaa
#proc pub:asdsaa {nick host hand chan arg} { 
#puthelp "PRIVMSG $chan :$nick\: Kirjoita: \002!keli kaupunki\002 (esim !keli vantaa)"
#}

#laittaa botin puhumaan, esim !sano plää  -> <Haamu> plää

bind pub - !sano sano
proc sano {nick host hand chan arg} {
puthelp "PRIVMSG $chan :$arg"
}

proc pub:linkit {nick host hand chan arg} {
   puthelp "PRIVMSG $chan :$nick\: Irkistä kerätyt linkit: http://peikko.us/urllog.log (random-linkki: http://peikko.us/randomlink.php)"
}

proc pub:urlit {nick host hand chan arg} {
   puthelp "PRIVMSG $chan :$nick\: Irkistä kerättyä randomia: http://peikko.us/pulinakuvat/"
}

proc pub:piespy {nick host hand chan arg} {
   puthelp "PRIVMSG $chan :$nick\: http://sillisalaatti.fi/piespy/pulina/pulina-current.png"
}

proc pub:pics {nick host hand chan arg} {
   puthelp "PRIVMSG $chan :$nick\: http://peikko.us/pics/"
}


proc pub:miitit {nick host hand chan arg} {
if {$chan == "#pulina"} {
   puthelp "PRIVMSG $chan :Tulevien ja menneiden miittien tiedot: http://www.pulina.fi/miitit"
   }
}

proc pub:keskustelu {nick host hand chan arg} {
if {$chan == "#pulina"} {
   puthelp "PRIVMSG $chan :$nick\: Keskustelufoorumi: http://keskustelu.pulina.fi"
   }
}


proc pub:kotisivu {nick host hand chan arg} {
if {$chan == "#pulina"} {
   puthelp "PRIVMSG $chan :$nick\: Kanavan kotisivu: http://www.pulina.fi"
   }
}

proc pub:muistuttaja {nick host hand chan arg} {
   puthelp "PRIVMSG $chan :$nick\: Muistuttajan käyttö, esimerkiksi: \0033!muistuta omanick \"tomorrow 10:00\" Soita patelle\003   tai   \0033!muistuta omanick \"2009-12-31 23:59\" Hyvää uutta vuotta!\003   tai   \0033!muistuta omanick \"10 min\" Munat pois hellalta\003   tai   \0033!muistuta omanick \"2 hours\" mene töihin. Poista muistutus komennolla \0033!peruuta <id> \003, aktiiviset muistutukset ja niiden id:t näet komennolla \0033!muistutukset\003."
}

proc pub:statsit {nick host hand chan arg} {
if {$chan == "#pulina"} {
   puthelp "PRIVMSG $chan :Qnetin kätevät statsit: https://stats.quakenet.org/channel/pulina - kokonaistilastot kanavan perustamisesta lähtien: http://peikko.us/statsit/pulina - tämä kuukausi: http://peikko.us/statsit/pulina/kuukausi + Nicdin ylläpitämät tilastot: http://ircstats.nytsoi.net/pulina.html & tämä kuukausi: http://ircstats.nytsoi.net/pulina-month.html"
   }
}
proc pub:statsit2 {nick host hand chan arg} {
if {$chan == "#pulina"} {
   puthelp "PRIVMSG $chan :$nick\: Tässä Nicdin ylläpitämät tilastot, ole hyvä: http://ircstats.nytsoi.net/pulina.html"
   }
}
proc pub:kuukausistatsit {nick host hand chan arg} {
if {$chan == "#pulina"} {
   puthelp "PRIVMSG $chan :$nick\: Tässä tämän kuukauden tilastot, ole hyvä: http://peikko.us/statsit/pulina/kuukausi/"
   }
}   

proc pub:kuukausistatsit2 {nick host hand chan arg} {
if {$chan == "#pulina"} {
   puthelp "PRIVMSG $chan :$nick\: Tässä Nicdin ylläpitämät tämän kuukauden tilastot, ole hyvä: http://ircstats.nytsoi.net/pulina-month.html"
   }
}


proc pub:ohje {nick host hand chan arg} {
   puthelp "PRIVMSG $chan :http://pulina.fi/komennot"
   }

#proc pub:quote {nick host hand chan arg} {
#if {$chan == "#pulina"} {
#   puthelp "PRIVMSG $chan :7.1.2010 14:59 <kyselia> Hupakko on pedo(Koukussa pikkusiin poikiin), snd o sadomasokisti, tykkää heitellä pikkutyttöjä kovilla paketeilla ja jaella namuja kasseista. blANZEY on pervo muuten vaan, tosin töissä jimssissä jotenka loisto tyyppi.(ja kovis online peluri!!!!), sitte TiTii on tommone kiva tyttö, en oo uskaltanu puhuu sille nii en tiedä. tira on kuuma <3, ja mustikkasoppa on kaikkien meidä äiti ja rolle o iskä!"
#   }
#}
proc pub:saannot {nick host hand chan arg} {
    puthelp "PRIVMSG $chan :Säännöt, jotta kaikilla olisi kivaa: http://www.pulina.fi/tietoa/#saannot"
}

proc pub:etiketti {nick host hand chan arg} {
    puthelp "PRIVMSG $chan :IRC-etiketti: http://www.pulina.fi/irc-etiketti"
}
