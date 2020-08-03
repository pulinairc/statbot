#   ____ _   _    _  _____    _        _
#  / ___| | | |  / \|_   _|__| |_ __ _| |_ ___
# | |   | |_| | / _ \ | |/ __| __/ _` | __/ __|
# | |___|  _  |/ ___ \| |\__ \ || (_| | |_\__ \
#  \____|_| |_/_/   \_\_||___/\__\__,_|\__|___/
#              3.1.2 by Baerchen, February 2002
#                  for eggdrop 1.4.5+ & TCL 8.3
#                     baerchen@germany-chat.net
#       latest versions @ home.dal.net/baerchen
#
# Patch: New DCC Commands: statmerge statdelete statfreeze statunfreeze
# added by XXanadoo, 06.12.2004
# More Info in the Help File
#
# Read the files 1_DESCRIPTION, 2_CONFIGURATION & 3_INSTALLATION. Yes, in this order.
# Do not mail me problems unless you didn't read these files.
#
# CONFIGURATION

set cs(workdir) "/var/www/chatstats/"
set cs(trigger) "."
set cs(idle) 300
set cs(dont) "fserv type trigger"
set cs(global) {
 post=2
 rankrange=10
 timebalance=+0
 trimlimit=1
 adinterval=0
 adsite=https://www.pulina.fi
 update=60
 htmsuffix=.htm
 ulmethod=1
 localfolder=/home/rolle/public_html/chatstats/
 ftpname=www.myftp.com
 ftpport=21
 ftpfolder=/subdir/subdir/subdir/
 username=username
 password=password
}

# CODEBASE

proc cs:ini {} {
 global cs csa csc csu numversion
 foreach e [timers] {if {[string match *cs:* $e]} {killtimer [lindex $e 2]}}
 array set csa ""; array set csc ""; array set csu ""; set cs(scriptver) 312
 if {![file exists $cs(workdir)CHATstats.dat]} {
  set fid [open $cs(workdir)CHATstats.dat w]
  puts $fid "CHATstats datafile v3.0\n--UserData--\n--ChannelData--\n--ActivityData--"
  close $fid
 }
 putlog "TCL LOADED: CHATstats X [join [split $cs(scriptver) {}] .] by Baerchen"
 cs:read
 foreach e [array names csc] {
  cs:cv $e
  if {[lindex $csc($e) 0] == "yes"} {
   bind pubm - "$e *" cs:count; bind topc - "$e *" cs:topic;    bind nick - "$e *" cs:nick
   bind join - "$e *" cs:join;  bind rejn - "$e *" cs:join;     bind kick - "$e *" cs:kick
   bind mode - "$e +b" cs:ban;  bind splt - "$e *" cs:partquit; bind sign - "$e *" cs:partquit2
   bind raw - PART cs:rawpart
   if {$numversion >= 1050000} {bind part - "$e *" cs:partquit2} else {bind part - "$e *" cs:partquit}
   if {$cs(update)} {
    timer $cs(update) "cs:html $e"
    if {$cs(adinterval)} {timer $cs(adinterval) "cs:advertize $e"}
   }
  }
 }
 set cs(ftperror) [catch {set cs(ftpclient) [exec which ftp]}]; set cs(rehash) 1
 if {$cs(ftperror) && [file executable /usr/bin/ftp]} {set cs(ftpclient) "/usr/bin/ftp"; set cs(ftperror) 0}
 if {$cs(ftperror) && [file executable /bin/ftp]} {set cs(ftpclient) "/bin/ftp"; set cs(ftperror) 0}
 if {$cs(ftperror) && [info commands auto_execok] != ""} {
  set cs(ftpclient) [auto_execok ftp]
  if {$cs(ftpclient) != ""} {set cs(ftperror) 0}
 }
 if {$cs(ftperror)} {putlog "            Cannot find FTP client."}
 bind pub - $cs(trigger)show cs:show
 bind pub nC|C $cs(trigger)change cs:change
 bind pub nC|C $cs(trigger)merge cs:merge
 bind pub nC|C $cs(trigger)delete cs:delete
 bind pub nC|C $cs(trigger)freeze cs:freeze
 bind pub nC|C $cs(trigger)unfreeze cs:unfreeze
 bind pub nC|C $cs(trigger)cyclestats cs:cycle
 bind dcc nC|nC chatstats cs:status
 bind dcc nC|C go cs:go
 bind dcc nC|C stop cs:stop

# Here the new Commands for the Partyline
 bind dcc nC|C statmerge cs:merge_dcc
 bind dcc nC|C statdelete cs:delete_dcc
 bind dcc nC|C statfreeze cs:freeze_dcc
 bind dcc nC|C statunfreeze cs:unfreeze_dcc

 bind dcc n trim cs:trim
 bind dcc n wipechan cs:wipechan
 bind dcc n update cs:update
 bind dcc n back-up cs:backup
 bind dcc n recover cs:recover
 bind time - "18 * * * *" cs:autosave
 bind time - "00 06 * * *" cs:autotrim
}

proc cs:go {h idx a} {
 global botnick cs csa csc csu numversion
 set c [string tolower $a]
 if {![validchan $c] || ![botonchan $c]} {putdcc $idx "CHATstats: I'm not on $a."; return}
 if {[lsearch -exact [bind pubm - "$c *"] cs:count] == -1} {
  bind pubm - "$c *" cs:count; bind topc - "$c *" cs:topic;    bind nick - "$c *" cs:nick
  bind join - "$c *" cs:join;  bind rejn - "$c *" cs:join;     bind kick - "$c *" cs:kick
  bind mode - "$c +b" cs:ban;  bind splt - "$c *" cs:partquit; bind sign - "$c *" cs:partquit2
  bind raw - PART cs:rawpart
  if {$numversion >= 1050000} {bind part - "$c *" cs:partquit2} else {bind part - "$c *" cs:partquit}
 } else {putdcc $idx "CHATstats is already enabled for $c."; return}
 if {![info exists csa(00$c)]} {
  foreach e "00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23" {set csa($e$c) 0}
  set csa(24$c) 1
 }
 if {![info exists csc($c)]} {
  set csc($c) "yes [clock seconds] 0 0 [llength [chanlist $c]] [clock seconds]"
  } else {
  set csc($c) [lreplace $csc($c) 0 0 "yes"]
  if {[lindex $csc($c) 1] == 0} {set csc($c) [lreplace $csc($c) 1 1 [clock seconds]]}
  set csc($c) [lreplace $csc($c) 2 2 0]
 }
 foreach e [chanlist $c] {
  if {([matchattr $e b]) || ($e == $botnick) || [string match -nocase "guest*" $e]} {continue}
  set el [cs:fl [string tolower $e]]
  if {[info exists csu(.$el$c)]} {continue}
  if {[info exists csu($el$c)]} {
   set csu($el$c) [lreplace $csu($el$c) 0 0 [cs:fl $e]]
   set csu($el$c) [lreplace $csu($el$c) 1 1 [clock seconds]]
  } else {set csu($el$c) "[cs:fl $e] [clock seconds] 1 0 0 0 0 0 0 0 0 0 0 0"}
 }
 cs:checkpeak $c
 cs:save
 putdcc $idx "CHATstats enabled for $c"
 putlog "CHATstats enabled for $c ($h)"
 cs:cv $c
 if {$cs(update)} {
  timer $cs(update) "cs:html $c"
  if {$cs(adinterval)} {timer $cs(adinterval) "cs:advertize $c"}
 }
}

proc cs:stop {h idx a} {
 global cs csc numversion
 set c [string tolower $a]
 if {[lsearch -exact [bind pubm - "$c *"] cs:count] == -1} {putdcc $idx "CHATstats is not enabled for $c."; return}
 unbind pubm - "$c *" cs:count; unbind topc - "$c *" cs:topic;    unbind nick - "$c *" cs:nick
 unbind join - "$c *" cs:join;  unbind rejn - "$c *" cs:join;     unbind kick - "$c *" cs:kick
 unbind mode - "$c +b" cs:ban;  unbind splt - "$c *" cs:partquit; unbind sign - "$c *" cs:partquit2
 if {$numversion >= 1050000} {unbind part - "$c *" cs:partquit2} else {unbind part - "$c *" cs:partquit}
 if {[info exists csc($c)]} {
  set csc($c) [lreplace $csc($c) 0 0 "no"]
  set csc($c) [lreplace $csc($c) 2 2 [clock seconds]]
 }
 foreach e [array names csu *$c] {cs:reset $e}
 cs:save
 cs:cv $c
 if {$cs(update)} {cs:html $c}
 foreach e [timers] {if {[string match *cs:*$c* $e]} {killtimer [lindex $e 2]}}
 putdcc $idx "CHATstats disabled for $c, channel commands are still available."
 putlog "CHATstats disabled for $c ($h)."
}

proc cs:join {n uh h c} {
 global cs csu botnick
 set ni [string tolower [cs:fl $n]]; set c [string tolower $c]; set j [llength [chanlist $c]]
 if {$n == $botnick} {bind raw - 353 cs:rawjoin; return}
 if {[matchattr $n b] || [string match -nocase "guest*" $n] || [info exists csu(.$ni$c)]} {return}
 if {[info exists csu($ni$c)]} {
  set csu($ni$c) [lreplace $csu($ni$c) 0 0 [cs:fl $n]]
  set csu($ni$c) [lreplace $csu($ni$c) 1 1 [clock seconds]]
  set csu($ni$c) [lreplace $csu($ni$c) 2 2 [expr [lindex $csu($ni$c) 2] + 1]]
 } else {set csu($ni$c) "[cs:fl $n] [clock seconds] 1 0 0 0 0 0 0 0 0 0 0 0"}
 cs:checkpeak $c
}

proc cs:rawjoin {f k a} {
 global botnick cs csc csu
 set c [string tolower [lindex $a 2]]
 if {[lsearch -exact [bind pubm - "$c *"] cs:count] == -1} {return 0}
 set userlist [lindex [split $a :] 1]
 foreach e $userlist {
  set e [string trimleft $e "%+@"]
  if {[matchattr $e b] || ($e == $botnick) || [string match -nocase "guest*" $e]} {continue}
  set el [cs:fl [string tolower $e]]
  if {[info exists csu(.$el$c)]} {continue}
  if {[info exists csu($el$c)]} {
   set csu($el$c) [lreplace $csu($el$c) 0 0 [cs:fl $e]]
   set csu($el$c) [lreplace $csu($el$c) 1 1 [clock seconds]]
  } else {set csu($el$c) "[cs:fl $e] [clock seconds] 1 0 0 0 0 0 0 0 0 0 0 0"}
 }
 return 0
}

proc cs:count {n uh h c t} {
 global botnick cs csa csu
 set t [split $t]; set ni [cs:fl [string tolower $n]]; set c [string tolower $c]
 foreach e $cs(dont) {if {[lsearch $t *$e*] > -1} {return}}
 if {([matchattr $n b]) || ($n == $botnick) || [string match -nocase "guest*" $n] || [info exists csu(.$ni$c)]} {return}
 set t [llength $t]; set u [clock seconds]
 if {[info exists csu($ni$c)]} {
  set csu($ni$c) [lreplace $csu($ni$c) 4 4 [expr [lindex $csu($ni$c) 4] + $t]]
  set csu($ni$c) [lreplace $csu($ni$c) 5 5 [expr [lindex $csu($ni$c) 5] + 1]]
  set ls [lindex $csu($ni$c) 12]; set idle [expr $u - $ls]
  if {($ls > 0) && ($idle > $cs(idle))} {
   set csu($ni$c) [lreplace $csu($ni$c) 13 13 [expr [lindex $csu($ni$c) 13] + $idle]]
   set csu($ni$c) [lreplace $csu($ni$c) 12 12 $u]
  } else {set csu($ni$c) [lreplace $csu($ni$c) 12 12 $u]}
 } else {set csu($ni$c) "[cs:fl $n] $u 1 0 $t 1 0 0 0 0 0 0 $u 0"}
 cs:cv $c
 incr csa([strftime "%H" [expr $u + $cs(timebalance) * 3600]]$c) $t
}

proc cs:nick {n uh h c ne} {
 cs:join $ne $uh $h $c
 cs:partquit2 $n $uh $h $c ""
}

proc cs:kick {n uh h c t r} {
 global csu
 if {$n == "" } {return}
 set ni [string tolower [cs:fl $n]]; set c [string tolower $c]; set ta [string tolower [cs:fl $t]]
 if {[info exists csu($ni$c)]} {set csu($ni$c) [lreplace $csu($ni$c) 8 8 [expr [lindex $csu($ni$c) 8] + 1]]}
 if {[info exists csu($ta$c)]} {
  cs:reset $ta$c
  set csu($ta$c) [lreplace $csu($ta$c) 10 10 [expr [lindex $csu($ta$c) 10] + 1]]
 }
}

proc cs:ban {n uh h c mc v} {
 global cs csu
 if {$n == "" } {return}; set ni [string tolower [cs:fl $n]]; set c [string tolower $c]
 if {[info exists csu($ni$c)]} {set csu($ni$c) [lreplace $csu($ni$c) 9 9 [expr [lindex $csu($ni$c) 9] + 1]]}
 foreach e [chanlist $c] {
  if {[string match -nocase $v $e![getchanhost $e $c]]} {
   set vi [string tolower [cs:fl $e]]
   if {[info exists csu($vi$c)]} {set csu($vi$c) [lreplace $csu($vi$c) 11 11 [expr [lindex $csu($vi$c) 11] + 1]]}
  }
 }
}

proc cs:partquit {n uh h c} {cs:partquit2 $n $uh $h $c ""}
proc cs:partquit2 {n uh h c t} {
 global csu
 set ni [cs:fl [string tolower $n]]; set c [string tolower $c]
 if {[info exists csu($ni$c)]} {cs:reset $ni$c}
}

proc cs:rawpart {f k a} {
 global botnick csc csu
 if {[lindex [split $f "!"] 0] != $botnick} {return 0}
 set c [string tolower $a]
 if {[lsearch -exact [bind pubm - "$c *"] cs:count] == -1} {return 0}
 foreach e [array names csu *$c] {cs:reset $e}
 cs:save
 return 0
}

proc cs:show {n uh h c a} {
 global cs csc csu botnick
 set c [string tolower $c]
 cs:cv $c
 set cs(rankrange) [expr $cs(rankrange) - 1]
 if {$cs(post) == 0} {puthelp "PRIVMSG $c: Stats not available. Go visit $cs(adsite)"; return}
 if {![info exists csc($c)]} {return}
 set a [cs:fl $a]; set what [string tolower [lindex $a 0]]; set who [lindex $a 1]; set ch "04$c"
 if {$who == ""} {set who [cs:fl $n]}
 switch -exact $what {
  channel    {set o "CHATstats for $ch\n";          append o [cs:prep 0 0 $c $who]}
  joins      {set o "Top Joiners of $ch\n";         append o [cs:prep 1 2 $c $who]}
  toptalkers {set o "Top Talkers of $ch\n";         append o [cs:prep 1 4 $c $who]}
  allstars   {set o "Top AllStars of $ch\n";        append o [cs:prep 1 6 $c $who]}
  kickers    {set o "Top Kickers of $ch\n";         append o [cs:prep 1 8 $c $who]}
  banners    {set o "Top Banners of $ch\n";         append o [cs:prep 1 9 $c $who]}
  kicked     {set o "Most famous victims of $ch\n"; append o [cs:prep 1 10 $c $who]}
  banned     {set o "Most famous victims of $ch\n"; append o [cs:prep 1 11 $c $who]}
  visitors   {set o "Top Visitors of $ch\n";        append o [cs:prep 2 3 $c $who]}
  idlers     {set o "Top Idlers of $ch\n";          append o [cs:prep 2 13 $c $who]}
  actives    {set o "Most active users of $ch\n";   append o [cs:prep 3 3 $c $who]}
  stats      {set o "";                             append o [cs:prep 4 4 $c $who]}
  titties    {set o "Hehe, I wish I had .."}
  default {
   puthelp "NOTICE $n :Usage: $cs(trigger)show <stats ?nick?|toptalkers|allstars|joins|visitors|idlers|actives|kickers|kicked|banners|banned|channel>"
   puthelp "NOTICE $n :       e.g. $cs(trigger)show stats WhoEver or $cs(trigger)show channel"
   return
  }
 }
 set o [split $o "\n"]
 switch -exact $cs(post) {
   1 {foreach e $o {puthelp "PRIVMSG $c :[cs:dfl $e]"}}
   2 {foreach e $o {puthelp "NOTICE $n :[cs:dfl $e]"}}
   3 {foreach e $o {puthelp "PRIVMSG $n :[cs:dfl $e]"}}
 }
}

proc cs:prep {type sortfor c who} {
 global cs csc csu
 if {$type == 0} {
  foreach e "i j t wc wl k ku b bu id" {set $e 0}
  foreach e [array names csu *$c] {
   incr i; incr j  [lindex $csu($e) 2]; incr t [lindex $csu($e) 3]; incr k  [lindex $csu($e) 8]
   incr wc [expr [lindex $csu($e) 4] + [lindex $csu($e) 6]]; incr b [lindex $csu($e) 10]
   incr wl [expr [lindex $csu($e) 5] + [lindex $csu($e) 7]]; incr id [lindex $csu($e) 13]
  }
  if {$i == 0} {return "Apparently, $c has no users. Try again later"}
  if {$k != 0} {set insert ", one kick every [cs:dur [expr $t/$k]])."} else {set insert ")."}
  regexp {\d{1,10}\..{2}} [expr $k/$i.0] ku
  regexp {\d{1,10}\..{2}} [expr $b/$i.0] bu
  append o "Monitoring: [lindex $csc($c) 0]   Started: [cs:date $c sta]   Stopped: [cs:date $c sto]   Last cycle: [cs:date $c lr]\n"
  append o "Channel peak: [lindex $csc($c) 4] users on [cs:date $c peak]\n"
  append o "I've seen [cs:fmt $i] people joining [cs:fmt $j] times wasting [cs:dur $t].\n"
  append o "Their idletimes add up to [cs:dur $id] leaving [cs:dur [expr $t - $id]] of active chatting.\n"
  if {$wl > 0} {
   regexp {\d{1,10}\..{1}} [expr $wc/$wl.0] wla
   append o "All in all, people have spoken [cs:fmt $wc] words on [cs:fmt $wl] lines (avg $wla).\n"
  }
  append o "I count [cs:fmt $k] kicks/[cs:fmt $b] bans ($ku kicks/$bu bans per user$insert"
  return $o
 }
 if {$type == 1} {
  set l ""
  foreach e [array names csu *$c] {lappend l "[lindex $csu($e) 0] [lindex $csu($e) $sortfor]"}
  if {$l != ""} {set l [lsort -integer -decreasing -index 1 $l]} else {return "Insufficient data, please try again later"}
  for {set i 0} {$i <= $cs(rankrange)} {incr i} {
   set n [lindex [lindex $l $i] 0]; set r [lindex [lindex $l $i] 1]
   if {$n == "" || $r == 0} {append o "04[expr $i + 1]. N/A "; continue}
   append o "04[expr $i + 1]. $n $r "
  }
  return $o
 }
 if {$type == 2} {
  set l ""
  foreach e [array names csu *$c] {lappend l "[lindex $csu($e) 0] [lindex $csu($e) $sortfor]"}
  if {$l != ""} {set l [lsort -integer -decreasing -index 1 $l]} else {return "Insufficient data, please try again later"}
  for {set i 0} {$i <= $cs(rankrange)} {incr i} {
   set n [lindex [lindex $l $i] 0]; set r [lindex [lindex $l $i] 1]
   if {$n == "" || $r == 0} {append o "04[expr $i + 1]. N/A "} else {append o "04[expr $i + 1]. $n [cs:dur $r] "}
  }
  return $o
 }
 if {$type == 3} {
  set l ""
  foreach e [array names csu *$c] {lappend l "[lindex $csu($e) 0] [expr [lindex $csu($e) 3] - [lindex $csu($e) 13]]"}
  if {$l != ""} {set l [lsort -integer -decreasing -index 1 $l]} else {return "Insufficient data, please try again later"}
  for {set i 0} {$i <= $cs(rankrange)} {incr i} {
   set n [lindex [lindex $l $i] 0]; set r [lindex [lindex $l $i] 1]
   if {$n == "" || $r == 0} {append o "04[expr $i + 1]. N/A "} else {append o "04[expr $i + 1]. $n [cs:dur $r] "}
  }
  return $o
 }
 if {$type == 4} {
  set w [string tolower $who];  set l ""
  if {![info exists csu($w$c)]} {
   if {[info exists csu(.$w$c)]} {return "$who's account in $c has been frozen. Try again later."} else {
    return "No record about $who in $c"
   }
  }
  foreach e [array names csu *$c] {lappend l "[lindex $csu($e) 0] [lindex $csu($e) $sortfor]"}
  if {$l != ""} {set l [lsort -integer -decreasing -index 1 $l]} else {return "Insufficient data, please try again later"}
  set cw [lindex $csu($w$c) 4]; set aw [lindex $csu($w$c) 6]; set insert1 ""; set insert2 ""
  set insert3 ""; set cwavg "N/A"; set rc "N/A"; set awavg "N/A"; set ra "N/A"
  if {[onchan $who $c]} {
   set ts [expr [lindex $csu($w$c) 3] + ([clock seconds] - [lindex $csu($w$c) 1]) ]} else {
   set ts [lindex $csu($w$c) 3]
  }
  if {$ts == 0} {set ts "N/A"} else {
   set insert3 "-> Active chatting: [cs:dur [expr $ts - [lindex $csu($w$c) 13]]]"
   set ts "[cs:dur $ts] "
  }
  if {$cw > 0} {
   set rc [expr [lsearch [string tolower $l] $w*] + 1]
   regexp {\d{1,3}\..{1}} [expr $cw.0/[lindex $csu($w$c) 5]] cwavg
   if {$rc > 1} {
    set rcp [expr $rc - 2]
    set insert1 "04[lindex [lindex $l $rcp] 0] is [expr [lindex [lindex $l $rcp] 1] - $cw] words ahead"
   }
  }
  if {$aw > 0} {
   set l ""
   regexp {\d{1,3}\..{1}} [expr $aw.0/[lindex $csu($w$c) 7]] awavg
   foreach e [array names csu *$c] {lappend l "[lindex $csu($e) 0] [lindex $csu($e) 6]"}
   if {$l != ""} {set l [lsort -integer -decreasing -index 1 $l]}
   set ra [expr [lsearch [string tolower $l] $w*] + 1]
   if {$ra > 1} {
    set rap [expr $ra - 2]
    set insert2 "04[lindex [lindex $l $rap] 0] is [expr [lindex [lindex $l $rap] 1] - $aw] words ahead"
   }
  }
  append o "Personal stats for 04[cs:dfl [lindex $csu($w$c) 0]] on 04$c\n"
  append o "Joins: [lindex $csu($w$c) 2]   Time spent: $ts   Idle: [cs:dur [lindex $csu($w$c) 13]] $insert3\n"
  append o "TopTalkers: Rank $rc - $cw words/[lindex $csu($w$c) 5] lines (avg $cwavg). $insert1\n"
  append o "AllStars: Rank $ra - $aw words/[lindex $csu($w$c) 7] lines (avg $awavg). $insert2\n"
  append o "Kicks: [lindex $csu($w$c) 8]   Bans: [lindex $csu($w$c) 9]   Got kicked: [lindex $csu($w$c) 10]   Got banned: [lindex $csu($w$c) 11]"
  return $o
 }
}

proc cs:change {n uh h c a} {
 global cs csc csu
 set c [string tolower $c]; if {![info exists csc($c)]} {return}
 set a [cs:fl $a]; set what [lindex $a 0]
 if {[string match -nocase toptalker $what]} {set p 4; set q 5; set str "TopTalker"}
 if {[string match -nocase allstar $what]} {set p 6; set q 7; set str "AllStar"}
 if {![info exists p]} {puthelp "NOTICE $n :Usage: $cs(trigger)change toptalker|allstar <nick> <+|-amount>"; return}
 set ni [lindex $a 1]; set nic [string tolower $ni]; set value [lindex $a 2]
 if {[info exists csu($nic$c)]} {
  if {[string is integer $value]} {
   set old [lindex $csu($nic$c) $p]; set lines [lindex $csu($nic$c) $q]; set new [expr $old + $value]
   if {$old > 0} {set x [expr $lines + int($value / ($old / $lines))]} else {set x [expr $lines + int($value / 4)]}
   if {$new < 0} {set new 0; set x 0; set value $old}
   set csu($nic$c) [lreplace $csu($nic$c) $p $p $new]
   set csu($nic$c) [lreplace $csu($nic$c) $q $q $x]
   puthelp "NOTICE $n :Changed [cs:dfl $ni]'s $str balance from $old by $value to $new"
  } else {puthelp "NOTICE $n :Use an integer like +1000 or -500"}
 } else {puthelp "NOTICE $n :No record about [cs:dfl $ni] in $c"}
}

proc cs:merge {n uh h c a} {
 global cs csc csu
 set c [string tolower $c]; if {![info exists csc($c)]} {return}
 set a [cs:fl $a]; set from [lindex $a 0]; set i 2
 set froml [string tolower $from]; set to [lindex $a 1]; set tol [string tolower $to]
 if {[llength $a] != 2} {puthelp "NOTICE $n :Usage: $cs(trigger)merge <source-nick> <destination-nick>"; return}
 if {[info exists csu($froml$c)]} {
  if {[info exists csu($tol$c)]} {
   while {$i < 12} {
    set csu($tol$c) [lreplace $csu($tol$c) $i $i [expr [lindex $csu($froml$c) $i] + [lindex $csu($tol$c) $i]]]
    incr i
   }
   set csu($tol$c) [lreplace $csu($tol$c) 13 13 [expr [lindex $csu($froml$c) 13] + [lindex $csu($tol$c) 13]]]
   unset csu($froml$c)
   puthelp "NOTICE $n :Merged [cs:dfl $from] in [cs:dfl $to], deleted [cs:dfl $from]"
  } else {puthelp "NOTICE $n :No record about [cs:dfl $to] in $c"}
 } else {puthelp "NOTICE $n :No record about [cs:dfl $from] in $c"}
}

proc cs:merge_dcc {h idx a} {
 global cs csc csu
  set a [cs:fl $a]
  if {[llength $a] != 3} {
    putlog "Usage: .statmerge <#channel> <source-nick> <destination-nick>"
    return
  }
  set c [lindex $a 0]; set c [string tolower $c]
  if {![info exists csc($c)]} {
    putlog "channel $c not supportet or not active for stats"
    putlog "Usage: .statmerge <#channel> <source-nick> <destination-nick>"
    return
  }
  set from [lindex $a 1]; set i 2; set froml [string tolower $from]
  set to   [lindex $a 2]; set tol [string tolower $to]
  if {[info exists csu($froml$c)]} {
   if {[info exists csu($tol$c)]} {
    while {$i < 12} {
     set csu($tol$c) [lreplace $csu($tol$c) $i $i [expr [lindex $csu($froml$c) $i] + [lindex $csu($tol$c) $i]]]
     incr i
    }
    set csu($tol$c) [lreplace $csu($tol$c) 13 13 [expr [lindex $csu($froml$c) 13] + [lindex $csu($tol$c) 13]]]
    unset csu($froml$c)
    putlog "Merged [cs:dfl $from] in [cs:dfl $to], deleted [cs:dfl $from]"
   } else {putlog "No record about [cs:dfl $to] in $c"}
  } else {putlog "No record about [cs:dfl $from] in $c"}
 }

proc cs:delete {n uh h c a} {
 global cs csc csu
 set c [string tolower $c]; if {![info exists csc($c)]} {return}
 if {$a == ""} {puthelp "NOTICE $n :Usage: $cs(trigger)delete <nick>"; return}
 set ni [cs:fl $a]; set nic [string tolower $ni]
 if {[info exists csu($nic$c)]} {
  unset csu($nic$c)
  puthelp "NOTICE $n :Deleted [cs:dfl $ni] in $c"
 } else {puthelp "NOTICE $n :No record about [cs:dfl $ni] in $c"}
}

proc cs:delete_dcc {h idx a} {
 global cs csc csu
  set a [cs:fl $a]
  if {[llength $a] != 2} {
    putlog "Usage: .statdelete <#channel> <nick>"
    return
  }
  set c [lindex $a 0]; set c [string tolower $c]
  if {![info exists csc($c)]} {
    putlog "channel $chan not supportet or not active for stats"
    putlog "Usage: .statdelete <#channel> <nick>"
    return
  }
 set ni [lindex $a 1]; set nic [string tolower $ni]
 if {[info exists csu($nic$c)]} {
  unset csu($nic$c)
  putlog "Deleted [cs:dfl $ni] in $c"
 } else {putlog "No record about [cs:dfl $ni] in $c"}
}

proc cs:freeze {n uh h c a} {
 global cs csu
 set c [string tolower $c]; set ar [string tolower [cs:fl $a]]
 if {$ar == ""} {puthelp "NOTICE $n :Usage: $cs(trigger)freeze <nick> ?<nick> ..?"; return}
 foreach e $ar {
  if {[info exists csu($e$c)]} {
   cs:reset $e$c
   set csu(.$e$c) $csu($e$c)
   unset csu($e$c)
   puthelp "NOTICE $n :[cs:dfl $e]'s account in $c is now frozen"
  } elseif {[info exists csu(.$e$c)]} {puthelp "NOTICE $n :[cs:dfl $e]'s account in $c is already frozen"} else {
   puthelp "NOTICE $n :No record about [cs:dfl $e] in $c"
  }
 }
}

proc cs:freeze_dcc {h idx a} {
 global cs csu csc
  set a [cs:fl $a]
  if {[llength $a] < 2} {
    putlog "Usage: .statfreeze <#channel> <nick> ?<nick> ..?"
    return
  }
  set c [lindex $a 0]; set c [string tolower $c]
  if {![info exists csc($c)]} {
    putlog "channel $c not supportet or not active for stats"
    putlog "Usage: .statfreeze <#channel> <nick> ?<nick> ..?"
    return
  }
 set ar [string tolower [lrange $a 1 end]]
 foreach e $ar {
  if {[info exists csu($e$c)]} {
   cs:reset $e$c
   set csu(.$e$c) $csu($e$c)
   unset csu($e$c)
   putlog "[cs:dfl $e]'s account in $c is now frozen"
  } elseif {[info exists csu(.$e$c)]} {putlog "[cs:dfl $e]'s account in $c is already frozen"} else {
   putlog "No record about [cs:dfl $e] in $c"
  }
 }
}

proc cs:unfreeze {n uh h c a} {
 global cs csu
 set c [string tolower $c]; set ar [string tolower [cs:fl $a]]
 if {$ar == ""} {puthelp "NOTICE $n :Usage: $cs(trigger)unfreeze <nick> ?<nick> ..?"; return}
 foreach e $ar {
  if {[info exists csu(.$e$c)]} {
   set csu($e$c) $csu(.$e$c)
   unset csu(.$e$c)
   if {[onchan [cs:dfl $e] $c]} {cs:join [lindex $csu($e$c) 0] "unknown" "unknown" $c}
   puthelp "NOTICE $n :Unfroze [cs:dfl $e]'s account in $c"
  } else {puthelp "NOTICE $n :[cs:dfl $e]'s account in $c was not frozen."}
 }
}

proc cs:unfreeze_dcc {h idx a} {
 global cs csu csc
  set a [cs:fl $a]
  if {[llength $a] < 2} {
    putlog "Usage: .statunfreeze <#channel> <nick> ?<nick> ..?"
    return
  }
  set c [lindex $a 0]; set c [string tolower $c]
  if {![info exists csc($c)]} {
    putlog "channel $c not supportet or not active for stats"
    putlog "Usage: .statunfreeze <#channel> <nick> ?<nick> ..?"
    return
  }
 set ar [string tolower [lrange $a 1 end]]
 foreach e $ar {
  if {[info exists csu(.$e$c)]} {
   set csu($e$c) $csu(.$e$c)
   unset csu(.$e$c)
   if {[onchan [cs:dfl $e] $c]} {cs:join [lindex $csu($e$c) 0] "unknown" "unknown" $c}
   putlog "Unfroze [cs:dfl $e]'s account in $c"
  } else {putlog "[cs:dfl $e]'s account in $c was not frozen."}
 }
}

proc cs:cycle {n uh h c a} {
 global cs csc csu
 set c [string tolower $c]
 if {![info exists csc($c)]} {return}
 foreach e [array names csu *$c] {
  set csu($e) [lreplace $csu($e) 6 6 [expr [lindex $csu($e) 6] + [lindex $csu($e) 4]]]
  set csu($e) [lreplace $csu($e) 7 7 [expr [lindex $csu($e) 7] + [lindex $csu($e) 5]]]
  set csu($e) [lreplace $csu($e) 4 4 0]
  set csu($e) [lreplace $csu($e) 5 5 0]
 }
 set csc($c) [lreplace $csc($c) 3 3 [clock seconds]]
 cs:save
 puthelp "PRIVMSG $c :CHATstats: Finished cycling TopTalkers."
 putlog "CHATstats: Finished cycling TopTalkers ($h, $c)"
}

proc cs:status {h idx a} {
 global cs csa csc csu
 set bc ""; set i 0; set al "csa csc csu"
 foreach e $al {
  foreach el [array names $e] {
   set el "#[lindex [split $el #] 1]"
   if {[lsearch $bc $el] > -1} {incr i; continue}
   if {![validchan $el]} {incr i; lappend bc $el}
  }
 }
 putdcc $idx "CHATstats [join [split $cs(scriptver) {}] .] Configuration Info"
 if {$bc != ""} {
  putdcc $idx "Database: $i orphaned entries for channels: [join $bc ", "] ('help wipechan' for more info)"
 } else {putdcc $idx "Database: clean, no orphaned entries ([array size csu] entries total)"}
 putdcc $idx "Valid idle time: > $cs(idle) seconds"
 putdcc $idx "Trigger words for invalid lines: $cs(dont)"
 putdcc $idx "Channel details:"
 foreach e [array names csc] {
  set cname [string trimleft $e #]; set files ""; set cfiles ""; set gfiles ""; set fu ""; cs:cv $e
  putdcc $idx " \n$e (Active: [lindex $csc($e) 0] Start: [cs:date $e sta] Stop: [cs:date $e sto] Last cycle: [cs:date $e lr])"
  switch $cs(post) {
   0 {set y "None, I tell them to visit $cs(adsite)"}
   1 {set y "PRIVMSG to channel"}
   2 {set y "NOTICE to user"}
   3 {set y "PRIVMSG to user"}
  }
  putdcc $idx " Database trim limit: < $cs(trimlimit) words"
  putdcc $idx " Info posting: $y"
  foreach el [array names csu .*$e] {lappend fu [lindex $csu($el) 0]}
  if {$fu == ""} {set fu "None"}
  putdcc $idx " Frozen users: [join $fu ", "]"
  putdcc $idx " Time correction: $cs(timebalance) hours (currently [strftime %H:%M [clock seconds]], corrected [strftime %H:%M [expr [clock seconds] + ($cs(timebalance) * 3600)]])"
  if {$cs(update)} {
   switch $cs(ulmethod) {
    0 {set y ", left in $cs(workdir)"}
    1 {set y ", moved to $cs(localfolder)"}
    2 {set y ", uploaded to $cs(ftpname)$cs(ftpfolder) on port $cs(ftpport)"}
   }
   putdcc $idx " Webpages: yes$y"
   putdcc $idx " Interval: $cs(update) minutes"
   append cfiles "[glob -nocomplain -path $cs(workdir) *.$cname.template] "
   append gfiles [glob -nocomplain -path $cs(workdir) *.global.template]
   foreach el $gfiles {
    set searchfor [string range $el 0 [string first "." $el]]
    if {[lsearch $cfiles $searchfor$cname.template] > -1} {
     set pos [lsearch $gfiles $el]
     set gfiles [lreplace $gfiles $pos $pos]
    }
   }
   foreach el "$cfiles$gfiles" {lappend files [lindex [split $el "/"] end]}
   putdcc $idx " Templates in use: [join $files ", "]"
   if {$cs(adinterval)} {putdcc $idx " Advertisements: every $cs(adinterval) minutes"} else {putdcc $idx " Advertisements: no"}
  } else {putdcc $idx " Webpage creation: no"}
 }
}

proc cs:read {} {
 global cs csa csc csu
 if {[info exists cs(rehash)]} {return}
 set fid [open $cs(workdir)CHATstats.dat r]
 gets $fid cs(datafilever)
 gets $fid l
 if {![string match "--UserData--" $l]} {
  putlog "CHATstats: CHATstats.dat corrupted. Script not loaded properly."
  return
 }
 gets $fid l
 while {![string match "--ChannelData--" $l]} {
  if {[llength $l] == 15} {
   set l [lreplace $l 1 1 0]
   set l [lreplace $l 12 12 0]
   if {[lindex $l 3] > 900000000} {set l [lreplace $l 3 3 0]}
   if {[lindex $l 13] > [lindex $l 3]} {set l [lreplace $l 13 13 [lindex $l 3]]}
   set csu([string tolower [lindex $l 0]][lindex $l 14]) [lrange $l 0 13]
  } else {putlog "            Corrupt line in CHATstats.dat, not loaded: $l"}
  gets $fid l
 }
 gets $fid l
 while {![string match "--ActivityData--" $l]} {
  if {[llength $l] == 7} {set csc([lindex $l 0]) [lrange $l 1 end]} else {
   putlog "            Corrupt line in CHATstats.dat, not loaded: $l"
  }
  gets $fid l
 }
 gets $fid l
 while {![eof $fid]} {
  if {[llength $l] == 26} {
   set c [lindex $l 0]; set l [lrange $l 1 end]
   foreach e $l {set csa([lindex $e 0]$c) [lindex $e 1]}
  } else {putlog "            Corrupt line in CHATstats.dat, not loaded: $l"}
  gets $fid l
 }
 close $fid
}

proc cs:autosave {mi ho da mo ye} {cs:save}

proc cs:save {} {
 global cs csa csc csu
 set fid [open $cs(workdir)CHATstats.dat w]
 puts $fid "CHATstats datafile v3.0"
 puts $fid "--UserData--"
 if {[array exists csu]} {
  foreach e [array names csu] {puts $fid "$csu($e) #[lindex [split $e #] 1]"}
 }
 puts $fid "--ChannelData--"
 if {[array exists csc]} {
  foreach e [array names csc] {puts $fid "$e $csc($e)"}
 }
 puts $fid "--ActivityData--"
 if {[array exists csa]} {
  foreach e [array names csa] {lappend l(#[lindex [split $e #] 1]) "[lindex [split $e #] 0] $csa($e)"}
  foreach e [array names l] {puts $fid "$e $l($e)"}
 }
 close $fid
 if {![file exists $cs(workdir)CHATstats.backup]} {
  file copy -force $cs(workdir)CHATstats.dat $cs(workdir)CHATstats.backup
 }
}

proc cs:backup {h idx a} {
 global cs csa csc csu
 cs:save
 file copy -force $cs(workdir)CHATstats.dat $cs(workdir)CHATstats.backup
 putdcc $idx "Saved current data and copied CHATstats.dat to CHATstats.backup."
}

proc cs:recover {h idx a} {
 global cs csa csc csu
 if {![file exists $cs(workdir)CHATstats.backup]} {
  putdcc $idx "Can't find file $cs(workdir)CHATstats.backup, aborting."
  return
 }
 unset csa; unset csc; unset csu
 file copy -force $cs(workdir)CHATstats.backup $cs(workdir)CHATstats.dat
 unset cs(rehash); cs:read; set cs(rehash) 1
 putdcc $idx "Database reloaded from CHATstats.backup."
}

proc cs:wipechan {h idx a} {
 global cs csa csc csu
 set c [string tolower $a]; set l ""
 if {$c == "" || [string range $c 0 0] != "#"} {putdcc $idx "Usage: .wipechan <channel> ?<channel> ..?"; return}
 foreach e $c {
  if {[lsearch -exact [bind pubm - "$e *"] cs:count] > -1} {
   putdcc $idx "CHATstats is enabled on $e. Use \".stop $e\" in DCC first."
  } else {
   set al "csa csc csu"; set f 0
   foreach el $al {foreach ele [array names $el *$e] {set f 1}}
   if {!$f} {putdcc $idx "Can't find channel $e in database"} else {
    foreach el [timers] {if {[string match *cs:*$e* $el]} {killtimer [lindex $el 2]}}
    array unset csa *$e; array unset csc $e; array unset csu *$e; lappend l $e
   }
  }
 }
 if {$l != ""} {cs:save; putdcc $idx "Deleted all entries for [join $l ", "] from database."}
}

proc cs:trim {h idx a} {
 global cs csu
 set c [lindex [string tolower $a] 0]; set limit [lindex $a 1]; set foo 0; set l ""
 if {$idx == -1} {
  foreach e [array names csu *$c] {lappend l $e}
  if {$l != ""} {
   foreach e $l {
    if {([lindex $csu($e) 4] < $limit) && ([lindex $csu($e) 6] < $limit)} {unset csu($e); incr foo}
   }
   putlog "Trimmed CHATstats database for $c by $limit words, $foo of [llength $l] users have been removed."
  } else {putlog "CHATstats: No user in $c has less than $limit words, no need to trim database."}
  return
 }
 if {[string is integer $c]} {
  set limit $c; set bar [array size csu]
  foreach e [array names csu] {
   if {([lindex $csu($e) 4] < $a) && ([lindex $csu($e) 6] < $a)} {unset csu($e); incr foo}
  }
  cs:save
  putdcc $idx "Trimmed complete CHATstats database by $limit words, $foo of $bar users have been removed."
 } else {
  foreach e [array names csu *$c] {lappend l $e}
  if {$l == ""} {putdcc $idx "Can't find channel $c in CHATstats database"; return}
  foreach e $l {
   if {([lindex $csu($e) 4] < $limit) && ([lindex $csu($e) 6] < $limit)} {unset csu($e); incr foo}
  }
  putdcc $idx "Trimmed CHATstats database for $c by $limit words, $foo of [llength $l] users have been removed."
 }
}

proc cs:autotrim {mi ho da mo ye} {
 global cs
 set l ""
 foreach e [binds cs:count] {
  regexp {#.*?\s} $e e; set e [string trim $e]; lappend l $e
 }
 if {$l == ""} {return} else {
  foreach e $l {
   cs:cv $e; cs:trim "CHATstats" "-1" "$e $cs(trimlimit)"
  }
 }
}

proc cs:advertize {c} {
 global cs
 cs:cv $c
 puthelp "PRIVMSG $c :I create diverse statistics for $c. Go visit $cs(adsite)"
 timer $cs(adinterval) "cs:advertize $c"
}

proc cs:update {h idx a} {
 global cs
 set c [string tolower $a]; set l ""
 foreach e [binds cs:count] {
  regexp {#.*?\s} $e e
  set e [string trim $e]
  cs:cv $e
  if {$cs(update)} {
   if {![validchan $e] || ![botonchan $e]} {putdcc $idx "I'm not on $e."; continue}
   lappend l $e
  }
 }
 if {[llength $l] == 0} {putdcc $idx "No channel is configured to have webpages."; return} else {set l [lsort $l]}
 if {$c == ""} {
  foreach e $l {
   cs:cv $e
   foreach el [timers] {if {[string match "*cs:html $e*" $el]} {killtimer [lindex $el 2]}}
   set cs(manual) "$idx Successfully updated webpages for $e"
   cs:html $e
  }
 } else {
  cs:cv $c
  if {![validchan $c] || ![botonchan $c]} {putdcc $idx "I'm not on $c."; return}
  if {[lsearch $l $c] == -1} {putdcc $idx "CHATstats is not enabled in $c"; return}
  if {$cs(update)} {
   foreach e [timers] {
    if {[string match "*cs:html $c*" $e]} {killtimer [lindex $e 2]}
   }
   set cs(manual) "$idx Successfully updated webpages for $c"; cs:html $c
  } else {putdcc $idx "Configuration does not allow webpages for $c"}
 }
}

proc cs:html {c} {
 global cs csa csc csu csx csy csz
 cs:save; set cname [string trimleft $c #]; set ullist ""; set cfiles ""; set gfiles ""; cs:cv $c
 if {$cs(ftperror) && $cs(ulmethod) == 2} {
  putlog "Skipped creating webpages for $c due to an FTP configuration error"
  return
 }
 if {![botonchan $c]} {
  putlog "I'm not on $c, skipped creating webpages."
  if {$cs(update)} {timer $cs(update) "cs:html $c"}
  return
 }
 append cfiles "[glob -nocomplain -path $cs(workdir) *.$cname.template] "
 append gfiles [glob -nocomplain -path $cs(workdir) *.global.template]
 foreach e $gfiles {
  set searchfor [string range $e 0 [string first "." $e]]
  if {[lsearch $cfiles $searchfor$cname.template] > -1} {
   set pos [lsearch $gfiles $e]
   set gfiles [lreplace $gfiles $pos $pos]
  }
 }
 set files "$cfiles$gfiles"
 if {$files == ""} {
  putlog "There are no templates in $cs(workdir), skipped creating webpages for $c. "
  if {$cs(update)} {timer $cs(update) "cs:html $c"}
  return
 }
 foreach e $files {
  set output "[string range $e 0 [string first "." $e]]$cname$cs(htmsuffix)"
  cs:create $c $e $output
  lappend ullist $output
 }
 if {[array exists csx]} {unset csx}
 if {[array exists csy]} {unset csy}
 if {[array exists csz]} {unset csz}
 if {$ullist != ""} {
  switch -exact $cs(ulmethod) {
   1 {foreach e $ullist {
       if {[file exists $e]} {
        file copy -force $e $cs(localfolder)
        file delete -force $e
       } else {putlog "CHATstats: Skipped moving $e, file not found."}
      }
     }
   2 {set ftperror [catch {
       set ftpid [open "|$cs(ftpclient) -n $cs(ftpname) $cs(ftpport)" w]
       puts $ftpid "user $cs(username) $cs(password)"
       foreach a $ullist {
        if {[file exists $a]} {
         puts $ftpid "put $a $cs(ftpfolder)[lindex [split $a "/"] end]"
        } else {putlog "CHATstats: Skipped uploading $a, file not found."}
       }
       puts $ftpid "quit"
       close $ftpid
      }]
      if {$ftperror} {putlog "CHATstats: An error occured while trying to use FTP."}
      foreach a $ullist {file delete -force $a}
     }
  }
 }
 if {[info exists cs(manual)]} {
  putdcc [lindex $cs(manual) 0] "[lrange $cs(manual) 1 end]"
  unset cs(manual)
 }
 if {$cs(update)} {timer $cs(update) "cs:html $c"}
}

proc cs:create {c input output} {
 global cs csa csc csu csx csy csz cst botnick offset timezone uptime server {server-online}
 if {![array exists csy]} {
  set csy(plusers) ""; set csy(ulink) "None"
  if {[llength [bots]] > 0} {set csy(bots) [join [lsort -dictionary [bots]] ", "]} else {set csy(bots) "None"}
  foreach e [whom *] {if {$e != ""} {lappend csy(plusers) [cs:fl "[lindex $e 0] [lindex $e 1] [lindex $e 6]"]}}
  set csy(plusers) [lsort -dictionary $csy(plusers)]
  foreach e [bots] {
   if {([validuser $e]) && ([string match *h* [getuser $e BOTFL]]) && ([islinked $e])} {set csy(ulink) [cs:fl $e]}
   if {([validuser $e]) && ([matchattr $e b]) && (![string match *h* [getuser $e BOTFL]]) && ([islinked $e])} {lappend csy(dlinks) [cs:fl $e]}
  }
  if {[info exists csy(dlinks)]} {set csy(dlinks) [join [lsort -dictionary $csy(dlinks)] ", "]} else {set csy(dlinks) "None"}
 }
 if {![array exists csx]} {
  set topic [cs:fltpc [topic $c]]
  foreach e "all nos ops vos ttoptalkers tallstars tjoins totime ttwords ttlines tawords talines tkicks tbans titime" {set csx($e) 0}
  foreach e "csx(chbans) csx(chul) csx(topic) oplist volist uslist" {set $e ""}
  foreach e [chanlist $c] {
   incr csx(all)
   if {[isop $e $c]} {incr csx(ops); set e "@[cs:fl $e]"; lappend oplist $e; continue}
   if {[isvoice $e $c]} {incr csx(vos); set e "+[cs:fl $e]"; lappend volist $e; continue}
   set e " [cs:fl $e]"; incr csx(nos); lappend uslist $e
  }
  set csx(chul) [append csx(chul) " [lsort -dictionary $oplist]" " [lsort -dictionary $volist]" " [lsort -dictionary $uslist]"]
  set csx(opsp) [expr ($csx(ops) * 100) / $csx(all)]
  set csx(vosp) [expr ($csx(vos) * 100) / $csx(all)]
  set csx(nosp) [expr ($csx(nos) * 100) / $csx(all)]
  foreach e [chanbans $c] {lappend csx(chbans) "[lindex [split $e] 0]"}
  set csx(chbans) [lsort -dictionary $csx(chbans)]
  if {![info exists cst($c)]} {set cst($c) "N/A"}
  # regsub -all "(.{50}\[^http://\])" $csx(topic) {\1<BR>} csx(topic)
  foreach e [split $topic] {
   if {[string match "http://*" $e]} {
    set el $e
    regsub -all "<BR>" $e "" e
    append csx(topic) " <A HREF=\"$e\">$el</A>"
   } else {append csx(topic) " $e"}
  }
  if {![info exists timezone] || $timezone == ""} {set timezone "N/A"}
  if {![info exists offset] || $offset == ""} {set offset "N/A"}
  foreach e [array names csu *$c] {
   if {[lindex $csu($e) 4] > 0} {incr csx(ttoptalkers)}
   if {[lindex $csu($e) 6] > 0} {incr csx(tallstars)}
   incr csx(tjoins) [lindex $csu($e) 2]; incr csx(totime) [lindex $csu($e) 3]; incr csx(ttwords) [lindex $csu($e) 4]
   incr csx(ttlines) [lindex $csu($e) 5]; incr csx(tawords) [lindex $csu($e) 6]; incr csx(talines) [lindex $csu($e) 7]
   incr csx(tkicks)  [lindex $csu($e) 8]; incr csx(tbans) [lindex $csu($e) 10]; incr csx(titime) [lindex $csu($e) 13]
  }
 }
 set fid [open $input r]
 set html [open $output w]
 while {![eof $fid]} {
  gets $fid l; set i 0
  while {[regexp {%%[A-Z]} $l null]} {
   if {$i > 50} {break}
   switch -glob $l {
    *%%BOTNICK*      {regsub -all %%BOTNICK $l $botnick l}
    *%%BOTIRCSERVER* {regsub -all %%BOTIRCSERVER $l $server l}
    *%%BOTONLINE*    {regsub -all %%BOTONLINE $l [cs:dur [expr [clock seconds] - ${server-online}]] l}
    *%%BOTNETBOTS*   {regsub -all %%BOTNETBOTS $l $csy(bots) l}
    *%%BOTNETSIZE*   {regsub -all %%BOTNETSIZE $l [cs:fmt [llength $csy(bots)]] l}
    *%%BOTNETUSERS*  {regsub -all %%BOTNETUSERS $l [cs:fmt [llength $csy(plusers)]] l}
    *%%BOTUSERLIST*  {regsub -all %%BOTUSERLIST $l [cs:fmt [countusers]] l}
    *%%BOTUPLINK*    {regsub -all %%BOTUPLINK $l [cs:dfl $csy(ulink)] l}
    *%%BOTDOWNLINKS* {regsub -all %%BOTDOWNLINKS $l [cs:dfl $csy(dlinks)] l}
    *%%BOTUPTIME*    {regsub -all %%BOTUPTIME $l [cs:dur [expr [clock seconds] - $uptime]] l}
    *%%BOTOFFSET*    {regsub -all %%BOTOFFSET $l $offset l}
    *%%BOTTIMEZONE*  {regsub -all %%BOTTIMEZONE $l $timezone l}
    *%%SCRIPTSTATUS*  {regsub -all %%SCRIPTSTATUS $l [lindex $csc($c) 0] l}
    *%%SCRIPTSTARTED* {regsub -all %%SCRIPTSTARTED $l [cs:date $c sta] l}
    *%%SCRIPTSTOPPED* {regsub -all %%SCRIPTSTOPPED $l [cs:date $c sto] l}
    *%%SCRIPTCYCLE*   {regsub -all %%SCRIPTCYCLE $l [cs:date $c lr] l}
    *%%CHANNEL*        {regsub -all & $c "\\\\&" cfix; regsub -all %%CHANNEL $l $cfix l}
    *%%CHANTOPIC*      {regsub -all & $csx(topic) "\\\\&" ctopfix; regsub -all %%CHANTOPIC $l $ctopfix l}
    *%%CHANTOPSETTER*  {regsub -all %%CHANTOPSETTER $l $cst($c) l}
    *%%CHANMODES*      {regsub -all %%CHANMODES $l [getchanmode $c] l}
    *%%CHANUSERS*      {regsub -all %%CHANUSERS $l $csx(all) l}
    *%%CHANOPS*        {regsub -all %%CHANOPS $l $csx(ops) l}
    *%%CHANVOICES*     {regsub -all %%CHANVOICES $l $csx(vos) l}
    *%%CHANOTHERS*     {regsub -all %%CHANOTHERS $l $csx(nos) l}
    *%%CHAN%USERS*     {regsub -all %%CHAN%USERS $l "100%" l}
    *%%CHAN%OPS*       {regsub -all %%CHAN%OPS $l "$csx(opsp)%" l}
    *%%CHAN%VOICES*    {regsub -all %%CHAN%VOICES $l "$csx(vosp)%" l}
    *%%CHAN%OTHERS*    {regsub -all %%CHAN%OTHERS $l "$csx(nosp)%" l}
    *%%CHANPEAKVALUE*  {regsub -all %%CHANPEAKVALUE $l [lindex $csc($c) 4] l}
    *%%CHANPEAKDATE*   {regsub -all %%CHANPEAKDATE $l [cs:date $c peak] l}
    *%%TIMEBALANCE*    {regsub -all %%TIMEBALANCE $l $cs(timebalance) l}
    *%%TIMENOW*        {regsub -all %%TIMENOW $l [cs:date $c curr] l}
    *%%TIMENEXTUPDATE* {regsub -all %%TIMENEXTUPDATE $l [cs:date $c nu] l}
    *%%TOPTALKERSAMOUNT* {regsub -all %%TOPTALKERSAMOUNT $l [cs:fmt $csx(ttoptalkers)] l}
    *%%TOPTALKERSWORDS*  {regsub -all %%TOPTALKERSWORDS $l [cs:fmt $csx(ttwords)] l}
    *%%TOPTALKERSLINES*  {regsub -all %%TOPTALKERSLINES $l [cs:fmt $csx(ttlines)] l}
    *%%TOPTALKERSRATIO*  {set x [expr $csx(ttwords).0 / ($csx(ttlines) + 1)]; regexp {\d+\..{1}} $x x; regsub -all %%TOPTALKERSRATIO $l $x l}
    *%%ALLSTARSAMOUNT*   {regsub -all %%ALLSTARSAMOUNT $l [cs:fmt $csx(tallstars)] l}
    *%%ALLSTARSWORDS*    {regsub -all %%ALLSTARSWORDS $l [cs:fmt $csx(tawords)] l}
    *%%ALLSTARSLINES*    {regsub -all %%ALLSTARSLINES $l [cs:fmt $csx(talines)] l}
    *%%ALLSTARSRATIO*    {set x [expr $csx(tawords).0 / ($csx(talines) + 1)]; regexp {\d+\..{1}} $x x; regsub -all %%ALLSTARSRATIO $l $x l}
    *%%TOTALWORDS*       {regsub -all %%TOTALWORDS $l [cs:fmt [expr $csx(ttwords) + $csx(tawords)]] l}
    *%%TOTALLINES*       {regsub -all %%TOTALLINES $l [cs:fmt [expr $csx(ttlines) + $csx(talines)]] l}
    *%%TOTALRATIO*       {set x [expr ($csx(ttwords) + $csx(tawords)) / ($csx(ttlines).0 + $csx(talines) + 1)]
                          regexp {\d+\..{1}} $x x; regsub -all %%TOTALRATIO $l $x l}
    *%%TOTALJOINS*       {regsub -all %%TOTALJOINS $l [cs:fmt $csx(tjoins)] l}
    *%%TOTALKICKS*       {regsub -all %%TOTALKICKS $l [cs:fmt $csx(tkicks)] l}
    *%%TOTALBANS*        {regsub -all %%TOTALBANS $l [cs:fmt $csx(tbans)] l}
    *%%TOTALONLINE*      {regsub -all %%TOTALONLINE $l [cs:dur $csx(totime)] l}
    *%%TOTALIDLE*        {regsub -all %%TOTALIDLE $l [cs:dur $csx(titime)] l}
    *%%TOTALACTIVE*      {regsub -all %%TOTALACTIVE $l [cs:dur [expr $csx(totime) - $csx(titime)]] l}
   }
   incr i
  }
  if {[string match -nocase "<!--*-->" $l]} {
   set width 0; set amount 0; set eoc 0; set what ""; set rep1 ""; set list ""
   regexp {(\w+)\s(\d+)?,?(\d+)?} $l match what width amount
   set what [string tolower $what]
   while {!$eoc} {
    gets $fid nl
    if {[string match -nocase "<!--*end of $what*-->" $nl] || [eof $fid]} {set eoc 1} else {append rep1 $nl}
   }
   switch -glob $what {
    botnetmap {
     if {[info exists botnet-nick]} {set lb [string range ${botnet-nick} 0 8]} else {set lb [string range $botnick 0 8]}
     if {[info exists csz]} {unset csz}
     foreach e [botlist] {set csz([lindex $e 0]) [lindex $e 1]}
     set csz($lb) $lb
     puts $html "   $lb   "
     cs:botnetmap "     " $html $lb
     continue
    }
    partyline {
     foreach e $csy(plusers) {
      regsub -all !!USER $rep1 [lindex $e 0] rep2
      regsub -all !!BOT $rep2 [lindex $e 1] rep2
      regsub -all !!CHAN $rep2 [lindex $e 2] rep2
      puts $html [cs:dfl $rep2]
     }
     continue
    }
    bans {
     for {set i 0} {$i <= [llength $csx(chbans)]} {incr i} {
      regsub !!BAN $rep1 [lindex $csx(chbans) $i] rep2
      while {[string match *!!BAN* $rep2]} {incr i; regsub !!BAN $rep2 [lindex $csx(chbans) $i] rep2}
      puts $html [cs:dfl $rep2]
     }
     continue
    }
    activity {
     if {$width == 0} {
      putlog "CHATstats: Syntax error in template $input, must be: <!-- activity x,0  --> (see file INSTALLATION for help)"
      continue
     }
     foreach e [array names csa *$c] {lappend list "[lindex [split $e #] 0] $csa($e)"}
     set total 0; foreach e $list {incr total [lindex $e 1]}
     set list [lsort -integer -decreasing -index 1 $list]
     set max [expr ([lindex [lindex $list 0] 1] * 100.0)/$total]
     set list [lsort -increasing -index 0 $list]
     for {set i 0} {$i < 24} {incr i} {
      set int [lindex [lindex $list $i] 1]
      set x [expr ($int * 100.0)/$total]
      regexp {\d{1,3}\..{1}} $x x
      set barlength [expr int($x * ($width / $max) + ($x / 10))]
      regsub !!TIME1 $rep1 "[lindex [lindex $list $i] 0]:00" rep2
      regsub !!TIME2 $rep2 "[lindex [lindex $list [expr $i + 1]] 0]:00" rep2
      regsub !!VALUE $rep2 $int rep2
      regsub !!PERCENT $rep2 "$x%" rep2
      regsub !!WIDTH $rep2 $barlength rep2
      puts $html $rep2
     }
     continue
    }
    chanusers {
     foreach n $csx(chul) {
      set n [cs:dfl $n]; set ni [string range $n 1 end]; set u [clock seconds]
      if {![onchan $ni $c]} {continue}
      set gcj [getchanjoin $ni $c]
      if {$gcj > 0} {set gcj "[expr round((($u-$gcj)/60)/60)]h:[expr round(fmod((($u-$gcj)/60),60))]m"} else {set gcj "N/A"}
      if {[nick2hand $ni $c] == "*"} {set flags "-"} else {set flags [chattr $ni $c]}
      if {$flags == "*"} {set flags "-"}
      regsub -all "!!USER" $rep1 $n rep2
      regsub -all "!!HOST" $rep2 [string range [getchanhost $ni] 0 45] rep2
      regsub -all "!!DUR" $rep2 $gcj rep2
      regsub -all "!!IDLE" $rep2 "[getchanidle $ni $c]m" rep2
      regsub -all "!!FLAGS" $rep2 $flags rep2
      puts $html $rep2
     }
     continue
    }
    top* {
     if {$width == 0 || $amount == 0} {
      putlog "CHATstats: Syntax error in template $input, must be: <!-- $what x,y --> (see file INSTALLATION for help)"
      continue
     }
     set total 0
     switch -exact $what {
      topjoiners {set sortfor 2}  topvisitors {set sortfor 3}
      toptalkers {set sortfor 4}  topallstars {set sortfor 6}
      topkickers {set sortfor 8}  topbanners {set sortfor 9}
      topkicked {set sortfor 10}  topbanned {set sortfor 11}
      topidlers {set sortfor 13}  topactiveusers {}
      default {putlog "CHATstats: unknown listing found in template $what - aborting (see file INSTALLATION for help)."; return}
     }
     switch -exact $what {
      topactiveusers {
       foreach e [array names csu *$c] {
        lappend list "[lindex $csu($e) 0] [expr [lindex $csu($e) 3] - [lindex $csu($e) 13]]"
       }
      }
      default {
       foreach e [array names csu *$c] {
        lappend list "[lindex $csu($e) 0] [lindex $csu($e) $sortfor]"
       }
      }
     }
     if {$list != ""} {set list [lsort -integer -decreasing -index 1 $list]} else {continue}
     foreach e $list {incr total [lindex $e 1]}
     if {$total == 0} {continue}
     set max [expr ([lindex [lindex $list 0] 1] * 100.0)/$total]; set i 1
     foreach e $list {
      set int [lindex $e 1]
      if {$int == 0 || $i > $amount} {continue}
      set x [expr ($int * 100.0)/$total]
      regexp {\d{1,3}\..{1}} $x x
      set barlength [expr int($x * ($width / $max) + ($x / 10))]
      regsub -all "!!RANK" $rep1 $i rep2
      regsub -all "!!USER" $rep2 [lindex $e 0] rep2
      switch -exact $what {
       topactiveusers {regsub -all "!!VALUE" $rep2 [cs:dur $int] rep2}
       topvisitors {regsub -all "!!VALUE" $rep2 [cs:dur $int] rep2}
       topidlers {regsub -all "!!VALUE" $rep2 [cs:dur $int] rep2}
       default {regsub -all "!!VALUE" $rep2 [cs:fmt $int] rep2}
      }
      regsub -all "!!PERCENT" $rep2 "$x%" rep2
      regsub -all "!!WIDTH" $rep2 $barlength rep2
      puts $html [cs:dfl $rep2]; incr i
     }
     continue
    }
    default {puts $html $l}
   }
  }
  puts $html $l
 }
 close $html
 close $fid
}

proc cs:botnetmap {ind html bot} {
 global csz
 foreach e [array names csz] {
  if {(![string match [string tolower $bot] [string tolower $e]]) && ([string match [string tolower $csz($e)] [string tolower $bot]])} {
   lappend dl $e
  }
 }
 if {[info exists dl]} {
  foreach e $dl {
   if {[string match [string tolower $e] [string tolower [lindex $dl end]]]} {
    puts $html "$ind `-$e     "
    cs:botnetmap "$ind  " $html $e
   } else {
    puts $html "$ind |-$e     "
    cs:botnetmap "$ind |   " $html $e
   }
  }
 }
}

proc cs:checkpeak {c} {
 global cs csc
 set i [lindex $csc($c) 4]; set j [llength [chanlist $c]]
 if {$j > $i} {
  putserv "PRIVMSG $c :New peak for $c @ $j users! Old peak was $i users on [cs:date $c peak]."
  cs:cv $c
  set csc($c) [lreplace $csc($c) 4 4 $j]
  set csc($c) [lreplace $csc($c) 5 5 [clock seconds]]
  cs:save
 }
}

proc cs:date {c t} {
 global cs csc
 switch -exact $t {
  curr {return [strftime "%A, %d.%m.%Y, %H:%M" [expr [clock seconds] + $cs(timebalance) * 3600]]}
  nu   {if {[lindex $csc($c) 2] == 0} {return [strftime %H:%M [expr [clock seconds] + ($cs(timebalance) * 3600) + ($cs(update) * 60)]]} else {return "N/A"}}
  sta  {set i 1}
  sto  {set i 2}
  lr   {set i 3}
  peak {set i 5}
 }
 if {[lindex $csc($c) $i] == 0} {return "N/A"} else {return [strftime "%d.%m.%Y" [expr [lindex $csc($c) $i] + $cs(timebalance) * 3600]]}
}

proc cs:reset {w} {
 global cs csu
 set jt [lindex $csu($w) 1]; set u [clock seconds]; set nic [lindex [split $w #] 0]
 set c "#[lindex [split $w #] 1]"; set ls [lindex $csu($w) 12]; set idle 0
 if {$jt > 0} {
  set csu($w) [lreplace $csu($w) 3 3 [expr [lindex $csu($w) 3] + ($u - $jt)]]
  set csu($w) [lreplace $csu($w) 1 1 0]
  if {$ls > 0} {set idle [expr $u - $ls]} else {set idle [expr $u - $jt]}
  } else {
  if {$ls > 0} {set idle [expr $u - $ls]}
 }
 set csu($w) [lreplace $csu($w) 12 12 0]
 if {$idle > $cs(idle)} {set csu($w) [lreplace $csu($w) 13 13 [expr [lindex $csu($w) 13] + $idle]]}
}

proc cs:dur {du} {
 set o ""; set i [expr int($du/31536000)]; if {$i > 0} {lappend o "${i}y"}
 set i [expr int(fmod($du,31536000)/86400)]; if {$i > 0} {lappend o "${i}d"}
 set i [expr int(fmod($du,86400)/3600)]; if {$i > 0} {lappend o "${i}h"}
 set i [expr int(fmod($du,3600)/60)]; if {$i > 0} {lappend o "${i}m"}
 # set i [expr int(fmod($du,60))]; if {$i > 0} {lappend o "${i}s"}
 if {$o == ""} {return "N/A"} else {return [join $o ":"]}
}

proc cs:cv {c} {
 global cs
 foreach e $cs(global) {set cs([lindex [split $e =] 0]) [lindex [split $e "="] 1]}
 if {[info exists cs($c)]} {
  foreach e $cs($c) {set cs([lindex [split $e =] 0]) [lindex [split $e "="] 1]}
 }
}

proc cs:topic {n uh h c t} {
 global cs cst
 cs:cv $c
 if {$n == "\*"} {set n "Unknown"}
 set cst($c) "$n on [cs:date $c curr]"
}

proc cs:fltpc {n} {
 regsub -all {|||(([0-9])?([0-9])?(\,([0-9])?([0-9])?)?)?|([0-9A-F][0-9A-F])?} $n "" n
 return $n
}

proc cs:fl {n} {
 regsub -all \\\[ $n !2 n; regsub -all \\\] $n !3 n
 regsub -all \\\{ $n !5 n; regsub -all \\\} $n !4 n
 regsub -all \\\^ $n !6 n; regsub -all \\\" $n !7 n
 regsub -all \\\\ $n !1 n; return $n
}
proc cs:dfl {n} {
 regsub -all !1 $n \\ n; regsub -all !2 $n \[ n
 regsub -all !3 $n \] n; regsub -all !4 $n \} n
 regsub -all !5 $n \{ n; regsub -all !6 $n \^ n
 regsub -all !7 $n \" n; return $n
}

proc cs:fmt {i} {
 if {![string is integer $i]} {return $i}
 while {[regsub {([0-9])([0-9]{3})($|\.)} $i {\1.\2} i]} {}
 return $i
}

set cs(tclver) 0
if {[info exists tcl_version]} {set cs(tclver) [join [split $tcl_version .] {}]}
if {$cs(tclver) < 83} {putlog "CHATstats needs TCL version 8.3 or later, stopped loading."} else {cs:ini}
