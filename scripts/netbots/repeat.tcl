# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## repeat.tcl component script ##

proc rp_pubmsg {nick uhost hand chan text} {
  global botnick rp_bcount rp_bflood rp_breason rp_btime rp_efficient rp_exempt rp_kcount rp_kflood rp_kreason rp_scount rp_sflood rp_slength rp_sreason rp_warning
  set uhost [string tolower $uhost] ; set chan [string tolower $chan] ; set text [string tolower $text]
  if {$nick == $botnick || ![rp_chan $chan] || [matchattr $hand $rp_exempt $chan]} {return 0}
  if {!$rp_efficient && [llength [utimers]] > 999} {return 0}
  if {![info exists rp_bcount($uhost:$chan:$text)]} {
    set rp_bcount($uhost:$chan:$text) 1
  } else {
    incr rp_bcount($uhost:$chan:$text)
  }
  if {![info exists rp_kcount($uhost:$chan:$text)]} {
    set rp_kcount($uhost:$chan:$text) 1
  } else {
    incr rp_kcount($uhost:$chan:$text)
  }
  if {!$rp_efficient} {
    utimer [lindex $rp_bflood 1] [list rp_breset $uhost $chan $text]
    utimer [lindex $rp_kflood 1] [list rp_kreset $uhost $chan $text]
  }
  if {[string length $text] > $rp_slength} {
    if {![info exists rp_scount($uhost:$chan:$text)]} {
      set rp_scount($uhost:$chan:$text) 1
    } else {
      incr rp_scount($uhost:$chan:$text)
    }
    if {!$rp_efficient} {
      utimer [lindex $rp_sflood 1] [list rp_sreset $uhost $chan $text]
    }
  }
  if {$rp_bcount($uhost:$chan:$text) == [lindex $rp_bflood 0]} {
    if {[botisop $chan]} {
      putserv "KICK $chan $nick :$rp_breason"
    }
    set ban *!*[string range $uhost [string first @ $uhost] end]
    if {![matchban $ban $chan]} {
      newchanban $chan $ban repeat $rp_breason $rp_btime
    }
  } elseif {$rp_kcount($uhost:$chan:$text) == [lindex $rp_kflood 0]} {
    if {![rp_mhost $nick $uhost $chan] && [botisop $chan]} {
      if {$rp_warning} {
        puthelp "PRIVMSG $chan :$nick$rp_kreason"
      } else {
        putserv "KICK $chan $nick :$rp_kreason"
      }
    }
  } elseif {[info exists rp_scount($uhost:$chan:$text)]} {
    if {$rp_scount($uhost:$chan:$text) == [lindex $rp_sflood 0]} {
      if {![rp_mhost $nick $uhost $chan] && [botisop $chan]} {
        if {$rp_warning} {
          puthelp "PRIVMSG $chan :$nick$rp_sreason"
        } else {
          putserv "KICK $chan $nick :$rp_sreason"
        }
      }
    }
  }
  return 0
}

proc rp_chan {chan} {
  global rp_chans rp_echans
  if {$rp_chans != ""} {
    if {[lsearch -exact $rp_chans [string tolower $chan]] == -1} {return 0}
  }
  if {$rp_echans != ""} {
    if {[lsearch -exact $rp_echans [string tolower $chan]] != -1} {return 0}
  }
  return 1
}

proc rp_pubact {nick uhost hand dest key arg} {
  if {![validchan $dest]} {return 0}
  rp_pubmsg $nick $uhost $hand $dest $arg
  return 0
}

proc rp_pubnotc {from keyword arg} {
  set nick [lindex [split $from !] 0]
  set chan [lindex [split $arg] 0]
  if {![validchan $chan] || ![onchan $nick $chan]} {return 0}
  set uhost [string trimleft [getchanhost $nick $chan] "~+-^="]
  set hand [nick2hand $nick $chan]
  set text [join [lrange [split $arg] 1 end]]
  rp_pubmsg $nick $uhost $hand $chan $text
  return 0
}

proc rp_mhost {nick uhost chan} {
  global rp_btime rp_mhosts rp_mreason rp_mtime
  set mhost [lindex [split $uhost @] 1]
  if {![info exists rp_mhosts($chan)]} {
    set rp_mhosts($chan) ""
  }
  if {[lsearch -exact $rp_mhosts($chan) $mhost] != -1} {
    if {[botisop $chan]} {
      putserv "KICK $chan $nick :$rp_mreason"
    }
    set ban *!*[string tolower [string range $uhost [string first @ $uhost] end]]
    if {![matchban $ban $chan]} {
      newchanban $chan $ban repeat $rp_mreason $rp_btime
    }
    return 1
  } else {
    lappend rp_mhosts($chan) $mhost
    utimer $rp_mtime [list rp_mhostreset $chan]
  }
  return 0
}

proc rp_mhostreset {chan} {
  global rp_mhosts
  set rp_mhosts($chan) [lrange $rp_mhosts($chan) 1 end]
  return 0
}

if {$rp_efficient} {

  proc rp_breset {} {
    global rp_bcount rp_bflood
    if {[info exists rp_bcount]} {
      unset rp_bcount
    }
    utimer [lindex $rp_bflood 1] rp_breset
    return 0
  }

  proc rp_kreset {} {
    global rp_kcount rp_kflood
    if {[info exists rp_kcount]} {
      unset rp_kcount
    }
    utimer [lindex $rp_kflood 1] rp_kreset
    return 0
  }

  proc rp_sreset {} {
    global rp_scount rp_sflood
    if {[info exists rp_scount]} {
      unset rp_scount
    }
    utimer [lindex $rp_sflood 1] rp_sreset
    return 0
  }

  nb_killutimer rp_kreset
  nb_killutimer rp_breset
  nb_killutimer rp_sreset

  if {[lsearch -exact $rp_kflood 0] == -1} {
    utimer [lindex $rp_kflood 1] rp_kreset
  }
  if {[lsearch -exact $rp_bflood 0] == -1} {
    utimer [lindex $rp_bflood 1] rp_breset
  }
  if {[lsearch -exact $rp_sflood 0] == -1} {
    utimer [lindex $rp_sflood 1] rp_sreset
  }

} else {

  proc rp_breset {uhost chan text} {
    global rp_bcount
    if {![incr rp_bcount($uhost:$chan:$text) -1]} {
      unset rp_bcount($uhost:$chan:$text)
    }
    return 0
  }

  proc rp_kreset {uhost chan text} {
    global rp_kcount
    if {![incr rp_kcount($uhost:$chan:$text) -1]} {
      unset rp_kcount($uhost:$chan:$text)
    }
    return 0
  }

  proc rp_sreset {uhost chan text} {
    global rp_scount
    if {![incr rp_scount($uhost:$chan:$text) -1]} {
      unset rp_scount($uhost:$chan:$text)
    }
    return 0
  }

  nb_killutimer "rp_kreset*"
  nb_killutimer "rp_breset*"
  nb_killutimer "rp_sreset*"

}

set rp_chans [split [string tolower $rp_chans]]
set rp_echans [split [string tolower $rp_echans]]
set rp_kflood [split $rp_kflood :]
set rp_bflood [split $rp_bflood :]
set rp_sflood [split $rp_sflood :]

bind pubm - * rp_pubmsg
bind ctcp - ACTION rp_pubact
bind raw - NOTICE rp_pubnotc

return "nb_info 4.10.0"
