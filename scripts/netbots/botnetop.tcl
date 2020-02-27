# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## botnetop.tcl component script ##

proc bop_jointmr {nick uhost hand chan} {
  global bop_asktmr bop_delay botnick numversion
  if {$nick != $botnick} {
    if {![matchattr $hand b] || ![matchattr $hand o|o $chan] || [matchattr $hand d|d $chan]} {return 0}
    set stlchan [string tolower $chan]
    if {[info exists bop_asktmr($hand:$stlchan)]} {return 0}
    set bop_asktmr($hand:$stlchan) 1
    if {!$bop_delay || [bop_lowbots $chan]} {
      utimer 5 [list bop_askbot $hand $chan]
    } else {
      utimer [expr [rand $bop_delay] + 5] [list bop_askbot $hand $chan]
    }
  } else {
    bop_setneed $chan
  }
  return 0
}

proc bop_linkop {bot via} {
  if {[isbotnetnick $bot] || [isbotnetnick $via]} {
    if {![string match *bop_linkreq* [utimers]]} {
      utimer 2 bop_linkreq
    }
  }
  return 0
}

proc bop_linkreq {} {
  foreach chan [channels] {
    if {![botisop $chan]} {
      bop_reqop $chan op
    }
  }
  return
}

proc bop_reqop {chan need} {
  global bop_needi
  if {![info exists bop_needi([string tolower $chan])]} {
    bop_setneed $chan
  }
  if {$need == "op"} {
    foreach bot [chanlist $chan b] {
      if {[isop $bot $chan] && [matchattr [set hand [nick2hand $bot $chan]] o|o $chan] && [islinked $hand]} {
        putbot $hand "reqops $chan"
      }
    }
  } else {
    bop_letmein $chan $need
  }
  return 0
}

proc bop_modeop {nick uhost hand chan mode opped} {
  global botnick
  if {$mode == "+o" && ![botisop $chan] && $nick != $botnick && $opped != $botnick && [matchattr [set obot [nick2hand $opped $chan]] b] && [matchattr $obot o|o $chan] && [islinked $obot]} {
    putbot $obot "reqops $chan"
  }
  return
}

proc bop_reqtmr {frombot cmd arg} {
  global bop_asktmr bop_delay
  set chan [lindex [split $arg] 0]
  if {![validchan $chan]} {return 0}
  if {![matchattr $frombot b] || ![matchattr $frombot o|o $chan] || [matchattr $frombot d|d $chan]} {return 0}
  set stlchan [string tolower $chan]
  if {[info exists bop_asktmr($frombot:$stlchan)]} {return 0}
  set bop_asktmr($frombot:$stlchan) 1
  if {!$bop_delay || [bop_lowbots $chan]} {
    utimer 2 [list bop_askbot $frombot $chan]
  } else {
    utimer [expr [rand $bop_delay] + 2] [list bop_askbot $frombot $chan]
  }
  return 0
}

proc bop_askbot {hand chan} {
  global botnick bop_asktmr
  set stlchan [string tolower $chan]
  if {[info exists bop_asktmr($hand:$stlchan)]} {
    unset bop_asktmr($hand:$stlchan)
  }
  if {![validchan $chan] || ![botonchan $chan] || ![botisop $chan]} {return 0}
  if {![islinked $hand]} {return 0}
  putbot $hand "doyawantops $chan $botnick"
  return 0
}

proc bop_doiwantops {frombot cmd arg} {
  global bop_log bop_maxreq bop_opreqs botname botnick
  set chan [lindex [split $arg] 0] ; set fromnick [lindex [split $arg] 1]
  if {![validchan $chan] || ![botonchan $chan] || [botisop $chan]} {return 0}
  set stlchan [string tolower $chan]
  if {$bop_maxreq && $bop_opreqs($stlchan) >= $bop_maxreq} {return 0}
  if {![onchan $fromnick $chan] || [onchansplit $fromnick $chan] || ![isop $fromnick $chan]} {return 0}
  if {![matchattr [nick2hand $fromnick $chan] o|o $chan]} {return 0}
  if {![islinked $frombot]} {return 0}
  putbot $frombot "yesiwantops $chan $botnick [string trimleft [lindex [split $botname !] 1] "~+-^="]"
  incr bop_opreqs($stlchan)
  if {$bop_maxreq} {
    nb_killutimer "bop_opreqsreset $stlchan"
    utimer 30 [list bop_opreqsreset $stlchan]
  }
  if {$bop_log >= 2} {
    putlog "botnetop: requested ops from $frombot on $chan"
  }
  return 0
}

proc bop_botwantsops {frombot cmd arg} {
  global bop_addhost bop_hcheck bop_log bop_osync numversion strict-host
  set chan [lindex [split $arg] 0] ; set fromnick [lindex [split $arg] 1] ; set fromhost [lindex [split $arg] 2]
  if {![botonchan $chan] || ![botisop $chan]} {return 0}
  if {![onchan $fromnick $chan] || [onchansplit $fromnick $chan]} {return 0}
  if {![matchattr $frombot b] || ![matchattr $frombot o|o $chan] || [matchattr $frombot d|d $chan]} {return 0}
  if {$bop_hcheck && $fromhost != "" && $fromhost != [string trimleft [getchanhost $fromnick $chan] "~+-^="]} {return 0}
  if {![matchattr [nick2hand $fromnick $chan] o|o $chan]} {
    if {$fromhost == "" || !$bop_addhost} {return 0}
    if {${strict-host} == 0} {
      set host *![string trimleft [getchanhost $fromnick $chan] "~+-^="]
    } else {
      set host *![getchanhost $fromnick $chan]
    }
    setuser $frombot HOSTS $host
    putlog "botnetop: added host $host to $frombot"
  }
  if {$bop_osync} {
    if {$numversion < 1040000} {
      pushmode $chan +o $fromnick
    } else {
      putquick "MODE $chan +o $fromnick"
    }
  } else {
    if {[isop $fromnick $chan]} {return 0}
    pushmode $chan +o $fromnick
  }
  if {$bop_log >= 2} {
    if {$fromnick != $frombot} {
      putlog "botnetop: gave ops to $frombot (using nick $fromnick) on $chan"
    } else {
      putlog "botnetop: gave ops to $frombot on $chan"
    }
  }
  return 0
}

proc bop_letmein {chan need} {
  global botname botnick bop_log bop_needk bop_needi bop_needl bop_needu
  if {[bots] == "" || [botonchan $chan]} {return 0}
  set stlchan [string tolower $chan]
  switch -exact -- $need {
    "key" {
      if {$bop_needk($stlchan)} {return 0}
      set reqlist ""
      foreach bot [bots] {
        if {![matchattr $bot b] || ![matchattr $bot o|o $chan]} {continue}
        putbot $bot "wantkey $chan $botnick"
        lappend reqlist $bot
      }
      if {$bop_log >= 1 && $reqlist != ""} {
        regsub -all -- " " [join $reqlist] ", " reqlist
        putlog "botnetop: requested key for $chan from $reqlist"
      }
      set bop_needk($stlchan) 1
      utimer 30 [list set bop_needk($stlchan) 0]
    }
    "invite" {
      if {$bop_needi($stlchan)} {return 0}
      set reqlist ""
      foreach bot [bots] {
        if {![matchattr $bot b] || ![matchattr $bot o|o $chan]} {continue}
        if {[string match *!* $botname]} {
          putbot $bot "wantinvite $chan $botnick [string trimleft [lindex [split $botname !] 1] "~+-^="]"
        } else {
          putbot $bot "wantinvite $chan $botnick"
        }
        lappend reqlist $bot
      }
      if {$bop_log >= 1 && $reqlist != ""} {
        regsub -all -- " " [join $reqlist] ", " reqlist
        putlog "botnetop: requested invite to $chan from $reqlist"
      }
      set bop_needi($stlchan) 1
      utimer 30 [list set bop_needi($stlchan) 0]
    }
    "limit" {
      if {$bop_needl($stlchan)} {return 0}
      set reqlist ""
      foreach bot [bots] {
        if {![matchattr $bot b] || ![matchattr $bot o|o $chan]} {continue}
        putbot $bot "wantlimit $chan $botnick"
        lappend reqlist $bot
      }
      if {$bop_log >= 1 && $reqlist != ""} {
        regsub -all -- " " [join $reqlist] ", " reqlist
        putlog "botnetop: requested limit raise on $chan from $reqlist"
      }
      set bop_needl($stlchan) 1
      utimer 30 [list set bop_needl($stlchan) 0]
    }
    "unban" {
      if {$bop_needu($stlchan) || ![string match *!* $botname]} {return 0}
      set reqlist ""
      foreach bot [bots] {
        if {![matchattr $bot b] || ![matchattr $bot o|o $chan]} {continue}
        putbot $bot "wantunban $chan $botnick $botname"
        lappend reqlist $bot
      }
      if {$bop_log >= 1 && $reqlist != ""} {
        regsub -all -- " " [join $reqlist] ", " reqlist
        putlog "botnetop: requested unban on $chan from $reqlist"
      }
      set bop_needu($stlchan) 1
      utimer 30 [list set bop_needu($stlchan) 0]
    }
  }
  return 0
}

proc bop_botwantsin {frombot cmd arg} {
  global bop_didlimit bop_icheck bop_log bop_who
  set chan [lindex [split $arg] 0]
  if {![validchan $chan]} {return 0}
  if {![matchattr $frombot b] || ![matchattr $frombot fo|fo $chan]} {return 0}
  set fromhost [lindex [split $arg] 2]
  switch -exact -- $cmd {
    "wantkey" {
      if {[string match *k* [lindex [split [getchanmode $chan]] 0]]} {
        set key [lindex [split [getchanmode $chan]] 1]
        # Key may be * (not displayed) on some networks (e.g. Undernet) if the bot splits into a +k channel unopped
        if {$key == "*"} {return 0}
        putbot $frombot "thekey $chan $key"
        if {$bop_log >= 1} {
          putlog "botnetop: gave key for $chan to $frombot"
        }
      }
    }
    "wantinvite" {
      if {![botisop $chan]} {return 0}
      set fromnick [lindex [split $arg] 1]
      if {$bop_icheck && $fromhost != ""} {
        if {![info exists bop_who($fromnick)]} {
          set bop_who($fromnick) "$chan $frombot $fromhost"
          utimer 60 [list bop_whounset $fromnick]
        }
        putserv "WHO $fromnick"
      } else {
        putserv "INVITE $fromnick $chan"
        if {$bop_log >= 1} {
          if {$fromnick != $frombot} {
            putlog "botnetop: invited $frombot (using nick $fromnick) to $chan"
          } else {
            putlog "botnetop: invited $frombot to $chan"
          }
        }
      }
    }
    "wantlimit" {
      if {![botisop $chan]} {return 0}
      if {[info commands cl_priority] != "" && ![info exists bop_didlimit]} {
        if {$bop_log >= 1} {
          putlog "botnetop: adjusting limit on $chan as requested by $frombot"
        }
        cl_dolimit "" 0
        # calling cl_dolimit multiple times within a short period can result in multiple limit changes because of mode queue delays, hence the following bloat
        set bop_didlimit 1
        utimer 10 [list unset bop_didlimit]
      }
      # must be called even if chanlimit.tcl is present in case channel is excluded from chanlimit or cl_priority bot is lagged
      # delay to allow some time for bots with chanlimit.tcl to raise limit first, can also lessen flooding a bit in any case
      utimer [expr {10 + [rand 11]}] [list bop_raiselimit $chan $frombot]
    }
    "wantunban" {
      if {![botisop $chan]} {return 0}
      foreach ban [chanbans $chan] {
        if {[string match [string tolower [lindex $ban 0]] [string tolower $fromhost]]} {
          pushmode $chan -b [lindex $ban 0]
          if {$bop_log >= 1} {
            putlog "botnetop: unbanned $frombot on $chan"
          }
        }
      }
    }
  }
  return 0
}

proc bop_raiselimit {chan frombot} {
  global bop_log
  if {[string match *l* [lindex [split [getchanmode $chan]] 0]]} {
    set currlimit [string range [getchanmode $chan] [expr [string last " " [getchanmode $chan]] + 1] end]
    if {[llength [chanlist $chan]] >= $currlimit} {
      pushmode $chan +l [expr [llength [chanlist $chan]] + 1]
      if {$bop_log >= 1} {
        putlog "botnetop: raised limit on $chan as requested by $frombot"
      }
    }
  }
  return 0
}

proc bop_who {from keyword arg} {
  global bop_log bop_who
  set fromnick [lindex [split $arg] 5]
  if {[info exists bop_who($fromnick)]} {
    set chan [lindex [split $bop_who($fromnick)] 0] ; set frombot [lindex [split $bop_who($fromnick)] 1] ; set fromhost [lindex [split $bop_who($fromnick)] 2]
    unset bop_who($fromnick)
    if {$fromhost == [string trimleft [lindex [split $arg] 2]@[lindex [split $arg] 3] "~+-^="]} {
      putserv "INVITE $fromnick $chan"
      if {$bop_log >= 1} {
        if {$fromnick != $frombot} {
          putlog "botnetop: invited $frombot (using nick $fromnick) to $chan"
        } else {
          putlog "botnetop: invited $frombot to $chan"
        }
      }
    }
  }
  return 0
}

proc bop_whounset {fromnick} {
  global bop_who
  if {[info exists bop_who($fromnick)]} {
    unset bop_who($fromnick)
  }
  return
}

proc bop_joinkey {frombot cmd arg} {
  global bop_kjoin
  set chan [lindex [split $arg] 0] ; set stlchan [string tolower $chan]
  if {[botonchan $chan] || $bop_kjoin($stlchan)} {return 0}
  putserv "JOIN $chan [lindex [split $arg] 1]"
  set bop_kjoin($stlchan) 1
  utimer 10 [list set bop_kjoin($stlchan) 0]
  return 0
}

proc bop_lowbots {chan} {
  global botnick
  set bots 1
  foreach bot [chanlist $chan b] {
    if {$bot != $botnick && [isop $bot $chan]} {
      incr bots
    }
  }
  if {$bots < 3} {return 1}
  return 0
}

proc bop_opreqsreset {stlchan} {
  global bop_opreqs
  set bop_opreqs($stlchan) 0
  return
}

proc bop_setneed {chan} {
  global bop_kjoin bop_needk bop_needi bop_needl bop_needu bop_opreqs numversion
  set stlchan [string tolower $chan]
  set bop_opreqs($stlchan) 0 ; set bop_kjoin($stlchan) 0
  set bop_needk($stlchan) 0 ; set bop_needi($stlchan) 0
  set bop_needl($stlchan) 0 ; set bop_needu($stlchan) 0
  if {$numversion < 1060000} {
    channel set $chan need-op [split "bop_reqop $chan op"]
    channel set $chan need-key [split "bop_letmein $chan key"]
    channel set $chan need-invite [split "bop_letmein $chan invite"]
    channel set $chan need-limit [split "bop_letmein $chan limit"]
    channel set $chan need-unban [split "bop_letmein $chan unban"]
  }
  return
}

proc bop_unsetneed {nick uhost hand chan {msg ""}} {
  global bop_kjoin bop_needk bop_needi bop_needl bop_needu bop_opreqs botnick
  if {$nick == $botnick && ![validchan $chan]} {
    set stlchan [string tolower $chan]
    catch {unset bop_opreqs($stlchan)} ; catch {unset bop_kjoin($stlchan)}
    catch {unset bop_needk($stlchan)} ; catch {unset bop_needi($stlchan)}
    catch {unset bop_needl($stlchan)} ; catch {unset bop_needu($stlchan)}
  }
  return 0
}

proc bop_clearneeds {} {
  foreach chan [channels] {
    channel set $chan need-op ""
    channel set $chan need-invite ""
    channel set $chan need-key ""
    channel set $chan need-limit ""
    channel set $chan need-unban ""
  }
  bop_settimer
  return
}

proc bop_settimer {} {
  foreach chan [channels] {
    bop_setneed $chan
  }
  if {![string match *bop_settimer* [timers]]} {
    timer 5 bop_settimer
  }
  return 0
}

if {$numversion >= 1060000} {
  bind need - * bop_reqop
}

utimer 2 bop_clearneeds

bind mode - * bop_modeop
if {!$bop_modeop} {
  unbind mode - * bop_modeop
  rename bop_modeop ""
}
bind link - * bop_linkop
if {!$bop_linkop} {
  unbind link - * bop_linkop
  rename bop_linkop ""
}
bind bot - doyawantops bop_doiwantops
bind bot - yesiwantops bop_botwantsops
bind bot - reqops bop_reqtmr
bind bot - wantkey bop_botwantsin
bind bot - wantinvite bop_botwantsin
bind bot - wantlimit bop_botwantsin
bind bot - wantunban bop_botwantsin
bind bot - thekey bop_joinkey
bind join - * bop_jointmr
bind part - * bop_unsetneed
bind raw - 352 bop_who

return "nb_info 4.10.0"
