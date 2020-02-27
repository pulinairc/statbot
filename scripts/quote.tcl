# Quote Script by Steinsky.  Version: 1.2.1
# See www.cotch.net, irc.fwaggle.net, irc.zone.dk and virus.eleethal.com
#
# Adds channel commands: !addquote (And !quoteadd !+quote) 
# and !quote with the option of an arg e.g. !quote *Steinsky*
# and !quotestats or !quotestats *matchtext*
# And the DCC Commands:
# .addquote <quote> and .quotestats or .quotestats *matchtext*
# And the MSG Commands:
# /msg botnick addquote <quote>
#
# Needs more?  Talk to me on irc.fwaggle.net
# (Note: I edited some variables earlier and haven't tested to make sure I got them all, it should work though.)

# Where are the quotes ganna be kept?
set quotefile /home/rolle/eggdrop/scripts/quote.txt

# Set this log file to store nick!user@host of people who added quotes
# I added this feature because a load of people added some crappy quotes and needed a slap
# I hardwired it in so you best make the file and set it, in the next version I'll add some more ifs
set quotelog /home/rolle/eggdrop/scripts/quote.log

# 0 = display quotes in channel
# 1 = display quotes via private notice.
set quotevianotice 0


if { ![info exists toolbox_loaded] } { source scripts/alltools.tcl }

bind pub - !quote quote:pub:quote
bind pub - !addquote quote:pub:addquote
bind pub - !quoteadd quote:pub:addquote
bind pub - !+quote quote:pub:addquote
bind pub - !quotestats quote:pub:quotestats
bind dcc - addquote quote:dcc:addquote
bind msg - addquote quote:msg:addquote
bind dcc - quotestats quote:dcc:quotestats

proc quote:pub:quote {nick uhost hand chan arg} {
 global quotefile quotevianotice
 set quotes ""
 if { [file exists $quotefile] } { set file [open $quotefile r] 
 } else {
  if { $quotevianotice == 0 } { putmsg $chan "$quotefile does not exist. You'll need to add quotes to the database first by typing \002!addquote <a quote>\002" }
  if { $quotevianotice == 1 } { putnotc $nick "$quotefile does not exist. You'll need to add quotes to the database first by typing \002!addquote <a quote>\002" }
  return 0
 }
 while { ![eof $file] } {
  set quote [gets $file]
  if { $quote != "" } {
   set quotes [linsert $quotes end $quote]
  }
 }
 close $file
 if { $arg != "" } {
  set pattern [string tolower $arg]
  set aquotes ""
  set quote ""
  foreach quote $quotes {
   set lowquote [string tolower $quote]
   if { [string match $pattern $lowquote] } {
    set aquotes [linsert $aquotes end $quote]
   }
   set quotes ""
   set quotes $aquotes
  }
 }
 set row [rand [llength $quotes]]
 if { [expr $row >= 0] && [expr $row < [llength $quotes]] } {
  set quote [lindex $quotes $row]
 }
 if { $quote != "" } {
  if { $quotevianotice == 0 } {
   putmsg $chan "Quote: $quote"
  }
  if { $quotevianotice == 1 } {
   putnotc $nick "$quote"
  }
 }
 return 1
}

proc quote:pub:addquote {nick uhost hand chan arg} {
 global quotefile
 global quotelog
 if { $arg == "" } {
  putnotc $nick "Usage: !addquote <a quote>"
  return 0
 }
 set file [open $quotefile a]
 puts $file $arg
 close $file
 putnotc $nick "Chi Chinga..."
 set filea [open $quotelog a]
 puts $filea "$nick ($uhost) of $chan Added: $arg"
 close $filea
 return 1
}

proc quote:pub:quotestats {nick uhost hand chan arg} {
 global quotefile quotevianotice
 set quotes ""
 if { [file exists $quotefile] } { set file [open $quotefile r] 
 } else {
  if { $quotevianotice == 0 } { putmsg $chan "$quotefile does not exist. You'll need to add quotes to the database first by typing \002!addquote <a quote>\002" }
  if { $quotevianotice == 1 } { putnotc $nick "$quotefile does not exist. You'll need to add quotes to the database first by typing \002!addquote <a quote>\002" }
  return 0
 }
 set row 0
 while { ![eof $file] } {
  set quote [gets $file]
  if { $quote != "" } {
   set quotes [linsert $quotes end $quote]
  }
 }
 close $file
 if { $arg != "" } {
  foreach quote $quotes {
   set pattern [string tolower $arg]
   set lowquote [string tolower $quote]
   if { [string match $pattern $lowquote] } {
    set row [expr $row+1]
   }
  }  
 } else {
  foreach quote $quotes {
    set row [expr $row+1]
  }
 }
 if { $arg != "" } {
  putchan $chan "Quotestats: There are $row quotes matching $arg"
 }
 if { $arg == "" } {
  putchan $chan "Quotestats: I have $row quotes in my quote file"
 }
 return 1
}
proc quote:dcc:addquote {hand idx arg} {
 global quotefile
 global quotelog
 if { $arg == "" } {
  putidx $idx "Usage: .addquote <a quote>"
  return 0
 }
 set file [open $quotefile a]
 puts $file $arg
 close $file
 putdcc $idx "Chi Chinga..."
 set filea [open $quotelog a]
 puts $filea "$hand on botnet Added: $arg"
 close $filea
 return 1
}
proc quoteit:msg:addquote {nick uhost hand arg} {
 global quotefile
 global quotelog
 if { $arg == "" } {
  putnotc $nick "Usage: /msg $botnick addquote <a quote>"
  return 0
 }
 set file [open $quotefile a]
 puts $file $arg
 close $file
 putnotc $nick "Chi Chinga..."
 set filea [open $quotelog a]
 puts $filea "$nick ($uhost) used msg to add: $arg"
 close $filea
 return 1
}
proc quote:dcc:quotestats {hand idx arg} {
 global quotefile quotevianotice
 set quotes ""
 if { [file exists $quotefile] } { set file [open $quotefile r] 
 } else {
  if { $quotevianotice == 0 } { putdcc $idx "$quotefile does not exist. You'll need to add quotes to the database first by typing \002!addquote <a quote>\002" }
  if { $quotevianotice == 1 } { putdcc $idx "$quotefile does not exist. You'll need to add quotes to the database first by typing \002!addquote <a quote>\002" }
  return 0
 }
 set row 0
 while { ![eof $file] } {
  set quote [gets $file]
  if { $quote != "" } {
   set quotes [linsert $quotes end $quote]
  }
 }
 close $file
 if { $arg != "" } {
  foreach quote $quotes {
   set pattern [string tolower $arg]
   set lowquote [string tolower $quote]
   if { [string match $pattern $lowquote] } {
    set row [expr $row+1]
   }
  }  
 } else {
  foreach quote $quotes {
    set row [expr $row+1]
  }
 }
 if { $arg != "" } {
  putdcc $idx "Quotestats: There are $row quotes matching $arg"
 }
 if { $arg == "" } {
  putdcc $idx "Quotestats: I have $row quotes in my quote file"
 }
 return 1
}

putlog "Script loaded: \002Quote.tcl By Steinsky\002"
