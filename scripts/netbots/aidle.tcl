# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## aidle.tcl component script ##

proc ai_sendmsg {} {
  global ai_chans ai_msgbots ai_msgs ai_time ai_uidle botnick
  if {$ai_chans == ""} {
    set chan [lindex [channels] [rand [llength [channels]]]]
  } else {
    set chan [lindex $ai_chans [rand [llength $ai_chans]]]
  }
  if {$ai_msgbots} {
    if {[validchan $chan] && [botonchan $chan]} {
      set botlist ""
      foreach bot [chanlist $chan b] {
        if {$bot == $botnick || [onchansplit $bot $chan]} {continue}
        lappend botlist $bot
      }
      if {$botlist != ""} {
        puthelp "PRIVMSG [lindex $botlist [rand [llength $botlist]]] :[lindex $ai_msgs [rand [llength $ai_msgs]]]"
      }
    }
  } else {
    puthelp "PRIVMSG $chan :[lindex $ai_msgs [rand [llength $ai_msgs]]]"
  }
  if {$ai_uidle} {
    utimer [expr 140 + [rand 40]] ai_sendmsg
  } else {
    timer [expr [rand $ai_time] + 1] ai_sendmsg
  }
  return 0
}

set ai_chans [split $ai_chans]

if {$ai_uidle} {
  if {![string match *ai_sendmsg* [utimers]]} {
    utimer [expr 140 + [rand 40]] ai_sendmsg
  }
} else {
  if {![string match *ai_sendmsg* [timers]]} {
    timer [expr [rand $ai_time] + 1] ai_sendmsg
  }
}

return "nb_info 4.10.0"
