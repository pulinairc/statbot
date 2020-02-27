# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## extras.tcl component script ##

proc ex_helpidx {hand chan idx} {
  if {![matchattr $hand o] && ![matchattr $hand |o $chan]} {return 0}
  putidx $idx "extras.tcl commands"
  if {[matchattr $hand n]} {
    putidx $idx " For owners:"
    putidx $idx "  clearbans     clearignores  telnethosts"
  }
  putidx $idx " For ops:"
  putidx $idx "  opall         inviteall"
  putidx $idx " "
  return 1
}

proc ex_help {hand chan idx cmd} {
  if {[matchattr $hand o|o $chan]} {
    switch -exact -- $cmd {
      "clearbans" {
        if {[matchattr $hand n]} {
          putidx $idx "# clearbans <channel|-global|-all\> \[creator\]"
          putwrap $idx 3 "This command is used to clear bans set on the bot. Specifying a channel will remove all bans for that channel, specifying -global will remove all global bans, specifying -all will remove all global and channel bans. If you specify a creator, only bans set by that user will be removed."
          return 1
        }
      }
      "clearignores" {
        if {[matchattr $hand n]} {
          putidx $idx "# clearignores \[creator\]"
          putwrap $idx 3 "This command is used to clear all ignores set on the bot. If you specify a creator, only ignores set by that user will be removed."
          return 1
        }
      }
      "telnethosts" {
        if {[matchattr $hand n]} {
          putidx $idx "# telnethosts"
          putwrap $idx 3 "If ex_telnethost is set, this command runs the telnet host script, which checks the hostmasks of all users with the flags specified in ex_telnethost. If no telnet hostmask (e.g. -telnet!*@your.hostmask.com) exists for a particular hostmask, it is added to their user record."
          return 1
        }
      }
      "opall" {
        putidx $idx "# opall <nick>"
        putwrap $idx 3 "Makes the bot give ops to the specified nick on all channels the bot is on. For each channel, the user of the command as well as the specified nick must have +o status."
        return 1
      }
      "inviteall" {
        putidx $idx "# inviteall <nick>"
        putwrap $idx 3 "Makes the bot invite the specified nick to all invite-only channels the bot is on. For each channel, the user of the command must have +o status."
        return 1
      }
    }
  }
  return 0
}

lappend nb_helpidx "ex_helpidx"
set nb_help(clearbans) "ex_help"
set nb_help(clearignores) "ex_help"
set nb_help(telnethosts) "ex_help"
set nb_help(opall) "ex_help"
set nb_help(inviteall) "ex_help"

# ex_cleanup feature

proc ex_cleanup {min hour day month year} {
  putlog "Checking for redundant files.."
  catch {exec ls -a} files
  foreach file $files {
    if {[string match .share* $file] || [string match .nfs* $file] || $file == "core"} {
      if {[catch {file atime $file} filedate]} {continue}
      if {[expr [unixtime] - $filedate] > 1800} {
        if {![catch {file delete -- $file}]} {
          putlog "Deleted '$file'."
        }
      }
    }
  }
  return 0
}

if {$ex_cleanup} {
  if {![string length [binds ex_cleanup]]} {
    bind time - "[format "%02d" [expr {[rand 59] + 1}]] [format "%02d" [rand 24]] * * *" ex_cleanup
  }
} else {
  if {[string length [binds ex_cleanup]]} {
    unbind time - [lindex [lindex [binds ex_cleanup] 0] 2] ex_cleanup
  }
  rename ex_cleanup ""
}

# ex_clearbans feature

proc ex_clearbans {hand idx arg} {
  putcmdlog "#$hand# clearbans $arg"
  set chan [lindex [split $arg] 0]
  if {$chan == ""} {
    putidx $idx "Usage: clearbans <channel|-global|-all> \[creator\]" ; return 0
  }
  set remove [lindex [split $arg] 1]
  if {$chan == "-all"} {
    set gcount 0 ; set ccount 0
    foreach ban [banlist] {
      if {$remove != ""} {
        if {[string tolower [lindex $ban 5]] == [string tolower $remove]} {
          killban [lindex $ban 0] ; incr gcount
        }
      } else {
        killban [lindex $ban 0] ; incr gcount
      }
    }
    foreach banchan [channels] {
      foreach ban [banlist $banchan] {
        if {$remove != ""} {
          if {[string tolower [lindex $ban 5]] == [string tolower $remove]} {
            killchanban $banchan [lindex $ban 0] ; incr ccount
          }
        } else {
           killchanban $banchan [lindex $ban 0] ; incr ccount
        }
      }
    }
    if {$remove != ""} {
      putidx $idx "Removed $gcount global and $ccount channel [nb_plural ban bans $ccount] set by $remove."
    } else {
      putidx $idx "Removed $gcount global and $ccount channel [nb_plural ban bans $ccount]."
    }
  } elseif {$chan == "-global"} {
    set count 0
    foreach ban [banlist] {
      if {$remove != ""} {
        if {[string tolower [lindex $ban 5]] == [string tolower $remove]} {
          killban [lindex $ban 0] ; incr count
        }
      } else {
        killban [lindex $ban 0] ; incr count
      }
    }
    if {$remove != ""} {
      putidx $idx "Removed $count global [nb_plural ban bans $count] set by $remove."
    } else {
      putidx $idx "Removed $count global [nb_plural ban bans $count]."
    }
  } elseif {[string trim [string index $chan 0] "#+&!"] == ""} {
    if {![validchan $chan]} {
      putidx $idx "$chan is not a valid channel."
    } else {
      set count 0
      foreach ban [banlist $chan] {
        if {$remove != ""} {
          if {[string tolower [lindex $ban 5]] == [string tolower $remove]} {
            killchanban $chan [lindex $ban 0] ; incr count
          }
        } else {
          killchanban $chan [lindex $ban 0] ; incr count
        }
      }
      if {$remove != ""} {
        putidx $idx "Removed $count $chan [nb_plural ban bans $count] set by $remove."
      } else {
        putidx $idx "Removed $count $chan [nb_plural ban bans $count]."
      }
    }
  }
  return 0
}

proc ex_clearignores {hand idx arg} {
  putcmdlog "#$hand# clearignores $arg"
  set remove [lindex [split $arg] 0]
  set count 0
  foreach ignore [ignorelist] {
    if {$remove != ""} {
      if {[string tolower [lindex $ignore 4]] == [string tolower $remove]} {
        killignore [lindex $ignore 0] ; incr count
      }
    } else {
      killignore [lindex $ignore 0] ; incr count
    }
  }
  if {$remove != ""} {
    putidx $idx "Removed $count [nb_plural ignore ignores $count] set by $remove."
  } else {
    putidx $idx "Removed $count [nb_plural ignore ignores $count]."
  }
  return 0
}

bind dcc n clearbans ex_clearbans
bind dcc n clearignores ex_clearignores

if {!$ex_clearbans} {
  unbind dcc n clearbans ex_clearbans
  unbind dcc n clearignores ex_clearignores
  rename ex_clearbans ""
  rename ex_clearignores ""
}

# ex_newuser feature

proc ex_+bot {hand idx arg} {
  global ex_newuser
  foreach recipient $ex_newuser {
    if {[validuser $recipient] && [string tolower $recipient] != [string tolower $hand]} {
      sendnote NEWUSER $recipient "$hand added bot (command '.+bot $arg')."
    }
  }
  *dcc:+bot $hand $idx $arg
}

proc ex_+user {hand idx arg} {
  global ex_newuser
  foreach recipient $ex_newuser {
    if {[validuser $recipient] && [string tolower $recipient] != [string tolower $hand]} {
      sendnote NEWUSER $recipient "$hand added user (command '.+user $arg')."
    }
  }
  *dcc:+user $hand $idx $arg
}

proc ex_adduser {hand idx arg} {
  global ex_newuser
  foreach recipient $ex_newuser {
    if {[validuser $recipient] && [string tolower $recipient] != [string tolower $hand]} {
      sendnote NEWUSER $recipient "$hand added user (command '.adduser $arg')."
    }
  }
  *dcc:adduser $hand $idx $arg
}

if {$ex_newuser != ""} {
  set ex_newuser [split $ex_newuser]
  unbind dcc t|- +bot *dcc:+bot ; bind dcc t|- +bot ex_+bot
  unbind dcc m|- +user *dcc:+user ; bind dcc m|- +user ex_+user
  unbind dcc m|m adduser *dcc:adduser ; bind dcc m|m adduser ex_adduser
}

# ex_opall feature

proc ex_opall {hand idx arg} {
  putcmdlog "#$hand# opall $arg"
  set nick [lindex [split $arg] 0]
  if {$nick == ""} {
    putidx $idx "Usage: opall <nick>" ; return 0
  }
  set clist ""
  foreach chan [channels] {
    if {[matchattr $hand o|o $chan] && ![matchattr $hand d|d $chan] && [botisop $chan] && [onchan $nick $chan] && [string tolower [nick2hand $nick $chan]] == [string tolower $hand]} {
      pushmode $chan +o $nick
      lappend clist $chan
    }
  }
  if {$clist != ""} {
    putidx $idx "Gave op to $nick on [join $clist ", "]"
  } else {
    putidx $idx "Didn't op $nick on any channels."
  }
  return 0
}

proc ex_inviteall {hand idx arg} {
  putcmdlog "#$hand# inviteall $arg"
  set nick [lindex [split $arg] 0]
  if {$nick == ""} {
    putidx $idx "Usage: inviteall <nick>" ; return 0
  }
  set clist ""
  foreach chan [channels] {
    if {[matchattr $hand o|o $chan] && [botisop $chan] && [string match *i* [lindex [split [getchanmode $chan]] 0]]} {
      putserv "INVITE $nick $chan"
      lappend clist $chan
    }
  }
  if {$clist != ""} {
    putidx $idx "Invited $nick to [join $clist ", "]"
  } else {
    putidx $idx "Didn't invite $nick to any channels."
  }
  return 0
}

bind dcc o|o opall ex_opall
bind dcc o|o inviteall ex_inviteall
if {!$ex_opall} {
  unbind dcc o|o opall ex_opall
  unbind dcc o|o inviteall ex_inviteall
  rename ex_opall ""
  rename ex_inviteall ""
}

# ex_telnethost feature

proc ex_telnethost {min hour day month year} {
  global ex_telnethost numversion
  putlog "Checking telnet hostmasks of $ex_telnethost users.."
  if {$numversion < 1060000} {
    set telnet "telnet"
  } else {
    set telnet "-telnet"
  }
  foreach user [userlist $ex_telnethost] {
    foreach host [getuser $user HOSTS] {
      if {![string match $telnet* $host]} {
        set thost $telnet!*[string range $host [string first @ $host] end]
        if {[lsearch -exact [getuser $user HOSTS] $thost] == -1} {
          setuser $user HOSTS $thost
          putlog "Added $thost to $user"
        }
      }
    }
  }
  return 0
}

proc ex_dcctelnethosts {hand idx arg} {
  putcmdlog "#$hand# telnethosts $arg"
  ex_telnethost * * * * *
  return 0
}

if {[string length $ex_telnethost]} {
  if {![string length [binds ex_telnethost]]} {
    bind time - "[format "%02d" [expr {[rand 59] + 1}]] [format "%02d" [rand 24]] * * *" ex_telnethost
  }
  bind dcc n telnethosts ex_dcctelnethosts
} else {
  if {[string length [binds ex_telnethost]]} {
    unbind time - [lindex [lindex [binds ex_telnethost] 0] 2] ex_telnethost
  }
  if {[string length [binds ex_dcctelnethosts]]} {
    unbind dcc n telnethosts ex_dcctelnethosts
  }
  rename ex_telnethost ""
  rename ex_dcctelnethosts ""
}

return "nb_info 4.10.0"
