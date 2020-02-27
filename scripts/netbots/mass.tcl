# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## mass.tcl component script ##

proc ma_helpidx {hand chan idx} {
  if {![matchattr $hand n]} {return 0}
  putidx $idx "mass.tcl commands"
  putidx $idx " For owners:"
  if {[info commands putserv] != ""} {
    putidx $idx "  mass          netmass"
  } else {
    putidx $idx "  netmass"
  }
  putidx $idx " "
  return 1
}

proc ma_help {hand chan idx cmd} {
  if {[matchattr $hand n]} {
    switch -exact -- $cmd {
      "mass" {
        putidx $idx "# mass <type> <channel> \[option\]"
        putwrap $idx 3 "Makes the bot perform a variety of mass functions, including mass kick, op, deop, voice, and devoice. Each of the mass types has different options to specify how the mass function should be performed. The mass function types and their options are explained below."
        putidx $idx "    kick"
        putwrap $idx 5 "Sets +i and kicks all users on the specified channel, except opped, voiced, and users matching the +f/o/v flags. The option can be a kick reason. If no reason is specified, the default mass kick reason is used."
        putidx $idx "    op"
        putwrap $idx 5 "If no option is specified, ops all +o flag users who aren't opped on the channel. If -ops is specified, ops all +o flag users who are currently opped."
        putidx $idx "    deop"
        putwrap $idx 5 "If no option is specified, deops all opped users without the +o flag. If -all is specified, deops all opped users except global owners (+n) and other netbots (or +b users if nb_flag is set to 'all'). If -nonops is specified, deops all users without the +o flag, including those who aren't currently opped on the channel."
        putidx $idx "    voice"
        putwrap $idx 5 "If no option is specified, voices all +v flag users who aren't voiced. If -all is specified, voices all users on the channel who aren't currently voiced."
        putidx $idx "    devoice"
        putwrap $idx 5 "If no option is specified, devoices all voiced users without the +v flag. If -all is specied, devoices all voiced users."
        return 1
      }
      "netmass" {
        putidx $idx "# netmass <type> <channel> \[option\]"
        putwrap $idx 3 "Makes all currently controlled netbots perform the specified mass command (see '.nethelp mass' for more info about mass types and their options)."
        return 1
      }
    }
  }
  return 0
}

lappend nb_helpidx "ma_helpidx"
set nb_help(mass) "ma_help"
set nb_help(netmass) "ma_help"

if {[info commands putserv] != ""} {
  proc ma_dccmass {hand idx arg} {
    global ma_reason
    putcmdlog "#$hand# mass $arg"
    set type [lindex [split $arg] 0] ; set chan [lindex [split $arg] 1]
    if {$type == "" || $chan == ""} {
      putidx $idx "Usage: mass <type> <channel> \[option\]" ; return 0
    }
    if {![validchan $chan]} {
      putidx $idx "No such channel." ; return 0
    } elseif {![botonchan $chan]} {
      putidx $idx "I'm not on $chan" ; return 0
    } elseif {![botisop $chan]} {
      putidx $idx "I'm not opped on $chan" ; return 0
    }
    set option [lindex [split $arg] 2]
    if {$option == ""} {
      set option "none"
    }
    switch -exact -- $type {
      "kick" {
        putidx $idx "Mass kicking $chan"
        if {$option == "none"} {
          set reason $ma_reason
        } else {
          set reason [join [lrange [split $arg] 2 end]]
        }
        ma_kick $chan [join [lrange [split $arg] 2 end]]
      }
      "op" {
        if {$option == "none" || $option == "-ops"} {
          putidx $idx "Mass opping $chan"
          ma_op $chan $option
        } else {
          putidx $idx "Valid options are: -ops"
        }
      }
      "deop" {
        if {$option == "none" || $option == "-all" || $option == "-nonops"} {
          putidx $idx "Mass deopping $chan"
          ma_deop $chan $option
        } else {
          putidx $idx "Valid options are: -all, -nonops"
        }
      }
      "voice" {
        if {$option == "none" || $option == "-all"} {
          putidx $idx "Mass voicing $chan"
          ma_voice $chan $option
        } else {
          putidx $idx "Valid options are: -all"
        }
      }
      "devoice" {
        if {$option == "none" || $option == "-all"} {
          putidx $idx "Mass devoicing $chan"
          ma_devoice $chan $option
        } else {
          putidx $idx "Valid options are: -all"
        }
      }
      "default" {putidx $idx "$type is not a valid mass command."}
    }
    return 0
  }
}

proc ma_dccnetmass {hand idx arg} {
  global ma_reason nb_control
  putcmdlog "#$hand# netmass $arg"
  set type [lindex [split $arg] 0] ; set chan [lindex [split $arg] 1]
  if {$type == "" || $chan == ""} {
    putidx $idx "Usage: netmass <type> <channel> \[option\]" ; return 0
  }
  set option [lindex [split $arg] 2]
  if {$option == ""} {
    set option "none"
  }
  switch -exact -- $type {
    "kick" {
      putidx $idx "Making netbots mass kick $chan"
      if {$option == "none"} {
        set reason $ma_reason
      } else {
        set reason [join [lrange [split $arg] 2 end]]
      }
      nb_sendcmd $nb_control mass [list $hand kick $chan $reason]
      if {[nb_control]} {
        if {[info commands putserv] != ""} {
          ma_kick $chan $reason
        }
      }
    }
    "op" {
      if {$option == "none" || $option == "-ops"} {
        putidx $idx "Making netbots mass op $chan"
        nb_sendcmd $nb_control mass [list $hand op $chan $option]
        if {[nb_control]} {
          if {[info commands putserv] != ""} {
            ma_op $chan $option
          }
        }
      } else {
        putidx $idx "Valid options are: -ops"
      }
    }
    "deop" {
      if {$option == "none" || $option == "-all" || $option == "-nonops"} {
        putidx $idx "Making netbots mass deop $chan"
        nb_sendcmd $nb_control mass [list $hand deop $chan $option]
        if {[nb_control]} {
          if {[info commands putserv] != ""} {
            ma_deop $chan $option
          }
        }
      } else {
        putidx $idx "Valid options are: -all, -nonops"
      }
    }
    "voice" {
      if {$option == "none" || $option == "-all"} {
        putidx $idx "Making netbots mass voice $chan"
        nb_sendcmd $nb_control mass [list $hand voice $chan $option]
        if {[nb_control]} {
          if {[info commands putserv] != ""} {
            ma_voice $chan $option
          }
        }
      } else {
        putidx $idx "Valid options are: -all"
      }
    }
    "devoice" {
      if {$option == "none" || $option == "-all"} {
        putidx $idx "Making netbots mass devoice $chan"
        nb_sendcmd $nb_control mass [list $hand devoice $chan $option]
        if {[nb_control]} {
          if {[info commands putserv] != ""} {
            ma_devoice $chan $option
          }
        }
      } else {
        putidx $idx "Valid options are: -all"
      }
    }
    "default" {putidx $idx "$type is not a valid mass command."}
  }
  return 0
}

proc ma_netmass {frombot arg} {
  set type [lindex $arg 1] ; set chan [lindex $arg 2]
  putlog "netbots \[[lindex $arg 0]@$frombot\]: mass $type $chan."
  if {![validchan $chan] || ![botonchan $chan] || ![botisop $chan]} {return 0}
  set option [lindex $arg 3]
  switch -exact -- $type {
    "kick" {
      ma_kick $chan $option
    }
    "op" {
      if {$option == "none" || $option == "-ops"} {
        ma_op $chan $option
      }
    }
    "deop" {
      if {$option == "none" || $option == "-all" || $option == "-nonops"} {
        ma_deop $chan $option
      }
    }
    "voice" {
      if {$option == "none" || $option == "-all"} {
        ma_voice $chan $option
      }
    }
    "devoice" {
      if {$option == "none" || $option == "-all"} {
        ma_devoice $chan $option
      }
    }
  }
  return 0
}

proc ma_kick {chan reason} {
  global botnick ma_kicks
  putserv "MODE $chan +i"
  set nlist ""
  foreach nick [nb_randomise [chanlist $chan]] {
    if {[isop $nick $chan] || [isvoice $nick $chan] || [matchattr [nick2hand $nick $chan] fov|fov $chan] || $nick == $botnick || [onchansplit $nick $chan]} {continue}
    lappend nlist $nick
    if {[llength $nlist] >= $ma_kicks} {
      putserv "KICK $chan [join $nlist ,] :$reason"
      unset nlist
    }
  }
  if {[info exists nlist]} {
    putserv "KICK $chan [join $nlist ,] :$reason"
  }
  return 0
}

proc ma_op {chan option} {
  global botnick nb_flag
  set randlist [nb_randomise [chanlist $chan]]
  if {$option == "-ops"} {
    foreach nick $randlist {
      if {![isop $nick $chan] || ![matchattr [nick2hand $nick $chan] o|o $chan] || [onchansplit $nick $chan]} {continue}
      pushmode $chan +o $nick
    }
  } elseif {$option == "none"} {
    foreach nick $randlist {
      if {[isop $nick $chan] || ![matchattr [nick2hand $nick $chan] o|o $chan] || [onchansplit $nick $chan]} {continue}
      pushmode $chan +o $nick
    }
  }
  flushmode $chan
  return 0
}

proc ma_deop {chan option} {
  global botnick nb_flag
  set randlist [nb_randomise [chanlist $chan]]
  if {$option == "-all"} {
    if {$nb_flag == "all"} {
      set botflag "b"
    } else {
      set botflag $nb_flag
    }
    foreach nick $randlist {
      set hand [nick2hand $nick $chan]
      if {![isop $nick $chan] || [matchattr $hand $botflag] || [matchattr $hand n] || $nick == $botnick || [onchansplit $nick $chan]} {continue}
      pushmode $chan -o $nick
    }
  } elseif {$option == "-nonops"} {
    foreach nick $randlist {
      if {[matchattr [nick2hand $nick $chan] o|o $chan] || $nick == $botnick || [onchansplit $nick $chan]} {continue}
      pushmode $chan -o $nick
    }
  } elseif {$option == "none"} {
    foreach nick $randlist {
      if {![isop $nick $chan] || [matchattr [nick2hand $nick $chan] o|o $chan] || $nick == $botnick || [onchansplit $nick $chan]} {continue}
      pushmode $chan -o $nick
    }
  }
  flushmode $chan
  return 0
}

proc ma_voice {chan option} {
  global botnick nb_flag
  set randlist [nb_randomise [chanlist $chan]]
  if {$option == "-all"} {
    foreach nick $randlist {
      if {[isvoice $nick $chan] || $nick == $botnick || [onchansplit $nick $chan]} {continue}
      pushmode $chan +v $nick
    }
  } elseif {$option == "none"} {
    foreach nick $randlist {
      if {[isvoice $nick $chan] || ![matchattr [nick2hand $nick $chan] v|v $chan] || $nick == $botnick || [onchansplit $nick $chan]} {continue}
      pushmode $chan +v $nick
    }
  }
  flushmode $chan
  return 0
}

proc ma_devoice {chan option} {
  global botnick nb_flag
  set randlist [nb_randomise [chanlist $chan]]
  if {$option == "-all"} {
    foreach nick $randlist {
      if {![isvoice $nick $chan] || $nick == $botnick || [onchansplit $nick $chan]} {continue}
      pushmode $chan -v $nick
    }
  } elseif {$option == "none"} {
    foreach nick $randlist {
      if {![isvoice $nick $chan] || [matchattr [nick2hand $nick $chan] v|v $chan] || $nick == $botnick || [onchansplit $nick $chan]} {continue}
      pushmode $chan -v $nick
    }
  }
  flushmode $chan
  return 0
}

if {[info commands putserv] != ""} {
  if {!${kick-method}} {
    set ma_kicks 8
  } else {
    set ma_kicks ${kick-method}
  }
}

set nb_netcmds(mass) "ma_netmass"

if {[info commands putserv] != ""} {
  bind dcc n mass ma_dccmass
}
bind dcc n netmass ma_dccnetmass

return "nb_info 4.10.0"
