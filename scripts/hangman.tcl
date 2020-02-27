#         Script : Hangman v1.01 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2002 Radical Computer Systems
#                             All Rights Reserved
#
#       Testing
#      Platforms : Linux 2.2.16   TCL v8.3
#                  Eggdrop v1.6.2
#                  Eggdrop v1.6.6
#            And : SunOS 5.8      TCL v8.3
#                  Eggdrop v1.5.4
#
#    Description : Hangman game.
#       Features :
#               o Allows person who started it to play if they
#                 let the script pick a random puzzle.
#               o Wont get bogged down when a lot of letter
#                 guesses are thrown at it.
#               o Auto-end game when the last letter has been
#                 guessed.
#               o Three (3) difficulty levels.
#               o Automatially ends game if no one takes a
#                 guess for a predetermined period of time.
#               o Comes with 100 preset puzzles.
#
#        History : 04/15/2002 - First Release
#                  08/26/2002 - v1.01
#                              o Removed single usage of -nocase to fix
#                                error on older TCLs. 
#                                (Reported by |^Jax^|@DALnet)
#
#
#   Future Plans : Fix Bugs. :)
#
# Author Contact :     Email - DProper@stx.rr.com
#                  Home Page - http://home.stx.rr.com/dproper
#       Homepage Direct Link - http://www.chaotix.net:3000/~dproper
#                        IRC - Primary Nick: DrN
#                     UseNet - alt.irc.bots.eggdrop
# Support Channels: #RCS @UnderNet.Org
#                   #RCS @DALnet
#                   #RCS @EFnet
#                   #RCS @GalaxyNet
#                   #RCS @Choatix Addiction
#
# Notice: ChatGalaxy is no longer supported. It's OPERs are cunts and
#         Klined me for no reason at all. So fuck the lamers.
#
#                Current contact information can be located at:
#                 http://www.chaotix.net:3000/rcs/contact.html
#
# New TCL releases are sent to the following sites as soon as they're released:
#
# FTP Site                   | Directory                     
# ---------------------------+-------------------------------
# ftp.chaotix.net            | /pub/RCS
# ftp.eggheads.org           | Various
# ftp.realmweb.org           | /drn
#
# Chaotix.Net has returned. mailing list and web site back online.
#
#   Radical Computer Systems - http://www.chaotix.net/rcs/
# To subscribe to the RCS mailing list: mail majordomo@chaotix.net and in
#  BODY of message, type  subscribe rcs-list
#
#  Feel free to Email me any suggestions/bug reports/etc.
# 
# You are free to use this TCL/script as long as:
#  1) You don't remove or change author credit
#  2) You don't release it in modified form. (Only the original)
# 
# If you have a "too cool" modification, send it to me and it'll be
# included in the official release. (With your credit)
#
# Commands Added:
#  Where     F CMD          F CMD            F CMD           F CMD
#  -------   - ----------   - ------------   - -----------   - ----------
#  Public:   - hangman      - hangmanstats   o hangmanstart
#     MSG:   N/A
#     DCC:   o hangman
#
# Using the !hangmanstart command to start a game you can include a level
# on the command line. IE:  !hangmanstart 2     to start a game with
# difficultly level 2.
#
# When using the .hangman command to start a game you have 4 options:
# .hangman                               - Start a game with random puzzle
#                                          Last used/default difficultly
# .hangman 2                             - Start a game with random puzzle
#                                          Set difficultly level 2
# .hangman This is my puzzle             - Start a game with given puzzle
#                                          Last used/default difficultly
# .hangman 3 This is my puzzle           - Start a game with given puzzle
#                                          Set difficultly level 3
#
# When using .hangman to start a game with a custom puzzle, the person
# who started the game will not be able to play it. (How fair would THAT be)
#
# Public Matching: N/A
#


# Set this to the command charactor to preceed all public commands
set cmdchar_ "!"

# Set this to the path/filename of the list of words/phrases to use
set hangman(datafile) "/home/rolle/eggdrop/scripts/hangman/hangman_words"

# Set this to the path/filename of the high scores file
set hangman(scorefile) "/home/rolle/eggdrop/scripts/hangman/hangman_scores"

# Set this to how many letter gusses they get
set hangman(maxtry) 6

# [1/2/3] This sets the difficulty level of the game.
#         Level 1: Display how many turns are left and what letters used.
#         Level 2: Don't display how many turns are left.
#         Level 3: Don't display how many turns are left or letters used.
set hangman(level) 1

# [Minutes] Set this to how long a game will last without someone taking a guess
set hangman(timeout) 5

# [Seconds] Set this to how long to wait after a guess to show current
#           puzzle status
set hangman(display) 10

# Set this to the max numbers of scores to list in the high score display
set hangman(maxscore) 5

# [seconds] Set this to how long to keep old hangman score records
#2592000 = 1 day       77760000 = 30 days
set hangman(expire) 77760000

# [1/2/3/4] 0:Total Correct Letters 1:Total Wrong Letters
#           2:Total Wrong Guesses   3:Total Wins
# Select the method in which to sort the high score list by.
set hangman(sortby) 3



set hangman(ver) "v1.01.00"

set hangman(timer) ""
set hangman(dtimer) ""

proc cmdchar { } {global cmdchar_; return $cmdchar_}


bind pub - [cmdchar]h pub_hangman
proc pub_hangman {nick uhost hand chan rest} {
global hangman hangmans
  if {$hangman(trys) == 0} {putserv "NOTICE $nick :$nick: Hirsipuu ei ole käynnissä juuri nyt."
                            return 0}
  killtimer $hangman(timer)
  set hangman(timer) [timer $hangman(timeout) hangman_abort]
 if {$hangman(started) == $nick} {putserv "PRIVMSG $chan :Älä arvaamalla paljasta omaa hirsipuutasi $nick :D"
  if {[botisop $chan]} {putserv "KICK $chan $nick :Oikeesti, älä arvaa omaa hirsipuutas... idiootti"}
                                  return 0}
 if {$rest == ""} {putserv "privmsg $chan :$nick: Haluutko arvatakin joskus?"
                   return 1}

 # tot_r tot_w r w tot_w
 if {[info exists hangmans($nick)]} {
   set totrit [lindex $hangmans($nick) 0]
   set totwrg [lindex $hangmans($nick) 1]
   set totwrgg [lindex $hangmans($nick) 2]
   set rit [lindex $hangmans($nick) 3]
   set wrg [lindex $hangmans($nick) 4]
   set wrgg [lindex $hangmans($nick) 5]
   set totwin [lindex $hangmans($nick) 6]
                                    } else {
                                            hangman_update $nick 0 0 0 0 0 0 0
                                            lappend hangman(nicks) $nick
   set totrit 0;set totwrg 0; set totwrgg 0; set rit 0; set wrg 0; set wrgg 0; set totwin 0
                                           }

 if {[string length $rest] > 1} {
  if {$hangman(puzzle) == [string toupper $rest]} {
    incr totwin 1
    hangman_update $nick $totrit $totwrg $totwrgg $rit $wrg $wrg $totwin
                                                   hangman_win $chan $nick
                                                   return 0}
  putserv "PRIVMSG $chan :Väärä arvaus $nick!"
  incr totwrgg 1; incr wrgg 1;  hangman_update $nick $totrit $totwrg $totwrgg $rit $wrg $wrgg $totwin
  hangman_lt $chan
  return 0
                                 }

 if {[lindex $rest 1] != ""} {hangman_takeguess $nick $chan $rest}
 set chr [string toupper [string index $rest 0]]
 if {([string match "*$chr*" $hangman(guessed)] > 0)} {
  putserv "PRIVMSG $chan :$nick: Kirjainta $chr on jo veikattu!"
  incr wrg 1;incr totwrg 1;  hangman_update $nick $totrit $totwrg $totwrgg $rit $wrg $wrgg $totwin
  hangman_lt $chan
  return 0
                                                      }
 if {([string match "*$chr*" $hangman(puzzle)] < 1)} {
                 incr wrg 1; incr totwrg 1
                 hangman_update $nick $totrit $totwrg $totwrgg $rit $wrg $wrgg $totwin
                 hangman_missed $chan $nick $chr
                                              return 0}
 if {([string match "*$chr*" $hangman(alpha)] > 0)} {
                 hangman_guess $chan $nick $chr}
}

proc hangman_update {nick totrit totwrg totwrgg rit wrg wrgg totwin} {
global hangmans
 set hangmans($nick) "$totrit $totwrg $totwrgg $rit $wrg $wrgg $totwin [unixtime]"
}


proc hangman_lt {chan} {
global hangman
 incr hangman(trys) -1
 if {$hangman(trys) == 0} {hangman_end $chan}
}

proc hangman_missed {chan nick chr} {
global hangman
  append hangman(guessed) $chr
  putserv "PRIVMSG $chan :$nick: HUTI! $chr on väärin."
  hangman_lt $chan
}

proc hangman_guess {chan nick chr} {
global hangman hangmans
   set totrit [lindex $hangmans($nick) 0]
   set totwrg [lindex $hangmans($nick) 1]
   set totwrgg [lindex $hangmans($nick) 2]
   set rit [lindex $hangmans($nick) 3]
   set wrg [lindex $hangmans($nick) 4]
   set wrgg [lindex $hangmans($nick) 5]
   set totwin [lindex $hangmans($nick) 6]

 append hangman(guessed) $chr
 set le [string length $hangman(spuzzle)]        
 set lp 0
 set temppuzzle ""
 
 while {$lp < $le} {
  if {[string index $hangman(puzzle) $lp] == $chr} {append temppuzzle $chr} else {append temppuzzle [string index $hangman(spuzzle) $lp]}
  incr lp
                   }
 set hangman(spuzzle) $temppuzzle
 if {$hangman(puzzle) == $hangman(spuzzle)} {
      incr totwin 1
      hangman_update $nick $totrit $totwrg $totwrgg $rit $wrg $wrgg $totwin
                                             hangman_win $chan $nick
                                             return 0}
 if {([string match "*$chr*" $hangman(puzzle)] > 0)} {
  putserv "PRIVMSG $chan :Oikea kirjain \026 $chr \026 - hyvä $nick!" 
  incr rit 1; incr totrit 1
  hangman_update $nick $totrit $totwrg $totwrgg $rit $wrg $wrgg $totwin

  if {$hangman(dtimer) != ""} {killutimer $hangman(dtimer)}
  set hangman(dtimer) [utimer $hangman(display) "hangman_show $chan"]
#  hangman_show $chan
                                                     }
}

proc hangman_win {chan nick} {
 global hangman
 if {$hangman(dtimer) != ""} {killutimer $hangman(dtimer)}
 putserv "PRIVMSG $chan :\002Onnittelut $nick! Arvasit hirsipuun.\002"
 putserv "PRIVMSG $chan :Ratkaistu hirsipuun sana: $hangman(puzzle)"
 set hangman(trys) 0
 killtimer $hangman(timer)
 hangman_save
 putserv "PRIVMSG $chan :Käytä [cmdchar]hangmanstats nähdäksesi pisteet."
}

proc hangman_end {chan} {
global hangman
 if {$hangman(dtimer) != ""} {killutimer $hangman(dtimer)}
 putserv "PRIVMSG $chan :Kukaan ei ratkaissut hirsipuuta."
 putserv "PRIVMSG $chan :Hirsipuun sana oli: $hangman(puzzle)"
 set hangman(trys) 0
 killtimer $hangman(timer)
 hangman_save
 putserv "PRIVMSG $chan :Käytä [cmdchar]hangmanstats nähdäksesi pisteet."
}

proc hangman_abort {} {
global hangman
 if {$hangman(dtimer) != ""} {killutimer $hangman(dtimer)}
 set chan $hangman(chan)
 putserv "PRIVMSG $chan :Bah. Kyllästyn arvausten odotteluun..."
 putserv "PRIVMSG $chan :Hirsipuu on päättynyt."
 putserv "PRIVMSG $chan :Ja sanahan oli: $hangman(puzzle)"
 set hangman(trys) 0
 hangman_save
}


bind dcc o|o hangman dcc_hangman
proc dcc_hangman {handle idx rest} {
 global hangman
 set rest1 [lindex $rest 0]
 if {($rest1 > 0) && ($rest1 <4)} {set hangman(level) $rest1
                                   set rest [lrange $rest 1 end]}


 set chan [string tolower [lindex [console $idx] 0]]
 if {$hangman(trys) > 0} {putidx $idx "Hirsipuu jo menossa kanavalla $hangman(chan)." 
                          return 0}

 set hangman(started) [hand2nick $handle]
 if {$rest == ""} {
   if {![file exists $hangman(datafile)]} {
     putidx $idx "$hangman(datafile) -datatiedostoa ei löytynyt."
     return 0
                                          }
                   set rest [hangman_pick]
                   set hangman(started) "RandomSelection"}
 putidx $idx "Käytetään kanavaa $chan hirsipuuhun"
 hangman_start $chan $handle $rest
}

proc hangman_start {chan nick rest} {
global hangman hangmans
 set hangman(puzzle) [string toupper $rest]
 set hangman(chan) $chan
 set hangman(guessed) ""
 set hangman(spuzzle) ""
 set hangman(trys) $hangman(maxtry)
 
 set count 0
 while {$count < [string length $hangman(puzzle)]} {
  set chr [string index $hangman(puzzle) $count]
  if {([string match "*[string tolower $chr]*" [string tolower $hangman(alpha)]] > 0)} {
   append hangman(spuzzle) "_"} else {
   append hangman(spuzzle) "$chr"}
  incr count
                                        }
 foreach n $hangman(nicks) {
   set totrit [lindex $hangmans($n) 0]
   set totwrg [lindex $hangmans($n) 1]
   set totwrgg [lindex $hangmans($n) 2]
   set totwin [lindex $hangmans($n) 6]
   set rit 0
   set wrg 0
   set wrgg 0
   hangman_update $n $totrit $totwrg $totwrgg $rit $wrg $wrgg $totwin
                            }

#  putserv "PRIVMSG $chan :Hirsipuu $hangman(ver) - Koodannut David Proper (DrN)"
  putserv "PRIVMSG $chan :Pelin aloitti $nick. Vaikeusaste: $hangman(level)."
  putserv "PRIVMSG $chan :\002Arvataksesi kirjaimen:\002 [cmdchar]h kirjain"
  putserv "PRIVMSG $chan :\002Arvataksesi koko sanan:\002 [cmdchar]h sana"
  putserv "PRIVMSG $chan :\002Statsit:\002 [cmdchar]hirsipuutilastot"
  hangman_show $chan
  set hangman(chan) $chan
  set hangman(timer) [timer $hangman(timeout) hangman_abort]
}

proc hangman_pick {} {
 global hangman
 set tot 0
 set path $hangman(datafile)
 set in [open $path r]
 while {![eof $in]} {set line [gets $in]; if {$line != ""} {set tot [expr $tot + 1]}}
 close $in
 set ploop 0
 while {$ploop < 100} {incr ploop; set r [rand $tot]}
 set in [open $path r]
 for {set rloop 1} {$rloop < $r} {incr rloop} {set line [gets $in]}
 set line [gets $in]
 return $line
}


bind pub o|o [cmdchar]hirsipuu pub_hangmanstart
proc pub_hangmanstart {nick uhost hand chan rest} {
global hangman
 if {$hangman(trys) > 0} {putserv "NOTICE $nick :Hirsipuu on jo käynnissä kanavalla $hangman(chan)." 
                          return 0}
 if {($rest > 0) && ($rest <4)} {set hangman(level) $rest}

 if {![file exists $hangman(datafile)]} {
     putserv "NOTICE $nick :$hangman(datafile) -datatiedostoa ei löytynyt."
     return 0
                                        }
 set rest [hangman_pick]
 set hangman(started) "RandomSelection"
 hangman_start $chan $nick $rest
}

proc hangman_show {chan} {
 global hangman
 set hangman(dtimer) ""
 putserv "privmsg $chan :\002Sana: \002 $hangman(spuzzle)"
#         Level 1: Display how many turns are left and what letters used.
#         Level 2: Don't display how many turns are left.
#         Level 3: Don't display how many turns are left or letters used.
 switch $hangman(level) {
  1 {putserv "privmsg $chan :\002Yrityksiä jäljellä: \002 $hangman(trys)  -:- \002 Käytetyt kirjaimet: \002 $hangman(guessed)"}
  2 {putserv "privmsg $chan :\002 Käytetyt kirjaimet: \002 $hangman(guessed)"}
                        }
 if {$hangman(hint) != ""} {putserv "privmsg $chan :\026Vihje: \026 $hangman(hint)"}
}

bind pub - [cmdchar]hirsipuutilastot pub_hangmanstats
proc pub_hangmanstats {nick uhost hand chan rest} {
global hangman hangmans
 if {[llength $hangman(nicks)] == 0} {putserv "PRIVMSG $chan :Ei vielä yhtään pelaajaa."; return 0}
# putserv "PRIVMSG $chan :There's been a total of [llength $hangman(nicks)] people play."
 set num 0

hangman_highscores $chan
}

proc hangman_highscores {chan} {
global hangman hangmans 
 set sorted [hangman_sort]
 set tot [llength $hangman(nicks)]
 if {$tot > $hangman(maxscore)} {
   putserv "PRIVMSG $chan :[llength $hangman(nicks)] pistettä listattu. Listataan top $hangman(maxscore). Lajiteltu $sorted mukaan."
   set tot $hangman(maxscore)
               }

putserv "PRIVMSG $chan :\002          \[\026 Kokonaistilastot \026\] \[\026 Nykyiset tilastot \026\] Yhteensä\002"
putserv "PRIVMSG $chan :\002   Nick   Oikeita Vääriä Arvauksia Oikeita Vääriä Arvauksia Voittoja\002"
putserv "PRIVMSG $chan :\002--------- ------- ------ --------- ------- ------ --------- --------\002"

 for {set l 0} {$l < $tot} {incr l} {
  set n [lindex $hangman(nicks) $l]
   set totrit [lindex $hangmans($n) 0]; set totwrg [lindex $hangmans($n) 1]
   set totwrgg [lindex $hangmans($n) 2]; set rit [lindex $hangmans($n) 3]
   set wrg [lindex $hangmans($n) 4]; set wrgg [lindex $hangmans($n) 5]
   set totwin [lindex $hangmans($n) 6]
      set out ""
  append out " [format "%-9s" $n]"
  append out " [format "%-5s" $totrit]"
  append out " [format "%-5s" $totwrg]"
  append out " [format "%-5s" $totwrgg]"
  append out " [format "%-5s" $rit]"
  append out " [format "%-5s" $wrg]"
  append out " [format "%-5s" $wrgg]"
  append out " [format "%-5s" $totwin]"
  putserv "PRIVMSG $chan :$out"
                        }
 unset out  
putserv "PRIVMSG $chan :\002--------- ------- ------ --------- ------- ------ --------- --------\002"
}

proc hangman_sort {} {
 global hangman hangmans
# hangman_sort
 set sortby $hangman(sortby)
 switch $sortby {
                   "0" {set sorting "Oikeita kirjaimia kaikenkaikkiaan"}
                   "1" {set sorting "Vääriä kirjaimia kaikenkaikkiaan"}
                   "2" {set sorting "Vääriä arvauksia kaikenkaikkiaan"}
                   "3" {set sorting "Voittoja kaikenkaikkiaan"}
                  }
 if {$sortby == 3} {set sortby 6}
 set l 0
 set tot [llength $hangman(nicks)]
 for {set l 1} {$l < [expr $tot +1]} {incr l} {
  set nicks($l) [lindex $hangman(nicks) [expr $l -1]]
  }
 set l1 0
 set t [llength $hangman(nicks)]
 for {set l1 1} {$l1 < $tot} {incr l1} {
  for {set l2 $l1} {$l2 < [expr $tot +1]} {incr l2} {
   set data1 [lindex $hangmans($nicks($l1)) $sortby]
   set data2 [lindex $hangmans($nicks($l2)) $sortby]
   if {$data1 < $data2} {set temp $nicks($l1)
                         set nicks($l1) $nicks($l2)
                         set nicks($l2) $temp
                        }
                                                              }
                                                           } 
# set tot [llength $hangman(nicks)]
 set hangman(nicks) ""
 for {set l 1} {$l < [expr $tot +1]} {incr l} {
  lappend hangman(nicks) $nicks($l)
                                    }
 return "$sorting"
}

proc hangman_fake {} {
global hangman hangmans
 set nick ""
 for {set loop 1} {$loop < [expr [rand 5] + 3]} {incr loop} {
  append nick [string index $hangman(alpha) [rand 26]]
                                                             }
 hangman_update $nick [rand 100] [rand 100] [rand 100] [rand 100] [rand 100] [rand 100] [rand 100]
 lappend hangman(nicks) $nick
}

proc hangman_save {} {
global hangman hangmans
 putlog "Tallennetaan Hirsipuun $hangman(ver) pisteitä."
 set tot [llength $hangman(nicks)]
 set out [open $hangman(scorefile) w]

 puts $out $tot
 for {set l 0} {$l < $tot} {incr l} {
  puts $out "[lindex $hangman(nicks) $l] $hangmans([lindex $hangman(nicks) $l])"
                                              }
 close $out
}

proc hangman_load {} {
global hangman hangmans
 putlog "Ladataan Hirsipuun $hangman(ver) pisteitä tiedostosta $hangman(scorefile)"
# set tot [llength $hangman(nicks)]

  set hangman(nicks) ""
  if {[info exists hangmans]} {unset hangmans}
  if {[file exists $hangman(scorefile)]} {
                                 set in [open $hangman(scorefile) r]
                                 set tot [gets $in]
 for {set l 0} {$l < $tot} {incr l} {
   set line [gets $in]
   set nick [lindex $line 0]
   set lastused [lindex $line 8]
   if {$lastused == ""} {set lastused [unixtime]}
   if {[expr [unixtime] - $lastused] < $hangman(expire)} {
             set totrit [lindex $line 1]
             set totwrg [lindex $line 2]
             set totwrgg [lindex $line 3]
             set rit [lindex $line 4]
             set wrg [lindex $line 5]
             set wrgg [lindex $line 6]
             set totwin [lindex $line 7]
             lappend hangman(nicks) $nick
             hangman_update $nick $totrit $totwrg $totwrgg $rit $wrg $wrgg $totwin
                                                         }
                                   }
                                           }
}

set hangman(puzzle) ""
set hangman(chan) ""
set hangman(spuzzle) ""
set hangman(guessed) ""
set hangman(alpha) "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖ"
set hangman(trys) 0
set hangman(hint) ""

hangman_load


putlog "Script loaded: \002Hirsipuu $hangman(ver) - Koodannut David Proper (DrN)\002"
return "Hirsipuu $hangman(ver) - Koodannut David Proper (DrN) -: Ladattu :-"

