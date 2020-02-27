# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## mainserver.tcl component script ##

proc ms_helpidx {hand chan idx} {
  if {![matchattr $hand n]} {return 0}
  putidx $idx "mainserver.tcl commands"
  putidx $idx " For owners:"
  putidx $idx "  mserver       mservers      msreset"
  putidx $idx " "
  return 1
}

proc ms_help {hand chan idx cmd} {
  if {[matchattr $hand n]} {
    switch -exact -- $cmd {
      "mserver" {
        putidx $idx "# mserver"
        putwrap $idx 3 "Displays server/timer details."
        putidx $idx "# mserver <servers>"
        putwrap $idx 3 "Temporarily changes the bot's main server(s). You can specify the server port in server:port format."
        return 1
      }
      "mservers" {
        putidx $idx "# mservers"
        putwrap $idx 3 "Displays server details for all linked bots."
        return 1
      }
      "msreset" {
        putidx $idx "# msreset \[bot|-all\]"
        putwrap $idx 3 "Restarts the server checking timer. If a bot is specified, restarts the timer on that bot. If -all is specified, restarts the timer on all netbots."
        return 1
      }
    }
  }
  return 0
}

lappend nb_helpidx "ms_helpidx"
set nb_help(mserver) "ms_help"
set nb_help(mservers) "ms_help"
set nb_help(msreset) "ms_help"

proc ms_chkserver {} {
  global botnick ms_chans ms_chktime ms_mservers ms_needbot nb_realserver server
  set onserver $server
  if {$server != "" && [info exists nb_realserver] && [string tolower [lindex [split $server :] 0]] != [string tolower $nb_realserver]} {
    set onserver $nb_realserver
  }
  if {![ms_ismserver $onserver]} {
    putlog "mainserver: I'm not on a main server - checking to see if I can jump.."
    set lowbots ""
    if {$ms_chans == ""} {
      set ms_chans [channels]
    }
    foreach chan $ms_chans {
      if {![validchan $chan] || ![botonchan $chan] || ![botisop $chan]} {continue}
      set bots 0
      foreach bot [chanlist $chan b] {
        if {$bot == $botnick} {continue}
        set hand [nick2hand $bot $chan]
        if {[islinked $hand] && ![onchansplit $bot $chan] && [matchattr $hand o|o $chan] && [isop $bot $chan]} {
          incr bots
        }
      }
      if {$bots < $ms_needbot} {
        lappend lowbots $chan
      }
    }
    if {$lowbots != ""} {
      putlog "mainserver: I can't jump because there aren't enough bots to reop me in [join $lowbots ", "] - will try again in $ms_chktime minutes."
      timer $ms_chktime ms_chkserver
    } else {
      putlog "mainserver: found $ms_needbot [nb_plural bot bots $ms_needbot] to reop me on rejoin - jumping to a main server.."
      jump [lindex [split [lindex $ms_mservers 0] :] 0] [lindex [split [lindex $ms_mservers 0] :] 1]
      utimer 300 ms_dblcheck
    }
  } else {
    timer $ms_chktime ms_chkserver
  }
  return 0
}

proc ms_dblcheck {} {
  global ms_chktime ms_failed ms_tryagn nb_realserver server
  set onserver $server
  if {$server != "" && [info exists nb_realserver] && [string tolower [lindex [split $server :] 0]] != [string tolower $nb_realserver]} {
    set onserver $nb_realserver
  }
  if {![ms_ismserver $onserver]} {
    putlog "mainserver: failed to connect to a main server - will try once more in $ms_tryagn minutes."
    set ms_failed 1
    timer $ms_tryagn ms_tryagn
  } else {
    set ms_failed 0
    putlog "mainserver: successful jump to a main server ([lindex [split $onserver :] 0]) detected."
    timer $ms_chktime ms_chkserver
  }
  return 0
}

proc ms_tryagn {} {
  global botnick ms_chans ms_chktime ms_mservers ms_needbot ms_tryagn nb_realserver server
  set onserver $server
  if {$server != "" && [info exists nb_realserver] && [string tolower [lindex [split $server :] 0]] != [string tolower $nb_realserver]} {
    set onserver $nb_realserver
  }
  if {![ms_ismserver $onserver]} {
    putlog "mainserver: failed to connect to a main server $ms_tryagn minutes ago - trying once more.."
    set lowbots ""
    if {$ms_chans == ""} {
      set ms_chans [channels]
    }
    foreach chan $ms_chans {
      if {![validchan $chan] || ![botonchan $chan] || ![botisop $chan]} {continue}
      set bots 0
      foreach bot [chanlist $chan b] {
        if {$bot == $botnick} {continue}
        set hand [nick2hand $bot $chan]
        if {[islinked $hand] && ![onchansplit $bot $chan] && [matchattr $hand o|o $chan] && [isop $bot $chan]} {
          incr bots
        }
      }
      if {$bots < $ms_needbot} {
        set lowbots 1
      }
    }
    if {$lowbots != ""} {
      putlog "mainserver: I can't jump because there aren't enough bots to reop me in [join $lowbots ", "] - will try again in $ms_chktime minutes."
      timer $ms_chktime ms_tryagn
    } else {
      putlog "mainserver: found $ms_needbot [nb_plural bot bots $ms_needbot] to reop me on rejoin - jumping to a main server.."
      jump [lindex [split [lindex $ms_mservers 0] :] 0] [lindex [split [lindex $ms_mservers 0] :] 1]
      utimer 300 ms_forgetit
    }
  } else {
    timer $ms_chktime ms_chkserver
  }
  return 0
}

proc ms_forgetit {} {
  global ms_autoreset ms_chktime ms_failed ms_loaded ms_mservers ms_note nb_realserver server
  set onserver $server
  if {$server != "" && [info exists nb_realserver] && [string tolower [lindex [split $server :] 0]] != [string tolower $nb_realserver]} {
    set onserver $nb_realserver
  }
  if {![ms_ismserver $onserver]} {
    putlog "mainserver: failed to connect to a main server on second attempt."
    if {$ms_autoreset} {
      timer [expr $ms_autoreset * 60] ms_autoreset
      putlog "mainserver: automatically resetting mainserver timer in $ms_autoreset [nb_plural hour hours $ms_autoreset]."
    }
    set ms_failed 2 ; set ms_loaded 0
    if {[info commands sendnote] != ""} {
      foreach recipient $ms_note {
        if {[validuser $recipient]} {
          sendnote MAINSERVER $recipient "Failed to connect to a main server ([join $ms_mservers ", "]) on second attempt."
        }
      }
    }
  } else {
    set ms_failed 0
    putlog "mainserver: successful jump to a main server ([lindex [split $onserver :] 0]) detected."
    timer $ms_chktime ms_chkserver
  }
  return 0
}

proc ms_dccmserver {hand idx arg} {
  global default-port ms_failed ms_mservers nb_realserver server
  putcmdlog "#$hand# mserver $arg"
  if {$arg != ""} {
    set ms_mservers [split $arg]
    putidx $idx "Temporarily changed main [nb_plural server servers [llength $ms_mservers]] to [join $ms_mservers ", "]"
    return 0
  }
  set onserver $server
  if {$server != "" && [info exists nb_realserver] && [string tolower [lindex [split $server :] 0]] != [string tolower $nb_realserver]} {
    set onserver $nb_realserver
  }
  putidx $idx "mainserver.tcl by slennox"
  putidx $idx "Use .mserver <servers> to temporarily change main server(s)."
  putidx $idx "This bot's main servers are: [join $ms_mservers ", "]"
  if {$onserver == ""} {
    putidx $idx "Not connected to a server."
  } else {
    putidx $idx "Connected to: $onserver"
  }
  if {$ms_failed == 1} {
    putidx $idx "Jump status: failed first attempt to connect to a main server."
  } elseif {$ms_failed == 2} {
    putidx $idx "Jump status: failed both attempts to connect to a main server."
  }
  foreach timer [timers] {
    if {[lindex $timer 1] == "ms_chkserver"} {
      putidx $idx "Timer status: [lindex $timer 0] minutes until the next server check."
      set timeron 1
    } elseif {[lindex $timer 1] == "ms_tryagn"} {
      putidx $idx "Timer status: [lindex $timer 0] minutes until the second attempt to connect to a main server."
      set timeron 1
    }
  }
  foreach timer [utimers] {
    if {[lindex $timer 1] == "ms_dblcheck"} {
      putidx $idx "Timer status: waiting to check if attempt to jump to a main server was successful.."
      set timeron 1
    } elseif {[lindex $timer 1] == "ms_forgetit"} {
      putidx $idx "Timer status: waiting to check if second attempt to jump to a main server was successful.."
      set timeron 1
    }
  }
  if {![info exists timeron]} {
    putidx $idx "Timer status: server checking not active - use .msreset to restart the timer."
  }
  return 0
}

proc ms_dccmservers {hand idx arg} {
  global botnet-nick ms_mservers nb_realserver server
  putcmdlog "#$hand# mservers $arg"
  set tmrstatus ""
  if {![ms_timer]} {
    set tmrstatus "\[timer inactive\]"
  }
  set onserver $server
  if {$server != "" && [info exists nb_realserver] && [string tolower [lindex [split $server :] 0]] != [string tolower $nb_realserver]} {
    set onserver $nb_realserver
  }
  if {$onserver == ""} {
    putidx $idx "${botnet-nick} is not on a server (main servers: [join $ms_mservers ", "]) $tmrstatus"
  } elseif {![ms_ismserver $onserver]} {
    putidx $idx "${botnet-nick} is on $onserver (main servers: [join $ms_mservers ", "]) $tmrstatus"
  } else {
    putidx $idx "${botnet-nick} is on $onserver (a main server) $tmrstatus"
  }
  nb_sendcmd * mservers [list $idx]
  return 0
}

proc ms_mservers {frombot arg} {
  global botnick ms_mservers nb_realserver server
  set onserver $server
  if {$server != "" && [info exists nb_realserver] && [string tolower [lindex [split $server :] 0]] != [string tolower $nb_realserver]} {
    set onserver $nb_realserver
  }
  if {$onserver == ""} {
    set main "none"
  } elseif {![ms_ismserver $onserver]} {
    set main "notmain"
  } else {
    set main "main"
  }
  set tmrstatus "tmron"
  if {![ms_timer]} {
    set tmrstatus "tmroff"
  }
  nb_sendcmd $frombot rmservers [list [lindex $arg 0] $tmrstatus $main $onserver [join $ms_mservers ", "]]
  return 0
}

proc ms_rmservers {frombot arg} {
  set server [lindex $arg 2] ; set onserver [lindex $arg 3] ; set mservers [lindex $arg 4]
  set tmrstatus ""
  if {[lindex $arg 1] == "tmroff"} {
    set tmrstatus "\[timer inactive\]"
  }
  if {$server == "none"} {
    putidx [lindex $arg 0] "$frombot is not on a server (main servers: $mservers) $tmrstatus"
  } elseif {$server == "notmain"} {
    putidx [lindex $arg 0] "$frombot is on $onserver (main servers: $mservers) $tmrstatus"
  } else {
    putidx [lindex $arg 0] "$frombot is on $onserver (a main server) $tmrstatus"
  }
  return 0
}

proc ms_dccmsreset {hand idx arg} {
  global ms_chktime ms_failed ms_loaded
  putcmdlog "#$hand# msreset $arg"
  set bot [lindex [split $arg] 0]
  if {$bot != ""} {
    if {$bot == "-all"} {
      nb_sendcmd * msreset [split $idx]
      putidx $idx "Resetting mainserver timer on all bots.."
    } else {
      if {![islinked $bot]} {
        putidx $idx "$bot is not linked." ; return 0
      }
      nb_sendcmd $bot msreset [split $idx]
      putidx $idx "Resetting mainserver timer on $bot"
    }
  } else {
    if {$ms_loaded} {
      putidx $idx "Server check is already active."
    } else {
      set ms_loaded 1 ; set ms_failed 0
      timer $ms_chktime ms_chkserver
      putidx $idx "Reset mainserver timer, will resume checking to make sure I'm on a main server."
    }
  }
  return 0
}

proc ms_msreset {frombot arg} {
  global ms_chktime ms_failed ms_loaded
  if {$ms_loaded} {
    nb_sendcmd $frombot rmsreset [list [lindex $arg 0] tmractive]
  } else {
    set ms_loaded 1 ; set ms_failed 0
    timer $ms_chktime ms_chkserver
    nb_sendcmd $frombot rmsreset [list [lindex $arg 0]]
  }
  return 0
}

proc ms_rmsreset {frombot arg} {
  if {[lindex $arg 1] == "tmractive"} {
    putidx [lindex $arg 0] "$frombot: server check is already active."
  } else {
    putidx [lindex $arg 0] "$frombot: reset mainserver timer, will resume checking to make sure I'm on a main server."
  }
  return 0
}

proc ms_autoreset {} {
  global ms_autoreset ms_chktime ms_failed ms_loaded
  if {!$ms_loaded} {
    set ms_loaded 1 ; set ms_failed 0
    timer $ms_chktime ms_chkserver
    putlog "mainserver: timer automatically reset after $ms_autoreset [nb_plural hour hours $ms_autoreset] wait, will resume checking to make sure I'm on a main server."
  }
  return 0
}

proc ms_ismserver {server} {
  global ms_mservers
  set server [string tolower [lindex [split $server :] 0]] ; set mservers ""
  foreach mserver $ms_mservers {
    set mserver [string tolower [lindex [split $mserver :] 0]]
    lappend mservers $mserver
  }
  if {[lsearch -exact $mservers $server] != -1} {return 1}
  return 0
}

proc ms_timer {} {
  set timers [timers] ; set utimers [utimers]
  if {![string match *ms_chkserver* $timers] && ![string match *ms_tryagn* $timers] && ![string match *ms_dblcheck* $utimers] && ![string match *ms_forgetit* $utimers]} {
    return 0
  }
  return 1
}

if {![info exists ms_loaded]} {
  set ms_loaded 1 ; set ms_failed 0
  timer $ms_chktime ms_chkserver
}

set ms_chans [split $ms_chans] ; set ms_note [split $ms_note]
set servers [nb_randport [concat [nb_randomise $ms_mservers] [nb_randomise $ms_servers]]]

set nb_netcmds(mservers) "ms_mservers"
set nb_netcmds(rmservers) "ms_rmservers"
set nb_netcmds(msreset) "ms_msreset"
set nb_netcmds(rmsreset) "ms_rmsreset"

bind dcc n mserver ms_dccmserver
bind dcc n mservers ms_dccmservers
bind dcc n msreset ms_dccmsreset

return "nb_info 4.10.0"
