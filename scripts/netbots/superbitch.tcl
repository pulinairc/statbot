# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## superbitch.tcl component script ##

proc sb_bitch {nick uhost hand chan mode opped} {
  global botnick sb_chans sb_canop sb_canopany sb_canopflags sb_checkop sb_note sb_remove
  if {$mode == "+o"} {
    if {$nick != $botnick} {
      if {(($opped != $botnick) && ($nick != $opped) && ([onchan $nick $chan]) && (![wasop $opped $chan]) && (($sb_chans == "") || ([lsearch -exact $sb_chans [string tolower $chan]] != -1)))} {
        if {![matchattr [nick2hand $opped $chan] $sb_canopflags $chan]} {
          if {$sb_canopany == "" || ![matchattr $hand $sb_canopany $chan]} {
            pushmode $chan -o $opped
            pushmode $chan -o $nick
            if {$sb_remove && [validuser $hand] && [matchattr $hand o|o $chan]} {
              chattr $hand -o+d|-o+d $chan
              if {[info commands sendnote] != ""} {
                foreach recipient $sb_note {
                  if {[validuser $recipient]} {
                    sendnote SUPERBITCH $recipient "Removed +o from $hand (opped $opped on $chan)"
                  }
                }
              }
            }
          }
        } else {
          if {((($sb_canopany == "") || (![matchattr $hand $sb_canopany $chan])) && (($sb_canop == "") || (![matchattr $hand $sb_canop $chan])))} {
            pushmode $chan -o $opped
            pushmode $chan -o $nick
            if {$sb_remove && [validuser $hand] && [matchattr $hand o|o $chan]} {
              chattr $hand -o+d|-o+d $chan
              if {[info commands sendnote] != ""} {
                foreach recipient $sb_note {
                  if {[validuser $recipient]} {
                    sendnote SUPERBITCH $recipient "Removed +o from $hand (opped $opped on $chan)"
                  }
                }
              }
            }
          }
        }
      }
    } else {
      if {(($sb_checkop) && (![matchattr [nick2hand $opped $chan] o|o $chan]) && (($sb_chans == "") || ([lsearch -exact $sb_chans [string tolower $chan]] != -1)))} {
        pushmode $chan -o $opped
        putlog "superbitch: opped non +o user $opped on $chan - reversing."
        nb_sendcmd * rbroadcast "superbitch: opped non +o user $opped on $chan - reversing."
      }
    }
  }
  return 0
}

set sb_chans [split [string tolower $sb_chans]] ; set sb_note [split $sb_note]

bind mode - * sb_bitch

return "nb_info 4.10.0"
