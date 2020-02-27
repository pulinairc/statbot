#!/bin/sh
# \
exec tclsh "$0" "$@"
package require http 2.2
;###############################################################################
set tinyurl(version) "tinyurl.tcl v2.32 by jer@usa.com" ;# updated: 2007.02.14
;###############################################################################
;# * command-line:
;#   * $ ./tinyurl.tcl 'http://www.icaughtyouadeliciousbass.com/'
;# * console:
;#   * $ ./tinyurl.tcl
;#   * http://www.dontbejealousthativebeenchattingonlinewithbabesallday.com/
;# * eggdrop:
;#   * .chanset #channel +tinyurl +untinyurl +logallurl
;#   * /msg #channel http://www.icaughtyouadeliciousbass.com/
;#   * /msg bot http://www.icaughtyouadeliciousbass.com/
;###############################################################################
set tinyurl(antiflags) "bdkqr|dkqr" ;# user flags to ignore for eggdrop use
set tinyurl(msgmflags) "o|o" ;# user flags required for message eggdrop use
set tinyurl(pubmflags) "-|-" ;# user flags required for channel eggdrop use
set tinyurl(length) 60 ;# minimum url length to trigger channel eggdrop use
set tinyurl(delay) 30 ;# minimum seconds to wait before another eggdrop use
set tinyurl(last) 408 ;# internal variable, stores time of last eggdrop use
;###############################################################################
proc tinyurl {url} {
 if {[info exists url] && [string length $url]} {
  if {[regexp {http://tinyurl\.com/\w+} $url]} {
   set http [::http::geturl $url -timeout 9000]
   upvar #0 $http state ; array set meta $state(meta)
   ::http::cleanup $http ; return $meta(Location)
  } else {
   set http [::http::geturl "http://tinyurl.com/create.php" \
     -query [::http::formatQuery "url" $url] -timeout 9000]
   set data [split [::http::data $http] \n] ; ::http::cleanup $http
   for {set index [llength $data]} {$index >= 0} {incr index -1} {
    if {[regexp {href="http://tinyurl\.com/\w+"} [lindex $data $index] url]} {
     return [string map { {href=} "" \" "" } $url]
 }}}}
 return ""
}
;###############################################################################
;# tclsh command-line/console procedure
;###############################################################################
if {[info exists argc]} {
 if {$argc} {
  foreach arg [lrange $argv 0 end] {puts [tinyurl $arg]}
 } else {
  puts "$tinyurl(version)"
  puts "usage: $argv0 http://bullfrog.webhop.net/"
  puts "enter url(s), one per line, press ctrl+c to cancel:"
  while {[gets stdin line]} {puts [tinyurl [string trim $line]]}
 }
 exit
}
;###############################################################################
;# eggdrop channel message procedure
;###############################################################################
proc pubm:tinyurl {nick host user chan text} { global tinyurl
 if {([channel get $chan tinyurl] || [channel get $chan untinyurl]) && \
     [expr [unixtime] - $tinyurl(delay)] > $tinyurl(last) && \
     ![matchattr $user $tinyurl(antiflags)]} {
  foreach word [split $text] {
   if {([channel get $chan tinyurl] && \
        [string length $word] >= $tinyurl(length) && \
        [regexp {^(f|ht)tp(s|)://} $word] && \
        ![regexp {://([^/:]*:([^/]*@|\d+(/|$))|.*/\.)} $word]) || \
       ([channel get $chan untinyurl] && \
        [regexp {http://tinyurl.com/\w+} $word])} {
    set tinyurl(last) [unixtime]
    set newurl [tinyurl $word]
    if {[string length $newurl]} {
     puthelp "PRIVMSG $chan :\002Linkin vaihtoehtoinen osoite\002: $newurl"
    }
    putlog "<$nick:$chan> $word <-> $newurl"
    break
 }}}
 if {[channel get $chan logallurl]} {
  foreach word [split $text] {
   if {[string match "*://*" $word]} {
    putlog "<$nick:$chan> $word"
 }}}
 return 0
}
bind pubm $tinyurl(pubmflags) {*://*} pubm:tinyurl
;###############################################################################
;# eggdrop private message procedure
;###############################################################################
proc msgm:tinyurl {nick host user text} { global tinyurl
 if {![matchattr $user $tinyurl(antiflags)] && \
     [expr [unixtime] - $tinyurl(delay)] > $tinyurl(last) && \
     [string match "*://*" [lindex [split $text] 0]] && \
     [llength [split $text]] == 1} {
  set tinyurl(last) [unixtime]
  set newurl [tinyurl $text]
  if {[string length $newurl]} {
   puthelp "PRIVMSG $nick :\1ACTION $newurl\1"
   putlog "<$nick> $text <-> $newurl"
 }}
 return 0
}
bind msgm $tinyurl(msgmflags) {*://*} msgm:tinyurl
;###############################################################################
;# eggdrop chanset flags
;###############################################################################
setudef flag tinyurl
setudef flag untinyurl
setudef flag logallurl
;###############################################################################
putlog "Script loaded: \002$tinyurl(version)\002" ;# eggdrop log message
;###############################################################################
