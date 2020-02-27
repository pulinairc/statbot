# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## logfile.tcl component script ##

proc lg_helpidx {hand chan idx} {
  if {![matchattr $hand n]} {return 0}
  putidx $idx "logfile.tcl commands"
  putidx $idx " For owners:"
  putidx $idx "  logs          sendlog       maillog"
  putidx $idx " "
  return 1
}

proc lg_help {hand chan idx cmd} {
  global lg_email
  if {[matchattr $hand n]} {
    switch -exact -- $cmd {
      "logs" {
        putidx $idx "# logs"
        putwrap $idx 3 "Lists all available logfiles."
        return 1
      }
      "sendlog" {
        putidx $idx "# sendlog <logfile> <nick>"
        putwrap $idx 3 "Sends the specified log file to the specified nick via DCC."
        return 1
      }
      "maillog" {
        putidx $idx "# maillog <nick> \[email@address\]"
        putwrap $idx 3 "Sends the specified log file to the specified e-mail address. If no address is specified, the log is sent to:"
        putidx $idx "    $lg_email"
        return 1
      }
    }
  }
  return 0
}

lappend nb_helpidx "lg_helpidx"
set nb_help(logs) "lg_help"
set nb_help(sendlog) "lg_help"
set nb_help(maillog) "lg_help"

proc lg_logs {hand idx arg} {
  putcmdlog "#$hand# logs $arg"
  set loglist ""
  foreach log [logfile] {
    set logname [lindex [split $log] 2]
    if {[file exists $logname]} {
      if {[catch {file size $logname} logsize]} {
        set logsize 0
      }
      set logsize [expr $logsize / 1024]
      if {$logsize < 1} {
        set logsize 1
      }
      lappend loglist "$logname ($logsize K)"
    }
    if {[file exists $logname.yesterday]} {
      if {[catch {file size $logname.yesterday} logsize]} {
        set logsize 0
      }
      set logsize [expr $logsize / 1024]
      if {$logsize < 1} {
        set logsize 1
      }
      lappend loglist "$logname.yesterday ($logsize K)"
    }
  }
  if {$loglist == ""} {
    putidx $idx "There are no logs."
  } else {
    putidx $idx "Log files:"
    foreach log $loglist {
      putidx $idx $log
    }
  }
  return 0
}

proc lg_sendlog {hand idx arg} {
  putcmdlog "#$hand# sendlog $arg"
  set file [lindex [split $arg] 0] ; set nick [lindex [split $arg] 1]
  if {$file == "" || $nick == ""} {
    putidx $idx "Usage: sendlog <logfile> <nick>" ; return 0
  }
  switch -exact -- [dccsend $file $nick] {
    0 {putidx $idx "Sending $file to $nick"}
    1 {putidx $idx "Error: can't send $file (too many connections)"}
    2 {putidx $idx "Error: can't send $file (can't open socket)"}
    3 {putidx $idx "File '$file' does not exist."}
    4 {putidx $idx "Error: can't send $file ($nick has too many transfers)"}
  }
  return 0
}

proc lg_maillog {hand idx arg} {
  global botnet-nick lg_email
  putcmdlog "#$hand# maillog $arg"
  set file [lindex [split $arg] 0]
  if {$file == ""} {
    putidx $idx "Usage: maillog <logfile> \[email@address\]" ; return 0
  }
  set email [lindex [split $arg] 1]
  if {$email == ""} {
    set email $lg_email
  }
  if {![file exists $file]} {
    putidx $idx "File '$file' does not exist."
  } else {
    if {[catch {exec mail -s "$file from ${botnet-nick}" $email < $file}]} {
      putidx $idx "Error sending $file to $email"
    } else {
      putidx $idx "Sent $file to $email"
    }
  }
  return 0
}

proc lg_timer {min hour day month year} {
  timer 3 lg_sendmail
  return 0
}

proc lg_sendmail {} {
  global botnet-nick lg_email lg_maillog lg_maxsize
  if {[info exists lg_maillog] && $lg_maillog != ""} {
    putlog "Sending logs.."
    foreach file [split $lg_maillog] {
      if {![file exists $file]} {
        putlog "Unable to send $file to $lg_email ($file doesn't exist)."
      } else {
        if {[catch {file size $file} filesize]} {
          set filesize 0
        }
        if {[expr $filesize / 1024] > $lg_maxsize} {
          putlog "$file is larger than $lg_maxsize K, not sending." ; continue
        }
        if {[catch {exec mail -s "$file from ${botnet-nick}" $lg_email < $file}]} {
          putlog "Error sending $file to $lg_email"
        } else {
          putlog "Sent $file to $lg_email"
        }
      }
    }
  }
  return 0
}

if {[string length ${switch-logfiles-at}] == 3} {
  bind time - "[string range ${switch-logfiles-at} 1 2] 0[string index ${switch-logfiles-at} 0] * * *" lg_timer
} elseif {[string length ${switch-logfiles-at}] == 4} {
  bind time - "[string range ${switch-logfiles-at} 2 3] [string range ${switch-logfiles-at} 0 1] * * *" lg_timer
}
bind dcc n logs lg_logs
bind dcc n sendlog lg_sendlog
bind dcc n maillog lg_maillog

return "nb_info 4.10.0"
