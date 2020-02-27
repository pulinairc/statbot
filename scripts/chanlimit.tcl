# chanlimit.tcl for netbots.tcl v3.35
# designed to work with eggdrop 1.4.0 or higher
# copyright (c) 1998-2000 by slennox <slennox@egghelp.org>
# chanlimit.tcl copyright (c) 1999,2000 by johoho <johoho@hojo-net.de>
# slennox's eggdrop page - http://www.egghelp.org/

## chanlimit.tcl component script v3.35.0+johoho ##

proc cl_helpidx {hand chan idx} {
  if {![matchattr $hand m|m $chan]} {return 0}
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

proc cl_dolimit {} {
  global cl_bots cl_chans cl_echans cl_bots cl_grace cl_limit cl_log cl_timer
  foreach chan [channels] {
    set ishere 0
    foreach thisbot $cl_bots	{
      if {[handonchan $thisbot $chan] && [isop $thisbot $chan]} {
        set ishere 1
        break
      }
    }
    if {!$ishere} {
      if {$cl_chans != ""} {
        if {[lsearch -exact $cl_chans [string tolower $chan]] == -1} {continue}
      }
      if {$cl_echans != ""} {
        if {[lsearch -exact $cl_echans [string tolower $chan]] != -1} {continue}
      }
      if {((![validchan $chan]) || (![botonchan $chan]) || (![botisop $chan]))} {continue}
      if {[string match *l* [lindex [lindex [channel info $chan] 0] 0]]} {continue}
      set newlimit [expr [llength [chanlist $chan]] + $cl_limit]
      if {[string match *l* [lindex [split [getchanmode $chan]] 0]]} {
        set currlimit [string range [getchanmode $chan] [expr [string last " " [getchanmode $chan]] + 1] end]
      } else {
        set currlimit 0
      }
      if {$newlimit == $currlimit} {continue}
      if {$newlimit > $currlimit} {
        set difference [expr $newlimit - $currlimit]
      } elseif {$currlimit > $newlimit} {
        set difference [expr $currlimit - $newlimit]
      }
      if {$difference <= $cl_grace} {continue}
      pushmode $chan +l $newlimit
      if {$cl_log} {
        putlog "chanlimit: set +l $newlimit on $chan"
      }
    }
  }
  timer $cl_timer cl_dolimit
  return 0
}

proc cl_dccdolimit {hand idx arg} {
  nb_killtimer "cl_dolimit"
  putidx $idx "Checking limits.."
  cl_dolimit
  return 0
}

proc cl_dccstoplimit {hand idx arg} {
  if {[nb_killtimer "cl_dolimit"]} {
    putidx $idx "Limiting is now OFF."
  } else {
    putidx $idx "Limiting is already off."
  }
  return 0
}

proc cl_dccstartlimit {hand idx arg} {
  global cl_timer
  if {[string match *cl_dolimit* [timers]]} {
    putidx $idx "Limiting is already on."
  } else {
    timer $cl_timer cl_dolimit
    putidx $idx "Limiting is now ON."
  }
  return 0
}

set cl_chans [split [string tolower $cl_chans]] ; set cl_echans [split [string tolower $cl_echans]]

if {![string match *cl_dolimit* [timers]]} {
  timer $cl_timer cl_dolimit
}

bind dcc m|m dolimit cl_dccdolimit
bind dcc m|m stoplimit cl_dccstoplimit
bind dcc m|m startlimit cl_dccstartlimit
bind rejn - * cl_dolimit

return
