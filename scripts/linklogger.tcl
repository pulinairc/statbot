#####################################################
#  link logger v 1.1 by m00nie
#         www.m00nie.com
#
#   Mostly written as a way to practice TCL....
# V1.1 Added Global Stats
# V1.0 Original release
#####################################################
# Settings to edit below
#####################################################
# chan to use
set linklog(chanset) "#pulina"

# Debug? Enabling debug is very verbose!
set linklog(debug) 0

# Users to ignore? E.g other bots
set linklog(ignore) "some people"

# Command to search for link
set linklog(call) "!link"

# Command for stats
set linklog(stats) "!linkstats"

# Location of the file to store links
set linklog(location) "/home/rolle/eggdrop/links_"

# output line start
set linklog(out) "\002\[\002Link\002\]\002 "


#####################################################
# No need to edit anything from below here
#####################################################

set linklog(debugstring) "Link Logger Debug: "

bind pub - $linklog(call) linkcall 
bind pub - $linklog(stats) linkstats
bind pubm - "$linklog(chanset) *://*" linklogger

###################
# Link logging process
###################
proc linklogger {nick host hand chan arg} {
  global linklog
  if {$linklog(debug) == 1} {
    putlog "$linklog(debugstring) nick = $nick"
    putlog "$linklog(debugstring) host = $host"
    putlog "$linklog(debugstring) hand = $hand"
    putlog "$linklog(debugstring) chan = $chan"
    putlog "$linklog(debugstring) arg = $arg"
  }
  ###################
  # Checking the channel has been set
  ###################
        
  if {$chan != $linklog(chanset)} {
    if {$linklog(debug) == 1} {
      putlog "$linklog(debugstring) $chan is not set to log links!"
      putlog "$linklog(debugstring) chan is set to $linklog(chanset)"
      return
    }
  return
  }
  ###################
  # Check is user ignored
  ###################
  set linklog(ignoretest) [regexp -nocase $nick $linklog(ignore)]
  if {$linklog(ignoretest) == 1} {
     if {$linklog(debug) == 1} {
      puts "$linklog(debugstring) $nick is being ignored"
      puts "$linklog(debugstring) Ingnore variable is $linklog(ignore)"
      return
     }
  return
  }
  ###################
  # Check for a link
  ###################
  if {[regexp -- {(https?://[a-z0-9\-]+\.[a-z0-9\-\.]+(?:/|(?:/[a-zA-Z0-9!#\$%&'\*\+,\-\.:;=\?@\[\]_~]+)*))} $arg match linklog(url)]} {
    if {$linklog(debug) == 1} {
      putlog "$linklog(debugstring) Found link, chan set and not ignoring user!"
      putlog "Link is $linklog(url)"
    }
    ###################
    # Open the file append and close
    ###################
    set time [clock seconds]
    set linklog(fileappend) [open $linklog(location)$nick a]
    if {$linklog(debug) == 1} {
      putlog "$linklog(debugstring) File $linklog(location) opened at $time"
    }
    puts $linklog(fileappend) "Linked to $linklog(url) @ [clock format $time]"
    close $linklog(fileappend) 
    if {$linklog(debug) == 1} {
      putlog "$linklog(debugstring) File $linklog(location) closed"
    }
  } else {
    if {$linklog(debug) == 1} {
      putlog "$linklog(debugstring) This shouldnt really happen....."
      putlog "$linklog(debugstring) Channel set, user not ignored but no valid link!"
    }
}
}

###################
# Link searching
###################
proc linkcall {nick host hand chan arg} {
  global linklog
  ###################
  # Check for no arguments then spam help
  ###################
  if {[string length $arg] < 1} {
                puthelp "PRIVMSG $chan :usage: $linklog(call) <username>"
    puthelp "PRIVMSG $chan :usage: $linklog(stats) <username>"
    puthelp "PRIVMSG $chan :usage: $linklog(stats) for global stats"  
    return
  }
  if {$linklog(debug) == 1} {
    putlog "$linklog(debugstring) $linklog(call) triggered linkcall"
    putlog "$linklog(debugstring) The argument was $arg"
  }
  ###################
  # Check a file exists
  ###################
  set linklog(fileresult) [linkfilecheck $linklog(location)$arg]
  if {$linklog(fileresult) != 1} {
    puthelp "PRIVMSG $chan $linklog(out) No links found for $arg :("
    putlog "$linklog(debugstring) File $linklog(location)$arg doesnt exist??"
    return
  }
  ###################
  # Open and read the file line by line
  ###################
  set loop 0
  set linklog(fileopen) [open $linklog(location)$arg r]
  set lines [split [read -nonewline $linklog(fileopen)] "\n"]
  puthelp "PRIVMSG $chan $linklog(out) $arg's most recent links"
  if {$linklog(debug) == 1} {
    putlog "$linklog(debugstring) $linklog(location)$arg File open and split"
  }
  for {set i [llength $lines]} {$i} {incr i -1} {
    set line [lindex $lines $i-1]
    if {$loop > 2} {
      return
    }
    puthelp "PRIVMSG $chan $line"
          if {$linklog(debug) == 1} {
                        putlog "$linklog(debugstring) loop = $loop "
                } 
    incr loop
  }
  close $linklog(fileopen)
  if {$linklog(debug) == 1} {
    putlog "$linklog(debugstring) File $linklog(location)$arg closed"
  }
}

###################
# Get some stats
###################
proc linkstats {nick host hand chan arg} {
  global linklog
  if {$linklog(debug) == 1} {
    putlog "$linklog(debugstring) link stats called with arg $arg"
  }
  if {[string length $arg] < 1} {
    if {$linklog(debug) == 1} {
      putlog "$linklog(debugstring) No arg given to $linklog(stats)"
    }
    set files [glob $linklog(location)*]
    if {$linklog(debug) == 1} {
      putlog "$linklog(debugstring) Files to be checked are $files"
    }
    if { [llength $files] > 0 } {
      foreach f [lsort $files] {
        set name [regsub -nocase {.*links\_} $f {}]
        set size [linklinecount $f]
        lappend thelist "$name $size"
       }
     } else {
      puthelp "PRIVMSG $chan $linklog(out) Nobody has linked to anything :o"
     }
           if {$linklog(debug) == 1} {
                        putlog "$linklog(debugstring) unsorted list is $thelist "
                 }
     lappend outputlist [lsort -index 1 -decreasing -integer $thelist]
     if {$linklog(debug) == 1} {
                         putlog "$linklog(debugstring) Sorted list is $outputlist"
                 }
                 set x "0"
     while {$x < 3} {
      set list [lindex $outputlist 0 $x]
      incr x
      lassign $list user count
      if {$count < 0} {
        return
      }
      if {$x == 1} {
        puthelp "PRIVMSG $chan $linklog(out) Top link spammers"
      }
      puthelp "PRIVMSG $chan $x. $user spammed $count links"
    }
    return
  }
  # Check the file exists first
  set linklog(fileresult) [linkfilecheck $linklog(location)$arg]
  if {$linklog(debug) == 1} {
    putlog "$linklog(debugstring) files we try to open will be $linklog(fileresult)"
  }
  if {$linklog(fileresult) != 1} {
    puthelp "PRIVMSG $chan $linklog(out) No links found for $arg :("
    putlog "$linklog(debugstring) File $linklog(location)$arg doesnt exist??"
  return
  }
  # Count the links
  set linkcount [linklinecount $linklog(location)$arg]
        puthelp "PRIVMSG $chan $arg has spammed $linkcount links"
}

###################
# Count the lines in a file
###################
proc linklinecount {FILENAME} {
  global linklog
  if {$linklog(debug) == 1} {
    putlog "$linklog(debugstring) Linklinecount called with arg $FILENAME"
  }
  # c
        set i 0
        set fid [open $FILENAME r]
        while {[gets $fid line] > -1} {incr i}
        close $fid
  if {$linklog(debug) == 1} {
                putlog "$linklog(debugstring) Linklinecount returning $i lines counted"
        }
        return $i
}

###################
# Check file exsists
###################
proc linkfilecheck {FILENAME} {
  global linklog
  if {$linklog(debug) == 1} {
    putlog "$linklog(debugstring) Linkfilecheck called with arg $FILENAME"
  }
  # checking the file exists
        if [file exists $FILENAME] then {
        # file exists
    return 1
        } else {
        # file not exists
    return "0"
  }
}
putlog "link logger v 1.1 by m00nie http://www.m00nie.com :)"
