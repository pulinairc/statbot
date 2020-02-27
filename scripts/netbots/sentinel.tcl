# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## sentinel.tcl component script ##

proc sl_helpidx {hand chan idx} {
  global sl_lockflags
  if {![matchattr $hand m$sl_lockflags] && ![matchattr $hand |m$sl_lockflags $chan]} {return 0}
  putidx $idx "sentinel.tcl commands"
  if {[matchattr $hand m|m $chan]} {
    putidx $idx " For channel masters:"
    putidx $idx "  sentinel"
  }
  if {[matchattr $hand $sl_lockflags|$sl_lockflags $chan]} {
    putidx $idx " For channel [nb_flag2word $sl_lockflags]:"
    putidx $idx "  lock          unlock"
  }
  putidx $idx " "
  return 1
}

proc sl_help {hand chan idx cmd} {
  global sl_lockflags
  switch -exact -- $cmd {
    "sentinel" {
      if {[matchattr $hand m|m $chan]} {
        putidx $idx "# sentinel"
        putwrap $idx 3 "Displays current sentinel.tcl settings."
        return 1
      }
    }
    "lock" {
      if {[matchattr $hand $sl_lockflags|$sl_lockflags $chan]} {
        putidx $idx "# lock \[channel|-all\]"
        putwrap $idx 3 "Locks the specified channel. If no channel is specified, locks the current console channel. If -all is specified, locks all channels bot is on."
        return 1
      }
    }
    "unlock" {
      if {[matchattr $hand $sl_lockflags|$sl_lockflags $chan]} {
        putidx $idx "# unlock \[channel|-all\]"
        putwrap $idx 3 "Unlocks the specified channel. If no channel is specified, unlocks the current console channel. If -all is specified, unlocks all channels the bot is on."
        return 1
      }
    }
  }
  return 0
}

lappend nb_helpidx "sl_helpidx"
set nb_help(sentinel) "sl_help"
set nb_help(lock) "sl_help"
set nb_help(unlock) "sl_help"

proc sl_ctcp {nick uhost hand dest key arg} {
  global botnet-nick botnick realname sl_ban sl_bflooded sl_bcflood sl_bcqueue sl_bxjointime sl_bxmachine sl_bxonestack sl_bxsimul sl_bxsystem sl_bxversion sl_bxwhoami sl_ccbanhost sl_ccbannick sl_ccflood sl_ccqueue sl_flooded sl_locked sl_note
  set chan [string tolower $dest]
  if {[lsearch -exact $sl_ccflood 0] == -1 && [validchan $chan] && ![isop $nick $chan]} {
    if {$nick == $botnick} {return 0}
    if {$sl_ban && !$sl_locked($chan) && ![matchattr $hand f|f $chan]} {
      lappend sl_ccbannick($chan) $nick ; lappend sl_ccbanhost($chan) [string tolower $uhost]
      utimer [lindex $sl_ccflood 1] [list sl_ccbanqueue $chan]
    }
    if {$sl_flooded($chan)} {return 1}
    incr sl_ccqueue($chan)
    utimer [lindex $sl_ccflood 1] [list sl_ccqueuereset $chan]
    if {$sl_ccqueue($chan) >= [lindex $sl_ccflood 0]} {
      sl_lock $chan "CTCP flood" ${botnet-nick} ; return 1
    }
    if {$sl_bflooded} {return 1}
  } elseif {[lindex $sl_bcflood 0] && $dest == $botnick} {
    if {$sl_bflooded} {
      sl_ignore [string tolower $uhost] $hand "CTCP flooder" ; return 1
    }
    incr sl_bcqueue
    utimer [lindex $sl_bcflood 1] {incr sl_bcqueue -1}
    if {$sl_bcqueue >= [lindex $sl_bcflood 0]} {
      putlog "sentinel: CTCP flood detected on me! Stopped answering CTCPs temporarily."
      set sl_bflooded 1
      utimer [lindex $sl_bcflood 1] {set sl_bflooded 0}
      if {[info commands sendnote] != ""} {
        foreach recipient $sl_note {
          if {[validuser $recipient]} {
            sendnote SENTINEL $recipient "Bot was CTCP flooded."
          }
        }
      }
      nb_sendcmd * rbroadcast "sentinel: CTCP flood detected on me!"
      return 1
    }
    if {$hand == "*"} {
      nb_sendcmd * rbroadcast "CTCP from $nick!$uhost: $key [string range $arg 0 400]"
    }
  }

  if {!$sl_bxsimul} {return 0}
  if {$sl_bxonestack} {return 1}
  set sl_bxonestack 1 ; utimer 2 {set sl_bxonestack 0}
  switch -exact -- $key {
    "CLIENTINFO" {
      set bxcmd [string toupper $arg]
      switch -exact -- $bxcmd {
        "" {putserv "NOTICE $nick :\001CLIENTINFO SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN IDENT XLINK UPTIME  :Use CLIENTINFO <COMMAND> to get more specific information\001"}
        "SED" {putserv "NOTICE $nick :\001CLIENTINFO SED contains simple_encrypted_data\001"}
        "UTC" {putserv "NOTICE $nick :\001CLIENTINFO UTC substitutes the local timezone\001"}
        "ACTION" {putserv "NOTICE $nick :\001CLIENTINFO ACTION contains action descriptions for atmosphere\001"}
        "DCC" {putserv "NOTICE $nick :\001CLIENTINFO DCC requests a direct_client_connection\001"}
        "CDCC" {putserv "NOTICE $nick :\001CLIENTINFO CDCC checks cdcc info for you\001"}
        "BDCC" {putserv "NOTICE $nick :\001CLIENTINFO BDCC checks cdcc info for you\001"}
        "XDCC" {putserv "NOTICE $nick :\001CLIENTINFO XDCC checks cdcc info for you\001"}
        "VERSION" {putserv "NOTICE $nick :\001CLIENTINFO VERSION shows client type, version and environment\001"}
        "CLIENTINFO" {putserv "NOTICE $nick :\001CLIENTINFO CLIENTINFO gives information about available CTCP commands\001"}
        "USERINFO" {putserv "NOTICE $nick :\001CLIENTINFO USERINFO returns user settable information\001"}
        "ERRMSG" {putserv "NOTICE $nick :\001CLIENTINFO ERRMSG returns error messages\001"}
        "FINGER" {putserv "NOTICE $nick :\001CLIENTINFO FINGER shows real name, login name and idle time of user\001"}
        "TIME" {putserv "NOTICE $nick :\001CLIENTINFO TIME tells you the time on the user's host\001"}
        "PING" {putserv "NOTICE $nick :\001CLIENTINFO PING returns the arguments it receives\001"}
        "ECHO" {putserv "NOTICE $nick :\001CLIENTINFO ECHO returns the arguments it receives\001"}
        "INVITE" {putserv "NOTICE $nick :\001CLIENTINFO INVITE invite to channel specified\001"}
        "WHOAMI" {putserv "NOTICE $nick :\001CLIENTINFO WHOAMI user list information\001"}
        "OP" {putserv "NOTICE $nick :\001CLIENTINFO OP ops the person if on userlist\001"}
        "OPS" {putserv "NOTICE $nick :\001CLIENTINFO OPS ops the person if on userlist\001"}
        "UNBAN" {putserv "NOTICE $nick :\001CLIENTINFO UNBAN unbans the person from channel\001"}
        "IDENT" {putserv "NOTICE $nick :\001CLIENTINFO IDENT change userhost of userlist\001"}
        "XLINK" {putserv "NOTICE $nick :\001CLIENTINFO XLINK x-filez rule\001"}
        "UPTIME" {putserv "NOTICE $nick :\001CLIENTINFO UPTIME my uptime\001"}
        "default" {putserv "NOTICE $nick :\001ERRMSG CLIENTINFO: $arg is not a valid function\001"}
      }
      return 1
    }
    "VERSION" {
      putserv "NOTICE $nick :\001VERSION \002BitchX-$sl_bxversion\002 by panasync \002-\002 $sl_bxsystem :\002 Keep it to yourself!\002\001"
      return 1
    }
    "USERINFO" {
      putserv "NOTICE $nick :\001USERINFO \001"
      return 1
    }
    "FINGER" {
      putserv "NOTICE $nick :\001FINGER $realname ($sl_bxwhoami@$sl_bxmachine) Idle [expr [unixtime] - $sl_bxjointime] seconds\001"
      return 1
    }
    "PING" {
      putserv "NOTICE $nick :\001PING $arg\001"
      return 1
    }
    "ECHO" {
      if {[validchan $chan]} {return 1}
      putserv "NOTICE $nick :\001ECHO [string range $arg 0 59]\001"
      return 1
    }
    "ERRMSG" {
      if {[validchan $chan]} {return 1}
      putserv "NOTICE $nick :\001ERRMSG [string range $arg 0 59]\001"
      return 1
    }
    "INVITE" {
      if {$arg == "" || [validchan $chan]} {return 1}
      set chanarg [lindex [split $arg] 0]
      if {((($sl_bxversion == "75p1+") && ([string trim [string index $chanarg 0] "#+&"] == "")) || (($sl_bxversion == "75p3+") && ([string trim [string index $chanarg 0] "#+&!"] == "")))} {
        if {[validchan $chanarg]} {
          putserv "NOTICE $nick :\002BitchX\002: Access Denied"
        } else {
          putserv "NOTICE $nick :\002BitchX\002: I'm not on that channel"
        }
      }
      return 1
    }
    "WHOAMI" {
      if {[validchan $chan]} {return 1}
      putserv "NOTICE $nick :\002BitchX\002: Access Denied"
      return 1
    }
    "OP" -
    "OPS" {
      if {$arg == "" || [validchan $chan]} {return 1}
      putserv "NOTICE $nick :\002BitchX\002: I'm not on [lindex [split $arg] 0], or I'm not opped"
      return 1
    }
    "UNBAN" {
      if {$arg == "" || [validchan $chan]} {return 1}
      if {[validchan [lindex [split $arg] 0]]} {
        putserv "NOTICE $nick :\002BitchX\002: Access Denied"
      } else {
        putserv "NOTICE $nick :\002BitchX\002: I'm not on that channel"
      }
      return 1
    }
  }
  return 0
}

proc sl_bmflood {nick uhost hand text} {
  global nb_castfilter sl_bmflood sl_bflooded sl_bmqueue sl_note
  if {[matchattr $hand b] && [string tolower [lindex [split $text] 0]] == "go"} {return 0}
  if {$sl_bflooded} {
    sl_ignore [string tolower $uhost] $hand "MSG flooder" ; return 0
  }
  incr sl_bmqueue
  utimer [lindex $sl_bmflood 1] {incr sl_bmqueue -1}
  if {$sl_bmqueue >= [lindex $sl_bmflood 0]} {
    putlog "sentinel: MSG flood detected on me! Stopped answering MSGs temporarily."
    set sl_bflooded 1
    utimer [lindex $sl_bmflood 1] {set sl_bflooded 0}
    if {[info commands sendnote] != ""} {
      foreach recipient $sl_note {
        if {[validuser $recipient]} {
          sendnote SENTINEL $recipient "Bot was MSG flooded."
        }
      }
    }
    nb_sendcmd * rbroadcast "sentinel: MSG flood detected on me!"
    return 0
  }
  if {!$sl_bflooded && $hand == "*"} {
    if {[lsearch -exact $nb_castfilter [string tolower [lindex [split $text] 0]]] != -1} {
      nb_sendcmd * rbroadcast "MSG from $nick!$uhost: [lindex [split $text] 0] .."
    } else {
      nb_sendcmd * rbroadcast "MSG from $nick!$uhost: [string range $text 0 399]"
    }
  }
  return 0
}

proc sl_avflood {from keyword arg} {
  global botnet-nick botnick sl_ban sl_avbanhost sl_avbannick sl_avflood sl_avqueue sl_flooded sl_locked sl_txflood sl_txqueue
  set arg [split $arg]
  set chan [string tolower [lindex $arg 0]]
  if {![validchan $chan]} {return 0}
  set nick [lindex [split $from !] 0]
  if {$nick == $botnick || $nick == "" || [string match *.* $nick]} {return 0}
  if {![onchan $nick $chan] || [isop $nick $chan]} {return 0}
  if {!$sl_flooded($chan) && [lsearch -exact $sl_txflood 0] == -1} {
    incr sl_txqueue($chan)
    if {$sl_txqueue($chan) >= [lindex $sl_txflood 0]} {
      sl_lock $chan "LINE flood" ${botnet-nick}
    }
  }
  set text [join [lrange $arg 1 end]]
  if {[string length [set floodtype [sl_checkaval $keyword $text]]] && [lsearch -exact $sl_avflood 0] == -1} {
    set uhost [string trimleft [getchanhost $nick $chan] "~+-^="]
    set hand [nick2hand $nick $chan]
    if {$sl_ban && !$sl_locked($chan) && $nick != $botnick && ![matchattr $hand f|f $chan]} {
      lappend sl_avbannick($chan) $nick ; lappend sl_avbanhost($chan) [string tolower $uhost]
      utimer [lindex $sl_avflood 1] [list sl_avbanqueue $chan]
    }
    if {$sl_flooded($chan)} {return 0}
    incr sl_avqueue($chan)
    utimer [lindex $sl_avflood 1] [list sl_avqueuereset $chan]
    if {$sl_avqueue($chan) >= [lindex $sl_avflood 0]} {
      sl_lock $chan "TEXT ($floodtype) flood" ${botnet-nick}
    }
  }
  return 0
}

# proc now covers criteria for PRIVMSGs and NOTICEs
proc sl_checkaval {keyword text} {
  global sl_nclength sl_tsunami sl_txlength
  if {$sl_txlength && [string equal $keyword "PRIVMSG"] && [string length $text] >= $sl_txlength} {
    return "length"
  }
  if {$sl_nclength && [string equal $keyword "NOTICE"]} {
    if {$sl_nclength == 1 || [string length $text] >= $sl_nclength} {
      return "notice"
    }
  }
  if {$sl_tsunami} {
    if {[regsub -all -- "\001|\007" $text "" temp] >= 3} {
      return "avalanche"
    }
    if {[regsub -all -- "\002|\003|\017|\026|\037" $text "" temp] >= $sl_tsunami} {
      return "tsunami"
    }
  }
  return ""
}

proc sl_nkflood {nick uhost hand chan newnick} {
  global botnet-nick botnick sl_ban sl_banmax sl_flooded sl_globalban sl_locked sl_nickkick sl_nkbanhost sl_nkflood sl_nkflooding sl_nkqueue
  if {[string equal $chan "*"]} {return 0}
  set chan [string tolower $chan]
  if {[isop $newnick $chan]} {return 0}
  if {$sl_ban && !$sl_locked($chan) && $nick != $botnick && ![matchattr $hand f|f $chan]} {
    lappend sl_nkbanhost($chan) [string tolower $uhost]
    utimer [lindex $sl_nkflood 1] [list sl_nkbanqueue $chan]
  }
  if {!$sl_nickkick && $sl_flooded($chan) && $sl_locked($chan)} {
    putserv "KICK $chan $newnick :NICK flooder"
    set sl_nickkick 1 ; set sl_nkflooding($chan) [unixtime]
    if {$sl_ban} {
      set bhost [string tolower [sl_masktype $uhost]]
      if {$sl_globalban} {
        if {[llength [banlist]] < $sl_banmax && ![isban $bhost] && ![matchban $bhost]} {
          newban $bhost sentinel "NICK flooder" $sl_ban
        }
      } else {
        if {[llength [banlist $chan]] < $sl_banmax && ![isban $bhost $chan] && ![matchban $bhost $chan]} {
          newchanban $chan $bhost sentinel "NICK flooder" $sl_ban
        }
      }
    }
    utimer [expr [rand 2] + 3] {set sl_nickkick 0}
    return 0
  }
  if {$sl_flooded($chan)} {return 0}
  incr sl_nkqueue($chan)
  utimer [lindex $sl_nkflood 1] [list sl_nkqueuereset $chan]
  if {$sl_nkqueue($chan) >= [lindex $sl_nkflood 0]} {
    sl_lock $chan "NICK flood" ${botnet-nick}
  }
  return 0
}

proc sl_jflood {nick uhost hand chan} {
  global botnet-nick botnick sl_ban sl_banmax sl_boban sl_bobanhost sl_bobannick sl_boflood sl_boqueue sl_flooded sl_globalban sl_jbanhost sl_jbannick sl_jflood sl_jqueue sl_locked sl_pqueue
  if {$nick == $botnick} {
    sl_setarray $chan
  } else {
    set ihost [string tolower [sl_masktype $uhost]]
    if {[isignore $ihost]} {
      killignore $ihost
    }
    set chan [string tolower $chan]
    if {[lsearch -exact $sl_boflood 0] == -1 && [sl_checkbogus [lindex [split $uhost @] 0]]} {
      if {!$sl_locked($chan) && ![matchattr $hand f|f $chan]} {
        set bhost [string tolower [sl_masktype $uhost]]
        if {$sl_boban && [botisop $chan] && !$sl_flooded($chan)} {
          putserv "KICK $chan $nick :BOGUS username"
          if {$sl_globalban} {
            if {[llength [banlist]] < $sl_banmax && ![isban $bhost] && ![matchban $bhost]} {
              newban $bhost sentinel "BOGUS username" $sl_boban
            }
          } else {
            if {[llength [banlist $chan]] < $sl_banmax && ![isban $bhost $chan] && ![matchban $bhost $chan]} {
              newchanban $chan $bhost sentinel "BOGUS username" $sl_boban
            }
          }
        }
        if {$sl_ban} {
          lappend sl_bobannick($chan) $nick ; lappend sl_bobanhost($chan) [string tolower $uhost]
          utimer [lindex $sl_boflood 1] [list sl_bobanqueue $chan]
        }
      }
      if {!$sl_flooded($chan)} {
        incr sl_boqueue($chan)
        utimer [lindex $sl_boflood 1] [list sl_boqueuereset $chan]
        if {$sl_boqueue($chan) >= [lindex $sl_boflood 0]} {
          sl_lock $chan "BOGUS joins" ${botnet-nick}
        }
      }
    }
    if {[lsearch -exact $sl_jflood 0] == -1} {
      if {$sl_ban && !$sl_locked($chan) && ![matchattr $hand f|f $chan]} {
        lappend sl_jbannick($chan) $nick ; lappend sl_jbanhost($chan) [string tolower $uhost]
        utimer [lindex $sl_jflood 1] [list sl_jbanqueue $chan]
      }
      if {$sl_flooded($chan)} {return 0}
      incr sl_jqueue($chan)
      utimer [lindex $sl_jflood 1] [list sl_jqueuereset $chan]
      if {$sl_jqueue($chan) >= [lindex $sl_jflood 0] && $sl_pqueue($chan) >= [lindex $sl_jflood 0]} {
        sl_lock $chan "JOIN-PART flood" ${botnet-nick}
      }
    }
  }
  return 0
}

proc sl_checkbogus {ident} {
  if {[regsub -all -- "\[^\041-\176\]" $ident "" temp] >= 1} {return 1}
  return 0
}

proc sl_pflood {nick uhost hand chan {msg ""}} {
  global botnick sl_ban sl_flooded sl_jflood sl_locked sl_pbanhost sl_pbannick sl_pqueue
  if {[lsearch -exact $sl_jflood 0] != -1} {return 0}
  if {$nick == $botnick} {
    if {![validchan $chan]} {
      timer 5 [list sl_unsetarray $chan]
    }
    return 0
  }
  set chan [string tolower $chan]
  if {$sl_ban && !$sl_locked($chan) && ![matchattr $hand f|f $chan]} {
    lappend sl_pbannick($chan) $nick ; lappend sl_pbanhost($chan) [string tolower $uhost]
    utimer [lindex $sl_jflood 1] [list sl_pbanqueue $chan]
  }
  if {$sl_flooded($chan)} {return 0}
  incr sl_pqueue($chan)
  utimer [lindex $sl_jflood 1] [list sl_pqueuereset $chan]
  return 0
}

proc sl_pfloodk {nick uhost hand chan kicked reason} {
  global botnick sl_flooded sl_jflood sl_pqueue
  if {[lsearch -exact $sl_jflood 0] != -1} {return 0}
  if {$kicked == $botnick} {return 0}
  set chan [string tolower $chan]
  if {$sl_flooded($chan)} {return 0}
  incr sl_pqueue($chan)
  utimer [lindex $sl_jflood 1] [list sl_pqueuereset $chan]
  return 0
}

proc sl_lock {chan flood detected} {
  global sl_bflooded sl_cfnotice sl_flooded sl_locktimes sl_note
  if {[isbotnetnick $detected]} {
    set sl_flooded($chan) 1 ; set sl_bflooded 1
    if {[botisop $chan]} {
      sl_quicklock $chan
      nb_killutimer "sl_unlock $chan*"
      nb_killutimer "set sl_bflooded 0"
      foreach lockmode $sl_locktimes {
        if {[lindex $lockmode 1]} {
          utimer [lindex $lockmode 1] [list sl_unlock $chan [lindex $lockmode 0]]
        }
      }
      utimer 120 {set sl_bflooded 0}
      putlog "sentinel: $flood detected on $chan! Channel locked temporarily."
      if {$sl_cfnotice != ""} {
        puthelp "NOTICE $chan :$sl_cfnotice"
      }
    } else {
      putlog "sentinel: $flood detected on $chan! Cannot lock channel because I'm not opped."
      utimer 120 {set sl_bflooded 0}
    }
  } else {
    putlog "sentinel: $flood detected by $detected on $chan!"
  }
  if {[info commands sendnote] != ""} {
    foreach recipient $sl_note {
      if {[validuser $recipient]} {
        if {[isbotnetnick $detected]} {
          sendnote SENTINEL $recipient "$flood detected on $chan."
        } else {
          sendnote SENTINEL $recipient "$flood detected by $detected on $chan."
        }
      }
    }
  }
  if {[isbotnetnick $detected]} {
    nb_sendcmd * rlock [list $chan $flood]
  }
  return 0
}

proc nb_sl_lock {frombot arg} {
  sl_lock [lindex $arg 0] [lindex $arg 1] $frombot
  return 0
}

proc sl_unlock {chan {umodes ""}} {
  global sl_bflooded sl_bfmaxbans sl_flooded sl_locktimes sl_nkflooding
  if {[expr [unixtime] - $sl_nkflooding($chan)] < 12} {
    putlog "sentinel: nick flooding still in progress on $chan - not unlocking yet.."
    set sl_flooded($chan) 1 ; set sl_bflooded 1
    nb_killutimer "sl_unlock $chan*"
    nb_killutimer "set sl_bflooded 0"
    foreach lockmode $sl_locktimes {
      if {[lindex $lockmode 1]} {
        utimer [lindex $lockmode 1] [list sl_unlock $chan [lindex $lockmode 0]]
      }
    }
    utimer 120 {set sl_bflooded 0}
  } else {
    set sl_flooded($chan) 0
    if {![botisop $chan]} {return 0}
    if {$umodes == ""} {
      putlog "sentinel: flood was small, performing early unlock.."
      set umodes [sl_lockmodes]
    }
    foreach umode [split $umodes ""] {
      if {[string equal $umode i] && $sl_bfmaxbans && [llength [chanbans $chan]] >= $sl_bfmaxbans} {
        putlog "sentinel: not removing +i on $chan due to full ban list."
        continue
      }
      if {[string match *$umode* [lindex [split [getchanmode $chan]] 0]]} {
         pushmode $chan -$umode
         append uremoved $umode
      }
    }
    if {[info exists uremoved]} {
      putlog "sentinel: removed +$uremoved on $chan"
    }
  }
  return 0
}

proc sl_mode {nick uhost hand chan mode victim} {
  global botnick sl_ban sl_bfmaxbans sl_bfnotice sl_bfull sl_flooded sl_locked sl_note sl_unlocked
  set chan [string tolower $chan]
  if {$mode == "+b" && $sl_bfmaxbans && !$sl_bfull($chan) && ![string match *i* [lindex [split [getchanmode $chan]] 0]] && [botisop $chan] && [llength [chanbans $chan]] >= $sl_bfmaxbans} {
    putserv "MODE $chan +i"
    set sl_bfull($chan) 1
    utimer 5 [list set sl_bfull($chan) 0]
    putlog "sentinel: locked $chan due to full ban list!"
    if {$sl_bfnotice != ""} {
      puthelp "NOTICE $chan :$sl_bfnotice"
    }
    if {[info commands sendnote] != ""} {
      foreach recipient $sl_note {
        if {[validuser $recipient]} {
          sendnote SENTINEL $recipient "Locked $chan due to full ban list."
        }
      }
    }
  } elseif {$mode == "+i" && $sl_flooded($chan)} {
    set sl_locked($chan) 1
    if {$sl_ban} {
      nb_killutimer "sl_*banqueue $chan"
      utimer 7 [list sl_dokicks $chan] ; utimer 16 [list sl_setbans $chan]
    }
  } elseif {$mode == "-i" || $mode == "-m"} {
    # lock modes other than +i and +m are considered auxiliary, so the channel isn't considered "unlocked" if they're removed
    set sl_locked($chan) 0
    set sl_unlocked($chan) [unixtime]
    if {$sl_flooded($chan)} {
      set sl_flooded($chan) 0
      if {$mode == "-i"} {
        nb_killutimer "sl_unlock $chan i"
      } else {
        nb_killutimer "sl_unlock $chan m"
      }
      nb_killutimer "sl_unlock $chan"
      if {$nick != $botnick} {
        putlog "sentinel: $chan unlocked by $nick"
      }
    }
  }
  return 0
}

proc sl_dokicks {chan} {
  global sl_avbannick sl_bobannick sl_ccbannick sl_kflooders sl_jbannick sl_pbannick
  if {![botisop $chan]} {return 0}
  set sl_kflooders 0
  sl_kick $chan $sl_ccbannick($chan) "CTCP flooder" ; set sl_ccbannick($chan) ""
  sl_kick $chan $sl_avbannick($chan) "TEXT flooder" ; set sl_avbannick($chan) ""
  sl_kick $chan $sl_bobannick($chan) "BOGUS username" ; set sl_bobannick($chan) ""
  set jklist $sl_jbannick($chan) ; set pklist $sl_pbannick($chan)
  if {$jklist != "" && $pklist != ""} {
    set klist ""
    foreach nick $jklist {
      if {[lsearch -exact $pklist $nick] != -1} {
        lappend klist $nick
      }
    }
    sl_kick $chan $klist "JOIN-PART flooder"
  }
  set sl_jbannick($chan) "" ; set sl_pbannick($chan) ""
  return 0
}

proc sl_kick {chan klist reason} {
  global sl_kflooders sl_kicks
  if {$klist != ""} {
    set kicklist ""
    foreach nick $klist {
      if {[lsearch -exact $kicklist $nick] == -1} {
        lappend kicklist $nick
      }
    }
    unset nick
    incr sl_kflooders [llength $kicklist]
    foreach nick $kicklist {
      if {[onchan $nick $chan] && ![onchansplit $nick $chan]} {
        lappend ksend $nick
        if {[llength $ksend] >= $sl_kicks} {
          putserv "KICK $chan [join $ksend ,] :$reason"
          unset ksend
        }
      }
    }
    if {[info exists ksend]} {
      putserv "KICK $chan [join $ksend ,] :$reason"
    }
  }
  return 0
}

proc sl_setbans {chan} {
  global sl_avbanhost sl_bobanhost sl_ccbanhost sl_kflooders sl_jbanhost sl_nkbanhost sl_pbanhost sl_shortlock sl_unlocked sl_wideban
  if {![botonchan $chan]} {return 0}
  set sl_ccbanhost($chan) [sl_dfilter $sl_ccbanhost($chan)]
  set sl_avbanhost($chan) [sl_dfilter $sl_avbanhost($chan)]
  set sl_nkbanhost($chan) [sl_dfilter $sl_nkbanhost($chan)]
  set sl_bobanhost($chan) [sl_dfilter $sl_bobanhost($chan)]
  set sl_jbanhost($chan) [sl_dfilter $sl_jbanhost($chan)]
  set sl_pbanhost($chan) [sl_dfilter $sl_pbanhost($chan)]
  set blist ""
  if {$sl_jbanhost($chan) != "" && $sl_pbanhost($chan) != ""} {
    foreach bhost $sl_jbanhost($chan) {
      if {[lsearch -exact $sl_pbanhost($chan) $bhost] != -1} {
        lappend blist $bhost
      }
    }
  }
  set allbans [sl_dfilter [concat $sl_ccbanhost($chan) $sl_avbanhost($chan) $sl_nkbanhost($chan) $sl_bobanhost($chan) $blist]]
  if {$sl_wideban} {
    sl_ban $chan [sl_dcheck $allbans] "MULTIPLE IDENT/HOST flooders"
  }
  sl_ban $chan $sl_ccbanhost($chan) "CTCP flooder" ; set sl_ccbanhost($chan) ""
  sl_ban $chan $sl_avbanhost($chan) "TEXT flooder" ; set sl_avbanhost($chan) ""
  sl_ban $chan $sl_nkbanhost($chan) "NICK flooder" ; set sl_nkbanhost($chan) ""
  sl_ban $chan $sl_bobanhost($chan) "BOGUS username" ; set sl_bobanhost($chan) ""
  sl_ban $chan $blist "JOIN-PART flooder"
  set sl_jbanhost($chan) "" ; set sl_pbanhost($chan) ""
  if {$sl_shortlock && $sl_kflooders <= 2 && [llength $allbans] <= 2 && [expr [unixtime] - $sl_unlocked($chan)] > 120} {
    nb_killutimer "sl_unlock $chan*"
    utimer 10 [list sl_unlock $chan]
  }
  return 0
}

proc sl_dfilter {list} {
  set newlist ""
  foreach item $list {
    if {[lsearch -exact $newlist $item] == -1} {
      lappend newlist $item
    }
  }
  return $newlist
}

proc sl_dcheck {bhosts} {
  set blist ""
  foreach bhost $bhosts {
    set baddr [lindex [split [maskhost $bhost] "@"] 1]
    set bident [string trimleft [lindex [split $bhost "@"] 0] "~"]
    if {![info exists baddrs($baddr)]} {
      set baddrs($baddr) 1
    } else {
      incr baddrs($baddr)
    }
    if {![info exists bidents($bident)]} {
      set bidents($bident) 1
    } else {
      incr bidents($bident)
    }
  }
  foreach baddr [array names baddrs] {
    if {$baddrs($baddr) >= 2} {
      lappend blist *!*@$baddr
    }
  }
  foreach bident [array names bidents] {
    if {$bidents($bident) >= 2} {
      lappend blist *!*$bident@*
    }
  }
  return $blist
}

proc sl_ban {chan blist reason} {
  global sl_ban sl_banmax sl_globalban
  if {$blist != ""} {
    if {$sl_globalban} {
      foreach bhost $blist {
        if {![string match *!* $bhost]} {
          if {[matchban *!$bhost]} {continue}
          set bhost [sl_masktype $bhost]
          if {[isban $bhost]} {continue}
        } else {
          if {[isban $bhost]} {continue}
          foreach ban [banlist] {
            if {[lindex $ban 5] == "sentinel" && [string match $bhost [string tolower [lindex $ban 0]]]} {
              killban $ban
            }
          }
        }
        if {[llength [banlist]] >= $sl_banmax} {continue}
        newban $bhost sentinel $reason $sl_ban
        putlog "sentinel: banned $bhost ($reason)"
        sl_ignore $bhost * $reason
      }
    } else {
      foreach bhost $blist {
        if {![string match *!* $bhost]} {
          if {[matchban *!$bhost $chan]} {continue}
          set bhost [sl_masktype $bhost]
          if {[isban $bhost $chan]} {continue}
        } else {
          if {[isban $bhost $chan]} {continue}
          foreach ban [banlist $chan] {
            if {[lindex $ban 5] == "sentinel" && [string match $bhost [string tolower [lindex $ban 0]]]} {
              killchanban $chan $ban
            }
          }
        }
        if {[llength [banlist $chan]] >= $sl_banmax} {continue}
        newchanban $chan $bhost sentinel $reason $sl_ban
        putlog "sentinel: banned $bhost on $chan ($reason)"
        sl_ignore $bhost * $reason
      }
    }
  }
  return 0
}

proc sl_ignore {ihost hand flood} {
  global sl_igtime
  if {$hand != "*"} {
    foreach chan [channels] {
      if {[matchattr $hand f|f $chan]} {return 0}
    }
  }
  if {![string match *!* $ihost]} {
    foreach ignore [ignorelist] {
      if {[string match [string tolower [lindex $ignore 0]] $ihost]} {
        return 0
      }
    }
    set ihost [sl_masktype $ihost]
    if {[isignore $ihost]} {return 0}
  } else {
    if {[isignore $ihost]} {return 0}
    foreach ignore [ignorelist] {
      if {[lindex $ignore 4] == "sentinel" && [string match $ihost [string tolower [lindex $ignore 0]]]} {
        killignore $ignore
      }
    }
  }
  newignore $ihost sentinel $flood $sl_igtime
  putlog "sentinel: added $ihost to ignore list ($flood)"
  return 1
}

# queuereset procs allow all queue timers to be killed easily
proc sl_ccqueuereset {chan} {
  global sl_ccqueue
  incr sl_ccqueue($chan) -1
  return 0
}

proc sl_bcqueuereset {} {
  global sl_bcqueue
  incr sl_bcqueue -1
  return 0
}

proc sl_bmqueuereset {} {
  global sl_bmqueue
  incr sl_bmqueue -1
  return 0
}

proc sl_avqueuereset {chan} {
  global sl_avqueue
  incr sl_avqueue($chan) -1
  return 0
}

proc sl_txqueuereset {} {
  global sl_txqueue sl_txflood
  foreach chan [string tolower [channels]] {
    if {[info exists sl_txqueue($chan)]} {
      set sl_txqueue($chan) 0
    }
  }
  utimer [lindex $sl_txflood 1] sl_txqueuereset
  return 0
}

proc sl_nkqueuereset {chan} {
  global sl_nkqueue
  incr sl_nkqueue($chan) -1
  return 0
}

proc sl_boqueuereset {chan} {
  global sl_boqueue
  incr sl_boqueue($chan) -1
  return 0
}

proc sl_jqueuereset {chan} {
  global sl_jqueue
  incr sl_jqueue($chan) -1
  return 0
}

proc sl_pqueuereset {chan} {
  global sl_pqueue
  incr sl_pqueue($chan) -1
  return 0
}

proc sl_ccbanqueue {chan} {
  global sl_ccbanhost sl_ccbannick
  set sl_ccbannick($chan) [lrange sl_ccbannick($chan) 1 end] ; set sl_ccbanhost($chan) [lrange sl_ccbanhost($chan) 1 end]
  return 0
}

proc sl_avbanqueue {chan} {
  global sl_avbanhost sl_avbannick
  set sl_avbannick($chan) [lrange sl_avbannick($chan) 1 end] ; set sl_avbanhost($chan) [lrange sl_avbanhost($chan) 1 end]
  return 0
}

proc sl_nkbanqueue {chan} {
  global sl_nkbanhost
  set sl_nkbanhost($chan) [lrange sl_nkbanhost($chan) 1 end]
  return 0
}

proc sl_bobanqueue {chan} {
  global sl_bobanhost sl_bobannick
  set sl_bobannick($chan) [lrange sl_bobannick($chan) 1 end] ; set sl_bobanhost($chan) [lrange sl_bobanhost($chan) 1 end]
  return 0
}

proc sl_jbanqueue {chan} {
  global sl_jbanhost sl_jbannick
  set sl_jbannick($chan) [lrange sl_jbannick($chan) 1 end] ; set sl_jbanhost($chan) [lrange sl_jbanhost($chan) 1 end]
  return 0
}

proc sl_pbanqueue {chan} {
  global sl_pbanhost sl_pbannick
  set sl_pbannick($chan) [lrange sl_pbannick($chan) 1 end] ; set sl_pbanhost($chan) [lrange sl_pbanhost($chan) 1 end]
  return 0
}

proc sl_flud {nick uhost hand type chan} {
  global sl_flooded
  set chan [string tolower $chan]
  if {[validchan $chan] && $sl_flooded($chan)} {return 1}
  return 0
}

proc sl_lc {nick uhost hand chan arg} {
  global sl_lockcmds
  set chan [string tolower $chan]
  if {![botisop $chan]} {return 0}
  if {$sl_lockcmds == 2 && ![isop $nick $chan]} {return 0}
  sl_quicklock $chan
  putlog "sentinel: channel lock requested by $hand on $chan"
  return 0
}

proc sl_uc {nick uhost hand chan arg} {
  global sl_lockcmds
  set chan [string tolower $chan]
  if {![botisop $chan]} {return 0}
  if {$sl_lockcmds == 2 && ![isop $nick $chan]} {return 0}
  putserv "MODE $chan -[sl_lockmodes]"
  putlog "sentinel: channel unlock requested by $hand on $chan"
  return 0
}

proc sl_dcclc {hand idx arg} {
  global sl_lockflags
  putcmdlog "#$hand# lock $arg"
  set chan [lindex [split $arg] 0]
  if {$chan == "-all"} {
    if {![matchattr $hand $sl_lockflags]} {
      putidx $idx "You're not global +$sl_lockflags." ; return 0
    }
    set locklist ""
    foreach chan [channels] {
      if {[botisop $chan]} {
        sl_quicklock $chan
        lappend locklist $chan
      }
    }
    putidx $idx "Locked [join $locklist ", "]"
  } else {
    if {$chan == ""} {
      set chan [lindex [console $idx] 0]
    }
    if {![validchan $chan]} {
      putidx $idx "No such channel." ; return 0
    } elseif {![matchattr $hand $sl_lockflags|$sl_lockflags $chan]} {
      putidx $idx "You're not +$sl_lockflags on $chan." ; return 0
    } elseif {![botonchan $chan]} {
      putidx $idx "I'm not on $chan" ; return 0
    } elseif {![botisop $chan]} {
      putidx $idx "I'm not opped on $chan" ; return 0
    }
    sl_quicklock $chan
    putidx $idx "Locked $chan"
  }
  return 0
}

proc sl_dccuc {hand idx arg} {
  global sl_lockflags
  putcmdlog "#$hand# unlock $arg"
  set chan [lindex [split $arg] 0]
  if {$chan == "-all"} {
    if {![matchattr $hand $sl_lockflags]} {
      putidx $idx "You're not global +$sl_lockflags." ; return 0
    }
    set locklist ""
    foreach chan [channels] {
      if {[botisop $chan]} {
        putserv "MODE $chan -[sl_lockmodes]"
        lappend locklist $chan
      }
    }
    putidx $idx "Unlocked [join $locklist ", "]"
  } else {
    if {$chan == ""} {
      set chan [lindex [console $idx] 0]
    }
    if {![validchan $chan]} {
      putidx $idx "No such channel." ; return 0
    } elseif {![matchattr $hand $sl_lockflags|$sl_lockflags $chan]} {
      putidx $idx "You're not +$sl_lockflags on $chan." ; return 0
    } elseif {![botonchan $chan]} {
      putidx $idx "I'm not on $chan" ; return 0
    } elseif {![botisop $chan]} {
      putidx $idx "I'm not opped on $chan" ; return 0
    }
    putserv "MODE $chan -[sl_lockmodes]"
    putidx $idx "Unlocked $chan"
  }
  return 0
}

proc sl_quicklock {chan} {
  global numversion
  if {$numversion < 1050000} {
    putquick "MODE $chan +[sl_lockmodes]"
  } else {
    putquick "MODE $chan +[sl_lockmodes]" -next
  }
}

proc sl_lockmodes {} {
  global sl_locktimes
  foreach lockmode $sl_locktimes {
    append lockmodes [lindex $lockmode 0]
  }
  return $lockmodes
}

proc sl_dcc {hand idx arg} {
  global sl_avflood sl_ban sl_banmax sl_bcflood sl_boban sl_boflood sl_bmflood sl_bxsimul sl_bfmaxbans sl_ccflood sl_detectquits sl_globalban sl_igtime sl_jflood sl_kicks sl_lockcmds sl_lockflags sl_locktimes sl_nclength sl_nkflood sl_note sl_shortlock sl_tsunami sl_txflood sl_txlength
  putcmdlog "#$hand# sentinel $arg"
  putidx $idx "This bot is protected by sentinel.tcl by slennox"
  putidx $idx "Current settings"
  if {[lsearch -exact $sl_bcflood 0] != -1} {
    putidx $idx "- Bot CTCP flood:           Off"
  } else {
    putidx $idx "- Bot CTCP flood:           [lindex $sl_bcflood 0] in [lindex $sl_bcflood 1] secs"
  }
  if {[lsearch -exact $sl_bmflood 0] != -1} {
    putidx $idx "- Bot MSG flood:            Off"
  } else {
    putidx $idx "- Bot MSG flood:            [lindex $sl_bmflood 0] in [lindex $sl_bmflood 1] secs"
  }
  if {[lsearch -exact $sl_ccflood 0] != -1} {
    putidx $idx "- Channel CTCP flood:       Off"
  } else {
    putidx $idx "- Channel CTCP flood:       [lindex $sl_ccflood 0] in [lindex $sl_ccflood 1] secs"
  }
  if {[lsearch -exact $sl_avflood 0] != -1} {
    putidx $idx "- Channel TEXT flood:       Off"
  } else {
    putidx $idx "- Channel TEXT flood:       [lindex $sl_avflood 0] in [lindex $sl_avflood 1] secs"
    if {$sl_txlength} {
      putidx $idx "                            Includes PRIVMSGs over $sl_txlength chars"
    } else {
      putidx $idx "                            Doesn't include PRIVMSGs"
    }
    if {$sl_nclength == 1} {
      putidx $idx "                            Includes all NOTICEs"
    } elseif {$sl_nclength > 1} {
      putidx $idx "                            Includes NOTICEs over $sl_nclength chars"
    } else {
      putidx $idx "                            Doesn't include NOTICEs"
    }
    if {$sl_tsunami} {
      putidx $idx "                            Includes TSUNAMIs ($sl_tsunami control codes)"
      putidx $idx "                            Includes AVALANCHEs"
    } else {
      putidx $idx "                            Doesn't include TSUNAMIs or AVALANCHEs"
    }
  }
  if {[lsearch -exact $sl_boflood 0] != -1} {
    putidx $idx "- Channel BOGUS flood:      Off"
  } else {
    putidx $idx "- Channel BOGUS flood:      [lindex $sl_boflood 0] in [lindex $sl_boflood 1] secs"
  }
  if {$sl_detectquits} {
    set detectquits "quit detection ON"
  } else {
    set detectquits "quit detection OFF"
  }
  if {[lsearch -exact $sl_jflood 0] != -1} {
    putidx $idx "- Channel JOIN-PART flood:  Off"
  } else {
    putidx $idx "- Channel JOIN-PART flood:  [lindex $sl_jflood 0] in [lindex $sl_jflood 1] secs ($detectquits)"
  }
  if {[lsearch -exact $sl_nkflood 0] != -1} {
    putidx $idx "- Channel NICK flood:       Off"
  } else {
    putidx $idx "- Channel NICK flood:       [lindex $sl_nkflood 0] in [lindex $sl_nkflood 1] secs"
  }
  if {[lsearch -exact $sl_txflood 0] != -1} {
    putidx $idx "- Channel line cap:         Off"
  } else {
    putidx $idx "- Channel line cap:         [lindex $sl_txflood 0] in [lindex $sl_txflood 1] secs"
  }
  foreach lockmode $sl_locktimes {
    lappend chanlocktimes "+[lindex $lockmode 0]: [lindex $lockmode 1] s"
  }
  putidx $idx "- Channel locktimes:        [join $chanlocktimes ", "]"
  if {$sl_shortlock && $sl_ban} {
    putidx $idx "- Small flood short lock:   Active"
  } else {
    putidx $idx "- Small flood short lock:   Inactive"
  }
  if {$sl_ban && $sl_ban < 120} {
    putidx $idx "- Channel flood bans:       $sl_ban mins"
  } elseif {$sl_ban >= 120} {
    putidx $idx "- Channel flood bans:       [expr $sl_ban / 60] hrs"
  } else {
    putidx $idx "- Channel flood bans:       Disabled"
  }
  if {!$sl_boban || [lsearch -exact $sl_boflood 0] != -1} {
    putidx $idx "- Bogus username bans:      Disabled"
  } elseif {$sl_boban > 0 && $sl_boban < 120} {
    putidx $idx "- Bogus username bans:      $sl_boban mins"
  } elseif {$sl_boban >= 120} {
    putidx $idx "- Bogus username bans:      [expr $sl_boban / 60] hrs"
  }
  if {$sl_ban || [lsearch -exact $sl_boflood 0] == -1} {
    if {$sl_globalban} {
      putidx $idx "- Ban type:                 Global [sl_masktype nick@host.domain]"
    } else {
      putidx $idx "- Ban type:                 Channel-specific [sl_masktype nick@host.domain]"
    }
  }
  if {$sl_ban || [lsearch -exact $sl_boflood 0] == -1} {
    putidx $idx "- Maximum bans:             $sl_banmax"
  }
  if {$sl_igtime > 0 && $sl_igtime < 120} {
    putidx $idx "- Flooder ignores:          $sl_igtime mins"
  } elseif {$sl_igtime >= 120} {
    putidx $idx "- Flooder ignores:          [expr $sl_igtime / 60] hrs"
  } else {
    putidx $idx "- Flooder ignores:          Permanent"
  }
  if {$sl_ban} {
    putidx $idx "- Kicks per line:           $sl_kicks"
  }
  if {!$sl_bfmaxbans} {
    putidx $idx "- Maximum channel bans:     Disabled"
  } else {
    putidx $idx "- Maximum channel bans:     $sl_bfmaxbans"
  }
  if {$sl_note != ""} {
    putidx $idx "- Flood notification:       Notifying [join $sl_note ", "]"
  } else {
    putidx $idx "- Flood notification:       Off"
  }
  if {!$sl_lockcmds} {
    putidx $idx "- Public lc/uc commands:    Disabled"
  } elseif {$sl_lockcmds == 1} {
    putidx $idx "- Public lc/uc commands:    Enabled (+$sl_lockflags users, ops not required)"
  } elseif {$sl_lockcmds == 2} {
    putidx $idx "- Public lc/uc commands:    Enabled (+$sl_lockflags users, ops required)"
  }
  if {$sl_bxsimul} {
    putidx $idx "- BitchX simulation:        On"
  } elseif {!$sl_bxsimul} {
    putidx $idx "- BitchX simulation:        Off"
  }
  return 0
}

if {$sl_bxsimul} {
  bind raw - 001 sl_bxserverjoin
  if {![info exists sl_bxonestack]} {
    set sl_bxonestack 0
  }
  if {![info exists sl_bxversion]} {
    set sl_bxversion [lindex {75p1+ 75p3+} [rand 2]]
  }
  set sl_bxsystem "*IX" ; set sl_bxwhoami $username ; set sl_bxmachine ""
  catch {set sl_bxsystem [exec uname -s -r]}
  catch {set sl_bxwhoami [exec id -un]}
  catch {set sl_bxmachine [exec uname -n]}
  set sl_bxjointime [unixtime]
  proc sl_bxserverjoin {from keyword arg} {
    global sl_bxjointime sl_bxisaway
    set sl_bxjointime [unixtime] ; set sl_bxisaway 0
    return 0
  }
  proc sl_bxaway {} {
    global sl_bxjointime sl_bxisaway
    if {!$sl_bxisaway} {
      puthelp "AWAY :is away: (Auto-Away after 10 mins) \[\002BX\002-MsgLog [lindex {On Off} [rand 2]]\]"
      set sl_bxisaway 1
    } else {
      puthelp "AWAY"
      set sl_bxisaway 0 ; set sl_bxjointime [unixtime]
    }
    if {![string match *sl_bxaway* [timers]]} {
      timer [expr [rand 300] + 10] sl_bxaway
    }
    return 0
  }
  if {![info exists sl_bxisaway]} {
    set sl_bxisaway 0
  }
  if {![string match *sl_bxaway* [timers]]} {
    timer [expr [rand 300] + 10] sl_bxaway
  }
}

proc sl_setarray {chan} {
  global sl_avbanhost sl_avbannick sl_avqueue sl_bfull sl_bobanhost sl_bobannick sl_boqueue sl_ccbanhost sl_ccbannick sl_ccqueue sl_flooded sl_jbanhost sl_jbannick sl_jqueue sl_locked sl_nkbanhost sl_nkflooding sl_nkqueue sl_pbanhost sl_pbannick sl_pqueue sl_txqueue sl_unlocked
  set chan [string tolower $chan]
  nb_killutimer "incr sl_*queue($chan) -1"
  nb_killutimer "sl_*banqueue $chan"
  nb_killutimer "sl_*queuereset $chan"
  set sl_flooded($chan) 0 ; set sl_locked($chan) 0 ; set sl_unlocked($chan) [unixtime]
  set sl_nkflooding($chan) [unixtime]
  set sl_ccqueue($chan) 0 ; set sl_ccbanhost($chan) "" ; set sl_ccbannick($chan) ""
  set sl_avqueue($chan) 0 ; set sl_avbanhost($chan) "" ; set sl_avbannick($chan) ""
  set sl_txqueue($chan) 0
  set sl_nkqueue($chan) 0 ; set sl_nkbanhost($chan) ""
  set sl_boqueue($chan) 0 ; set sl_bobanhost($chan) "" ; set sl_bobannick($chan) ""
  set sl_jqueue($chan) 0 ; set sl_jbanhost($chan) "" ; set sl_jbannick($chan) ""
  set sl_pqueue($chan) 0 ; set sl_pbanhost($chan) "" ; set sl_pbannick($chan) ""
  set sl_bfull($chan) 0
  return 0
}

proc sl_unsetarray {chan} {
  global sl_avbanhost sl_avbannick sl_avqueue sl_bfull sl_bobanhost sl_bobannick sl_boqueue sl_ccbanhost sl_ccbannick sl_ccqueue sl_flooded sl_jbanhost sl_jbannick sl_jqueue sl_locked sl_nkbanhost sl_nkflooding sl_nkqueue sl_pbanhost sl_pbannick sl_pqueue sl_txqueue sl_unlocked
  set chan [string tolower $chan]
  if {![validchan $chan] && [info exists sl_flooded($chan)]} {
    unset sl_flooded($chan) sl_locked($chan) sl_unlocked($chan) sl_nkflooding($chan) sl_ccqueue($chan) sl_ccbanhost($chan) sl_ccbannick($chan) sl_avqueue($chan) sl_avbanhost($chan) sl_avbannick($chan) sl_txqueue($chan) sl_nkqueue($chan) sl_nkbanhost($chan) sl_boqueue($chan) sl_bobanhost($chan) sl_bobannick($chan) sl_jqueue($chan) sl_jbanhost($chan) sl_jbannick($chan) sl_pqueue($chan) sl_pbanhost($chan) sl_pbannick($chan) sl_bfull($chan)
  }
  return 0
}

proc sl_settimer {} {
  foreach chan [channels] {
    sl_setarray $chan
  }
  return 0
}

proc sl_masktype {uhost} {
  global sl_masktype
  switch -exact -- $sl_masktype {
    0 {return *!*[string range $uhost [string first @ $uhost] end]}
    1 {return *!*$uhost}
    2 {return *!*[lindex [split [maskhost $uhost] "!"] 1]}
  }
  return
}

if {![info exists sl_unlocked] && ![string match *sl_settimer* [utimers]]} {
  utimer 3 sl_settimer
}

if {![info exists sl_bflooded]} {
  set sl_bflooded 0
}
if {![info exists sl_bcqueue]} {
  set sl_bcqueue 0
}
if {![info exists sl_bmqueue]} {
  set sl_bmqueue 0
}
if {![info exists sl_nickkick]} {
  set sl_nickkick 0
}

set sl_bcflood [split $sl_bcflood :] ; set sl_bmflood [split $sl_bmflood :]
# sl_txflood stays named as sl_avflood internally to simplify update
set sl_ccflood [split $sl_ccflood :] ; set sl_avflood [split $sl_txflood :]
# sl_linecap stays named as sl_txflood internally to simplify update
set sl_txflood [split $sl_linecap :] ; set sl_boflood [split $sl_boflood :]
set sl_jflood [split $sl_jflood :] ; set sl_nkflood [split $sl_nkflood :]
set sl_note [split $sl_note]

foreach sl_locktimepair $sl_locktimes {
  if {[lindex [split $sl_locktimepair :] 1] > 0 && [lindex [split $sl_locktimepair :] 1] < 30} {
    lappend sl_locktimeslist [list [lindex [split $sl_locktimepair :] 0] 30]
  } else {
    lappend sl_locktimeslist [split $sl_locktimepair :]
  }
}

set sl_locktimes $sl_locktimeslist
unset sl_locktimepair
unset sl_locktimeslist

if {[lsearch -glob $sl_locktimes {*i* *}] == -1} {
  lappend sl_locktimes {i 30}
}
if {[lsearch -glob $sl_locktimes {*m* *}] == -1} {
  lappend sl_locktimes {m 30}
}

set trigger-on-ignore 0
if {!${kick-method}} {
  set sl_kicks 8
} else {
  set sl_kicks ${kick-method}
}

if {$numversion <= 1040400} {
  if {$numversion >= 1032100} {
    set kick-bogus 0
  }
  if {$numversion >= 1032400} {
    set ban-bogus 0
  }
}
if {$numversion >= 1032400} {
  set kick-fun 0 ; set ban-fun 0
}
if {$numversion >= 1032500} {
  set ctcp-mode 0
}

if {![string match *sl_txqueuereset* [utimers]] && [lsearch -exact $sl_txflood 0] == -1} {
  utimer [lindex $sl_txflood 1] sl_txqueuereset
}

set nb_netcmds(rlock) "nb_sl_lock"

bind pub $sl_lockflags|$sl_lockflags lc sl_lc
bind pub $sl_lockflags|$sl_lockflags uc sl_uc
bind dcc $sl_lockflags|$sl_lockflags lock sl_dcclc
bind dcc $sl_lockflags|$sl_lockflags unlock sl_dccuc
if {!$sl_lockcmds} {
  unbind pub $sl_lockflags|$sl_lockflags lc sl_lc
  unbind pub $sl_lockflags|$sl_lockflags uc sl_uc
  rename sl_lc ""
  rename sl_uc ""
}
bind dcc m|m sentinel sl_dcc
bind raw - NOTICE sl_avflood
bind raw - PRIVMSG sl_avflood
if {[lsearch -exact $sl_avflood 0] != -1 && [lsearch -exact $sl_txflood 0] != -1} {
  unbind raw - NOTICE sl_avflood
  unbind raw - PRIVMSG sl_avflood
  rename sl_avflood ""
}
bind ctcp - CLIENTINFO sl_ctcp
bind ctcp - USERINFO sl_ctcp
bind ctcp - VERSION sl_ctcp
bind ctcp - FINGER sl_ctcp
bind ctcp - ERRMSG sl_ctcp
bind ctcp - ECHO sl_ctcp
bind ctcp - INVITE sl_ctcp
bind ctcp - WHOAMI sl_ctcp
bind ctcp - OP sl_ctcp
bind ctcp - OPS sl_ctcp
bind ctcp - UNBAN sl_ctcp
bind ctcp - PING sl_ctcp
bind ctcp - TIME sl_ctcp
bind msgm - * sl_bmflood
if {[lsearch -exact $sl_bmflood 0] != -1} {
  unbind msgm - * sl_bmflood
  rename sl_bmflood ""
}
bind nick - * sl_nkflood
if {[lsearch -exact $sl_nkflood 0] != -1} {
  unbind nick - * sl_nkflood
  rename sl_nkflood ""
}
bind join - * sl_jflood
bind part - * sl_pflood
bind sign - * sl_pflood
if {![info exists sl_detectquits]} {
  set sl_detectquits 0
}
if {!$sl_detectquits} {
  unbind sign - * sl_pflood
}
bind kick - * sl_pfloodk
bind flud - * sl_flud
bind mode - * sl_mode

return "nb_info 4.10.0"
