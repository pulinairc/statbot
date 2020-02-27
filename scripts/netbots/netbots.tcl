# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## netbots.tcl core script ##

## Please read netbots.txt and components.txt before using this script ##
## Settings must be configured in netset.tcl ##

set nb_ver "v4.10" ; set nb_numver "4100"
putlog "Loading netbots.tcl $nb_ver..."

if {[string trimleft [lindex [split $version] 1] 0] < 1032200} {
  die "*** netbots.tcl $nb_ver requires eggdrop 1.3.22 or later. Please upgrade your eggdrop or remove the script."
}

set nb_script [info script]
set nb_dir [file dirname $nb_script]
set nb_setscript $nb_dir/netset.tcl
if {![file exists $nb_setscript]} {
  putlog "*** Couldn't find netbots.tcl settings file '$nb_setscript'."
  return
}

if {[info exists nb_component]} {
  unset nb_component
}

if {![info exists botnet-nick] || ${botnet-nick} == ""} {
  set botnet-nick $nick
}

proc nb_set {bots setting value} {
  global botnet-nick [lindex [split $setting "("] 0]
  if {[lsearch -exact [split [string tolower $bots] ,] [string tolower ${botnet-nick}]] != -1} {
    set $setting $value
  }
}

proc nb_berror {file} {
  global nb_error
  if {[info commands nb_sendcmd] != ""} {
    nb_sendcmd * rbroadcast "*** WARNING: error found when loading $file:"
    nb_sendcmd * rbroadcast $nb_error
  }
}

if {[info exists nb_ctrlbots]} {
  unset nb_ctrlbots
}

if {[catch {source $nb_setscript} nb_error]} {
  putlog "*** WARNING: error found when loading $nb_setscript:"
  putlog $nb_error
  utimer 3 [list nb_berror $nb_setscript]
  return
}

if {$numversion < 1040200} {
  if {[info commands isop] != ""} {
    proc wasop {nick chan} {
      return [isop $nick $chan]
    }
  }
  if {$numversion < 1032500} {
    proc islinked {bot} {
      if {[lsearch -exact [string tolower [bots]] [string tolower $bot]] == -1} {return 0}
      return 1
    }
    if {$numversion < 1032400} {
      if {[info commands onchan] != ""} {
        proc botonchan {chan} {
          global botnick
          if {![validchan $chan]} {
            error "illegal channel: $chan"
          } elseif {![onchan $botnick $chan]} {
            return 0
          }
          return 1
        }
      }
      if {[info commands putserv] != ""} {
        proc putquick {text args} {
          putserv $text
        }
      }
    }
  }
}

proc isbotnetnick {nick} {
  global botnet-nick
  if {[string tolower $nick] == [string tolower ${botnet-nick}]} {return 1}
  return 0
}

proc slindex {string n} {
  return [lindex [split $string] $n]
}

proc stl {string} {
  return [string tolower $string]
}

if {[info exists nb_helpidx]} {
  unset nb_helpidx
}
if {[info exists nb_help]} {
  unset nb_help
}
if {[info exists nb_netcmds]} {
  unset nb_netcmds
}

proc nb_dccnethelp {hand idx arg} {
  global nb_help nb_helpidx nb_owner owner
  putcmdlog "#$hand# nethelp $arg"
  set command [string tolower [string trimleft [lindex [split $arg] 0] "."]]
  set chan [lindex [console $idx] 0]
  if {$command == ""} {
    if {(([matchattr $hand n]) && ((!$nb_owner) || ([lsearch -exact [split [string tolower $owner] ", "] [string tolower $hand]] != -1)))} {
      putidx $idx "netbots.tcl commands"
      if {$nb_owner} {
        putidx $idx " For permanent owners:"
      } else {
        putidx $idx " For owners:"
      }
      putidx $idx "  netbots       netcontrol    netinfo       netshell"
      putidx $idx "  netserv       netpass       netsave       nethash"
      putidx $idx "  netsay        netact        netnotice     netdump"
      putidx $idx "  netnick       netjump       netjoin       netpart"
      putidx $idx "  netchanset    nettcl        netupdate     components"
      putidx $idx " "
      set found 1
    }
    if {[info exists nb_helpidx]} {
      foreach procname $nb_helpidx {
        if {[$procname $hand $chan $idx]} {
          set found 1
        }
      }
    }
    if {![info exists found]} {
      putidx $idx "What?  You need '.help'"
    }
  } else {
    if {[info exists nb_help($command)]} {
      if {[$nb_help($command) $hand $chan $idx $command]} {
        return 0
      }
    }
    putidx $idx "What?  You need '.nethelp'"
  }
  return 0
}

proc nb_help {hand chan idx cmd} {
  global nb_owner owner
  if {((![matchattr $hand n]) || (($nb_owner) && ([lsearch -exact [split [string tolower $owner] ", "] [string tolower $hand]] == -1)))} {return 0}
  switch -exact -- $cmd {
    "nethelp" {
      putidx $idx "# nethelp \[command\]"
      putwrap $idx 3 "Displays information about the specified command. If no command is specified, this will display a list of all the available netbot commands."
      return 1
    }
    "netbots" {
      putidx $idx "# netbots \[add|remove <handle1,handle2,etc>\]"
      putwrap $idx 3 "This command gives the netbot flag to or removes it from the specified bots. You can specify a list of bots to add/remove by separating their handles with commas or spaces. It automatically gives the specified bot(s) the netbot flag. The bot(s) will only send commands to and receive commands from other netbots. If no options are specified, this command lists all current netbots."
      putwrap $idx 3 "Note: this command is not used if nb_flag is set to 'b' or 'all' in the script's options."
      return 1
    }
    "control" -
    "netcontrol" {
      putidx $idx "# netcontrol/control \[*|group|bot1,bot2,etc\]"
      putwrap $idx 3 "Allows you to select which netbots to control with netbot commands. Specifying '*' will let you control the current bot and all other netbots. Specifying a group of netbots (as defined in the config file using 'nb_group') will make netbot commands control that group only (only including the current bot if it's part of the group). Specifying a list of bots (separated by commas or spaces) will make netbot commands control that list of bots only (only including the current bot if it's listed)."
      putwrap $idx 3 "The netcontrol command is effective until you sign off from the bot. So, for example, if you use .netcontrol \[group\], any netbot commands you use will control that group, until you either use .netcontrol to change the bots to control, or sign off from the bot."
      putwrap $idx 3 "If no arguments are specified, the command will list the netbots you're currently controlling, as well as any netbot groups available to control."
      return 1
    }
    "netinfo" {
      putidx $idx "# netinfo \[-more\]"
      putwrap $idx 3 "Displays information about the version of netbots.tcl each netbot is running, and the components each has loaded. If -more is specified, Tcl versions and additional component information is displayed."
      return 1
    }
    "netshell" {
      putidx $idx "# netshell"
      putwrap $idx 3 "Displays brief information about the shell each netbot is running on, including operating system, uptime, and load averages."
      return 1
    }
    "netserv" {
      putidx $idx "# netserv"
      putwrap $idx 3 "Displays the server each netbot is using and time connected."
      return 1
    }
    "netpass" {
      putidx $idx "# netpass \[handle \[password\]\]"
      putwrap $idx 3 "This command works in different ways depending on which options are specified. If both a handle and password are specified, this will change the password for that particular user across the botnet. If only a handle is specified, a random password for that user will be generated automatically. If no options are specified, a new netbot password table is generated and sent out to all connected netbots (since these are the passwords netbots use to link to one another, you should only do this while all netbots are connected, otherwise you may get bad password errors during linking)."
      putwrap $idx 3 "Note: if you set nb_flag to 'b' or 'all' in the script's options this command is only partially enabled - you can change the password for a particular user, but cannot generate a netbot password table."
      putidx $idx "# netpass -check"
      putwrap $idx 3 "Displays a list of users without a password set for each netbot."
      return 1
    }
    "netsave" {
      putidx $idx "# netsave"
      putwrap $idx 3 "Makes all netbots perform a userfile/chanfile save."
      return 1
    }
    "nethash" {
      putidx $idx "# nethash"
      putwrap $idx 3 "Makes all netbots perform a rehash."
      return 1
    }
    "netsay" {
      putidx $idx "# netsay <channel|nick> <message>"
      putwrap $idx 3 "Makes all netbots say the specified message to the specified channel or nick."
      return 1
    }
    "netact" {
      putidx $idx "# netact <channel|nick> <message>"
      putwrap $idx 3 "Makes all netbots perform the specified action to the specified channel or nick."
      return 1
    }
    "netnotice" {
      putidx $idx "# netnotice <channel|nick> <notice>"
      putwrap $idx 3 "Makes all netbots send the specified notice to the specified channel or nick."
      return 1
    }
    "netdump" {
      putidx $idx "# netdump <text>"
      putwrap $idx 3 "Makes all netbots send the specified text to the server. Basically the same as eggdrop's .dump command. Be careful when using this."
      return 1
    }
    "netnick" {
      putidx $idx "# netnick \[-rand\]"
      putwrap $idx 3 "Makes all netbots change their nicknames to their alternate nickname. If -rand is specified, it instead changes their nicks to the first three letters of their nick with a random number between 10 and 999999 added on the end."
      putidx $idx "# netnick <bot1:newnick bot2:newnick botN:newnick>"
      putwrap $idx 3 "Makes each specified netbot change its nickname to the specified new nickname. For example, if you have a bot named 'Tom' and another named 'Harry', and would like to change their nicks to 'Dumb' and 'Dumber' respectively, you would use: .netnick Tom:Dumb Harry:Dumber"
      putidx $idx " "
      putwrap $idx 3 "Tip: to make the bots switch back to their ordinary nicks, use nethash."
      return 1
    }
    "netjump" {
      putidx $idx "# netjump <bot|-all> \[server\]"
      putwrap $idx 3 "Makes netbots jump to the next server in their server list. If -all is specified, all currently controlled netbots will jump. If a bot is specified, only that bot will jump. If a server is specified, the bot(s) will jump to the specified server. You can specify the server port/password in server:port:password format."
      return 1
    }
    "netjoin" {
      putidx $idx "# netjoin <channel> \[key\]"
      putwrap $idx 3 "Adds the specified channel to all netbots. If the channel has a key, you should specify the key so that the bots can join."
      return 1
    }
    "netpart" {
      putidx $idx "# netpart <channel>"
      putwrap $idx 3 "Removes the specified channel from all netbots."
      putwrap $idx 3 "Tip: if your netbots are 1.3.28+, you can take advantage of the 'inactive' channel setting to make all netbots temporarily part a channel (without losing channel-specific flags, etc.). Simply use '.netchanset <channel> +inactive'."
      return 1
    }
    "netchanset" {
      putidx $idx "# netchanset <channel|-all> \[settings\]"
      putwrap $idx 3 "Allows you to change a channel's settings on all netbots. This command works in basically the same way as eggdrop's .chanset command. Specifying -all instead of a channel will make the chanset take effect on all channels. If no settings are specified, the channel's settings are changed to the defaults set in the bot's config file (global-flood-chan, global-chanset, etc.)"
      putwrap $idx 3 "Note: it is safe to specify channel settings that may not be supported by older bots. Any netbots that don't support a specified chanset will simply ignore it."
      putidx $idx "# netchanset -reload"
      putwrap $idx 3 "Resets all channel settings as set in the config file. Normally, the chanfile will override the config file's channel settings, preventing any changes you make from taking effect unless you use the .chanset command. This command lets you make changes in the bot config files and reload the channel settings from there, without the need to disable the chanfile. Note that this feature only works if you specify the channel settings in a 'channel set' line."
      return 1
    }
    "nettcl" {
      putidx $idx "# nettcl <command>"
      putwrap $idx 3 "Executes the specified tcl command on netbots. Errors are caught, and all bots will reply with the return value of the command."
      putwrap $idx 3 "This is a very powerful command that must be enabled in the netset.tcl file to use. It allows you to make all netbots perform virtually any function. It is mainly intended for tcl scripters and experienced eggdrop users, and some tcl knowledge is recommended before using the nettcl command."
      return 1
    }
    "netupdate" {
      putidx $idx "# netupdate \[-config|-motd|-banner|-settings|-scripts|-changed|-everything\] \[bot\]"
      putwrap $idx 3 "You should typically use this command on the hub bot, after updating config files, motd, telnet-banner, netbots.tcl or a component script, or settings file on the hub's shell. The first option specifies which file(s) is updated."
      putidx $idx "    -config sends bot config files."
      putidx $idx "    -motd sends motd files."
      putidx $idx "    -banner sends telnet-banner files."
      putidx $idx "    -settings sends the netbots settings file."
      putidx $idx "    -scripts sends netbots.tcl and component scripts."
      putidx $idx "    -changed sends only files which have changed on the current bot's"
      putidx $idx "             shell in the past 24 hours."
      putidx $idx "    -everything sends all of the above."
      putwrap $idx 3 "If no switch is specified, a settings/scripts update is performed. If a bot is specified, the requested file is sent to that bot only, instead of updating all netbots."
      putidx $idx "# netupdate -file <filename(s)> \[bot\]"
      putwrap $idx 3 "Allows you to update a specific file or files across the botnet. This should only be used with text files (e.g. Tcl scripts). Wildcards are supported. Files that do not exist will be created, files that exist will be overwritten. Examples:"
      putidx $idx "    netupdate -file awesome.tcl"
      putwrap $idx 5 "Sends 'awesome.tcl' to all netbots."
      putidx $idx "    netupdate -file scripts/groovy.tcl  OR"
      putidx $idx "    netupdate -file ./scripts/groovy.tcl"
      putwrap $idx 5 "Sends 'groovy.tcl' to all netbots. The netbots will place it in the 'scripts' directory. If the directory doesn't exist, it will be created."
      putidx $idx "    netupdate -file seendata infodata Dash9"
      putwrap $idx 5 "Sends 'seendata' and 'infodata' to Dash9."
      putidx $idx "    netupdate -file text/*"
      putwrap $idx 5 "Sends all files in the 'text' directory to all netbots."
      putidx $idx " "
      putwrap $idx 3 "This feature can only be used for sending text (not binary) files. See the script documentation for more information about netupdate."
      return 1
    }
    "components" {
      putidx $idx "# components \[-more\]"
      putwrap $idx 3 "Displays a list of loaded components and a list of available components. If -more is specified, additional component information is displayed."
      return 1
    }
  }
  return 0
}

set nb_help(netbots) "nb_help"
set nb_help(nethelp) "nb_help"
set nb_help(control) "nb_help"
set nb_help(netcontrol) "nb_help"
set nb_help(netinfo) "nb_help"
set nb_help(netshell) "nb_help"
set nb_help(netserv) "nb_help"
set nb_help(netpass) "nb_help"
set nb_help(netsave) "nb_help"
set nb_help(nethash) "nb_help"
set nb_help(netsay) "nb_help"
set nb_help(netact) "nb_help"
set nb_help(netnotice) "nb_help"
set nb_help(netdump) "nb_help"
set nb_help(netnick) "nb_help"
set nb_help(netjump) "nb_help"
set nb_help(netjoin) "nb_help"
set nb_help(netpart) "nb_help"
set nb_help(netchanset) "nb_help"
set nb_help(nettcl) "nb_help"
set nb_help(netupdate) "nb_help"

proc nb_dcccomponents {hand idx arg} {
  global nb_components nb_dir nb_setscript nb_ucomponents
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# components $arg"
  if {[lindex [split $arg] 0] == "-more"} {
    foreach component [lsort [array names nb_components]] {
      if {$nb_components($component) != ""} {
        lappend components "$component ($nb_components($component))"
      } else {
        lappend components $component
      }
    }
    putidx $idx "Loaded components: [join $components ", "]"
  } else {
    putidx $idx "Loaded components: [join [lsort [array names nb_components]] ", "]"
  }
  if {[info exists nb_ucomponents]} {
    putidx $idx "Unload on next restart: [join [lsort $nb_ucomponents] ", "]"
  }
  if {[catch {glob -- $nb_dir/*.tcl} scripts]} {
    putlog "Unable to list component scripts in '$nb_dir'."
    return 0
  }
  foreach script $scripts {
    set script [file tail $script]
    if {$script != [file tail $nb_setscript]} {
      lappend available [file rootname $script]
    }
  }
  putidx $idx "Available components: [join [lsort $available] ", "]"
  return 0
}

proc nb_dccnetbots {hand idx arg} {
  global nb_control nb_flag
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netbots $arg"
  if {$nb_flag == "b" || $nb_flag == "all"} {
    putidx $idx "This command is not used if nb_flag is set to 'b' or 'all'." ; return 0
  }
  set command [lindex [split $arg] 0] ; set bothands [lrange [split $arg] 1 end]
  if {$command == "add"} {
    if {$bothands == ""} {
      putidx $idx "You must specify a handle." ; return 0
    }
    set added ""
    foreach bothand $bothands {
      if {![validuser $bothand]} {
        putidx $idx "$bothand is not a valid user." ; continue
      }
      if {![matchattr $bothand b]} {
        putidx $idx "$bothand is not a valid bot." ; continue
      }
      if {[nb_control]} {
        chattr $bothand +$nb_flag
      }
      nb_sendcmd $nb_control netbots [list $hand add $bothand]
      lappend added $bothand
    }
    if {$added != ""} {
      putidx $idx "Added [join $added ", "] to netbot list."
    }
  } elseif {$command == "remove"} {
    if {$bothands == ""} {
      putidx $idx "You must specify a handle." ; return 0
    }
    set removed ""
    foreach bothand $bothands {
      if {![validuser $bothand]} {
        putidx $idx "$bothand is not a valid user." ; continue
      }
      if {![matchattr $bothand b]} {
        putidx $idx "$bothand is not a valid bot." ; continue
      }
      nb_sendcmd $nb_control netbots [list $hand remove $bothand]
      if {[nb_control]} {
        chattr $bothand -$nb_flag
      }
      lappend removed $bothand
    }
    if {$removed != ""} {
      putidx $idx "Removed [join $removed ", "] from netbot list."
    }
  } elseif {$command == ""} {
    set botlist "" ; set offline ""
    foreach netbot [userlist $nb_flag] {
      lappend botlist $netbot
      if {![islinked $netbot] && ![isbotnetnick $netbot]} {
        lappend offline $netbot
      }
    }
    if {$botlist == ""} {
      putidx $idx "There are no netbots." ; return 0
    }
    putidx $idx "Current netbots: [join $botlist ", "]."
    if {$offline != ""} {
      putidx $idx "Offline or not linked: [join $offline ", "]."
    } else {
      putidx $idx "All netbots are online and linked."
    }
  } else {
    putidx $idx "Usage: netbots \[add|remove <handle1,handle2,etc>\]"
  }
  return 0
}

proc nb_netbots {frombot arg} {
  global nb_flag
  set command [lindex $arg 1] ; set bothand [lindex $arg 2]
  if {![validuser $bothand] || ![matchattr $bothand b]} {return 0}
  if {$command == "add"} {
    chattr $bothand +$nb_flag
    putlog "netbots \[[lindex $arg 0]@$frombot\]: added $bothand to netbot list."
  } elseif {$command == "remove"} {
    chattr $bothand -$nb_flag
    putlog "netbots \[[lindex $arg 0]@$frombot\]: removed $bothand from netbot list."
  }
  return 0
}

proc nb_dccnetcontrol {hand idx arg} {
  global nb_control nb_group
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netcontrol $arg"
  regsub -all -- ", " $arg "," bots ; regsub -all -- " " $bots "," bots
  if {$bots == ""} {
    if {$nb_control == "*"} {
      putidx $idx "* Controlling all netbots."
    } else {
      regsub -all -- "," $nb_control ", " ctrlbots
      putidx $idx "* Controlling netbots: $ctrlbots"
    }
    if {[info exists nb_group]} {
      putidx $idx "  Available groups: [join [array names nb_group] ", "]"
    }
  } elseif {$bots == "*"} {
    set nb_control "*"
    putidx $idx "* Now controlling all netbots."
  } elseif {[info exists nb_group($bots)]} {
    set nb_control $nb_group($bots)
    regsub -all -- "," $nb_control ", " ctrlbots
    putidx $idx "* Now controlling '$bots' netbots: $ctrlbots"
  } else {
    set nb_control $bots
    regsub -all -- "," $nb_control ", " ctrlbots
    putidx $idx "* Now controlling netbots: $ctrlbots"
  }
  return 0
}

proc nb_dccnetinfo {hand idx arg} {
  global botnet-nick nb_components nb_control nb_ucomponents nb_ver version
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netinfo $arg"
  if {[nb_control]} {
    if {[string compare [lindex [split $arg] 0] "-more"] == 0} {
      foreach component [lsort [array names nb_components]] {
        if {[info exists nb_ucomponents] && [lsearch -exact $nb_ucomponents $component] != -1} {
          set unload " \[unload on next restart\]"
        } else {
          set unload ""
        }
        if {$nb_components($component) != ""} {
          lappend components "$component ($nb_components($component))$unload"
        } else {
          lappend components $component$unload
        }
      }
      putidx $idx "BOT        VERSION    TCL    NETBOTS  COMPONENTS"
      foreach line $components {
        if {![info exists firstline]} {
          putidx $idx [format "%-10.10s %-10.10s %-6.6s %-8.8s %s" ${botnet-nick} [lindex $version 0] [info patchlevel] $nb_ver $line]
          set firstline 1
        } else {
          putidx $idx [format "%-37s %s" "" $line]
        }
      }
    } else {
      set components [lsort [array names nb_components]]
      while {$components != ""} {
        set line [join [lrange $components 0 6] ", "]
        set components [lrange $components 7 end]
        if {$components != ""} {
          append line ","
        }
        lappend lines $line
      }
      putidx $idx "BOT        VERSION  COMPONENTS"
      foreach line $lines {
        if {![info exists firstline]} {
          putidx $idx [format "%-10.10s %-8.8s %s" ${botnet-nick} $nb_ver $line]
          set firstline 1
        } else {
          putidx $idx [format "%-19s %s" "" $line]
        }
      }
    }
  }
  if {[string compare [lindex [split $arg] 0] "-more"] == 0} {
    nb_sendcmd $nb_control netinfo [list $idx info]
  } else {
    nb_sendcmd $nb_control netinfo [list $idx]
  }
  return 0
}

proc nb_netinfo {frombot arg} {
  global nb_components nb_ucomponents nb_ver version
  if {[lindex $arg 1] == "info"} {
    foreach component [lsort [array names nb_components]] {
      if {[info exists nb_ucomponents] && [lsearch -exact $nb_ucomponents $component] != -1} {
        set unload " \[unload on next restart\]"
      } else {
        set unload ""
      }
      if {$nb_components($component) != ""} {
        lappend components "$component ($nb_components($component))$unload"
      } else {
        lappend components $component$unload
      }
    }
    nb_sendcmd $frombot rnetinfo [list [lindex $arg 0] [lindex $version 0] [info patchlevel] $nb_ver $components]
  } else {
    set components [lsort [array names nb_components]]
    while {$components != ""} {
      set line [join [lrange $components 0 6] ", "]
      set components [lrange $components 7 end]
      if {$components != ""} {
        append line ","
      }
      lappend lines $line
    }
    nb_sendcmd $frombot rnetinfo [list [lindex $arg 0] $nb_ver $lines]
  }
  return 0
}

proc nb_rnetinfo {frombot arg} {
  set idx [lindex $arg 0]
  if {[llength $arg] == 3} {
    foreach line [lindex $arg 2] {
      if {![info exists firstline]} {
        putidx $idx [format "%-10.10s %-8.8s %s" $frombot [lindex $arg 1] $line]
        set firstline 1
      } else {
        putidx $idx [format "%-19s %s" "" $line]
      }
    }
  } elseif {[llength $arg] == 5} {
    foreach line [lindex $arg 4] {
      if {![info exists firstline]} {
        putidx $idx [format "%-10.10s %-10.10s %-6.6s %-8.8s %s" $frombot [lindex $arg 1] [lindex $arg 2] [lindex $arg 3] $line]
        set firstline 1
      } else {
        putidx $idx [format "%-37s %s" "" $line]
      }
    }
  }
  return 0
}

proc nb_dccnetshell {hand idx arg} {
  global botnet-nick nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netshell $arg"
  if {[nb_control]} {
    catch {string trim [exec uptime]} uptime
    if {[info exists uptime]} {
      regsub -all -- "  " $uptime " " uptime
      putidx $idx "${botnet-nick} is on [info hostname] - [unames] - $uptime"
    }
  }
  nb_sendcmd $nb_control netshell [list $hand $idx]
  return 0
}

proc nb_netshell {frombot arg} {
  catch {string trim [exec uptime]} uptime
  if {[info exists uptime]} {
    regsub -all -- "  " $uptime " " uptime
    nb_sendcmd $frombot rnetshell [list [lindex $arg 1] [info hostname] [unames] $uptime]
  }
  return 0
}

proc nb_rnetshell {frombot arg} {
  putidx [lindex $arg 0] "$frombot is on [lindex $arg 1] - [lindex $arg 2] - [lindex $arg 3]"
  return 0
}

proc nb_dccnetserv {hand idx arg} {
  global botnet-nick nb_control nb_realserver server server-online
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netserv $arg"
  putidx $idx "BOT        SERVER                                CONNECTED"
  if {[nb_control]} {
    catch {set server}
    if {[info exists server]} {
      if {$server == ""} {
        putidx $idx [format "%-10.10s %-37.37s" ${botnet-nick} -]
      } elseif {[info exists nb_realserver] && [string tolower [lindex [split $server :] 0]] != [string tolower $nb_realserver]} {
        putidx $idx [format "%-10.10s %-37.37s %s" ${botnet-nick} $nb_realserver [nb_duration [expr [unixtime] - ${server-online}]]]
      } else {
        putidx $idx [format "%-10.10s %-37.37s %s" ${botnet-nick} $server [nb_duration [expr [unixtime] - ${server-online}]]]
      }
    }
  }
  nb_sendcmd $nb_control netserv [list $hand $idx]
  return 0
}

proc nb_netserv {frombot arg} {
  global nb_realserver server server-online
  catch {set server}
  if {[info exists server]} {
    if {$server != "" && [info exists nb_realserver] && [string tolower [lindex [split $server :] 0]] != [string tolower $nb_realserver]} {
      nb_sendcmd $frombot rnetserv [list [lindex $arg 1] $nb_realserver [expr [unixtime] - ${server-online}]]
    } else {
      nb_sendcmd $frombot rnetserv [list [lindex $arg 1] $server [expr [unixtime] - ${server-online}]]
    }
  }
  return 0
}

proc nb_rnetserv {frombot arg} {
  if {[lindex $arg 1] != ""} {
    putidx [lindex $arg 0] [format "%-10.10s %-37.37s %s" $frombot [lindex $arg 1] [nb_duration [lindex $arg 2]]]
  } else {
    putidx [lindex $arg 0] [format "%-10.10s %-37.37s" $frombot -]
  }
  return 0
}

proc nb_dccnetpass {hand idx arg} {
  global botnet-nick nb_control nb_flag nb_key
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netpass"
  set forhand [lindex [split $arg] 0] ; set thepass [lindex [split $arg] 1]
  if {$forhand == ""} {
    if {$nb_flag == "b" || $nb_flag == "all"} {
      putidx $idx "Cannot generate netbot passwords if nb_flag is set to 'b' or 'all'."
      return 0
    }
    putidx $idx "Generating new netbot password table.."
    set botlist [userlist $nb_flag]
    if {[lsearch -exact $botlist ${botnet-nick}] == -1} {
      lappend botlist ${botnet-nick}
    }
    while {$botlist != ""} {
      set shaker [lindex $botlist 0]
      set shakees [lrange $botlist 1 end]
      foreach shakee $shakees {
        lappend passtbl [list $shaker $shakee [nb_randpass]]
      }
      set botlist $shakees
    }
    set changed 0
    foreach entry $passtbl {
      if {[isbotnetnick [lindex $entry 0]]} {
        setuser [lindex $entry 1] PASS [lindex $entry 2]
        incr changed
      } elseif {[isbotnetnick [lindex $entry 1]]} {
        setuser [lindex $entry 0] PASS [lindex $entry 2]
        incr changed
      }
    }
    putidx $idx "Changed $changed netbot [nb_plural password passwords $changed]."
    nb_sendcmd * netpass [list $hand $idx $passtbl]
    putidx $idx "Password table distrubuted to all linked netbots."
  } elseif {$forhand == "-check"} {
    putidx $idx "Checking netbots for users without passwords.."
    if {[nb_control]} {
      set nopass ""
      foreach user [userlist] {
        if {[passwdok $user ""]} {
          lappend nopass $user
        }
      }
      if {$nopass != ""} {
        putidx $idx "${botnet-nick}: [join $nopass ", "]"
      } else {
        putidx $idx "${botnet-nick}: all users have a password set."
      }
    }
    nb_sendcmd $nb_control netpass [list $hand $idx -check]
  } else {
    if {![validuser $forhand]} {
      putidx $idx "$forhand is not a valid user." ; return 0
    }
    if {$thepass == ""} {
      set thepass [nb_randpass]
    }
    if {[nb_control]} {
      setuser $forhand PASS $thepass
    }
    nb_sendcmd $nb_control netpass [list $hand $idx $thepass $forhand]
    putidx $idx "Changed password for $forhand to '$thepass'."
  }
  return 0
}

proc nb_netpass {frombot arg} {
  global nb_flag
  set passtbl [lindex $arg 2] ; set forhand [lindex $arg 3]
  if {$forhand == ""} {
    if {$passtbl == "-check"} {
      set nopass ""
      foreach user [userlist] {
        if {[passwdok $user ""]} {
          lappend nopass $user
        }
      }
      if {$nopass != ""} {
        nb_sendcmd $frombot rnetpass [list [lindex $arg 1] $nopass]
      } else {
        nb_sendcmd $frombot rnetpass [list [lindex $arg 1]]
      }
    } else {
      set changed 0
      foreach entry $passtbl {
        if {[isbotnetnick [lindex $entry 0]]} {
          setuser [lindex $entry 1] PASS [lindex $entry 2]
          incr changed
        } elseif {[isbotnetnick [lindex $entry 1]]} {
          setuser [lindex $entry 0] PASS [lindex $entry 2]
          incr changed
        }
      }
      putlog "netbots \[[lindex $arg 0]@$frombot\]: received new netbot password table, changed $changed netbot passwords."
    }
  } else {
    setuser $forhand PASS $passtbl
    putlog "netbots \[[lindex $arg 0]@$frombot\]: changed password for $forhand."
  }
  return 0
}

proc nb_rnetpass {frombot arg} {
  if {[set nopass [lindex $arg 1]] != ""} {
    putidx [lindex $arg 0] "$frombot: [join $nopass ", "]"
  } else {
    putidx [lindex $arg 0] "$frombot: all users have a password set."
  }
  return 0
}

proc nb_dccnetsave {hand idx arg} {
  global nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netsave $arg"
  putidx $idx "Performing netbot userfile/chanfile save."
  if {[nb_control]} {
    save
  }
  nb_sendcmd $nb_control netsave [list $hand]
  return 0
}

proc nb_netsave {frombot arg} {
  putlog "netbots \[[lindex $arg 0]@$frombot\]: performing netbot userfile/chanfile save."
  save
  return 0
}

proc nb_dccnethash {hand idx arg} {
  global nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# nethash $arg"
  putidx $idx "Rehashing netbots."
  if {[nb_control]} {
    uplevel {rehash}
  }
  nb_sendcmd $nb_control nethash [list $hand]
  return 0
}

proc nb_nethash {frombot arg} {
  putlog "netbots \[[lindex $arg 0]@$frombot\]: rehashing."
  uplevel {rehash}
  return 0
}

proc nb_dccnetsay {hand idx arg} {
  global nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netsay $arg"
  set sayto [lindex [split $arg] 0] ; set themsg [join [lrange [split $arg] 1 end]]
  if {$sayto == "" || $themsg == ""} {
    putidx $idx "Usage: netsay <channel|nick> <message>" ; return 0
  }
  nb_sendcmd $nb_control netsay [list $hand $sayto $themsg]
  if {[nb_control]} {
    if {[info commands putserv] != ""} {
      putserv "PRIVMSG $sayto :$themsg"
    }
  }
  return 0
}

proc nb_netsay {frombot arg} {
  set sayto [lindex $arg 1]
  putlog "netbots \[[lindex $arg 0]@$frombot\]: sending message to $sayto"
  if {[info commands putserv] != ""} {
    putserv "PRIVMSG $sayto :[lindex $arg 2]"
  }
  return 0
}

proc nb_dccnetact {hand idx arg} {
  global nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netact $arg"
  set actto [lindex [split $arg] 0] ; set theact [join [lrange [split $arg] 1 end]]
  if {$actto == "" || $theact == ""} {
    putidx $idx "Usage: netact <channel|nick> <action>" ; return 0
  }
  nb_sendcmd $nb_control netact [list $hand $actto $theact]
  if {[nb_control]} {
    if {[info commands putserv] != ""} {
      putserv "PRIVMSG $actto :\001ACTION $theact\001"
    }
  }
  return 0
}

proc nb_netact {frombot arg} {
  set actto [lindex $arg 1]
  putlog "netbots \[[lindex $arg 0]@$frombot\]: sending action to $actto"
  if {[info commands putserv] != ""} {
    putserv "PRIVMSG $actto :\001ACTION [lindex $arg 2]\001"
  }
  return 0
}

proc nb_dccnetnotc {hand idx arg} {
  global nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netnotice $arg"
  set notcto [lindex [split $arg] 0] ; set thenotc [join [lrange [split $arg] 1 end]]
  if {$notcto == "" || $thenotc == ""} {
    putidx $idx "Usage: netnotice <channel|nick> <notice>" ; return 0
  }
  nb_sendcmd $nb_control netnotc [list $hand $notcto $thenotc]
  if {[nb_control]} {
    if {[info commands putserv] != ""} {
      putserv "NOTICE $notcto :$thenotc"
    }
  }
  return 0
}

proc nb_netnotc {frombot arg} {
  set notcto [lindex $arg 1]
  putlog "netbots \[[lindex $arg 0]@$frombot\]: sending notice to $notcto"
  if {[info commands putserv] != ""} {
    putserv "NOTICE $notcto :[lindex $arg 2]"
  }
  return 0
}

proc nb_dccnetdump {hand idx arg} {
  global nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netdump $arg"
  if {$arg == ""} {
    putidx $idx "Usage: netdump <text>" ; return 0
  }
  putidx $idx "Making netbots dump text '$arg'."
  nb_sendcmd $nb_control netdump [list $hand $arg]
  if {[nb_control]} {
    if {[info commands putserv] != ""} {
      putserv $arg
    }
  }
  return 0
}

proc nb_netdump {frombot arg} {
  set text [lindex $arg 1]
  putlog "netbots \[[lindex $arg 0]@$frombot\]: dumping text '$text'."
  if {[info commands putserv] != ""} {
    putserv $text
  }
  return 0
}

proc nb_dccnetnick {hand idx arg} {
  global altnick nb_control nick
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netnick $arg"
  if {$arg == ""} {
    putidx $idx "Changing netbot nicks to altnicks."
    nb_sendcmd $nb_control netnick [list $hand]
    if {[nb_control]} {
      set newnick $altnick
      while {[regsub -- \\? $newnick [rand 10] newnick]} {continue}
      set nick $newnick
    }
  } elseif {$arg == "-rand"} {
    putidx $idx "Changing netbot nicks to randnicks."
    nb_sendcmd $nb_control netnick [list $hand -rand]
    if {[nb_control]} {
      set nick [string range $nick 0 2][expr 10 + [rand 999990]]
    }
  } else {
    putidx $idx "Changing netbot nicks."
    nb_sendcmd $nb_control netnick [list $hand $arg]
    if {[nb_control]} {
      foreach i [split $arg] {
        if {[isbotnetnick [lindex [split $i :] 0]] && [set newnick [lindex [split $i :] 1]] != ""} {
          set nick $newnick
        }
      }
    }
  }
  return 0
}

proc nb_netnick {frombot arg} {
  global altnick nick
  if {[lindex $arg 1] == ""} {
    putlog "netbots \[[lindex $arg 0]@$frombot\]: changing nick to altnick '$altnick'."
    set newnick $altnick
    while {[regsub -- \\? $newnick [rand 10] newnick]} {continue}
    set nick $newnick
  } elseif {[lindex $arg 1] == "-rand"} {
    set newnick [string range $nick 0 2][expr 10 + [rand 999990]]
    putlog "netbots \[[lindex $arg 0]@$frombot\]: changing nick to randnick '$newnick'."
    set nick $newnick
  } else {
    foreach i [split [lindex $arg 1]] {
      if {[isbotnetnick [lindex [split $i :] 0]] && [set newnick [lindex [split $i :] 1]] != ""} {
        putlog "netbots \[[lindex $arg 0]@$frombot\]: changing nick to '$newnick'."
        set nick $newnick
      }
    }
  }
  return 0
}

proc nb_dccnetjump {hand idx arg} {
  global nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netjump $arg"
  if {[lindex [split $arg] 0] == ""} {
    putidx $idx "Usage: netjump <bot|-all> \[server\]" ; return 0
  }
  set bot [lindex [split $arg] 0] ; set server [lindex [split $arg] 1]
  if {$bot == "-all"} {
    nb_sendcmd $nb_control netjump [list $hand $server]
    if {$server == ""} {
      putidx $idx "Making netbots jump to next server."
      if {[nb_control]} {
        jump
      }
    } else {
      putidx $idx "Making netbots jump to $server"
      if {[nb_control]} {
        eval jump [join [split $server :]]
      }
    }
  } else {
    nb_sendcmd $bot netjump [list $hand $server]
    if {$server == ""} {
      putidx $idx "Making $bot jump to next server."
    } else {
      putidx $idx "Making $bot jump to $server"
    }
  }
  return 0
}

proc nb_netjump {frombot arg} {
  set server [lindex $arg 1]
  if {$server == ""} {
    putlog "netbots \[[lindex $arg 0]@$frombot\]: jumping to next server."
    jump
  } else {
    putlog "netbots \[[lindex $arg 0]@$frombot\]: jumping to $server"
    eval jump [join [split $server :]]
  }
  return 0
}

proc nb_dccnetjoin {hand idx arg} {
  global nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netjoin $arg"
  set chan [lindex [split $arg] 0] ; set key [lindex [split $arg] 1]
  if {$chan == "" || [string trim [string index $chan 0] "#+&!"] != ""} {
    putidx $idx "Usage: netjoin <channel>" ; return 0
  }
  putidx $idx "Adding channel $chan to netbots."
  nb_sendcmd $nb_control netjoin [list $hand $chan $key]
  if {[nb_control]} {
    if {![validchan $chan]} {
      channel add $chan
      if {[info commands bop_setneed] != ""} {
        bop_setneed $chan
      }
      if {$key != ""} {
        putserv "JOIN $chan $key"
      }
    }
  }
  return 0
}

proc nb_netjoin {frombot arg} {
  set chan [lindex $arg 1]
  putlog "netbots \[[lindex $arg 0]@$frombot\]: adding channel $chan"
  if {![validchan $chan]} {
    channel add $chan
    if {[info commands bop_setneed] != ""} {
      bop_setneed $chan
    }
    if {[set key [lindex $arg 2]] != ""} {
      putserv "JOIN $chan $key"
    }
  }
  return 0
}

proc nb_dccnetpart {hand idx arg} {
  global nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netpart $arg"
  set chan [lindex [split $arg] 0]
  if {$chan == "" || [string trim [string index $chan 0] "#+&!"] != ""} {
    putidx $idx "Usage: netpart <channel>" ; return 0
  }
  putidx $idx "Removing channel $chan from netbots."
  nb_sendcmd $nb_control netpart [list $hand $chan]
  if {[nb_control]} {
    if {[validchan $chan] && [isdynamic $chan]} {
      channel remove $chan
    }
  }
  return 0
}

proc nb_netpart {frombot arg} {
  set chan [lindex $arg 1]
  putlog "netbots \[[lindex $arg 0]@$frombot\]: removing channel $chan"
  if {[validchan $chan] && [isdynamic $chan]} {
    channel remove $chan
  }
  return 0
}

proc nb_dccnetchanset {hand idx arg} {
  global config nb_control
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netchanset $arg"
  set chan [lindex [split $arg] 0]
  if {$chan == "-reload"} {
    putidx $idx "Making netbots reload channel settings from config file."
    nb_sendcmd $nb_control netchanset [list $hand $chan]
    if {![file exists $config]} {
      putidx $idx "Error: unable to find file $config" ; return 0
    }
    set rfile [open $config r]
    while {![eof $rfile]} {
      set string [gets $rfile]
      if {[string match "channel set *" $string]} {
        eval $string
      }
    }
    close $rfile
    save
    return 0
  }
  if {(($chan == "") || (([string trim [string index $chan 0] "#+&!"] != "") && ($chan != "-all")))} {
    putidx $idx "Usage: netchanset <channel> \[settings\]" ; return 0
  }
  regsub -all -- \" [join [lrange [split $arg] 1 end]] "" settings
  set settings [split $settings]
  if {$settings == ""} {
    if {$chan == "-all"} {
      putidx $idx "Setting channel settings for all channels to config file default settings."
    } else {
      putidx $idx "Setting channel settings for $chan to config file default settings."
    }
    nb_sendcmd $nb_control netchanset [list $hand $chan]
    if {[nb_control]} {
      if {$chan == "-all"} {
        foreach chan [channels] {
          nb_chanset $chan
        }
      } else {
        if {[validchan $chan]} {
          nb_chanset $chan
        }
      }
    }
  } else {
    if {[string match "need-*" [lindex $settings 0]]} {
      putidx $idx "You cannot change need-op/invite/key/limit/unban settings." ; return 0
    }
    if {$chan == "-all"} {
      putidx $idx "Setting channel settings for all channels to '$settings' on netbots."
    } else {
      putidx $idx "Setting channel settings for $chan to '$settings' on netbots."
    }
    nb_sendcmd $nb_control netchanset [list $hand $chan $settings]
    if {[nb_control]} {
      if {$chan == "-all"} {
        if {[string index [lindex $settings 0] 0] == "+" || [string index [lindex $settings 0] 0] == "-"} {
          foreach chan [channels] {
            catch {eval channel set $chan $settings}
          }
        } else {
          foreach chan [channels] {
            catch {channel set $chan [lindex $settings 0] [lrange $settings 1 end]}
          }
        }
      } else {
        if {[validchan $chan]} {
          if {[string index [lindex $settings 0] 0] == "+" || [string index [lindex $settings 0] 0] == "-"} {
            catch {eval channel set $chan $settings}
          } else {
            catch {channel set $chan [lindex $settings 0] [lrange $settings 1 end]}
          }
        }
      }
    }
  }
  return 0
}

proc nb_netchanset {frombot arg} {
  global config
  set chan [lindex $arg 1]
  if {$chan == "-reload"} {
    putlog "netbots \[[lindex $arg 0]@$frombot\]: reloading channel settings from config file."
    if {![file exists $config]} {
      putlog "netbots: error - unable to find file $config" ; return 0
    }
    set rfile [open $config r]
    while {![eof $rfile]} {
      set string [gets $rfile]
      if {[string match "channel set *" $string]} {
        eval $string
      }
    }
    close $rfile
    save
    return 0
  }
  set settings [lindex $arg 2]
  if {$settings == ""} {
    if {$chan == "-all"} {
      putlog "netbots \[[lindex $arg 0]@$frombot\]: setting channel settings for all channels to config file default settings."
      foreach chan [channels] {
        nb_chanset $chan
      }
    } else {
      putlog "netbots \[[lindex $arg 0]@$frombot\]: setting channel settings for $chan to config file default settings."
      if {[validchan $chan]} {
        nb_chanset $chan
      }
    }
  } else {
    if {[string match "need-*" [lindex $settings 0]]} {return 0}
    if {$chan == "-all"} {
      putlog "netbots \[[lindex $arg 0]@$frombot\]: setting channel settings for all channels to '$settings'."
      if {[string index [lindex $settings 0] 0] == "+" || [string index [lindex $settings 0] 0] == "-"} {
        foreach chan [channels] {
          catch {eval channel set $chan $settings}
        }
      } else {
        foreach chan [channels] {
          catch {channel set $chan [lindex $settings 0] [lrange $settings 1 end]}
        }
      }
    } else {
      putlog "netbots \[[lindex $arg 0]@$frombot\]: setting channel settings for $chan to '$settings'."
      if {[validchan $chan]} {
        if {[string index [lindex $settings 0] 0] == "+" || [string index [lindex $settings 0] 0] == "-"} {
          catch {eval channel set $chan $settings}
        } else {
          catch {channel set $chan [lindex $settings 0] [lrange $settings 1 end]}
        }
      }
    }
  }
  return 0
}

proc nb_dccnettcl {hand idx arg} {
  global nb_control nb_tclarg nb_tclreturn
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# nettcl $arg"
  if {$arg == ""} {
    putidx $idx "Usage: nettcl <command>" ; return 0
  }
  putidx $idx "Executing command '$arg' on netbots."
  set nb_tclarg $arg
  if {[nb_control]} {
    uplevel #0 {catch $nb_tclarg nb_tclreturn}
    putidx $idx "Tcl: $nb_tclreturn"
    unset nb_tclarg nb_tclreturn
  }
  nb_sendcmd $nb_control nettcl [list $hand $idx $arg]
  return 0
}

proc nb_nettcl {frombot arg} {
  global nb_tclcmd nb_tclreturn
  set nb_tclcmd [lindex $arg 2]
  putlog "netbots \[[lindex $arg 0]@$frombot\]: executing tcl command '$nb_tclcmd'."
  uplevel #0 {catch $nb_tclcmd nb_tclreturn}
  nb_sendcmd $frombot rnettcl [list [lindex $arg 1] $nb_tclreturn]
  unset nb_tclcmd nb_tclreturn
  return 0
}

proc nb_rnettcl {frombot arg} {
  putidx [lindex $arg 0] "$frombot: Tcl: [lindex $arg 1]"
  return 0
}

proc nb_dccnetupdate {hand idx arg} {
  global nb_control nb_flag nb_sending
  if {![nb_checkowner $hand $idx]} {return 0}
  putcmdlog "#$hand# netupdate $arg"
  set command [lindex [split $arg] 0]
  switch -exact -- $command {
    "-config" {set file "config"}
    "-motd" {set file "motd"}
    "-banner" {set file "telnet-banner"}
    "-settings" {set file "settings"}
    "-scripts" {set file "scripts"}
    "-everything" {set file "everything"}
    "-changed" {set file "changed"}
    "-file" {set file [lrange [split $arg] 1 end]}
    "default" {set file "settings/scripts"}
  }
  if {[string match -* $command]} {
    if {$file == "settings/scripts"} {
      putidx $idx "Valid options are: -config, -motd, -banner, -settings, -scripts, -changed, -everything, -file" ; return 0
    }
    if {$command != "-file"} {
      set bot [lindex [split $arg] 1]
    } else {
      if {$arg == ""} {
        putidx $idx "You must specify a file." ; return 0
      }
      set bot ""
      foreach filearg $file {
        if {[matchattr $filearg $nb_flag] || [islinked $filearg]} {
          set bot $filearg ; break
        }
        if {[set globfiles [glob -nocomplain -- $filearg]] == ""} {
          putidx $idx "No files matched by the pattern $filearg" ; continue
        } else {
          foreach globfile $globfiles {
            if {![file exists $globfile] || [file isdirectory $globfile]} {
              putidx $idx "File '$globfile' does not exist." ; continue
            }
            lappend files $globfile
          }
        }
      }
      if {![info exists files]} {
        putidx $idx "You must specify a file." ; return 0
      } else {
        set file $files
      }
    }
  } else {
    set bot [lindex [split $arg] 0]
  }
  if {[isbotnetnick $bot]} {
    putidx $idx "Cannot send files to myself." ; return 0
  }
  if {$bot == ""} {
    if {[bots] == ""} {
      putidx $idx "There are no linked bots." ; return 0
    }
    putidx $idx "Initiating transfer of $file to netbots.."
    nb_sendcmd $nb_control netupdate [list initiate $file $hand]
  } else {
    if {$nb_flag != "all" && ![matchattr $bot $nb_flag]} {
      putidx $idx "$bot is not a valid netbot." ; return 0
    }
    if {![islinked $bot]} {
      putidx $idx "$bot is not on the botnet." ; return 0
    }
    if {[info exists nb_sending([string tolower $bot])]} {
      putidx $idx "File transfer to $bot is already active." ; return 0
    }
    putidx $idx "Initiating transfer of $file to $bot.."
    nb_sendcmd $bot netupdate [list initiate $file $hand]
  }
  return 0
}

proc nb_netupdate {frombot arg} {
  global config motd nb_dir nb_files nb_getting nb_lines nb_netupdate nb_script nb_scripts nb_setscript nb_timeout telnet-banner
  switch -exact -- [lindex $arg 0] {
    "initiate" {
      if {$nb_getting} {return 0}
      set file [lindex $arg 1] ; set hand [lindex $arg 2]
      if {$hand != ""} {
        putlog "netbots \[$hand@$frombot\]: initiating $file update.."
      } else {
        putlog "netbots \[$frombot\]: initiating $file update.."
      }
      switch -exact -- $file {
        "config" {set intfiles $config}
        "motd" {set intfiles $motd}
        "telnet-banner" {
          if {[info exists telnet-banner]} {
            set intfiles ${telnet-banner}
          }
        }
        "settings" {set intfiles $nb_setscript}
        "scripts" {set intfiles $nb_scripts}
        "settings/scripts" {set intfiles [concat $nb_setscript $nb_scripts]}
        "changed" -
        "everything" {
          if {[info exists telnet-banner]} {
            set intfiles [concat $nb_setscript $nb_scripts $config $motd ${telnet-banner}]
          } else {
            set intfiles [concat $nb_setscript $nb_scripts $config $motd]
          }
        }
        "default" {set intfiles $file}
      }
      foreach intfile $intfiles {
        lappend files [list $intfile [nb_md5get $intfile]]
      }
      nb_sendcmd $frombot rnetupdate [list send $file $files]
    }
    "wait" {
      if {$nb_getting} {return 0}
      set file [lindex $arg 1]
      putlog "netbots: $frombot is busy, waiting to try again.."
      set nb_getting 1
      switch -exact -- $file {
        "scripts" -
        "settings/scripts" {
          utimer [expr 20 + [rand 21]] [list nb_wait $frombot $file]
        }
        "everything" {
          utimer [expr 20 + [rand 31]] [list nb_wait $frombot $file]
        }
        "default" {
          utimer [expr 10 + [rand 11]] [list nb_wait $frombot $file]
        }
      }
    }
    "start" {
      if {$nb_getting} {return 0}
      set file [lindex $arg 1]
      set nb_getting 1
      putlog "netbots: downloading $file from $frombot"
      utimer $nb_timeout [list nb_timeout getting $frombot $file]
      set nb_lines ""
    }
    "write" {
      set nb_lines [lindex $arg 1]
    }
    "close" {
      if {!$nb_getting} {return 0}
      set filename [lindex $arg 1]
      lappend nb_files [list $filename [file tail $filename].tmp [lindex $arg 2] $nb_lines]
      set nb_lines ""
    }
    "end" {
      if {!$nb_getting} {return 0}
      set file [lindex $arg 1]
      if {![info exists nb_files]} {
        putlog "netbots: no files need to be downloaded."
        nb_sendcmd $frombot rnetupdate [list nofiles $file]
        nb_killutimer "nb_timeout getting $frombot *"
        set nb_getting 0
        return 0
      }
      foreach filepack $nb_files {
        set tmpfile [lindex $filepack 1]
        lappend tmplist $tmpfile
        set wfile [open $tmpfile w]
        fconfigure $wfile -translation binary
        puts -nonewline $wfile [lindex $filepack 3]
        close $wfile
      }
      foreach filepack $nb_files {
        set filename [lindex $filepack 0]
        set chksize [lindex $filepack 2]
        if {[catch {file size [lindex $filepack 1]} filesize]} {
          set filesize 0
        }
        if {$filesize != $chksize || $chksize == 0} {
          putlog "netbots: error on $file download from $frombot - filesize mismatch for $filename (expected $chksize bytes, got $filesize [nb_plural byte bytes $filesize])."
          nb_sendcmd $frombot rnetupdate [list fserror $file]
          nb_killutimer "nb_timeout getting $frombot *"
          eval file delete -- [join $tmplist]
          unset nb_files
          set nb_getting 0
          return 0
        }
        if {[set dir [file dirname $filename]] != "."} {
          if {![file exists $dir]} {
            putlog "netbots: creating directory '$dir'.."
            file mkdir $dir
          } elseif {![file isdirectory $dir]} {
            putlog "netbots: error on $file download from $frombot - '$dir' exists but is not a directory."
            nb_sendcmd $frombot rnetupdate [list direrror $file]
            nb_killutimer "nb_timeout getting $frombot *"
            eval file delete -- [join $tmplist]
            unset nb_files
            set nb_getting 0
            return 0
          }
        }
      }
      set downloaded 0
      foreach filepack $nb_files {
        set filename [lindex $filepack 0]
        file rename -force -- [lindex $filepack 1] $filename
        if {$filename == $config} {
          catch {exec chmod 700 $filename}
        } else {
          catch {exec chmod 600 $filename}
        }
        if {$nb_netupdate == 2} {
          if {[catch {file mtime $filename} filemtime]} {
            set filemtime 0
          }
          nb_md5write $filename $filemtime [md5 [lindex $filepack 3]]
        }
        incr downloaded
      }
      nb_killutimer "nb_timeout getting $frombot *"
      unset nb_files
      nb_sendcmd $frombot rnetupdate [list end $file]
      if {$file == "config" || $file == "changed" || $file == "everything"} {
        putlog "netbots: $file download complete (updated $downloaded [nb_plural file files $downloaded]), rehashing.."
        utimer 3 rehash
        utimer 5 {set nb_getting 0}
      } elseif {$file == "settings" || $file == "scripts" || $file == "settings/scripts"} {
        # more efficient than rehashing, but use of nb_component outside netset.tcl will fail
        putlog "netbots: $file download complete (updated $downloaded [nb_plural file files $downloaded]), resourcing.."
        utimer 3 [list source $nb_script]
        utimer 5 {set nb_getting 0}
      } else {
        putlog "netbots: $file download complete (updated $downloaded [nb_plural file files $downloaded])."
        set nb_getting 0
      }
    }
    "ferror" {
      putlog "netbots: error - $frombot cannot find file '[lindex $arg 1]'."
    }
  }
  return 0
}

proc nb_rnetupdate {frombot arg} {
  global nb_max nb_netupdate nb_sending nb_timeout
  set file [lindex $arg 1]
  switch -exact -- [lindex $arg 0] {
    "initiate" {
      if {[info exists nb_sending([string tolower $frombot])]} {return 0}
      nb_sendcmd $frombot netupdate [list initiate $file]
    }
    "send" {
      set filenames [lindex $arg 2]
      set stlfrombot [string tolower $frombot]
      if {[info exists nb_sending($stlfrombot)]} {return 0}
      if {[llength [array names nb_sending]] >= $nb_max} {
        nb_sendcmd $frombot netupdate [list wait $file]
        return 0
      }
      foreach filename $filenames {
        set filename [lindex $filename 0]
        if {![file exists $filename]} {
          putlog "netbots: error - cannot find file '$filename' (requested by $frombot)."
          nb_sendcmd $frombot netupdate [list ferror $filename]
          return 0
        }
      }
      putlog "netbots: sending $file to $frombot"
      set nb_sending($stlfrombot) 1
      utimer $nb_timeout [list nb_timeout sending $frombot $file]
      nb_sendcmd $frombot netupdate [list start $file]
      set clockseconds [unixtime]
      foreach filename $filenames {
        set filenamemd5 [lindex $filename 1]
        set filename [lindex $filename 0]
        if {$filenamemd5 != 0 && $filenamemd5 == [nb_md5get $filename]} {
          continue
        }
        if {[catch {file mtime $filename} filemtime]} {
          set filemtime 0
        }
        if {$file == "changed" && [expr $clockseconds - $filemtime] >= 86400} {
          continue
        }
        set rfile [open $filename r]
        fconfigure $rfile -translation binary
        set fstring [read $rfile]
        close $rfile
        if {$nb_netupdate == 2} {
          nb_md5write $filename $filemtime [md5 $fstring]
        }
        nb_sendcmd $frombot netupdate [list write $fstring]
        if {[catch {file size $filename} filesize]} {
          set filesize 0
        }
        nb_sendcmd $frombot netupdate [list close $filename $filesize]
      }
      nb_sendcmd $frombot netupdate [list end $file]
    }
    "end" {
      set stlfrombot [string tolower $frombot]
      nb_killutimer "nb_timeout sending $frombot *"
      if {[info exists nb_sending($stlfrombot)]} {
        unset nb_sending($stlfrombot)
      }
      putlog "netbots: completed $file transfer to $frombot"
    }
    "fserror" {
      set stlfrombot [string tolower $frombot]
      nb_killutimer "nb_timeout sending $frombot *"
      if {[info exists nb_sending($stlfrombot)]} {
        unset nb_sending($stlfrombot)
      }
      putlog "netbots: error on $file transfer to $frombot - filesize mismatch."
    }
    "direrror" {
      set stlfrombot [string tolower $frombot]
      nb_killutimer "nb_timeout sending $frombot *"
      if {[info exists nb_sending($stlfrombot)]} {
        unset nb_sending($stlfrombot)
      }
      putlog "netbots: error on $file transfer to $frombot - $frombot is unable to create directory."
    }
    "nofiles" {
      set stlfrombot [string tolower $frombot]
      nb_killutimer "nb_timeout sending $frombot *"
      if {[info exists nb_sending($stlfrombot)]} {
        unset nb_sending($stlfrombot)
      }
      putlog "netbots: no files need to be sent to $frombot"
    }
  }
  return 0
}

proc nb_md5write {file mtime md5sum} {
  global nb_dir nb_md5
  set nb_md5($file) [list $mtime $md5sum]
  set wfile [open $nb_dir/nbmd5 w]
  foreach filename [array names nb_md5] {
    puts $wfile [list $filename [lindex $nb_md5($filename) 0] [lindex $nb_md5($filename) 1]]
  }
  close $wfile
  return
}

proc nb_md5get {file} {
  global nb_md5
  if {[info exists nb_md5($file)] && [set md5time [lindex $nb_md5($file) 0]] && ![catch {file mtime $file} filemtime] && $md5time == $filemtime} {
    return [lindex $nb_md5($file) 1]
  }
  return 0
}

proc nb_md5load {} {
  global nb_dir nb_md5
  if {[file readable $nb_dir/nbmd5]} {
    set file [open $nb_dir/nbmd5 r]
    set lines [split [read -nonewline $file] \n]
    close $file
    foreach line $lines {
      if {[llength $line] == 3} {
        set nb_md5([lindex $line 0]) [list [lindex $line 1] [lindex $line 2]]
      }
    }
  }
  return
}

if {$nb_netupdate != 2} {
  proc nb_md5get {file} {
    return 0
  }
  rename nb_md5write ""
  rename nb_md5load ""
}

proc nb_wait {frombot file} {
  global config motd nb_getting nb_scripts nb_setscript telnet-banner
  set nb_getting 0
  switch -exact -- $file {
    "config" {set intfiles $config}
    "motd" {set intfiles $motd}
    "telnet-banner" {
      if {[info exists telnet-banner]} {
        set intfiles ${telnet-banner}
      }
    }
    "settings" {set intfiles $nb_setscript}
    "scripts" {set intfiles $nb_scripts}
    "settings/scripts" {set intfiles [concat $nb_setscript $nb_scripts]}
    "changed" -
    "everything" {
      if {[info exists telnet-banner]} {
        set intfiles [concat $nb_setscript $nb_scripts $config $motd ${telnet-banner}]
      } else {
        set intfiles [concat $nb_setscript $nb_scripts $config $motd]
      }
    }
    "default" {set intfiles $file}
  }
  foreach intfile $intfiles {
    lappend files [list $intfile [nb_md5get $intfile]]
  }
  nb_sendcmd $frombot rnetupdate [list send $file $files]
  return 0
}

proc nb_timeout {action bot file} {
  global nb_files nb_getting nb_lines nb_sending
  switch -exact -- $action {
    "getting" {
      putlog "netbots: timed out $file download from $bot"
      if {[info exists nb_lines]} {
        unset nb_lines
      }
      if {[info exists nb_files]} {
        unset nb_files
      }
      set nb_getting 0
    }
    "sending" {
      putlog "netbots: timed out $file transfer to $bot"
      if {[info exists nb_sending([string tolower $bot])]} {
        unset nb_sending([string tolower $bot])
      }
    }
  }
  return 0
}

proc nb_chanset {chan} {
  global global-aop-delay global-chanmode global-chanset global-flood-chan global-flood-ctcp global-flood-deop global-flood-join global-flood-kick global-flood-nick global-idle-kick global-revenge-mode global-stopnethack-mode
  if {[info exists global-aop-delay]} {
    channel set $chan aop-delay ${global-aop-delay}
  }
  if {[info exists global-chanmode]} {
    channel set $chan chanmode ${global-chanmode}
  }
  if {[info exists global-chanset]} {
    foreach chanset ${global-chanset} {
      catch {channel set $chan $chanset}
    }
  }
  if {[info exists global-flood-chan]} {
    channel set $chan flood-chan ${global-flood-chan}
  }
  if {[info exists global-flood-ctcp]} {
    channel set $chan flood-ctcp ${global-flood-ctcp}
  }
  if {[info exists global-flood-deop]} {
    channel set $chan flood-deop ${global-flood-deop}
  }
  if {[info exists global-flood-join]} {
    channel set $chan flood-join ${global-flood-join}
  }
  if {[info exists global-flood-kick]} {
    channel set $chan flood-kick ${global-flood-kick}
  }
  if {[info exists global-flood-nick]} {
    channel set $chan flood-nick ${global-flood-nick}
  }
  if {[info exists global-idle-kick]} {
    channel set $chan idle-kick ${global-idle-kick}
  }
  if {[info exists global-stopnethack-mode]} {
    channel set $chan stopnethack-mode ${global-stopnethack-mode}
  }
  if {[info exists global-revenge-mode]} {
    channel set $chan revenge-mode ${global-revenge-mode}
  }
  return 0
}

proc nb_update {min hour day month year} {
  global nb_dir nb_numver nb_update
  if {[catch {package require http}]} {
    putlog "netbots: error - update check cannot find package 'http' (you should probably disable nb_update on this bot)."
    return 0
  }
  foreach recipient [split $nb_update] {
    if {[validuser $recipient]} {
      lappend recipients $recipient
    }
  }
  if {![info exists recipients]} {
    putlog "netbots: error - update check recipients '$nb_update' are invalid."
    return 0
  }
  set unumver $nb_numver
  if {[file exists $nb_dir/nbupdate]} {
    set rfile [open $nb_dir/nbupdate r]
    set lines [split [read $rfile] \n]
    close $rfile
    if {![string is integer -strict [lindex $lines 1]]} {
      putlog "netbots: error - update check file $nb_dir/nbupdate is corrupt (try deleting it)."
      return 0
    } else {
      if {[expr [unixtime] - [lindex $lines 0]] < 93600} {
        return 0
      } elseif {[lindex $lines 1] > $nb_numver} {
        set unumver [lindex $lines 1]
      }
    }
  }
  if {[catch {::http::geturl http://www.egghelp.org/netbots/nbupdate3.txt} token]} {
    return 0
  }
  set hlines [split [::http::data $token] \n]
  unset $token
  if {[lindex $hlines 2] != "eof"} {
    return 0
  }
  set hnumver [lindex $hlines 0]
  if {$hnumver > $unumver} {
    foreach recipient $recipients {
      sendnote NETBOTS $recipient [lindex $hlines 1]
    }
  }
  set wfile [open $nb_dir/nbupdate w]
  puts -nonewline $wfile "[unixtime]\n$hnumver"
  close $wfile
  return 0
}

proc nb_chon {hand idx} {
  global botnet-nick nb_chon nb_control nb_defctrl nb_flag nb_ver
  set nb_control $nb_defctrl
  if {$nb_chon} {
    if {[matchattr $hand mnt]} {
      set bots [expr [llength [bots]] + 1]
      putidx $idx " "
      putidx $idx "Running netbots.tcl $nb_ver"
      putidx $idx "  $bots [nb_plural bot bots $bots] on the botnet."
      if {$nb_flag != "b" && $nb_flag != "all"} {
        set botlist ${botnet-nick}
        set offline ""
        foreach netbot [userlist $nb_flag] {
          if {[isbotnetnick $netbot]} {continue}
          if {[islinked $netbot]} {
            lappend botlist $netbot
          } else {
            lappend offline $netbot
          }
        }
        if {$botlist == ""} {
          putidx $idx "  No netbots linked."
        } else {
          set bots [llength $botlist]
          if {$offline != ""} {
            putidx $idx "  $bots [nb_plural netbot netbots $bots] ([llength $offline] offline or not linked: [join $offline ", "])."
          } else {
            putidx $idx "  $bots [nb_plural netbot netbots $bots] (all netbots online and linked)."
          }
        }
      }
    }
    set partylist ""
    putidx $idx " "
    foreach partydude [whom *] {
      if {[lindex $partydude 0] == $hand} {continue}
      lappend partylist [lindex $partydude 0]@[lindex $partydude 1]
    }
    if {$partylist == ""} {
      putidx $idx "There are no other users on the bot or party line."
      putidx $idx " "
    } else {
      putidx $idx "Other users on the bot and party line: [join $partylist ", "]"
      putidx $idx " "
    }
    nb_sendcmd * rbroadcast "$hand has logged in."
  }
  return 0
}

proc nb_chof {hand idx} {
  nb_sendcmd * rbroadcast "$hand has logged out."
  return 0
}

proc nb_sighup {type} {
  nb_sendcmd * rbroadcast "Received SIGHUP!" ; return 0
}

proc nb_sigterm {type} {
  nb_sendcmd * rbroadcast "Received SIGTERM!" ; return 0
}

proc nb_svkline {from keyword arg} {
  nb_sendcmd * rbroadcast "KLINED from $from: [string range [string trimleft $arg :] 0 150]" ; return 0
}

proc nb_svconnect {from keyword arg} {
  global nb_realserver
  set nb_realserver $from
  if {$nb_realserver == ""} {
    unset nb_realserver
  }
  nb_sendcmd * rbroadcast "Connected to $from" ; return 0
}

proc nb_cmdcast {idx text} {
  global nb_castfilter
  set hand [idx2hand $idx] ; set cmd [string tolower [lindex [split $text] 0]]
  if {![catch {getchan $idx} chan]} {
    if {$chan == -1} {
      set cmd .[string trimleft $cmd "."]
    } elseif {![string match ".*" $cmd]} {
      return $text
    }
    if {[lsearch -exact $nb_castfilter $cmd] != -1} {
      nb_sendcmd * rbroadcast "#$hand# [string trimleft [lindex [split $text] 0] "."] .."
    } else {
      nb_sendcmd * rbroadcast "#$hand# [string trimleft [string range $text 0 399] "."]"
    }
  }
  return $text
}

proc nb_broadcast {frombot arg} {
  global nb_broadcast
  if {$nb_broadcast == ""} {return 0}
  foreach dccuser [dcclist] {
    if {[lindex $dccuser 3] == "CHAT"} {
      set idx [lindex $dccuser 0]
      if {[matchattr [idx2hand $idx] $nb_broadcast]} {
        putidx $idx "\[$frombot\]: $arg"
      }
    }
  }
  return 0
}

proc nb_control {} {
  global botnet-nick nb_control
  if {$nb_control == "*" || [lsearch -exact [split [string tolower $nb_control] ,] [string tolower ${botnet-nick}]] != -1} {return 1}
  return 0
}

proc nb_sendcmd {to cmd arg} {
  global botnet-nick nb_flag nb_key
  set key [encrypt $nb_key [list ${botnet-nick} $cmd $arg]]
  while {$key != ""} {
    lappend skey [string range $key 0 390]
    set key [string range $key 391 end]
  }
  if {$to == "*"} {
    if {$nb_flag == "all"} {
      if {[llength $skey] > 1} {
        set sid [expr [rand 999] + 1]
        foreach key $skey {
          putallbots "nb [list $sid $key]"
        }
        putallbots "nb $sid"
      } else {
        putallbots "nb [list 0 $skey]"
      }
    } else {
      foreach bot [userlist $nb_flag] {
        if {[islinked $bot]} {
          if {[llength $skey] > 1} {
            set sid [expr [rand 999] + 1]
            foreach key $skey {
              putbot $bot "nb [list $sid $key]"
            }
            putbot $bot "nb $sid"
          } else {
            putbot $bot "nb [list 0 $skey]"
          }
        }
      }
    }
  } else {
    foreach bot [split $to ,] {
      if {[islinked $bot]} {
        if {[llength $skey] > 1} {
          set sid [expr [rand 999] + 1]
          foreach key $skey {
            putbot $bot "nb [list $sid $key]"
          }
          putbot $bot "nb $sid"
        } else {
          putbot $bot "nb [list 0 $skey]"
        }
      }
    }
  }
  return 0
}

proc nb_gotcmd {frombot cmd arg} {
  global nb_ctrlbot nb_ctrlbots nb_flag nb_gbuffer nb_key nb_netcmds nb_nettcl nb_netupdate
  if {$nb_flag != "all" && ![matchattr $frombot $nb_flag]} {return 0}
  if {[catch {llength $arg}]} {
    putlog "netbots: rejected command from $frombot (malformed data)." ; return 0
  }
  if {[set sid [lindex $arg 0]]} {
    set skey [lindex $arg 1]
    if {$skey != ""} {
      append nb_gbuffer($sid) $skey
      return 0
    }
    set arg [decrypt $nb_key [append nb_gbuffer($sid) $skey]]
    unset nb_gbuffer($sid)
  } else {
    set arg [decrypt $nb_key [lindex $arg 1]]
  }
  if {[lindex $arg 0] != $frombot} {
    putlog "netbots: rejected command from $frombot (incorrect key)." ; return 0
  }
  set command [lindex $arg 1]
  if {![string match "r*" $command]} {
    if {[array exists nb_ctrlbots]} {
      if {[lsearch -exact $nb_ctrlbot(*) $command] == -1} {
        set stlfrombot [string tolower $frombot]
        if {((![info exists nb_ctrlbot($stlfrombot)]) || (($nb_ctrlbot($stlfrombot) != "*") && ([lsearch -exact $nb_ctrlbot($stlfrombot) $command] == -1)))} {
          putlog "netbots: rejected command from $frombot (not a control bot)." ; return 0
        }
      }
    } else {
      if {$nb_ctrlbots != "" && [lsearch -exact $nb_ctrlbots [string tolower $frombot]] == -1} {
        putlog "netbots: rejected command from $frombot (not a control bot)." ; return 0
      }
    }
  }
  set args [lindex $arg 2]
  switch -exact -- $command {
    "netbots" {nb_netbots $frombot $args}
    "netinfo" {nb_netinfo $frombot $args}
    "rnetinfo" {nb_rnetinfo $frombot $args}
    "netshell" {nb_netshell $frombot $args}
    "rnetshell" {nb_rnetshell $frombot $args}
    "netserv" {nb_netserv $frombot $args}
    "rnetserv" {nb_rnetserv $frombot $args}
    "netpass" {nb_netpass $frombot $args}
    "rnetpass" {nb_rnetpass $frombot $args}
    "netsave" {nb_netsave $frombot $args}
    "nethash" {nb_nethash $frombot $args}
    "netsay" {nb_netsay $frombot $args}
    "netact" {nb_netact $frombot $args}
    "netnotc" {nb_netnotc $frombot $args}
    "netdump" {nb_netdump $frombot $args}
    "netnick" {nb_netnick $frombot $args}
    "netjump" {nb_netjump $frombot $args}
    "netjoin" {nb_netjoin $frombot $args}
    "netpart" {nb_netpart $frombot $args}
    "netchanset" {nb_netchanset $frombot $args}
    "nettcl" {
      if {$nb_nettcl} {nb_nettcl $frombot $args}
    }
    "rnettcl" {
      if {$nb_nettcl} {nb_rnettcl $frombot $args}
    }
    "netupdate" {
      if {$nb_netupdate} {nb_netupdate $frombot $args}
    }
    "rnetupdate" {
      if {$nb_netupdate} {nb_rnetupdate $frombot $args}
    }
    "rbroadcast" {nb_broadcast $frombot $args}
  }
  if {[info exists nb_netcmds($command)]} {
    $nb_netcmds($command) $frombot $args
  }
  return 0
}

proc nb_checkowner {hand idx} {
  global nb_owner owner
  if {$nb_owner && [lsearch -exact [split [string tolower $owner] ", "] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'" ; return 0
  }
  return 1
}

proc nb_chattr {hand idx arg} {
  global nb_flag nb_owner owner
  if {[string match *$nb_flag* [lindex [split $arg] 1]]} {
    if {((![matchattr $hand n]) || (($nb_owner) && ([lsearch -exact [split [string tolower $owner] ", "] [string tolower $hand]] == -1)))} {
      putidx $idx "You do not have access to add/remove the netbot (+$nb_flag) flag."
      return
    }
  }
  *dcc:chattr $hand $idx $arg
}

proc nb_randpass {} {
  set l [expr 8 + [rand 4]]
  for {set x 0} {$x < $l} {incr x} {
    append randpass [string index "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" [rand 62]]
  }
  return $randpass
}

proc nb_randomise {list} {
  set randlist ""
  while {[llength $list] > 0} {
    set random [rand [llength $list]]
    lappend randlist [lindex $list $random]
    set list [lreplace $list $random $random]
  }
  return $randlist
}

proc putwrap {idx ind text} {
# This is probably the ugliest proc I've even written :-)
  set string $text
  set length [expr 69 - $ind]
  set ind [string range "                                        " 0 [expr $ind - 1]]
  while {$string != ""} {
    if {[string length $string] > [expr $length + 1] && [set last [string last " " [string range $string 0 $length]]] != -1} {
      set first [expr $last + 1]
      set last [expr $last - 1]
    } else {
      set last $length
      set first [expr $length + 1]
    }
    putidx $idx $ind[string range $string 0 $last]
    set string [string trimleft [string range $string $first end]]
  }
  return
}

proc nb_plural {word plural llength} {
  if {$llength != 1} {
    return $plural
  }
  return $word
}

proc nb_flag2word {flags} {
  set words ""
  foreach flag [split $flags ""] {
    switch -exact -- $flag {
      "a" {lappend words "auto-ops"}
      "b" {lappend words "bots"}
      "c" {lappend words "commons"}
      "d" {lappend words "deops"}
      "f" {lappend words "friends"}
      "g" {lappend words "auto-voices"}
      "h" {lappend words "high-lights"}
      "j" {lappend words "janitors"}
      "k" {lappend words "auto-kicks"}
      "m" {lappend words "masters"}
      "n" {lappend words "owners"}
      "o" {lappend words "ops"}
      "p" {lappend words "party-lines"}
      "t" {lappend words "botnet masters"}
      "u" {lappend words "unshared"}
      "v" {lappend words "voices"}
      "w" {lappend words "wasop-tests"}
      "x" {lappend words "xfers"}
      "default" {lappend words "+$flag users"}
    }
  }
  if {[llength $words] > 1} {
    return "[join [lrange $words 0 [expr [llength $words] - 2]] ", "] and [lindex $words [expr [llength $words] - 1]]"
  }
  return $words
}

proc nb_killtimer {cmd} {
  set n 0
  regsub -all -- {\[} $cmd {\[} cmd ; regsub -all -- {\]} $cmd {\]} cmd
  foreach tmr [timers] {
    if {[string match $cmd [join [lindex $tmr 1]]]} {
      killtimer [lindex $tmr 2]
      incr n
    }
  }
  return $n
}

proc nb_killutimer {cmd} {
  set n 0
  regsub -all -- {\[} $cmd {\[} cmd ; regsub -all -- {\]} $cmd {\]} cmd
  foreach tmr [utimers] {
    if {[string match $cmd [join [lindex $tmr 1]]]} {
      killutimer [lindex $tmr 2]
      incr n
    }
  }
  return $n
}

proc nb_randport {servers} {
# This proc is based on that used in randomservers.tcl by FireEgl
  set tmpservers ""
  foreach server $servers {
    set ports [lindex [split $server :] 1]
    set pass [lindex [split $server :] 2]
    if {$ports != ""} {
      set portlist ""
      foreach group [split $ports ,] {
        set lowport [lindex [split $group -] 0]
        set highport [lindex [split $group -] 1]
        if {$highport == ""} {
          lappend portlist $lowport
        } else {
          while {$highport >= $lowport} {
            lappend portlist $lowport
            incr lowport
          }
        }
      }
      if {$pass != ""} {
        lappend tmpservers [lindex [split $server :] 0]:[lindex $portlist [rand [llength $portlist]]]:$pass
      } else {
        lappend tmpservers [lindex [split $server :] 0]:[lindex $portlist [rand [llength $portlist]]]
      }
    } else {
      lappend tmpservers $server
    }
  }
  return $tmpservers
}

proc nb_duration {time} {
# This proc is based on that used in Bass's Seen script (http://bseen.tclslave.net)
  set years 0 ; set days 0 ; set hours 0 ; set mins 0
  if {$time < 60} {return "< 1 min"}
  if {$time >= 31536000} {
    set years [expr int([expr $time/31536000])] ; set time [expr $time - [expr 31536000*$years]]
  }
  if {$time >= 86400} {
    set days [expr int([expr $time/86400])] ; set time [expr $time - [expr 86400*$days]]
  }
  if {$time >= 3600} {
    set hours [expr int([expr $time/3600])] ; set time [expr $time - [expr 3600*$hours]]
  }
  if {$time >= 60} {
    set mins [expr int([expr $time/60])]
  }
  if {$years == 0} {
    set output ""
  } elseif {$years == 1} {
    set output "1 yr,"
  } else {
    set output "$years yrs,"
  }
  if {$days == 1} {
    lappend output "1 day,"
  } elseif {$days > 1} {
    lappend output "$days days,"
  }
  if {$hours == 1} {
    lappend output "1 hr,"
  } elseif {$hours > 1} {
    lappend output "$hours hrs,"
  }
  if {$mins == 1} {
    lappend output "1 min"
  } elseif {$mins > 1} {
    lappend output "$mins mins"
  }
  return [string trimright [join $output] ", "]
}

if {[info exists nb_ctrlbot]} {
  unset nb_ctrlbot
}

if {[array exists nb_ctrlbots]} {
  proc nb_setctrlbots {} {
    global nb_ctrlbot nb_ctrlbots
    foreach botgroup [array names nb_ctrlbots] {
      if {$botgroup == "*"} {
        set nb_ctrlbot(*) [split $nb_ctrlbots(*)]
      } else {
        set nb_ctrlbots($botgroup) [string tolower $nb_ctrlbots($botgroup)]
        regsub -all -- "," $botgroup " " bots
        foreach bot [split [string tolower $bots]] {
          if {[isbotnetnick $bot]} {continue}
          set nb_ctrlbot($bot) [split $nb_ctrlbots($botgroup)]
        }
      }
    }
    if {![info exists nb_ctrlbot(*)]} {
      set nb_ctrlbot(*) ""
    }
    return
  }
  nb_setctrlbots
  rename nb_setctrlbots ""
} else {
  set nb_ctrlbots [split [string tolower $nb_ctrlbots] ,]
}

if {![info exists nb_control]} {
  set nb_control $nb_defctrl
}

if {[info exists nb_servers] && [llength $nb_servers] >= 1} {
  set servers [nb_randport [nb_randomise $nb_servers]]
}

if {$nb_netupdate == 2} {
  if {$numversion < 1060000} {
    set nb_netupdate 1
  } elseif {![info exists nb_md5]} {
    nb_md5load
  }
}

if {![info exists nb_getting]} {
  set nb_getting 0
}

set nb_castfilter [split [string tolower $nb_castfilter]]

if {[string length $nb_update]} {
  if {![string length [binds nb_update]]} {
    bind time - "[format "%02d" [expr {[rand 59] + 1}]] [format "%02d" [rand 24]] * * [rand 8]" nb_update
  }
} elseif {[string length [binds nb_update]]} {
  unbind time - [lindex [lindex [binds nb_update] 0] 2] nb_update
}
bind filt - * nb_cmdcast
if {!$nb_cmdcast} {
  unbind filt - * nb_cmdcast
  rename nb_cmdcast ""
}
if {$nb_flag != "b" && $nb_flag != "all"} {
  unbind dcc m|m chattr *dcc:chattr
  bind dcc m|m chattr nb_chattr
} else {
  catch {unbind dcc m|m chattr nb_chattr}
  rename nb_chattr ""
}
bind bot - nb nb_gotcmd
bind dcc - nethelp nb_dccnethelp
bind dcc n components nb_dcccomponents
bind dcc n netbots nb_dccnetbots
bind dcc n netcontrol nb_dccnetcontrol
bind dcc n control nb_dccnetcontrol
bind dcc n netinfo nb_dccnetinfo
bind dcc n netshell nb_dccnetshell
bind dcc n netserv nb_dccnetserv
bind dcc n netpass nb_dccnetpass
bind dcc n netsave nb_dccnetsave
bind dcc n nethash nb_dccnethash
bind dcc n netsay nb_dccnetsay
bind dcc n netact nb_dccnetact
bind dcc n netnotice nb_dccnetnotc
bind dcc n netdump nb_dccnetdump
bind dcc n netnick nb_dccnetnick
bind dcc n netjump nb_dccnetjump
bind dcc n netjoin nb_dccnetjoin
bind dcc n netpart nb_dccnetpart
bind dcc n netchanset nb_dccnetchanset
bind dcc n nettcl nb_dccnettcl
if {!$nb_nettcl} {
  unbind dcc n nettcl nb_dccnettcl
  rename nb_dccnettcl ""
}
bind dcc n netupdate nb_dccnetupdate
if {!$nb_netupdate} {
  unbind dcc n netupdate nb_dccnetupdate
  rename nb_dccnetupdate ""
}
bind chon - * nb_chon
bind chof - * nb_chof
if {!$nb_chon} {
  unbind chof - * nb_chof
  rename nb_chof ""
}
if {$numversion >= 1032800} {
  bind evnt - sighup nb_sighup ; bind evnt - sigterm nb_sigterm
}
catch {bind raw - 001 nb_svconnect}
catch {bind raw - 465 nb_svkline}

set nb_components(netbots) "[string index $nb_numver 0].[string range $nb_numver 1 2].[string index $nb_numver 3]"

set nb_scripts $nb_script

if {[info exists nb_component]} {
  foreach nb_lcomponent [lsort [array names nb_component]] {
    if {!$nb_component($nb_lcomponent)} {continue}
    set nb_lsource $nb_dir/$nb_lcomponent.tcl
    lappend nb_scripts $nb_lsource
    if {[file readable $nb_lsource] && [file isfile $nb_lsource]} {
      if {$nb_netupdate == 2} {
        if {[catch {file mtime $nb_lsource} filemtime]} {
          set filemtime 0
        }
        set rfile [open $nb_lsource r]
        fconfigure $rfile -translation binary
        set fstring [read $rfile]
        close $rfile
        nb_md5write $nb_lsource $filemtime [md5 $fstring]
      }
      if {[catch {source $nb_lsource} nb_error]} {
        putlog "*** WARNING: error found when loading $nb_lsource:"
        putlog $nb_error
        utimer 3 [list nb_berror $nb_lsource]
        return
      }
      if {[lindex [split $nb_error] 0] == "nb_info"} {
        set nb_components($nb_lcomponent) [lrange [split $nb_error] 1 end]
      } else {
        set nb_components($nb_lcomponent) ""
      }
    } else {
      putlog "Unable to load component '$nb_lcomponent' - $nb_lsource is not readable or doesn't exist."
    }
  }
}
if {[info exists nb_lcomponent]} {
  unset nb_lcomponent
}
if {[info exists nb_lsource]} {
  unset nb_lsource
}
if {[info exists nb_error]} {
  unset nb_error
}

putlog "Loaded components: [join [lsort [array names nb_components]] ", "]"

set nb_ucomponents ""
foreach nb_lcomponent [array names nb_components] {
  if {[string compare $nb_lcomponent "netbots"] == 0} {
    continue
  }
  if {![info exists nb_component($nb_lcomponent)] || !$nb_component($nb_lcomponent)} {
    lappend nb_ucomponents $nb_lcomponent
  }
}
if {[string length $nb_ucomponents]} {
  putlog "The following components will be unloaded the next time the bot is restarted: [join [lsort $nb_ucomponents] ", "]"
} else {
  unset nb_ucomponents
}
if {[info exists nb_lcomponent]} {
  unset nb_lcomponent
}

return
