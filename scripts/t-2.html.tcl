#%v2064#%dt140814#%t-2.html.tcl#
#############################################################################
# Copyright (c) 2006-2014, Richard Fischer (SpiKe^^) spike@mytclscripts.com #
#                                                                           #
# Permission to use, copy, modify, and/or distribute this software for any  #
# purpose with or without fee is hereby granted, provided that the above    #
# copyright notice and this permission notice appear in all copies.         #
#                                                                           #
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES  #
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF          #
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR   #
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    #
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN     #
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF   #
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.            #
#                                                                           #
# v1.1 by SpiKe^^  spike@mytclscripts.com,  August 14, 2014                 #
#############################################################################

################################################## Date: 14Aug14 ##
## BogusHTML 2.06.4 by SpiKe^^      :BogusTrivia Html Page Maker ##
###################################################################

###################################################################
##                                                               ##
##  BogusHTML is an html page generator for BogusTrivia 2.06.3+  ##
##                                                               ##
##  ! THIS SCRIPT REQUIRES: BogusTrivia ver. 2.06.3 or higher !  ##
##                                                               ##
###################################################################
#                        BogusHTML 2.06.4                         #
#                    ! USE AT YOUR OWN RISKS !                    #
#                                                                 #
#   If you'd like to Preview the Html Output Visit BogusTrivia    #
#                http://athlon.ispeeds.net/~bogus/                #
#                                                                 #
#             Please report bugs or make comments at:             #
#                  irc: undernet: #pc-mIRC-help                   #
#                email: spike@mytclscripts.com                    #
#             web site: http://www.mytclscripts.com               #
#                                                                 #
#         View Extensive Info, FAQ Sheets and Screenshots         #
#                   http://mytclscripts.com                       #
###################################################################
#                                                                 #
#  Version 2.06.4 Release Notes:                                  #
#                                                                 #
# -> New Updated File:  t-2.html.tcl <-                           #
#  Moved the patch in BogusHTML 2.06.2.beta4 to a full release    #
#    complete script (you no longer have to install & then patch).#
#  Several other small code adjustments.                          #
#                                                                 #
# -> New Updated Files:  all html templates <-                    #
#  Cleaned up and slightly patched all five html template files.  #
#                                                                 #
#  The BogusHTML 2.06.4.zip file now includes all required files. #
#                                                                 #
###################################################################
##                  Included ReadMe Files                        ##
##                   !!  Please Read  !!                         ##
##                                                               ##
##   1. BogusHtml-ReadMe.txt                                     ##
##   2. BogusHtml-Install-Upgrade.txt                            ##
##   3. BogusHtml-Commands.txt                                   ##
##                                                               ##
###################################################################
#                                                                 #
#  This tcl script Must be in the /scripts directory to run!      #
#  Does Not Require a source line in your eggdrop conf file!      #
#                                                                 #
###################################################################

###################################################################
##                      BogusHTML Features                       ##
###################################################################
#                                                                 #
#  1.  Bot Generated HTML Stats w/ On|Off Option                  #
#  2.  Single Stat Pages or An Entire Site                        #
#  3.  Active, History & Extended History Options                 #
#  4.  Custom Naming of Stat Pages                                #
#  5.  Track And Display Any Number of Events                     #
#  6.  Custom Templates & CSS with Included Themes                #
#                                                                 #
###################################################################

###################################################################
##                       BogusHTML History                       ##
###################################################################
#  Version 2.06.2 BETA 4 Release Notes:                           #
#                                                                 #
#  Includes one New File (t-2.html.tcl):                          #
#    1. Patched BogusHTML to run correctly on BogusTrivia 2.06.4+ #
###################################################################
#  Version 2.06.2 BETA 3 Release Notes:                           #
#                                                                 #
#  Includes All New Files:                                        #
#    1. New Custom Templates with CSS Themes.                     #
#    2. Extended History Pages with Smartlinks.                   #
#    3. Better Web Page Navigation.                               #
#    4. Makes Web Pages on Demand.                                #
###################################################################

#########################################################################
#####  BogusHTML Script Settings  #####  BogusHTML Script Settings  #####
#########################################################################

## Turn this page maker on or off ##
set thtm(html) "1"  ;# make html pages ??  (0=no | 1=yes)

## Set the directory where the updated html pages go!! ##
set thtm(output) "../public_html"  ;# route from the eggdrop exe folder

## Set the IRC Network ##
set thtm(network) "YourNetwork"  ;# irc network the bot is running on #

## Make an html index page, with links to all the other stats pages ?? ##
set thtm(shoin) "1"   ;# make an updated index page ??  (0=no | 1=yes) #
set thtm(index) ""    ;# name the output index page this  ("" = index.html) #
# Note: Requires Template File:  index.html #


#### Active Stats Pages:  Recent top players for today, this week, this month, & ever ####
###  if you are manually uploading these pages to a web server,  set     ###
###  this to make an updated top players ever page once or twice a day.  ###

# update active page stats this often.  (pages only made if stats change:) #
#  1= make active pages once a day   (at midnight)                         #
#  2= make active pages twice a day  (noon & midnight)                     #
#  3+ = make updated active pages every "x" minutes (any number 3 or more) #
set thtm(activ) "3"

# show a top players ever page ??  (0=no ever.html page) #
set thtm(shoev) "50"   ;# number of players to show for top players ever #
# Note: Requires Template File:  ever.html #

# show a top players this month page ??  (0=no tmonth.html page) #
set thtm(shotmo) "50"   ;# number of players to show for top players this month #
# Note: Requires Template File:  active.html #

# show a top players this week page ??  (0=no tweek.html page) #
set thtm(shotwe) "50"   ;# number of players to show for top players this week #
# Note: Requires Template File:  active.html #

# show a top players today page ??  (0=no today.html page) #
set thtm(shotda) "50"   ;# number of players to show for top players today #
# Note: All today stats disabled if thtm(activ) above is set to "1" or "2" #
# Note: Requires Template File:  active.html #


#### History Stats Pages:  stats for last 7 days, last 4 weeks and last 4 months ####
###  these pages are updated just after midnight as required.  ###

# show a top players monthly history page ??  (0=no month.html page) #
set thtm(shomo) "4"   ;# show monthly history page ??  (0=no | 1+ = number of months to show) #
set thtm(musrs) "30"  ;# number of players to show for each month #
# Note: Requires Template File:  history.html #

# show a top players weekly history page ??  (0=no week.html page) #
set thtm(showe) "4"   ;# show weekly history page ??  (0=no | 1+ = number of weeks to show) #
set thtm(wusrs) "30"  ;# number of players to show for each week #
# Note: Requires Template File:  history.html #

# show a top players daily history page ??  (0=no day.html page) #
set thtm(shoda) "7"   ;# show daily history page ??  (0=no | 1+ = number of days to show) #
set thtm(dusrs) "30"  ;# number of players to show for each day #
# Note: Requires Template File:  history.html #


#### Extended Stats Pages:  stats for any number of past days, weeks and months ####
### Make a more complet stats page,  one day, week or month per html page.      ###
### Can keep and link any number of extended history pages!                     ###
### Example:  thtm(xda) "30"     (keep 30 daily history pages)                  ###
### Example:  thtm(xwe) "52 50"  (keep 52 weekly pages, each with 50 players)   ###
### Example:  thtm(xmo) "12 *"   (keep 12 monthly pages, and show all players)  ###

# show extended daily history pages ??  (0=no extended daily pages) #
set thtm(xda) "30 *"
# Note: Requires Template File:  xhistory.html #

# show extended weekly history pages ??  (0=no extended weekly pages) #
set thtm(xwe) "52 *"
# Note: Requires Template File:  xhistory.html #

# show extended monthly history pages ??  (0=no extended monthly pages) #
set thtm(xmo) "12 *"
# Note: Requires Template File:  xhistory.html #



##########################################################################
####  BogusHTML Advanced Settings  ####  BogusHTML Advanced Settings  ####
##########################################################################

#### Advanced Settings  (for all stats tables on all pages) ####

# minimum points to show in all stats # 0=all with any points # 1+= all with x+ points #
set thtm(shomin) "0"

# maximum number of players to show on any 'show all players' stats
# must be a number 10 or more.   examples: 50, 30, 75  etc.
set thtm(shomax) "200"

# apply classes to the column heads <th> tags ?? #
# will use the classes:  th1 th2 th3 ...etc.
# 0 = no
# 1 or more = number of col heads to assign classes to  (ex. 2 = first 2 col heads)
set thtm(stych) "5"

# apply classes to the stats data <td> tags ?? #
# will use the classes:  td1 td2 td3 ...etc.
set thtm(stytd) "1"


############################################################################
#### !! END SETTINGS !! #### !! END SETTINGS !! #### !! END SETTINGS !! ####
############################################################################
#### !! END SETTINGS !! #### !! END SETTINGS !! #### !! END SETTINGS !! ####
############################################################################

## settings in next version ##
#### do not change these! ####
set thtm(webmastr) ""  ;  set thtm(shoot) ""
set thtm(dausrs) "50 30"  ;  set thtm(weusrs) "50 30"  ;  set thtm(mousrs) "50 30"
set thtm(defda) "30"  ;  set thtm(defwe) "30"  ;  set thtm(defmo) "30"
set thtm(defev) "30"  ;  set thtm(deftda) "30"
set thtm(deftwe) "30"  ;  set thtm(deftmo) "30"

if {![info exists t2(hdowat)]} {  array unset thtm  ;  return  }
foreach thtm(q) {xda xwe xmo} {
 if {![info exists thtm($thtm(q))] || $thtm($thtm(q)) eq ""} {  set thtm($thtm(q)) 0  }
 if {$thtm($thtm(q)) ne "0"} {  set thtm($thtm(q)) [split $thtm($thtm(q))]
   if {![TStrDig [lindex $thtm($thtm(q)) 0]] || [lindex $thtm($thtm(q)) 0]=="0"} {
     set thtm($thtm(q)) 0
   } elseif {[llength $thtm($thtm(q))]>"1"} {  set thtm(y) [lindex $thtm($thtm(q)) 1]
     if {[string equal * $thtm(y)]} {  set thtm($thtm(q)) [lreplace $thtm($thtm(q)) 1 1 500]
     } elseif {([TStrDig $thtm(y)] && $thtm(y)=="0") || ![TStrDig $thtm(y)]} {
       set thtm($thtm(q)) [lreplace $thtm($thtm(q)) 1 1]
     }
   }
 }
}
if {$t2(hdowat) eq "read"} {  lappend thtm(tmls) dausrs [split $thtm(dausrs)] xda
  lappend thtm(tmls) weusrs [split $thtm(weusrs)] xwe mousrs [split $thtm(mousrs)] xmo
  foreach {thtm(x) thtm(y) thtm(q)} $thtm(tmls) {
   if {[llength $thtm(y)]=="1"} {  lappend thtm(y) [lindex $thtm(y) 0]  }
   if {[string equal * [lindex $thtm(y) 0]]} {  set thtm(z) 500
   } elseif {[TStrDig [lindex $thtm(y) 0]] && [lindex $thtm(y) 0]>"30"} {
     set thtm(z) [lindex $thtm(y) 0]
   } else {  set thtm(z) 30  }
   if {[string equal * [lindex $thtm(y) 1]]} {
     if {$thtm(z)<"500"} {  set thtm(z) "500 500"  } else {  lappend thtm(z) 500  }
   } elseif {[TStrDig [lindex $thtm(y) 1]] && [lindex $thtm(y) 1]>"20"} {
     if {$thtm(z)<[lindex $thtm(y) 1]} {  set thtm(z) "[lindex $thtm(y) 1] [lindex $thtm(y) 1]"
     } else {  lappend thtm(z) [lindex $thtm(y) 1]  }
   } else {  lappend thtm(z) 20  }
   set t2($thtm(x)) $thtm(z)
   if {[llength $thtm($thtm(q))]>"1"} {
     if {[lindex $thtm($thtm(q)) 1]>[lindex $thtm(z) 0]} {
         lappend t2($thtm(x)) [lindex $thtm($thtm(q)) 1]  }
   }
  }
}
foreach {thtm(x) thtm(q)} {dausrs xda weusrs xwe mousrs xmo} {
 if {$thtm($thtm(q)) eq "0"} {  continue  }
 if {[llength $thtm($thtm(q))]=="1"} {  lappend thtm($thtm(q)) [lindex $t2($thtm(x)) 0]  }
 if {$thtm(q) eq "xda"} {
   if {[lindex $thtm(xda) 0]>"7"} {  set t2(keepda) [lindex $thtm(xda) 0]  }
 } elseif {$thtm(q) eq "xwe"} {
   if {[lindex $thtm(xwe) 0]>"4"} {  set t2(keepwe) [lindex $thtm(xwe) 0]  }
 } elseif {[lindex $thtm(xmo) 0]>"4"} {  set t2(keepmo) [lindex $thtm(xmo) 0]  }
}

set thtm(t2ver) [string range [string map {. ""} $t2(ver)] 0 3]
if {$thtm(html)=="0" || $thtm(t2ver)<"2063"} {
  foreach thtm(q) {-html -hactv -hchanges -hxchanges} {
   if {[info exists t2($thtm(q))]} {  unset t2($thtm(q))  }
  }
  array unset thtm  ;  unset t2(hdowat)  ;  return
}

set thtm(htmdir) $t2(pwdpath)$t2(scrpath)t2/template/
if {[string match ../* $thtm(output)]} {  set thtm(temp) $t2(pwdpath)
  while {[string match ../* $thtm(output)]} {  set thtm(temp) [file dirname $thtm(temp)]
     set thtm(output) [string range $thtm(output) 3 end]  }
  set thtm(houtdir) $thtm(temp)/[string trim $thtm(output) /]/
} else {  set thtm(houtdir) $t2(pwdpath)[string trim $thtm(output) /]/  }

if {$t2(hdowat) eq "read"} {  putlog "Loading 10BogusHTML v2.06.4 by SpiKe^^..."
  set thtm(-tls) ""  ;  set thtm(-new) 0
  if {![file exists $thtm(htmdir)]} {  file mkdir $thtm(htmdir)  ;  set thtm(-new) 1  }
  foreach thtm(x) {history active ever index xhistory} {
   if {[file exists $t2(pwdpath)$t2(scrpath)$thtm(x).html]} {  lappend thtm(-tls) $thtm(x).html  }
  }
  if {$thtm(-tls) ne ""} {
    putlog "Moving template files:  [join $thtm(-tls) ", "]  to $thtm(htmdir)"
    foreach thtm(-tfl) $thtm(-tls) {  file rename -force $t2(pwdpath)$t2(scrpath)$thtm(-tfl) $thtm(htmdir)  }
  } elseif {$thtm(-new)=="1"} {  putlog "Made template directory:  $thtm(htmdir)"  }
  if {![file exists $thtm(houtdir)]} {  file mkdir $thtm(houtdir)
    putlog "Made html output directory:  $thtm(houtdir)"
  } elseif {$thtm(-new)=="1"} {  putlog "Found existing html output directory:  $thtm(houtdir)"  }
  if {[file exists $t2(pwdpath)$t2(scrpath)default.css]} {
    putlog "Moving css file:  default.css  to $thtm(houtdir)"
    file rename -force $t2(pwdpath)$t2(scrpath)default.css $thtm(houtdir)
  }
}

if {![file exists $thtm(htmdir)]} {  file mkdir $thtm(htmdir)  }
if {![file exists $thtm(houtdir)]} {  file mkdir $thtm(houtdir)  }
set t2(-html) ""  ;  set thtm(-hls) ""  ;  set thtm(-changes) ""  ;  set thtm(-xchanges) ""
if {![file exists $thtm(htmdir)history.html]} {  array set thtm {showe 0 shomo 0 shoda 0}  }
foreach {thtm(x) thtm(y)} {showe week.html shomo month.html shoda day.html} {
 if {$thtm($thtm(x))=="0" && [file exists $thtm(houtdir)$thtm(y)]} {
     lappend thtm(-changes) -$thtm(y)  ;  file delete $thtm(houtdir)$thtm(y)  }
}
if {![file exists $thtm(htmdir)xhistory.html]} {  array set thtm {xwe 0 xmo 0 xda 0}
} elseif {$t2(hdowat) eq "read"} {
  foreach {thtm(x) thtm(y)} {xwe weusrs xmo mousrs xda dausrs} {
   if {$thtm($thtm(x)) ne "0"} {
     if {[llength $t2($thtm(y))]>"2" && [lindex $t2($thtm(y)) 2]>[lindex $t2($thtm(y)) 0]} {
         set t2($thtm(y)) [lreplace $t2($thtm(y)) 0 0 [lindex $t2($thtm(y)) 2]]  }
     if {[lindex $t2($thtm(y)) 0]>[lindex $t2($thtm(y)) 1]} {
         set t2($thtm(y)) [lreplace $t2($thtm(y)) 1 1 [lindex $t2($thtm(y)) 0]]  }
   }
  }
}
foreach {thtm(x) thtm(y)} {xwe xw_* xmo xm_* xda xd_*} {  set thtm(-rmls) ""
 set thtm(-tmls) [lsort -decreasing [glob -directory $thtm(houtdir) -nocomplain $thtm(y)]]
 if {$thtm($thtm(x)) eq "0"} {
   if {$thtm(-tmls) ne ""} {  set thtm(-rmls) $thtm(-tmls)  ;  set thtm(-rfcnt) 0  }
 } elseif {[llength $thtm(-tmls)]>[lindex $thtm($thtm(x)) 0]} {  set thtm(-rfcnt) [lindex $thtm($thtm(x)) 0]
   set thtm(-rmls) [lrange $thtm(-tmls) [lindex $thtm($thtm(x)) 0] end]
 }
 foreach thtm(z) $thtm(-rmls) {  incr thtm(-rfcnt)  ;  file delete $thtm(z)
    lappend thtm(-xchanges) -[string range $thtm(y) 0 1]-$thtm(-rfcnt)  }
}
if {$thtm(showe)>"0" || $thtm(xwe) ne "0"} {  set t2(-html) w
  if {$thtm(showe)>"0"} {  lappend thtm(-hls) week.html  }
  if {$thtm(xwe) ne "0"} {  lappend thtm(-hls) xw_.html  }
}
if {$thtm(shomo)>"0" || $thtm(xmo) ne "0"} {  append t2(-html) m
  if {$thtm(shomo)>"0"} {  lappend thtm(-hls) month.html  }
  if {$thtm(xmo) ne "0"} {  lappend thtm(-hls) xm_.html  }
}
if {$thtm(shoda)>"0" || $thtm(xda) ne "0"} {  set t2(-html) d
  if {$thtm(shoda)>"0"} {  lappend thtm(-hls) day.html  }
  if {$thtm(xda) ne "0"} {  lappend thtm(-hls) xd_.html  }
}

set thtm(-als) ""  ;  if {[info exists t2(-hactv)]} {  unset t2(-hactv)  }
if {$thtm(shoev)>"0"} {
  if {![file exists $thtm(htmdir)ever.html]} {  set thtm(shoev) 0
  } else {  lappend thtm(-als) ever.html  }
}
if {![file exists $thtm(htmdir)active.html]} {  array set thtm {shotwe 0 shotmo 0 shotda 0}
} else {    if {$thtm(shotmo)>"0"} {  lappend thtm(-als) tmonth.html  }
  if {$thtm(shotwe)>"0"} {  lappend thtm(-als) tweek.html  }
  if {$thtm(shotda)>"0"} {
    if {$thtm(activ)>"2"} { lappend thtm(-als) today.html } else { set thtm(shotda) 0 }
  }
}
foreach {thtm(x) thtm(y)} {shoev ever.html shotmo tmonth.html shotwe tweek.html shotda today.html} {
 if {$thtm($thtm(x))=="0" && [file exists $thtm(houtdir)$thtm(y)]} {
     lappend thtm(-changes) -$thtm(y)  ;  file delete $thtm(houtdir)$thtm(y)  }
}
if {$thtm(-als) ne ""} {
  if {$thtm(activ)>"2"} {  set t2(-hactv) $thtm(activ)
  } elseif {$thtm(activ)=="2"} {  set t2(-html) d2  } else { set t2(-html) d  ; set thtm(activ) 1 }
}
if {$t2(hdowat) eq "read"} {
  if {($t2(-html) eq "d" && [info exists t2(-hactv)]) || $t2(-html) eq "d2"} { set thtm(-gotit) 1 }
}

if {![info exists thtm(-gotit)]} {  set thtm(-tols) ""
  if {$thtm(shoin)>"0"} {
    if {![file exists $thtm(htmdir)index.html]} {  set thtm(shoin) 0
    } else {  lappend thtm(-tols) index.html  }
  }
  if {$thtm(shoot) ne ""} {
    foreach thtm(-tfl) [split $thtm(shoot)] {
     if {[file exists $thtm(htmdir)$thtm(-tfl)]} {  lappend thtm(-tols) $thtm(-tfl)  }
    }
  }
  if {$thtm(-tols) ne ""} {  set thtm(-ols) ""
    foreach thtm(-ofl) $thtm(-tols) {  set thtm(-open) [open $thtm(htmdir)$thtm(-ofl)]
     set thtm(-oln) [gets $thtm(-open)]  ;  close $thtm(-open)
     if {![string match #CONTENT#* $thtm(-oln)]} {  lappend thtm(-fixls) $thtm(-ofl)
     } else {  set thtm(-oln) [lrange [split $thtm(-oln)] 1 end]
       set thtm(-frst) [lindex $thtm(-oln) 0]
       if {$thtm(-frst) eq ""} {  lappend thtm(-fixls) $thtm(-ofl)
       } else {  set thtm(-tls) [split $thtm(-frst) {}]  ;  set thtm(-good) 1 
         foreach thtm(-tdig) $thtm(-tls) {
          if {![string match {[adwm]} $thtm(-tdig)]} { set thtm(-good) 0 ; break }
         }
         if {$thtm(-good)=="0"} {  lappend thtm(-fixls) $thtm(-ofl)
         } else {  set thtm(-tmp) [list $thtm(-ofl) $thtm(-frst)]
           if {[string match *a* $thtm(-frst)]} {
             set thtm(-tm2) [lsearch -all -inline $thtm(-oln) *-0*]
             if {$thtm(-tm2) eq ""} {  lappend thtm(-fixls) $thtm(-ofl)  ;  continue  }
             set thtm(-tmp) [concat $thtm(-tmp) $thtm(-tm2)]
           }
           lappend thtm(-ols) $thtm(-tmp)
           if {[string match {*[dwm]*} $thtm(-frst)]} {  lappend thtm(-hls) $thtm(-ofl)
             if {$t2(-html) ne "d" && $t2(-html) ne "d2"} {
               if {[string match *d* $thtm(-frst)]} {  set t2(-html) d
               } elseif {[string match *w* $thtm(-frst)] && [string match *m* $thtm(-frst)]} {
                 set t2(-html) wm
               } elseif {$t2(-html) ne "wm"} {
                 if {[string match *w* $thtm(-frst)]} {
                   if {$t2(-html) eq "m"} {  set t2(-html) wm  } else {  set t2(-html) w  }
                 }
                 if {[string match *m* $thtm(-frst)]} {
                   if {$t2(-html) eq "w"} {  set t2(-html) wm  } else {  set t2(-html) m  }
                 }
               }
             }
           }
           if {[string match *a* $thtm(-frst)]} {  lappend thtm(-als) $thtm(-ofl)
             if {$thtm(activ)>"2"} {  set t2(-hactv) $thtm(activ)
             } elseif {$thtm(activ)=="2"} {  set t2(-html) d2  } else {  set t2(-html) d  }
           }
         }
       }
       if {$t2(hdowat) eq "read"} {
         if {($t2(-html) eq "d" && [info exists t2(-hactv)]) || $t2(-html) eq "d2"} {
             set thtm(-gotit) 1  ;  break  }
       }
     }
    }
    if {![info exists thtm(-gotit)] && [info exists thtm(-fixls)]} {
      if {$t2(hdowat) eq "read"} {  putlog "Fixing html template files..."  }
    }
  }
}

if {$thtm(-hls) eq "" && $thtm(-als) eq ""} {
  if {$t2(hdowat) eq "read"} {
    putlog "$tclr(-msg)BogusHTML NOT Loaded.$tclr(-emsg)  Required html template(s) not found."
  }
  foreach thtm(q) {-html -hactv -hchanges -hxchanges} {
     if {[info exists t2($thtm(q))]} { unset t2($thtm(q)) }   }
  array unset thtm  ;  unset t2(hdowat)  ;  return
}
if {![file exists $t2(sfpath)t2.users]} {  TSavUsers  }

if {$t2(hdowat) eq "read"} {

##
bind msgm $t2(mflag) .mak* HMake
proc HMake {nk uh hn tx {opt 0} } {  global t2 thtm nick
  if {$tx eq ".makx" || $tx eq ".makex"} {  set t2(hdowat) allx
  } elseif {$tx eq ".mak" || $tx eq ".make"} {  set t2(hdowat) all  }

  if {[info exists t2(hdowat)]} {  source $t2(pwdpath)$t2(scrpath)t-2.html.tcl  }
}
##
proc HStartEnd {wat ut {opt 0} } {  global t2
 set is [split [strftime %H.%M.%S $ut] .]  ;  set start $ut
 if {[lindex $is 0] ne "00"} {  set tmp [expr {[string trimleft [lindex $is 0] 0]*3600}]
     incr start -$tmp  }
 if {[lindex $is 1] ne "00"} {  set tmp [expr {[string trimleft [lindex $is 1] 0]*60}]
     incr start -$tmp  }
 if {[lindex $is 2] ne "00"} {  set tmp [string trimleft [lindex $is 2] 0]
     incr start -$tmp  }
 if {[strftime %H $start] eq "01"} {  incr start -3600
 } elseif {[strftime %H $start] eq "23"} {  incr start 3600  }
 if {$wat eq "m"} {  set tmp [string trimleft [strftime %d $start] 0]
   if {$tmp!="1"} {  set tmp [expr {($tmp-1)*86400}]
       incr start -$tmp  }
 } elseif {$wat eq "w"} {  set tmp [strftime %u $start]  ;  set tm2 $t2(newweek)
   if {$tmp!=$tm2} {
     if {$tm2<$tmp} {  set tmp [expr {($tmp-$tm2)*86400}]
         incr start -$tmp  }
   } else {  set days 0
     while {$tmp!=$tm2} {  incr tmp -1  ;  incr days
      if {$tmp=="0"} {  set tmp 7  }
     }
     set tmp [expr {$days*86400}]  ;  incr start -$tmp
   }
 }
 if {[strftime %H $start] eq "01"} {  incr start -3600
 } elseif {[strftime %H $start] eq "23"} {  incr start 3600  }
 if {$opt=="1"} {  return $start  }
 if {$wat eq "m"} {  set end [expr {$start+2332800}]  ; set month [strftime %m $start]  ; set dun 0
   while {$dun=="0"} {
    if {[strftime %H $end] eq "01"} {  incr end -3600
    } elseif {[strftime %H $end] eq "23"} {  incr end 3600  }
    if {[strftime %m $end] ne $month} {  incr end -1  ;  set dun 1
    } else {  incr end 86400  }
   }
 } else {
   if {$wat eq "w"} {  set end [expr {$start+604800}]
   } else {  set end [expr {$start+86400}]  }
   if {[strftime %H $end] eq "01"} {  incr end -3600
   } elseif {[strftime %H $end] eq "23"} {  incr end 3600  }
   incr end -1
 }
 return [list $start $end]
}
##

  putlog "$tclr(-msg)BogusHTML$tclr(-emsg) Loaded."
  if {$thtm(-changes) ne ""} {
    if {![info exists t2(-hchanges)]} {  set t2(-hchanges) $thtm(-changes)
    } else {  set t2(-hchanges) [concat $t2(-hchanges) $thtm(-changes)]  }
  }
  if {$thtm(-xchanges) ne ""} {
    if {![info exists t2(-hxchanges)]} {  set t2(-hxchanges) $thtm(-xchanges)
    } else {  set t2(-hxchanges) [concat $t2(-hxchanges) $thtm(-xchanges)]  }
  }
  array unset thtm  ;  unset t2(hdowat)  ;  return
}

if {[info exists t2(-hchanges)]} {
  if {$thtm(-changes) eq ""} {  set thtm(-changes) $t2(-hchanges)
  } else {  set thtm(-changes) [concat $t2(-hchanges) $thtm(-changes)]  }
  unset t2(-hchanges)
}
if {[info exists t2(-hxchanges)]} {
  if {$thtm(-xchanges) eq ""} {  set thtm(-xchanges) $t2(-hxchanges)
  } else {  set thtm(-xchanges) [concat $t2(-hxchanges) $thtm(-xchanges)]  }
  unset t2(-hxchanges)
}
if {$t2(-ison)=="0"} {
  if {[file exists $t2(sfpath)t2.recent]} {
      TSavUsers 1  ;  file delete $t2(sfpath)t2.recent  }
} elseif {$t2(-reccnt)>"0"} {  TSavUsers 1  }

set thtm(-gmap) [list %c $t2(chan) %n $thtm(network) %q $t2(-qtotal) %k $t2(-ktotal) %b $nick %v $t2(ver)]
set thtm(-uopen) [open $t2(sfpath)t2.users]
set thtm(-uinf) [string trim [gets $thtm(-uopen)] :]  ;  close $thtm(-uopen)  ;  unset thtm(-uopen)
set thtm(-uinf) [lreplace $thtm(-uinf) 0 0 [lindex [split [lindex $thtm(-uinf) 0] :] end]]
lappend thtm(-gmap) %p [lindex $thtm(-uinf) 8]

set thtm(-hdls) ""
if {[file exists $t2(sfpath)t2.hist]} {  set thtm(-hopen) [open $t2(sfpath)t2.hist]
  while {![eof $thtm(-hopen)]} {  set thtm(-hln) [gets $thtm(-hopen)]
   if {[string match ::D:* $thtm(-hln)]} {  lappend thtm(-hdls) [lindex $thtm(-hln) 2]
   } elseif {[string match ::W:* $thtm(-hln)]} {  lappend thtm(-hwls) [lindex $thtm(-hln) 2]
   } elseif {[string match ::M:* $thtm(-hln)]} {  lappend thtm(-hmls) [lindex $thtm(-hln) 2]  }
  }
  close $thtm(-hopen)  ;  unset thtm(-hopen)
  if {$thtm(-hdls) ne ""} {  set thtm(-hdls) [lsort -integer -decreasing $thtm(-hdls)]  }
  if {[info exists thtm(-hwls)]} {  set thtm(-hwls) [lsort -integer -decreasing $thtm(-hwls)]  }
  if {[info exists thtm(-hmls)]} {  set thtm(-hmls) [lsort -integer -decreasing $thtm(-hmls)]  }
}

if {[file exists $thtm(htmdir)xhistory.html]} {
  set thtm(-xopen) [open $thtm(htmdir)xhistory.html]  ;  gets $thtm(-xopen)  ;  gets $thtm(-xopen)
  set thtm(-xln) [gets $thtm(-xopen)]
  if {[string match #L,* $thtm(-xln)]} {  set thtm(-xln) [split $thtm(-xln) ,]
    if {[lindex $thtm(-xln) 1] ne ""} {  set thtm(-xlline) [lrange $thtm(-xln) 1 end]  }
  }
  close $thtm(-xopen)  ;  unset thtm(-xopen) thtm(-xln)
}
if {$t2(hdowat) eq "all" || $t2(hdowat) eq "allx"} {
  if {$t2(hdowat) eq "all"} {  set thtm(-all) 1  } else {  set thtm(-all) 2  }
  if {$thtm(-hdls) ne ""} {  set t2(hdowat) history
    if {[info exists thtm(-hwls)]} {  append t2(hdowat) w  }
    if {[info exists thtm(-hmls)]} {  append t2(hdowat) m  }
  } else {
    if {$thtm(-all)=="1"} {  set t2(hdowat) active
    } else {
      if {$thtm(-changes) ne ""} {
        if {![info exists t2(-hchanges)]} {  set t2(-hchanges) $thtm(-changes)
        } else {  set t2(-hchanges) [concat $t2(-hchanges) $thtm(-changes)]  }
      }
      if {$thtm(-xchanges) ne ""} {
        if {![info exists t2(-hxchanges)]} {  set t2(-hxchanges) $thtm(-xchanges)
        } else {  set t2(-hxchanges) [concat $t2(-hxchanges) $thtm(-xchanges)]  }
      }
      array unset thtm  ;  unset t2(hdowat)  ;  return NoHistory
    }
  }
}
foreach {thtm(x) thtm(y) thtm(z)} {-xwls xw_* -hwls -xmls xm_* -hmls -xdls xd_* -hdls} {
 set thtm(-tmls) [glob -directory $thtm(houtdir) -tails -nocomplain $thtm(y)]
 if {$thtm(-tmls) ne ""} {
   if {[info exists thtm(-all)] && $thtm(-all)=="2"} {
     foreach thtm(q) $thtm(-tmls) {  file delete $thtm(houtdir)$thtm(q)  }
     if {[info exists thtm($thtm(z))] && $thtm($thtm(z)) ne ""} {  set thtm($thtm(x)) ""  }
   } else {  set thtm($thtm(x)) [lsort -decreasing $thtm(-tmls)]  }
 }
}

set thtm(-dols) ""
if {[string match history* $t2(hdowat)]} {
  if {[string match *m* $t2(hdowat)] && $thtm(xmo) ne "0"} {
      lappend thtm(-xdo) -xmls -hmls xmo  }
  if {[string match *w* $t2(hdowat)] && $thtm(xwe) ne "0"} {
      lappend thtm(-xdo) -xwls -hwls xwe  }
  if {$thtm(xda) ne "0"} {  lappend thtm(-xdo) -xdls -hdls xda  }
  if {[string match *m* $t2(hdowat)] && $thtm(shomo)>"0"} {
    if {![info exists thtm(-all)] || $thtm(-all)=="1"} {  lappend thtm(-dols) month.html
      if {![file exists $thtm(houtdir)month.html]} {  lappend thtm(-changes) +month.html  }
    }
  }
  if {[string match *w* $t2(hdowat)] && $thtm(showe)>"0"} {
    if {![info exists thtm(-all)] || $thtm(-all)=="1"} {  lappend thtm(-dols) week.html
      if {![file exists $thtm(houtdir)week.html]} {  lappend thtm(-changes) +week.html  }
    }
  }
  if {$thtm(shoda)>"0"} {
    if {![info exists thtm(-all)] || $thtm(-all)=="1"} {  lappend thtm(-dols) day.html
      if {![file exists $thtm(houtdir)day.html]} {  lappend thtm(-changes) +day.html  }
    }
  }
  if {$thtm(shotmo)>"0" && (![info exists t2(-hactv)] || [string match *m* $t2(hdowat)])} {
    if {![info exists thtm(-all)] || $thtm(-all)=="1"} {  lappend thtm(-dols) tmonth.html
      if {![file exists $thtm(houtdir)tmonth.html]} {  lappend thtm(-changes) +tmonth.html  }
    }
  }
  if {$thtm(shotwe)>"0" && (![info exists t2(-hactv)] || [string match *w* $t2(hdowat)])} {
    if {![info exists thtm(-all)] || $thtm(-all)=="1"} {  lappend thtm(-dols) tweek.html
      if {![file exists $thtm(houtdir)tweek.html]} {  lappend thtm(-changes) +tweek.html  }
    }
  }
  if {$thtm(shotda)>"0"} {
    if {![info exists thtm(-all)] || $thtm(-all)=="1"} {  lappend thtm(-dols) today.html
      if {![file exists $thtm(houtdir)today.html]} {  lappend thtm(-changes) +today.html  }
    }
  }
  if {![info exists t2(-hactv)] && $thtm(shoev)>"0"} {
    if {![info exists thtm(-all)] || $thtm(-all)=="1"} {  lappend thtm(-dols) ever.html
      if {![file exists $thtm(houtdir)ever.html]} {  lappend thtm(-changes) +ever.html  }
    }
  }
}
if {$t2(hdowat) eq "active" || ([info exists thtm(-all)] && $thtm(-all)=="1")} {
  if {$thtm(shotda)>"0" && [lsearch -exact $thtm(-dols) today.html]=="-1"} {  lappend thtm(-dols) today.html
    if {![file exists $thtm(houtdir)today.html]} {  lappend thtm(-changes) +today.html  }
  }
  if {$thtm(shotwe)>"0" && [lsearch -exact $thtm(-dols) tweek.html]=="-1"} {  lappend thtm(-dols) tweek.html
    if {![file exists $thtm(houtdir)tweek.html]} {  lappend thtm(-changes) +tweek.html  }
  }
  if {$thtm(shotmo)>"0" && [lsearch -exact $thtm(-dols) tmonth.html]=="-1"} {  lappend thtm(-dols) tmonth.html
    if {![file exists $thtm(houtdir)tmonth.html]} {  lappend thtm(-changes) +tmonth.html  }
  }
  if {$thtm(shoev)>"0" && [lsearch -exact $thtm(-dols) ever.html]=="-1"} {  lappend thtm(-dols) ever.html
    if {![file exists $thtm(houtdir)ever.html]} {  lappend thtm(-changes) +ever.html  }
  }
}
if {[info exists thtm(-xdo)]} {
  foreach {thtm(x) thtm(y) thtm(z)} $thtm(-xdo) {
   if {[info exists thtm(-all)] && $thtm(-all)=="2"} {  set thtm(-ecnt) 0
     foreach thtm(q) $thtm($thtm(y)) {  incr thtm(-ecnt)
      if {$thtm(-ecnt)>[lindex $thtm($thtm(z)) 0]} {  break  }
      set thtm(-xname) [string range $thtm(z) 0 1]_$thtm(q).html
      lappend thtm(-dols) $thtm(-xname)  ;  lappend thtm($thtm(x)) $thtm(-xname)
     }
   } else {  set thtm(-xname) [string range $thtm(z) 0 1]_[lindex $thtm($thtm(y)) 0].html
     lappend thtm(-dols) $thtm(-xname)
     if {![info exists thtm($thtm(x))]} {  lappend thtm($thtm(x)) $thtm(-xname)
       lappend thtm(-xchanges) +[string range $thtm(z) 0 1]-1
     } else {
       if {$thtm(-xname) ne [lindex $thtm($thtm(x)) 0]} {
         lappend thtm(-xchanges) +[string range $thtm(z) 0 1]-1
         set thtm($thtm(x)) [linsert $thtm($thtm(x)) 0 $thtm(-xname)]
         if {[llength $thtm($thtm(x))]>[lindex $thtm($thtm(z)) 0]} {  set thtm(-ecnt) [lindex $thtm($thtm(z)) 0]
           set thtm(-del) [lrange $thtm($thtm(x)) [lindex $thtm($thtm(z)) 0] end]
           set thtm($thtm(x)) [lreplace $thtm($thtm(x)) [lindex $thtm($thtm(z)) 0] end]
           foreach thtm(-dfl) $thtm(-del) {  file delete $thtm(houtdir)$thtm(-dfl)  ;  incr thtm(-ecnt)
            lappend thtm(-xchanges) -[string range $thtm(z) 0 1]-$thtm(-ecnt)
           }
         }
       }
     }
   }
  }
  if {[info exists thtm(-all)] && $thtm(-all)=="2"} {  unset thtm(-xdo)  }
}
if {[info exists thtm(-xdo)]} {  set thtm(-addme) ""
  if {[info exists thtm(-xlline)] && $thtm(-changes) ne ""} {
    foreach thtm(q) $thtm(-changes) {  set thtm(q) [lindex [split [string trim $thtm(q) -+] .] 0]
     if {[lsearch -exact $thtm(-xlline) $thtm(q)]>"-1"} {  set thtm(-addme) all  ;  break  }
    }
  }
  if {$thtm(-addme) ne "all"} {
    if {![info exists thtm(-xlline)]} {  set thtm(-xlline) [list xa_back xa_next]
    } else {  set thtm(q) [lsearch $thtm(-xlline) {x[adwm][-_]*}]
      if {$thtm(q)=="-1"} {  set thtm(-xlline) [list xa_back xa_next]
      } elseif {$thtm(q)>"0"} {  set thtm(-xlline) [lrange $thtm(-xlline) $thtm(q) end]  }
    }
    if {$thtm(-xchanges) ne ""} {
      if {[lsearch $thtm(-xlline) xd-*]>"-1" && [lsearch $thtm(-xchanges) +xd-1]>"-1"} {
        set thtm(-addme) all
      } elseif {[lsearch $thtm(-xlline) xw-*]>"-1" && [lsearch $thtm(-xchanges) +xw-1]>"-1"} {
        set thtm(-addme) all
      } elseif {[lsearch $thtm(-xlline) xm-*]>"-1" && [lsearch $thtm(-xchanges) +xm-1]>"-1"} {
        set thtm(-addme) all
      }
    }
  }
  if {$thtm(-addme) ne "all"} {
    foreach {thtm(x) thtm(y) thtm(z)} $thtm(-xdo) {  set thtm(q) [string index $thtm(z) 1]
     if {[lsearch $thtm(-xlline) xa-*]>"-1"} {
       if {[lsearch $thtm(-xchanges) +x$thtm(q)-1]>"-1" && [llength $thtm($thtm(x))]>"1"} {
           set thtm(-dols) [concat $thtm(-dols) [lrange $thtm($thtm(x)) 1 end]]  }
     } else {
       if {[lsearch $thtm(-xlline) xa_back]>"-1"} {
         if {[lsearch $thtm(-xchanges) +x$thtm(q)-1]>"-1" && [llength $thtm($thtm(x))]>"1"} {
             lappend thtm(-dols) [lindex $thtm($thtm(x)) 1]  }
       }
       if {[lsearch $thtm(-xlline) xa_next]>"-1"} {
         if {[lsearch $thtm(-xchanges) +x$thtm(q)-1]>"-1" && [llength $thtm($thtm(x))]>"1"} {
           if {[lindex $thtm($thtm(x)) end] ne [lindex $thtm(-dols) end]} {
               lappend thtm(-dols) [lindex $thtm($thtm(x)) end]  }
         }
       }
     }
    }
  } else {
    foreach {thtm(x) thtm(y) thtm(z)} $thtm(-xdo) {  set thtm(q) [string index $thtm(z) 1]
     if {[lsearch $thtm(-xchanges) +x$thtm(q)-1]>"-1" && [llength $thtm($thtm(x))]>"1"} {
         set thtm(-dols) [concat $thtm(-dols) [lrange $thtm($thtm(x)) 1 end]]  }
    }
  }  ;  unset thtm(-xdo)
}
if {[info exists thtm(-ols)] && (![info exists thtm(-all)] || $thtm(-all)=="1")} {
  foreach thtm(-tfls) $thtm(-ols) {
   foreach {thtm(-ofl) thtm(-cont)} $thtm(-tfls) { break }
   if {($t2(hdowat) eq "active" || [info exists thtm(-all)]) && [llength $thtm(-tfls)]>"2"} {
     lappend thtm(-dols) $thtm(-ofl)
   } elseif {[string match history* $t2(hdowat)]} {
     if {[string match *d* $thtm(-cont)]} {  lappend thtm(-dols) $thtm(-ofl)
     } elseif {[string match *w* $thtm(-cont)] && [string match *w* $t2(hdowat)]} {
       lappend thtm(-dols) $thtm(-ofl)
     } elseif {[string match *m* $thtm(-cont)] && [string match *m* $t2(hdowat)]} {
       lappend thtm(-dols) $thtm(-ofl)
     } elseif {[llength $thtm(-tfls)]>"2"} {  set thtm(-tfls) [lrange $thtm(-tfls) 2 end]
       if {[lsearch $thtm(-tfls) d-0*]} {  lappend thtm(-dols) $thtm(-ofl)
       } elseif {[lsearch $thtm(-tfls) w-0*]>"-1" && (![info exists t2(-hactv)] || [string match *w* $t2(hdowat)])} {
         lappend thtm(-dols) $thtm(-ofl)
       } elseif {[lsearch $thtm(-tfls) m-0*]>"-1" && (![info exists t2(-hactv)] || [string match *m* $t2(hdowat)])} {
         lappend thtm(-dols) $thtm(-ofl)
       } elseif {![info exists t2(-hactv)] && [lsearch $thtm(-tfls) e-0*]>"-1"} {  lappend thtm(-dols) $thtm(-ofl)  }
     }
   }
  }
}
if {$thtm(-dols) eq ""} {
  if {$thtm(-changes) ne ""} {
    if {![info exists t2(-hchanges)]} {  set t2(-hchanges) $thtm(-changes)
    } else {  set t2(-hchanges) [concat $t2(-hchanges) $thtm(-changes)]  }
  }
  if {$thtm(-xchanges) ne ""} {
    if {![info exists t2(-hxchanges)]} {  set t2(-hxchanges) $thtm(-xchanges)
    } else {  set t2(-hxchanges) [concat $t2(-hxchanges) $thtm(-xchanges)]  }
  }
  array unset thtm  ;  unset t2(hdowat)  ;  return
}

if {![info exists thtm(shomin)] || $thtm(shomin)=="0"} {  set thtm(shomin) 1  }

foreach thtm(-tfl) $thtm(-dols) {  set thtm(-doing) ""  ; set thtm(-changd) 0  ; set thtm(-hide) 0
 set thtm(-cln) ""  ;  set thtm(-vln) ""  ;  set thtm(-cont) ""  ;  set thtm(-err) 0
 if {[info exists thtm(-dousrs)]} {  unset thtm(-dousrs)  }
 if {[info exists thtm(-dostats)]} {  unset thtm(-dostats)  }
 if {$thtm(-tfl) eq "today.html" || $thtm(-tfl) eq "tweek.html" || $thtm(-tfl) eq "tmonth.html"} {
   set thtm(-usefl) active.html
   if {$thtm(-tfl) eq "today.html"} {  set thtm(-dodwm) d
     if {$thtm(shotda) eq "*"} {  set thtm(-dousrs) $thtm(shomax)
     } else {  set thtm(-dousrs) $thtm(shotda)  }
   } elseif {$thtm(-tfl) eq "tweek.html"} {  set thtm(-dodwm) w
     if {$thtm(shotwe) eq "*"} {  set thtm(-dousrs) $thtm(shomax)
     } else {  set thtm(-dousrs) $thtm(shotwe)  }
   } else {  set thtm(-dodwm) m
     if {$thtm(shotmo) eq "*"} {  set thtm(-dousrs) $thtm(shomax)
     } else {  set thtm(-dousrs) $thtm(shotmo)  }
   }
 } elseif {$thtm(-tfl) eq "day.html" || $thtm(-tfl) eq "week.html" || $thtm(-tfl) eq "month.html"} {
   set thtm(-usefl) history.html
   if {$thtm(-tfl) eq "day.html"} {  set thtm(-dodwm) d  ;  set thtm(-dostats) $thtm(shoda)
     if {$thtm(dusrs) eq "*"} {  set thtm(-dousrs) $thtm(shomax)
     } else {  set thtm(-dousrs) $thtm(dusrs)  }
   } elseif {$thtm(-tfl) eq "week.html"} {  set thtm(-dodwm) w ;  set thtm(-dostats) $thtm(showe)
     if {$thtm(wusrs) eq "*"} {  set thtm(-dousrs) $thtm(shomax)
     } else {  set thtm(-dousrs) $thtm(wusrs)  }
   } else {  set thtm(-dodwm) m  ;  set thtm(-dostats) $thtm(shomo)
     if {$thtm(musrs) eq "*"} {  set thtm(-dousrs) $thtm(shomax)
     } else {  set thtm(-dousrs) $thtm(musrs)  }
   }
 } elseif {[string match {x[dwm]_*.html} $thtm(-tfl)]} {
   set thtm(-usefl) xhistory.html  ;  set thtm(-dodwm) [string index $thtm(-tfl) 1]
   if {$thtm(-dodwm) eq "d"} {  set thtm(-dousrs) [lindex $thtm(xda) 1]
   } elseif {$thtm(-dodwm) eq "w"} {  set thtm(-dousrs) [lindex $thtm(xwe) 1]
   } else {  set thtm(-dousrs) [lindex $thtm(xmo) 1]  }
   set thtm(-dostats) [expr {[lsearch $thtm(-x$thtm(-dodwm)ls) $thtm(-tfl)]+1}]
   if {$thtm(-dostats)=="0"} {  continue  }
 } else {  set thtm(-usefl) $thtm(-tfl)
   if {[info exists thtm(-dodwm)]} {  unset thtm(-dodwm)  }
   if {$thtm(-tfl) eq "ever.html"} {  set thtm(-dousrs) $thtm(shoev)
     if {$thtm(shoev) eq "*"} {  set thtm(-dousrs) $thtm(shomax)
     } else {  set thtm(-dousrs) $thtm(shoev)  }
   }
 }
 foreach thtm(-var) {-ada -awe -amo -aev -hda -hwe -hmo} {
  if {[info exists thtm($thtm(-var))]} {  unset thtm($thtm(-var))  }
 }
 foreach thtm(-var) {-hopen -uopen -fmt -hid1 -hid2 -hidcnt -link -xlink -xinfo} {
  if {[info exists thtm($thtm(-var))]} {  unset thtm($thtm(-var))  }
 }
 set thtm(-open) [open $thtm(htmdir)$thtm(-usefl)]  ;  set thtm(-olncnt) 0
 set thtm(-newfl) [open $thtm(htmdir)t2.html.tmp w]
 while {![eof $thtm(-open)]} {   set thtm(-gln) [gets $thtm(-open)]  ;  incr thtm(-olncnt)
  if {$thtm(-olncnt)<"4" && [string match #L,* $thtm(-gln)]} {  continue  }
  if {[string match {#[DWM]#*} $thtm(-gln)]} {
    if {[info exists thtm(-dodwm)]} {
      if {[TStrLo [string index $thtm(-gln) 1]] eq $thtm(-dodwm)} {
        set thtm(-gln) [string range $thtm(-gln) 3 end]
        if {[string match " #*" $thtm(-gln)] || [string match "  #*" $thtm(-gln)]} {
            set thtm(-gln) [string trimleft $thtm(-gln)]  }
        if {[string index $thtm(-gln) 0] eq " "} {  set thtm(-gln) [string range $thtm(-gln) 1 end]  }
      } else {  continue  }
    } else {  set thtm(-err) 4  }
  }
  if {[string match #ENDH#* $thtm(-gln)]} {
    if {$thtm(-hide)=="1"} {
      if {[string match *nos* [TStrLo $thtm(-gln)]]} {  set thtm(-hide) 0  }
    } elseif {$thtm(-hide)=="2"} {
      if {[string match *noh* [TStrLo $thtm(-gln)]]} {  set thtm(-hide) 0  }
    } elseif {$thtm(-hide)=="3"} {
      if {[string match *nox* [TStrLo $thtm(-gln)]]} {  set thtm(-hide) 0  }
    } elseif {[info exists thtm(-hid1)]} {  set thtm(-gln) #END#  }
    if {![info exists thtm(-hid1)]} {  continue  }
  } elseif {[string match #HIDE#* $thtm(-gln)]} {
    if {$thtm(-hide)=="0"} {
      if {[string match *nos* [TStrLo $thtm(-gln)]]} {
        set thtm(-x) [split [lindex [split $thtm(-gln) :] 1] -]
        if {[lindex $thtm(-x) 0] eq "a" && [info exists thtm(-dodwm)]} {
          set thtm(-x) [lreplace $thtm(-x) 0 0 $thtm(-dodwm)]
        } elseif {[lindex $thtm(-x) 0] eq "a"} {  set thtm(-err) 5.1  }
        if {[lindex $thtm(-x) 1] eq "0"} {  set thtm(-err) 5.2
        } elseif {[lindex $thtm(-x) 0] eq "d"} {
          if {[lindex $thtm(-x) 1]>[llength $thtm(-hdls)]} {  set thtm(-hide) 1
          } elseif {$thtm(-usefl) eq "history.html" && [lindex $thtm(-x) 1]>$thtm(shoda)} {
              set thtm(-hide) 1  }
        } elseif {[lindex $thtm(-x) 0] eq "w"} {
          if {![info exists thtm(-hwls)] || [lindex $thtm(-x) 1]>[llength $thtm(-hwls)]} { set thtm(-hide) 1
          } elseif {$thtm(-usefl) eq "history.html" && [lindex $thtm(-x) 1]>$thtm(showe)} {
              set thtm(-hide) 1  }
        } elseif {[lindex $thtm(-x) 0] eq "m"} {
          if {![info exists thtm(-hmls)] || [lindex $thtm(-x) 1]>[llength $thtm(-hmls)]} { set thtm(-hide) 1
          } elseif {$thtm(-usefl) eq "history.html" && [lindex $thtm(-x) 1]>$thtm(shomo)} {
              set thtm(-hide) 1  }
        }
        if {$thtm(-hide)=="0"} {  set thtm(-hid1) ""  ;  set thtm(-hid2) ""  ;  set thtm(-hidcnt) 1  }
      } elseif {[string match *noh* [TStrLo $thtm(-gln)]]} {
        if {$thtm(-hdls) eq ""} {  set thtm(-hide) 2  }
      } elseif {[string match *nox* [TStrLo $thtm(-gln)]]} {
        set thtm(-x) [TStrLo [lindex [split $thtm(-gln)] 1]]
        if {[string match *d* $thtm(-x)]} {
          if {![info exists thtm(-xdls)]} {  set thtm(-hide) 3  }
        } elseif {[string match *w* $thtm(-x)]} {
          if {![info exists thtm(-xwls)]} {  set thtm(-hide) 3  }
        } elseif {[string match *m* $thtm(-x)]} {
          if {![info exists thtm(-xmls)]} {  set thtm(-hide) 3  }
        } elseif {![info exists thtm(-xdls)] && ![info exists thtm(-xwls)] && ![info exists thtm(-xmls)]} {
          set thtm(-hide) 3
        }
      }
    }
    continue
  } elseif {$thtm(-hide)>"0"} {
    if {![string match #STATS#* $thtm(-gln)]} {  continue  }
  } elseif {[info exists thtm(-hid1)]} {  ;## if in a Hide nostats loop  ##
    if {[info exists thtm(-h1cnt)] && ![string match {#[0-9]#*} $thtm(-gln)]} {
      if {$thtm(-hidcnt)=="1"} {  lappend thtm(-hid1) $thtm(-h1nex)
      } elseif {$thtm(-hidcnt)=="3"} {  lappend thtm(-hid2) $thtm(-h1nex)  }
      unset thtm(-h1nex)  ;  unset thtm(-h1cnt)
    }
    if {[info exists thtm(-xlink)] && $thtm(-gln) eq ""} {  set thtm(-gln) #L,end#  }
    if {[string match *#L,*# $thtm(-gln)]} {  set thtm(-gln) [string trim $thtm(-gln)]
      if {[string match *#l,end# [TStrLo $thtm(-gln)]]} {
        if {[info exists thtm(-link)]} {  unset thtm(-link)  ;  continue  }
        if {![info exists thtm(-xlink)]} {  continue  } else {  unset thtm(-xlink)  }
      } elseif {[string match *#l,x?_.* [TStrLo $thtm(-gln)]]} {
        set thtm(-tmp2) [split $thtm(-gln) _]  ;  set thtm(-tmp3) [lindex $thtm(-tmp2) 0]
        if {[TStrLo [string index $thtm(-tmp3) end]] eq "a" && [info exists thtm(-dodwm)]} {
          set thtm(-tmp3) [string range $thtm(-tmp3) 0 end-1]$thtm(-dodwm)
          set thtm(-gln) [join [lreplace $thtm(-tmp2) 0 0 $thtm(-tmp3)] _]
        } elseif {![string match {[dwm]} [TStrLo [string index $thtm(-tmp3) end]]]} {
          set thtm(-link) $thtm(-gln)  ;  continue
        }
        set thtm(-xlink) 1
      } else {  set thtm(-gln) [string trim [lindex [split $thtm(-gln) ,] 1] #]
        if {[file exists $thtm(houtdir)$thtm(-gln)] || [lsearch -exact $thtm(-dols) $thtm(-gln)]>"-1"} {
          if {[info exists thtm(-link)]} {  unset thtm(-link)  }
        } else {  set thtm(-link) $thtm(-gln)  }
        if {[info exists thtm(-xlink)]} {  unset thtm(-xlink)  ;  set thtm(-gln) #L,end#
        } else {  continue  }
      }
    } elseif {[info exists thtm(-link)]} {
      if {$thtm(-gln) eq ""} {  unset thtm(-link)  }  ;  continue
    }
    if {[string match #END#* $thtm(-gln)] || $thtm(-gln) eq "" || $thtm(-gln) eq " "} {
      set thtm(-hidcnt) 3  ;  continue
    } elseif {[string match #STATS#* $thtm(-gln)] || [string match #*HEAD*#* $thtm(-gln)]} {
      if {$thtm(-hidcnt)=="1"} {  set thtm(-hidcnt) 2  }
    } elseif {$thtm(-hidcnt)=="2"} {
    } elseif {[string match {#[0-9]#*} $thtm(-gln)]} {
      if {[string index $thtm(-gln) 3] ne " "} {  set thtm(-gln) [string replace $thtm(-gln) 2 2 "# "]  }
      if {![info exists thtm(-h1cnt)]} {  set thtm(-h1cnt) [string index $thtm(-gln) 1]
        set thtm(-h1nex) [string range $thtm(-gln) 4 end]
      } elseif {[string index $thtm(-gln) 1] eq $thtm(-h1cnt)} {
        append thtm(-h1nex) #BR#[string range $thtm(-gln) 4 end]
      } else {  set thtm(-h1cnt) [string index $thtm(-gln) 1]
        append thtm(-h1nex) #NX#[string range $thtm(-gln) 4 end]
      }
      continue
    } else {
      if {$thtm(-hidcnt)=="1"} {  lappend thtm(-hid1) $thtm(-gln)
      } elseif {$thtm(-hidcnt)=="3"} {  lappend thtm(-hid2) $thtm(-gln)  }
      continue
    }
  }
  if {![info exists thtm(-hid1)] && [string match *#L,*# $thtm(-gln)]} {
    set thtm(-gln) [string trim $thtm(-gln)]
    if {[TStrLo $thtm(-gln)] eq "#l,end#"} {
      if {[info exists thtm(-link)]} {  unset thtm(-link)  }
    } elseif {[string match #l,x?_.* [TStrLo $thtm(-gln)]]} {
    } else {  set thtm(-gln) [string trim [lindex [split $thtm(-gln) ,] 1] #]
      if {[file exists $thtm(houtdir)$thtm(-gln)] || [lsearch -exact $thtm(-dols) $thtm(-gln)]>"-1"} {
        if {[info exists thtm(-link)]} {  unset thtm(-link)  }
      } else {  set thtm(-link) $thtm(-gln)  }
    }
    continue
  } elseif {[info exists thtm(-link)]} {
    if {$thtm(-gln) eq ""} {  unset thtm(-link)  }  ;  continue
  }
  if {$thtm(-err)=="0" && ($thtm(-doing) eq "table" || [string match #* $thtm(-gln)])} {
    if {[string match #CONTENT#* $thtm(-gln)]} {
      if {$thtm(-usefl) eq "xhistory.html"} {  set thtm(-gln) "#CONTENT# dwm a-$thtm(-dostats),"  }
      set thtm(-cln) [lrange $thtm(-gln) 2 end]
      if {[info exists thtm(-dodwm)]} {
          set thtm(-cln) [string map [list a $thtm(-dodwm)] $thtm(-cln)]  }
      if {[string match *a* [lindex $thtm(-gln) 1]]} {
        if {![info exists thtm(-aels)]} {  set thtm(-aels) ""
          if {[file exists $t2(sfpath)t2.users]} {  set thtm(-uopen) [open $t2(sfpath)t2.users]
            while {![eof $thtm(-uopen)]} {  set thtm(-uln) [gets $thtm(-uopen)]
             if {[string match :N:* $thtm(-uln)]} {  set thtm(-uln) [split $thtm(-uln)]
               if {[lindex $thtm(-uln) 3]>"0"} {  lappend thtm(-adls) [lindex $thtm(-uln) 3]  }
               if {[lindex $thtm(-uln) 5]>"0"} {  lappend thtm(-awls) [lindex $thtm(-uln) 5]  }
               if {[lindex $thtm(-uln) 7]>"0"} {  lappend thtm(-amls) [lindex $thtm(-uln) 7]  }
               if {[lindex $thtm(-uln) 9]>"0"} {  lappend thtm(-aels) [lindex $thtm(-uln) 9]  }
             }
            }
            close $thtm(-uopen)  ;  unset thtm(-uopen)  ;  set thtm(-z) ""
            if {$thtm(-aels) ne ""} {  lappend thtm(-z) -aels  }
            if {[info exists thtm(-adls)]} {  lappend thtm(-z) -adls  }
            if {[info exists thtm(-awls)]} {  lappend thtm(-z) -awls  }
            if {[info exists thtm(-amls)]} {  lappend thtm(-z) -amls  }
            if {$thtm(-z) ne ""} {
              foreach thtm(-elm) $thtm(-z) {  set thtm(-y) ""
               set thtm($thtm(-elm)) [lsort -integer -decreasing $thtm($thtm(-elm))]
               while {[llength $thtm($thtm(-elm))]>"9"} {  lappend thtm(-y) [lindex $thtm($thtm(-elm)) 9]
                if {[llength $thtm($thtm(-elm))]=="10"} {  set thtm($thtm(-elm)) ""
                } else {  set thtm($thtm(-elm)) [lrange $thtm($thtm(-elm)) 10 end]  }
               }
               if {$thtm($thtm(-elm)) ne ""} {  lappend thtm(-y) [lindex $thtm($thtm(-elm)) end]  }
               set thtm($thtm(-elm)) $thtm(-y)
              }
            }
          }
        }
      }
      if {[string match {*[dwm]*} [lindex $thtm(-gln) 1]]} {
        if {[string first -*, $thtm(-cln)]>"-1"} {  set thtm(-newc) ""  ;  set thtm(-last) ""
          foreach thtm(-y) $thtm(-cln) {
           if {[string first -*, $thtm(-y)]>"-1"} {  set thtm(-last) [split $thtm(-last) -,]
             set thtm(-z) [lindex $thtm(-last) 1]
             if {[lindex $thtm(-last) 0] eq "d"} {
               if {$thtm(-z)<[llength $thtm(-hdls)]} {  set thtm(-stop) [llength $thtm(-hdls)]  }
             } elseif {[lindex $thtm(-last) 0] eq "w"} {
               if {[info exists thtm(-hwls)] && $thtm(-z)<[llength $thtm(-hwls)]} {
                   set thtm(-stop) [llength $thtm(-hwls)]  }
             } elseif {[lindex $thtm(-last) 0] eq "m"} {
               if {[info exists thtm(-hmls)] && $thtm(-z)<[llength $thtm(-hmls)]} {
                   set thtm(-stop) [llength $thtm(-hmls)]  }
             }
             if {[info exists thtm(-stop)]} {
               while {$thtm(-stop)>$thtm(-z)} {  incr thtm(-z)
                if {[info exists thtm(-dostats)] && $thtm(-z)>$thtm(-dostats)} {  break  }
                lappend thtm(-newc) [lindex $thtm(-last) 0]-$thtm(-z),[lindex [split $thtm(-y) ,] 1]
               }
               unset thtm(-stop)
             }
           } else {  lappend thtm(-newc) $thtm(-y)  }
           set thtm(-last) $thtm(-y)
          }
          set thtm(-cln) $thtm(-newc)
        }
      }
      if {[lsearch $thtm(-cln) *,]>"-1" || [string first ,* $thtm(-cln)]>"-1"} {  set thtm(-newc) ""
        foreach thtm(-y) $thtm(-cln) {
         if {[string first ,* $thtm(-y)]>"-1"} {
           lappend thtm(-newc) [lindex [split $thtm(-y) ,] 0],$thtm(shomax)
         } elseif {[string match *, $thtm(-y)]} {
           if {[info exists thtm(-dousrs)]} {  lappend thtm(-newc) $thtm(-y)$thtm(-dousrs)
           } elseif {[string match e-* $thtm(-y)]} {  lappend thtm(-newc) $thtm(-y)$thtm(defev)
           } elseif {[string match d-0* $thtm(-y)]} {  lappend thtm(-newc) $thtm(-y)$thtm(deftda)
           } elseif {[string match d-* $thtm(-y)]} {  lappend thtm(-newc) $thtm(-y)$thtm(defda)
           } elseif {[string match w-0* $thtm(-y)]} {  lappend thtm(-newc) $thtm(-y)$thtm(deftwe)
           } elseif {[string match w-* $thtm(-y)]} {  lappend thtm(-newc) $thtm(-y)$thtm(defwe)
           } elseif {[string match m-0* $thtm(-y)]} {  lappend thtm(-newc) $thtm(-y)$thtm(deftmo)
           } elseif {[string match m-* $thtm(-y)]} {  lappend thtm(-newc) $thtm(-y)$thtm(defmo)  }
         } else {  lappend thtm(-newc) $thtm(-y)  }
        }
        set thtm(-cln) $thtm(-newc)
      }
      set thtm(-chkls) $thtm(-cln)  ;  continue
    } elseif {[string match #%v* $thtm(-gln)]} {  set thtm(-vln) $thtm(-gln)  ;  continue
    } elseif {[string match #STATS#* $thtm(-gln)] || [string match #*HEAD*#* $thtm(-gln)]} {
      if {$thtm(-doing) ne "body" && $thtm(-doing) ne "table"} {  set thtm(-err) 3.1
      } else {
        if {$thtm(-hide)=="0" && $thtm(-doing) eq "body"} {  set thtm(-doing) table  }
        if {![info exists thtm(_show)]} {
          array set thtm {_show "" _cols "" _shohed 0 _head "" _scnt 0}
        }
        if {[string match #STATS#* $thtm(-gln)]} {
          if {$thtm(_shohed)=="0"} {  set thtm(_shohed) 2  }
          if {$thtm(-usefl) eq "xhistory.html"} {  set thtm(-gln) "#STATS# show:a-$thtm(-dostats)"  }
          set thtm(_show) [split [string tolower [lindex [split [lindex [split $thtm(-gln)] 1] :] 1]] ,]
          if {[llength $thtm(_show)]>"2"} {  set thtm(_show) [lrange $thtm(_show) 0 1]  }
          if {[info exists thtm(-dodwm)]} {
              set thtm(_show) [string map [list a $thtm(-dodwm)] $thtm(_show)]  }
          set thtm(-temp) [split [lindex $thtm(_show) 0] -]
          if {[llength $thtm(_show)]>"1" && ![TStrDig [lindex $thtm(_show) 1]] && ![string equal * [lindex $thtm(_show) 1]]} {
            set thtm(-err) 3.2
          } elseif {[llength $thtm(-temp)]<"2" || ![string match {[ademw]} [lindex $thtm(-temp) 0]]} {
            set thtm(-err) 3.3
          } elseif {![TStrDig [lindex $thtm(-temp) 1]] || [llength $thtm(-temp)]>"3"} {
            set thtm(-err) 3.4
          } else {
            if {[llength $thtm(-temp)]=="3"} {
              if {![string equal * [lindex $thtm(-temp) 2]] && ![TStrDig [lindex $thtm(-temp) 2]]} {
                set thtm(-temp) [lrange $thtm(-temp) 0 1]
              } elseif {[TStrDig [lindex $thtm(-temp) 2]] && [lindex $thtm(-temp) 1]>=[lindex $thtm(-temp) 2]} {
                set thtm(-temp) [lrange $thtm(-temp) 0 1]
              }
            }
            set thtm(-tem2) [lindex $thtm(-temp) 0]-[lindex $thtm(-temp) 1]
            if {[llength $thtm(-temp)]=="3"} {
              if {[string equal * [lindex $thtm(-temp) 2]]} {  set thtm(-last) [lindex $thtm(-temp) 1]
                if {[lindex $thtm(-temp) 0] eq "d"} {
                  if {$thtm(-last)<[llength $thtm(-hdls)]} {  set thtm(-stop) [llength $thtm(-hdls)]  }
                } elseif {[lindex $thtm(-temp) 0] eq "w"} {
                  if {[info exists thtm(-hwls)] && $thtm(-last)<[llength $thtm(-hwls)]} {
                      set thtm(-stop) [llength $thtm(-hwls)]  }
                } elseif {[lindex $thtm(-temp) 0] eq "m"} {
                  if {[info exists thtm(-hmls)] && $thtm(-last)<[llength $thtm(-hmls)]} {
                      set thtm(-stop) [llength $thtm(-hmls)]  }
                }
                if {[info exists thtm(-stop)]} {
                  while {$thtm(-stop)>$thtm(-last)} {  incr thtm(-last)
                   if {[info exists thtm(-dostats)] && $thtm(-last)>$thtm(-dostats)} {  break  }
                   lappend thtm(-tem2) [lindex $thtm(-temp) 0]-$thtm(-last)
                  }
                  unset thtm(-stop)
                }
              } else {  set thtm(-tem3) [lindex $thtm(-temp) 1]
                while {$thtm(-tem3)<[lindex $thtm(-temp) 2]} {  incr thtm(-tem3)
                   lappend thtm(-tem2) [lindex $thtm(-temp) 0]-$thtm(-tem3)  }
              }
            }
            if {[llength $thtm(_show)]>"1"} {  lappend thtm(-tem2) [lindex $thtm(_show) 1]
            } else {
              if {[info exists thtm(-dousrs)]} {  lappend thtm(-tem2) $thtm(-dousrs)
              } else {
                if {[lindex $thtm(-temp) 0] eq "e"} {  lappend thtm(-tem2) $thtm(defev)
                } elseif {[lindex $thtm(-temp) 0] eq "d"} {
                  if {[lindex $thtm(-temp) 1] eq "0"} {  lappend thtm(-tem2) $thtm(deftda)
                  } else {  lappend thtm(-tem2) $thtm(defda)  }
                } elseif {[lindex $thtm(-temp) 0] eq "w"} {
                  if {[lindex $thtm(-temp) 1] eq "0"} {  lappend thtm(-tem2) $thtm(deftwe)
                  } else {  lappend thtm(-tem2) $thtm(defwe)  }
                } elseif {[lindex $thtm(-temp) 0] eq "m"} {
                  if {[lindex $thtm(-temp) 1] eq "0"} {  lappend thtm(-tem2) $thtm(deftmo)
                  } else {  lappend thtm(-tem2) $thtm(defmo)  }
                }
              }
            }
            set thtm(_show) $thtm(-tem2)
          }
          if {$thtm(-hide)>"0"} {  set thtm(_z) [lindex $thtm(-chkls) end]
            set thtm(-chkls) [lreplace $thtm(-chkls) 0 [expr {[llength $thtm(_show)]-2}]]
            if {$thtm(-chkls) eq ""} {  set thtm(-chkls) $thtm(_z)  }  ;  array unset thtm _*
          } elseif {$thtm(_scnt)=="0"} {
            if {[string match -nocase *col:* $thtm(-gln)]} {
              set thtm(-start) [expr {[string first col: $thtm(-gln)]+4}]
              while {[set thtm(-next) [string first col: $thtm(-gln) $thtm(-start)]] ne "-1"} {
               lappend thtm(_cols) [split [string trim [string range $thtm(-gln) $thtm(-start) [incr thtm(-next) -1]]] =]
               set thtm(-start) [expr {$thtm(-next)+5}]
              }
              lappend thtm(_cols) [split [string trim [string range $thtm(-gln) $thtm(-start) end]] =]
            } else {  set thtm(_cols) {{Rank #%r} {Nick %n} {Points %p} {Questions %c}}  }
          }
        } else { set thtm(-gln) [string trimleft $thtm(-gln) #]  ; set thtm(_fnum) [string first # $thtm(-gln)]
          if {$thtm(_shohed)=="0"} {  set thtm(_shohed) 1  }
          if {[string match *HEAD#* $thtm(-gln)]} {  set thtm(_x) ""
          } else {  set thtm(_y) [string first HEAD $thtm(-gln)]  ;  incr thtm(_y) 4
            set thtm(_x) [string range $thtm(-gln) $thtm(_y) [expr {$thtm(_fnum)-1}]]
          }
          if {[string index $thtm(-gln) [expr {$thtm(_fnum)+1}]] ne " "} {  incr thtm(_fnum)
          } else {  incr thtm(_fnum) 2  }
          if {[string match A* $thtm(-gln)]} {
            if {$thtm(_x) eq ""} {
              if {[info exists thtm(_ahnex)]} {  lappend thtm(_ahead) $thtm(_ahnex)
                  unset thtm(_ahnex)  ;  unset thtm(_ahcnt)  }
              lappend thtm(_ahead) [string range $thtm(-gln) $thtm(_fnum) end]
            } else {
              if {![info exists thtm(_ahcnt)]} {  set thtm(_ahcnt) $thtm(_x)
                set thtm(_ahnex) [string range $thtm(-gln) $thtm(_fnum) end]
              } elseif {$thtm(_x) eq $thtm(_ahcnt)} {
                append thtm(_ahnex) #BR#[string range $thtm(-gln) $thtm(_fnum) end]
              } else {  lappend thtm(_ahead) $thtm(_ahnex)  ;  set thtm(_ahcnt) $thtm(_x)
                  set thtm(_ahnex) [string range $thtm(-gln) $thtm(_fnum) end]  }
            }
          } elseif {[string match N* $thtm(-gln)]} {
            if {$thtm(_x) eq ""} {
              if {[info exists thtm(_nhnex)]} {  lappend thtm(_nhead) $thtm(_nhnex)
                  unset thtm(_nhnex)  ;  unset thtm(_nhcnt)  }
              lappend thtm(_nhead) [string range $thtm(-gln) $thtm(_fnum) end]
            } else {
              if {![info exists thtm(_nhcnt)]} {  set thtm(_nhcnt) $thtm(_x)
                set thtm(_nhnex) [string range $thtm(-gln) $thtm(_fnum) end]
              } elseif {$thtm(_x) eq $thtm(_nhcnt)} {
                append thtm(_nhnex) #BR#[string range $thtm(-gln) $thtm(_fnum) end]
              } else {  lappend thtm(_nhead) $thtm(_nhnex)  ;  set thtm(_nhcnt) $thtm(_x)
                  set thtm(_nhnex) [string range $thtm(-gln) $thtm(_fnum) end]  }
            }
          } else {
            if {$thtm(_x) eq ""} {
              if {[info exists thtm(_hnex)]} {  lappend thtm(_head) $thtm(_hnex)
                  unset thtm(_hnex)  ;  unset thtm(_hcnt)  }
              lappend thtm(_head) [string range $thtm(-gln) $thtm(_fnum) end]
            } else {
              if {![info exists thtm(_hcnt)]} {  set thtm(_hcnt) $thtm(_x)
                set thtm(_hnex) [string range $thtm(-gln) $thtm(_fnum) end]
              } elseif {$thtm(_x) eq $thtm(_hcnt)} {
                append thtm(_hnex) #BR#[string range $thtm(-gln) $thtm(_fnum) end]
              } else {  lappend thtm(_head) $thtm(_hnex)  ;  set thtm(_hcnt) $thtm(_x)
                  set thtm(_hnex) [string range $thtm(-gln) $thtm(_fnum) end]  }
            }
          }
        }
        continue
      }
    } elseif {[string match #*FOOT*#* $thtm(-gln)]} {
      if {$thtm(-doing) ne "table"} {  set thtm(-err) 3.5
      } else { set thtm(-gln) [string trimleft $thtm(-gln) #]  ; set thtm(_fnum) [string first # $thtm(-gln)]
        if {[string match *FOOT#* $thtm(-gln)]} {  set thtm(_x) ""
        } else {  set thtm(_y) [string first FOOT $thtm(-gln)]  ;  incr thtm(_y) 4
          set thtm(_x) [string range $thtm(-gln) $thtm(_y) [expr {$thtm(_fnum)-1}]]
        }
        if {[string index $thtm(-gln) [expr {$thtm(_fnum)+1}]] ne " "} {  incr thtm(_fnum)
        } else {  incr thtm(_fnum) 2  }
        if {[string match A* $thtm(-gln)]} {
          if {$thtm(_x) eq ""} {
            if {[info exists thtm(_afnex)]} {  lappend thtm(_afoot) $thtm(_afnex)
                unset thtm(_afnex)  ;  unset thtm(_afcnt)  }
            lappend thtm(_afoot) [string range $thtm(-gln) $thtm(_fnum) end]
          } else {
            if {![info exists thtm(_afcnt)]} {  set thtm(_afcnt) $thtm(_x)
              set thtm(_afnex) [string range $thtm(-gln) $thtm(_fnum) end]
            } elseif {$thtm(_x) eq $thtm(_afcnt)} {
              append thtm(_afnex) #BR#[string range $thtm(-gln) $thtm(_fnum) end]
            } else {  lappend thtm(_afoot) $thtm(_afnex)  ;  set thtm(_afcnt) $thtm(_x)
                set thtm(_afnex) [string range $thtm(-gln) $thtm(_fnum) end]  }
          }
        } elseif {[string match N* $thtm(-gln)]} {
          if {$thtm(_x) eq ""} {
            if {[info exists thtm(_nfnex)]} {  lappend thtm(_nfoot) $thtm(_nfnex)
                unset thtm(_nfnex)  ;  unset thtm(_nfcnt)  }
            lappend thtm(_nfoot) [string range $thtm(-gln) $thtm(_fnum) end]
          } else {
            if {![info exists thtm(_nfcnt)]} {  set thtm(_nfcnt) $thtm(_x)
              set thtm(_nfnex) [string range $thtm(-gln) $thtm(_fnum) end]
            } elseif {$thtm(_x) eq $thtm(_nfcnt)} {
              append thtm(_nfnex) #BR#[string range $thtm(-gln) $thtm(_fnum) end]
            } else {  lappend thtm(_nfoot) $thtm(_nfnex)  ;  set thtm(_nfcnt) $thtm(_x)
                set thtm(_nfnex) [string range $thtm(-gln) $thtm(_fnum) end]  }
          }
        } else {
          if {$thtm(_x) eq ""} {
            if {[info exists thtm(_fnex)]} {  lappend thtm(_foot) $thtm(_fnex)
                unset thtm(_fnex)  ;  unset thtm(_fcnt)  }
            lappend thtm(_foot) [string range $thtm(-gln) $thtm(_fnum) end]
          } else {
            if {![info exists thtm(_fcnt)]} {  set thtm(_fcnt) $thtm(_x)
              set thtm(_fnex) [string range $thtm(-gln) $thtm(_fnum) end]
            } elseif {$thtm(_x) eq $thtm(_fcnt)} {
              append thtm(_fnex) #BR#[string range $thtm(-gln) $thtm(_fnum) end]
            } else {  lappend thtm(_foot) $thtm(_fnex)  ;  set thtm(_fcnt) $thtm(_x)
                set thtm(_fnex) [string range $thtm(-gln) $thtm(_fnum) end]  }
          }
        }
        continue
      }
    } elseif {[string match #COLGROUPS#* $thtm(-gln)]} {
      if {$thtm(-doing) ne "table"} {  set thtm(-err) 3.6
      } else {  set thtm(-gln) [string trim [string range $thtm(-gln) 11 end]]
        if {$thtm(_scnt)=="0" && ![info exists thtm(_colgroups)]} { set thtm(_colgroups) $thtm(-gln) }
        continue
      }
    } elseif {[string match #SORTBYCOUNT#* $thtm(-gln)]} {
      if {$thtm(-doing) ne "table"} {  set thtm(-err) 3.7
      } else {  set thtm(_sortbyc) 1  ;  continue  }
    } elseif {[string match #SWAP#* $thtm(-gln)]} {
      if {$thtm(-doing) ne "table"} {  set thtm(-err) 3.8
      } else {  set thtm(_swap) [lindex [split $thtm(-gln)] 1]
        if {![TStrDig $thtm(_swap)]} {  set thtm(_swap) 0  }  ;  continue
      }
    } elseif {[string match #TABLE#* $thtm(-gln)]} {
      if {$thtm(-doing) ne "table"} {  set thtm(-err) 3.9
      } else {  set thtm(_table) [string trim [string range $thtm(-gln) 7 end]]
        if {$thtm(_table) eq ""} {  unset thtm(_table)  }  ;  continue
      }
    } elseif {[string match #END#* $thtm(-gln)] || $thtm(-gln) eq "" || $thtm(-gln) eq " "} {
      if {![info exists thtm(_swap)]} {  set thtm(_swap) 0  }
      foreach {thtm(_x) thtm(_y)} {_h ead _ah ead _nh ead _f oot _af oot _nf oot} {
       if {[info exists thtm($thtm(_x)nex)]} {
         lappend thtm($thtm(_x)$thtm(_y)) $thtm($thtm(_x)nex)
         unset thtm($thtm(_x)nex)  ;  unset thtm($thtm(_x)cnt)
       }
      }
      if {[string match *-0 [lindex $thtm(_show) 0]]} {
        if {![info exists thtm(-uopen)] && $thtm(-aels) ne ""} {
          foreach {thtm(_x) thtm(-z)} {d da w we m mo e ev} {
           set thtm(-tmp) [lsearch -all -inline $thtm(-cln) $thtm(_x)-0*]
           if {$thtm(-tmp) ne ""} {
             if {[llength $thtm(-tmp)]=="1"} {  set thtm(-y) [lindex [split $thtm(-tmp) ,] 1]
             } else {  set thtm(-y) 0
               foreach thtm(_ti) $thtm(-tmp) {  set thtm(_ti) [lindex [split $thtm(-ti) ,] 1]
                  if {$thtm(_ti)>$thtm(-y)} {  set thtm(-y) $thtm(_ti)  }   }
             }
             if {[string index $thtm(-y) end]!="0"} {  incr thtm(-y) 10  }
             set thtm(-y) [string range $thtm(-y) 0 end-1]
             if {![info exists thtm(-a$thtm(_x)ls)]} {  set thtm(-$thtm(_x)kp) $thtm(shomin)
             } elseif {$thtm(-y)>[llength $thtm(-a$thtm(_x)ls)]} {
               set thtm(-$thtm(_x)kp) [lindex $thtm(-a$thtm(_x)ls) end]
             } else { incr thtm(-y) -1  ; set thtm(-$thtm(_x)kp) [lindex $thtm(-a$thtm(_x)ls) $thtm(-y)]  }
             set thtm(-a$thtm(-z)) ""  ;  set thtm(-$thtm(_x)c) "0"
           }
          }
          set thtm(-uopen) [open $t2(sfpath)t2.users]
          while {![eof $thtm(-uopen)]} {  set thtm(-uln) [gets $thtm(-uopen)]
           if {[string match :N:* $thtm(-uln)]} {  set thtm(-uln) [split $thtm(-uln)]
             foreach {thtm(nk) thtm(hn) thtm(uh) thtm(dp) thtm(dc) thtm(wp) thtm(wc) thtm(mp) thtm(mc) thtm(ep) thtm(ec)} $thtm(-uln) { break }
             set thtm(nk) [string range $thtm(nk) 3 end]
             if {[info exists thtm(-ada)] && $thtm(dp)>=$thtm(shomin)} {  incr thtm(-dc)
               if {$thtm(dp)>=$thtm(-dkp)} {
                   lappend thtm(-ada) [list $thtm(dp) $thtm(dc) $thtm(nk) $thtm(hn) $thtm(uh)]  }
             }
             if {[info exists thtm(-awe)] && $thtm(wp)>=$thtm(shomin)} {  incr thtm(-wc)
               if {$thtm(wp)>=$thtm(-wkp)} {
                   lappend thtm(-awe) [list $thtm(wp) $thtm(wc) $thtm(nk) $thtm(hn) $thtm(uh)]  }
             }
             if {[info exists thtm(-amo)] && $thtm(mp)>=$thtm(shomin)} {  incr thtm(-mc)
               if {$thtm(mp)>=$thtm(-mkp)} {
                   lappend thtm(-amo) [list $thtm(mp) $thtm(mc) $thtm(nk) $thtm(hn) $thtm(uh)]  }
             }
             if {[info exists thtm(-aev)] && $thtm(ep)>=$thtm(shomin)} {  incr thtm(-ec)
               if {$thtm(ep)>=$thtm(-ekp)} {
                   lappend thtm(-aev) [list $thtm(ep) $thtm(ec) $thtm(nk) $thtm(hn) $thtm(uh)]  }
             }
           }
          }
          close $thtm(-uopen)  ;  set thtm(-uopen) done
        }
      } else {
        if {![info exists thtm(-hopen)] && $thtm(-hdls) ne ""} {
          set thtm(-hopen) [open $t2(sfpath)t2.hist]  ;  set thtm(_doing) ""
          if {[info exists thtm(-hdls)]} {  set thtm(-hdc) 1  }
          if {[info exists thtm(-hwls)]} {  set thtm(-hwc) 1  }
          if {[info exists thtm(-hmls)]} {  set thtm(-hmc) 1  }
          while {![eof $thtm(-hopen)]} {  set thtm(-hln) [gets $thtm(-hopen)]
           if {$thtm(_doing) ne "" && ![string match :N:* $thtm(-hln)]} {
             if {$thtm(_doing) eq "d"} {  set thtm(_nex) $thtm(-hdc)
               set thtm(-tmp) [lsearch -all -inline $thtm(-cln) d-$thtm(-hdc),*]
             } elseif {$thtm(_doing) eq "w"} {  set thtm(_nex) $thtm(-hwc)
               set thtm(-tmp) [lsearch -all -inline $thtm(-cln) w-$thtm(-hwc),*]
             } elseif {$thtm(_doing) eq "m"} {  set thtm(_nex) $thtm(-hmc)
                 set thtm(-tmp) [lsearch -all -inline $thtm(-cln) m-$thtm(-hmc),*]  }
             if {$thtm(-tmp) ne ""} {  set thtm(_x) 0
               foreach thtm(_y) $thtm(-tmp) {  set thtm(_y) [lindex [split $thtm(_y) ,] 1]
                if {$thtm(_y)>$thtm(_x)} {  set thtm(_x) $thtm(_y)  }
               }
               lappend thtm(_nex) [lindex $thtm(_thln) 2]
               if {[llength $thtm(_thln)]=="3"} {  lappend thtm(_nex) unknown
               } else {  lappend thtm(_nex) [lindex $thtm(_thln) 3]  }
               lappend thtm(_nex) [lrange $thtm(_tpls) 0 [expr {$thtm(_x)+3}]]
               if {$thtm(_doing) eq "d"} {  lappend thtm(-hda) $thtm(_nex)
               } elseif {$thtm(_doing) eq "w"} {  lappend thtm(-hwe) $thtm(_nex)
               } elseif {$thtm(_doing) eq "m"} {  lappend thtm(-hmo) $thtm(_nex)  }
             }
             if {$thtm(_doing) eq "d"} {  incr thtm(-hdc)
             } elseif {$thtm(_doing) eq "w"} {  incr thtm(-hwc)
             } elseif {$thtm(_doing) eq "m"} {  incr thtm(-hmc)  }
             unset thtm(_tpls)  ;  unset thtm(_nex)  ;  set thtm(_doing) ""
           }
           if {[string match ::D:* $thtm(-hln)]} {  set thtm(_thln) $thtm(-hln)
             set thtm(_doing) d  ;  set thtm(_tpls) ""
           } elseif {[string match ::W:* $thtm(-hln)]} {  set thtm(_thln) $thtm(-hln)
             set thtm(_doing) w  ;  set thtm(_tpls) ""
           } elseif {[string match ::M:* $thtm(-hln)]} {  set thtm(_thln) $thtm(-hln)
             set thtm(_doing) m  ;  set thtm(_tpls) ""
           } elseif {[string match :N:* $thtm(-hln)]} {
             set thtm(-hln) [split [string range $thtm(-hln) 3 end]]
             lappend thtm(_tpls) [concat [lrange $thtm(-hln) 3 4] [lrange $thtm(-hln) 0 2]]
           }
          }
          close $thtm(-hopen)  ;  set thtm(-hopen) done
        }
      }
      foreach thtm(_todo) [lrange $thtm(_show) 0 end-1] {  set thtm(_dols) $thtm(_todo)
       if {[string match *-0 $thtm(_todo)]} {
         if {$thtm(-aels) ne ""} {
           if {[string match d* $thtm(_todo)]} {
             lappend thtm(_dols) [HStartEnd d [lindex $thtm(-uinf) 2] 1] [unixtime] $thtm(-dc)
             if {$thtm(-dc)>"0"} {
               if {[info exists thtm(_sortbyc)]} {
                 set thtm(-ada) [lsort -index 1 -integer -decreasing $thtm(-ada)]
               } else {  set thtm(-ada) [lsort -index 0 -integer -decreasing $thtm(-ada)]  }
               set thtm(-z) [lindex [split [lindex $thtm(-chkls) 0] ,] 1]
               lappend thtm(_dols) [lrange $thtm(-ada) 0 [expr {$thtm(-z)-1}]]
             }
           } elseif {[string match w* $thtm(_todo)]} {
             lappend thtm(_dols) [HStartEnd w [lindex $thtm(-uinf) 4] 1] [unixtime] $thtm(-wc)
             if {$thtm(-wc)>"0"} {
               if {[info exists thtm(_sortbyc)]} {
                 set thtm(-awe) [lsort -index 1 -integer -decreasing $thtm(-awe)]
               } else {  set thtm(-awe) [lsort -index 0 -integer -decreasing $thtm(-awe)]  }
               set thtm(-z) [lindex [split [lindex $thtm(-chkls) 0] ,] 1]
               lappend thtm(_dols) [lrange $thtm(-awe) 0 [expr {$thtm(-z)-1}]]
             }
           } elseif {[string match m* $thtm(_todo)]} {
             lappend thtm(_dols) [HStartEnd m [lindex $thtm(-uinf) 6] 1] [unixtime] $thtm(-mc)
             if {$thtm(-mc)>"0"} {
               if {[info exists thtm(_sortbyc)]} {
                 set thtm(-amo) [lsort -index 1 -integer -decreasing $thtm(-amo)]
               } else {  set thtm(-amo) [lsort -index 0 -integer -decreasing $thtm(-amo)]  }
               set thtm(-z) [lindex [split [lindex $thtm(-chkls) 0] ,] 1]
               lappend thtm(_dols) [lrange $thtm(-amo) 0 [expr {$thtm(-z)-1}]]
             }
           } elseif {[string match e* $thtm(_todo)]} {
             lappend thtm(_dols) [lindex $thtm(-uinf) 0] [unixtime] $thtm(-ec)
             if {$thtm(-ec)>"0"} {
               if {[info exists thtm(_sortbyc)]} {
                 set thtm(-aev) [lsort -index 1 -integer -decreasing $thtm(-aev)]
               } else {  set thtm(-aev) [lsort -index 0 -integer -decreasing $thtm(-aev)]  }
               set thtm(-z) [lindex [split [lindex $thtm(-chkls) 0] ,] 1]
               lappend thtm(_dols) [lrange $thtm(-aev) 0 [expr {$thtm(-z)-1}]]
             }
           }
         }
       } else {
         if {$thtm(-hdls) ne ""} {
           if {[string match d* $thtm(_todo)] && [info exists thtm(-hda)]} {
             set thtm(_x) [lsearch -inline $thtm(-hda) "[lindex [split $thtm(_todo) -] 1] *"]
             if {$thtm(_x) ne ""} {  set thtm(_y) [HStartEnd d [lindex $thtm(_x) 1]]
               lappend thtm(_dols) [lindex $thtm(_y) 0] [lindex $thtm(_y) 1]
               lappend thtm(_dols) [lindex $thtm(_x) 2]
               if {[lindex $thtm(_x) 2]>"0"} {
                 if {[info exists thtm(_sortbyc)]} {
                   set thtm(_pnex) [lsort -index 1 -integer -decreasing [lindex $thtm(_x) 3]]
                 } else {  set thtm(_pnex) [lindex $thtm(_x) 3]  }
                 set thtm(-z) [lindex [split [lindex $thtm(-chkls) 0] ,] 1]
                 lappend thtm(_dols) [lrange $thtm(_pnex) 0 [expr {$thtm(-z)-1}]]
               }
             }
           } elseif {[string match w* $thtm(_todo)] && [info exists thtm(-hwe)]} {
             set thtm(_x) [lsearch -inline $thtm(-hwe) "[lindex [split $thtm(_todo) -] 1] *"]
             if {$thtm(_x) ne ""} {  set thtm(_y) [HStartEnd w [lindex $thtm(_x) 1]]
               lappend thtm(_dols) [lindex $thtm(_y) 0] [lindex $thtm(_y) 1]
               lappend thtm(_dols) [lindex $thtm(_x) 2]
               if {[lindex $thtm(_x) 2]>"0"} {
                 if {[info exists thtm(_sortbyc)]} {
                   set thtm(_pnex) [lsort -index 1 -integer -decreasing [lindex $thtm(_x) 3]]
                 } else {  set thtm(_pnex) [lindex $thtm(_x) 3]  }
                 set thtm(-z) [lindex [split [lindex $thtm(-chkls) 0] ,] 1]
                 lappend thtm(_dols) [lrange $thtm(_pnex) 0 [expr {$thtm(-z)-1}]]
               }
             }
           } elseif {[string match m* $thtm(_todo)] && [info exists thtm(-hmo)]} {
             set thtm(_x) [lsearch -inline $thtm(-hmo) "[lindex [split $thtm(_todo) -] 1] *"]
             if {$thtm(_x) ne ""} {  set thtm(_y) [HStartEnd m [lindex $thtm(_x) 1]]
               lappend thtm(_dols) [lindex $thtm(_y) 0] [lindex $thtm(_y) 1]
               lappend thtm(_dols) [lindex $thtm(_x) 2]
               if {[lindex $thtm(_x) 2]>"0"} {
                 if {[info exists thtm(_sortbyc)]} {
                   set thtm(_pnex) [lsort -index 1 -integer -decreasing [lindex $thtm(_x) 3]]
                 } else {  set thtm(_pnex) [lindex $thtm(_x) 3]  }
                 set thtm(-z) [lindex [split [lindex $thtm(-chkls) 0] ,] 1]
                 lappend thtm(_dols) [lrange $thtm(_pnex) 0 [expr {$thtm(-z)-1}]]
               }
             }
           }
         }
       }
       if {[llength $thtm(_dols)]=="1"} {  lappend thtm(_dols) 0 0 0  }
       foreach {thtm(_is) thtm(_st) thtm(_et) thtm(_pc) thtm(_pls)} $thtm(_dols) {  break  }
       set thtm(-hmap) [list %t $thtm(_pc) %a [lindex [split $thtm(_is) -] 1]]
       if {[info exists thtm(_pre)]} {  unset thtm(_pre)  }
       if {[info exists thtm(_post)]} {  unset thtm(_post)  }
       if {[info exists thtm(-xlink)]} {  unset thtm(-xlink)  }
       if {[info exists thtm(-hid1)]} {
         if {$thtm(-hid1) ne ""} {  set thtm(_newh1) ""  ;  set thtm(_pre) ""
           foreach thtm(_item) $thtm(-hid1) {
            if {[set thtm(_x) [string first #NX# $thtm(_item)]]>"-1"} {
              append thtm(_pre) #BR#[string range $thtm(_item) 0 [expr {$thtm(_x)-1}]]
              lappend thtm(_newh1) [string range $thtm(_item) [expr {$thtm(_x)+4}] end]
            } else {  append thtm(_pre) #BR#$thtm(_item)  ;  lappend thtm(_newh1) $thtm(_item)  }
           }
           set thtm(-hid1) $thtm(_newh1)  ;  set thtm(_pre) [string range $thtm(_pre) 4 end]
         }
         if {$thtm(-hid2) ne ""} {  set thtm(_newh2) ""  ;  set thtm(_post) ""
           foreach thtm(_item) $thtm(-hid2) {
            if {[set thtm(_x) [string first #NX# $thtm(_item)]]>"-1"} {
              append thtm(_post) #BR#[string range $thtm(_item) 0 [expr {$thtm(_x)-1}]]
              lappend thtm(_newh2) [string range $thtm(_item) [expr {$thtm(_x)+4}] end]
            } else {  append thtm(_post) #BR#$thtm(_item)  ;  lappend thtm(_newh2) $thtm(_item)  }
           }
           set thtm(-hid2) $thtm(_newh2)  ;  set thtm(_post) [string range $thtm(_post) 4 end]
         }

       }
       if {[info exists thtm(_hnow)]} {  unset thtm(_hnow)  }
       if {[info exists thtm(_fnow)]} {  unset thtm(_fnow)  }
       if {$thtm(_head) ne ""} {
         if {($thtm(_pc) eq "" || $thtm(_pc) eq "0") && [info exists thtm(_nhead)]} {
           set thtm(_hnow) [lindex $thtm(_nhead) 0]
         } elseif {$thtm(_pc) eq [llength $thtm(_pls)] && [info exists thtm(_ahead)]} {
           set thtm(_hnow) [lindex $thtm(_ahead) 0]
         } else {  set thtm(_hnow) [lindex $thtm(_head) 0]  }
         if {[llength $thtm(_head)]>"1"} {  set thtm(_head) [lreplace $thtm(_head) 0 0]  }
         if {[info exists thtm(_ahead)] && [llength $thtm(_ahead)]>"1"} {
             set thtm(_ahead) [lreplace $thtm(_ahead) 0 0]  }
         if {[info exists thtm(_nhead)] && [llength $thtm(_nhead)]>"1"} {
             set thtm(_nhead) [lreplace $thtm(_nhead) 0 0]  }
       }
       if {[info exists thtm(_foot)] && $thtm(_foot) ne ""} {
         if {($thtm(_pc) eq "" || $thtm(_pc) eq "0") && [info exists thtm(_nfoot)]} {
           set thtm(_fnow) [lindex $thtm(_nfoot) 0]
         } elseif {$thtm(_pc) eq [llength $thtm(_pls)] && [info exists thtm(_afoot)]} {
           set thtm(_fnow) [lindex $thtm(_afoot) 0]
         } else {  set thtm(_fnow) [lindex $thtm(_foot) 0]  }
         if {[llength $thtm(_foot)]>"1"} {  set thtm(_foot) [lreplace $thtm(_foot) 0 0]  }
         if {[info exists thtm(_afoot)] && [llength $thtm(_afoot)]>"1"} {
             set thtm(_afoot) [lreplace $thtm(_afoot) 0 0]  }
         if {[info exists thtm(_nfoot)] && [llength $thtm(_nfoot)]>"1"} {
             set thtm(_nfoot) [lreplace $thtm(_nfoot) 0 0]  }
       }
       foreach thtm(_var) {_hnow _fnow _pre _post} {
        if {[info exists thtm($thtm(_var))]} {  set thtm(_enow) $thtm($thtm(_var))
          if {[string first #L, $thtm(_enow)]>"-1"} {  set thtm(_enew) ""  ;  set thtm(_xfile) ""
            set thtm(_xlhid) 0  ;  set thtm(_dun) 0  ;  set thtm(_start) 0
            while {$thtm(_dun)=="0"} {   set thtm(_br) [string first #BR# $thtm(_enow) $thtm(_start)]
             if {$thtm(_br)=="-1"} {  set thtm(_nxln) [string range $thtm(_enow) $thtm(_start) end]
               set thtm(_start) end  ;  set thtm(_dun) 1
             } else {  set thtm(_nxln) [string range $thtm(_enow) $thtm(_start) [expr {$thtm(_br)-1}]]
               set thtm(_start) [expr {$thtm(_br)+4}]
             }
             if {[string match *#l,end#* [TStrLo $thtm(_nxln)]]} { set thtm(_xlhid) 0  ; set thtm(_xfile) ""
             } elseif {[string match *#l,x?_.* [TStrLo $thtm(_nxln)]]} { set thtm(_xlhid) 0  ; set thtm(_xfile) ""
               set thtm(_nxln) [split [TStrLo [string trim $thtm(_nxln) "# "]] ,.]
               foreach {thtm(-x) thtm(-z) thtm(-y)} $thtm(_nxln) {  break  }
               set thtm(-x) [string index $thtm(-z) 1]
               if {[TStrDig [string index $thtm(-y) 0]]} {  set thtm(-y) [lindex [split $thtm(-y) +-] 0]
                 if {![TStrDig $thtm(-y)] || ![info exists thtm(-x$thtm(-x)ls)]} {  set thtm(_xlhid) 1
                 } else {  set thtm(-z) $thtm(-x$thtm(-x)ls)
                   if {$thtm(-y)>[llength $thtm(-z)] || $thtm(-y)=="0"} {  set thtm(_xlhid) 1
                   } else {
                     lappend thtm(_xfile) %z [lindex $thtm(-z) [expr {$thtm(-y)-1}]] %a $thtm(-y)
                   }
                 }
               } else {
                 set thtm(_tmp1) [split $thtm(_is) -]  ;  set thtm(-x) [lindex $thtm(_tmp1) 0]
                 if {![info exists thtm(-x$thtm(-x)ls)]} {  set thtm(_xlhid) 1
                 } else {  set thtm(-z) $thtm(-x$thtm(-x)ls)
                   set thtm(_now) [lindex $thtm(_tmp1) 1]
                   if {[string match thi* $thtm(-y)]} {
                     if {$thtm(-usefl) eq "xhistory.html" || $thtm(_now)>[llength $thtm(-z)]} {
                       set thtm(_xlhid) 1
                     } else {
                       lappend thtm(_xfile) %z [lindex $thtm(-z) [expr {$thtm(_now)-1}]] %a $thtm(_now)
                     }
                   } elseif {[string match nex* $thtm(-y)]} {
                     if {[expr {$thtm(_now)+1}]>[llength $thtm(-z)]} {  set thtm(_xlhid) 1
                     } else {
                       lappend thtm(_xfile) %z [lindex $thtm(-z) $thtm(_now)] %a [expr {$thtm(_now)+1}]
                     }
                   } elseif {[string match bac* $thtm(-y)]} {
                     if {$thtm(_now)=="1"} {  set thtm(_xlhid) 1
                     } else {
                       lappend thtm(_xfile) %z [lindex $thtm(-z) [expr {$thtm(_now)-2}]] %a [expr {$thtm(_now)-1}]
                     }
                   } else {  set thtm(_xlhid) 1  }
                 }
               }
               if {$thtm(_xfile) ne ""} {  set thtm(_xst) [lindex [split [lindex $thtm(_xfile) 1] _.] 1]
                 set thtm(_xst) [HStartEnd $thtm(-x) $thtm(_xst)]
                 set thtm(_xet) [lindex $thtm(_xst) 1]  ;  set thtm(_xst) [lindex $thtm(_xst) 0]
               }
             } elseif {$thtm(_xfile) ne ""} {
               if {[string first %s $thtm(_nxln)]>"-1" || [string first %o $thtm(_nxln)]>"-1"} {
                 set thtm(_x) [string first %s $thtm(_nxln)]  ;  set thtm(_nstart) 0
                 set thtm(_y) [string first %o $thtm(_nxln)]  ;  set thtm(_nxnew) ""
                 while {$thtm(_x)>"-1" || $thtm(_y)>"-1"} {
                  if {$thtm(_x)>"-1" && $thtm(_y)=="-1"} {  set thtm(_nexut) $thtm(_x)
                  } elseif {$thtm(_y)>"-1" && $thtm(_x)=="-1"} {  set thtm(_nexut) $thtm(_y)
                  } elseif {$thtm(_y)<$thtm(_x)} {  set thtm(_nexut) $thtm(_y)
                  } else {  set thtm(_nexut) $thtm(_x)  }
                  if {[set thtm(_z) [string first %f [string range $thtm(_nxln) $thtm(_nstart) $thtm(_nexut)]]]>"-1"} {
                    if {$thtm(_z)>$thtm(_nstart)} {
                        append thtm(_nxnew) [string range $thtm(_nxln) $thtm(_nstart) [expr {$thtm(_z)-1}]]  }
                    set thtm(-fmt) [string range $thtm(_nxln) [expr {$thtm(_z)+2}] [expr {$thtm(_nexut)-1}]]
                  } else {
                    if {$thtm(_nexut)>$thtm(_nstart)} {
                        append thtm(_nxnew) [string range $thtm(_nxln) $thtm(_nstart) [expr {$thtm(_nexut)-1}]]  }
                    if {![info exists thtm(-fmt)]} {  set thtm(-fmt) "%B %e, %Y"  }
                  }
                  if {[string index $thtm(_nxln) [expr {$thtm(_nexut)+1}]] eq "s"} {
                    append thtm(_nxnew) [strftime $thtm(-fmt) $thtm(_xst)]
                  } elseif {[string index $thtm(_nxln) [expr {$thtm(_nexut)+1}]] eq "o"} {
                      append thtm(_nxnew) [strftime $thtm(-fmt) $thtm(_xet)]  }
                  if {[set thtm(_nstart) [expr {$thtm(_nexut)+2}]]<[string length $thtm(_nxln)]} {
                    set thtm(_x) [string first %s $thtm(_nxln) $thtm(_nstart)]
                    set thtm(_y) [string first %o $thtm(_nxln) $thtm(_nstart)]
                    if {$thtm(_x)=="-1" && $thtm(_y)=="-1"} {
                        append thtm(_nxnew) [string range $thtm(_nxln) $thtm(_nstart) end]  }
                  } else {  break  }
                 }
                 set thtm(_nxln) $thtm(_nxnew)
               }
               append thtm(_enew) #BR#[string map $thtm(_xfile) $thtm(_nxln)]
             } elseif {$thtm(_xlhid)=="0"} {  append thtm(_enew) #BR#$thtm(_nxln)  }
            }
            if {$thtm(_enew) eq ""} {  unset thtm($thtm(_var))  ;  continue  }
            set thtm(_enow) [string range $thtm(_enew) 4 end]  ; set thtm($thtm(_var)) $thtm(_enow)
          }
          if {[string first % $thtm(_enow)]>"-1"} {
            if {[string first %s $thtm(_enow)]>"-1" || [string first %o $thtm(_enow)]>"-1"} {
              set thtm(_x) [string first %s $thtm(_enow)]  ;  set thtm(_start) 0
              set thtm(_y) [string first %o $thtm(_enow)]  ;  set thtm(_enew) ""
              while {$thtm(_x)>"-1" || $thtm(_y)>"-1"} {
               if {$thtm(_x)>"-1" && $thtm(_y)=="-1"} {  set thtm(_nexut) $thtm(_x)
               } elseif {$thtm(_y)>"-1" && $thtm(_x)=="-1"} {  set thtm(_nexut) $thtm(_y)
               } elseif {$thtm(_y)<$thtm(_x)} {  set thtm(_nexut) $thtm(_y)
               } else {  set thtm(_nexut) $thtm(_x)  }
               if {[set thtm(_z) [string first %f [string range $thtm(_enow) $thtm(_start) $thtm(_nexut)]]]>"-1"} {
                 if {$thtm(_z)>$thtm(_start)} {
                     append thtm(_enew) [string range $thtm(_enow) $thtm(_start) [expr {$thtm(_z)-1}]]  }
                 set thtm(-fmt) [string range $thtm(_enow) [expr {$thtm(_z)+2}] [expr {$thtm(_nexut)-1}]]
               } else {
                 if {$thtm(_nexut)>$thtm(_start)} {
                     append thtm(_enew) [string range $thtm(_enow) $thtm(_start) [expr {$thtm(_nexut)-1}]]  }
                 if {![info exists thtm(-fmt)]} {  set thtm(-fmt) "%B %e, %Y"  }
               }
               if {[string index $thtm(_enow) [expr {$thtm(_nexut)+1}]] eq "s"} {
                 append thtm(_enew) [strftime $thtm(-fmt) $thtm(_st)]
               } elseif {[string index $thtm(_enow) [expr {$thtm(_nexut)+1}]] eq "o"} {
                 append thtm(_enew) [strftime $thtm(-fmt) $thtm(_et)]
               }
               if {[set thtm(_start) [expr {$thtm(_nexut)+2}]]<[string length $thtm(_enow)]} {
                 set thtm(_x) [string first %s $thtm(_enow) $thtm(_start)]
                 set thtm(_y) [string first %o $thtm(_enow) $thtm(_start)]
                 if {$thtm(_x)=="-1" && $thtm(_y)=="-1"} {
                    append thtm(_enew) [string range $thtm(_enow) $thtm(_start) end]  }
               } else {  break  }
              }
              set thtm(_enow) $thtm(_enew)
            }
            set thtm(_enow) [string map $thtm(-gmap) $thtm(_enow)]
            set thtm(_enow) [string map $thtm(-hmap) $thtm(_enow)]
            if {[string match *%#* $thtm(_enow)]} {
              set thtm(-z) [lindex [split [lindex $thtm(-chkls) 0] ,] 1]
              set thtm(_enow) [string map [list %# $thtm(-z)] $thtm(_enow)]
            }
            if {[string match *%%* $thtm(_enow)]} {
              if {$thtm(_pc)<"11"} {   set thtm(-z) 10
              } else {   set thtm(-z) [llength $thtm(_pls)]
                if {[string index $thtm(-z) end]>"0"} {  incr thtm(-z) 10
                    set thtm(-z) [string range $thtm(-z) 0 end-1]0  }
              }
              set thtm(_enow) [string map [list %% $thtm(-z)] $thtm(_enow)]
            }
            set thtm($thtm(_var)) $thtm(_enow)
          }
        }
       }
       if {[info exists thtm(_pre)]} {
         if {[string match *#BR#* $thtm(_pre)]} {  set thtm(_start) 0
           while {[set thtm(_br) [string first #BR# $thtm(_pre) $thtm(_start)]]>"-1"} {
            puts $thtm(-newfl) [string range $thtm(_pre) $thtm(_start) [expr {$thtm(_br)-1}]]
            set thtm(_start) [expr {$thtm(_br)+4}]
           }
           puts $thtm(-newfl) [string range $thtm(_pre) $thtm(_start) end]
         } else {  puts $thtm(-newfl) $thtm(_pre)  }   ;  unset thtm(_pre)
       }
       if {$thtm(_scnt)=="0" || [info exists thtm(-hid1)]} {
         if {[info exists thtm(_table)]} {
           puts $thtm(-newfl) "<table $thtm(_table) class=\"btable\">"
         } else {  puts $thtm(-newfl) "<table class=\"btable\">"  }
         if {![info exists thtm(_colgroups)]} {  set thtm(_colgroups) "1 2 3+"  }
         set thtm(_colgroups) [split $thtm(_colgroups)]
         set thtm(_x) 0  ;  set thtm(_y) 0
         foreach thtm(-temp) $thtm(_colgroups) {  set thtm(-temp) [split $thtm(-temp) ,]
          set thtm(-tem2) [split [lindex $thtm(-temp) 0] -]
          incr thtm(_x)  ;  incr thtm(_y)  ;  set thtm(_z) "<colgroup "
          if {$thtm(_y)==[llength $thtm(_colgroups)]} {  set thtm(-tem2) $thtm(_x)+
          } else {
            if {[string match *+* $thtm(-tem2)]} {  set thtm(-tem2) $thtm(_x)+
            } elseif {[llength $thtm(-tem2)]=="1"} {  set thtm(-tem2) $thtm(_x)
            } else {  set thtm(-tem2) [list $thtm(_x) [lindex $thtm(-tem2) 1]]
              if {![TStrDig [lindex $thtm(-tem2) 1]] || [lindex $thtm(-tem2) 1]<=[lindex $thtm(-tem2) 0]} {
                  set thtm(-tem2) $thtm(_x)  }
            }
          }
          if {$thtm(_x)<[llength $thtm(_cols)] && ([llength $thtm(-tem2)]>"1" || [string match *+ $thtm(-tem2)])} {
            set thtm(_cleft) [expr {[llength $thtm(_cols)]-($thtm(_x)-1)}]
            if {[llength $thtm(-tem2)]>"1"} {
              if {[lindex $thtm(-tem2) 1]>[llength $thtm(_cols)]} {
                append  thtm(_z) "span=\"$thtm(_cleft)\" "  ;  set thtm(_x) [llength $thtm(_cols)]
              } else {  set thtm(_x) [lindex $thtm(-tem2) 1]
                append  thtm(_z) "span=\"[expr {([lindex $thtm(-tem2) 1]-[lindex $thtm(-tem2) 0])+1}]\" "
              }
            } else {
              append  thtm(_z) "span=\"$thtm(_cleft)\" "  ;  set thtm(_x) [llength $thtm(_cols)]
            }
          }
          if {[llength $thtm(-temp)]>"1"} { append  thtm(_z) "width=\"[lindex $thtm(-temp) 1]\" " }
          puts $thtm(-newfl) "$thtm(_z)class=\"colg$thtm(_y)\"></colgroup>"
          if {$thtm(_x)>=[llength $thtm(_cols)]} {  break  }
         }
         if {$thtm(_shohed)=="2"} {  set thtm(_tmct) 0  ;  set thtm(_tmls) ""  ;  set thtm(_keep) 0
           foreach thtm(_tm2) $thtm(_cols) {  incr thtm(_tmct)  ;  set thtm(_tmp) <th
            if {$thtm(_tmct)<=$thtm(stych)} {  append thtm(_tmp) " class=\"th$thtm(_tmct)\""  }
            if {[llength $thtm(_tm2)]=="1"} {  append thtm(_tmp) "> </th>"
            } elseif {[lindex $thtm(_tm2) 0] eq ""} {  append thtm(_tmp) "> </th>"
            } else {  set thtm(_keep) 1  ;  append thtm(_tmp) ">[lindex $thtm(_tm2) 0]</th>"  }
            lappend thtm(_tmls) $thtm(_tmp)
           }
           if {$thtm(_keep)=="1"} {  puts $thtm(-newfl) "<tbody class=\"tcolhd\">"
             puts $thtm(-newfl) "<tr class=\"bcolhd\">"
             foreach thtm(_tmp) $thtm(_tmls) {  puts $thtm(-newfl) $thtm(_tmp)  }
             puts $thtm(-newfl) </tr>  ;  puts $thtm(-newfl) </tbody>
           }
         }
       }
       incr thtm(_scnt)
       if {[info exists thtm(_hnow)]} {  puts $thtm(-newfl) "<tbody class=\"thead\">"
         puts $thtm(-newfl) "<tr class=\"bhead\">"
         puts $thtm(-newfl) "<th colspan=\"[llength $thtm(_cols)]\" class=\"thd\">"
         if {[string match *#BR#* $thtm(_hnow)]} {  set thtm(_start) 0
           while {[set thtm(_br) [string first #BR# $thtm(_hnow) $thtm(_start)]]>"-1"} {
            puts $thtm(-newfl) [string range $thtm(_hnow) $thtm(_start) [expr {$thtm(_br)-1}]]
            set thtm(_start) [expr {$thtm(_br)+4}]
           }
           puts $thtm(-newfl) [string range $thtm(_hnow) $thtm(_start) end]</th>
         } else {  puts $thtm(-newfl) $thtm(_hnow)</th>  }
         puts $thtm(-newfl) </tr>  ;  puts $thtm(-newfl) </tbody>
       }
       if {$thtm(_shohed)=="1" && $thtm(_pc) ne "" && $thtm(_pc) ne "0"} {
         set thtm(_tmct) 0  ;  set thtm(_tmls) ""  ;  set thtm(_keep) 0
         foreach thtm(_tm2) $thtm(_cols) {  incr thtm(_tmct)  ;  set thtm(_tmp) <th
          if {$thtm(_tmct)<=$thtm(stych)} {  append thtm(_tmp) " class=\"th$thtm(_tmct)\""  }
          if {[llength $thtm(_tm2)]=="1"} {  append thtm(_tmp) "> </th>"
          } else {  set thtm(_keep) 1  ;  append thtm(_tmp) ">[lindex $thtm(_tm2) 0]</th>"  }
          lappend thtm(_tmls) $thtm(_tmp)
         }
         if {$thtm(_keep)=="1"} {  puts $thtm(-newfl) "<tbody class=\"tcolhd\">"
           puts $thtm(-newfl) "<tr class=\"bcolhd\">"
           foreach thtm(_tmp) $thtm(_tmls) {  puts $thtm(-newfl) $thtm(_tmp)  }
           puts $thtm(-newfl) </tr>  ;  puts $thtm(-newfl) </tbody>
         }
       }
       puts $thtm(-newfl) "<tbody class=\"tstats\">"
       if {$thtm(_pc) eq "" || $thtm(_pc) eq "0"} {  puts $thtm(-newfl) "<tr class=\"browone\">"
         puts $thtm(-newfl) "<td colspan=\"[llength $thtm(_cols)]\" class=\"tdn\">"
         puts $thtm(-newfl) "No Players To Show.</td>"  ;  puts $thtm(-newfl) </tr>
       } else {  set thtm(_swcnt) 1  ;  set thtm(_style) 1  ;  set thtm(_rank) 1
         set thtm(_col2) ""
         foreach thtm(_tm2) $thtm(_cols) {  lappend thtm(_col2) [lindex $thtm(_tm2) end]  }
         foreach thtm(_tl) $thtm(_pls) {
          set thtm(_map) [list %r $thtm(_rank) %p [lindex $thtm(_tl) 0] %c [lindex $thtm(_tl) 1]]
          lappend thtm(_map) %n [lindex $thtm(_tl) 2] %h [lindex $thtm(_tl) 3] %u [lindex $thtm(_tl) 4]
          if {$thtm(_style)=="1"} {  puts $thtm(-newfl) "<tr class=\"browone\">"
          } else {  puts $thtm(-newfl) "<tr class=\"browtwo\">"  }   ;  set thtm(_tmct) 0
          foreach thtm(_y) $thtm(_col2) {  incr thtm(_tmct)  ;  set thtm(_tmp) <td
           if {$thtm(_tmct)<=$thtm(stytd)} {  append thtm(_tmp) " class=\"td$thtm(_tmct)\""  }
           puts $thtm(-newfl) "$thtm(_tmp)>[string map $thtm(_map) $thtm(_y)]</td>"
          }
          puts $thtm(-newfl) </tr>  ;  incr thtm(_rank)
          if {$thtm(_swap)>"0"} {
            if {$thtm(_swcnt)==$thtm(_swap)} {  set thtm(_swcnt) 1
              if {$thtm(_style)=="1"} {  set thtm(_style) 2  } else {  set thtm(_style) 1  }
            } else {  incr thtm(_swcnt)  }
          }
         }
       }
       puts $thtm(-newfl) </tbody>
       if {[info exists thtm(_fnow)]} {  puts $thtm(-newfl) "<tbody class=\"tfoot\">"
         puts $thtm(-newfl) "<tr class=\"bfoot\">"
         puts $thtm(-newfl) "<th colspan=\"[llength $thtm(_cols)]\" class=\"tft\">"
         if {[string match *#BR#* $thtm(_fnow)]} {  set thtm(_start) 0
           while {[set thtm(_br) [string first #BR# $thtm(_fnow) $thtm(_start)]]>"-1"} {
            puts $thtm(-newfl) [string range $thtm(_fnow) $thtm(_start) [expr {$thtm(_br)-1}]]
            set thtm(_start) [expr {$thtm(_br)+4}]
           }
           puts $thtm(-newfl) [string range $thtm(_fnow) $thtm(_start) end]</th>
         } else {  puts $thtm(-newfl) $thtm(_fnow)</th>  }
         puts $thtm(-newfl) </tr>  ;  puts $thtm(-newfl) </tbody>
       }
       if {[llength $thtm(-chkls)]>"1"} {  set thtm(-chkls) [lreplace $thtm(-chkls) 0 0]  }
       if {[info exists thtm(-hid1)]} {  puts $thtm(-newfl) "</table>"  }
       if {[info exists thtm(_post)]} {
         if {[string match *#BR#* $thtm(_post)]} {  set thtm(_start) 0
           while {[set thtm(_br) [string first #BR# $thtm(_post) $thtm(_start)]]>"-1"} {
            puts $thtm(-newfl) [string range $thtm(_post) $thtm(_start) [expr {$thtm(_br)-1}]]
            set thtm(_start) [expr {$thtm(_br)+4}]
           }
           puts $thtm(-newfl) [string range $thtm(_post) $thtm(_start) end]
         } else {  puts $thtm(-newfl) $thtm(_post)  }
         unset thtm(_post)
       }
      }
      if {[string match #END#* $thtm(-gln)]} {  set thtm(-doing) body
        if {![info exists thtm(-hid1)]} {  puts $thtm(-newfl) "</table>"
        } else {  unset thtm(-hid1) thtm(-hid2) thtm(-hidcnt)  }
        array unset thtm _*
      } else {
        foreach thtm(_x) {_head _ahead _nhead _foot _afoot _nfoot} {
         if {[info exists thtm($thtm(_x))]} {  unset thtm($thtm(_x))  }
        }
      }
      continue
    } elseif {$thtm(-doing) eq "table"} {  set thtm(-err) 3.20
    } else {  set thtm(-gln) [string trimleft $thtm(-gln) #]
      if {[string match {*%[iso]*} $thtm(-gln)]} {
        set thtm(_u1) [string first %i $thtm(-gln)]  ;  set thtm(_start) 0
        set thtm(_u2) [string first %s $thtm(-gln)]  ;  set thtm(_gnew) ""
        set thtm(_u3) [string first %o $thtm(-gln)]
        while {$thtm(_u1)>"-1" || $thtm(_u2)>"-1" || $thtm(_u3)>"-1"} {
         set thtm(_uls) ""
         if {$thtm(_u1)>"-1"} {  lappend thtm(_uls) $thtm(_u1)  }
         if {$thtm(_u2)>"-1"} {  lappend thtm(_uls) $thtm(_u2)  }
         if {$thtm(_u3)>"-1"} {  lappend thtm(_uls) $thtm(_u3)  }
         set thtm(_uls) [lindex [lsort -integer $thtm(_uls)] 0]
         if {[set thtm(_z) [string first %f [string range $thtm(-gln) $thtm(_start) $thtm(_uls)]]]>"-1"} {
           if {$thtm(_z)>$thtm(_start)} {
               append thtm(_gnew) [string range $thtm(-gln) $thtm(_start) [expr {$thtm(_z)-1}]]  }
           set thtm(-fmt) [string range $thtm(-gln) [expr {$thtm(_z)+2}] [expr {$thtm(_uls)-1}]]
         } else {
           if {$thtm(_uls)>$thtm(_start)} {
               append thtm(_gnew) [string range $thtm(-gln) $thtm(_start) [expr {$thtm(_uls)-1}]]  }
           if {![info exists thtm(-fmt)]} {  set thtm(-fmt) "%B %e, %Y"  }
         }
         if {[string index $thtm(-gln) [expr {$thtm(_uls)+1}]] eq "i"} {
           append thtm(_gnew) [strftime $thtm(-fmt) [unixtime]]
         } elseif {[string index $thtm(-gln) [expr {$thtm(_uls)+1}]] eq "s"} {
           if {$thtm(-usefl) eq "history.html" || $thtm(-usefl) eq "xhistory.html"} {
             if {$thtm(-hdls) eq ""} {  append thtm(_gnew) :NONE:
             } else {
               if {$thtm(-dodwm) eq "d"} {
                 append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-hdls) 0]]
               } elseif {$thtm(-dodwm) eq "w"} {
                 if {![info exists thtm(-hwls)]} {  append thtm(_gnew) :NONE:
                 } else {  append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-hwls) 0]]  }
               } elseif {$thtm(-dodwm) eq "m"} {
                 if {![info exists thtm(-hmls)]} {  append thtm(_gnew) :NONE:
                 } else {  append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-hmls) 0]]  }
               }
             }
           } elseif {$thtm(-usefl) eq "active.html"} {
             if {$thtm(-dodwm) eq "d"} {
               append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-uinf) 2]]
             } elseif {$thtm(-dodwm) eq "w"} {
               append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-uinf) 4]]
             } elseif {$thtm(-dodwm) eq "m"} {
               append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-uinf) 6]]
             }
           } elseif {$thtm(-usefl) eq "ever.html"} {
             append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-uinf) 0]]
           } else {  append thtm(_gnew) :UNDEFINED:  }
         } elseif {[string index $thtm(-gln) [expr {$thtm(_uls)+1}]] eq "o"} {
           if {$thtm(-usefl) eq "history.html" || $thtm(-usefl) eq "xhistory.html"} {
             if {$thtm(-hdls) eq ""} {  append thtm(_gnew) :NONE:
             } else {
               if {$thtm(-dodwm) eq "d" && $thtm(-usefl) eq "history.html" && $thtm(shoda)>"1"} {
                 if {[llength $thtm(-hdls)]=="1"} {  append thtm(_gnew) :NONE:
                 } elseif {[llength $thtm(-hdls)]<$thtm(shoda)} {
                   append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-hdls) end]]
                 } else {
                   append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-hdls) [expr {$thtm(shoda)-1}]]]
                 }
               } elseif {$thtm(-dodwm) eq "d"} {
                 append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-uinf) 2]]
               } elseif {$thtm(-dodwm) eq "w"} {
                 if {![info exists thtm(-hwls)]} {  append thtm(_gnew) :NONE:
                 } elseif {$thtm(-usefl) eq "history.html" && $thtm(showe)>"1"} {
                   if {[llength $thtm(-hwls)]=="1"} {  append thtm(_gnew) :NONE:
                   } elseif {[llength $thtm(-hwls)]<$thtm(showe)} {
                     append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-hwls) end]]
                   } else {
                     append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-hwls) [expr {$thtm(showe)-1}]]]
                   }
                 } else {  set thtm(_adj) [lindex $thtm(-uinf) 4]  }
               } elseif {$thtm(-dodwm) eq "m"} {
                 if {![info exists thtm(-hmls)]} {  append thtm(_gnew) :NONE:
                 } elseif {$thtm(-usefl) eq "history.html" && $thtm(shomo)>"1"} {
                   if {[llength $thtm(-hmls)]=="1"} {  append thtm(_gnew) :NONE:
                   } elseif {[llength $thtm(-hmls)]<$thtm(shomo)} {
                     append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-hmls) end]]
                   } else {
                     append thtm(_gnew) [strftime $thtm(-fmt) [lindex $thtm(-hmls) [expr {$thtm(shomo)-1}]]]
                   }
                 } else {  set thtm(_adj) [lindex $thtm(-uinf) 6]  }
               }
               if {[info exists thtm(_adj)]} {
                 if {[set thtm(_z) [strftime %H $thtm(_adj)]] ne "00"} {
                    incr thtm(_adj) -[expr {$thtm(_z)*3600}]  }
                 if {[set thtm(_z) [strftime %M $thtm(_adj)]] ne "00"} {
                    incr thtm(_adj) -[expr {$thtm(_z)*60}]  }
                 if {[set thtm(_z) [strftime %S $thtm(_adj)]] ne "00"} {
                    incr thtm(_adj) -$thtm(_z)  }
                 append thtm(_gnew) [strftime $thtm(-fmt) [incr thtm(_adj) -1]]  ;  unset thtm(_adj)
               }
             }
           } elseif {$thtm(-usefl) eq "active.html" || $thtm(-usefl) eq "ever.html"} {
             append thtm(_gnew) [strftime $thtm(-fmt) [unixtime]]
           } else {  append thtm(_gnew) :UNDEFINED:  }
         }
         if {[set thtm(_start) [expr {$thtm(_uls)+2}]]<[string length $thtm(-gln)]} {
           set thtm(_u1) [string first %i $thtm(-gln) $thtm(_start)]
           set thtm(_u2) [string first %s $thtm(-gln) $thtm(_start)]
           set thtm(_u3) [string first %o $thtm(-gln) $thtm(_start)]
           if {$thtm(_u1)=="-1" && $thtm(_u2)=="-1" && $thtm(_u3)=="-1"} {
              append thtm(_gnew) [string range $thtm(-gln) $thtm(_start) end]  }
         } else {  break  }
        }
        set thtm(-gln) $thtm(_gnew)
      }
      set thtm(-gln) [string map $thtm(-gmap) $thtm(-gln)]
      if {[string match *%#* $thtm(-gln)]} {
        if {[info exists thtm(-dousrs)]} {  set thtm(-z) $thtm(-dousrs)
        } else {  set thtm(-z) [lindex [split [lindex $thtm(-chkls) 0] ,] 1]  }
        set thtm(-gln) [string map [list %# $thtm(-z)] $thtm(-gln)]
      }
      if {[string match *%%* $thtm(-gln)]} {  set thtm(-z) ""
        if {$thtm(-usefl) eq "active.html"} {
          if {$thtm(-dodwm) eq "d"} {
            if {!{info exists thtm(-adls)}} {  set thtm(-z) 10
            } else {  set thtm(-z) [llength $thtm(-adls)]0  }
          } elseif {$thtm(-dodwm) eq "w"} {
            if {!{info exists thtm(-awls)}} {  set thtm(-z) 10
            } else {  set thtm(-z) [llength $thtm(-awls)]0  }
          } elseif {$thtm(-dodwm) eq "m"} {
            if {!{info exists thtm(-amls)}} {  set thtm(-z) 10
            } else {  set thtm(-z) [llength $thtm(-amls)]0  }
          }
        } elseif {$thtm(-usefl) eq "ever.html"} {
          if {$thtm(-aels) eq ""} {  set thtm(-z) 10
          } else {  set thtm(-z) [llength $thtm(-aels)]0  }
        } else {  set thtm(-z) :UNDEFINED:  }
        set thtm(-gln) [string map [list %% $thtm(-z)] $thtm(-gln)]
      }
    }
  }
  if {$thtm(-gln) eq ""} {  continue  }
  if {$thtm(-err)>"0"} {
  } elseif {$thtm(-gln) eq " "} {  puts $thtm(-newfl) $thtm(-gln)
  } elseif {[string match -nocase {<head[ >]*} $thtm(-gln)]} {
    if {$thtm(-doing) ne ""} {  set thtm(-err) 1
    } else {  set thtm(-doing) head  ;  set thtm(-hcnt) 0
        set thtm(-x) ""  ;  set thtm(-y) ""  ;  puts $thtm(-newfl) $thtm(-gln)  }
  } elseif {[string match -nocase </head>* $thtm(-gln)]} {
    if {$thtm(-doing) ne "head"} {  set thtm(-err) 1
    } else {  set thtm(-doing) endhead  ;  puts $thtm(-newfl) $thtm(-gln)  }
  } elseif {[string match -nocase {<body[ >]*} $thtm(-gln)]} {
    if {$thtm(-doing) ne "endhead"} {  set thtm(-err) 1
    } else {  set thtm(-doing) body  ;  puts $thtm(-newfl) $thtm(-gln)  }
  } elseif {[string match -nocase </body>* $thtm(-gln)]} {
    if {$thtm(-doing) ne "body"} {  set thtm(-err) 2
    } else {  set thtm(-doing) endbody  ;  puts $thtm(-newfl) $thtm(-gln)  }
  } elseif {$thtm(-doing) eq "head" || $thtm(-doing) eq "title"} {
    if {[string match -nocase {<title[ >]*} $thtm(-gln)]} {
      if {$thtm(-x) ne ""} {  set thtm(-err) 1  } else {  set thtm(-x) [string trim $thtm(-gln)]  }
      if {![string match -nocase *</title> $thtm(-gln)]} {  set thtm(-doing) title  }
    } elseif {[string match -nocase *</title> $thtm(-gln)]} {  set thtm(-doing) head
      if {$thtm(-x) eq ""} {  set thtm(-err) 1  } else {  append thtm(-x) $thtm(-gln)  }
    } elseif {$thtm(-doing) eq "title"} {
      if {[string match -nocase *<meta* $thtm(-gln)] || [string match -nocase *</head* $thtm(-gln)]} {
        set thtm(-err) 1
      } else {  append thtm(-x) [string trim $thtm(-gln)]  }
    } elseif {[string match -nocase *<meta* $thtm(-gln)]} {
      if {![string match -nocase *generator*content* $thtm(-gln)]} {
          lappend thtm(-y) [string trim $thtm(-gln)]  }
    } else {
      if {$thtm(-hcnt)=="0"} {
        if {$thtm(-x) eq ""} {
          set thtm(-x) "<title>BogusTrivia Stats Page for $t2(chan) on $thtm(network)</title>"
        } elseif {![string match -nocase *bogustrivia* $thtm(-x)]} {
          set thtm(-z) [string first > $thtm(-x)]
          set thtm(-x) [string replace $thtm(-x) $thtm(-z) $thtm(-z) ">BogusTrivia: "]
        }
        puts $thtm(-newfl) $thtm(-x)  ;  set thtm(-hcnt) 1
        if {[set thtm(-z) [lsearch -all [TStrLo $thtm(-y)] *http-equiv*]] ne ""} {
          foreach thtm(-tnum) $thtm(-z) {  puts $thtm(-newfl) [lindex $thtm(-y) $thtm(-tnum)]  }
          foreach thtm(-tnum) [lsort -integer -decreasing $thtm(-z)] {
             set thtm(-y) [lreplace $thtm(-y) $thtm(-tnum) $thtm(-tnum)]  }
        }
        if {[set thtm(-z) [lsearch -all [TStrLo $thtm(-y)] *name*author*content*]] ne ""} {
          puts $thtm(-newfl) [lindex $thtm(-y) [lindex $thtm(-z) 0]]
          foreach thtm(-tnum) [lsort -integer -decreasing $thtm(-z)] {
             set thtm(-y) [lreplace $thtm(-y) $thtm(-tnum) $thtm(-tnum)]  }
        } else {  set thtm(-z) {<meta name="author" content="unknown_author" />}
            puts $thtm(-newfl) $thtm(-z)  }
        set thtm(-z) {<meta name="generator" content="BogusHTML 2.06.4 by SpiKe^^" />}
        puts $thtm(-newfl) $thtm(-z)
        if {[set thtm(-z) [lsearch -all [TStrLo $thtm(-y)] *name*description*content*]] ne ""} {
          set thtm(-tm2) {content="}  ;  set thtm(-tdesc) [lindex $thtm(-y) [lindex $thtm(-z) 0]]
          set thtm(-tnum) [expr {[string first $thtm(-tm2) $thtm(-tdesc)] + 8}]
          if {![string match -nocase *bogustrivia* [string range $thtm(-tdesc) $thtm(-tnum) end]]} {
            set thtm(-tm2) "[string range $thtm(-tdesc) 0 $thtm(-tnum)]BogusTrivia: "
            puts $thtm(-newfl) $thtm(-tm2)[string trim [string range $thtm(-tdesc) [incr thtm(-tnum)] end]]
          } else {  puts $thtm(-newfl) $thtm(-tdesc)  }
          foreach thtm(-tnum) [lsort -integer -decreasing $thtm(-z)] {
             set thtm(-y) [lreplace $thtm(-y) $thtm(-tnum) $thtm(-tnum)]  }
        } else {
          set thtm(-z) "<meta name=\"description\" content=\"BogusTrivia Stats Page for $t2(chan) on $thtm(network)\" />"
          puts $thtm(-newfl) $thtm(-z)
        }
        set thtm(-tkls) [list bogustrivia bogushtml $t2(chan) $thtm(network) tcl irc trivia game bot]
        if {[set thtm(-z) [lsearch -all [TStrLo $thtm(-y)] *name*keywords*content*]] ne ""} {
          set thtm(-tm2) {content="}  ;  set thtm(-tkws) [lindex $thtm(-y) [lindex $thtm(-z) 0]]
          set thtm(-tnum) [expr {[string first $thtm(-tm2) $thtm(-tkws)] + 8}]
          set thtm(-tm2) [string range $thtm(-tkws) 0 $thtm(-tnum)]
          set thtm(-tm3) [split [string range $thtm(-tkws) [incr thtm(-tnum)] end] ,]
          set thtm(-tkws) ""
          foreach thtm(-x) [lrange $thtm(-tm3) 0 end-1] {  lappend thtm(-tkws) [string trim $thtm(-x)]  }
          lappend thtm(-tkws) [string trim [lindex [split [lindex $thtm(-tm3) end] \"] 0]]
          foreach thtm(-x) $thtm(-tkls) {
           if {[lsearch -exact $thtm(-tkws) $thtm(-x)]=="-1"} {  append thtm(-tm2) "$thtm(-x), "  }
          }
          puts $thtm(-newfl) "$thtm(-tm2)[join $thtm(-tkws) ", "]\" />"
          foreach thtm(-tnum) [lsort -integer -decreasing $thtm(-z)] {
             set thtm(-y) [lreplace $thtm(-y) $thtm(-tnum) $thtm(-tnum)]  }
        } else {
          set thtm(-z) "<meta name=\"keywords\" content=\"[join $thtm(-tkls) ", "], eggdrop, windrop\" />"
          puts $thtm(-newfl) $thtm(-z)
        }
        if {$thtm(-y) ne ""} {
          foreach thtm(-x) $thtm(-y) {  puts $thtm(-newfl) $thtm(-x)  }
        }
        set thtm(-hcnt) 2
      }
      puts $thtm(-newfl) $thtm(-gln)
    }
  } elseif {$thtm(-doing) eq "body" || $thtm(-doing) eq "table"} {
    puts $thtm(-newfl) $thtm(-gln)
  } else {  puts $thtm(-newfl) $thtm(-gln)  }
  if {$thtm(-err)>"0"} {  break  }
 }
 close $thtm(-open)  ;  close $thtm(-newfl)
 if {$thtm(-err)=="0"} {
   if {$thtm(-tfl) eq "index.html" && $thtm(index) ne ""} {  set thtm(-tfl) $thtm(index)  }
   file delete $thtm(houtdir)$thtm(-tfl)
   file rename -force $thtm(htmdir)t2.html.tmp $thtm(houtdir)$thtm(-tfl)
 }
 file delete $thtm(htmdir)t2.html.tmp
}

array unset thtm  ;  unset t2(hdowat)
