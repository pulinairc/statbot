# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## chanlimit.tcl component script ##

proc cl_helpidx {hand chan idx} {
  if {![matchattr $hand m] && ![matchattr $hand |m $chan]} {return 0}
  putidx $idx "chanlimit.tcl commands"
  putidx $idx " For channel masters:"
  putidx $idx "  dolimit       stoplimit     startlimit"
  putidx $idx " "
  return 1
}

proc cl_help {hand chan idx cmd} {
  if {[matchattr $hand m|m $chan]} {
    switch -exact -- $cmd {
      "dolimit" {
        putidx $idx "# dolimit"
        putwrap $idx 3 "Runs limit checking on demand."
        return 1
      }
      "stoplimit" {
        putidx $idx "# stoplimit"
        putwrap $idx 3 "Temporarily stops limiting (until the next rehash/restart)."
        return 1
      }
      "startlimit" {
        putidx $idx "# startlimit"
        putwrap $idx 3 "Restarts limiting."
        return 1
      }
    }
  }
  return 0
}

lappend nb_helpidx "cl_helpidx"
set nb_help(dolimit) "cl_help"
set nb_help(stoplimit) "cl_help"
set nb_help(startlimit) "cl_help"

# override argument: 1 to ignore cl_priority list and do the limit anyway (e.g. when calling from a user dcc command), 0 otherwise
proc cl_dolimit {chan override} {
  global cl_chans cl_echans cl_grace cl_limit cl_log
  if {$chan != ""} {
    set chans $chan
  } else {
    set chans [channels]
  }
  foreach chan $chans {
    if {$cl_chans != ""} {
      if {[lsearch -exact $cl_chans [string tolower $chan]] == -1} {continue}
    }
    if {$cl_echans != ""} {
      if {[lsearch -exact $cl_echans [string tolower $chan]] != -1} {continue}
    }
    if {![validchan $chan] || ![botonchan $chan] || ![botisop $chan]} {continue}
    if {!$override && ![cl_priority $chan]} {continue}
    if {[string match *l* [lindex [lindex [channel info $chan] 0] 0]]} {continue}
    set newlimit [expr [llength [chanlist $chan]] + $cl_limit]
    if {[string match *l* [lindex [split [getchanmode $chan]] 0]]} {
      set currlimit [string range [getchanmode $chan] [expr [string last " " [getchanmode $chan]] + 1] end]
    } else {
      set currlimit 0
    }
    if {$currlimit > 0} {
      if {$newlimit == $currlimit} {continue}
      if {$newlimit > $currlimit} {
        set difference [expr $newlimit - $currlimit]
      } elseif {$currlimit > $newlimit} {
        set difference [expr $currlimit - $newlimit]
      }
      if {$difference <= $cl_grace} {continue}
    }
    pushmode $chan +l $newlimit
    if {$cl_log} {
      putlog "chanlimit: set +l $newlimit on $chan"
    }
  }
  return
}

proc cl_priority {chan} {
  global cl_priority
  if {$cl_priority == ""} {return 1}
  foreach bot $cl_priority {
    if {[isbotnetnick $bot]} {return 1}
    if {[set nick [hand2nick $bot $chan]] != "" && [isop $nick $chan] && ![onchansplit $nick $chan]} {return 0}
  }
  return 1
}

proc cl_dccdolimit {hand idx arg} {
  putidx $idx "Checking limits.."
  cl_dolimit "" 1
  return 0
}

proc cl_dccstoplimit {hand idx arg} {
  if {[nb_killtimer "cl_timer"]} {
    putidx $idx "Limiting is now OFF."
  } else {
    putidx $idx "Limiting is already off."
  }
  return 0
}

proc cl_dccstartlimit {hand idx arg} {
  global cl_timer
  if {[string match *cl_timer* [timers]]} {
    putidx $idx "Limiting is already on."
  } else {
    timer $cl_timer cl_timer
    putidx $idx "Limiting is now ON."
  }
  return 0
}

proc cl_mode {nick uhost hand chan mode limit} {
  if {$mode == "+l" && [string match "*.*" $nick]} {
    cl_dolimit $chan 0
  }
}

proc cl_timer {} {
  global cl_timer
  cl_dolimit "" 0
  if {$cl_timer && ![string match *cl_timer* [timers]]} {
    timer $cl_timer cl_timer
  }
  return
}

set cl_priority [split $cl_priority]

set cl_chans [split [string tolower $cl_chans]] ; set cl_echans [split [string tolower $cl_echans]]

if {$cl_timer && ![string match *cl_timer* [timers]]} {
  timer $cl_timer cl_timer
}

bind mode - * cl_mode
if {!$cl_server} {
  unbind mode - * cl_mode
  rename cl_mode ""
}
bind dcc m|m dolimit cl_dccdolimit
bind dcc m|m stoplimit cl_dccstoplimit
bind dcc m|m startlimit cl_dccstartlimit

return "nb_info 4.10.0"
