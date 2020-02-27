#---------------------------------------------------------------#
# webby - web link information script                      v1.7 #
#                                                               #
# This script will display titles and other relevant information#
# from links given in irc channels. Can also be used to test    #
# and contstruct regular expression in channel.                 #
# Usage:                                                        #
#   .chanset #channel +webby                                    #
#   !webby website.here.com [--html] [--header] [--xheader]     #
#       [--post] [--override] [--nostrip] [--swap]              #
#       [--regexp regexp-here--] [--file] [--validate]          #
#                                                               #
# ChangeLog:                                                    #
#    v1.7 - Added --file option for saving files and such.      #
#    v1.6 - Corrected dynamic encoding conflict resolution.     #
#             able to identify and correct 100% of header       #
#             charset vs meta charset conflicts.                #
#    v1.5 - Added dynamic encoding conflict resolution.         #
#             work-in-progress .. may be incorrect..            #
#             ..seems to work in a few tests... crosses fingers #
#    v1.4 - Added detection for http-package exploits, and      #
#             cleaned up messaging.                             #
#    v1.3 - Added both automatic and forced character set       #
#             recognition.                                      #
#           Added Http-package character set misdetection, now  #
#             you can know when a flaw within http-package could#
#             render your results useless and realize it isn't  #
#             a fault of this script, but a flaw within the     #
#             package Http.                                     #
#           Added --swap parameter for hassle free encoding     #
#             conflict resolutions.                             #
#    v1.2 - Addded multiple url shortening sites via their      #
#             api query. can also be randomized or cycled.      #
#    v1.1 - Added post and regexp support for those learning    #
#             regexp for the very first time.                   #
#    v1.0 - first release, enjoy.. :)                           #
#                                                               #
# TODO:                                                         #
#   - Add support for regexp templates specific to each site.   #
#   - Support multiple proxies ( with ability to choose )       #
#   - Suggestions/Thanks/Bugs, e-mail at bottom of header.      #
#                                                               #
# LICENSE:                                                      #
#   This code comes with ABSOLUTELY NO WARRANTY.                #
#                                                               #
#   This program is free software; you can redistribute it      #
#   and/or modify it under the terms of the GNU General Public  #
#   License as published by the Free Software Foundation;       #
#   either version 2 of the License, or (at your option) any    #
#   later version.                                              #
#                                                               #
#   This program is distributed in the hope that it will be     #
#   useful, but WITHOUT ANY WARRANTY; without even the implied  #
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     #
#   PURPOSE.  See the GNU General Public License for more       #
#   details. (http://www.gnu.org/copyleft/library.txt)          #
#                                                               #
# Copyleft (C) 2009-2012, speechles                             #
# imspeechless@gmail.com                                        #
# June 27th, 2012                                               #
#                                                               #
# Credit: lee8oi for the help ... to PsWii60 for nothing.. :P   #
#---------------------------------------------------------------#
# ---> Start of config; setting begins

# do you want to display header attributes always?
# --- [ 0 no / 1 yes ]
variable webbyheader 0

# do you want to display x-header attributes always?
# --- [ 0 no / 1 yes ]
variable webbyXheader 0

# do you want to display html attributes always?
# --- [ 0 no / 1 yes ]
variable webbydoc 0

# if using the regexp (regular expression) engine do
# you want to still show title and description of webpage?
# --- [ 0 no / 1 yes ]
variable webbyRegShow 0

# max length of each line of your regexp capture?
# --- [ integer ]
variable webbySplit 403

# how many regexp captures is the maximum to issue?
# presently going above 9, will only result in 9...
# --- [ 1 - 9 ]
variable webbyMaxRegexp 9

# which method should be used when shortening the url?
# (0-3) will only use the one you've chosen.
# (4-5) will use them all.
# 0 --> http://tinyurl.com
# 1 --> http://u.nu
# 2 --> http://is.gd
# 3 --> http://cli.gs
# 4 --> randomly select one of the four above ( 2,0,0,3,1..etc )
# 5 --> cycle through the four above ( 0,1,2,3,0,1..etc )
# ---  [ 0 - 5 ]
variable webbyShortType 5

# regexp capture limit
# this is how wide each regexp capture can be, prior to it
# being cleaned up for html elements. this can take a very
# long time to cleanup if the entire html was taken. so this
# variable is there to protect your bot lagging forever and
# people giving replies with tons of html to lag it.
# --- [ integer ]
variable regexp_limit 3000

# Adjusts time in last-modified which gives you durations ago
# Set this in seconds. Most people should leave this set to 0.
# 
variable webbyTimeAdjust 0

# how should we treat encodings?
# 0 - do nothing, use eggdrops internal encoding whatever that may be.
# 1 - use the encoding the website is telling us to use.
#     This is the option everyone should use primarily.
# 2 - Force a static encoding for everything. If you use option 2,
#     please specify the encoding in the setting below this one.
# --- [ 0 off-internal / 1 automatic / 2 forced ]
variable webbyDynEnc 1

# option 2, force encoding
# if you've chosen this above then you must define what
# encoding we are going to force for all queries...
# --- [ encoding ]
variable webbyEnc "iso8859-1"

# fix Http-Package conflicts?
# this will disregard http-packages detected charset if it appears
# different from the character set detected within the meta's of
# the html and vice versa, you can change this behavior
# on-the-fly using the --swap parameter.
# --- [ 0 no / 1 use http-package / 2 use html meta's ]
variable webbyFixDetection 2

# report Http-package conflicts?
# this will display Http-package conflict errors to the
# channel, and will show corrections made to any encodings.
# --- [ 0 never / 1 when the conflict happens / 2 always ]
variable webbyShowMisdetection 0

# where should files be saved that people have downloaded?
# this should NOT be eggdrops root because things CAN and WILL
# be overwritten. This FOLDER MUST exist otherwise the --file
# command will always fail as well.
# --- [ directory ] ----
variable webbyFile "downloads/"

# when using the --file parameter should webby immediately return
# after saving or should it return results for the query as well?
# --- [ 0 return after saving / 1 do normal query stuff as well ]
variable webbyFileReact 0

# <--- end of config; script begins

package require http
# gzip-zlib/trf
if {([lsearch [info commands] zlib] == -1) && ([catch {package require zlib} error] !=0)} {
  if {([catch {package require Trf} error] == 0) || ([lsearch [info commands] zip] != -1)} {
    putlog "Webby: Found trf package. Fast lane activated!"
    set webbyTrf 1
  } else {
    putlog "Webby: Cannot find zlib or trf package! Gzipped url queries will not be used. Enjoy the slow lane! :P"
    set webbyNoGzip 1
  }
} else {
  putlog "Webby: Found zlib package. Fast lane activated!"
}
# tls-https
if {[catch {package require tls} error]} {
	putlog "Webby: https NOT supported: tls package NOT found."
} else {
	::http::register https 443 [list ::tls::socket -require 0 -request 1]
	putlog "Webby: https supported: tls package found."
}

setudef flag webby
bind pubm - {*://*} webby
bind pub - !webby webby
bind pub - !web webby
bind pub - !webbycrumble webbycrumble
bind pub - !webbycookie webbycookie

proc webbycrumble {nick uhost handle chan text} {
  if {![channel get $chan webby]} { return }
  global webbyCookie
  if {![info exists webbyCookie]} { putserv "privmsg $chan :\002Webby\002: Cookie does not exist." ; return }
  putserv "privmsg $chan :\002Webby\002: Crumbling \"$::webbyCookie\"..."
  set webbyCookie ""
}

proc webbycookie {nick uhost handle chan text} {
  if {![channel get $chan webby]} { return }
  global webbyCookie
  if {[info exists webbyCookie]} {
    if {[string length $webbyCookie]} {
      putserv "privmsg $chan :\002Webby\002: Cookie \"$::webbyCookie\"..."
    } else {
      putserv "privmsg $chan :\002Webby\002: Cookie is empty."
    }
  } else {
    putserv "privmsg $chan :\002Webby\002: Cookie does not exist."
  }
}

proc webby {nick uhost handle chan site} {
   if {![channel get $chan webby]} { return }
   global webbyCookie ; set binary 1
   if {![info exists ::webbyCookie]} {
     set ::webbyCookie "" ; set cookies ""
   } else {
     set cookies $::webbyCookie
   }
   if {[regsub -nocase -all -- {--header} $site "" site]} { set w1 0 }
   if {[regsub -nocase -all -- {--validate} $site "" site]} { set w1 0 ; set w2 0 ; set w3 0 ; set w10 0 }
   if {[regsub -nocase -all -- {--xheader} $site "" site]} { set w2 0 }
   if {[regsub -nocase -all -- {--html} $site "" site]} { set w3 0 }
   if {[regsub -nocase -all -- {--post} $site "" site]} { set w4 0 }
   if {[regsub -nocase -all -- {--override} $site "" site]} { set w6 0 }
   if {[regsub -nocase -all -- {--nostrip} $site "" site]} { set w7 0 }
   if {[regsub -nocase -all -- {--swap} $site "" site]} { set w8 0 }
   if {[regsub -nocase -all -- {--gz} $site "" site]} { set w9 0 }
   if {[regsub -nocase -all -- {--file} $site "" site]} { set w11 0 }
   if {[regsub -nocase -all -- {--nobinary} $site "" site]} { set w12 0 ; set binary 0 }
   if {[regexp -nocase -- {--regexp (.*?)--} $site - reggy]} {
     if {[catch {set varnum [lindex [regexp -about -- $reggy] 0]} error]} {
       putserv "privmsg $chan :\002regexp\002 [set error]"
       return 0
     } elseif {$varnum > $::webbyMaxRegexp} {
       putserv "privmsg $chan :\002regexp\002 too many captures ($varnum), reducing to ($::webbyMaxRegexp)"
       set varnum $::webbyMaxRegexp
     }
     set w5 0
     regsub -nocase -- {--regexp .*?--} $site {} site
   }
   if {![regexp -nocase -- {--ua (.*?)--} $site - ua]} {
     set ua "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5"
   } else {
     regsub -nocase -- {--ua .*?--} $site {} site
   }
   if {[string match "*://*" $site]} { set site [join [lrange [set proto [split $site "/"]] 2 end] "/"] ; set proto [lindex $proto 0] } { set proto "http:" }
   if {[string equal "-" [string index [set site [string map {"  " " "} [string trim $site]]] 0]]} {
     putserv "privmsg $chan :\002webby\002: you've used an improper flag which may exploit http-package!"
     return
   }
   foreach e [split $site "."] { lappend newsite [idna::domain_toascii $e] }
   set fullquery "$proto//[join $newsite "."]"
   set http [::http::config -useragent $ua]
   if {[info exists w4]} {
     putserv "privmsg $chan :Deconstructing post query..."
     if {![regexp -- {\|} $fullquery] && ![regexp -- {\?} $fullquery]} {
       putserv "privmsg $chan :\002webby\002: $fullquery does not appear to be a post query, using simple query..."
       unset w4
     } else {
       if {[regexp -- {\|} $fullquery]} {
         set url [lindex [split $fullquery "|"] 0]
         set query [lindex [split $fullquery "|"] 1]
         if {[regexp -- {\?} $query]} {
           set suburl "/[lindex [split $query "?"] 0]?"
           set query [lindex [split $query "?"] 1]
         } else { set suburl "" }
         putserv "privmsg $chan :\002webby\002: detected \002url\002 $url \002query\002 $query"
       } else {
         set suburl ""
         set url [lindex [split $fullquery "?"] 0]
         set query [lindex [split $fullquery "?"] 1]
         putserv "privmsg $chan :\002webby\002: detected \002url\002 $url \002query\002 $query"
       }
       set post [list]
       foreach {entry} [split $query "&"] {
         if {![regexp {\=} $entry]} {
           putserv "privmsg $chan :\002webby\002: broken post structure ($entry). Is not post query, using simple query..."
           unset w4
           break
         } else {
           set name [lindex [split $entry "="] 0]
           set value [lindex [split $entry "="] 1]
           set post [concat $post "$name=$value"]
         }
       }
     }
     if {[info exists w4]} { putserv "privmsg $chan :Posting..." }
   }
   set value ""
   if {[info exists w9]} {
    set gzp "Accept-Encoding gzip,deflate"
   } else {
    set gzp ""
   }
   if {[info exists w4]} {
     if {[info exists w10]} {
        catch {set http [::http::geturl "$url$suburl" -query "[join $post "&"]" -headers $gzp -validate 1 -binary $binary -timeout 10000]} error
     } else {
        if {[string length $cookies]} {
	    catch {set http [::http::geturl "$url$suburl" -query "[join $post "&"]" -headers "$gzp Cookie $cookies" -binary $binary -timeout 10000]} error
        } else {
	    catch {set http [::http::geturl "$url$suburl" -query "[join $post "&"]" -headers $gzp -binary $binary -timeout 10000]} error
        }
      }
   } else {
     if {[info exists w10]} {
       catch {set http [::http::geturl "$fullquery" -headers $gzp -validate 1 -binary $binary -timeout 10000]} error
     } else {
        if {[string length $cookies]} {
	    catch {set http [::http::geturl "$fullquery" -headers "$gzp Cookie $cookies" -binary $binary -timeout 10000]} error
        } else {
          catch {set http [::http::geturl "$fullquery" -headers $gzp -binary $binary -timeout 10000]} error
        }
     }
     set url $fullquery ; set query ""
   }
   if {![string match -nocase "::http::*" $error]} {
     putserv "privmsg $chan :\002webby\002: [string totitle [string map {"\n" " | "} $error]] \( $fullquery \)"
     return 0
   }
   if {![string equal -nocase [::http::status $http] "ok"]} {
     putserv "privmsg $chan :\002webby\002: [string totitle [::http::status $http]] \( $fullquery \)"
     return 0
   }
   upvar #0 $http state
   if {![info exists state(meta)]} { putserv "privmsg $chan :\002webby\002: unsupported URL error \( $fullquery \)" ; return 0 }
   set redir [::http::ncode $http]
   # iterate through the meta array
   foreach {name value} $state(meta) {
     # do we have cookies?                                                                                                                                                                             
     if {[string equal -nocase $name "Set-Cookie"]} {
       # yes, add them to cookie list                                                                                                                                                                          
       lappend webbyCookies [lindex [split $value {;}] 0]                                                                                                                                                             
     }                                                                                                                                                                                                             
   }
   if {[info exists webbyCookies] && [llength $webbyCookies]} {
     set cookies "[join $webbyCookies {;}]"
   } else {
     set cookies ""
   }
   set html [::http::data $http]
   if {[string match *t.co* $fullquery] && [regexp {<META http-equiv="refresh" content="[0-9]\;URL\=(.*?)">} $html - value]} {
     if {[info exists w10]} {
       if {[string length $cookies]} {
         catch {set http [::http::geturl "[string map {" " "%20"} $value]" -headers "[string trim "Referer $url $gzp"] Cookie $cookies" -binary $binary -validate 1 -timeout [expr 1000 * 10]]} error
       } else {
         catch {set http [::http::geturl "[string map {" " "%20"} $value]" -headers "[string trim "Referer $url $gzp"]" -binary $binary -validate 1 -timeout [expr 1000 * 10]]} error
       }
     } else {
       if {[string length $cookies]} {
         catch {set http [::http::geturl "[string map {" " "%20"} $value]" -headers "[string trim "Referer $url $gzp"] Cookie $cookies" -binary $binary -timeout [expr 1000 * 10]]} error
       } else {
         catch {set http [::http::geturl "[string map {" " "%20"} $value]" -headers "[string trim "Referer $url $gzp"]" -binary $binary -timeout [expr 1000 * 10]]} error
       }
     }
     if {![string match -nocase "::http::*" $error]} {
       putserv "privmsg $chan :\002webby\002: [string totitle $error] \( $value \)"
       return 0
     }
     if {![string equal -nocase [::http::status $http] "ok"]} {
       putserv "privmsg $chan :\002webby\002: [string totitle [::http::status $http]] \( $value \)"
       return 0
     }
     upvar #0 $http state
     if {![info exists state(meta)]} { putserv "privmsg $chan :\002webby\002: unsupported URL error \( $fullquery \)" ; return 0 }
     set html [::http::data $http]
     set url [string map {" " "%20"} $value]
     set redir [::http::ncode $http]
     # iterate through the meta array
     foreach {name value} $state(meta) {
       # do we have cookies?                                                                                                                                                                             
       if {[string equal -nocase $name "Set-Cookie"]} {
         # yes, add them to cookie list                                                                                                                                                                          
         lappend webbyCookies [lindex [split $value {;}] 0]                                                                                                                                                             
       }                                                                                                                                                                                                             
     }
     if {[info exists webbyCookies] && [llength $webbyCookies]} {
       set cookies "[join $webbyCookies {;}]"
     } else {
       set cookies ""
     }
   }
   # REDIRECT ?
   set r 0
   while {[string match "*${redir}*" "307|303|302|301" ]} {
     foreach {name value} $state(meta) {
       if {[regexp -nocase ^location$ $name]} {
         if {![string match "http*" $value]} {
           if {![string match "*://*" $value]} {
             if {![string match "/" [string index $value 0]]} {
               set value "[join [lrange [split $url "/"] 0 2] "/"]/$value"
             } else {
               set value "[join [lrange [split $url "/"] 0 2] "/"]$value"
             }
           }
         }
         if {[string match [string map {" " "%20"} $value] $url]} {
           if {![info exists poison]} {
             set poison 1 
           } else {
             incr poison
             if {$poison > 2} {
               putserv "privmsg $chan :\002webby\002: redirect error (self to self)\($url\) - ($cookies) are no help..."
               return
             }
           }
         }
		putlog "$url = $value"
         if {[info exists w10]} {
           if {[string length $cookies]} {
             catch {set http [::http::geturl "[string map {" " "%20"} $value]" -headers "[string trim "Referer $url $gzp"] Cookie $cookies" -binary $binary -validate 1 -timeout [expr 1000 * 10]]} error
           } else {
             catch {set http [::http::geturl "[string map {" " "%20"} $value]" -headers "[string trim "Referer $url $gzp"]" -binary $binary -validate 1 -timeout [expr 1000 * 10]]} error
           }
         } else {
           if {[string length $cookies]} {
             catch {set http [::http::geturl "[string map {" " "%20"} $value]" -headers "[string trim "Referer $url $gzp"] Cookie $cookies" -binary $binary -timeout [expr 1000 * 10]]} error
           } else {
             catch {set http [::http::geturl "[string map {" " "%20"} $value]" -headers "[string trim "Referer $url $gzp"]" -binary $binary -timeout [expr 1000 * 10]]} error
           }
         }
         if {![string match -nocase "::http::*" $error]} {
           putserv "privmsg $chan :\002webby\002: [string totitle $error] \( $value \)"
           return 0
         }
         if {![string equal -nocase [::http::status $http] "ok"]} {
           putserv "privmsg $chan :\002webby\002: [string totitle [::http::status $http]] \( $value \)"
           return 0
         }
         set redir [::http::ncode $http]
         set html [::http::data $http]
         set url [string map {" " "%20"} $value]
         upvar #0 $http state
         if {[incr r] > 10} { putserv "privmsg $chan :\002webby\002: redirect error (>10 too deep) \( $url \)" ; return }
         # iterate through the meta array
         #if {![string length cookies]} {
           foreach {name value} $state(meta) {
             # do we have cookies?                                                                                                                                                                             
             if {[string equal -nocase $name "Set-Cookie"]} {
               # yes, add them to cookie list                                                                                                                                                                        
               lappend webbyCookies [lindex [split $value {;}] 0]         
             }
           }                                                                                                                                                    
           if {[info exists webbyCookies] && [llength $webbyCookies]} {
             set cookies "[join $webbyCookies {;}]"
           } else {
             set cookies ""
           }
         #}
       }
     } 
   }

   set fi $html
   set bl [string bytelength $html]
   set nc [::http::ncode $http] ; set flaw "" 
   if {![info exists webbyNoGzip]} {
     foreach {name value} $state(meta) {
       if {[regexp -nocase ^Content-Encoding$ $name]} {
         if {[string equal -nocase "gzip" $value] && [string length $html]} {
	     if {![info exists webbyTrf]} {
             catch { set bl "$bl bytes (gzip); [string bytelength [set html [zlib inflate [string range $html 10 [expr { [string length $html] - 8 } ]]]]]" }
           } else {
             catch { set bl "$bl bytes (gzip); [string bytelength [set html [zip -mode decompress -nowrap 1 [string range $html 10 [expr { [string length $html] - 8 } ]]]]]" }
           }  
	   }
       } elseif {[regexp -nocase ^Content-Type$ $name]} {
	     if {[string match */* $value]} {
		 set ext [string trim [lindex [split [lindex [split $value /] 1] {;}] 0]]
	     } else {
	       set ext [string trim [lindex [split $value {;}] 0]]
           }
	     if {[string match -nocase x-* $ext]} { set ext [string trim [string range $ext 2 end] {;}] }
       }
     }
   }
   if {[regexp -nocase {"Content-Type" content=".*?; charset=(.*?)".*?>} $html - char]} {
     set char [string map {"\\n" ""} [string trim [string trim $char "\"' /"] {;}]]
     regexp {^(.*?)"} $char - char
     set mset $char
     if {![string length $char]} { set char "None Given" ; set char2 "None Given" }
     set char2 [string tolower [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $char]]
   } else {
     if {[regexp -nocase {<meta content=".*?; charset=(.*?)".*?>} $html - char]} {
       set char [string map {"\\n" ""} [string trim $char "\"' /"]]
       regexp {^(.*?)"} $char - char
       set mset $char
       if {![string length $char]} { set char "None Given" ; set char2 "None Given" }
       set char2 [string tolower [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $char]]
     } elseif {[regexp -nocase {encoding="(.*?)"} $html - char]} {
       set mset [string map {"\\n" ""} $char] ; set char [string trim $char]
       if {![string length $char]} { set char "None Given" ; set char2 "None Given" }
       set char2 [string tolower [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $char]]
     } else {
       set char "None Given" ; set char2 "None Given" ; set mset "None Given"
     }
   }
   set char3 [string map {"\\n" ""} [string tolower [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} [string trim $state(charset) {;}]]]]
   if {[string equal $char $state(charset)] && [string equal $char $char2] && ![string equal -nocase "none given" $char]} {
     set char [string map {"\\n" ""} [string trim $state(charset) {;}]]
     set flaw ""
   } else {
     if {![string equal -nocase $char2 $char3] && ![string equal -nocase "none given" $char2] && $::webbyFixDetection > 0} {
       if {$::webbyFixDetection > 0} {
         switch $::webbyFixDetection {
           1 { if {![info exists w8]} {
                 if {$::webbyShowMisdetection > 0 } { set flaw "\002webby\002: conflict! html meta tagging reports: $char2 .. using charset detected from http-package: $char3 to avoid conflict."} { set flaw "" }
		     set html [webbyConflict $html $char3 $char2 2 [info exists w9]]
                 set char [string trim $char3 {;}]
               } else {
                 if {$::webbyShowMisdetection > 0 } { set flaw "\002webby\002: conflict! http-package reports: $char3 .. using charset detected from html meta tagging: $char2 to avoid conflict." } { set flaw "" }
		     set html [webbyConflict $html $char3 $char2 1 [info exists w9]]
                 set char [string trim $char2 {;}]
               }
             }
           2 { if {![info exists w8]} {
                 if {$::webbyShowMisdetection > 0 } { set flaw "\002webby\002: conflict! http-package reports: $char3 .. using charset detected from html meta tagging: $char2 to avoid conflict." } { set flaw "" }
		     set html [webbyConflict $html $char3 $char2 1 [info exists w9]]
                 set char [string trim $char2 {;}]
               } else {
                 if {$::webbyShowMisdetection > 0 } { set flaw "\002webby\002: conflict! html meta tagging reports: $char2 .. using charset detected from http-package: $char3 to avoid conflict." } { set flaw "" }
		     set html [webbyConflict $html $char3 $char2 2 [info exists w9]]
                 set char [string trim $char3 {;}]
               }
             }
          }
       } else {
         set flaw ""
         set char [string trim $char3 {;}]
       }
     } else {
       set char [string trim $char3 {;}]
       if {[catch {package present http 2.7}]} {
         # assume http package 2.5.3
         if {[string equal -nocase "utf-8" [encoding system]]} {
           if {![string equal -nocase "utf-8" $char]} { 
             set html [encoding convertfrom $char $html]
           } else {
             #set html [encoding convertto $char $html]
           }
         } elseif {![string equal -nocase "utf-8" [encoding system]]} {
           if {[string equal "utf-8" $char]} {
             if {![info exists w9]} {
                set html [encoding convertto $char $html]
             }
           } else {
	       set html [encoding convertto "utf-8" [encoding convertfrom $char $html]]
           }
         }
         set flaw ""
       } else {
         # we have http package 2.7
         if {![string equal -nocase "utf-8" [encoding system]]} {
           set html [encoding convertto $char3 $html]
         }
       }
     }
   }
   # DEBUG DEBUG                    
   set junk [open "webby.txt" w]
   puts $junk $html
   close $junk
   set s [list] ; set sx [list] ; set type "\( $nc" ; set metas [list]
   if {[string equal -nocase "none given" $char]} { set char [string trim $state(charset) {;}] }
   set cset $state(charset)
   switch $::webbyDynEnc {
    
    2 { set html [incithencode $html [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $::webbyEnc]] }
   }
   set red ""; if {$r > 0} { set red "; $r redirects" } ; set end ""
   foreach {name value} $state(meta) {
     if {[string match -nocase "content-type" $name]} {
       append type "; [lindex [split $value ";"] 0]; $char; ${bl} bytes$red"
     }
     if {[string match -nocase "last-modified" $name]} { set end " \)\( [webbyTime $value]" }
     if {[string match -nocase "set-cookie" $name]} { continue }
     if {[string match -nocase "x-*" $name]} { lappend sx "\002$name\002=$value" ; continue }
     lappend s "\002$name\002=[string trim $value {;}]"
   }
   append type "$end \)" ; set e ""
   ::http::cleanup $http
   if {![regexp -nocase {<title.*?>(.*?)</title>} $html - title]} {
     if {[info exists w10]} {
       set title "\002Validated\002: [join [lrange [split $fullquery /] 0 2] /]"
     } else {
       set title "No Title"
     }
   } else {
	regsub -all {(?:\n|\t|\v|\r|\x01)} $title " " title
     while {[string match "*  *" $title]} { regsub -all -- {  } [string trim $title] " " title }
   }
   while {[regexp -nocase {<meta ((?!content).*?) content=(.*?)>} $html - name value]} {
     set name [string trim [lindex [split $name "="] end] "\"' /"]
     set value [string trim $value "\"' /"]
     lappend metas "$name=$value"
     regsub -nocase {<meta (?!content).*? content=.*?>} $html "" html
   }
   while {[regexp -nocase {<meta .*?=(.*?) name=(.*?)>} $html - value name]} {
     set name [string trim [lindex [split $name "="] end] "\"' /"]
     set value [string trim $value "\"' /"]
     lappend metas "$name=$value"
     regsub -nocase {<meta .*?=.*? name=.*?>} $html "" html
   }
   if {[info exists w3]} {
     if {![regexp -nocase {<\!DOCTYPE html PUBLIC \"-//W3C//DTD (.*?)"} $html - hv]} {
       if {![regexp -nocase {<!DOCTYPE html PUBLIC \'-//W3C//DTD (.*?)'} $html - hv]} {
         if {[llength $metas]} {
           foreach line [line_wrap [join $metas "; "]] {
             append hv " \002Metas\002: $line\n"
           }
         } else { set hv "" }
       }
     } else {
       set hv "\002[lindex [split $hv] 0]\002 [join [lrange [split $hv] 1 end] " "] "
       if {[llength $metas]} { 
         foreach line [line_wrap [join $metas "; "]] {
           append hv " \002Metas\002: $line\n"
         }
       }
     }
   }
   if {[llength $metas]} {
     if {[set pos [lsearch -glob [split [string tolower [join $metas "<"]] "<"] "description=*"]] != -1} {
       set desc [lindex [split [lindex $metas $pos] =] 1]
     } else {
	 if {[set pos [lsearch -glob [split [string tolower [join $metas "<"]] "<"] "*=description"]] != -1} {
       	set desc [lindex [split [lindex $metas $pos] =] 0]
	 } else { set desc "" }
     }
   } else { set desc "" }
   set webbyCookie $cookies
   # save the file if --file is used
   if {[info exists w11]} {
	set uri [file tail $url]
      if {![string match *.* $uri] || [string match -nocase www.* $uri]} {
	  set uri [webbyRangeString 13].$ext
	} else {
	  set uri "[lindex [split [lindex [split $uri ?] 0] .] 0].$ext"
	}
	set n "${::webbyFile}[lindex [split $url "/"] 2]--$uri"
	if {[file exists $n]} {
		set c 0
		while {[file exists "[join [lrange [split $n .] 0 end-1] .]-[incr c].[lindex [split $n .] end]"]} {}
		set n "[join [lrange [split $n .] 0 end-1] .]-$c.[lindex [split $n .] end]"
	}
      if {[catch {set f [open $n w]} error]} { putserv "privmsg $chan :\002Webby\002: $error" ; return }
      putserv "privmsg $chan :saving to $n"
      puts $f $fi
      close $f
      if {$::webbyFileReact < 1} { return }
   }
	
   # SPAM
   if {$::webbyShowMisdetection > 0} {
     if {[string length $flaw]} { putserv "privmsg $chan :$flaw" }
     if {$::webbyShowMisdetection > 1} {
       putserv "privmsg $chan :\002webby\002: Detected \002$char\002 \:\: Http-Package: $cset -> $char3 .. Meta-Charset: $mset -> $char2 \:\:"
     }
   }
   if {($::webbyRegShow > 0) || ![info exists w5]} {
     if {![string equal -nocase "$proto//$site" $url]} { set full "$url" } { set full "[webbytiny $fullquery $::webbyShortType]" }
     putserv "privmsg $chan : [webbydescdecode $title $char] \( ${full} \)$type"
     if {($::webbyheader > 0 && [llength $s]) || [info exists w1]} {
       foreach line [line_wrap [join [lsort -decreasing $s] "; "]] {
         putserv "privmsg $chan :$line"
       }
     }
     if {($::webbyXheader > 0 && [llength $sx]) || [info exists w2]} {
       foreach line [line_wrap [join [lsort -decreasing $sx] "; "]] {
         putserv "privmsg $chan :$line"
       }
     }
     if {($::webbydoc > 0 && [string length $hv]) || [info exists w3]} {
       foreach line [split [string trim $hv] \n] { putserv "privmsg $chan :$line" }
     }
     if {![info exists w3]} {
	regsub -all {(?:\n|\t|\v|\r|\x01)} $desc " " desc
       foreach line [line_wrap [webbydescdecode [webbydescdecode $desc $char] $char]] {
         putserv "privmsg $chan :$line"
       }
     }
   } else {
     if {[info exists w5]} {
       switch $varnum {
         1 { catch {regexp -nocase -- "$reggy" $html - m(1)} e }
         2 { catch {regexp -nocase -- "$reggy" $html - m(1) m(2)} e }
         3 { catch {regexp -nocase -- "$reggy" $html - m(1) m(2) m(3)} e }
         4 { catch {regexp -nocase -- "$reggy" $html - m(1) m(2) m(3) m(4)} e }
         5 { catch {regexp -nocase -- "$reggy" $html - m(1) m(2) m(3) m(4) m(5)} e }
         6 { catch {regexp -nocase -- "$reggy" $html - m(1) m(2) m(3) m(4) m(5) m(6)} e }
         7 { catch {regexp -nocase -- "$reggy" $html - m(1) m(2) m(3) m(4) m(5) m(6) m(7)} e }
         8 { catch {regexp -nocase -- "$reggy" $html - m(1) m(2) m(3) m(4) m(5) m(6) m(7) m(8)} e }
         9 { catch {regexp -nocase -- "$reggy" $html - m(1) m(2) m(3) m(4) m(5) m(6) m(7) m(8) m(9)} e }
       }
       if {![string is digit $e]} {
         putserv "privmsg $chan :\002regexp\002: [set e]"
         return 0
       } else {
         set found 0
         for {set n 1} {$n<10} {incr n} {
           if {[info exists m($n)]} {
             incr found
             if {([string length $m($n)] < $::regexp_limit) || [info exists w6]} {
               if {![info exists w7]} {
				regsub -all {(?:\n|\t|\v|\r|\x01)} $html " " html
				set m($n) [unhtml $m($n)]
		   }
               foreach line [line_wrap [webbydescdecode $m($n) $char]] {
		     regsub -all {(?:\n|\t|\v|\r|\x01)} $line " " line
                 putserv "privmsg $chan :\002regexp\002: capture$n ( $line \017)"
               }
             } else {
               putserv "privmsg $chan :\002regexp\002: capture$n is too long for display to irc ([string length $m($n)] > $::regexp_limit)."
             }
           }
         }
         if {$found == 0} {
            putserv "privmsg $chan :\002regexp\002: does not match any html."
         }
       }
     }
   }
}

proc webbyRangeString {length {chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"}} {
    set range [expr {[string length $chars]-1}]
    set txt ""
    for {set i 0} {$i < $length} {incr i} {
       set pos [expr {int(rand()*$range)}]
       append txt [string range $chars $pos $pos]
    }
    return $txt
 }

proc webbyConflict {html in out type gz} {
  if {[lsearch -exact [encoding names] [string tolower $out]] == -1} { set out "utf-8" }
  switch -- $type {
    "1" {  set html [encoding convertfrom [string map {"\\n" ""} $out] $html]
	     if {![string equal -nocase "utf-8" [encoding system]]} { set html [encoding convertto utf-8 $html] }
         }
    "2" {  set html [encoding convertfrom $out $html]
	     if {![string equal -nocase "utf-8" [encoding system]]} { set html [encoding convertto utf-8 $html] }
         }
    }
  return $html
}
proc incithencode {text enc} {
  if {[lsearch -exact [encoding names] $enc] != -1} {
    set text [encoding convertto $enc $text]
  }
  return $text
}

proc incithdecode {text enc {en2 "utf-8"}} {
  if {[lsearch -exact [encoding names] $enc] != -1} {
    set text [encoding convertto $en2 [encoding convertfrom $enc $text]]
  }
  return $text
}

proc unhtml {text} {
  regsub -all "(?:<b>|</b>|<b />|<em>|</em>|<strong>|</strong>)" $text "\002" text
  regsub -all "(?:<u>|</u>|<u />)" $text "\037" text
  regsub -all "(?:<br>|<br/>|<br />)" $text ". " text
  regsub -all "<script.*?>.*?</script>" $text "" text
  regsub -all "<style.*?>.*?</style>" $text "" text
  regsub -all -- {<.*?>} $text " " text
  while {[string match "*  *" $text]} { regsub -all "  " $text " " text }
  return [string trim $text]
}

proc webbydescdecode {text char} {
   # code below is neccessary to prevent numerous html markups
   # from appearing in the output (ie, &quot;, &#5671;, etc)
   # stolen (borrowed is a better term) from perplexa's urban
   # dictionary script..
   if {![string match *&* $text]} {return $text}
   if {[string match "*;*" $char]} {set char [string trim $char {;}] }
   set escapes {
		&nbsp; \xa0 &iexcl; \xa1 &cent; \xa2 &pound; \xa3 &curren; \xa4
		&yen; \xa5 &brvbar; \xa6 &sect; \xa7 &uml; \xa8 &copy; \xa9
		&ordf; \xaa &laquo; \xab &not; \xac &shy; \xad &reg; \xae
		&macr; \xaf &deg; \xb0 &plusmn; \xb1 &sup2; \xb2 &sup3; \xb3
		&acute; \xb4 &micro; \xb5 &para; \xb6 &middot; \xb7 &cedil; \xb8
		&sup1; \xb9 &ordm; \xba &raquo; \xbb &frac14; \xbc &frac12; \xbd
		&frac34; \xbe &iquest; \xbf &Agrave; \xc0 &Aacute; \xc1 &Acirc; \xc2
		&Atilde; \xc3 &Auml; \xc4 &Aring; \xc5 &AElig; \xc6 &Ccedil; \xc7
		&Egrave; \xc8 &Eacute; \xc9 &Ecirc; \xca &Euml; \xcb &Igrave; \xcc
		&Iacute; \xcd &Icirc; \xce &Iuml; \xcf &ETH; \xd0 &Ntilde; \xd1
		&Ograve; \xd2 &Oacute; \xd3 &Ocirc; \xd4 &Otilde; \xd5 &Ouml; \xd6
		&times; \xd7 &Oslash; \xd8 &Ugrave; \xd9 &Uacute; \xda &Ucirc; \xdb
		&Uuml; \xdc &Yacute; \xdd &THORN; \xde &szlig; \xdf &agrave; \xe0
		&aacute; \xe1 &acirc; \xe2 &atilde; \xe3 &auml; \xe4 &aring; \xe5
		&aelig; \xe6 &ccedil; \xe7 &egrave; \xe8 &eacute; \xe9 &ecirc; \xea
		&euml; \xeb &igrave; \xec &iacute; \xed &icirc; \xee &iuml; \xef
		&eth; \xf0 &ntilde; \xf1 &ograve; \xf2 &oacute; \xf3 &ocirc; \xf4
		&otilde; \xf5 &ouml; \xf6 &divide; \xf7 &oslash; \xf8 &ugrave; \xf9
		&uacute; \xfa &ucirc; \xfb &uuml; \xfc &yacute; \xfd &thorn; \xfe
		&yuml; \xff &fnof; \u192 &Alpha; \u391 &Beta; \u392 &Gamma; \u393 &Delta; \u394
		&Epsilon; \u395 &Zeta; \u396 &Eta; \u397 &Theta; \u398 &Iota; \u399
		&Kappa; \u39A &Lambda; \u39B &Mu; \u39C &Nu; \u39D &Xi; \u39E
		&Omicron; \u39F &Pi; \u3A0 &Rho; \u3A1 &Sigma; \u3A3 &Tau; \u3A4
		&Upsilon; \u3A5 &Phi; \u3A6 &Chi; \u3A7 &Psi; \u3A8 &Omega; \u3A9
		&alpha; \u3B1 &beta; \u3B2 &gamma; \u3B3 &delta; \u3B4 &epsilon; \u3B5
		&zeta; \u3B6 &eta; \u3B7 &theta; \u3B8 &iota; \u3B9 &kappa; \u3BA
		&lambda; \u3BB &mu; \u3BC &nu; \u3BD &xi; \u3BE &omicron; \u3BF
		&pi; \u3C0 &rho; \u3C1 &sigmaf; \u3C2 &sigma; \u3C3 &tau; \u3C4
		&upsilon; \u3C5 &phi; \u3C6 &chi; \u3C7 &psi; \u3C8 &omega; \u3C9
		&thetasym; \u3D1 &upsih; \u3D2 &piv; \u3D6 &bull; \u2022
		&hellip; \u2026 &prime; \u2032 &Prime; \u2033 &oline; \u203E
		&frasl; \u2044 &weierp; \u2118 &image; \u2111 &real; \u211C
		&trade; \u2122 &alefsym; \u2135 &larr; \u2190 &uarr; \u2191
		&rarr; \u2192 &darr; \u2193 &harr; \u2194 &crarr; \u21B5
		&lArr; \u21D0 &uArr; \u21D1 &rArr; \u21D2 &dArr; \u21D3 &hArr; \u21D4
		&forall; \u2200 &part; \u2202 &exist; \u2203 &empty; \u2205
		&nabla; \u2207 &isin; \u2208 &notin; \u2209 &ni; \u220B &prod; \u220F
		&sum; \u2211 &minus; \u2212 &lowast; \u2217 &radic; \u221A
		&prop; \u221D &infin; \u221E &ang; \u2220 &and; \u2227 &or; \u2228
		&cap; \u2229 &cup; \u222A &int; \u222B &there4; \u2234 &sim; \u223C
		&cong; \u2245 &asymp; \u2248 &ne; \u2260 &equiv; \u2261 &le; \u2264
		&ge; \u2265 &sub; \u2282 &sup; \u2283 &nsub; \u2284 &sube; \u2286
		&supe; \u2287 &oplus; \u2295 &otimes; \u2297 &perp; \u22A5
		&sdot; \u22C5 &lceil; \u2308 &rceil; \u2309 &lfloor; \u230A
		&rfloor; \u230B &lang; \u2329 &rang; \u232A &loz; \u25CA
		&spades; \u2660 &clubs; \u2663 &hearts; \u2665 &diams; \u2666
		&quot; \x22 &amp; \x26 &lt; \x3C &gt; \x3E O&Elig; \u152 &oelig; \u153
		&Scaron; \u160 &scaron; \u161 &Yuml; \u178 &circ; \u2C6
		&tilde; \u2DC &ensp; \u2002 &emsp; \u2003 &thinsp; \u2009
		&zwnj; \u200C &zwj; \u200D &lrm; \u200E &rlm; \u200F &ndash; \u2013
		&mdash; \u2014 &lsquo; \u2018 &rsquo; \u2019 &sbquo; \u201A
		&ldquo; \u201C &rdquo; \u201D &bdquo; \u201E &dagger; \u2020
		&Dagger; \u2021 &permil; \u2030 &lsaquo; \u2039 &rsaquo; \u203A
		&euro; \u20AC &apos; \u0027 &lrm; "" &rlm; "" &#8236; "" &#8237; ""
		&#8238; ""
   };
  set text [string map [list "\]" "\\\]" "\[" "\\\[" "\$" "\\\$" "\\" "\\\\"] [string map $escapes $text]]
  regsub -all -- {&#([[:digit:]]{1,5});} $text {[encoding convertto $char [format %c [string trimleft "\1" "0"]]]} text
  regsub -all -- {&#x([[:xdigit:]]{1,4});} $text {[encoding converto $char [format %c [scan "\1" %x]]]} text
  return [subst "$text"]
}

proc webbytiny {url type} {
   set ua "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5"
   set http [::http::config -useragent $ua -urlencoding "utf-8"]
   switch -- $type {
     4 { set type [rand 4] }
     5 { if {![info exists ::webbyCount]} {
           set ::webbyCount 0
           set type 0
         } else {
           set type [expr {[incr ::webbyCount] % 4}]
         }
       }
   } 
   switch -- $type {
     0 { set query "http://tinyurl.com/api-create.php?[http::formatQuery url $url]" }
     1 { set query "http://is.gd/api.php?[http::formatQuery longurl $url]" }
     2 { set query "http://is.gd/api.php?[http::formatQuery longurl $url]" }
     3 { set query "http://is.gd/api.php?[http::formatQuery longurl $url]" }
   }
   set token [http::geturl $query -binary 1 -timeout 3000]
   upvar #0 $token state
   if {[string length $state(body)]} { return [string map {"\\n" ""} $state(body)] }
   return $url
}

proc webbyTime {stamp} {
	if {[catch { set ago [duration [expr {[clock seconds] - [clock scan "$stamp"] - $::webbyTimeAdjust}]] }]} {
		set ago [duration [expr {[clock seconds] - [clock scan "[join [lrange [split $stamp] 0 end-1]]"] - $::webbyTimeAdjust}]]
	}
	set ago [string map {" years " "y, " " year " "y, " " weeks" "w, " " week" "w, " " days" "d, " " day" "d, " " hours" "h, " " hour" "h, " " minutes" "m, " " minute" "m, " " seconds" "s, " " second" "s,"} $ago]
	return "[string trim $ago ", "] ago"
}

proc cockrabbit {args} {
 putlog [webbydescdecode "Fox to Bring Back &#8217;24&#8242; for Season 9; 13 Episodes Planned" iso8859-1]
}

# LINE_WRAP
# takes a long line in, and chops it before the specified length
# http://forum.egghelp.org/viewtopic.php?t=6690
#
proc line_wrap {str {splitChr { }}} { 
  set out [set cur {}]
  set i 0
  set len $::webbySplit
  foreach word [split [set str][set str ""] $splitChr] { 
    if {[incr i [string length $word]] > $len} { 
      lappend out [join $cur $splitChr] 
      set cur [list $word] 
      set i [string length $word] 
    } else { 
      lappend cur $word 
    } 
    incr i 
  } 
  lappend out [join $cur $splitChr] 
}

#  idna support
#  
#      This file is part of the jabberlib. It provides support for
#      Internationalizing Domain Names in Applications (IDNA, RFC 3490).
#      
#  Copyright (c) 2005 Alexey Shchepin <alexey@sevcom.net>
#  
# $Id$
#
#  SYNOPSIS
#      idna::domain_toascii domain
#

namespace eval idna {}

##########################################################################

proc idna::domain_toascii {domain} {
    #set domain [string tolower $domain]
    set parts [split $domain "\u002E\u3002\uFF0E\uFF61"]
    set res {}
    foreach p $parts {
	set r [toascii $p]
	lappend res $r
    }
    return [join $res .]
}

##########################################################################

proc idna::toascii {name} {
    # TODO: Steps 2, 3 and 5 from RFC3490

    if {![string is ascii $name]} {
	set name [punycode_encode $name]
	set name "xn--$name"
    }
    return $name
}

##########################################################################

proc idna::punycode_encode {input} {
    set base 36
    set tmin 1
    set tmax 26
    set skew 38
    set damp 700
    set initial_bias 72
    set initial_n 0x80

    set n $initial_n
    set delta 0
    set out 0
    set bias $initial_bias
    set output ""
    set input_length [string length $input]
    set nonbasic {}

    for {set j 0} {$j < $input_length} {incr j} {
	set c [string index $input $j]
	if {[string is ascii $c]} {
	    append output $c
	} else {
	    lappend nonbasic $c
	}
    }

    set nonbasic [lsort -unique $nonbasic]

    set h [set b [string length $output]];

    if {$b > 0} {
	append output -
    }

    while {$h < $input_length} {
	set m [scan [string index $nonbasic 0] %c]
	set nonbasic [lrange $nonbasic 1 end]

	incr delta [expr {($m - $n) * ($h + 1)}]
	set n $m

	for {set j 0} {$j < $input_length} {incr j} {
	    set c [scan [string index $input $j] %c]

	    if {$c < $n} {
		incr delta
	    } elseif {$c == $n} {
		for {set q $delta; set k $base} {1} {incr k $base} {
		    set t [expr {$k <= $bias ? $tmin :
				 $k >= $bias + $tmax ? $tmax : $k - $bias}]
		    if {$q < $t} break;
		    append output \
			[punycode_encode_digit \
			     [expr {$t + ($q - $t) % ($base - $t)}]]
		    set q [expr {($q - $t) / ($base - $t)}]
		}

		append output [punycode_encode_digit $q]
		set bias [punycode_adapt \
			      $delta [expr {$h + 1}] [expr {$h == $b}]]
		set delta 0
		incr h
	    }
	}
	
	incr delta
	incr n
    }

    return $output;
}

##########################################################################

proc idna::punycode_adapt {delta numpoints firsttime} {
    set base 36
    set tmin 1
    set tmax 26
    set skew 38
    set damp 700

    set delta [expr {$firsttime ? $delta / $damp : $delta >> 1}]
    incr delta [expr {$delta / $numpoints}]

    for {set k 0} {$delta > (($base - $tmin) * $tmax) / 2}  {incr k $base} {
	set delta [expr {$delta / ($base - $tmin)}];
    }

    return [expr {$k + ($base - $tmin + 1) * $delta / ($delta + $skew)}]
}

##########################################################################

proc idna::punycode_encode_digit {d} {
    return [format %c [expr {$d + 22 + 75 * ($d < 26)}]]
}

##########################################################################

putlog "webby v1.7 has been loaded."
