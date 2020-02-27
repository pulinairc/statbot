bind pub - "!braininfo" pub_braininfo
proc pub_braininfo {nick uhost hand chan arg} {
  global learnmode
  global surprise
  global maxreplywords
  set for [treesize -1 0]
  set back [treesize -1 1]
  puthelp "PRIVMSG $chan :Nykyinen sanamääräni käsittää [lindex $for 0] sanaa, aivojeni koko on [expr [lindex $for 1]+[lindex $back 1]] nystyrää, ja oppimistila on tilassa: $learnmode. Yllätystila on tilassa: $surprise. Sanoja vastauksissa: $maxreplywords." 
#  if {[file exists megahal.old]} {
#    puthelp "PRIVMSG $chan :This brain has been growing for [duration [expr [unixtime] - [file mtime megahal.old]]]" 
#  }
}