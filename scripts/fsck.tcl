# fsck function library v1.19
# Copyright (C) 2004-2007 perpleXa
# http://perplexa.ugug.org / #perpleXa on QuakeNet
#
# Redistribution, with or without modification, are permitted provided
# that redistributions retain the above copyright notice, this condition
# and the following disclaimer.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.
#
# To update this package you need to _RESTART_ your bot.
# A rehash will most likely cause a crash...
#
# You do _not_ need to load any other scripts. This package will do all that
# work for you, just copy it to your scripts directory.
# You can optionally set the script-path variable to let fsck load scripts
# only from directories you specified:
   set script-path {
    "scripts/autoload"
   };
#
# This file carries 35 functions, which are listed in alphabetical order below:
# * assert <expression>
# * bytify <integer>
# * cat <file>
# * compiled
# * crypthost <user>
# * delchars  <string> <chars>
# * do <body> while <condition>
# * duration <integer>
# * durationtolong <string>
# * Error <source> <severity> <reason>
# * getword <string> <start?-end?>
# * hand2nick:all <hand>
# * initseed
# * iptolong <ip>
# * lines <file>
# * longtoduration <integer>
# * longtoip <integer>
# * merge <arguments ...>
# * minmaxrand <min> <max>
# * mmax <integer> <integer>
# * mmin <integer> <integer>
# * pretty_mask <string>
# * putamsg <text>
# * randstr [minlength] [maxlength] [chars]
# * rputquick <string>
# * sendmail <sender> <recipient> <subject> <message>
# * shuffle <list>
# * sortfile <file>
# * splitline <string> <variable> <maxparams>
# * splitmsg <string>
# * strcom <variable>
# * strreverse <string>
# * strtoul <string>
# * tree <directory>
# * urandom <limit>
# * validip <ip>
#
# Additional features:
# * Prints G-line reasons to the logfile.
#
# * Removes flood triggers for friendly users with one of the +fmno flags.
set NOFLOOD_FOR_FRIENDS true;
#
# * Loads all other scripts from fsck's parent directory or script-path, using
#   enhanced error catching to prevent the bot from crashing when it's loading
#   an erroneous script during startup.
set LOAD_ALL_SCRIPTS true;

###############################################################################
# DO NOT EDIT CODE BELOW THIS LINE UNLESS YOU REALLY KNOW WHAT YOU ARE DOING! #
###############################################################################

# Log debug messages
set LOG_DEBUG false;

# Package stuff
package require Tcl 8.4;
package provide fsck 1.19;

# splitmsg:
#  Splits a message into 400byte chunks.
#  Some messages exceed the 512 byte buffer of most ircds,
#  so here's the solution, this function splits each message
#  into a list with 400byte chunks (400+channelname+userhost etc).
#  The message will not be split in words, only between them.
proc splitmsg {string} {
  set buf1 ""; set buf2 [list];
  foreach word [split $string] {
    append buf1 " " $word;
    if {[string length $buf1]-1 >= 400} {
      lappend buf2 [string range $buf1 1 end];
      set buf1 "";
    }
  }
  if {$buf1 != ""} {
    lappend buf2 [string range $buf1 1 end];
  }
  return $buf2;
}

# compiled: Gets the eggdrop's file modifytime.
proc compiled {args} {
  return [strftime "%d/%m/%y %H:%M" [file mtime [info nameofexecutable]]];
}

# putamsg: Port of mirc's amsg function.
proc putamsg {text} {
  set channels [list];
  foreach channel [channels] {
    if {[botonchan $channel]} {
      lappend channels $channel;
    }
  }
  set channels [join $channels ","];
  puthelp "PRIVMSG $channels :$text";
}

# hand2nick:all: Returns a list of all users with that hand.
proc hand2nick:all {hand} {
  set users [list];
  foreach chan [channels] {
    foreach user [chanlist $chan] {
      if {[string equal -nocase [nick2hand $user] $hand] && ![isbotnick $user]} {
        lappend users $user;
      }
    }
  }
  return [lsort -unique $users];
}

# pretty_mask:
#  Canonify a mask.
#  The following transformations are made:
#   1)   xxx           -> nick!*@*
#   2)   xxx.xxx       -> *!*@host
#   3)   xxx!yyy       -> nick!user@*
#   4)   xxx@yyy       -> *!user@host
#   5)   xxx!yyy@zzz   -> nick!user@host
proc pretty_mask {mask} {
  set star "*";
  set retmask "";
  set last_dot 0;
  set nick $mask;
  set user $star;
  set host $star;
  set char $star;
  for {set x 0} {$char != ""} {incr x} {
    set char [string index $mask $x]
    if {$char == "!"} {
      set user [string range $mask [expr $x+1] end];
      set host $star;
    } elseif {$char == "@"} {
      set nick $star;
      set user [string range $mask 0 [expr $x-1]];
      set host [string range $mask [expr $x+1] end];
    } elseif {$char == "."} {
      set last_dot $x;
    } else {
      continue;
    }
    for {} {$char != ""} {incr x; set char [string index $mask $x]} {
      if {$char == "@"} {
        set host [string range $mask [expr $x+1] end];
      }
    }
    break;
  }
  if {$user == $star && $last_dot} {
    set nick $star;
    set user $star;
    set host $mask;
  }
  if {$nick != $star} {
    set char [string first "!" $nick];
    set nick [string range $nick 0 [expr {($char > -1) ? $char-1 : "end"}]];
    if {$nick == ""} {
      set nick $star;
    }
  }
  if {$user != $star} {
    set char [string first "@" $user];
    set user [string range $user 0 [expr {($char > -1) ? $char-1 : "end"}]];
    if {$user == ""} {
      set user $star;
    }
  }
  if {$host == ""} {
    set host $star;
  }
  format "%s!%s@%s" $nick $user $host;
}

# duration:
#  Converts a specified number of seconds into a duration string.
#  Changes to the original duration function:
#  * supports milliseconds
#  * removed year value
#  * sizes between values are always displayed
#    i.e. days>0, minutes>0, but hours=0
#    will return 1 day 0 hours 3 minutes
proc duration {interval} {
  set mseconds [expr ($interval)-int($interval)];
  set seconds [expr int($interval)%60];
  set minutes [expr (int($interval)%3600)/60];
  set hours [expr (int($interval)%(3600*24))/3600];
  set days [expr (int($interval)%(3600*24*7))/(3600*24)];
  set weeks [expr int($interval)/(3600*24*7)];
  set outstring "";
  if {$weeks>0} {
    append outstring [format "%d week%s " $weeks [expr $weeks==1?"":"s"]];
  }
  if {$days>0 || ($weeks>0 && ($hours>0 || $minutes>0 || $seconds>0 || $mseconds>0))} {
    append outstring [format "%d day%s " $days [expr $days==1?"":"s"]];
  }
  if {$hours>0 || (($weeks>0 || $days>0) && ($minutes>0 || $seconds>0 || $mseconds>0))} {
    append outstring [format "%d hour%s " $hours [expr $hours==1?"":"s"]];
  }
  if {$minutes>0 || (($weeks>0 || $days>0 || $hours>0) && ($seconds>0 || $mseconds>0))} {
    append outstring [format "%d minute%s " $minutes [expr $minutes==1?"":"s"]];
  }
  if {$mseconds>0} {
    append outstring [format "%.3f seconds " [expr $seconds+$mseconds]];
  } elseif {$seconds>0} {
    append outstring [format "%d second%s " $seconds [expr $seconds==1?"":"s"]];
  }
  return [string range $outstring 0 end-1];
}

# longtoduration:
#  Converts a specified number of seconds into a duration string.
#  format: 0 for the "/stats u" compatible output, 1 for more human-friendly output.
proc longtoduration {interval {format 1}} {
  set days [expr $interval/(3600*24)]
  if {($interval>86400 && ($interval % 86400)) || !$format} {
    set seconds [expr $interval%60]
    set minutes [expr ($interval%3600)/60]
    set hours [expr ($interval%(3600*24))/3600]
    return [format "%d day%s, %02d:%02d:%02d" $days [expr {($days==1)?"":"s"}] $hours $minutes $seconds]
  }
  return [format "%d day%s" $days [expr {($days==1)?"":"s"}]]
}

# durationtolong:
#  Converts the specified string into a number of seconds.
#  Valid switches are:
#   s (seconds)  m (minutes)  h (hours)    d (days)
#   w (weeks)    M (months)   y (years)
#  i.e. 2w3d will return a value of 2 weeks and 3 days.
proc durationtolong {string} {
  set total 0
  set current ""
  for {set x 0} {$x < [string length $string]} {incr x} {
    set ch [string index $string $x]
    if {[string is digit -strict $ch]} {
      append current $ch
    }
    if {$current != ""} {
      switch -exact $ch {
        "s" {set total [expr $total + $current]}
        "m" {set total [expr $total + ($current * 60)]}
        "h" {set total [expr $total + ($current * 3600)]}
        "d" {set total [expr $total + ($current * 86400)]}
        "w" {set total [expr $total + ($current * 604800)]}
        "M" {set total [expr $total + ($current * 2592000)]}
        "y" {set total [expr $total + ($current * 31557600)]}
      }
      if {[string match \[smhdwMy\] $ch]} {
        set current ""
      }
    }
  }
  if {$current != ""} {
    set total [expr $total + $current]
  }
  format "%lu" $total
}

# bytify: Converts the specifiednumber of bytes into a more human-friendly string.
proc bytify {bytes} {
  for {set pos 0; set bytes [expr double($bytes)]} {$bytes >= 1024} {set bytes [expr $bytes/1024]} {
    incr pos;
  }
  set a [lindex {"B" "KB" "MB" "GB" "TB" "PB"} $pos];
  format "%.3f%s" $bytes $a;
}

# randstr: Returns a random string of "chars" between min and max.
proc randstr {{min "7"} {max "13"} {chars "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\\|[{]}`^-_"}} {
  set length [minmaxrand $min $max];
  set count [string length $chars];
  set result [string index $chars [rand $count]];
  for {set index 1} {$index < $length} {incr index} {
    append result [string index $chars [rand $count]];
  }
  return $result;
}

# getword: Gets a word of a string, works independend of multiple spaces.
proc getword {inputstring index} {
  if {![regexp {^([[:digit:]]+)-([[:digit:]]+|end)} $index -> index end]} {
    set end 0;
  }
  set inputstring [string trim $inputstring]; set buf "";
  set params 0; set instr 1; incr index;
  if {$end != "end"} { incr end; }
  for {set i 0} {$i < [string length $inputstring]} {incr i} {
    set c [string index $inputstring $i];
    if {!($c==" " || $c=="\n" || $c=="\r" || $c=="\t")} {
      if {$instr} {
        incr params; set instr 0;
      }
    } else {
      set instr 1;
    }
    if {($params == $index) || (($params >= $index)
        && (($end == "end") || ($params <= $end)))} {
      append buf $c;
    }
  }
  return [string trim $buf];
}

# splitline:
#   This function splits lines on each space, up to a maximum of maxparams.
#   Spaces at the beginning/between words are removed/ignored.
#   Multiple spaces in the last parameter will not be removed.
proc splitline {inputstring outputvector maxparams} {
  upvar $outputvector cargv;
  set cargv [list];

  set inputstring [split $inputstring];
  set paramcount 0

  while {($paramcount<$maxparams || !$maxparams) && $inputstring!=""} {
    if {[lindex $inputstring 0]!=""} {
      if {[incr paramcount]==$maxparams} {
        lappend cargv [join $inputstring];
        break;
      }
      lappend cargv [lindex $inputstring 0];
    }
    set inputstring [lreplace $inputstring 0 0];
  }
  return $paramcount;
}

# rputquick: Sends text to the server _without_ any delay.
proc rputquick {text {options ""}} {
  # Thread options as this would be the real putquick function.
  # Due to sanity checks or something.. :)
  if {($options != "")} {
    if {![string equal -nocase "-normal" $options]
        && ![string equal -nocase "-next" $options]} {
      # Return an error if the specified option is neither -normal nor -next
      return -code error "unknown rputquick option: should be one of: -normal -next";
    }
  }
  if {![string equal [string index $text end] "\n"]} {
    # Add a newline to the end of the string, if not already.
    append text "\n";
  }
  # Must use catch here, because putdccraw returns a TCL_ERROR
  # if we aren't connected to the server and send something.
  catch {putdccraw 0 [string length $text] $text;}
  return;
}

# http://www.sendmail.org ;)
proc sendmail {sender recipient subject message} {
  set sendmail "/usr/sbin/sendmail";
  if {[catch {open "|$sendmail $recipient" "w"} fd]} {
    return 0;
  }
  puts $fd "To: $recipient";
  puts $fd "From: $sender";
  puts $fd "Subject: $subject\n";
  puts $fd "$message";
  close $fd;
  return 1;
}

# crypthost: An encrypted version of getchanhost
# I actually don't know why i made this...
proc crypthost {nick} {
  set host [getchanhost $nick];
  if {$host == ""} {return;}
  set salt $host;
  set ident [lindex [split $host "@"] 0];
  set host [lindex [split $host "@"] 1];
  set crypt [string range [encrypt $salt $host] 0 12];
  if {[string index $crypt 0] == "."} {
    set crypt "a[string range $crypt 1 12]";
  }
  if {[string index $crypt 12] == "."} {
    set crypt "[string range $crypt 0 11]a";
  }
  set host [split $host "."];
  if {([llength $host] == 4) && [string is digit -strict [lindex $host 3]]} {
    set host [join [lrange $host 0 2] "."];
    format "%s@%s.%s" $ident $host $crypt;
  } else {
    set host [join [lrange $host 1 end] "."];
    format "%s@qnet-%s.%s" $ident $crypt $host;
  }
}

# lines: Counts the lines of a file.
proc lines {file} {
  if {[catch {open $file "r"} fp]} {
    # We can not open the specified file, return -1
    return -1;
  }
  # Split the whole content on each newline char,
  set lines [llength [split [read $fp] "\n"]];
  # don't forget to close the file
  close $fp;
  # and return the list size.
  return $lines;
}

# sortfile:
#  Sorts a file in alphabetical order.
#  USE WITH CARE -- you don't have to worry about the original file
#  being untrusted, but you must get it sorted right :)
proc sortfile {file} {
  if {[catch {open $file "r"} fp]} {
    return -1;
  }
  set fcont [join [lsort -dictionary [split [read $fp] "\n"]] "\n"];
  close $fp;
  if {[catch {open $file "w"} fp]} {
    return -1;
  }
  puts $fp $fcont;
  close $fp;
  return 1;
}

# seed the pseudo-random number generator, rand()
proc initseed {args} {
  expr srand([clock clicks -milliseconds]%65536);
}; initseed

# returns a random number from /dev/urandom
proc urandom {limit} {
  if {[catch {open "/dev/urandom" "r"} fp]} {
    error "Could not open /dev/urandom";
  } elseif {![binary scan [read $fp 4] "i" rand]} {
    close $fp;
    error "Got weird input from /dev/urandom";
  } else {
    close $fp;
    return [expr ($rand & 0x7FFFFFFF) % $limit];
  }
}

# shuffle: Randomizes a list.
proc shuffle {list} {
  for {set i 0} {$i<[llength $list]} {incr i} {
    set j [rand [expr $i+1]];
    if {$i == $j} {continue;}
    set x [lindex $list $i];
    set list [lreplace $list $i $i [lindex $list $j]];
    set list [lreplace $list $j $j $x];
  }
  return $list;
}

# mmin: Returns the shorter value.
proc mmin {a b} {
  expr {$a > $b ? $b : $a}
}

# mmax: Returns the longer value.
proc mmax {a b} {
  expr {$a < $b ? $b : $a}
}

# minmaxrand: Returns a random number between min and max.
proc minmaxrand {min max} {
  expr ([rand [expr ($max - $min)]] + $min);
}

# strcom:
#  Strips C style comments from vars.
#  Comments in quotes " " will be ignored.
proc strcom {varName} {
  upvar $varName string;
  set sstring "";
  set instr 0;
  set incom 0;
  for {set i 0} {$i<[string length $string]} {incr i} {
    # Get the current char
    set c [string index $string $i];
    if {$c == "\""} {
      # Got a quote, check if it's escaped.
      set isesc 0;
      for {set x [expr $i-1]} {[string index $string $x] == "\\"} {incr x -1} {
        set isesc [expr !$isesc];
      }
      if {!$isesc && !$incom} {
        # It's not escaped.
        set instr [expr !$instr];
      }
    } elseif {$c == "/"} {
      # Got a slash, check if we reached begin/end of a comment.
      if {!$instr} {
        if {$incom} {
          # Currently not in string, check if trailing char was *.
          if {[string index $string [expr $i-1]] == "*"} {
            # End of comment.
            set incom 0;
            continue;
          }
        } else {
          # Check if following char is *.
          if {[string index $string [expr $i+1]] == "*"} {
            # Now we are in a comment.
            set incom 1;
            continue;
          }
        }
      }
    }
    if {!$incom} {
      # Not in comment, add char.
      append sstring $c;
    }
  }
  set string $sstring;
}

# delchars: Deletes characters occuring in badchars from string.
proc delchars {string badchars} {
  set newstring "";
  for {set i 0} {$i < [string length $string]} {incr i} {
    set isbad 0;
    foreach char [split $badchars ""] {
      if {[string index $string $i] == $char} {
        set isbad 1;
        break;
      }
    }
    if {!$isbad} {
      append newstring [string index $string $i];
    }
  }
  return $newstring;
}

# strreverse: Returns the inputstring in reversed order.
proc strreverse {string} {
  for {set i 0; set j [expr [string length $string]-1];} {$i < $j} {incr i 1; incr j -1} {
    set c [string index $string $i];
    set string [string replace $string $i $i [string index $string $j]];
    set string [string replace $string $j $j $c];
  }
  return $string;
}

# validip: Checks an IP for sanity.
proc validip {ip} {
  set tmp 0;
  if {!([llength [set ip [split $ip "."]]] == 4)} {
    return 0;
  }
  foreach num $ip {
    if {[string length $num] > 3 || $num < 0 || $num >= 256} {
      return 0;
    }
    incr tmp $num;
  }
  expr $tmp>=1;
}

# sevtostring: Returns a string of an error code. (internal function)
proc sevtostring {severity} {
  switch -exact $severity {
    DEBUG {
      return "debug";
    }
    INFO {
      return "info";
    }
    WARNING {
      return "warning";
    }
    ERROR {
      return "error";
    }
    FATAL {
      return "fatal error";
    }
    default {
      return "unknown error";
    }
  }
}

# Error: Provides enhanced error logging. :)
proc Error {source severity reason} {
  global LOG_DEBUG;
  if {$severity == "DEBUG" && !$LOG_DEBUG} return;
  putlog [format "%s(%s): %s" [sevtostring $severity] $source $reason];
}

# tree:
#  Calls itself recursively and returns the content of a directory in a tree structure.
#  Leave the 'prefix' parameter blank, it's for internal use only.
#  Note about the general implementation: The tcl interpreter sets a
#  tcl stack limit of 1000 levels to prevent infinite recursions from
#  running out of bounds. As this command is implemented recursively it
#  will fail for very deeply nested directory structures.
proc tree {location {prefix ""}} {
  if {$prefix != ""} {
    if {[string index $prefix end-1] == " "} {
      set result [list [string range $prefix 0 end-2]`-[lindex [split $location "/"] end]];
    } else {
      set result [list [string range $prefix 0 end-1]-[lindex [split $location "/"] end]];
    }
  } else {
    set result [list [lindex [split $location "/"] end]];
  }
  set files [lsort -dictionary [glob -nocomplain "[string trimright $location "/"]/*"]];
  set flcnt [llength $files];
  for {set i 0} {$i<$flcnt} {incr i} {
    set file [lindex $files $i]
    if {$i+1 == $flcnt} {
      set pre "$prefix`-";
      set fpre "$prefix  "
    } else {
      set pre "$prefix|-";
      set fpre "$prefix| ";
    }
    if {[file isdirectory $file]} {
      foreach file [tree $file $fpre] {
        lappend result $file;
      }
    } else {
      lappend result $pre[lindex [split $file "/"] end];
    }
  }
  return $result;
}

# do: TCL implementation of do while loops.
proc do {body while condition} {
  if {$while != "while"} {
    return -code error "Invalid function call.";
  }
  set ccondition [list expr $condition];
  while {1} {
    uplevel 1 $body;
    if {![uplevel 1 $ccondition]} {
      break;
    }
  }
}

# assert: TCL implementation of the C assert function
proc assert {expr} {
  set code [catch {uplevel 1 [list expr $expr]} res];
  if {$code} {
    return -code $code $res;
  }
  if {![string is boolean -strict $res]} {
    return -code error "invalid boolean expression: $expr";
  }
  if {$res} {return;}
  return -code error "assertion failed: $expr";
}

# cat:
#  TCL implementation of the UNIX "cat" command.
#  Returns the contents of the specified file.
proc cat {file} {
  # Don't bother catching errors, just let them propagate up.
  set fp [open $file "r"];
  # Use the [file size] command to get the size, which preallocates memory,
  # rather than trying to grow it as the read progresses.
  set size [file size $file];
  if {$size} {
    set data [read $fp $size];
  } else {
    # If the file has zero bytes it is either empty, or something
    # where [file size] reports 0 but the file actually has data (like
    # the files in the /proc filesystem)
    set data [read $fp];
  }
  close $fp;
  return $data;
}

# strtoul: Converts a string to an unsigned digit.
proc strtoul {string} {
  if {[catch {expr int($string)} val]} {
    return 0;
  }
  format "%lu" $val;
}

# merge: Connects arguments.
proc merge {args} {
  return [join $args ""];
}

# iptolong: Converts an ip to it's long value.
proc iptolong {ip} {
  if {[scan $ip {%[1234567890]%c%[1234567890]%c%[1234567890]%c%[1234567890]} a & b & c & d] != 7} {
    return 0;
  }
  # format "%lu" [expr ((((($a<<8)^$b)<<8)^$c)<<8)^$d];
  # fix for 64-bit systems
  format "%u" [format "0x%.2X%.2X%.2X%.2X" $a $b $c $d];
}

# longip: Converts the long value of an ip to it's dotted quad ip.
proc longtoip {long} {
  format "%u.%u.%u.%u" [expr $long>>24] [expr ($long>>16)&255] [expr ($long>>8)&255] [expr $long&255];
}

# Sends the G-line reason to the log file if the bot was banned from a server.
bind raw -|- "465" *raw:fsck:465;
proc *raw:fsck:465 {srv raw str} {
  set reason [string range $str [expr [string first ":" $str]+1] end];
  Error "server" ERROR "G-lined ($srv): $reason"
  return 0;
}

# Removes flood triggers for users with one of the +fmno flags.
bind flud -|- * flood;
proc flood {nick host hand type chan} {
  global NOFLOOD_FOR_FRIENDS;
  if {$NOFLOOD_FOR_FRIENDS && (([validchan $chan] && [matchattr $hand "fmno|fmno" $chan]) || [matchattr $hand "fmno"])} {
    return 1;
  }
  return 0;
}

# Load all *.tcl files in either this directory or "script-path".
if {$LOAD_ALL_SCRIPTS} {
  putlog "--------------------------------------";
  putlog "-------- Initialising scripts --------";
  if {![info exists script-path]} {
    set script-path [list [file dirname [info script]]];
  }
  foreach fsck(dir) ${script-path} {
    putlog "Current search path:";
    putlog $fsck(dir);
    set fsck(scripts) [lsort -dictionary [glob -nocomplain -- "[string trimright $fsck(dir) "/"]/*"]];
    set fsck(error) "";
    set fsck(x) 0; set fsck(y) 0;
    foreach fsck(script) $fsck(scripts) {
      if {![file isdirectory $fsck(script)] && [string match -nocase *?.tcl $fsck(script)]} {
        incr fsck(y);
        if {![string compare [info script] $fsck(script)]} {
          incr fsck(x);
          continue;
        }
        if {[catch {source $fsck(script)} fsck(error)]} {
          Error "fsck" FATAL "Couldn't load $fsck(script) \[$fsck(error)\]";
          continue;
        }
        incr fsck(x);
      }
    }
    putlog "$fsck(x) of $fsck(y) script[expr {($fsck(y) == 1) ? "" : "s"}] initialised.";
  }
  catch {unset fsck}
}
