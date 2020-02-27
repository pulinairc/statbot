#%v2064#%dt140814#%t-2.tcl#
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
## BogusTrivia 2.06.4.7 by SpiKe^^    The Ultimate Trivia Script ##
###################################################################
#                                                                 #
#                    ! USE AT YOUR OWN RISK !                     #
# If you'd like to Preview the script Visit Undernet #BogusTrivia #
#                                                                 #
#            Please report bugs or make comments at:              #
#                  irc: undernet: #pc-mIRC-help                   #
#                email: spike@mytclscripts.com                    #
#             web site: http://www.mytclscripts.com               #
#                                                                 #
#                        Support Forum:                           #
#            http://forum.egghelp.org/viewforum.php?f=3           #
#                                                                 #
#         View Extensive Info, FAQ Sheets and Screenshots         #
#                   http://mytclscripts.com                       #
#                                                                 #
###################################################################
# Eggdrop 1.6.21 Important Note!                                  #
#                                                                 #
# BogusTrivia is now Immune to the Eggdrop 1.6.21 utimers Bug!!!  #
#                                                                 #
# It may still be best to properly patch the flawed Eggdrop.      #
# If you want to utimer patch an Eggdrop 1.6.21 bot, you will     #
# need to apply the timerworkaround.patch.gz by Thommey available #
# on egghelp.org at  http://www.egghelp.org/files.htm#patches     #
# This patch fixes the utimers issue with the Eggdrop 1.6.21      #
###################################################################
#                                                                 #
#  Version 2.06.4.7 Release Notes:                                #
#                                                                 #
#  BogusTrivia is now Immune to the Eggdrop 1.6.21 utimers Bug!!! #
#                                                                 #
#  New Feature:  BogusLimits                                      #
#    BogusTrivia can now Limit the number of points any           #
#    one player can get in any one day (midnight to midnight).    #
#                                                                 #
#  New Advanced Custom Points Rounding Settings:                  #
#    By default, BogusTrivia chooses the best points rounding     #
#    plan, based on your points settings. Now you can choose your #
#    preferred points rounding settings for all question values.  #
#                                                                 #
# -> New Settings in This Release:  t-2.settings.tcl <-           #
#  1. Added five settings to support the new BogusLimits feature. #
#  2. Added four new Advanced Custom Points Rounding settings.    #
#  3. Added a setting to control the low end of the bonus points. #
#                                                                 #
# -> New Updated File:  t-2.tcl <-                                #
#  Patched BogusTrivia's game timer functions to where they now   #
#    ignore bad utimers created due to the Eggdrop utimers bug:)  #
#  Added code for the new BogusLimits feature & points settings.  #
#                                                                 #
# -> New Updated Files:  All 4 Included ReadMe Files <-           #
#  Added documentation for the new BogusLimits feature and        #
#    cleaned/updated all the ReadMe files.                        #
#                                                                 #
# -> BogusTrivia no longer includes a patch file for BogusHTML <- #
#  BogusHTML now has its own new full version release available!  #
#  Get the new BogusHTML 2.06.4 (BogusTrivia Html Page Maker)     #
#    from my web site at:  http://www.mytclscripts.com            #
#                                                                 #
###################################################################

###################################################################
###################################################################
##                  Included ReadMe Files                        ##
##                   !!  Please Read  !!                         ##
##                                                               ##
##   1. ReadMe.txt                                               ##
##   2. Installation.txt                                         ##
##   3. Commands.txt                                             ##
##   4. Important Notes.txt                                      ##
##                                                               ##
###################################################################
###################################################################

###################################################################
##                  BogusTrivia Game Features                    ##
###################################################################
#                                                                 #
#  1. Scores Reset Daily, Weekly, and Monthly.                    #
#  2. 8 Preset Colors Themes & Colorless.                         #
#  3. Custom Color Setup.                                         #
#  4. Includes a Question File.                                   #
#  5. Supports UWord, Scramble, Multiple-Choice, and KAOS.        #
#  6. Custom On|Off Triggers                                      #
#  7. User Flag Protected Commands                                #
#  8. Anti-Theft Feature On|Off                                   #
#  9. Unlimited Point Ranges                                      #
# 10. Bonus Questions On|Off w/ Point Ranges & Intervals          #
# 11. KAOS Questions On|Off w/ Point Ranges & Intervals           #
# 12. Custom Hints (trigger & timer setting)                      #
# 13. Show|Hide Channel Stats (10-20-30 players)                  #
# 14. Unlimited Custom Channel Ads                                #
# 15. Public Command to Repeat Question                           #
# 16. Custom Week Reset (mon-tues-wed)                            #
# 17. Custom KAOS Options                                         #
# 18. Unlimited Questions (subject to hd space or 1 million)      #
# 19. Will accept almost any q&a format or text file extension.   #
# 20. No line limit on the question files added. 3+ lines per file#
# 21. Error correction: removes bad questions & creates a badqes  #
#     file you may edit or discard.                               #
# 22. Flood control on all public commands.                       #
# 23. Adjustable timers to slow trivia if there are no players.   #
#     Can also Stop the game when no one is playing.              #
# 24. Track Users by handle, nick or username@host (or just nick) #
# 25. Player Matching System On or Off (stops points theft abuse) #
# 26. Accurate Scores Totals.                                     #
# 27. Support for non-english characters in answers               #
#     examples:  ñ á æ ø å                                        #
# 28. User file clean up. remove players not seen in x amount     #
#     of time                                                     #
# 29. Restart game play on rejoin                                 #
# 30. Scheduled backup of user and history files                  #
# 31. Show or Hide Answers for Questions & Kaos                   #
# 32. Channel Greet system with flood control                     #
# 33. Auto-Voice Top Players with exempts                         #
# 34. On-Join Flood Settings                                      #
# 35. On-Join Auto-Start the Game with Exempts                    #
# 36. Public Triggers for game stats and info                     #
# 37. Complete User Defined Public Triggers System                #
# 38. Daily Player Points Limiting                                #
#                                                                 #
###################################################################


###################################################################
##              BogusTrivia 2.06.4+ Version History              ##
###################################################################
#  Version 2.06.4.6 Release Notes:  (Patch for Version 2.06.4.5)  #
#                                                                 #
# -> New Updated File:  t-2.commands.tcl <-                       #
# Bug Fix:   (Thanks ivanov)                                      #
#  Fixes the issues with the public .info command & the           #
#    %t variable substitution code in user defined public replies.#
#    Example: User file created on 05/14/11 (.info total players) #
#  Fixes the %m variable substitution code issue in user defined  #
#    public relies.  %m = command used to trigger the reply       #
#                                                                 #
# -> New Updated File:  t-2.tcl <-                                #
# Bug Fix:                                                        #
#  Fixes an issue with the public: .stats <nick>  usage reply.    #
#                                                                 #
# -> New Updated Files:  t-2.settings.tcl  &  Commands.txt <-     #
#  Added documentation for the fixed %m variable substitution     #
#    code in user defined public relies.                          #
###################################################################
#  Version 2.06.4.5 Release Notes:                                #
#                                                                 #
# -> New Settings in v2.06.4.5 :  t-2.settings.tcl <-             #
#  1. Set separate user flags to turn the game off                #
#  2. Allows much lower point ranges for questions and kaos       #
#  3. Allows much lower pause times between questions and hints   #
#  4. Change all command prefixes with one setting                #
#  5. Change hint placeholder default character                   #
#  6. Allows longer questions (max character limit & multi-line)  #
#  7. Several new question presentation options                   #
#  8. Strip color codes from players answers                      #
#  9. Strip extra spaces from players answers                     #
# 10. New public commands: .info .webstats & .stats <nick>        #
# 11. User defined public triggers and replies options            #
# 12. Sample user defined commands: .commands .rules .time        #
#                                                                 #
# -> New Updated File:  t-2.tcl <-                                #
# Bug Fix:  Fixed an issue where public stats command reply       #
#  was showing the \002 bold code.                                #
# Added code to support new options and public commands.          #
#                                                                 #
# -> New Updated File:  t-2.commands.tcl <-                       #
# Added code to support the new public commands.                  #
#                                                                 #
# -> New Updated File:  bogus.ques.sample <-                      #
# Cleaned Many Doubles and Removed Bad Questions.                 #
#                                                                 #
# Upgrading from BogusTrivia v2.06.4 or older may also require:   #
# -> Updated File:  t-2.html.tcl  (Patch for BogusHTML)<-         #
#  NOTE: The Patched t-2.html.tcl & Upgrade Instructions readme   #
#        BogusHtml-2.06.2.beta4-Upgrade.txt is included with this #
#        script release in:  BogusHTML 2.06.2.beta4.Upgrade.zip   #
#                                                                 #
# Bug Fix:                                                        #
#  Fixed an issue that was keeping BogusHTML 2.06.2.beta3         #
#  from running at all with BogusTrivia 2.06.4 and above          #
#  NOTE: Use the included t-2.html.tcl to patch an existing       #
#        install of BogusHTML 2.06.2 beta3 to run with this       #
#        version of BogusTrivia.                                  #
###################################################################
#  Version 2.06.4.4 Release Notes:                                #
#                                                                 #
# -> New Updated File:  t-2.tcl <-                                #
# Bug Fix:   (Thanks speechles)                                   #
#  Fixed a script load issue causing the following error...       #
#    can't read "tclr(-emsg)": no such element in array           #
#                                                                 #
# -> New Updated File:  bogus.ques.sample <-                      #
# New Trivia Question File:                                       #
#  Add 12,000 New Questions to the BogusTrivia Database.          #
#                                                                 #
# -> New Updated File:  t-2.settings.tcl <-                       #
# File Maintenance Only, No New Settings were Added:              #
#  Cleaned and Organized the BogusTrivia Settings File.           #
#                                                                 #
#  No Other Files were Changed from the 2.06.4.2 Release!         #
#  No New Options or Settings were Added to this patch release.   #
###################################################################
#  Version 2.06.4.2 Release Notes:                                #
#                                                                 #
# -> New Updated File:  t-2.tcl <-                                #
# Bug Fix:                                                        #
#  Fixed an issue where the information displayed for public      #
#  stats & auto-voice was not always reset properly at midnight.  #
#                                                                 #
# -> New Updated File:  t-2.html.tcl <-                           #
# Bug Fix:                                                        #
#  Fixed an issue that was keeping BogusHTML 2.06.2.beta3         #
#  from running at all with BogusTrivia 2.06.4                    #
#  NOTE: Use the included t-2.html.tcl to patch an existing       #
#        install of BogusHTML 2.06.2 beta3 to run with this       #
#        version of BogusTrivia.                                  #
#                                                                 #
#  No Other Files were Changed from the 2.06.4 Release!           #
#  No New Options or Settings were Added to this patch release.   #
###################################################################
#  Version 2.06.4 Release Notes:                                  #
#                                                                 #
# -> New in v2.06.4 <-                                            #
# 1. Point Matching System On or Off (stops points theft abuse)   #
# 2. Show or Hide Answers for Questions & Kaos                    #
# 3. Channel Greet System with Flood Control                      #
# 4. Auto-Voice Top Players with Exempts                          #
# 5. On-Join Flood Settings                                       #
# 6. Game Can Stop When No One Is Playing                         #
# 7. Auto-Start Game On-Join with Exempts                         #
# 8. Public Commands to View Stats                                #
# 9. Custom On-Join Greet Colors                                  #
#                                                                 #
# Bug Fix:                                                        #
#  Game Play timings should now update and change with a .rehash  #
#  of the bot.                                                    #
###################################################################


###################################################################
##             BogusTrivia Extended Version History              ##
###################################################################
# -> Updates in v2.06.4.5 <-                                      #
#  1. Set separate user flags to turn the game off                #
#  2. Allows much lower point ranges for questions and kaos       #
#  3. Allows much lower pause times between questions and hints   #
#  4. Change all command prefixes with one setting                #
#  5. Change hint placeholder default character:  *               #
#  6. Allows longer questions (max character limit & multi-line)  #
#  7. Several new question presentation options                   #
#  8. Strip color codes from players answers                      #
#  9. Strip extra spaces from players answers                     #
# 10. New public commands: .info .webstats & .stats <nick>        #
# 11. User defined public triggers and replies options            #
# 12. Sample user defined commands: .commands .rules .time        #
# -> Updates in v2.06.4 <-                                        #
# 1. Point Matching System On or Off (stops points theft abuse)   #
# 2. Show or Hide Answers for Questions & Kaos                    #
# 3. Channel Greet System with Flood Control                      #
# 4. Auto Voice Top Players with Exempts                          #
# 5. On-Join Flood Settings                                       #
# 6. Game Can Stop When No One Is Playing                         #
# 7. Auto Start Game On-Join with Exempts                         #
# 8. Public Commands to View Stats                                #
# 9. Custom OnJoin Greet Colors                                   #
# -> Updates in v2.06.3.2 <-                                      #
# 1. Fixes the install & restart issues found in v2.06.3          #
# 2. Only the t-2.tcl was updated                                 #
# -> Updates in v2.06.3 <-                                        #
# 1. Contains all new files!                                      #
# 2. Smooth installation or upgrades                              #
# 3. Custom on|off triggers now accepted                          #
# 4. Show|Hide stats to the channel                               #
# 5. New settings to translate day and month names                #
# 6. Restart game play on rejoin bot to the channel               #
# 7. Scheduled backup of user and history files                   #
# -> Updates in v2.06.2.beta2 <-                                  #
# 1. Last release with bundled html page generator                #
# 2. New templates & CSS files                                    #
# 3. History stats, previous Days, Weeks and Months               #
# 4. /msg command .make to generate pages on demand               #
# -> Updates in v2.06.2.beta1 <-                                  #
# 1. Now supports html stat page generator                        #
# 2. Currently supports Active Stats Only                         #
# 3. Player stats for Today, This Week, This Month & Lifetime     #
# 4. Creates public_html folder and moves pages to it.            #
# -> Updates in v2.06.1 <-                                        #
# 1. Added support for non-english characters in answers          #
# -> Updates in v2.06 <-                                          #
# 1. Moved All Script Settings To File:   t-2.settings.tcl        #
# 2. Added Three Advanced Stats Options                           #
# 3. Fixed The Stats Bug That Allowed A User To Lose Their Stats  #
# 4. Will Fix Old User File,  Combines & Removes All Doubles      #
# 5. Fixed: Script Would Crash If Kaos Was On & Had No Kaos Files #
# -> Updates in v2.05.2 <-                                        #
# 1. Script Now Supports KAOS                                     #
# 2. Added Advanced KAOS Options                                  #
# 3. Additional Color Themes                                      #
# -> Updates in v2.04 <-                                          #
# 1. Script Now Supports UWord & Scrambles                        #
# 2. Now Supports Multiple-Choice Answers (example: "two" or "2") #
# 3. New Custom Colors Setup (choose your own colors:)            #
# 4. Anti-Theft Feature now with On-Off                           #
# 5. Added several other Advanced Settings                        #
###################################################################



############################################################################
#####   All BogusTrivia Script Settings In File:   t-2.settings.tcl    #####
#####                                                                  #####
##### EDIT THE SETTINGS IN: t-2.settings.tcl & UPLOAD IT WITH THIS TCL #####
############################################################################


############################################################################
### NO SCRIPT SETTINGS IN THIS FILE!!  NO SCRIPT SETTINGS IN THIS FILE!! ###
############################################################################
#######   !!  DO NOT EDIT THIS FILE  !!  DO NOT EDIT THIS FILE  !!   #######
############################################################################
###  !!  All BogusTrivia Script Settings In File:  t-2.settings.tcl  !!  ###
############################################################################



putlog "Loading \00310BogusTrivia\003 v2.06.4.7 (14Aug14) by SpiKe^^..."

set ttmp(pwdpath) [pwd]/  ;  set ttmp(scrpath) [file dirname [info script]]/
set ttmp(sysdir) t2/  ;  set ttmp(qesdir) t2/ques/
if {[set ttmp(temp) [info tclversion]]<"8.4"} {
  putlog "Tcl-version kanssa konfliktia. Tämä scripti vaatii Tcl:n version 8.4 tai suuremman."
  putlog "[info hostname] -serverissä on tällä hetkellä vanha Tcl-versio. $ttmp(temp) (PatchLevel: [info patchlevel])"
  putlog "Ota yhteyttä shelliisi ja käske päivittää tcl, tai hae scripti osoitteesta mytclscripts.com joka päivittää vanhan tcl:si."
  putlog "\00310BogusTrivia\003 ei ladattu!"  ;  unset ttmp  ;  return
}
if {![info exists t2(pwdpath)]} {  set t2(pwdpath) $ttmp(pwdpath)
  set t2(scrpath) $ttmp(scrpath)  ;  set t2(sfpath) $t2(pwdpath)$t2(scrpath)$ttmp(sysdir)
  set t2(qfpath) $t2(pwdpath)$t2(scrpath)$ttmp(qesdir)
}
if {[info exists t2(ver)]} {
  if {$t2(ver) eq "2.06.4" || [string match 2.06.4.* $t2(ver)]} {  set ttmp(temp) 0
  } else {  die "Trivia-scriptin päivitys: Botti pitää käynnistää uudelleen!"  }
}
if {![file exists $t2(sfpath)]} { file mkdir $t2(sfpath) }
if {![file exists [set ttmp(temp) $t2(pwdpath)$t2(scrpath)t-2.settings.tcl]]} {
    putlog "Couldn't find the BogusTrivia settings file: $t2(scrpath)t-2.settings.tcl"
    putlog "\00310BogusTrivia\003 game script not loaded!"  ;  unset ttmp  ;  return  }
source $ttmp(temp)
if {![info exists t2(chan)] || $t2(chan) eq "#YourChanneL"} {
    putlog "Please edit your BogusTrivia settings file: $t2(scrpath)t-2.settings.tcl"
    putlog "You Must set the channel to run the game in."
    putlog "\00310BogusTrivia\003 game script not loaded!"  ;  unset ttmp  ;  return  }

proc TStrInt {str} { return [string is integer -strict $str] }
proc TStrDig {str} { return [string is digit -strict $str] }
proc TStrLo {str} { return [string tolower $str] }
proc TStrTrSp {str} {  return [regsub -all -- {\s{2,}} [string trim $str] { }]  }

if {[file exists [set ttmp(temp) $t2(pwdpath)$t2(scrpath)t-2.commands.tcl]]} {
  if {[file exists $t2(sfpath)t2.commands]} {
      file rename -force $t2(sfpath)t2.commands $t2(sfpath)t2.commands.bak  }
  file rename -force $ttmp(temp) $t2(sfpath)t2.commands
} elseif {[file exists [set ttmp(temp) $t2(sfpath)t-2.commands.tcl]]} {
  if {[file exists $t2(sfpath)t2.commands]} {
      file rename -force $t2(sfpath)t2.commands $t2(sfpath)t2.commands.bak  }
  file rename -force $ttmp(temp) $t2(sfpath)t2.commands
}
set ttmp(cver) ""
if {[file exists $t2(sfpath)t2.commands]} {  set ttmp(open) [open $t2(sfpath)t2.commands]
  set ttmp(x) [string range [gets $ttmp(open)] 3 6]  ;  close $ttmp(open)
  if {[TStrDig $ttmp(x)] && $ttmp(x)>"2060" && $ttmp(x)<"2070"} {  set ttmp(cver) $ttmp(x)
  } else {  set ttmp(cver) 0  }
}
if {[file exists $t2(sfpath)t2.hist]} {  set ttmp(open) [open $t2(sfpath)t2.hist]
  set ttmp(ln1) [gets $ttmp(open)]  ;  close $ttmp(open)
  if {[string match ::N:* $ttmp(ln1)]} {
    if {$ttmp(cver) eq ""} {  set ttmp(stop) 1
    } elseif {$ttmp(cver)<"2063"} {  set ttmp(stop) 2
    } else {  set t2(_cm) h  ;  source $t2(sfpath)t2.commands  }
    if {[info exists ttmp(stop)]} {
      putlog "BogusTrivia History File Needs to be Updated. The code to do that is in the New Commands File."
      if {$ttmp(stop)=="1"} {
        putlog "Couldn't find t-2.tcl commands file: $t2(scrpath)t-2.commands.tcl"
      } else {  putlog "Existing t-2.tcl commands file needs to be replaced."  }
      putlog "Put the included t-2.commands.tcl file in $t2(scrpath) & rehash the bot."
      putlog "\00310BogusTrivia\003 game script not loaded!"  ;  unset ttmp  ;  return
    }
  }
}
set t2(ver) 2.06.4.7  ; set t2(-reldate) 1408018838  ; set t2(-test) 0  ; set ttmp(err) 0
if {[info exists t2(-newstart)]} {  set t2(-newstart) 0  } else {  set t2(-newstart) 1  }

if {$ttmp(cver) eq ""} {  set ttmp(err) 1
  putlog "Couldn't find t-2.tcl commands file: $t2(scrpath)t-2.commands.tcl"
} elseif {$ttmp(cver)=="0"} {  set ttmp(err) 2
  putlog "Corrupt t-2.tcl commands file: $t2(scrpath)t-2.commands.tcl"
} elseif {$ttmp(cver)<"2064"} {  set ttmp(err) 3
  putlog "Old t-2.tcl commands file: $t2(scrpath)t-2.commands.tcl"
}
if {$ttmp(err)>"0"} {  set ttmp(x) greet/voice
  if {$ttmp(err)<"3"} {  set ttmp(x) mix/greet/voice  }
  if {[info exists t2(autostart)] && $t2(autostart) ne "0"} {  append ttmp(x) /autostart  }
  if {[info exists t2(pubcmd)] && $t2(pubcmd) ne "0"} {  append ttmp(x) /public-commands  }
  set t2(greet) 0  ;  set t2(voice) 0  ;  set t2(autostart) 0  ;  set t2(pubcmd) 0
  putlog "All BogusTrivia $ttmp(x) functions disabled!"
  putlog "Put the included t-2.commands.tcl file in $t2(scrpath) & rehash the bot."
}

proc TFixSettins {} {  global t2
 set v(nls0) "randfil maxanti match restart custclr stripcolor stripspace"
 set v(nls1) "otherhist shonum shothe descend givansr givkaos ever tda twe tmo lda lwe lmo"
 set v(nls2) "history usrqes krest"
 set v(nds2) "0-2,2   0-2,2  0-2,1"
 set v(nls3) "voice autostart kstyle v-top3 v-top10 v-op l-match"
 set v(nds3) "0-3,3   0-3,2   0-3,1  0-3,3  0-3,3  0-3,3  0-3,3"
 set v(nls4) "maxhow bakhow v-mhow v-msg"
 set v(nds4) "1-2,2  1-2,1  1-2,2  1-2,2"
 set v(nls5) "greet color today yesterda bakupu bakuph newweek kbonus v-how v-max jflud jqtime"
 set v(nds5) "0-4,3 0-8,1 1-3,3  1-3,3   0-9,2  0-9,2   1-7,1  0-9,5  0-4,3 1-9,3 2-9,5 1-9,4"
 append v(nls5) " l-rnum roundques roundbonus roundkaos roundkbon"
 append v(nds5) " 0-9,1  0-9,0     0-9,0      0-9,0     0-9,0"
 set v(nls6) "lpoint hpoint maxbonus klpoint khpoint kbonlo kbonhi"
 set v(nds6) "5000   10000  15000    5000    10000   5000   10000"
 set v(nls7) "dobonus kaos pubcmd randad qslow pslow rest   oldusr v-min   limit minbonus"
 set v(nds7) "99,10  99,10 60,10  99,4   90,20 90,25 120,30 +,365 1000000,0 +,0  +,0"
 append v(nls7) " p-tmax-d p-tmax-w p-tmax-m p-tmax-e"
 append v(nds7) " 500,30   500,60   800,120  2000,250"
 set v(nls8) "qtime   ptime   ktime    maxchar    sqcnt  rqcnt   usrmax"
 set v(nds8) "6-60,15 6-60,20 6-90,20 200-999,400 3-99,6 5-99,15 200-+,500"
 append v(nls8) " a-delay a-same  g-same  v-same  jftime  p-activ"
 append v(nds8) " 5-30,10 1-60,10 1-60,10 1-60,10 5-60,20 1-365,7"
 set v(tls0) "mflag oflag sflag pflag pqflag hflag p-gflag p-tflag"
 set v(tls1) "a-xflag g-xflag v-xflag"
 set v(tls2) "chan on off upubq hint p-cmdpre m-cmdpre hintchar"
 set v(tls3) "p-mystat p-opstat p-info p-owner p-page p-top-d p-t20-d p-tmor-d"
 append v(tls3) " p-top-w p-t20-w p-tmor-w p-top-m p-t20-m p-tmor-m p-top-e p-t20-e p-tmor-e"
 set v(tls4) "a-xnick g-xnick v-xnick"
 set v(tls5) "rndlin g-say g-fludsay p-pwww l-stxt l-rtxt"
 set v(tlsdef) "on .t2 mflag o|o"
 foreach {na tx} [array get v] {  set v($na) [split [TStrTrSp $tx]]  }
 set v(nds0) ""  ;  foreach x $v(nls0) {  lappend v(nds0) 0-1,0  }
 set v(nds1) ""  ;  foreach x $v(nls1) {  lappend v(nds1) 0-1,1  }
 set y ""  ;  foreach x $v(nds6) {  lappend y 0-+,$x  }  ;  set v(nds6) $y
 set y ""  ;  foreach x $v(nds7) {  lappend y 0-$x  }  ;  set v(nds7) $y
 set allnums [list nls0 nls1 nls2 nls3 nls4 nls5 nls6 nls7 nls8]
 set allndef [list nds0 nds1 nds2 nds3 nds4 nds5 nds6 nds7 nds8]
 set alltxt [list tls0 tls1 tls2 tls3 tls4 tls5]
 set vnames "" ;  set vdeflts "" ;  set vlsname "" ;  set vlohi "" ;  set lid 0 ;  set doing n
 foreach x $allnums y $allndef {
  foreach z $v($x) q $v($y) {  lappend vnames $z  ;  lappend vlsname $x  ;  set q [split $q ,]
   lappend vdeflts [lindex $q 1]  ;  lappend vlohi [split [lindex $q 0] -]
  }
 }
 foreach x $alltxt {
  foreach z $v($x) {  lappend vnames $z ;  lappend vlsname $x
   if {[set y [lsearch $v(tlsdef) $z]]=="-1"} {  lappend vdeflts ""
   } else {  lappend vdeflts [lindex $v(tlsdef) [incr y]]  }
  }
 }
 foreach x $vnames y $vdeflts z $vlsname {
  if {![info exists t2($x)]} {  set t2($x) $y  }  ;  set q $t2($x)
  if {$z ne "tls5"} {  set q [split [TStrTrSp $q]]
    if {$z ne "tls4" && $z ne "tls3"} {  set q [lindex $q 0]  }
  }
  if {$doing eq "n"} {   foreach {lo hi} [lindex $vlohi $lid] {  break  }
    if {[TStrDig $q]} {  set q [string trimleft $q 0]  ;  if {$q eq ""} {  set q 0  }
      if {$q<$lo} {  set q $lo  } elseif {$hi ne "+" && $q>$hi} {  set q $hi  }
    } elseif {$q eq "" && $lo=="0" && $z ne "nls6"} {  set q 0  } else {  set q $y  }
  } elseif {$z eq "tls5"} {  set q [split $q "\n"]  ;  set new ""
    foreach tline $q {   if {$tline ne "" && $tline ne " "} { lappend new $tline }   }
    set q $new
  } elseif {$z eq "tls3" && $t2(p-cmdpre) ne "."} {  set new ""
    foreach trg $q {
     if {![string match .* $trg]} {  lappend new $trg
     } else {  lappend new "$t2(p-cmdpre)[string range $trg 1 end]"  }
    }
    set q $new
  }
  set t2($x) $q
  incr lid  ;  if {$doing=="n" && $lid==[llength $vlohi]} {  set doing t  }
 }
 foreach x $v(tls0) {  set y $t2($x)
  if {$x eq "sflag" && $y eq ""} {  set t2($x) $t2(oflag)
  } elseif {$y eq "" || $y eq "-" || $y eq "-|-"} {  set t2($x) -
  } elseif {[string first | $y]=="-1"} {  append t2($x) |$y  }
 }
 foreach x $v(tls1) {  set y $t2($x)
  if {$y ne ""} {
    if {[string first | $y]=="-1"} {  append y |$y  }
    set t2($x) [split $y |]
  }
  if {$t2($x) eq "- -"} {  set t2($x) ""  }
 }
 if {$t2(p-cmdpre) ne "."} {
   foreach x {on off} {  set y $t2($x)
    if {[string match .* $y]} {  set t2($x) "$t2(p-cmdpre)[string range $y 1 end]"  }
   }
 }
 if {[info exists t2(p-other)]} {  set all [split $t2(p-other) "\n"]  ;  lappend all ::END:
   set t2(p-other) ""  ;  set t2(p-otext) ""
   set trls ""  ;  set txls ""  ;  set flls ""  ;  set mpls ""
   set ntr ""  ;  set ntx ""  ;  set nfl ""  ;  set nmp p  ;  set cnt 0
   foreach tline $all {
    if {$tline ne "" && $tline ne " "} {
      if {[regexp {(:TRIGS:|:FLAGS:|:PRVMSG:|::END:)} $tline] && $ntx ne ""} {
        if {$ntr ne ""} {  incr cnt  ;  lappend txls $ntx  ;  lappend mpls $nmp
          if {$nmp eq "p" && $t2(p-cmdpre) ne "."} {  set new ""
            foreach y $ntr {
             if {![string match .* $y]} {  lappend new $y
             } else {  lappend new "$t2(p-cmdpre)[string range $y 1 end]"  }
            }
            set ntr $new
          } elseif {$nmp eq "m" && $t2(m-cmdpre) ne "."} {  set new ""
            foreach y $ntr {
             if {![string match .* $y]} {  lappend new $y
             } else {  lappend new "$t2(m-cmdpre)[string range $y 1 end]"  }
            }
            set ntr $new
          }
          lappend trls $ntr
          if {$nfl ne ""} {  lappend flls $nfl
          } elseif {$nmp eq "m"} {  lappend flls $t2(mflag)
          } else {  lappend flls $t2(p-gflag)  }
        }
        if {$tline eq "::END:" || $cnt=="25"} {  break  }
        set ntr ""  ;  set ntx ""  ;  set nfl ""  ;  set nmp p
      }
      if {[regexp {(:TRIGS:|:FLAGS:|:PRVMSG:)} $tline]} {  set tline [split [TStrTrSp $tline]]
        set doin ""  ;  set wat ""  ;  lappend tline ::END:
        foreach wd $tline {
         if {$doin ne "" && [regexp {(:TRIGS:|:FLAGS:|:PRVMSG:|::END:)} $wd]} {
           if {[string index $wd 0] ne ":"} {  set wd [string range $wd [string first : $wd] end]  }
           if {$doin eq ":TRIGS:" && $wat ne ""} {  set ntr [concat $ntr $wat]
           } elseif {$doin eq ":FLAGS:" && $wat ne ""} {  set nfl $wat
           } elseif {$doin eq ":FLAGS:"} {  set nfl -  } else {  set nmp m  }
           if {$wd eq "::END:"} {  break  }
         }
         if {[string match :TRIGS:* $wd]} {  set doin :TRIGS:
           if {![string match :TRIGS: $wd]} {  lappend wat [string range $wd 7 end]  }
         } elseif {[string match :FLAGS:* $wd]} {  set doin :FLAGS:
           if {![string match :FLAGS: $wd]} {  set wat [string range $wd 7 end]  }
         } elseif {[string match :PRVMSG:* $wd]} {  set doin :PRVMSG:
         } elseif {$doin eq ":TRIGS:"} {  lappend wat $wd
         } elseif {$doin eq ":FLAGS:"} {  set wat $wd  }
        }
      } elseif {$ntr ne ""} {  lappend ntx $tline  }
    }
   }
   if {$cnt>"0"} {  set t2(p-otrls) $trls  ;  set t2(p-otxls) $txls
     set t2(p-oflls) $flls  ;  set t2(p-ompls) $mpls
     set t2(p-other) [lindex $trls 0]  ;  set t2(p-otext) [lindex $txls 0]
   }
 } else {  set t2(p-other) ""  ;  set t2(p-otext) ""  }
}
TFixSettins  ;  rename TFixSettins ""

if {$t2(limit)>"0"} {  set t2(-lchek) 1
  if {$t2(l-rtxt) eq "" || $t2(l-rnum)=="0"} { set t2(l-rtxt) "" ; set t2(l-rnum) 0 }
  if {![info exists t2(-limls)]} {  set t2(-limls) ""  }
} else {  array unset t2 l-*  ;  array unset t2 -limls  ;  array unset t2 -lchek  }

if {$t2(hintchar)=="" || [string length $t2(hintchar)]>"1"} { set t2(hintchar) * }
set t2(savsettins) [list kaos $t2(kaos)]  ;  set t2(-setkaos) $t2(kaos)
if {$t2(rqcnt)<=$t2(sqcnt)} {  set t2(rqcnt) [expr {$t2(sqcnt)+3}]  }
if {$t2(randad)=="1"} {  set t2(randad) 2  }
foreach ttmp(x) {p-tmax-d p-tmax-w p-tmax-m p-tmax-e} {
 if {$t2($ttmp(x))<"30"} {  set t2($ttmp(x)) 30
 } elseif {![string match *0 $t2($ttmp(x))]} {  incr t2($ttmp(x)) 10
   set t2($ttmp(x)) [string range $t2($ttmp(x)) 0 end-1]0
 }
}
if {![info exists alltools_loaded]} {
  proc iscommand {cmd} {
   if {[string compare "" [info commands $cmd]]} {  return 1  }
   return 0
  }
}
if {$numversion<"1061700" && $t2(stripcolor)>"0"} {  set t2(stripcolor) 0
  putlog "BogusTrivia's strip color codes option requires Eggdrop 1.6.17 or higher."
  putlog "Your current Eggdrop version is:  [lindex [split $version] 0]"
  putlog "BogusTrivia strip color codes option disabled."
}
if {$t2(stripcolor)>"0" || $t2(stripspace)>"0"} {
  catch {unbind raw - PRIVMSG *raw:irc:msg}
  bind raw - PRIVMSG striprivmsg
  if {$t2(stripcolor)>"0" && $t2(stripspace)>"0"} {
    proc striprivmsg {f k a} {
     set a [TStrTrSp [string map [list \017 ""] [stripcodes abcgru $a]]]
     set tls [split $a :]  ;  set txt [lindex $tls 1]
     if {[string index $txt 0] eq " "} {  set txt [string range $txt 1 end]
       set a [join [lreplace $tls 1 1 $txt] :]
     }
     *raw:irc:msg $f $k $a
    }
  } elseif {$t2(stripcolor)>"0"} {
    proc striprivmsg {f k a} {
     set a [string map [list \017 ""] [stripcodes abcgru $a]]
     *raw:irc:msg $f $k $a
    }
  } else {
    proc striprivmsg {f k a} {
     set a [TStrTrSp $a]  ;  set tls [split $a :]  ;  set txt [lindex $tls 1]
     if {[string index $txt 0] eq " "} {  set txt [string range $txt 1 end]
       set a [join [lreplace $tls 1 1 $txt] :]
     }
     *raw:irc:msg $f $k $a
    }
  }
} elseif {[iscommand striprivmsg]} {  rename striprivmsg ""
  catch {unbind raw - PRIVMSG striprivmsg}  ;  bind raw - PRIVMSG *raw:irc:msg
}

proc TChkPoint {} {  global t2
 lappend loopls q lpoint hpoint $t2(roundques) b minbonus maxbonus $t2(roundbonus)
 lappend loopls k klpoint khpoint $t2(roundkaos) kb kbonlo kbonhi $t2(roundkbon)
 foreach {doin lnam hnam round} $loopls {  set lo $t2($lnam)  ;  set hi $t2($hnam)
   if {$doin eq "b"} {
     if {$lo<"1"} {  set lo $t2(hpoint)  ;  set t2($lnam) $lo  }
     if {$hi<=$lo} {  set hi [expr {$lo+1}]  ;  set t2($hnam) $hi  ;  set t2(dobonus) 0  }
   } else {
     if {$lo<"1"} {  set lo 1  ;  set t2($lnam) 1  }
     if {$hi<$lo} {  set hi $lo  ;  set t2($hnam) $hi  }
   }
   set t2(-round$doin) 0  ;  set range [expr {$hi-$lo}]  ;  set cnt 6
   while {$cnt>"0"} {  set z [string repeat 0 $cnt]
    if {$cnt>"2"} {  set x 19$z  } else {  set x 9$z  }
    if {[string match *?$z $lo] && [string match *?$z $hi] && $range>=$x} {
      set t2(-round$doin) $cnt  ;  break
    }
    incr cnt -1
   }
   if {$round=="1"} {  set t2(-round$doin) 0
   } elseif {$round>"1"} {  incr round -1  ;  set cnt 8
     while {$cnt>"0"} {  set z [string repeat 9 $cnt]
      if {$round>=$cnt && $hi>$z} {  set t2(-round$doin) $cnt  ;  break  }
      incr cnt -1
     }
   }
 }
}
TChkPoint  ;  rename TChkPoint ""

foreach ttmp(x) {qslow pslow rest} {
 if {$t2($ttmp(x))>"0" && $t2($ttmp(x))<"6"} { set t2($ttmp(x)) 6 }
}
if {$t2(qslow)=="0" || $t2(pslow)=="0"} { set t2(qslow) 0 ; set t2(pslow) 0 ; set t2(rest) 0 }
if {$t2(qslow)<$t2(qtime) && $t2(qslow)>"0"} { set t2(qslow) $t2(qtime) }
if {$t2(pslow)<$t2(ptime) && $t2(pslow)>"0"} { set t2(pslow) $t2(ptime) }
if {$t2(rest)<$t2(qslow) && $t2(rest)>"0"} {  set t2(rest) $t2(qslow)  }
if {$t2(rest)<$t2(pslow) && $t2(rest)>"0"} {  set t2(rest) $t2(pslow)  }
if {$t2(kaos)>"0"} {
  if {$t2(ktime)<$t2(qtime)} {  set t2(ktime) $t2(qtime)  }
}
set t2(-lgests) 1
if {$t2(today)>"1" && ($t2(ever)>"0" || $t2(tda)>"0" || $t2(twe)>"0" || $t2(tmo)>"0")} {
  set t2(-lgests) $t2(today)
}
if {$t2(-lgests)<"3" && $t2(yesterda)>"1" && ($t2(lda)>"0" || $t2(lwe)>"0" || $t2(lmo)>"0")} {
  if {$t2(yesterda)>$t2(-lgests)} {  set t2(-lgests) $t2(yesterda)  }
}
if {$t2(-lgests)=="1" && $t2(history)=="2"} {  set t2(-lgests) 2  }
if {$t2(-lgests)=="3"} {
  if {$t2(ptime)<"11"} {  set t2(stime) 2
  } elseif {$t2(ptime)<"14"} {  set t2(stime) 3  } else {  set t2(stime) 4  }
  if {$t2(pslow)>"0"} {
    if {$t2(pslow)<"11"} {  set t2(sslow) 2
    } elseif {$t2(pslow)<"14"} {  set t2(sslow) 3  } else {  set t2(sslow) 4  }
  }
  if {$t2(rest)>"0"} {
    if {$t2(rest)<"11"} {  set t2(srest) 2
    } elseif {$t2(rest)<"14"} {  set t2(srest) 3  } else {  set t2(srest) 4  }
  }
} elseif {$t2(-lgests)=="2"} {
  if {$t2(ptime)<"8"} {  set t2(stime) 2
  } elseif {$t2(ptime)<"10"} {  set t2(stime) 3  } else {  set t2(stime) 4  }
  if {$t2(pslow)>"0"} {
    if {$t2(pslow)<"8"} {  set t2(sslow) 2
    } elseif {$t2(pslow)<"10"} {  set t2(sslow) 3  } else {  set t2(sslow) 4  }
  }
  if {$t2(rest)>"0"} {
    if {$t2(rest)<"8"} {  set t2(srest) 2
    } elseif {$t2(rest)<"10"} {  set t2(srest) 3  } else {  set t2(srest) 4  }
  }
} else {  set t2(stime) 4  ;  set t2(sslow) 4  ;  set t2(srest) 4  }
if {![info exists t2(-htime)] || ![info exists t2(-ptime)] || ![info exists t2(-stime)]} {
  set t2(-htime) $t2(qtime)  ;  set t2(-ptime) $t2(ptime)  ;  set t2(-stime) $t2(stime)
}
if {$t2(p-pwww) ne ""} {  set t2(p-pwww) [join $t2(p-pwww)]  }
if {$t2(oldusr)>"0" && $t2(oldusr)<"45"} { set t2(oldusr) 45 }
if {$t2(rndlin) eq ""} {  set t2(randad) 0  }
if {$t2(randad)=="0"} {  set t2(rndlin) ""  }
if {$t2(bakhow)=="2" && $t2(bakupu)=="1"} {  set t2(bakupu) 2  }
if {$t2(custclr)=="0" && $t2(color)=="0" && $t2(randfil)!="0"} { set t2(randfil) 0 }
if {$t2(off) eq ""} {  set t2(off) $t2(on)  }
foreach ttmp(x) [binds TOnOff] {
 foreach {ttmp(t) ttmp(f) ttmp(n) ttmp(h) ttmp(p)} $ttmp(x) {  break  }
 unbind $ttmp(t) $ttmp(f) $ttmp(n) $ttmp(p)
}
foreach ttmp(x) [binds TAdd] {
 foreach {ttmp(t) ttmp(f) ttmp(n) ttmp(h) ttmp(p)} $ttmp(x) {  break  }
 unbind $ttmp(t) $ttmp(f) $ttmp(n) $ttmp(p)
}
foreach ttmp(x) [binds TMix] {
 foreach {ttmp(t) ttmp(f) ttmp(n) ttmp(h) ttmp(p)} $ttmp(x) {  break  }
 unbind $ttmp(t) $ttmp(f) $ttmp(n) $ttmp(p)
}
foreach ttmp(x) [binds TJoin] {
 foreach {ttmp(t) ttmp(f) ttmp(n) ttmp(h) ttmp(p)} $ttmp(x) {  break  }
 unbind $ttmp(t) $ttmp(f) $ttmp(n) $ttmp(p)
}
if {$t2(off) ne $t2(on)} {  bind pubm $t2(sflag) "$t2(chan) $t2(off)" TOnOff  }
bind pubm $t2(oflag) "$t2(chan) $t2(on)" TOnOff
if {$t2(m-cmdpre) ne "."} {  bind msgm $t2(mflag) $t2(m-cmdpre)add* TAdd
  bind msg $t2(mflag) $t2(m-cmdpre)mix TMix
} else {  bind msgm $t2(mflag) .add* TAdd  ;  bind msg $t2(mflag) .mix TMix  }

if {$t2(greet) ne "0"} {  ;###### ALL ON-JOIN GREETING LANGUAGE TEXT ######

## greet 1 unknown person (publicly) ###
set t2(G01) {
%g
}  ;## END - greet 1 unknown person (publicly) ###

## greet 1 unknown person (privatly) ###
set t2(G11) {
%g
}  ;## END - greet 1 unknown person (privatly) ###

## greet multiple persons (always public) ###
set t2(G02) {
%g
}  ;## END - greet multiple persons (always public) ###

## greet 1 known player (publicly) ###
set t2(G21) {
%g
%3 %n's Stats: %4 Points (answers) %d%w%mTotal Ever: %5 %e 
}  ;## END - greet 1 known player (publicly) ###

## greet 1 known player (privatly) ###
set t2(G31) {
%g
%3 Your Stats: %4 Points (answers) %d%w%mTotal Ever: %5 %e 
}  ;## END - greet 1 known player (privatly) ###

  set t2(G71) "" ; set t2(G72) "" ; set t2(G73) "" ; set t2(G74) ""
  set t2(G78) "" ; set t2(G79) "" ; set t2(G81) "" ; set t2(G82) ""
  set t2(G83) "" ; set t2(G84) "" ; set t2(G85) "" ; set t2(G86) ""
  set t2(G91) "Today: %5 #%rd %pd (%qd) %4 "
  set t2(G92) ""
  set t2(G93) "This Week: %5 #%rw %pw (%qw) %4 "
  set t2(G94) ""
  set t2(G95) "This Month: %5 #%rm %pm (%qm) %4 "
  set t2(G96) ""
  set t2(G97) "#%re %pe (%qe)"
  set t2(G98) "none"
}  ;###### END -  ALL ON-JOIN GREETING LANGUAGE TEXT ######

if {$t2(voice) ne "0" && $t2(v-how) ne "0"} {  ;##### ALL SAY PLAYER WAS VOICED LANGUAGE TEXT #####

## say voiced 1 player on-join (publicly) ###
set t2(V01) {
%4 ->%2 %n %1has been%2 Auto-Voiced %1 for being a%3 %z Top %y Player %1!!! %4<- 
}  ;## END - say voiced 1 player on-join (publicly) ###

## say voiced 1 player on-join (privatly) ###
set t2(V11) {
%4 ->%2 You %1have been%2 Auto-Voiced %1 for being a%3 %z Top %y Player %1!!! %4<- 
}  ;## END - say voiced 1 player on-join (privatly) ###

## say voiced multiple players on-join (always public) ###
set t2(V02) {
%4 ->%2 [%n] %1have been%2 Auto-Voiced %1 for being%3 %z Top %y Players %1!!! %4<- 
}  ;## END - say voiced multiple players on-join (always public) ###

## say voiced 1 active player (publicly) ###
set t2(V21) {
%4 ->%2 %n %1has been%2 Auto-Voiced %1 for being a%3 %z Top %y Player %1!!! %4<- 
}  ;## END - say voiced 1 active player (publicly) ###

## say voiced 1 active player (privatly) ###
set t2(V31) {
%4 ->%2 You %1have been%2 Auto-Voiced %1 for being a%3 %z Top %y Player %1!!! %4<- 
}  ;## END - say voiced 1 active player (privatly) ###

  set t2(V81) "" ;  set t2(V82) "" ;  set t2(V83) ""
  set t2(V84) "" ;  set t2(V85) "" ;  set t2(V86) ""
  set t2(V91) "/"
  set t2(V92) "Weekly"
  set t2(V93) "Monthly"
}  ;###### END -  ALL SAY PLAYER WAS VOICED LANGUAGE TEXT ######

if {$t2(autostart) ne "0"} {  ;###### ALL ON-JOIN AUTO START LANGUAGE TEXT ######

## Trivia starting in 'x' seconds, get ready!!! (public) ###
set t2(A01) {%1 BogusTrivia starting in %x seconds, get ready!!! }

}  ;###### END -  ALL ON-JOIN AUTO START LANGUAGE TEXT ######

if {$t2(pubcmd)>"0"} {  ;###### ALL PUBLIC COMMANDS LANGUAGE TEXT ######

## Top 10 players taday ###
set t2(P01) {%1 TODAYS Top 10 - %x}

## Top 11-20 players taday ###
set t2(P02) {%1 TODAYS Top 11-20: - %x}

## Top daily players above 20 ###
set t2(P03) {%1 TODAYS Top %s-%e: - %x}

## Top daily players - stats for each nick ###
set t2(P04) {%2 #%r: %3 %n %p }

## Top 10 players this week ###
set t2(P11) {%1 This WEEKS Top 10 - %x}

## Top 11-20 players this week ###
set t2(P12) {%1 This WEEKS Top 11-20: - %x}

## Top weekly players above 20 ###
set t2(P13) {%1 This WEEKS Top %s-%e: - %x}

## Top weekly players - stats for each nick ###
set t2(P14) {%2 #%r: %3 %n %p }

## Top 10 players this month ###
set t2(P21) {%1 This MONTHS Top 10 - %x}

## Top 11-20 players this month ###
set t2(P22) {%1 This MONTHS Top 11-20: - %x}

## Top monthly players above 20 ###
set t2(P23) {%1 This MONTHS Top %s-%e: - %x}

## Top monthly players - stats for each nick ###
set t2(P24) {%2 #%r: %3 %n %p }

## Top 10 players ever ###
set t2(P31) {%1 TOP 10 PLAYERS - %x}

## Top 11-20 players ever ###
set t2(P32) {%1 Top PLAYERS 11-20: - %x}

## Top players ever above 20 ###
set t2(P33) {%1 Top PLAYERS %s-%e: - %x}

## Top players ever - stats for each nick ###
set t2(P34) {%2 #%r: %3 %n %p }

## !owner reply text ###
set t2(P41) {%1 %s v%v by %a (%o) - www.mytclscripts.com }

## !webstats reply text ###
set t2(P42) {%1 See BogusTrivia web statistics at: %w }

## !info reply text ###
set t2(P45) {
%3 %s v%v by %a (%o) - www.mytclscripts.com 
%1 The user file was created on %u (%t total players). 
%1 %q Questions & %k Kaos in the Datebase (%z total). 
%1 Current Game/Server Time: %f%c%i. 
}
set t2(P46) {}

## !mystats reply to known player ###
set t2(P50) {%1 %n's Stats: %2 Points (answers) %d%w%mTotal Ever: %3 %e }

## !mystats reply to unknown player (set empty to not reply to unknown player) ###
set t2(P51) {}

  set t2(P52) "Today: %3 #%rd %pd (%qd) %2 "
  set t2(P53) ""
  set t2(P54) "This Week: %3 #%rw %pw (%qw) %2 "
  set t2(P55) ""
  set t2(P56) "This Month: %3 #%rm %pm (%qm) %2 "
  set t2(P57) ""
  set t2(P58) "#%re %pe (%qe)"
  set t2(P59) "none"

## !stats <nick> : reply for known player ###
set t2(P60) {%1 %n's Stats: %2 Points (answers) %d%w%mTotal Ever: %3 %e }

## !stats <nick> : reply for unknown player (set empty to not reply for unknown player) ###
set t2(P61) {}

  set t2(P62) "Today: %3 #%rd %pd (%qd) %2 "
  set t2(P63) ""
  set t2(P64) "This Week: %3 #%rw %pw (%qw) %2 "
  set t2(P65) ""
  set t2(P66) "This Month: %3 #%rm %pm (%qm) %2 "
  set t2(P67) ""
  set t2(P68) "#%re %pe (%qe)"
  set t2(P69) "none"

## !stats nick : reply for no <nick> argument (set empty to not reply for no <nick> argument) ###
set t2(P70) {
%2 Incorrect Usage Of The %3%m%2 Command. You %3Must%2 Provide A Nick. 
%2 The Correct Usage For This Command Is: %3 %m SomeonesNick  
}

}  ;###### END -  ALL PUBLIC COMMANDS LANGUAGE TEXT ######

set ttmp(allg) "G01 G02 G11 G21 G31 G81 G82 G83 G84 G85 G86"
append ttmp(allg) " G71 G72 G73 G74 G78 G79 G91 G92 G93 G94 G95 G96 G97 G98"
foreach ttmp(x) $ttmp(allg) {
 if {![info exists t2($ttmp(x))]} {  set t2($ttmp(x)) ""  }
}
append ttmp(allg) " g-xflag g-xnick g-same"
if {$t2(greet) ne "0"} {
  foreach ttmp(x) {G01 G11 G02 G21 G31} {  set ttmp(y) [split $t2($ttmp(x)) "\n"] ;  set ttmp(z) ""
   if {$ttmp(x) eq "G02"} {  set ttmp(g) $t2(g-fludsay)  } else {  set ttmp(g) $t2(g-say)  }
   foreach ttmp(l) $ttmp(y) {
    if {$ttmp(l) ne "" && $ttmp(l) ne " "} {
      if {[set ttmp(f) [string first %g $ttmp(l)]]>"-1"} {
        if {[llength $ttmp(g)]>"1"} {  set ttmp(num) 0
          foreach ttmp(el) $ttmp(g) {  incr ttmp(num)
           if {$ttmp(num)=="1"} {
             if {$ttmp(f)=="0"} {  lappend ttmp(z) $ttmp(el)
             } else {  lappend ttmp(z) [string range $ttmp(l) 0 [expr {$ttmp(f)-1}]]$ttmp(el)  }
           } elseif {$ttmp(num)==[llength $ttmp(g)]} {  incr ttmp(f)
             if {$ttmp(f)==[string length $ttmp(l)]} {  lappend ttmp(z) $ttmp(el)
             } else {  lappend ttmp(z) $ttmp(el)[string range $ttmp(l) [expr {$ttmp(f)+1}] end]  }
           } else {  lappend ttmp(z) $ttmp(el)  }
          }
        } else {  lappend ttmp(z) [string map [list %g [join $ttmp(g)]] $ttmp(l)]  }
      } else {  lappend ttmp(z) $ttmp(l)  }
    }
   }
   set t2($ttmp(x)) $ttmp(z)
  }
}
unset t2(g-say) t2(g-fludsay)
foreach ttmp(x) {gr1 gr2 gstat gsta2 gsta3} {
 if {![info exists tscl($ttmp(x))]} {  set tscl($ttmp(x)) ""  }
}
if {$t2(greet)>"0"} {
  if {$t2(greet)<"3" && $t2(G11) eq "" && $t2(G31) eq ""} {  set t2(greet) 0  }
  if {$t2(greet)>"2" && $t2(G01) eq "" && $t2(G21) eq ""} {  set t2(greet) 0  }
}
if {$t2(greet)=="0"} {
  foreach ttmp(x) $ttmp(allg) {  unset t2($ttmp(x))  }
  unset tscl(gr1) tscl(gr2) tscl(gstat) tscl(gsta2) tscl(gsta3)
  if {[info exists t2(-gls)]} {  unset t2(-gls) t2(-lastgnk) t2(-lastgut)  }
}

foreach ttmp(x) {V01 V02 V11 V21 V31 V81 V82 V83 V84 V85 V86 V91 V92 V93} {
 if {![info exists t2($ttmp(x))]} {  set t2($ttmp(x)) ""  }
}
foreach ttmp(x) {vo1 vo2 vo3 vo4} {
 if {![info exists tscl($ttmp(x))]} {  set tscl($ttmp(x)) ""  }
}
if {$t2(voice) ne "0" && $t2(v-how) ne "0"} {
  foreach ttmp(x) {V01 V11 V02 V21 V31} {  set ttmp(y) [split $t2($ttmp(x)) "\n"] ;  set ttmp(z) ""
   foreach ttmp(l) $ttmp(y) {
    if {$ttmp(l) ne "" && $ttmp(l) ne " "} { lappend ttmp(z) $ttmp(l) }
   }
   set t2($ttmp(x)) $ttmp(z)
  }
}
if {$t2(v-top3)=="0" && $t2(v-top10)=="0"} {  set t2(voice) 0  }
if {$t2(voice)>"0"} {
  if {$t2(v-how)>"0"} {
    if {$t2(v-how)<"3" && $t2(V11) eq "" && $t2(V31) eq ""} {  set t2(v-how) 0  }
    if {$t2(v-how)>"2" && $t2(V01) eq "" && $t2(V21) eq ""} {  set t2(v-how) 0  }
  }
  if {$t2(v-how)=="0"} {  array set t2 {V01 "" V11 "" V21 "" V31 "" V02 ""}
    unset t2(V81) t2(V82) t2(V83) t2(V84) t2(V85) t2(V86) t2(V91) t2(V92) t2(V93)
    unset tscl(vo1) tscl(vo2) tscl(vo3) tscl(vo4)
  }
} else {  array unset t2 v-*  ;  unset t2(V01) t2(V11) t2(V21) t2(V31) t2(V02)
  unset t2(V81) t2(V82) t2(V83) t2(V84) t2(V85) t2(V86) t2(V91) t2(V92) t2(V93)
  unset tscl(vo1) tscl(vo2) tscl(vo3) tscl(vo4)
  if {[info exists t2(-vls)]} {  unset t2(-vls) t2(-lastvnk) t2(-lastvut)  }
  if {[info exists t2(-sayvls)]} {  unset t2(-sayvls)  }
}

foreach ttmp(x) {A01 A11} {
 if {![info exists t2($ttmp(x))]} {  set t2($ttmp(x)) ""  }
}
if {$t2(autostart) ne "0"} {
  set t2(A11) {}
  foreach ttmp(x) {A01 A11} {  set ttmp(y) [split $t2($ttmp(x)) "\n"] ;  set ttmp(z) ""
   foreach ttmp(l) $ttmp(y) {
    if {$ttmp(l) ne "" && $ttmp(l) ne " "} { lappend ttmp(z) $ttmp(l) }
   }
   set t2($ttmp(x)) $ttmp(z)
  }
}
foreach ttmp(x) {as1 as2} {
 if {![info exists tscl($ttmp(x))]} {  set tscl($ttmp(x)) ""  }
}
if {$t2(autostart)>"0" && $t2(qslow)>"0" && $t2(rest)>"0"} {  set t2(autostart) 0  }
if {$t2(autostart)=="0"} {  unset t2(a-xflag) t2(a-xnick) t2(a-delay) t2(a-same) t2(A01) t2(A11)
  unset tscl(as1) tscl(as2)
  if {[info exists t2(-aoff)]} {  unset t2(-aoff) t2(-als) t2(-lastank) t2(-lastaut)  }
}

set ttmp(all) [list P01 P02 P03 P04 P11 P12 P13 P14 P21 P22 P23 P24 P31 P32 P33 P34]
lappend ttmp(all) P41 P42 P45 P46 P50 P51 P52 P53 P54 P55 P56 P57 P58 P59
lappend ttmp(all) P60 P61 P62 P63 P64 P65 P66 P67 P68 P69 P70
foreach ttmp(x) $ttmp(all) {
 if {![info exists t2($ttmp(x))]} {  set t2($ttmp(x)) ""  }
}
if {![info exists t2(P43)]} {  set t2(P43) ""  }
if {$t2(pubcmd)>"0"} {  set t2(P43) $t2(p-otext)  ;  unset t2(p-otext)
  foreach ttmp(x) $ttmp(all) {
   set ttmp(y) [split $t2($ttmp(x)) "\n"]  ;  set ttmp(z) ""
   foreach ttmp(l) $ttmp(y) {
    if {$ttmp(l) ne "" && $ttmp(l) ne " "} {  lappend ttmp(z) $ttmp(l)  }
   }
   set t2($ttmp(x)) $ttmp(z)
  }
  if {$t2(p-top-d) ne "" && $t2(P01) ne "" && $t2(P04) ne ""} {
    if {$t2(p-t20-d) ne "" && $t2(P02) ne ""} {
      if {![TStrDig $t2(p-tmax-d)] || $t2(p-tmax-d)<"21"} {  set t2(p-tmax-d) 0  }
      if {$t2(p-tmax-d)>"0" && [string index $t2(p-tmax-d) end]>"0"} {
        set ttmp(x) [string range $t2(p-tmax-d) 0 end-1] ;  incr ttmp(x) ;  set t2(p-tmax-d) $ttmp(x)0
      }
      if {$t2(p-tmor-d) ne "" && $t2(P03) ne "" && $t2(p-tmax-d)>"0"} {
      } else {  set t2(p-tmor-d) ""  ;  unset t2(P03) t2(p-tmax-d)  }
    } else {  array set t2 {p-t20-d "" p-tmor-d ""}  ;  unset t2(P02) t2(P03) t2(p-tmax-d)  }
  } else { set t2(p-top-d) "" ; unset t2(P01) t2(P02) t2(P03) t2(P04) t2(p-t20-d) t2(p-tmor-d) t2(p-tmax-d) }
  if {$t2(p-top-w) ne "" && $t2(P11) ne "" && $t2(P14) ne ""} {
    if {$t2(p-t20-w) ne "" && $t2(P12) ne ""} {
      if {![TStrDig $t2(p-tmax-w)] || $t2(p-tmax-w)<"21"} {  set t2(p-tmax-w) 0  }
      if {$t2(p-tmax-w)>"0" && [string index $t2(p-tmax-w) end]>"0"} {
        set ttmp(x) [string range $t2(p-tmax-w) 0 end-1] ;  incr ttmp(x) ;  set t2(p-tmax-w) $ttmp(x)0
      }
      if {$t2(p-tmor-w) ne "" && $t2(P13) ne "" && $t2(p-tmax-w)>"0"} {
      } else {  set t2(p-tmor-w) ""  ;  unset t2(P13) t2(p-tmax-w)  }
    } else {  array set t2 {p-t20-w "" p-tmor-w ""}  ;  unset t2(P12) t2(P13) t2(p-tmax-w)  }
  } else { set t2(p-top-w) "" ; unset t2(P11) t2(P12) t2(P13) t2(P14) t2(p-t20-w) t2(p-tmor-w) t2(p-tmax-w) }
  if {$t2(p-top-m) ne "" && $t2(P21) ne "" && $t2(P24) ne ""} {
    if {$t2(p-t20-m) ne "" && $t2(P22) ne ""} {
      if {![TStrDig $t2(p-tmax-m)] || $t2(p-tmax-m)<"21"} {  set t2(p-tmax-m) 0  }
      if {$t2(p-tmax-m)>"0" && [string index $t2(p-tmax-m) end]>"0"} {
        set ttmp(x) [string range $t2(p-tmax-m) 0 end-1] ;  incr ttmp(x) ;  set t2(p-tmax-m) $ttmp(x)0
      }
      if {$t2(p-tmor-m) ne "" && $t2(P23) ne "" && $t2(p-tmax-m)>"0"} {
      } else {  set t2(p-tmor-m) ""  ;  unset t2(P23) t2(p-tmax-m)  }
    } else {  array set t2 {p-t20-m "" p-tmor-m ""}  ;  unset t2(P22) t2(P23) t2(p-tmax-m)  }
  } else { set t2(p-top-m) "" ; unset t2(P21) t2(P22) t2(P23) t2(P24) t2(p-t20-m) t2(p-tmor-m) t2(p-tmax-m) }
  if {$t2(p-top-e) ne "" && $t2(P31) ne "" && $t2(P34) ne ""} {
    if {$t2(p-t20-e) ne "" && $t2(P32) ne ""} {
      if {![TStrDig $t2(p-tmax-e)] || $t2(p-tmax-e)<"21"} {  set t2(p-tmax-e) 0  }
      if {$t2(p-tmax-e)>"0" && [string index $t2(p-tmax-e) end]>"0"} {
        set ttmp(x) [string range $t2(p-tmax-e) 0 end-1] ;  incr ttmp(x) ;  set t2(p-tmax-e) $ttmp(x)0
      }
      if {$t2(p-tmor-e) ne "" && $t2(P33) ne "" && $t2(p-tmax-e)>"0"} {
      } else {  set t2(p-tmor-e) ""  ;  unset t2(P33) t2(p-tmax-e)  }
    } else {  array set t2 {p-t20-e "" p-tmor-e ""}  ;  unset t2(P32) t2(P33) t2(p-tmax-e)  }
  } else { set t2(p-top-e) "" ; unset t2(P31) t2(P32) t2(P33) t2(P34) t2(p-t20-e) t2(p-tmor-e) t2(p-tmax-e) }
  if {$t2(p-info) eq "" || ($t2(P45) eq "" && $t2(P46) eq "")} {
      set t2(p-info) ""  ;  unset t2(P45)  ;  unset t2(P46)  }
  if {$t2(p-owner) eq "" || $t2(P41) eq ""} {  set t2(p-owner) ""  ;  unset t2(P41)  }
  if {$t2(p-page) eq "" || $t2(p-pwww) eq "" || $t2(P42) eq ""} {  set t2(p-page) ""  ;  unset t2(P42)  }
  if {$t2(p-other) eq "" || $t2(P43) eq ""} {  set t2(p-other) ""  ;  unset t2(P43)  }
  if {$t2(p-mystat) eq "" || $t2(P50) eq ""} {  set t2(p-mystat) ""
      unset t2(P50) t2(P51) t2(P52) t2(P53) t2(P54) t2(P55) t2(P56) t2(P57) t2(P58) t2(P59)  }
  if {$t2(p-opstat) eq "" || $t2(P60) eq ""} {  set t2(p-opstat) ""
      unset t2(P60) t2(P61) t2(P62) t2(P63) t2(P64) t2(P65) t2(P66) t2(P67) t2(P68) t2(P69) t2(P70)  }
  if {$t2(p-top-d) eq "" && $t2(p-top-w) eq "" && $t2(p-top-m) eq "" && $t2(p-top-e) eq "" && $t2(p-opstat) eq ""} {
    if {$t2(p-info) eq "" && $t2(p-owner) eq "" && $t2(p-page) eq "" && $t2(p-other) eq "" && $t2(p-mystat) eq ""} {
      set t2(pubcmd) 0
    }
  }
}
if {$t2(pubcmd)<"1"} {  lappend ttmp(all) -ptrigls -ptrigl2 p-opstat
  lappend ttmp(all) P43 p-gflag p-mystat p-info p-owner p-page p-other p-otext p-tflag
  lappend ttmp(all) p-top-d p-t20-d p-tmor-d p-tmax-d p-top-w p-t20-w p-tmor-w p-tmax-w
  lappend ttmp(all) p-top-m p-t20-m p-tmor-m p-tmax-m p-top-e p-t20-e p-tmor-e p-tmax-e
  foreach ttmp(x) $ttmp(all) {
   if {[info exists t2($ttmp(x))]} {  unset t2($ttmp(x))  }
  }
}

set t2(days1) ""  ; set t2(days2) ""   ;  set t2(mons1) ""  ;  set t2(mons2) ""

##################################################
#########  Translate Day & Month Names  ##########
###                                            ###
###   Remove the # from the lines below and    ###
###    edit each name in the list.             ###
###                                            ###
## -> To use the defaults, don't edit these! <- ##
##################################################

#set t2(days1) {
#MONDAY
#TUESDAY
#WEDNESDAY
#THURSDAY
#FRIDAY
#SATURDAY
#SUNDAY
#}

#set t2(days2) {
#Monday
#Tuesday
#Wednesday
#Thursday
#Friday
#Saturday
#Sunday
#}

#set t2(mons1) {
#JANUARY
#FEBRUARY
#MARCH
#APRIL
#MAY
#JUNE
#JULY
#AUGUST
#SEPTEMBER
#OCTOBER
#NOVEMBER
#DECEMBER
#}

#set t2(mons2) {
#January
#February
#March
#April
#May
#June
#July
#August
#September
#October
#November
#December
#}

##################################################
#######  END Translate Day & Month Names  ########
##################################################

foreach ttmp(var) {days1 days2 mons1 mons2} {
 if {$t2($ttmp(var)) ne ""} {
   set ttmp(is) [split $t2($ttmp(var)) "\n"]  ;  set ttmp(new) ""
   foreach ttmp(item) $ttmp(is) {  set ttmp(item) [string trim $ttmp(item)]
    if {$ttmp(item) ne ""} {  lappend ttmp(new) $ttmp(item)  }
   }
   if {[string match d* $ttmp(var)]} {
     if {[llength $ttmp(new)]=="7"} {  set t2($ttmp(var)) [linsert $ttmp(new) 0 0]
     } else {  set t2($ttmp(var)) ""  }
   } else {
     if {[llength $ttmp(new)]=="12"} {  set t2($ttmp(var)) [linsert $ttmp(new) 0 0]
     } else {  set t2($ttmp(var)) ""  }
   }
 }
}

proc TChar {how chr} {
 if {$chr eq " "} {
  if {$how=="1" || $how=="2"} { return 0 }
 }
 if {$how=="1"} {
  if {[string match {[A-Za-z0-9]} $chr]} { return 1 } else { return 0 }
 } elseif {$how=="2"} {
  if {[string match {[aeiouAEIOU]} $chr]} { return 1 } else { return 0 }
 }
 return $chr
}
proc TRandL {} {
 set lstr "qNwMrLtJpCsZdRfQgShFjklPzxTcWvb"
 return [string index $lstr [rand 30]]
}
proc TDoNum { {num Error} } {
 switch -exact -- $num {
  0 {  return Zero  }
  1 {  return One  }
  2 {  return Two  }
  3 {  return Three  }
  4 {  return Four  }
  5 {  return Five  }
  6 {  return Six  }
  7 {  return Seven  }
  8 {  return Eight  }
  9 {  return Nine  }
  10 {  return Ten  }
  11 {  return Eleven  }
  12 {  return Twelve  }
  13 {  return Thirteen  }
  14 {  return Fourteen  }
  15 {  return Fifteen  }
  16 {  return Sixteen  }
  17 {  return Seventeen  }
  18 {  return Eighteen  }
  19 {  return Nineteen  }
  20 {  return Twenty  }
  default {  return $num  }
 }
}
if {![info exists t2(-ison)]} { set t2(-ison) 0 }
if {![info exists t2(-active)]} { set t2(-active) "" }
if {![info exists t2(-qtimer)]} { set t2(-qtimer) "" }
if {![info exists t2(-otimer)]} { set t2(-otimer) "" }
if {![info exists t2(-abound)]} { set t2(-abound) 0 }
if {![info exists t2(-a2bound)]} { set t2(-a2bound) 0 }
if {![info exists t2(-qbound)]} { set t2(-qbound) 0 }
if {![info exists t2(-hbound)]} { set t2(-hbound) 0 }
if {![info exists t2(-reply)]} { set t2(-reply) "" }
if {![info exists t2(-newfiles)]} { set t2(-newfiles) "" }
if {![info exists t2(-openbad)]} { set t2(-openbad) "" }
if {![info exists t2(-iskaos)]} { set t2(-iskaos) 0 }

if {$t2(restart)>"0" && $t2(-newstart)>"0" && [file exists $t2(sfpath)t2.recent] && $t2(-ison)=="0"} {
  proc TStartTriv {} {  global t2 botnick
   if {[botonchan $t2(chan)]} {
     if {$t2(-ison)=="0"} {  TOnOff $botnick error restart $t2(chan) 1 3  }
   } else {  utimer 4 [list TStartTriv]  }
  }
  utimer 6 [list TStartTriv]
}
proc TFigurWe { {wat 0} {start 0} } {  global t2
 if {$wat=="1" && $start!="0"} {  set begin [strftime %u $start]  }
 if {$t2(newweek)=="1"} {  set wkend 7
 } else {  set wkend [expr {$t2(newweek)-1}]  }
 set wkls [strftime %j $start]  ;  set nexda $start
 if {$begin!=$wkend} {  set dacnt $begin
   while {$dacnt!=$wkend} {
    if {$dacnt=="7"} {  set dacnt 1  } else {  incr dacnt  }
    incr nexda 86400  ;  append wkls " [strftime %j $nexda]"
   }
 }
 if {$wat=="1"} { return $wkls }
}
proc TDoHInfo { {wat 0} } {  global t2 botnick  ;  set scnt 0  ;  set socnt 0
 if {[file exists $t2(sfpath)t2.hist.info]} {  set thiinfo [open $t2(sfpath)t2.hist.info]
   set hinfo [split [gets $thiinfo]]  ;  close $thiinfo  ;  file delete $t2(sfpath)t2.hist.info
   if {[TStrDig [lindex $hinfo 0]] && [llength $hinfo]>"1" && [TStrDig [lindex $hinfo 1]]} {
     set scnt [lindex $hinfo 1]
     if {[llength $hinfo]>"2" && [TStrDig [lindex $hinfo end]]} { set socnt [lindex $hinfo end] }
   }
 }
 set thiinfo [open $t2(sfpath)t2.hist.info w]
 if {![file exists $t2(sfpath)t2.hist]} {  set thifile [open $t2(sfpath)t2.hist w]
   puts $thifile "::N2:[unixtime]"  ;  puts $thifile "::X: Extra History:"  ;  close $thifile
   puts $thiinfo "[unixtime] 0"  ;  close $thiinfo
   set t2(-yestrda) 0  ;  set t2(-histcnt) 0
 } else {  set thifile [open $t2(sfpath)t2.hist]  ;  set dc 0  ;  set wc 0  ;  set mc 0
   while {![eof $thifile]} {  set temp [gets $thifile]
    if {($dc>"6" && $wc>"3" && $mc>"3") || [string match ::X:* $temp]} {  break  }
    if {[string match ::D:* $temp]} {  incr dc
    } elseif {[string match ::W:* $temp]} {  incr wc
    } elseif {[string match ::M:* $temp]} {  incr mc  }
   }
   close $thifile
   set tmlist [list $dc 1 12 $wc 1 22 $dc 2 13 $mc 1 32 $dc 3 14]  ;  set hlist ""
   lappend tmlist $wc 2 23 $dc 4 15 $mc 2 33 $dc 5 16 $wc 3 24 $dc 6 17 $mc 3 34
   foreach {x y z} $tmlist {   if {$x>$y} { lappend hlist $z }   }
   if {$hlist ne ""} {
     if {$scnt=="0"} {  set scnt 1  }  ;  if {$socnt=="0"} {  set socnt 1  }
     set t2(-histcnt) "$scnt [join $hlist] $socnt"
     puts $thiinfo "[unixtime] $t2(-histcnt)"
   } else {  puts $thiinfo "[unixtime] 0"  ;  set t2(-histcnt) 0  }
   close $thiinfo
   if {$dc>"0" && $wc>"0" && $mc>"0"} {  set t2(-yestrda) 4
   } elseif {$dc>"0" && $mc>"0"} {  set t2(-yestrda) 3
   } elseif {$dc>"0" && $wc>"0"} {  set t2(-yestrda) 2
   } elseif {$dc>"0"} {  set t2(-yestrda) 1  } else {  set t2(-yestrda) 0  }
 }
}
proc TSavUsers { {wat 0} {w2 0} } {  global t2 tclr botnick  ;  set isnew 0  ;  set tlin0 ""
 if {![file exists $t2(sfpath)t2.users]} {  set utnow [unixtime]  ;  set t2(-ufilcnt) 0
   set tlin0 "::N2:$utnow 0 $utnow 0 $utnow 0 $utnow 0 0"  ;  set t2(-ufiledt) $utnow
   set tusfile [open $t2(sfpath)t2.users w] ;  puts $tusfile "$tlin0" ;  close $tusfile
   if {$wat=="0"} {  return 1  }  ;  set isnew 1  ;  set uc 0
 } else {
   if {$wat=="0"} {  set t2(-active) ""  ;  set lincnt 0
    set tusfile [open $t2(sfpath)t2.users]  ;  set tlin0 [gets $tusfile]
    foreach {nt d10 dt w10 wt m10 mt e10 uc} $tlin0 {  break  }
    set t2(-ufiledt) [lindex [split $nt :] 3]  ;  set t2(-ufilcnt) $uc
    if {[strftime %j $dt]!=[strftime %j]} {  close $tusfile  ;  TSavHist 1
      if {$t2(-stats)>"0"} {  TSetStat  }
      if {$t2(limit)>"0"} {  set t2(-lchek) 2  }
      set tusfile [open $t2(sfpath)t2.users]  ;  set tlin0 [gets $tusfile]
      set uc [lindex [split $tlin0] 8]  ;  set t2(-ufilcnt) $uc
    }
    while {![eof $tusfile]} {  set temp [TStrLo [gets $tusfile]]
     if {$temp ne ""} {  incr lincnt
      if {$lincnt>"0" && $lincnt<=$t2(actvsiz)} {  set temp [split $temp]
        foreach {nk hn uh tp tc wp wc mp mc ep ec ad ud n2 u2} $temp {  break  }
        set nk [string range $nk 3 end]
        if {$n2 ne "-"} {  set n2 [string range $n2 3 end]  }
        lappend t2(-active) $nk $n2 $hn $uh $u2 $tp $wp $mp
      } elseif {$lincnt>$t2(actvsiz)} {  break  }
     }
    }
    close $tusfile  ;  return 0
   } elseif {$wat=="1"} {  set tusfile [open $t2(sfpath)t2.users]
    set tlin0 [gets $tusfile]  ;  close $tusfile
    foreach {nt d10 dt w10 wt m10 mt e10 uc} $tlin0 {  break  }
    set t2(-ufiledt) [lindex [split $nt :] 3]  ;  set t2(-ufilcnt) $uc
    if {$uc=="0"} {  set isnew 1  }
    if {[string match ::N:* $nt]} {  set nt [string replace $nt 2 2 N2]
       set tlin0 [lreplace $tlin0 0 0 $nt]  }
   }
 }
 if {$w2=="0"} {  set trefile [open $t2(sfpath)t2.recent]  ;  set content [read $trefile]
   close $trefile  ;  set content [split [string trimright $content \n] "\n"]
   set tlidx -1  ;  set newls ""  ;  set rlin0 ""
   foreach tline $content {  incr tlidx
    if {$tlidx=="0"} {  set rlin0 $tline
    } else {
     foreach {nk hn uh pt cnt} [split $tline] {  break  }
     if {$cnt eq ""} {  set cnt 1  }  ;  set uh [string trimleft $uh ~]
     if {$newls==""} {  lappend newls $nk $hn $uh $pt $cnt
     } else {  set fnd 0  ;  set nidx 0
       foreach {n h u p c} $newls {
        if {[TStrLo $nk] eq [TStrLo $n]} {  set fnd 1  ;  break  }
        if {$t2(match)>"0" && $hn ne "*" && $hn eq $h} {  set fnd 2  ;  break  }
        if {$t2(match)>"0" && $uh eq $u} {  set fnd 3  ;  break  }
        incr nidx 5
       }
       if {$fnd>"0"} {  set end [expr {$nidx+4}]
         set p [expr {round("$p.0"+$pt)}]  ;  set c [expr {round("$c.0"+$cnt)}]
         if {$t2(match)=="1" && $hn eq "*"} {  set hn $h  }
         set newls [lreplace $newls $nidx $end $nk $hn $uh $p $c]
       } else {  lappend newls $nk $hn $uh $pt $cnt  }
     }
    }
   }
 } else {  set newls ""  ;  putlog "Updating Bogus UserFile:  t2.users..."  }
 if {$t2(-stats)>"0"} {  set recnkls ""
   if {$newls ne ""} {
     foreach {ank ahn auh apt act} $newls {  set ank [string range $ank 3 end]
      if {$recnkls==""} {  lappend recnkls $ank
      } else {  set fnd 0
        foreach n $recnkls {
         if {[TStrLo $ank] eq [TStrLo $n]} {  set fnd 1  ;  break  }
        }
        if {$fnd=="0"} {  lappend recnkls $ank  }
      }
     }
   }
 }
 if {$isnew=="0"} {  set dubnks ""  ;  set dubls ""  ;  set nikls ""  ;  set hstls ""
  set tusfile [open $t2(sfpath)t2.users]  ;  set lincnt -1
  set tmpfile1 [open $t2(sfpath)t2.usr.tmp1 w] ; set tmpfile2 [open $t2(sfpath)t2.usr.tmp2 w]
  while {![eof $tusfile]} {  set temp [split [gets $tusfile]]
   if {$temp ne ""} {  incr lincnt
    if {$lincnt>"0"} {
      foreach {nk hn uh tp tc wp wc mp mc ep ec ad ud n2 u2} $temp {  break  }
      if {$n2 eq "" || $t2(match)=="0"} {  set n2 -  ;  set u2 -  }
      set uh [string trimleft $uh ~]  ;  set fnd 0  ;  set nidx 0
      if {$newls ne ""} {
        foreach {fnk fhn fuh fpt fct} $newls {
         if {[TStrLo $nk] eq [TStrLo $fnk]} {  set fnd 1  ;  break  }
         if {$t2(match)=="0"} {  incr nidx 5  ;  continue  }
         if {$hn ne "*" && $hn eq $fhn} {  set fnd 2  ;  break  }
         if {[TStrLo $uh] eq [TStrLo $fuh]} {  set fnd 3  ;  break  }
         if {[TStrLo $n2] eq [TStrLo $fnk]} {  set fnd 4  ;  break  }
         if {[TStrLo $u2] eq [TStrLo $fuh]} {  set fnd 5  ;  break  }
         incr nidx 5
        }
      }
      if {$fnd>"0"} {  set end [expr {$nidx+4}]  ;  set newls [lreplace $newls $nidx $end]
        if {$t2(match)=="1"} {
          if {[TStrLo $fnk] ne [TStrLo $nk]} {  set n2 $nk  ;  set nk $fnk  }
          if {$fhn ne "*"} {  set hn $fhn  }
          if {[TStrLo $fuh] ne [TStrLo $uh]} {  set u2 $uh  ;  set uh $fuh  }
        } else {  set nk $fnk  ;  set hn $fhn  ;  set uh $fuh  }
        set fpt "${fpt}.0"  ;  set fct "${fct}.0"
        set tp [expr { round($tp+$fpt) }]  ;  set tc [expr { round($tc+$fct) }]
        set wp [expr { round($wp+$fpt) }]  ;  set wc [expr { round($wc+$fct) }]
        set mp [expr { round($mp+$fpt) }]  ;  set mc [expr { round($mc+$fct) }]
        set ep [expr { round($ep+$fpt) }]  ;  set ec [expr { round($ec+$fct) }]
        set ud [unixtime]  ;  set putto 1
      } else {  set putto 2  }
      set isdub 0
      if {$nikls eq ""} {  lappend nikls $nk $n2  ;  lappend hstls $uh $u2
      } else {  set nidx 0
        foreach {dnk dn2} $nikls {
         if {[TStrLo $nk] eq [TStrLo $dnk] || [TStrLo $nk] eq [TStrLo $dn2]} { set isdub 1 ; break }
         if {$t2(match)=="0"} {  incr nidx 2  ;  continue  }
         if {$n2 ne "-" && ([TStrLo $n2] eq [TStrLo $dnk] || [TStrLo $n2] eq [TStrLo $dn2])} { set isdub 2 ; break }
         incr nidx 2
        }
        if {$isdub=="0" && $t2(match)>"0"} {  set nidx 0
          foreach {duh du2} $hstls {
           if {[TStrLo $uh] eq [TStrLo $duh] || [TStrLo $uh] eq [TStrLo $du2]} { set isdub 3 ; break }
           if {$u2 ne "-" && ([TStrLo $u2] eq [TStrLo $duh] || [TStrLo $u2] eq [TStrLo $du2])} { set isdub 4 ; break }
           incr nidx 2
          }
        }
        if {$isdub=="0"} {  lappend nikls $nk $n2  ;  lappend hstls $uh $u2
        } else {  set isdub [lindex $nikls $nidx]  }
      }
      if {$isdub eq "0"} {  set tmp2 "$nk $hn $uh $tp $tc $wp $wc $mp $mc $ep $ec $ad"
        if {$putto=="1"} {  puts $tmpfile1 "$tmp2 $ud $n2 $u2"
        } else {  puts $tmpfile2 "$tmp2 $ud $n2 $u2"  }
      } else {  lappend dubnks $isdub
        lappend dubls $nk $hn $uh $tp $tc $wp $wc $mp $mc $ep $ec $ad
      }
    }
   }
  }
  close $tmpfile1  ;  close $tmpfile2  ;  close $tusfile
  if {$dubls ne ""} {  set dubucnt [llength $dubnks]  ;  set uc [expr {$uc-$dubucnt}]
    putlog "Found $dubucnt players existing user records!"
  }
  if {$newls ne ""} {  set uc [expr {$uc+([llength $newls]/5)}]  }
  set nufile [open $t2(sfpath)t2.usr.tmp3 w]
  puts $nufile "$nt $d10 $dt $w10 $wt $m10 $mt $e10 $uc"
  set tmpfile1 [open $t2(sfpath)t2.usr.tmp1]  ;  set cusrcnt 0
  while {![eof $tmpfile1]} {  set tmptusr [split [gets $tmpfile1]]
   if {$tmptusr ne ""} {  incr cusrcnt
     foreach {nk hn uh tp tc wp wc mp mc ep ec ad ud n2 u2} $tmptusr {  break  }
     if {$dubls ne ""} {  set tmls ""  ;  set idx -1
       foreach dnk $dubnks {  incr idx
        if {[TStrLo $nk] eq [TStrLo $dnk]} {  set tmls [linsert $tmls 0 $idx]  }
       }
       if {$tmls ne ""} {
         foreach num $tmls {  set dubnks [lreplace $dubnks $num $num]
          set num [expr {$num*12}]  ;  set oldls [lrange $dubls $num [expr {$num+11}]]
          set dubls [lreplace $dubls $num [expr {$num+11}]]
          foreach {dnk dhn duh dtp dtc dwp dwc dmp dmc dep dec dad} $oldls {  break  }
          set tp [expr {round("$tp.0"+$dtp)}]  ;  set tc [expr {round("$tc.0"+$dtc)}]
          set wp [expr {round("$wp.0"+$dwp)}]  ;  set wc [expr {round("$wc.0"+$dwc)}]
          set mp [expr {round("$mp.0"+$dmp)}]  ;  set mc [expr {round("$mc.0"+$dmc)}]
          set ep [expr {round("$ep.0"+$dep)}]  ;  set ec [expr {round("$ec.0"+$dec)}]
          if {$dad<$ad} {  set ad $dad  }
         }
         if {$t2(match)>"0" && $n2 eq "-" && [TStrLo $dnk] ne [TStrLo $nk]} {  set n2 $dnk  }
         if {$t2(match)>"0" && $u2 eq "-" && [TStrLo $duh] ne [TStrLo $uh]} {  set u2 $duh  }
       }
     }
     puts $nufile "$nk $hn $uh $tp $tc $wp $wc $mp $mc $ep $ec $ad $ud $n2 $u2"
   }
  }
  close $tmpfile1  ;  file delete $t2(sfpath)t2.usr.tmp1
  if {$newls ne ""} {
    foreach {nnk nhn nuh npt nct} $newls {  incr cusrcnt  ;  set nexltmp ""
     lappend nexltmp $nnk $nhn $nuh $npt $nct $npt $nct $npt $nct $npt $nct
     lappend nexltmp [unixtime] [unixtime] - -  ;  puts $nufile "[join $nexltmp]"
    }
  }
  set tmpfile2 [open $t2(sfpath)t2.usr.tmp2]
  while {![eof $tmpfile2]} {  set tmptusr [split [gets $tmpfile2]]
   if {$tmptusr ne ""} {  incr cusrcnt
     foreach {nk hn uh tp tc wp wc mp mc ep ec ad ud n2 u2} $tmptusr {  break  }
     if {$dubls ne ""} {  set tmls ""  ;  set idx -1
       foreach dnk $dubnks {  incr idx
        if {[TStrLo $nk] eq [TStrLo $dnk]} {  set tmls [linsert $tmls 0 $idx]  }
       }
       if {$tmls ne ""} {
         foreach num $tmls {  set dubnks [lreplace $dubnks $num $num]
          set num [expr {$num*12}]  ;  set oldls [lrange $dubls $num [expr {$num+11}]]
          set dubls [lreplace $dubls $num [expr {$num+11}]]
          foreach {dnk dhn duh dtp dtc dwp dwc dmp dmc dep dec dad} $oldls {  break  }
          set tp [expr {round("$tp.0"+$dtp)}]  ;  set tc [expr {round("$tc.0"+$dtc)}]
          set wp [expr {round("$wp.0"+$dwp)}]  ;  set wc [expr {round("$wc.0"+$dwc)}]
          set mp [expr {round("$mp.0"+$dmp)}]  ;  set mc [expr {round("$mc.0"+$dmc)}]
          set ep [expr {round("$ep.0"+$dep)}]  ;  set ec [expr {round("$ec.0"+$dec)}]
          if {$dad<$ad} {  set ad $dad  }
         }
         if {$t2(match)>"0" && $n2 eq "-" && [TStrLo $dnk] ne [TStrLo $nk]} {  set n2 $dnk  }
         if {$t2(match)>"0" && $u2 eq "-" && [TStrLo $duh] ne [TStrLo $uh]} {  set u2 $duh  }
       }
     }
     puts $nufile "$nk $hn $uh $tp $tc $wp $wc $mp $mc $ep $ec $ad $ud $n2 $u2"
   }
  }
  close $tmpfile2  ;  file delete $t2(sfpath)t2.usr.tmp2
  close $nufile  ;  file delete $t2(sfpath)t2.users
  file rename $t2(sfpath)t2.usr.tmp3 $t2(sfpath)t2.users
 }
 if {$isnew=="1"} {  set tusfile [open $t2(sfpath)t2.users w]
  set uc [expr {[llength $newls]/5}]  ;  puts $tusfile "[lrange $tlin0 0 7] $uc"
  foreach {nk hn uh pt ct} $newls {  set nexline ""
   lappend nexline $nk $hn $uh $pt $ct $pt $ct $pt $ct $pt $ct
   lappend nexline [unixtime] [unixtime] - -  ;  puts $tusfile "[join $nexline]"
  }
  close $tusfile
 }
 if {[info exists recnkls] && $recnkls ne ""} {  TSetStat
   if {$t2(voice)>"1" && [botonchan $t2(chan)]} {  TDoActV $recnkls  }
 }
 if {$w2=="0" && $t2(-ison)=="1"} {  set trefile [open $t2(sfpath)t2.recent w]
   puts $trefile "$rlin0"  ;  close $trefile  ;  set t2(-reccnt) 0
 } elseif {$w2=="0" && [file exists $t2(sfpath)t2.recent]} { file delete $t2(sfpath)t2.recent }
 set t2(-ufilcnt) $uc
}
proc TSavHist { {wat 0} } {  global t2 tclr botnick nick  ;  set isnew 0  ;  set hflver 2
 if {![file exists $t2(sfpath)t2.hist]} {  TDoHInfo  ;  set isnew 1
 } elseif {$wat=="1"} {  set y [open $t2(sfpath)t2.hist]  ;  set z [gets $y]  ;  close $y
   if {[string match ::N:* $z]} {
     if {![file exists $t2(sfpath)t2.commands]} {  set hflver 1
     } else {  set open [open $t2(sfpath)t2.commands]
       set cver [string range [gets $open] 3 6]  ;  close $open
       if {![TStrDig $cver] || $cver<"2063"} {  set hflver 1
       } else {  set t2(_cm) h  ;  source $t2(sfpath)t2.commands  }
     }
   }
 }
 if {$wat>"0"} {
   if {[file exists $t2(sfpath)t2.recent]} {  TSavUsers 1  }
   set tusfile [open $t2(sfpath)t2.users]  ;  set tulin0 [gets $tusfile]
   foreach {nt d10 dt w10 wt m10 mt e10 uc} $tulin0 { break }
   set t2(-ufiledt) [lindex [split $nt :] 3]  ;  set t2(-ufilcnt) $uc
   set doda 0 ;  set dowe 0 ;  set domo 0 ;  set doev 0
   set dals ""  ;  set wels ""  ;  set mols ""  ;  set evls ""
   if {$wat=="1"} {  set wls [TFigurWe 1 $wt]  ;  set toda [strftime %j]
     if {[strftime %j $dt]!=$toda} {  set doda 1
       if {$t2(limit)>"0"} {  set t2(-lchek) 2  }
       if {[lsearch -exact $wls $toda]=="-1"} { set dowe 1 }
       if {[strftime %m]!=[strftime %m $mt]} {  set domo 1 }
       set xdals "" ;  set xwels "" ;  set xmols "" ;  set dells "" ;  set oldusr 0
       if {$t2(oldusr)>"0"} {  set oldusr [expr {[unixtime]-($t2(oldusr)*86400)}]  }
     } else {  close $tusfile  ;  return 0  }
     set tutmpfil [open $t2(sfpath)t2.usr.tmp w]
   } else {
     if {$t2(-shoda10)=="1"} { set doda 1  ;  set t2(-shoda10) 0
     } elseif {$t2(-showe10)=="1"} { set dowe 1  ;  set t2(-showe10) 0
     } elseif {$t2(-shomo10)=="1"} { set domo 1  ;  set t2(-shomo10) 0
     } elseif {$t2(-shoev10)=="1"} { set doev 1  ;  set t2(-shoev10) 0 }
   }
   set delrest 0  ;  set lincnt 0
   while {![eof $tusfile]} {  set temp [gets $tusfile]
    if {$temp ne ""} {  set temp [split $temp]
     foreach {nk hn uh tp tc wp wc mp mc ep ec at st n2 u2} $temp {  break  }
     if {$delrest>"0"} {  incr delrest
     } elseif {$wat=="1"} {
       if {$st<$oldusr} {  incr delrest  ;  set delrsn 1
       } elseif {$lincnt==$t2(usrmax)} {  incr delrest  ;  set delrsn 2  }
     }
     if {$delrest>"0"} {  lappend delrsn $nk $hn $uh $at $st  ;  continue  }
     if {$doda=="1"} {
       if {$tp>=$d10 && $tp>"0"} { lappend dals [list $tp $tc $nk $hn $uh]
       } elseif {$wat=="1" && $tp>"0"} { lappend xdals [list $tp $tc $nk $hn $uh] }
       if {$wat=="1"} { set tp 0  ;  set tc 0 }
     }
     if {$dowe=="1"} {
       if {$wp>=$w10 && $wp>"0"} { lappend wels [list $wp $wc $nk $hn $uh]
       } elseif {$wat=="1" && $wp>"0"} { lappend xwels [list $wp $wc $nk $hn $uh] }
       if {$wat=="1"} { set wp 0  ;  set wc 0 }
     }
     if {$domo=="1"} {
       if {$mp>=$m10 && $mp>"0"} { lappend mols [list $mp $mc $nk $hn $uh]
       } elseif {$wat=="1" && $mp>"0"} { lappend xmols [list $mp $mc $nk $hn $uh] }
       if {$wat=="1"} { set mp 0  ;  set mc 0 }
     }
     if {$doev=="1"} {
       if {$ep>=$e10} { lappend evls [list $ep $ec $nk $hn $uh] }
     }
     if {$wat=="1"} {  incr lincnt
       puts $tutmpfil "$nk $hn $uh $tp $tc $wp $wc $mp $mc $ep $ec $at $st $n2 $u2"
     }
    }
   }
   close $tusfile
   if {$wat=="1"} {  set uc $lincnt  ;  set t2(-ufilcnt) $uc
     if {$delrest>"0"} {  set one ""  ;   if {$delrest>"1"} { set one s }  ;  set pls ""
       foreach {x y z q1 q2} [lrange $delrsn 1 end] {  lappend pls [string range $x 3 end]  }
       putlog "Removed $delrest old user record$one ([join $pls])."
       if {[lindex $delrsn 0]=="1"} {  putlog "Player$one not seen in over $t2(oldusr) days."
       } else {  putlog "BogusTrivia userfile was over $t2(usrmax) players."  }
     }
     close $tutmpfil  ;  set cntda 0  ;  set cntwe 0  ;  set cntmo 0
     if {$hflver=="1"} {  set thifile [open $t2(sfpath)t2.hist a]
     } else {  set thifile [open $t2(sfpath)t2.hst.tmp w]
       set thfold [open $t2(sfpath)t2.hist]  ;  puts $thifile [gets $thfold]
     }
     if {$doda=="1"} {  set count 0  ;  incr cntda
       set dals [lsort -index 0 -integer -decreasing $dals]
       puts $thifile "::D: [strftime %j $dt] $dt [expr {[llength $dals]+[llength $xdals]}]"
       foreach item $dals {  incr count
        if {$count>[lindex $t2(dausrs) 0]} { break }
        foreach {tp tc nk hn uh} $item { break } ; puts $thifile "$nk $hn $uh $tp $tc"
       }
       if {$xdals ne ""} {  set keep 0
         if {$count<[lindex $t2(dausrs) 0]} {  set keep [lindex $t2(dausrs) 0]  }
         if {$keep>"0"} {  set xdals [lsort -index 0 -integer -decreasing $xdals]
           foreach item $xdals {  incr count  ;  if {$count>$keep} {  break  }
            foreach {tp tc nk hn uh} $item { break } ; puts $thifile "$nk $hn $uh $tp $tc"
           }
         }
       }
       set d10 0  ;  set dt [unixtime]
     }
     if {$dowe=="1"} {  set count 0  ;  incr cntwe
       set wels [lsort -index 0 -integer -decreasing $wels]
       puts $thifile "::W: [strftime %j $wt] $wt [expr {[llength $wels]+[llength $xwels]}]"
       foreach item $wels {  incr count
        if {$count>[lindex $t2(weusrs) 0]} { break }
        foreach {wp wc nk hn uh} $item { break } ; puts $thifile "$nk $hn $uh $wp $wc"
       }
       if {$xwels ne ""} {  set keep 0
         if {$count<[lindex $t2(weusrs) 0]} {  set keep [lindex $t2(weusrs) 0]  }
         if {$keep>"0"} {  set xwels [lsort -index 0 -integer -decreasing $xwels]
           foreach item $xwels {  incr count  ;  if {$count>$keep} {  break  }
            foreach {tp tc nk hn uh} $item { break } ; puts $thifile "$nk $hn $uh $tp $tc"
           }
         }
       }
       set w10 0  ;  set wt [unixtime]
     }
     if {$domo=="1"} {  set count 0  ;  incr cntmo
       set mols [lsort -index 0 -integer -decreasing $mols]
       puts $thifile "::M: [strftime %j $mt] $mt [expr {[llength $mols]+[llength $xmols]}]"
       foreach item $mols {  incr count
        if {$count>[lindex $t2(mousrs) 0]} { break }
        foreach {mp mc nk hn uh} $item { break } ; puts $thifile "$nk $hn $uh $mp $mc"
       }
       if {$xmols ne ""} {  set keep 0
         if {$count<[lindex $t2(mousrs) 0]} {  set keep [lindex $t2(mousrs) 0]  }
         if {$keep>"0"} {  set xmols [lsort -index 0 -integer -decreasing $xmols]
           foreach item $xmols {  incr count  ;  if {$count>$keep} {  break  }
            foreach {tp tc nk hn uh} $item { break } ; puts $thifile "$nk $hn $uh $tp $tc"
           }
         }
       }
       set m10 0  ;  set mt [unixtime]
     }
     if {$hflver=="1"} {   close $thifile
       putlog "BogusTrivia History File Needs to be Updated! The code to do that is in the new Commands File."
       if {![file exists $t2(sfpath)t2.commands]} {
         putlog "Couldn't find t-2.tcl commands file: $t2(scrpath)t-2.commands.tcl"
       } else {  putlog "Existing t-2.tcl commands file needs to be updated."  }
       putlog "Put the included t-2.commands.tcl file in $t2(scrpath) & rehash the bot."
       putlog "\00310BogusTrivia\003 History File Not Being Saved Correctly!"   ;  return 0
     }
     set delme 0  ;  set isold [expr {[unixtime]-2764800}]
     set moveme 0  ;  set movels ""  ;  set doing 1  ;  set dwm ""
     while {![eof $thfold]} {  set temp [gets $thfold]
      if {$dwm ne "" && ![string match :N:* $temp]} {  set delme 0  ;  set moveme 0  ;  set dwm ""
        if {$doing=="1" && $cntda>"6" && $cntwe>"6" && $cntmo>"6"} {  incr doing
          puts $thifile "::X: Extra History:"
          if {$movels ne ""} {
            foreach hln $movels {  puts $thifile $hln  }   ;  set movels ""
          }
        }
      }
      if {[string match ::D:* $temp]} {  incr cntda  ;  set pc 0  ;  set dwm d
        if {$cntda>$t2(keepda)} {  set delme 1
        } else {  set kp [lindex $t2(dausrs) 1]
          if {$cntda>"7" && $doing=="1"} {  set moveme 1  ;  lappend movels $temp
          } else {  puts $thifile $temp  }
          if {$cntda=="1"} {  set kp [lindex $t2(dausrs) 0]
          } elseif {$cntda>"7" && [llength $t2(dausrs)]>"2"} {  set kp [lindex $t2(dausrs) 2]  }
        }
      } elseif {[string match ::W:* $temp]} {  incr cntwe  ;  set pc 0  ;  set dwm w
        if {$cntwe>$t2(keepwe)} {  set delme 1
        } else {  set kp [lindex $t2(weusrs) 1]
          if {$cntwe>"7" && $doing=="1"} {  set moveme 1  ;  lappend movels $temp
          } else {  puts $thifile $temp  }
          if {$cntwe=="1"} {  set kp [lindex $t2(weusrs) 0]
          } elseif {$cntwe>"7" && [llength $t2(weusrs)]>"2"} {  set kp [lindex $t2(weusrs) 2]  }
        }
      } elseif {[string match ::M:* $temp]} {  incr cntmo  ;  set pc 0  ;  set dwm m
        if {$cntmo>$t2(keepmo)} {  set delme 1
        } else {  set kp [lindex $t2(mousrs) 1]
          if {$cntmo>"7" && $doing=="1"} {  set moveme 1  ;  lappend movels $temp
          } else {  puts $thifile $temp  }
          if {$cntmo=="1"} {  set kp [lindex $t2(mousrs) 0]
          } elseif {$cntmo>"7" && [llength $t2(mousrs)]>"2"} {  set kp [lindex $t2(mousrs) 2]  }
        }
      } elseif {[string match :N:* $temp]} {  incr pc
        if {$delme>"0"} {  continue  }
        if {$pc>$kp} {  set delme 1  ;  continue  }
        if {$moveme>"0"} {  lappend movels $temp  } else {  puts $thifile $temp  }
      } else {
        if {$doing=="1"} {  incr doing  ;  puts $thifile "::X: Extra History:"
          if {$movels ne ""} {
            foreach hln $movels {  puts $thifile $hln  }  ;  set movels ""
          }
        }
        if {[string match ::X:* $temp] || $temp eq ""} {  continue  }
        if {[string match ::O:* $temp] && [lindex [split $temp] end]<$isold} {  continue  }
        puts $thifile $temp
      }
     }
     close $thifile  ;  close $thfold  ;  file delete $t2(sfpath)t2.hist
     file rename -force $t2(sfpath)t2.hst.tmp $t2(sfpath)t2.hist
     file delete $t2(sfpath)t2.hst.tmp  ;  set x $cntda  ;  set y $cntwe  ;  set z $cntmo
     set tmlist [list $x 1 12 $y 1 22 $x 2 13 $z 1 32 $x 3 14 $y 2 23]  ;  set hlist ""
     lappend tmlist $x 4 15 $z 2 33 $x 5 16 $y 3 24 $x 6 17 $z 3 34
     foreach {x y z} $tmlist {   if {$x>$y} { lappend hlist $z }   }
     if {[file exists $t2(sfpath)t2.hist.info]} {  set thifile [open $t2(sfpath)t2.hist.info]
       set hinfo [gets $thifile]  ;  close $thifile  ;  file delete $t2(sfpath)t2.hist.info
       set hinfo [split $hinfo]
       if {[TStrDig [lindex $hinfo 0]]} {
         foreach {x y} $hinfo {  break  }
         if {[llength $hinfo]>"2"} {  set z [lindex $hinfo end]  } else {  set y 0  ;  set z 0  }
       } else {  set x [unixtime]  ;  set y 0  ;  set z 0  }
     } else {  set x [unixtime]  ;  set y 0  ;  set z 0  }
     set thifile [open $t2(sfpath)t2.hist.info w]
     if {$hlist ne ""} {
       if {$y=="0"} {  set y 1  }  ;  if {$z=="0"} {  set z 1  }
       puts $thifile "$x $y [join $hlist] $z"
     } else {  puts $thifile "$x $y"  }
     close $thifile ; set tusfile [open $t2(sfpath)t2.users w]
     set tutmpfil [open $t2(sfpath)t2.usr.tmp]
     puts $tusfile "$nt $d10 $dt $w10 $wt $m10 $mt $e10 $uc"
     while {![eof $tutmpfil]} {  set temp [gets $tutmpfil]
      if {$temp != ""} {  puts $tusfile "$temp"  }
     }
     close $tutmpfil  ;  close $tusfile  ;  file delete $t2(sfpath)t2.usr.tmp
     if {$t2(-stats)>"0" && ($doda>"0" || $delrest>"0")} {  TSetStat  }
     if {[info exists t2(-html)] && $t2(-html) ne ""} {
       if {$dowe=="0" && $domo=="0"} {
         if {$t2(-html) eq "d" || $t2(-html) eq "d2"} {  set t2(hdowat) history  }
       } elseif {$dowe=="1" && $domo=="1"} {
         if {$t2(-html) eq "d" || $t2(-html) eq "d2"} {  set t2(hdowat) historywm
         } elseif {$t2(-html) eq "wm" || $t2(-html) eq "mw"} {  set t2(hdowat) historywm
         } elseif {$t2(-html) eq "w"} {  set t2(hdowat) historyw
         } elseif {$t2(-html) eq "m"} {  set t2(hdowat) historym  }
       } elseif {$dowe=="1"} {  set t2(hdowat) historywm
         if {$t2(-html) eq "d" || $t2(-html) eq "d2"} {  set t2(hdowat) historyw
         } elseif {$t2(-html) eq "wm" || $t2(-html) eq "w"} {  set t2(hdowat) historyw  }
       } elseif {$domo=="1"} {  set t2(hdowat) historywm
         if {$t2(-html) eq "d" || $t2(-html) eq "d2"} {  set t2(hdowat) historym
         } elseif {$t2(-html) eq "wm" || $t2(-html) eq "m"} {  set t2(hdowat) historym  }
       }
       if {[info exists t2(hdowat)]} {  source $t2(pwdpath)$t2(scrpath)t-2.html.tcl  }
     }
     if {$t2(-ison)=="1"} {  utimer 1 [list TSavHCont]  }
     return 0
   } elseif {$wat=="2"} {  set toplin ""  ;  set topln2 ""  ;  set topln3 ""
     if {$doda=="1" && $dals!=""} {  set count 0
      set topls [lsort -index 0 -integer -decreasing $dals]
      set toplin "$tclr(-d10) TODAYS Top 10 - "
      if {$t2(today)>"1" && [llength $topls]>"11"} {
        set topln2 "$tclr(-d10) TODAYS Top 11-20: - "  }
      if {$t2(today)>"2" && [llength $topls]>"21"} {
        set topln3 "$tclr(-d10) TODAYS Top 21-30: - "  }
      foreach topusr $topls {  incr count
       foreach {tp tc nk hn uh} $topusr { break }
       set tnick [string range $nk 3 end]
       if {$count<"11"} {
         append toplin "$tclr(-d11) \002#$count:\002 $tclr(-d12) $tnick $tp "
       } elseif {$count<"21"} {
         if {$topln2!=""} {
           append topln2 "$tclr(-d11) \002#$count:\002 $tclr(-d12) $tnick $tp "  }
       } elseif {$count<"31"} {
         if {$topln3!=""} {
           append topln3 "$tclr(-d11) \002#$count:\002 $tclr(-d12) $tnick $tp "  }
       }
       if {$count=="30"} { set d10 $tp  ;  break  }
      }
      if {$count<"30" && $d10>"0"} {  set d10 [expr {round("$d10.0"-($d10/6))}]  }
     } elseif {$dowe=="1" && $wels!=""} {  set count 0
      set topls [lsort -index 0 -integer -decreasing $wels]
      set toplin "$tclr(-w10) This WEEKS Top 10 - "
      if {$t2(today)>"1" && [llength $topls]>"11"} {
        set topln2 "$tclr(-w10) This WEEKS Top 11-20: - "  }
      if {$t2(today)>"2" && [llength $topls]>"21"} {
        set topln3 "$tclr(-w10) This WEEKS Top 21-30: - "  }
      foreach topusr $topls {  incr count
       foreach {tp tc nk hn uh} $topusr { break }
       set tnick [string range $nk 3 end]
       if {$count<"11"} {
         append toplin "$tclr(-w11) \002#$count:\002 $tclr(-w12) $tnick $tp "
       } elseif {$count<"21"} {
         if {$topln2!=""} {
           append topln2 "$tclr(-w11) \002#$count:\002 $tclr(-w12) $tnick $tp "  }
       } elseif {$count<"31"} {
         if {$topln3!=""} {
           append topln3 "$tclr(-w11) \002#$count:\002 $tclr(-w12) $tnick $tp "  }
       }
       if {$count=="30"} { set w10 $tp  ;  break }
      }
      if {$count<"30" && $w10>"0"} {  set w10 [expr {round("$w10.0"-($w10/6))}]  }
     } elseif {$domo=="1" && $mols!=""} {  set count 0
      set topls [lsort -index 0 -integer -decreasing $mols]
      set toplin "$tclr(-m10) This MONTHS Top 10 - "
      if {$t2(today)>"1" && [llength $topls]>"11"} {
        set topln2 "$tclr(-m10) This MONTHS Top 11-20: - "  }
      if {$t2(today)>"2" && [llength $topls]>"21"} {
        set topln3 "$tclr(-m10) This MONTHS Top 21-30: - "  }
      foreach topusr $topls {  incr count
       foreach {tp tc nk hn uh} $topusr { break }
       set tnick [string range $nk 3 end]
       if {$count<"11"} {
         append toplin "$tclr(-m11) \002#$count:\002 $tclr(-m12) $tnick $tp "
       } elseif {$count<"21"} {
         if {$topln2!=""} {
           append topln2 "$tclr(-m11) \002#$count:\002 $tclr(-m12) $tnick $tp "  }
       } elseif {$count<"31"} {
         if {$topln3!=""} {
           append topln3 "$tclr(-m11) \002#$count:\002 $tclr(-m12) $tnick $tp "  }
       }
       if {$count=="30"} { set m10 $tp  ;  break }
      }
      if {$count<"30" && $m10>"0"} {  set m10 [expr {round("$m10.0"-($m10/6))}]  }
     } elseif {$doev=="1" && $evls!=""} {  set count "0"
      set topls [lsort -index 0 -integer -decreasing $evls]
      set toplin "$tclr(-e10) TOP 10 PLAYERS - "
      if {$t2(today)>"1" && [llength $topls]>"11"} {
          set topln2 "$tclr(-e10) Top PLAYERS 11-20: - "  }
      if {$t2(today)>"2" && [llength $topls]>"21"} {
          set topln3 "$tclr(-e10) Top PLAYERS 21-30: - "  }
      foreach topusr $topls {  incr count
       foreach {tp tc nk hn uh} $topusr { break }
       set tnick [string range $nk 3 end]
       if {$count<"11"} {
         append toplin "$tclr(-e11) \002#$count:\002 $tclr(-e12) $tnick $tp "
       } elseif {$count<"21"} {
         if {$topln2!=""} {
           append topln2 "$tclr(-e11) \002#$count:\002 $tclr(-e12) $tnick $tp "  }
       } elseif {$count<"31"} {
         if {$topln3!=""} {
           append topln3 "$tclr(-e11) \002#$count:\002 $tclr(-e12) $tnick $tp "  }
       }
       if {$count=="30"} { set e10 $tp  ;  break }
      }
      if {$count<"30" && $e10>"0"} {  set e10 [expr {round("$e10.0"-($e10/6))}]  }
     }
     set tutmpfil [open $t2(sfpath)t2.usr.tmp w]
     puts $tutmpfil "$nt $d10 $dt $w10 $wt $m10 $mt $e10 $uc"
     set tusfile [open $t2(sfpath)t2.users]  ;  set tulin0 [gets $tusfile]
     while {![eof $tusfile]} {  set temp [gets $tusfile]
      if {$temp ne ""} { puts $tutmpfil "$temp" }
     }
     close $tutmpfil  ;  close $tusfile ; file delete $t2(sfpath)t2.users
     file rename $t2(sfpath)t2.usr.tmp $t2(sfpath)t2.users
     if {$toplin ne ""} {  putquick "PRIVMSG $t2(chan) :$toplin"
       if {$topln3 ne "" && $t2(-ptime)>"7"} {  utimer $t2(-stime) [list TShoLine $topln2 $topln3]
       } elseif {$topln2 ne ""} {  utimer $t2(-stime) [list TShoLine $topln2]  }
     }
   }
 }
}
proc TSavHCont {} {  global t2 tclr botnick nick  ;  TSavUsers  ;  TDoHInfo  }
proc TOnOff {nk uh hn ch tx {from 0} } {  global t2 tclr botnick nick
 if {![file exists $t2(sfpath)t2.settings]} {  set temp [TSetup $nk $uh $hn 1 1]
   if {$temp=="0"} {  return 0  }
 }
 if {$t2(-ison)=="0"} {
   if {$from>"0" && $tx eq "0"} {  return 0  }
   if {$from=="0" && ![string match -nocase $t2(on) $tx]} {  return 0  }
   if {$t2(-hbound)=="1"} { TBind h u } ; if {$t2(-qbound)=="1"} { TBind q u }
   if {$t2(-abound)=="1"} { TBind a u } ; TCntQes
   if {$t2(-qfcnt)=="0"} {
    putserv "PRIVMSG $ch :$t2(script): No questions loaded."  ;  return 0
   }
   if {$t2(limit)>"0"} {  set t2(-lchek) 1  }
   set t2(-ison) 1  ;  set updat 0 ; TDoHInfo
   if {[file exists $t2(sfpath)t2.users]} {  set isnewus 0
     set tusfile [open $t2(sfpath)t2.users] ; set tlin0 [gets $tusfile] ; close $tusfile
     if {[string match ::N:* $tlin0]} {  set updat 1  }
   } else {  TSavUsers  ;  set isnewus 1  }
   set wasbad [TSavActiv 0 $updat]
   if {$from=="5"} {  set t2(-aon) $hn
   } else {  putquick "PRIVMSG $ch :Tietovisa aloitettu. Ladataan kysymyksiä..."  }
   set t2(-htime) $t2(qtime)  ;  set t2(-ptime) $t2(ptime)  ;  set t2(-stime) $t2(stime)
   array set t2 {-shorand 0 -randcnt 0 -shoda10 0 -showe10 0 -shomo10 0 -shoev10 0}
   array set t2 {-shohist 0 -qansrd 0 -qmissd 0 -utrigd 1 -udead 0 -shoad 0}
   array set t2 {-shobons 0 -lastbns 0 -qtimer "" -otimer "" -qstart "" -dosave 0}
   array set t2 {-preqes "" -active ""}
   if {$isnewus=="0" || $wasbad=="1"} {  TSavUsers  }
   TAddHEvent [list "::O:on $nk $hn $uh [unixtime]"]
   TBind s  ;  bind time - "* * * * *" TBndTime
   if {[string length $t2(-qcount)]<"4"} { set tmcnt $t2(-qcount)
   } else {  set tmcnt [string trimleft [string range $t2(-qcount) end-2 end] 0]
     if {$tmcnt==""} {  set tmcnt 0  }
   }
   set qflcnt 0 ; set t2(-opnfil) [open $t2(-qflnow)]
   if {$tmcnt!="0"} {
     while {![eof $t2(-opnfil)] && $qflcnt<$tmcnt} {
      set qfline [gets $t2(-opnfil)]  ;  incr qflcnt  }
     if {$qfline == ""} {  set t2(-ison) 0  ;  return 0  }
   }
   if {$t2(kaos)>"0"} {
    if {$t2(-iskaos)=="0"} {
     if {$t2(kaos)>"5"} {   set t2(-iskaos) [expr {($t2(kaos)-4)-[rand 3]}]
      if {$t2(-iskaos)<"1"} {  set t2(-iskaos) $t2(kaos)  }
     } else {  set t2(-iskaos) $t2(kaos)  }
    }
    set tmc2 -1  ;  set stopat [expr {$t2(-kcount)-1}]
    foreach tmkfl $t2(-kfills) {
     if {$tmkfl==$t2(-kflnow)} {  break  }
     set temp [split [lindex [split $tmkfl /] end] .]
     if {[llength $temp]=="3"} {  incr tmc2 1000
     } else {  incr tmc2 [lindex $temp 3]  }
    }
    set t2(-opnkfil) [open $t2(-kflnow)]  ;  set kfline :start:
    while {![eof $t2(-opnkfil)]} {
     if {$tmc2==$stopat} {  break  }
     set kfline [gets $t2(-opnkfil)]  ;  incr tmc2
    }
    if {$kfline == ""} {  set t2(-ison) 0  ;  return 0  }
   }
   if {[info exists t2(-hactv)]} {  set t2(-hcnt) 0  ;  set t2(-hnew) 0  }
   set t2(-hntnum) -1  ;  TShoTriv -1
 } else {
   if {$from>"0" && $tx=="1"} {  return 0  }
   if {$from=="0" && ![string match -nocase $t2(off) $tx]} {  return 0  }
   if {$t2(-hbound)=="1"} { TBind h u }  ;  if {$t2(-qbound)=="1"} { TBind q u }
   if {$t2(-abound)=="1"} { TBind a u }  ;  set t2(-ison) 0
   if {$t2(autostart)>"0" && $from=="0"} {  set t2(-aoff) 0  }
   TKillTimers
   foreach tmr [utimers] {  set prc [lindex $tmr 1 0]
    if {$prc eq "TSavActiv" || $prc eq "TMkLines"} {  killutimer [lindex $tmr 2]  }
   }
   set t2(-qtimer) ""  ;  set t2(-otimer) ""  ;  TBind s u  ;  unbind time - "* * * * *" TBndTime
   close $t2(-opnfil)  ;  if {$t2(kaos)>"0"} {  close $t2(-opnkfil)  }
   if {$t2(kaos)>"0" && $t2(-iskaos)==$t2(kaos)} {
     if {[info exists t2(-kusrls)] && $t2(-kusrls) ne ""} {  TSavActiv nk u@h hn apnt 1 2  }
   } else {
     if {[info exists t2(-notsaved)]} {
       foreach {nik ush hnd apnt} $t2(-notsaved) {  break  }
       TSavActiv $nik $ush $hnd $apnt 2 0
     }
   }
   TSavUsers 1  ;  file delete $t2(sfpath)t2.recent
   TAddHEvent [list "::O:off $nk $hn $uh [unixtime]"]
   array set t2 {-hint "" -hnt2 "" -hnt3 "" -uhint "" -uhnt2 "" -uhnt3 ""}
   array set t2 {-points "" -questn "" -quesn2 "" -answer "" -uqes "" -uqs2 "" -preqes ""}
   if {[info exists t2(-allansls)]} { unset t2(-allansls) }
   if {[info exists t2(-kusrls)]} { unset t2(-kusrls) }
   if {[info exists t2(-kansls)]} { unset t2(-kansls) }
   if {[info exists t2(-kanstot)]} { unset t2(-kanstot) }
   if {[info exists t2(-kgotpnts)]} { unset t2(-kgotpnts) }
   if {[info exists t2(-kbon)]} { unset t2(-kbon) }
   if {[info exists t2(-hactv)]} {
     if {$t2(-hnew)>"0"} {
       set t2(hdowat) active  ;  source $t2(pwdpath)$t2(scrpath)t-2.html.tcl
     }
     unset t2(-hcnt)  ;  unset t2(-hnew)
   }
   if {[info exists t2(-dobakup)]} {
     if {$t2(-dobakup)=="1"} {
       if {$t2(bakupu)>"0"} {  TBakUp u 0  }  ;  if {$t2(bakuph)>"0"} {  TBakUp h 0  }
     } else {  TBakUp u 0  }
     unset t2(-dobakup)
   }
   putquick "PRIVMSG Tietovisa pysäytetty."
 }
}
proc TRanking {pls len {how 1} {ho2 1} } {  global t2  ;  set new ""  ;  set tls ""  ;  set tnum 0
 if {$pls eq ""} {  return $pls  }
 if {$how=="2"} {  set pls [lsort -index 1 -integer -decreasing $pls]
 } else {  set pls [lsort -index 0 -integer -decreasing $pls]  }
 lappend pls [list 0 0 0 0]
 foreach usr $pls {
  if {$tnum=="0"} {  lappend tls $usr
    if {$how=="2"} {  set tnum [lindex $usr 1]  } else {  set tnum [lindex $usr 0]  }
  } elseif {$how=="2" && [lindex $usr 1]==$tnum} {  lappend tls $usr
  } elseif {$how=="1" && [lindex $usr 0]==$tnum} {  lappend tls $usr
  } else {
    if {[llength $tls]>"1"} {
      if {$ho2=="2"} {  
        if {$how=="2"} {  set tls [lsort -index 0 -integer -decreasing $tls]
        } else {  set tls [lsort -index 1 -integer -increasing $tls]  }
      } else {  set tls [lsort -index 3 -integer -increasing $tls]  }
    }
    foreach tu $tls {  lappend new $tu  }  ;  set tls ""  ;  lappend tls $usr
    if {$how=="2"} {  set tnum [lindex $usr 1]  } else {  set tnum [lindex $usr 0]  }
  }
 }
 if {[llength $new]>$len} {  set new [lreplace $new $len end]  }
 return $new
}
proc TGotIt {nk uh hn ch tx} {  global t2 tclr botnick  ;  set iskaos 0
 if {$t2(limit)>"0" && $t2(-limls) ne ""} {  set stop 0  ;  set lnk [TStrLo $nk]
   if {[set fnd [lsearch $t2(-limls) ":nk:*,$lnk,*:hn:*"]]>"-1"} { set stop 1 }
   if {$stop=="0" && $hn ne "*"} {  set lhn [TStrLo $hn]
     if {[set fnd [lsearch $t2(-limls) "*:hn:*,$lhn,*:uh:*"]]>"-1"} { set stop 1 }
   }
   if {$stop=="0" && $t2(l-match)>"0"} {  set luh [string trimleft [TStrLo $uh] ~]
     if {$t2(l-match)=="3"} {  set msk *,$luh,*
     } else {   foreach {un hs} [split $luh @] { break }
       if {$t2(l-match)=="1"} {  set msk *,*@$hs,*  } else {  set msk *,$un@*,*  }
     }
     if {[set fnd [lsearch $t2(-limls) "*:uh:${msk}:end:*"]]>"-1"} { set stop 1 }
   }
   if {$stop=="1"} {
     if {$t2(l-rnum)>"0"} {  set num [string index [set dat [lindex $t2(-limls) $fnd]] end]
       if {$num<$t2(l-rnum)} {  incr num  ;  set map [list %n $nk %l $t2(limit)]
         foreach line $t2(l-rtxt) {  putserv "NOTICE $nk :[string map $map $line]"  }
         set t2(-limls) [lreplace $t2(-limls) $fnd $fnd [string range $dat 0 end-1]$num]
       }
     }
     return 0
   }
 }
 if {$t2(kaos)>"0" && $t2(-iskaos)==$t2(kaos)} {  set iskaos 1  }
 set temp -1  ;  set fnd 0
 foreach x $t2(-allansls) {
  if {$fnd=="0"} {  incr temp  }
  if {[string equal -nocase $x $tx]} {  incr fnd
    if {$fnd=="2"} {  set nerp 1  ;  break  }
  }
 }
 if {$fnd<"1"} {  return 0  }
 if {$t2(limit)>"0"} {  set t2(-lchek) 1  }
 unset x  ;  set uh [string trimleft $uh ~]  ;  array set t2 {-utrigd 1 -udead 0}
 if {[info exists t2(-hactv)]} {  incr t2(-hnew)  }
 if {$iskaos=="1"} {  set endnow 0
   if {[llength $t2(-allansls)]=="1"} {  set endnow 1
   } else {  set t2(-allansls) [lreplace $t2(-allansls) $temp $temp]  }
 } else {  set endnow 1  }
 if {$endnow=="1"} {  TKillTimers  ;  set t2(-qtimer) ""
   if {$t2(-hbound)=="1"} {  TBind h u  }
   if {$t2(-qbound)=="1"} {  TBind q u  }
   set qestime [expr {[clock clicks -milliseconds]-$t2(-qstart)}]
   if {[string length $qestime]=="1"} {  set qestime 000$qestime
   } elseif {[string length $qestime]=="2"} {  set qestime 00$qestime
   } elseif {[string length $qestime]=="3"} {  set qestime 0$qestime  }
   set qestime [string range $qestime 0 end-3].[string range $qestime end-2 end]
 }
 if {$iskaos=="1"} {  set temp -1  ;  set fnd 0
   foreach {x1 x2 x3 x4} $t2(-kansls) {  incr temp 4
    if {[string equal -nocase $x1 $tx]} {  set fnd 1  ;  break  }
   }
   if {$fnd>"0"} {  set tmp2 [lindex $t2(-kansls) $temp]  ;  incr temp -3  }
   if {$endnow=="1"} {  TBind a u
   } else {
     if {![info exists nerp]} {  
        unbind pubm $t2(pflag) "$t2(chan) $t2($tmp2)" TGotIt  }
     if {$tmp2 eq "-answer"} {  set t2(-answer) ""
     } else {  array unset t2 $tmp2  }
   }
   set t2(-kansls) [lreplace $t2(-kansls) $temp [expr {$temp+3}]]
   if {$t2(-points)=="1"} {  set point point  } else {  set point points  }
   putquick "PRIVMSG $ch :$tclr(-ktu) $nk saa $t2(-points) $points vastauksesta: $tclr(-ktu2) $tx "
   incr t2(-kgotpnts) $t2(-points)
   if {$t2(-kusrls) eq ""} {  set t2(-kusrls) [list $nk $hn $uh $t2(-points) 1]
   } else {  set kfnd 0  ;  set nidx 0
     foreach {n h u p c} $t2(-kusrls) {
      if {[TStrLo $nk] eq [TStrLo $n]} {  set kfnd 1  ;  break  }
      if {$t2(match)>"0" && $hn ne "*" && $hn eq $h} {  set kfnd 2  ;  break  }
      if {$t2(match)>"0" && $uh eq $u} {  set kfnd 3  ;  break  }
      incr nidx 5
     }
     if {$kfnd>"0"} {  set end [expr {$nidx+4}]
       incr c  ;  set p [expr {round("$p.0"+$t2(-points))}]
       if {$t2(match)=="1" && $hn eq "*"} {  set hn $h  }
       set t2(-kusrls) [lreplace $t2(-kusrls) $nidx $end $nk $hn $uh $p $c]
     } else {  lappend t2(-kusrls) $nk $hn $uh $t2(-points) 1  }
   }
   if {$endnow=="1"} {  set newaddls $t2(-kusrls)  }
 } else {
   if {$t2(-abound)=="1"} {  TBind a u  }
   if {$t2(descend)=="0"} {  set points $t2(-points)
   } elseif {$t2(-hntnum)=="1"} {  set points $t2(-points)
   } elseif {$t2(-hntnum)=="2"} {  set points [expr {round($t2(-points)/2.0)}]
   } else {  set points [expr {round([expr {round($t2(-points)/2.0)}]/2.0)}]  }
   set say "$tclr(-tu2) KYLLÄ,$tclr(-tu1) $nk $tclr(-tu2)vastasi oikein ->$tclr(-tu1) $tx $tclr(-tu2)<- in$tclr(-tu1)"
   if {$points=="1"} {  set p point  } else {  set p points  }
   #putquick "PRIVMSG $ch :$say $qestime $tclr(-tu2)sekuntia ja saa$tclr(-tu1) pistettä $tclr(-tu2)$p "
   putquick "PRIVMSG $ch :$say $qestime $tclr(-tu2)sekuntia ja saa$tclr(-tu1) $points $tclr(-tu2)$p "
   set newaddls [list $nk $hn $uh $points 1]
   if {[string match -nocase "$nk *" $t2(-qansrd)]=="1"} {
     set anscnt [expr { [lindex [split $t2(-qansrd)] 1]+1 }] ; set t2(-qansrd) "$nk $anscnt"
   } else {  set anscnt 1  ;  set t2(-qansrd) "$nk 1"  }
   set pstr "$tclr(-tu1) $nk $tclr(-tu2)on vastannut oikein$tclr(-tu1) $anscnt $tclr(-tu2)kysymystä putkeen! "
 }
 if {$endnow=="1"} {
   if {$iskaos=="1"} {  set opt 1
     set kalltx "$tclr(-ktu) Onnittelut, $tclr(-ktu2)Arvasit kaikki!"
     if {[llength $newaddls]>"5" && $t2(-kbon)>"0"} {
       append kalltx " $tclr(-kbon) Kaikki saa$tclr(-kbon2) $t2(-kbon) pisteen $tclr(-kbon)bonusta! "
       set newaddl2 ""
     } else {  append kalltx "! "  ;  set t2(-kbon) 0  }
   }
   foreach {anik ahan aush apnt acnt} $newaddls {
    if {$iskaos=="1"} {
      if {$t2(-kbon)=="0"} {  break  }
      set t2(-kgotpnts) [expr { round("$t2(-kgotpnts).0"+$t2(-kbon)) }]
      set apnt [expr { round("$apnt.0"+$t2(-kbon)) }]
      lappend newaddl2 $anik $ahan $aush $apnt $acnt
    } else {  set fnd 0  ;  set nidx 0
      foreach {fnk fn2 fhn fuh fu2 da we mo} $t2(-active) {
       if {[TStrLo $anik] eq $fnk} {  set fnd 1  ;  break  }
       if {$t2(match)>"0" && $fhn ne "*" && [TStrLo $ahan] eq $fhn} {  set fnd 2  ;  break  }
       if {$t2(match)>"0" && [TStrLo $anik] eq $fn2} {  set fnd 3  ;  break  }
       if {$t2(match)>"0" && ([TStrLo $aush] eq $fuh || [TStrLo $aush] eq $fu2)} { set kfnd 4 ; break }
       incr nidx 8
      }
      if {$fnd>"0"} {  set end [expr {$nidx+7}]  ;  set opt 0
        set da [expr {round("$da.0"+$apnt)}] ;  set we [expr {round("$we.0"+$apnt)}]
        set mo [expr {round("$mo.0"+$apnt)}]
        if {[TStrLo $anik] ne $fnk && [TStrLo $anik] ne $fn2} {  set opt 1
        } elseif {[TStrLo $aush] ne $fuh && [TStrLo $aush] ne $fu2} {  set opt 1
        } elseif {$t2(match)=="0" && [TStrLo $ahan] ne $fhn} {  set opt 1
        } elseif {$t2(match)=="1" && $ahan ne "*" && [TStrLo $ahan] ne $fhn} {  set opt 1
        } else {   set t2(-active) [lreplace $t2(-active) $nidx $end]
          set t2(-active) [linsert $t2(-active) 0 $fnk $fn2 $fhn $fuh $fu2 $da $we $mo]
        }
        putquick "PRIVMSG $ch :$pstr Yhteensä Pisteitä TÄNÄÄN:$tclr(-tu1) $da $tclr(-tu2) tällä VIIKOLLA:$tclr(-tu1) $we $tclr(-tu2) & tässä KUUSSA:$tclr(-tu1) $mo "
      } else {  putquick "PRIVMSG $ch :$pstr"  ;  set opt 1  }
    }
   }
   if {$iskaos=="1"} {
     if {$t2(-kbon)>"0"} {  set t2(-kusrls) $newaddl2  }
     if {$t2(-kgotpnts)=="1"} {  set point Point  } else {  set point Points  }
     set kstats "$tclr(-kstat) Yhteensä:$tclr(-ksta2) $t2(-kgotpnts) $points "
     if {[llength $t2(-kusrls)]>"5"} {
       append kstats "$tclr(-kstat)[expr {[llength $t2(-kusrls)]/5}] pelaajalle "
     }
     putquick "PRIVMSG $t2(chan) :$kalltx" ; putquick "PRIVMSG $t2(chan) :$kstats"
   }
   array set t2 {-hint "" -hnt2 "" -hnt3 "" -uhint "" -uhnt2 "" -uhnt3 ""}
   array set t2 {-points "" -questn "" -quesn2 "" -answer "" -uqes "" -uqs2 "" -utrigd 1 -udead 0}
   array set t2 {-allansls ""}
   if {$iskaos=="1"} {  unset t2(-kansls) t2(-kanstot) t2(-kgotpnts) t2(-kbon)  }
   set t2(-htime) $t2(qtime)  ;  set t2(-ptime) $t2(ptime)  ;  set t2(-stime) $t2(stime)
   if {$t2(dobonus)>"0"} {
     if {$t2(-lastbns)<$t2(dobonus)} {  incr t2(-lastbns)
     } else {  set t2(-lastbns) 0  ;  incr t2(-shobons)  }
   }
   if {$t2(kaos)>"0"} {
    if {$t2(-iskaos)>=$t2(kaos)} {  set t2(-iskaos) 1
    } else {  incr t2(-iskaos)  }
   }
   incr t2(-hntnum)
   set t2(-qtimer) [utimer $t2(-ptime) [list TShoTrv2]]
   set t2(-otimer) [utimer $t2(-stime) [list TSavActiv $nk $uh $hn $apnt $opt $iskaos]]
   if {$iskaos=="0"} {  set t2(-notsaved) [list $nk $uh $hn $apnt]  }
 }
}
proc TPQues {nk uh hn ch tx} {  global t2 tclr
 TBind q u  ;  putserv "PRIVMSG $ch :$t2(-uqes)"  ;  set t2(-uqes) ""
 if {$t2(-uqs2) ne ""} {  putserv "PRIVMSG $ch :$t2(-uqs2)"  ;  set t2(-uqs2) ""  }
 array set t2 {-utrigd 1 -udead 0}
 set t2(-htime) $t2(qtime)  ;  set t2(-ptime) $t2(ptime)  ;  set t2(-stime) $t2(stime)
}
proc TDoHint {nk uh hn ch tx} {  global t2 tclr botnick  ;  TBind h u
 if {$t2(-hntnum)=="1"} {
   putserv "PRIVMSG $ch :$tclr(-hnt1) Vihje:$tclr(-hnt2) $t2(-uhint) " ; set t2(-uhint) ""
 } elseif {$t2(-hntnum)=="2"} {
   putserv "PRIVMSG $ch :$tclr(-hnt1) Vihje:$tclr(-hnt2) $t2(-uhnt2) " ; set t2(-uhnt2) ""
 } else {
   putserv "PRIVMSG $ch :$tclr(-hnt1) Vihje:$tclr(-hnt2) $t2(-uhnt3) " ; set t2(-uhnt3) "" }
 array set t2 {-utrigd 1 -udead 0}
 set t2(-htime) $t2(qtime)  ;  set t2(-ptime) $t2(ptime)  ;  set t2(-stime) $t2(stime)
}
proc TAddHEvent {els} {  global t2 botnick
 if {![file exists $t2(sfpath)t2.hist]} {  TDoHInfo  }
 set thifold [open $t2(sfpath)t2.hist]  ;  set ln1 [gets $thifold]
 if {[string match ::N:* $ln1]} {  close $thifold
   if {![file exists $t2(sfpath)t2.commands]} {  set stop 1
   } else {  set open [open $t2(sfpath)t2.commands]
     set cver [string range [gets $open] 3 6]  ;  close $open
     if {![TStrDig $cver] || $cver<"2063"} {  set stop 2
     } else {  set t2(_cm) h  ;  source $t2(sfpath)t2.commands  }
   }
   if {[info exists stop]} {  set thifold [open $t2(sfpath)t2.hist a]
     foreach ev $els {  puts $thifold $ev  }  ;  close $thifold  ;  return $stop
   }
   set thifold [open $t2(sfpath)t2.hist]  ;  set ln1 [gets $thifold]
 }
 set thifile [open $t2(sfpath)t2.hst.tmp w]  ;  puts $thifile $ln1
 while {![eof $thifold]} {  set temp [gets $thifold]
  if {$temp ne ""} {  puts $thifile $temp  }
  if {[string match ::X:* $temp]} {
    foreach ev $els {  puts $thifile $ev  }  ;  set els ""
  }
 }
 if {$els ne ""} {  puts $thifile "::X: Ekstra-historiaa:"
   foreach ev $els {  puts $thifile $ev  }
 }
 close $thifold  ;  close $thifile  ;  file delete $t2(sfpath)t2.hist
 file rename -force $t2(sfpath)t2.hst.tmp $t2(sfpath)t2.hist
 file delete $t2(sfpath)t2.hst.tmp  ;  return 0
}
proc TShoTriv { {expect unk} } {  global t2 tclr botnick
 if {$t2(-ison)=="0"} {  return 0  }  ;  set iskaos 0
 if {$expect ne "unk"} {
   if {$expect!=$t2(-hntnum)} {  return 0  }
 }
 if {$t2(kaos)>"0" && $t2(-iskaos)==$t2(kaos)} {  set iskaos 1  }
 if {$t2(-hntnum)>=$t2(hntcnt) || $t2(-hntnum)=="-1" || $t2(-hntnum)=="-2"} {  set istop 0
   if {$t2(-hntnum)=="-1"} {
     if {![info exists t2(-aon)]} {  set t2(-qtimer) [utimer 8 [list TShoTriv 0]]
     } else {  set t2(-qtimer) [utimer $t2(-aon) [list TShoTriv 0]]  ;  unset t2(-aon)  }
   } elseif {$t2(-hntnum)=="-2"} {  return 0
   } else {
     if {$t2(-utrigd)=="0" && ($t2(qslow)=="0" || $t2(rest)=="0")} {  set x $t2(-udead)  ;  incr x
       if {$x>=$t2(rqcnt) || ($x>=$t2(sqcnt) && $t2(qslow)=="0")} { set istop 1 }
     }
     if {$istop=="0"} {  set t2(-qtimer) [utimer $t2(-ptime) [list TShoTriv 0]]  }
     if {$iskaos=="1"} {  set kleft [expr {[llength $t2(-kansls)]/4}]
       set kgot [expr {$t2(-kanstot)-$kleft}]  ;  set kusrs [expr {[llength $t2(-kusrls)]/5}]
       if {$t2(givkaos)!="0"} {  set ktutmp "$tclr(-ktu) Aika loppu! $tclr(-ktu2) Kukaan ei osannut $tclr(-kng) "
         foreach {kans hn2 hn3 kvar} $t2(-kansls) {  append ktutmp "\[$kans\] "  }
       } else {  set ktutmp "$tclr(-ktu2) Aika loppu! "  }
       putquick "PRIVMSG $t2(chan) :$ktutmp"
       if {$kgot>"0"} {
         set ktutm2 "$tclr(-kstat) Oikeat vastaukset:$tclr(-ksta2) $kgot / $t2(-kanstot) "
         if {$t2(-kgotpnts)=="1"} {  set point Point  } else {  set point Points  }
         append ktutm2 "$tclr(-kstat) Yhteensä:$tclr(-ksta2) $t2(-kgotpnts) $points "
         if {$kusrs>"1"} {  append ktutm2 "$tclr(-kstat) $kusrs pelaajalle "  }
         putquick "PRIVMSG $t2(chan) :$ktutm2"
       }
     } else {  set ansr ""
       if {$t2(givansr)!="0"} { set ansr "$tclr(-tu2) Vastaus oli -> $tclr(-tu1) $t2(-answer) $tclr(-tu2) <- " }
       putquick "PRIVMSG $t2(chan) :$tclr(-tu1) Aika loppu! $ansr"
     }
   }
   if {$t2(-hntnum)>"-1" && $iskaos=="1" && $kgot>"0"} {
     set t2(-otimer) [utimer $t2(-stime) [list TSavActiv nk u@h hn apnt 1 1]]
   } else {
     if {$istop=="0"} {  set t2(-otimer) [utimer $t2(-stime) [list TMkLines]]  }
     if {$t2(-hntnum)>"-1" && $iskaos=="1"} {  unset t2(-kusrls)  }
   }
   if {$t2(-abound)=="1"} { TBind a u }
   if {$t2(-qbound)=="1"} { TBind q u } ;  if {$t2(-hbound)=="1"} { TBind h u }
   array set t2 {-hint "" -hnt2 "" -hnt3 "" -uhint "" -uhnt2 "" -uhnt3 ""}
   array set t2 {-points "" -questn "" -quesn2 "" -answer "" -uqes "" -uqs2 "" -hntnum 0}
   set t2(-allansls) ""
   if {$iskaos=="1"} {
      if {[info exists t2(-kanstot)]} { unset t2(-kanstot) }
      if {[info exists t2(-kansls)]} { unset t2(-kansls) }
      if {[info exists t2(-kgotpnts)]} { unset t2(-kgotpnts) }
      if {[info exists t2(-kbon)]} { unset t2(-kbon) }
   }
   if {$t2(dobonus)>"0"} {
     if {$t2(-lastbns)<$t2(dobonus)} {  incr t2(-lastbns)
     } else {  set t2(-lastbns) 0  ;  incr t2(-shobons)  }
   }
   if {$t2(kaos)>"0"} {
     if {$t2(-iskaos)>=$t2(kaos)} {  set t2(-iskaos) 1
     } else {
       if {$t2(krest)=="1"} {
         if {$t2(-udead)<$t2(rqcnt)} {  incr t2(-iskaos)  }
       } elseif {$t2(krest)>"1"} {
         if {$t2(-udead)<$t2(sqcnt)} {  incr t2(-iskaos)  }
       } else {  incr t2(-iskaos)  }
     }
   }
   if {$istop=="1"} {
     if {$t2(autostart)>"0"} {  set t2(-aoff) 1  }
     TOnOff $botnick idle stop $t2(chan) 0 4
   }
 } elseif {$t2(-hntnum)=="0" || $t2(-hntnum)=="-3"} {
  if {$t2(-preqes) ne ""} {
      putquick "PRIVMSG $t2(chan) :$tclr(-randad) $t2(-preqes) "  ;  set t2(-preqes) ""  }
  putquick "PRIVMSG $t2(chan) :$t2(-questn)"
  if {$t2(-quesn2) ne ""} {  putquick "PRIVMSG $t2(chan) :$t2(-quesn2)"  }
  putquick "PRIVMSG $t2(chan) :$t2(-hint)"
  if {$t2(-uhint) ne ""} { TBind h } ;  TBind a ;  set t2(-qstart) [clock clicks -milliseconds]
  if {$iskaos=="1"} {  incr t2(-kcount)  ;  set tkcntfil [open $t2(sfpath)t2.kcount w]
    puts $tkcntfil "$t2(-kcount)"  ;  close $tkcntfil  ;  set sec $t2(ktime)
    if {$t2(-udead)>=$t2(sqcnt) && $t2(-htime)>$t2(ktime)} {  set sec $t2(-htime)  }
    set t2(-qtimer) [utimer $sec [list TShoTriv 1]]
  } else {  incr t2(-qcount)  ;  set tqcntfil [open $t2(sfpath)t2.qcount w]
    puts $tqcntfil "$t2(-qcount)" ; close $tqcntfil
    set t2(-qtimer) [utimer $t2(-htime) [list TShoTriv 1]]
  }
  set t2(-hntnum) 1
 } elseif {$t2(-hntnum)=="1"} {  set t2(-hntnum) 2
  if {$iskaos=="1"} {  set sec $t2(ktime)  ;  set doshort 0
    if {$t2(-udead)>=$t2(sqcnt) && $t2(-htime)>$t2(ktime)} {  set sec $t2(-htime)  }
    set t2(-qtimer) [utimer $sec [list TShoTriv 2]]
    if {$t2(krest)=="1" && $t2(-udead)>=$t2(rqcnt)} {  set doshort 1
    } elseif {$t2(krest)>"1" && $t2(-udead)>=$t2(sqcnt)} {  set doshort 1  }
    set t2(-hnt2) "$tclr(-khnt) Toinen vihje:$tclr(-khnt2)"
    if {$t2(kstyle)>"1" || $doshort=="1"} {  set kleft [expr {[llength $t2(-kansls)]/4}]
      if {$kleft==$t2(-kanstot)} {  append t2(-hnt2) " Kaikki vastaukset jäljellä "
      } elseif {$kleft=="1"} {  append t2(-hnt2) " Yksi vastaus jäljellä "
      } else { append t2(-hnt2) " $kleft of $t2(-kanstot) Vastauksia jäljellä "  }
      if {$t2(-points)=="1"} {  set point Point  } else {  set point Points  }
      if {$kleft=="1"} {  append t2(-hnt2) "$t2(-points) $points $t2(-endclr) $tclr(-kpnt1) "
      } else {  append t2(-hnt2) "$t2(-points) $points jokaiselle $t2(-endclr) $tclr(-kpnt1) "  }
      putquick "PRIVMSG $t2(chan) :$t2(-hnt2)[expr {$sec*2}] sekuntia "
    } else {
      if {$t2(descend)=="1"} {  set t2(-points) [expr {round($t2(-points)/2.0)}]  }
      foreach {kans hn2 hn3 kvar} $t2(-kansls) {  append t2(-hnt2) " $hn2"  }
      append t2(-hnt2) " $t2(-endclr) $tclr(-kpnt1) [expr {$sec*2}] sekuntia "
      putquick "PRIVMSG $t2(chan) :$t2(-hnt2)"
    }
  } else {  set t2(-qtimer) [utimer $t2(-htime) [list TShoTriv 2]]
    set t2(-hnt2) "$tclr(-hint) Toinen vinkki:$tclr(-hint2) $t2(-hnt2) $t2(-endclr) "
    if {$t2(descend)=="1"} {  set givpnt [expr {round($t2(-points)/2.0)}]
      if {$givpnt=="1"} {  set point Point  } else {  set point Points  }
      append t2(-hnt2) "$tclr(-pnt1) [expr {$t2(-htime)*2}] sekuntia &$tclr(-pnt2) $givpnt"
      putquick "PRIVMSG $t2(chan) :$t2(-hnt2) $points $tclr(-pnt1)jäljellä "
    } else {  append t2(-hnt2) "$tclr(-pnt1) [expr {$t2(-htime)*2}] sekuntia jäljellä.  Arvo:"
      if {$t2(-points)=="1"} {  set point Point  } else {  set point Points  }
      putquick "PRIVMSG $t2(chan) :$t2(-hnt2)$tclr(-pnt2) $t2(-points) $points "
    }
  }
  if {$t2(usrqes)>="1" && $t2(-uqes)!=""} { TBind q }
  if {$t2(-uhnt2)!=""} {
   if {$t2(-hbound)=="0"} { TBind h }
  } else {
   if {$t2(-hbound)=="1"} { TBind h u }
  }
 } elseif {$t2(-hntnum)=="2"} {  set t2(-hntnum) 3
  if {$iskaos=="1"} {  set sec $t2(ktime)  ;  set doshort 0
    if {$t2(-udead)>=$t2(sqcnt) && $t2(-htime)>$t2(ktime)} {  set sec $t2(-htime)  }
    set t2(-qtimer) [utimer $sec [list TShoTriv 3]]
    if {$t2(krest)=="1" && $t2(-udead)>=$t2(rqcnt)} {  set doshort 1
    } elseif {$t2(krest)>"1" && $t2(-udead)>=$t2(sqcnt)} {  set doshort 1  }
    set t2(-hnt3) "$tclr(-khnt) Kolmas vihje:$tclr(-khnt2)"
    if {$t2(kstyle)>"2" || $doshort=="1"} {  set kleft [expr {[llength $t2(-kansls)]/4}]
      if {$kleft==$t2(-kanstot)} {  append t2(-hnt3) " Kaikki vastaukset käyttämättä "
      } elseif {$kleft=="1"} {  append t2(-hnt3) " Yksi vastaus jäljellä "
      } else { append t2(-hnt3) " $kleft of $t2(-kanstot) vastausta jäljellä"  }
      if {$t2(-points)=="1"} {  set point Point  } else {  set point Points  }
      if {$kleft=="1"} {  append t2(-hnt3) "$t2(-points) $points $t2(-endclr) $tclr(-kpnt1) "
      } else {  append t2(-hnt3) "$t2(-points) $points $t2(-endclr) $tclr(-kpnt1) "  }
      putquick "PRIVMSG $t2(chan) :$t2(-hnt3)$sec sekuntia "
    } else {
      if {$t2(descend)=="1"} {  set t2(-points) [expr {round($t2(-points)/2.0)}]  }
      foreach {kans hn2 hn3 kvar} $t2(-kansls) {  append t2(-hnt3) " $hn3"  }
      append t2(-hnt3) " $t2(-endclr) $tclr(-kpnt1) $sec sekuntia "
      putquick "PRIVMSG $t2(chan) :$t2(-hnt3)"
    }
  } else {  set t2(-qtimer) [utimer $t2(-htime) [list TShoTriv 3]]
    set t2(-hnt3) "$tclr(-hint) Kolmas vihje:$tclr(-hint2) $t2(-hnt3) $t2(-endclr) "
    if {$t2(descend)=="1"} {
      set givpnt [expr {round([expr {round($t2(-points)/2.0)}]/2.0)}]
      if {$givpnt=="1"} {  set point Point  } else {  set point Points  }
      append t2(-hnt3) "$tclr(-pnt1) $t2(-htime) sekuntia &$tclr(-pnt2) $givpnt"
      putquick "PRIVMSG $t2(chan) :$t2(-hnt3) $points $tclr(-pnt1)jäljellä "
    } else {  append t2(-hnt3) "$tclr(-pnt1) $t2(-htime) secs remaining.  Value:"
      if {$t2(-points)=="1"} {  set point Point  } else {  set point Points  }
      putquick "PRIVMSG $t2(chan) :$t2(-hnt3)$tclr(-pnt2) $t2(-points) $points "
    }
  }
  if {$t2(-uhnt3)!=""} {
   if {$t2(-hbound)=="0"} { TBind h }
  } else {
   if {$t2(-hbound)=="1"} { TBind h u }
  }
 }
}
proc TSavActiv { {nk 0} {uh 0} {hn 0} {points 0} {opt 0} {iskaos 0} } {
 global t2 tclr botnick  ;  set isnew 0
 if {[info exists t2(-notsaved)]} {  unset t2(-notsaved)  }
 if {![file exists $t2(sfpath)t2.recent]} {  set trefile [open $t2(sfpath)t2.recent w]
   puts $trefile "::N:[unixtime]"  ;  set t2(-reccnt) 0
   if {$nk eq "0"} {  close $trefile
     if {$uh eq "1"} {  TSavUsers 1 1  }  ;  return 0
   }
   set isnew 1
 } else {
   if {$nk eq "0"} {  TSavUsers 1  ;  set trefile [open $t2(sfpath)t2.recent w]
     puts $trefile "::N:[unixtime]"  ;  close $trefile  ;  set t2(-reccnt) 0  ;  return 1
   }
 }
 if {$isnew=="0"} {  set trefile [open $t2(sfpath)t2.recent a] }
 if {$iskaos=="0"} {  puts $trefile ":N:$nk $hn $uh $points"  ;  incr t2(-reccnt)
 } else {
   foreach {nk hn uh pnt cnt} $t2(-kusrls) {
      puts $trefile ":N:$nk $hn $uh $pnt $cnt"  ;  incr t2(-reccnt)
   }
   unset t2(-kusrls)
 }
 close $trefile
 if {$iskaos<"2" && $opt<"2"} {  set t2(-otimer) ""
   if {$opt=="1"} {  TSavUsers 1  ;  TSavUsers 0
   } elseif {$t2(-reccnt)>=$t2(recsiz)} {  TSavUsers 1  }
   TMkLines
 }
}
proc TReadHist {num {opt -1} } {  global t2 tclr botnick
 if {![file exists $t2(sfpath)t2.hist]} {  TDoHInfo  ;  return 0  }
 if {![file exists $t2(sfpath)t2.hist.info] || $t2(-yestrda)=="0"} {  TDoHInfo  }
 if {$num<"4"} {  set find 1  ;  set keep 30  ;  set dwm d
   if {$t2(yesterda)=="1"} {  set keep 10  } elseif {$t2(yesterda)=="2"} {  set keep 20  }
   if {$num=="2"} {  set dwm w  } elseif {$num=="3"} {  set dwm m  }
 } else {  set temp [split $t2(-histcnt)]
   if {[llength $temp]<"3"} {  TDoHInfo  ;  set temp [split $t2(-histcnt)]  }
   if {$t2(-histcnt) eq "0"} {  return 0  }
   if {$opt=="1" && $t2(history)!="0"} {  set keep 20  ;  set dwm d
     if {$t2(history)=="1"} {  set keep 10  }
     set x [lindex $temp 0]  ;  set y [lrange $temp 1 end-1]
     if {$x>[llength $y]} {  set x 1  }
     set do [lindex $y [expr {$x-1}]]  ;  incr x
     set find [string index $do 1]  ;  set z [string index $do 0]
     if {$z=="2"} {  set dwm w  } elseif {$z=="3"} {  set dwm m  }
     set t2(-histcnt) "$x [join [lrange $temp 1 end]]"
     set thiinfo [open $t2(sfpath)t2.hist.info w]
     puts $thiinfo "[unixtime] $t2(-histcnt)"  ;  close $thiinfo
   } elseif {$opt=="2" && $t2(otherhist)!="0"} {  set keep 1  ;  set find 1+
     set y [lrange $temp 1 end-1]  ;  set z [lindex $temp end]
     if {$z=="2"} {   if {[lsearch $y 2*]>"-1"} { set dwm w } else { incr z }   }
     if {$z=="3"} {   if {[lsearch $y 3*]>"-1"} { set dwm m } else { set z 1 }   }
     if {$z=="1"} {  if {[lsearch $y 1*]>"-1"} { set dwm d } else { TDoHInfo ; return 0 }   }
     incr z  ;  if {$z=="4"} {  set z 1  }
     set t2(-histcnt) "[join [lrange $temp 0 end-1]] $z"
     set thiinfo [open $t2(sfpath)t2.hist.info w]
     puts $thiinfo "[unixtime] $t2(-histcnt)"  ;  close $thiinfo
   }
 }
 if {![info exists keep]} {  return 0  }  ;  set dwm [string toupper $dwm]
 set thifile [open $t2(sfpath)t2.hist]  ;  set cnt 0  ;  set utls ""  ;  set plls ""
 set time ""  ;  set players ""
 while {![eof $thifile]} {  set temp [gets $thifile]
  if {$time ne "" && ![string match :N:* $temp]} {
    if {$players ne ""} {  lappend utls $time  ;  lappend plls $players  }
    set time ""  ;  set players ""
    if {$find ne "1+"} {  break  }  ;  if {$cnt=="7"} {  break  }
  }
  if {[string match ::$dwm:* $temp]} {  incr cnt  ;  set temp [lindex [split $temp] 2]
    if {$find eq "1+" || $find==$cnt} {  set time $temp  ;  set pcnt 0  }
  } elseif {[string match :N:* $temp] && $time ne ""} {  incr pcnt
    if {$pcnt>$keep} {  continue  }  ;  set temp [split $temp]
    foreach {nk hn uh pt} $temp {  break  }  ;  set nk [string range $nk 3 end]
    lappend players $nk $pt
  }
 }
 close $thifile
 if {$utls eq ""} {  return 0  }
 if {$dwm eq "D"} { set clr2 $tclr(-d11) ; set clr3 $tclr(-d12)
 } elseif {$dwm eq "W"} { set clr2 $tclr(-w11) ; set clr3 $tclr(-w12)
 } else {  set clr2 $tclr(-m11)  ;  set clr3 $tclr(-m12)  }
 if {$find ne "1+"} {  set lut [lindex $utls 0]  ;  set plls [lindex $plls 0]
   if {[llength $plls]=="22"} {  set plls [lrange $plls 0 19]
   } elseif {[llength $plls]=="42"} {  set plls [lrange $plls 0 39]  }
   if {$num=="1"} {  set sholine "$tclr(-d10)Eilisen kymmenen parasta: "
     if {[llength $plls]>"20"} {  set sholin2 "$tclr(-d10)Eilisen parhaat pelaajat (sijat 11-20): "  }
     if {[llength $plls]>"40"} {  set sholin3 "$tclr(-d10)Eilisen parhaat pelaajat (sijat 21-30): "  }
   } elseif {$num=="2"} {  set sholine "$tclr(-w10)Viime viikon kymmenen parasta pelaajaa: "
     if {[llength $plls]>"20"} {  set sholin2 "$tclr(-w10)Viime viikon parhaat (sijat 11-20): "  }
     if {[llength $plls]>"40"} {  set sholin3 "$tclr(-w10)Viime viikkojen parhaat pelaajat (sijat 21-30): "  }
   } elseif {$num=="3"} {  set sholine "$tclr(-m10)Viime kuukauden kymmenen parasta pelaajaa: "
     if {[llength $plls]>"20"} {  set sholin2 "$tclr(-m10)Viime kuukausien parhaat pelaajat (sijat 11-20): "  }
     if {[llength $plls]>"40"} {  set sholin3 "$tclr(-m10)Viime kuukausien parhaat pelaajat (sijat 21-30): "  }
   } elseif {$dwm=="D"} {
     if {$t2(days1) eq ""} {  set day [string toupper [strftime %A $lut]]
     } else {  set day [lindex $t2(days1) [strftime %u $lut]]  }
     set sholine "$tclr(-d10)${day}n parhaat kymmenen pelaajaa: "
     if {[llength $plls]>"20"} {  set sholin2 "$tclr(-d10)${day}n parhaat (sijat 11-20):"  }
   } elseif {$dwm=="W"} {  set sholine "$tclr(-w10)$find viikkoa sitten kymmenen parasta: "
     if {[llength $plls]>"20"} {  set sholin2 "$tclr(-w10)$find viikkoa sitten parhaat pelaajat (sijat 11-20): "  }
   } elseif {$dwm=="M"} {
     if {$t2(mons1) eq ""} {  set month [string toupper [strftime %B $lut]]
     } else {  set month [lindex $t2(mons1) [string trimleft [strftime %m $lut] 0]]  }
     set sholine "$tclr(-m10) ${month}n kymmenen parasta: "
     if {[llength $plls]>"20"} {  set sholin2 "$tclr(-m10) ${month}n Top 11-20: "  }
   }
   set cnt 0
   foreach {nk pt} $plls {  incr cnt
    if {$cnt<"11"} {  append sholine "$clr2 \002#$cnt:\002 $clr3 $nk $pt "
    } elseif {$cnt<"21"} {  append sholin2 "$clr2 \002#$cnt:\002 $clr3 $nk $pt "
    } elseif {[info exists sholin3]} {  append sholin3 "$clr2 \002#$cnt:\002 $clr3 $nk $pt "  }
   }
 } else {
   if {[llength $utls]=="1"} {  return 0  }
   if {$dwm=="D"} {  set sholine "$tclr(-d10)Paras pelaaja: - "
   } elseif {$dwm=="W"} {  set sholine "$tclr(-w10)Paras pelaaja: - "
   } else {  set sholine "$tclr(-m10)Paras pelaaja: - "  }
   set cnt 0
   foreach lut $utls player $plls {  incr cnt
    foreach {nk pt} $player { break }
    if {$dwm=="D"} {
      if {$t2(days2) eq ""} {  append sholine "$clr2 \002[strftime %A $lut]:\002 $clr3 $nk $pt "
      } else {  append sholine "$clr2 \002[lindex $t2(days2) [strftime %u $lut]]:\002 $clr3 $nk $pt "  }
    } elseif {$dwm=="W"} {
      if {$cnt=="1"} {  append sholine "$clr2 \002Viime viikko:\002 $clr3 $nk $pt "
      } else {  append sholine "$clr2 \002$cnt viikkoa sitten:\002 $clr3 $nk $pt "  }
    } else {
      if {$t2(mons2) eq ""} {  set month [strftime %B $lut]
      } else {  set month [lindex $t2(mons2) [string trimleft [strftime %m $lut] 0]]  }
      append sholine "$clr2 \002${month}:\002 $clr3 $nk $pt "
    }
   }
 }
 if {![info exists sholine]} {  return 0  }
 if {$sholine ne ""} {  putquick "PRIVMSG $t2(chan) :$sholine"
   if {[info exists sholin3] && $t2(-ptime)>"7"} {  utimer $t2(-stime) [list TShoLine $sholin2 $sholin3]
   } elseif {[info exists sholin2]} {  utimer $t2(-stime) [list TShoLine $sholin2]  }
 }
}
proc TShoLine {line {lin3 0} } {  global t2 tclr botnick
 if {$t2(-ison) == "0"} {  return 0  }
 if {$lin3 != "0"} {  utimer $t2(-stime) [list TShoLine $lin3]  }
 putquick "PRIVMSG $t2(chan) :$line"
}

proc TChkDed {todo done} {  global t2 botnick
 if {$t2(-ison) == "0"} {  return 0  }
 set cnt 0
 foreach tmr [utimers] {  set prc [lindex $tmr 1 0]
  if {$prc eq "TShoTriv" || $prc eq "TShoTrv2"} {  incr cnt  }
 }
 if {$cnt=="0"} {  incr todo -1  ;  incr done
   if {$todo=="0"} {
     putquick "PRIVMSG $t2(chan) :$t2(script) utimer Error! Shutting down..."
     TOnOff $botnick error stop $t2(chan) 0 6
     return 0
   }
   if {$done=="1"} {  set sec 3  } elseif {$done=="2"} {  set sec 4
   } else {  set sec [expr {[rand 8]+3}]  }
   utimer $sec [list TChkDed $todo $done]
 }
}
proc TBndTime {mn hr da mo yr} {  global t2 tclr botnick
 if {$t2(-ison) == "0"} {  return 0  }
 set cnt 0
 foreach tmr [utimers] {  set prc [lindex $tmr 1 0]
  if {$prc eq "TShoTriv" || $prc eq "TShoTrv2"} {  incr cnt  }
 }
 if {$cnt=="0"} {  utimer 6 [list TChkDed 2 0]  }
 if {$mn=="00" && $hr=="00"} {  incr t2(-dosave)
   if {$t2(bakupu)>"0" || $t2(bakuph)>"0"} {  set t2(-dobakup) 1  }
 } elseif {$mn=="00" && $hr=="12"} {
   if {$t2(bakupu)>"0" && $t2(bakhow)>"1"} {  set t2(-dobakup) 2  }
 }
 if {[info exists t2(-hactv)]} {
   if {$t2(-dosave)<"2"} {  incr t2(-hcnt)  }
   if {$t2(-hcnt)>=$t2(-hactv) && [info exists t2(-hnew)] && $t2(-hnew)>"0"} {
	    set t2(-hcnt) 0  ;  incr t2(-dosave) 2  }
 } elseif {$mn=="00" && $hr=="12" && [info exists t2(-html)] && $t2(-html) eq "d2"} {
   incr t2(-dosave) 2
 }
 if {$mn=="01" || $mn=="31"} {  set t2(-shoad) 1
   if {$mn=="01" && $hr=="00"} {  return 0  }
   if {$t2(tda)!="0"} {  set t2(-shoda10) 1  }
 } elseif {$mn=="06" || $mn=="36"} {  if {$t2(ever)!="0"} { set t2(-shoev10) 1 }
 } elseif {$mn=="16" || $mn=="46"} {  set t2(-shoad) 1
   if {$mn=="16"} {  if {$t2(lmo)!="0"} { set t2(-shohist) 3 }
   } elseif {$t2(tmo)!="0"} {  set t2(-shomo10) 1  }
 } elseif {$mn=="21" || $mn=="51"} {  if {$t2(twe)!="0"} { set t2(-showe10) 1 }
 } elseif {$mn=="11"} {  if {$t2(lda)!="0"} { set t2(-shohist) 1 }
 } elseif {$mn=="26"} {  set t2(-shohist) 4
 } elseif {$mn=="41"} {  if {$t2(lwe)!="0"} { set t2(-shohist) 2 }
 } elseif {$mn=="56"} {  set t2(-shohist) 5  }
}
proc TBind {typ {bnd b} } {  global t2 botnick
 if {$typ eq "q"} {
  if {$bnd eq "b"} { bind pubm $t2(pqflag) "$t2(chan) $t2(upubq)" TPQues ; set t2(-qbound) 1
  } else { unbind pubm $t2(pqflag) "$t2(chan) $t2(upubq)" TPQues ; set t2(-qbound) 0 }
 } elseif {$typ eq "h"} {
  if {$bnd eq "b"} {
   if {$t2(hint) eq "~"} { bind pubm $t2(hflag) $t2(chan)%~ TDoHint ; set t2(-hbound) 1
   } else { bind pubm $t2(hflag) "$t2(chan) $t2(hint)" TDoHint ; set t2(-hbound) 1 }
  } else {
   if {$t2(hint) eq "~"} { unbind pubm $t2(hflag) $t2(chan)%~ TDoHint ; set t2(-hbound) 0
   } else { unbind pubm $t2(hflag) "$t2(chan) $t2(hint)" TDoHint ; set t2(-hbound) 0 }
  }
 } elseif {$typ eq "a"} {
  if {$bnd eq "b"} { bind pubm $t2(pflag) "$t2(chan) $t2(-answer)" TGotIt ; set t2(-abound) 1
    if {[info exists t2(-answr2)]=="1"} {
      foreach {altavar altansr} [array get t2 -answr*] {
       bind pubm $t2(pflag) "$t2(chan) $altansr" TGotIt
      }
      set t2(-a2bound) 1
    }
  } else {  set t2(-abound) 0
    if {$t2(-answer) ne ""} {  set fnd 0
      set t2(-allansls) [lreplace $t2(-allansls) 0 0]
      foreach x $t2(-allansls) {
       if {[string equal -nocase $x $t2(-answer)]} {  incr fnd  ;  break  }
      }
      if {$fnd=="0"} {  unbind pubm $t2(pflag) "$t2(chan) $t2(-answer)" TGotIt  }
    }
    if {$t2(-a2bound)=="1"} {  set temp [array get t2 -answr*]
      if {$temp ne ""} {  set x 0
        foreach {altavar altansr} $temp {  incr x 2  ;  set fnd 0
         foreach {var ans} [lrange $temp $x end] {
          if {[string equal -nocase $ans $altansr]} {  incr fnd  ;  break  }
         }
         if {$fnd=="0"} {  unbind pubm $t2(pflag) "$t2(chan) $altansr" TGotIt  }
        }
      }
      set t2(-a2bound) 0  ;  set t2(-allansls) ""  ;  array unset t2 -answr*
    }
  }
 } elseif {$typ eq "s"} {
  if {$bnd eq "b"} {  bind pubm $t2(tflag) "$t2(chan) $t2(slow)" TSlow
   bind pubm $t2(tflag) "$t2(chan) $t2(fast)" TFast
  } else {  unbind pubm $t2(tflag) "$t2(chan) $t2(slow)" TSlow
   unbind pubm $t2(tflag) "$t2(chan) $t2(fast)" TFast
  }
 }
 return 0
}
proc TMkLines {} {  global t2 tclr botnick nick ;  set t2(-otimer) "" ;  set doques 1 ;  set isbon 0
 if {[info exists t2(S-akp)] && $t2(S-akp)>"0"} {
   if {[expr {$t2(S-aut)+300}]<[unixtime]} {  TSetStat 1  }
 }
 if {$t2(kaos)>"0" && $t2(-iskaos)==$t2(kaos)} {  set qfline [gets $t2(-opnkfil)]
  if {$qfline eq ""} {
    close $t2(-opnkfil) ; set temp [lsearch -exact $t2(-kfills) $t2(-kflnow)]
    if {$t2(-kflnow) eq [lindex $t2(-kfills) end]} {
      set tmp2 [lindex $t2(-kfills) 0]  ;  set tkcntfil [open $t2(sfpath)t2.kcount w]
      puts $tkcntfil "0"  ;  close $tkcntfil  ;  set t2(-kcount) 0
    } else {  set tmp2 [lindex $t2(-kfills) [expr {$temp+1}]]  }
    if {[file exists $tmp2]} { set t2(-opnkfil) [open $tmp2] ; set qfline [gets $t2(-opnkfil)]
      if {$qfline ne ""} {  set t2(-kflnow) $tmp2  ;  set doques 0
      } else {  set t2(kaos) 0  ;  close $t2(-opnkfil)  }
    } else {  set t2(kaos) 0  }
  } else {  set doques 0  }
 }
 if {$doques=="1"} {  set qfline [gets $t2(-opnfil)]
  if {$qfline eq ""} {
    close $t2(-opnfil) ; set temp [lsearch -exact $t2(-qfills) $t2(-qflnow)]
    if {$t2(-qflnow) eq [lindex $t2(-qfills) end]} {
      lappend tmpls $t2(-qfills)  ;  set startovr 1
    } else {  lappend tmpls [lrange $t2(-qfills) [expr {$temp+1}] end]
      lappend tmpls [lrange $t2(-qfills) 0 $temp]  ;  set startovr 0
    }
    set tmpcnt 0  ;  set missng 0  ;  set delfiles ""
    foreach tls $tmpls {  incr tmpcnt
     foreach qfile $tls {
      if {[file exists $qfile]} { set t2(-opnfil) [open $qfile] ; set t2(-qflnow) $qfile
       while {![eof $t2(-opnfil)]} {
        set qfline [gets $t2(-opnfil)]  ;  if {$qfline ne ""} { break }
       }
       if {$qfline eq ""} {  close $t2(-opnfil)  ;  file delete $qfile
         lappend  delfiles $qfile  ;  incr t2(-qfcnt) -1
         if {[set tfidx [lsearch $t2(-qfills) $qfile]]!="-1"} {
             set t2(-qfills) [lreplace $t2(-qfills) $tfidx $tfidx] }
       } else { break }
      } else {  incr missng  ;  incr t2(-qfcnt) -1
       if {[set tfidx [lsearch $t2(-qfills) $qfile]]!="-1"} {
           set t2(-qfills) [lreplace $t2(-qfills) $tfidx $tfidx] }
      }
     }
     if {$qfline ne ""} {  break  }
    }
    if {$tmpcnt=="2" || $startovr=="1"} {  set tqcntfil [open $t2(sfpath)t2.qcount w]
      puts $tqcntfil "0"  ;  close $tqcntfil  ;  set t2(-qcount) 0
    }
  }
 }
 if {$qfline ne ""} {  set qls [split $qfline *] ;  set t2(-allansls) [TStrLo [lrange $qls 1 end]]
  if {$t2(-test)=="1"} {  putlog "\00310$t2(-allansls)"  }
  set tqes [lindex $qls 0]  ;  set t2(-answer) [lindex $qls 1]
  if {[llength $qls]>"2"} {  set tmpcnt 1
    foreach altansr [lrange $qls 2 end] { incr tmpcnt ; set t2(-answr$tmpcnt) $altansr }
  }
  if {$t2(shonum)=="0"} {  set tqnum ""
  } else {
   if {$doques=="1"} {
    if {[string length $t2(-qcount)]=="1"} {  set tqnum ".000$t2(-qcount). "
    } elseif {[string length $t2(-qcount)]=="2"} { set tqnum ".00$t2(-qcount). "
    } elseif {[string length $t2(-qcount)]=="3"} { set tqnum ".0$t2(-qcount). "
    } else {  set tqnum ".$t2(-qcount). "  }
   } else {
    if {[string length $t2(-kcount)]=="1"} {  set tqnum ".K00$t2(-kcount). "
    } elseif {[string length $t2(-kcount)]=="2"} { set tqnum ".K0$t2(-kcount). "
    } else {  set tqnum ".K$t2(-kcount). "  }
   }
  }
  set t2(-quesn2) ""  ;  set t2(-uqes) ""  ;  set t2(-uqs2) ""
  set dun 0  ;  set tq2 ""  ;  set tq3 ""  ;  set uq2 ""  ;  set uq3 ""
  if {$t2(randfil)=="1"} {  set tc [lindex [split $tclr(-qt) ,] 0]
      set sc [lindex [split $tclr(-qs) ,] 0]  }
  if {[TStrLo $tqes]=="scramble" || [TStrLo $tqes]=="uword"} {  set temp [TStrLo $t2(-answer)]
   if {$t2(randfil)=="1"} {  append tq2 "UnScramble$sc[TRandL]$tc"
     append tq2 "tämä[TRandL]${tc}Sana:"
   } else {  append tq2 "Ratko seuraava sana:"  }
   while {$dun=="0"} {
    if {[string length $temp]>"1"} {  set tem2 [rand [string length $temp]]
     if {$t2(randfil)=="1"} {  append tq2 "$sc[TRandL]$tc[string index $temp $tem2]"
     } else {  append tq2 " [string index $temp $tem2]"  }
     set temp [string replace $temp $tem2 $tem2]
    } else {
     if {$t2(randfil)=="1"} {  append tq2 "$sc[TRandL]$tc$temp"  } else {  append tq2 " $temp"  }
     set dun 1  ;  break
    }
   }
   set t2(-questn) "$tclr(-qt) $tqnum$tq2 ? $t2(-endclr)"
   if {$t2(usrqes)>="1"} {  set t2(-uqes) "$tclr(-qt) $tq2 ? $t2(-endclr)"  }
  } else {
   if {$t2(randfil)=="1"} {  set stridx 0  ;  set ln1cnt 0  ;  set uln1cnt 0
    set charcnt [expr {[string length $tqnum]+7}]  ;  set pubqcnt 7
    while {$dun=="0"} {  set temp [string first " " $tqes $stridx]
     if {$temp!="-1"} {  set nxword [string range $tqes $stridx [expr {$temp-1}]]
     } else {  set nxword [string range $tqes $stridx end]  }
     set nxlen [expr {$charcnt+[string length $nxword]+3}]
     if {$tq3 ne "" || $uq3 ne ""} {
       if {$nxlen>=$t2(maxchar)} {  set dun 2  ;  break  }
       if {$tq3 eq ""} {  append tq2 $nxword  ;  incr charcnt [string length $nxword]
         set ln1cnt $charcnt  ;  set tq3 "$tclr(-qt) "  ;  set charcnt 3
       } else {  append tq3 $nxword  ;  incr charcnt [string length $nxword]
         if {$temp!="-1"} {  append tq3 " "  ;  incr charcnt  }
       }
       if {$t2(usrqes)>="1"} {
         if {$uq3 eq ""} {  append uq2 $nxword  ;  incr pubqcnt [string length $nxword]
           set uln1cnt $pubqcnt  ;  set uq3 "$tclr(-qt) " ;  set pubqcnt 3
         } else {  append uq3 $nxword  ;  incr pubqcnt [string length $nxword]
           if {$temp!="-1"} {  append uq3 " "  ;  incr pubqcnt  }
         }
       }
       if {$t2(maxhow)=="1" && $t2(usrqes)<="1"} {  set dun 1  ;  break  }
     } else {
       if {$temp!="-1"} {  set strid2 [expr {$temp+1}] ;  set tmp2 [string first " " $tqes $strid2]
         if {$tmp2!="-1"} {  set nxwrd2 [string range $tqes $strid2 [expr {$tmp2-1}]]
         } else {  set nxwrd2 [string range $tqes $strid2 end]  }
         set nxln2 [expr {$charcnt+[string length $nxword]+[string length $nxwrd2]+10}]
         if {$nxln2<$t2(maxchar)} {  append tq2 $nxword$sc[TRandL]$tc
           incr charcnt [expr {[string length $nxword]+7}]  ;  set ln1cnt $charcnt
         } else {
           if {$tmp2=="-1" && [expr {$nxln2-6}]<$t2(maxchar)} {  append tq2 "$nxword "
             incr charcnt [expr {[string length $nxword]+1}]  ;  set ln1cnt $charcnt
           } elseif {$tmp2=="-1" && $t2(maxhow)=="2"} {  append tq3 "$tclr(-qt) $nxword "
             set charcnt [expr {[string length $nxword]+8}]
           } else {  append tq2 $nxword  ;  incr charcnt [string length $nxword]
             set ln1cnt $charcnt  ;  append tq3 "$tclr(-qt) "  ;  set charcnt 7
           }
         }
         if {$t2(usrqes)>="1"} {
           set unxln2 [expr {$pubqcnt+[string length $nxword]+[string length $nxwrd2]+10}]
           if {$unxln2<$t2(maxchar)} {  append uq2 $nxword$sc[TRandL]$tc
             incr pubqcnt [expr {[string length $nxword]+7}]  ;  set uln1cnt $pubqcnt
           } else {
             if {$tmp2=="-1" && [expr {$unxln2-6}]<$t2(maxchar)} {  append uq2 "$nxword "
               incr pubqcnt [expr {[string length $nxword]+1}]  ;  set uln1cnt $pubqcnt
             } elseif {$tmp2=="-1" && $t2(usrqes)=="2"} {  append uq3 "$tclr(-qt) $nxword "
               set pubqcnt [expr {[string length $nxword]+8}]
             } else {  append uq2 $nxword  ;  incr pubqcnt [string length $nxword]
               set uln1cnt $pubqcnt  ;  append uq3 "$tclr(-qt) "  ;  set pubqcnt 7
             }
           }
         }
       } else {  append tq2 $nxword ;  incr charcnt [string length $nxword] ;  set ln1cnt $charcnt
         if {$t2(usrqes)>="1"} {  append uq2 $nxword
           incr pubqcnt [string length $nxword]  ;  set uln1cnt $pubqcnt
         }
       }
     }
     if {$temp=="-1"} {  set dun 1  ;  break  }
     set stridx [expr {$temp+1}]
    }
    if {$tq3 eq ""} {  incr ln1cnt 3
      set t2(-questn) "$tclr(-qt) $tqnum$tq2 ?"
      if {$ln1cnt<$t2(maxchar)} {  append t2(-questn) " $t2(-endclr)"  ;  incr ln1cnt
      } else {  append t2(-questn) $t2(-endclr)  }
    } elseif {$t2(maxhow)=="1" && $t2(maxanti)=="0"} {  incr ln1cnt 3
      set t2(-questn) "$tclr(-qt) $tqnum$tq2.."
      if {$ln1cnt<$t2(maxchar)} {  append t2(-questn) "."  ;  incr ln1cnt
        if {$ln1cnt<$t2(maxchar)} {  append t2(-questn) " "  ;  incr ln1cnt  }
      }
      append t2(-questn) $t2(-endclr)
    } elseif {$t2(maxanti)=="0"} {  set ln2cnt [expr {3+$charcnt}]
      set t2(-questn) "$tclr(-qt) $tqnum$tq2 $t2(-endclr)"  ;  incr ln1cnt 2
      if {$dun=="2"} {  set t2(-quesn2) "$tq3.."
        if {$ln2cnt<$t2(maxchar)} {  append t2(-quesn2) "."  ;  incr ln2cnt
          if {$ln2cnt<$t2(maxchar)} {  append t2(-quesn2) " "  ;  incr ln2cnt  }
        }
        append t2(-quesn2) $t2(-endclr)
      } else {  set t2(-quesn2) "$tq3 ?"
        if {$ln2cnt<$t2(maxchar)} {  append t2(-quesn2) " $t2(-endclr)"
        } else {  append t2(-quesn2) $t2(-endclr)  }
      }
    }
    if {$t2(usrqes)>="1"} {
      if {$uq3 eq ""} {  incr uln1cnt 3
        set t2(-uqes) "$tclr(-qt) $uq2 ?"
        if {$uln1cnt<$t2(maxchar)} {  append t2(-uqes) " $t2(-endclr)"
        } else {  append t2(-uqes) $t2(-endclr)  }
      } elseif {$t2(usrqes)=="1" && $t2(maxanti)=="0"} {  incr uln1cnt 3
        set t2(-uqes) "$tclr(-qt) $uq2.."
        if {$uln1cnt<$t2(maxchar)} {  append t2(-uqes) "."  ;  incr uln1cnt
          if {$uln1cnt<$t2(maxchar)} {  append t2(-uqes) " "  ;  incr uln1cnt  }
        }
        append t2(-uqes) $t2(-endclr)
      } elseif {$t2(maxanti)=="0"} {  set uln2cnt [expr {3+$pubqcnt}]
        set t2(-uqes) "$tclr(-qt) $uq2 $t2(-endclr)"
        if {$dun=="2"} {  set t2(-uqs2) "$uq3.."
          if {$uln2cnt<$t2(maxchar)} {  append t2(-uqs2) "."  ;  incr uln2cnt
            if {$uln2cnt<$t2(maxchar)} {  append t2(-uqs2) " "  ;  incr uln2cnt  }
          }
          append t2(-uqs2) $t2(-endclr)
        } else {  set t2(-uqs2) "$uq3 ?"
          if {$uln2cnt<$t2(maxchar)} {  append t2(-uqs2) " $t2(-endclr)"
          } else {  append t2(-uqs2) $t2(-endclr)  }
        }
      }
    }
   }
  }
  if {$t2(-questn) eq ""} {  set t2(-questn) "$tclr(-qt) $tqnum"
    set ln1cnt [expr {[string length $tqnum]+[string length $tqes]}]
    if {$tclr(-qt) eq ""} {  incr ln1cnt 4  ;  set end ""
    } else {  incr ln1cnt 7  ;  set end $t2(-endclr)  }
    if {$ln1cnt<=$t2(maxchar)} {  append t2(-questn) "$tqes ? $end"
    } else {
      if {$tclr(-qt) eq ""} {  set ln1cnt [expr {[string length $tqnum]+2}]  ;  set ln2cnt 4
      } else {  set ln1cnt [expr {[string length $tqnum]+5}]  ;  set ln2cnt 7  }
      if {$t2(maxhow)=="1"} {  incr ln1cnt 3  }
      set x [expr {$t2(maxchar)-$ln1cnt}]  ;  set y [string last " " $tqes $x]
      set frst [string range $tqes 0 [expr {$y-1}]]
      set scnd [string range $tqes [expr {$y+1}] end]
      if {$t2(maxhow)=="1"} {
        append t2(-questn) "$frst... $end"  ;  incr ln1cnt [string length $frst]
      } else {  append t2(-questn) "$frst $end"  ;  incr ln1cnt [string length $frst]
        set x [expr {$t2(maxchar)-$ln2cnt}]
        if {[string length $scnd]>$x} {  incr x -1  ;  set y [string last " " $scnd $x]
          set t2(-quesn2) "$tclr(-qt) [string range $scnd 0 [expr {$y-1}]]... $end"
        } else {  set t2(-quesn2) "$tclr(-qt) $scnd ? $end"  }
      }
    }
  }
  if {$t2(usrqes)>="1" && $t2(-uqes) eq ""} {  set t2(-uqes) "$tclr(-qt) "
    if {$tclr(-qt) eq ""} {  set uln1cnt [expr {[string length $tqes]+4}]  ;  set end ""
    } else {  set uln1cnt [expr {[string length $tqes]+7}]  ;  set end $t2(-endclr)  }
    if {$uln1cnt<=$t2(maxchar)} {  append t2(-uqes) "$tqes ? $end"
    } else {
      if {$tclr(-qt) eq ""} {  set uln1cnt 2  ;  set ln2cnt 4
      } else {  set uln1cnt 5  ;  set ln2cnt 7  }
      if {$t2(maxhow)=="1"} {  incr uln1cnt 3  }
      set x [expr {$t2(maxchar)-$uln1cnt}]  ;  set y [string last " " $tqes $x]
      if {$t2(maxhow)=="1"} {  append t2(-uqes) "[string range $tqes 0 [expr {$y-1}]]... $end"
      } else {  set z [string range $tqes [expr {$y+1}] end]
        append t2(-uqes) "[string range $tqes 0 [expr {$y-1}]] $end"
        set x [expr {$t2(maxchar)-$ln2cnt}]
        if {[string length $z]>$x} {  incr x -1  ;  set y [string last " " $z $x]
          set t2(-uqs2) "$tclr(-qt) [string range $z 0 [expr {$y-1}]]... $end"
        } else {  set t2(-uqs2) "$tclr(-qt) $z ? $end"  }
      }
    }
  }
  if {$doques=="1"} {  set tansls [list $t2(-answer)]
    set nrange [expr {$t2(hpoint)-$t2(lpoint)}] ; set brange [expr {$t2(maxbonus)-$t2(minbonus)}]
  } else {  set tansls [lrange $qls 1 end] ; set t2(-kansls) "" ; set kdigcnt 0  }
  set kanscnt 0  ;  set q $t2(hintchar)
  foreach tmansr $tansls {
   set ansls [split $tmansr {}] ;  set istrun 0 ;  incr kanscnt ;  set kbegin ""
   if {$doques=="1"} {  set pbase $t2(lpoint)  ;  set aprang 0
   } else {
     if {$kanscnt=="1"} { set tem4 -answer } else { set tem4 -answr$kanscnt }
   }
   if {[llength $ansls]=="1"} {
     if {$doques=="1"} {  set t2(-hint) $q ;  set t2(-hnt2) $q ;  set t2(-hnt3) $q
       if {[TStrDig $tmansr]} {  set aprang [expr {round($nrange/4.0)}]
       } else {  set aprang [expr {round($nrange/3.0)}]  }
     } else {  incr kdigcnt  ;  append t2(-hint) " \[$q\]"
       lappend t2(-kansls) $tmansr \[$q\] \[$q\] $tem4
     }
   } elseif {[llength $ansls]=="2"} {
     if {$doques=="1"} {
       set t2(-hint) "$q$q" ; set t2(-hnt2) "[lindex $ansls 0]$q" ; set t2(-hnt3) "[lindex $ansls 0]$q"
       if {[TStrDig [lindex $ansls 1]]} { set aprang [expr {round($nrange/4.0)}]
       } else { set aprang [expr {round($nrange/3.0)}] }
     } else {  incr kdigcnt 2  ;  append t2(-hint) " \[$q$q\]"
       lappend t2(-kansls) $tmansr \[[lindex $ansls 0]$q\] \[[lindex $ansls 0]$q\] $tem4
     }
   } elseif {[TStrDig $tmansr] && [llength $ansls]<"5"} {
     foreach {d1 d2 d3 d4} $ansls { break }
     if {$doques=="1"} {  set t2(-uhint) $d1
       if {$d4==""} {   set aprang [expr {round($nrange/3.0)}]
         set t2(-hint) "$q$q$q" ; set t2(-hnt2) "$d1$q$q" ; set t2(-hnt3) "$d1$d2$q"
       } else {   set aprang [expr {round($nrange/2.0)}]
         set t2(-hint) "$q$q$q$q" ; set t2(-hnt2) "$d1$d2$q$q" ; set t2(-hnt3) "$d1$d2$d3$q"
       }
     } else {
       if {$d4==""} {  incr kdigcnt 3  ;  append t2(-hint) " \[$q$q$q\]"
         lappend t2(-kansls) $tmansr \[$d1$q$q\] \[$d1$d2$q\] $tem4
       } else {  incr kdigcnt 4  ;  append t2(-hint) " \[$q$q$q$q\]"
         lappend t2(-kansls) $tmansr \[$d1$d2$q$q\] \[$d1$d2$d3$q\] $tem4
       }
     }
   } else {
    if {$t2(shothe)=="1" && [string match -nocase "The *" $tmansr]} {
      if {[string length $tmansr]>"6"} {
        if {$doques=="1"} {
          append t2(-hint) "The " ; append t2(-hnt2) "The " ; append t2(-hnt3) "The "
          append t2(-uhint) "the " ; append t2(-uhnt2) "the " ; append t2(-uhnt3) "the "
        } else {  incr kdigcnt  ;  append t2(-hint) " \[The "
          append t2(-hnt2) "\[The " ; append t2(-hnt3) "\[The "
        }
        set kbegin [string range $tmansr 0 3]  ;  set tmansr [string range $tmansr 4 end]
        set istrun 1  ;  set ansls [lrange $ansls 4 end]
      }
    }
    if {$doques=="1"} {  set onethrd [expr {$nrange/3.0}]
      if {[llength $ansls]>"14"} {
        if {$t2(dobonus)>"0" && $t2(-shobons)>"0"} {  set isbon 1
          incr t2(-shobons) -1  ;  set pbase $t2(minbonus)  ;  set onethrd [expr {$brange/3.0}]
        }
        if {[llength $ansls]>"24"} {  set aprang [expr {round($onethrd*1.0)}]
          incr pbase [expr {round($onethrd*2.0)}]
        } elseif {[llength $ansls]>"19"} {
          if {$isbon=="1"} {  set aprang [expr {round($onethrd*2.0)}]
            incr pbase [expr {round($onethrd*1.0)}]
          } else {  set half [expr {$nrange/2.0}]  ;  set aprang [expr {round($half*1.0)}]
            incr pbase [expr {round($half*1.0)}]
            if {[string match *.5 $half]} {  set tmp [rand 2]
              if {$tmp=="0"} {  incr pbase -1  } else {  incr aprang -1  }
            }
          }
        } else {
          if {$isbon=="1"} {  set aprang [expr {round($onethrd*2.0)}]
          } else { incr pbase [expr {round($onethrd*1.0)}] ; set aprang [expr {round($onethrd*1.0)}] }
        }
      } else {
        if {[llength $ansls]>"8"} {  set aprang [expr {round($onethrd*2.0)}]
        } else {  set aprang [expr {round($nrange/2.0)}] }
      }
    } elseif {$t2(-hnt2)==""} {  append t2(-hint) " \["
      append t2(-hnt2) "\["  ;  append t2(-hnt3) "\["
    }
    set cscnt 0 ;  set chidx -1
    foreach char $ansls { incr chidx  ;  if {$doques=="0"} {  incr kdigcnt  }
     if {[TChar 1 $char]} { incr cscnt ; append t2(-hint) $q
     } else { append t2(-hint) $char }
     if {$chidx=="0"} {  append t2(-hnt2) $char  ;  append t2(-hnt3) $char
      if {$doques=="1"} {  append t2(-uhint) $char
        append t2(-uhnt2) $char  ;  append t2(-uhnt3) $char  }
     } elseif {$chidx=="1"} {
      if {$doques=="1"} {
        if {![TChar 1 [lindex $ansls 0]] && [llength $ansls]>"3"} { append t2(-uhint) $char }
        append t2(-uhnt2) $char  ;  append t2(-uhnt3) $char
      }
      if {[llength $ansls]>"3"} {  append t2(-hnt2) $char  } else {  append t2(-hnt2) $q  }
      append t2(-hnt3) $char
     } elseif {$chidx=="2"} {
      if {[llength $ansls]>"7"} {  append t2(-hnt2) $char
      } else {
       if {[TChar 1 $char]} {  append t2(-hnt2) $q  } else {  append t2(-hnt2) $char  }
      }
      if {[llength $ansls]>"5"} {  append t2(-hnt3) $char
        if {$doques=="1"} {  append t2(-uhnt2) $char  }
      } else {
       if {[TChar 1 $char]} {  append t2(-hnt3) $q  } else {  append t2(-hnt3) $char  }
      }
      if {$doques=="1" && [llength $ansls]>"3"} {  append t2(-uhnt3) $char  }
     } elseif {$chidx=="3"} {
      if {[llength $ansls]>"7"} {
       if {$cscnt>"3"} {
        if {[TChar 1 $char]} {  append t2(-hnt2) $q
         if {[TChar 2 $char]} {  append t2(-hnt3) $char  } else {  append t2(-hnt3) $q  }
        } else {  append t2(-hnt2) $char  ;  append t2(-hnt3) $char  }
       } else {  append t2(-hnt2) $char  ;  append t2(-hnt3) $char  }
       if {$doques=="1"} {  append t2(-uhnt2) $char ; append t2(-uhnt3) $char  }
      } else { 
       if {[TChar 1 $char]} {  append t2(-hnt2) $q
        if {[TChar 2 $char]} {  append t2(-hnt3) $char  } else {  append t2(-hnt3) $q  }
       } else {  append t2(-hnt2) $char  ;  append t2(-hnt3) $char  }
      }
     } else {
      if {[TChar 1 $char]} {  append t2(-hnt2) $q
       if {[TChar 2 $char]} {  append t2(-hnt3) $char  } else {  append t2(-hnt3) $q  }
      } else {  append t2(-hnt2) $char  ;  append t2(-hnt3) $char  }
      if {$doques=="1"} {
        if {$chidx=="4" && [llength $ansls]>"7"} {  append t2(-uhnt3) $char
        } elseif {$chidx=="5" && [llength $ansls]>"12"} { append t2(-uhnt3) $char }
      }
     }
    }
    if {$doques=="0"} { append t2(-hint) \]  ; append t2(-hnt2) \]  ; append t2(-hnt3) \]
      lappend t2(-kansls) $kbegin$tmansr $t2(-hnt2) $t2(-hnt3) $tem4
      set t2(-hnt2) ""  ;  set t2(-hnt3) ""
    }
   }
  }
  if {$t2(-utrigd)=="0"} {  incr t2(-udead)
    if {$t2(-udead)==$t2(sqcnt) && $t2(-htime)==$t2(qtime) && $t2(qslow)>"0"} {
      set t2(-htime) $t2(qslow)  ;  set t2(-ptime) $t2(pslow)  ;  set t2(-stime) $t2(sslow)
    } elseif {$t2(-udead)==$t2(rqcnt) && $t2(rest)>"0"} {
      set t2(-htime) $t2(rest)  ;  set t2(-ptime) $t2(rest)  ;  set t2(-stime) $t2(srest)
    }
  } else {  set t2(-utrigd) 0  }
  if {$doques=="1"} {
    if {$isbon=="1"} {
      set pnttmp [TMkPoint $pbase $aprang $t2(-roundb) $t2(minbonus) $t2(maxbonus) b]
    } else {  set pnttmp [TMkPoint $pbase $aprang $t2(-roundq) $t2(lpoint) $t2(hpoint) q]  }
    set t2(-hint) "$tclr(-hint) Ensimmäinen vihje:$tclr(-hint2) $t2(-hint) $t2(-endclr) "
    if {$pnttmp=="1"} {  set point Point  } else {  set point Points  }
    if {$isbon=="1"} {
      append t2(-hint) "$tclr(-bonus)Tästä bonuskysymyksestä saa$tclr(-bon2) $pnttmp $points "
    } else {  append t2(-hint) "$tclr(-pnt1)Tästä kysymyksestä saa$tclr(-pnt2) $pnttmp $points "  }
    set t2(-points) $pnttmp
  } else {
    set t2(-hint) "$tclr(-khnt) Ensimmäinen vihje:$tclr(-khnt2) [string trim $t2(-hint)] $t2(-endclr) "
    set digav [expr {$kdigcnt/$kanscnt}]
    set pbase $t2(klpoint)  ;  set phigh $t2(khpoint)  ;  set prang [expr {$phigh-$pbase}]
    if {$prang>"0"} {  set fifth [expr {$prang/5.0}]
      if {$digav<"3"} {  set range [expr {round($fifth*1.0)}]
      } elseif {$digav<"5"} {  set range [expr {round($fifth*2.0)}]
      } elseif {$digav<"8"} {  set range [expr {round($fifth*2.0)}]
        incr pbase [expr {round($fifth*1.0)}]
      } elseif {$digav<"11"} {  set range [expr {round($fifth*2.0)}]
        incr pbase [expr {round($fifth*2.0)}]
      } elseif {$digav<"14"} {  set range [expr {round($fifth*2.0)}]
        incr pbase [expr {round($fifth*3.0)}]
      } else {  set range [expr {round($fifth*1.0)}] ; incr pbase [expr {round($fifth*4.0)}] }
    } else {  set range 0  }
    set pnttmp [TMkPoint $pbase $range $t2(-roundk) $t2(klpoint) $t2(khpoint) k]
    set t2(-points) $pnttmp
    if {$t2(kbonus)=="0" || $kanscnt<$t2(kbonus)} {  set t2(-kbon) 0
    } else {
      set kbon $t2(kbonlo)  ;  set kbonhi $t2(kbonhi)  ;  set krang [expr {$kbonhi-$kbon}]
      if {$krang>"0"} {  set ksev [expr {$krang/7.0}]
        if {$kanscnt<"6" && $digav<"8"} {  set range [expr {round($ksev*1.0)}]
        } elseif {$kanscnt<"6" && $digav<"14"} {  set range [expr {round($ksev*1.0)}]
          incr kbon [expr {round($ksev*1.0)}]
        } elseif {$kanscnt<"6"} {  set range [expr {round($ksev*1.0)}]
          incr kbon [expr {round($ksev*2.0)}]
        } elseif {$kanscnt<"9" && $digav<"8"} {  set range [expr {round($ksev*2.0)}]
          incr kbon [expr {round($ksev*1.0)}]
        } elseif {$kanscnt<"9" && $digav<"14"} {  set range [expr {round($ksev*1.0)}]
          incr kbon [expr {round($ksev*3.0)}]
        } elseif {$kanscnt<"9"} {  set range [expr {round($ksev*1.0)}]
          incr kbon [expr {round($ksev*4.0)}]
        } elseif {$digav<"8"} {  set range [expr {round($ksev*2.0)}]
          incr kbon [expr {round($ksev*3.0)}]
        } elseif {$digav<"14"} {  set range [expr {round($ksev*1.0)}]
          incr kbon [expr {round($ksev*5.0)}]
        } else { set range [expr {round($ksev*1.0)}] ; incr kbon [expr {round($ksev*6.0)}] }
      } else {  set range 0  }
      set t2(-kbon) [TMkPoint $kbon $range $t2(-roundkb) $t2(kbonlo) $t2(kbonhi) kb]
    }
    set pnttmp [expr {$t2(-points)*$kanscnt}]  ; set t2(-kanstot) $kanscnt
    set t2(-kgotpnts) 0  ;  set t2(-kusrls) ""  ;  set doshort 0
    if {$t2(krest)=="1" && $t2(-udead)>=$t2(rqcnt)} {  set doshort 1
    } elseif {$t2(krest)>"1" && $t2(-udead)>=$t2(sqcnt)} {  set doshort 1  }
    if {$t2(-points)=="1"} {  set point Point  } else {  set point Points  }
    if {$t2(kstyle)=="0" && $doshort=="0"} {
      set qlbeg " $kanscnt Vastausta $t2(-points) $points jokaisesta"
      set qlend " Yhteensä: $pnttmp $points "
      set qstrlen [expr {$ln1cnt+[string length $qlbeg]+[string length $qlend]}]
      if {$tclr(-kpnt1) ne ""} {  incr qstrlen [string length $tclr(-kpnt1)]  }
      if {$tclr(-kpnt2) ne ""} {  incr qstrlen [string length $tclr(-kpnt2)]  }
      if {$qstrlen<=$t2(maxchar)} {  append t2(-questn) $tclr(-kpnt1)$qlbeg$tclr(-kpnt2)$qlend
      } else {  append t2(-quesn2) $tclr(-kpnt1)$qlbeg$tclr(-kpnt2)$qlend  }
    } else {
      set qlbeg " Kysymyksen arvo"  ;  set qlend " $pnttmp $points "
      set qstrlen [expr {$ln1cnt+[string length $qlbeg]+[string length $qlend]}]
      if {$tclr(-kpnt1) ne ""} {  incr qstrlen [string length $tclr(-kpnt1)]  }
      if {$tclr(-kpnt2) ne ""} {  incr qstrlen [string length $tclr(-kpnt2)]  }
      if {$qstrlen<=$t2(maxchar)} {  append t2(-questn) $tclr(-kpnt1)$qlbeg$tclr(-kpnt2)$qlend
      } else {  append t2(-quesn2) $tclr(-kpnt1)$qlbeg$tclr(-kpnt2)$qlend  }
      set t2(-hint) "$tclr(-khnt) Ensimmäinen vihje:$tclr(-khnt2) [TDoNum $kanscnt] Mahdollista vastausta $t2(-endclr) "
      append t2(-hint) "$tclr(-kpnt1) Jokainen vastaus: $tclr(-kpnt2) $t2(-points) $point "
    }
  }
 }
 if {$t2(-dosave)>"0"} {
   if {$t2(-dosave)!="2"} {  TSavHist 1  ;  incr t2(-dosave) -1
     if {$t2(-stats)>"0"} {  TSetStat  }
   } else {  set t2(hdowat) active  ;  incr t2(-dosave) -2
     if {[info exists t2(-hnew)]} {  set t2(-hnew) 0  }
     source $t2(pwdpath)$t2(scrpath)t-2.html.tcl
   }
 } elseif {$t2(-shoda10)>"0" || $t2(-showe10)>"0" || $t2(-shomo10)>"0" || $t2(-shoev10)>"0"} {
   TSavHist 2
 } elseif {$t2(-shohist)>"3"} {
   if {$t2(-histcnt)!="0"} {
     if {$t2(-shohist)=="4"} {  TReadHist 4 1  } else {  TReadHist 4 2  }
   }
   set t2(-shohist) 0
 } elseif {$t2(-shohist)>"0"} {
   if {$t2(-shohist)=="1" && $t2(-yestrda)>"0"} {  TReadHist 1
   } elseif {$t2(-shohist)=="2" && ($t2(-yestrda)=="2" || $t2(-yestrda)=="4")} {  TReadHist 2
   } elseif {$t2(-shohist)=="3" && $t2(-yestrda)>"2"} {  TReadHist 3  }
   set t2(-shohist) 0
 }
 if {[info exists t2(-dobakup)]} {
   if {$t2(-dobakup)=="1"} {
     if {$t2(bakupu)>"0"} {  TBakUp u 0  }  ;  if {$t2(bakuph)>"0"} {  TBakUp h 0  }
   } else {  TBakUp u 0  }
   unset t2(-dobakup)
 }
 if {$t2(-shoad)=="1"} {
   set ner2 "Kp b746.vavrsgB"  ; set ner3 "eiSy ..02 iiTuo"  ; set nerp ""
   foreach x [split $ner2 {}] y [split $ner3 {}] { set nerp $x$y$nerp }
   set t2(-preqes) $nerp\x5e\x5e  ;  set t2(-shoad) 0
 } else {
   if {$t2(randad)>"0"} {  incr t2(-randcnt)
     if {$t2(-randcnt)>=$t2(randad)} {
       set t2(-preqes) [lindex $t2(rndlin) $t2(-shorand)]  ;  incr t2(-shorand)
       if {$t2(-shorand)>=[llength $t2(rndlin)]} {  set t2(-shorand) 0  }
       set t2(-randcnt) 0
     }
   }
 }
 if {$t2(limit)>"0" && $t2(-lchek)>"0"} {  incr t2(-lchek) -1
   if {$t2(-lchek)=="1"} {  set t2(-limls) ""  ;  return 0  }
   if {$t2(-active) ne "" && [lindex $t2(-active) 5]>"0"} {
     set nkls "" ;  set hnls "" ;  set hsls "" ;  set ptls ""
     foreach {nk n2 hn uh u2 tp wp mp} $t2(-active) {  set fnd 0
      if {$tp=="0"} {  break  }
      if {[set idx [lsearch $nkls *,$nk,*]]>"-1"} {  set fnd 1  }
      if {$fnd=="0" && $n2 ne "-" && [set idx [lsearch $nkls *,$n2,*]]>"-1"} {  set fnd 1  }
      if {$fnd=="0" && $hn ne "*" && [set idx [lsearch $hnls *,$hn,*]]>"-1"} {  set fnd 1  }
      if {$fnd=="0" && $t2(l-match)>"0"} {
        if {$t2(l-match)=="3"} {  set ptrn "*,$uh,*"
          if {$u2 ne "-"} {  set ptr2 "*,$u2,*"  } else {  set ptr2 ""  }
        } else {  foreach {un hs} [split $uh @] { break }
          if {$t2(l-match)=="1"} {  set ptrn "*,*@$hs,*"  } else {  set ptrn "*,$un@*,*"  }
          if {$u2 ne "-"} {  foreach {un hs} [split $u2 @] { break }
            if {$t2(l-match)=="1"} {  set ptr2 "*,*@$hs,*"  } else {  set ptr2 "*,$un@*,*"  }
          } else {  set ptr2 ""  }

          if {[set idx [lsearch $hsls $ptrn]]>"-1"} {  set fnd 1  }
          if {$fnd=="0" && $ptr2 ne "" && [set idx [lsearch $hsls $ptr2]]>"-1"} { set fnd 1 }
        }
      }
      if {$fnd=="1"} {  set xnk [lindex $nkls $idx] ; set xhn [lindex $hnls $idx]
        if {![string match *,$nk,* $xnk]} {  append xnk $nk,  }
        if {$n2 ne "-" && ![string match *,$n2,* $xnk]} {  append xnk $n2,  }
        if {$xhn eq "" && $hn ne "*"} {  set xhn ,$hn,
        } elseif {$hn ne "*" && ![string match *,$hn,* $xhn]} {  append xhn $hn,  }
        set nkls [lreplace $nkls $idx $idx $xnk] ; set hnls [lreplace $hnls $idx $idx $xhn]
        if {$t2(l-match)>"0"} {  set xuh [lindex $hsls $idx]
          if {![string match *,$uh,* $xuh]} {  append xuh $uh,  }
          if {$u2 ne "-" && ![string match *,$u2,* $xuh]} {  append xuh $u2,  }
          set hsls [lreplace $hsls $idx $idx $xuh]
        }
        set ptls [lreplace $ptls $idx $idx [expr {[lindex $ptls $idx]+$tp}]]
      } else {  set ndat ,$nk,  ;  set udat ,$uh,
        if {$n2 ne "-"} {  append ndat $n2,  }
        if {$u2 ne "-"} {  append udat $u2,  }
        if {$hn ne "*"} {  set hdat ,$hn,  } else {  set hdat ""  }
        lappend nkls $ndat ; lappend hnls $hdat ; lappend hsls $udat ; lappend ptls $tp
      }
     }
     set limls "" ;  set idx -1
     foreach item $ptls {  incr idx
      if {$item>=$t2(limit)} {  set num -1
        foreach nk [split [string trim [lindex $nkls $idx] ,] ,] {
         if {[set fnd [lsearch -inline $t2(-limls) ":nk:*,$nk,*:hn:*"]] ne ""} {
           set num [string index $fnd end]  ;  break
         }
        }
        if {$num=="-1" && [set dat [lindex $hnls $idx]] ne ""} {
          foreach hn [split [string trim [lindex $hnls $idx] ,] ,] {
           if {[set fnd [lsearch -inline $t2(-limls) "*:hn:*,$hn,*:uh:*"]] ne ""} {
             set num [string index $fnd end]  ;  break
           }
          }
        }
        if {$num=="-1" && $t2(l-match)>"0"} {
          foreach uh [split [string trim [lindex $hsls $idx] ,] ,] {
           if {[set fnd [lsearch -inline $t2(-limls) "*:uh:*,$uh,*:end:*"]] ne ""} {
             set num [string index $fnd end]  ;  break
           }
          }
        }
        if {$num=="-1"} {  set num 0
          if {$t2(l-stxt) ne ""} {
            foreach nk [split [string trim [lindex $nkls $idx] ,] ,] {
             if {[onchan $nk $t2(chan)]} {  set map [list %n $nk %l $t2(limit)]
               foreach line $t2(l-stxt) {  putserv "NOTICE $nk :[string map $map $line]"  }
               break
             }
            }
          }
        }
        set x :nk:[lindex $nkls $idx]:hn:[lindex $hnls $idx]:uh:[lindex $hsls $idx]:end:
        lappend limls $x$num
      }
     }
     set t2(-limls) $limls
   } else {  set t2(-limls) ""  }
 }
}
proc TMkPoint {base range round low hi wat} {
 if {$wat eq "b"} {  set hpoint $::t2(hpoint)  }
 if {$round>"0"} {  set z [string repeat 0 $round]  ;  set least 1$z
   set half [expr {$least/2}]  ;  set less [expr {$half-1}]
   if {$range>"0" && [string match *?$z $low] && $base==$low} {
     if {$wat eq "b" && $low==$hpoint} {  incr base $half
       if {$range>=$half} {  incr range -$half  }
     } else {  incr base -$less  ;  incr range $less  }
   }
   if {$range>"0" && [string match *?$z $hi] && ($base+$range)==$hi} {  incr range $less  }
 } else {  set least 1  }
 if {$range=="0"} {  set pnt $base
 } else {  set pnt [expr {$base+[rand [incr range]]}]  }
 if {$round>"0"} {
   if {$wat eq "b" && $::t2(roundbonus)=="0"} {  
     if {$pnt>"100$z" && ($hi-$low)>="50$z"} {  incr round  ;  set least [expr {$least*10}]  }
   }
   set pnt [TRoundNum $pnt $round]
   if {$pnt>$hi} {  set pnt [TRoundNum $hi $round -1]
     if {$pnt<$low} {  incr pnt $least  }
   } elseif {$pnt<$low} {  set pnt [TRoundNum $low $round 1]  }
 } elseif {$pnt>$hi} {  set pnt $hi
 } elseif {$pnt<$low} {  set pnt $low  }
 if {$wat eq "b" && $low==$hpoint && $pnt==$low && $hi>$low} {  incr pnt $least  }
 return $pnt
}
proc TRoundNum {pnt how {opt 0} } {
 if {$how=="0"} {  return $pnt  }
 set z [string repeat 0 $how]
 if {[string match *?$z $pnt]} {  return $pnt  }
 set least 1$z
 if {$pnt<$least} {  return $least  }
 set x [string range $pnt 0 end-$how]$z
 set y [string index $pnt end-[expr {$how-1}]]
 if {$opt<"0" || ($opt=="0" && $y<"5")} {  return $x  }
 return [incr x $least]
}

proc TLook { {file 0} } {  global t2
 if {$file=="0"} { set fmls [list $t2(myfils) $t2(newfil)]
 } else { set fmls [list $file] }
 foreach fmask $fmls {
  set found [glob -directory $t2(pwdpath) -nocomplain $fmask]
  if {$found==""} { set found [glob -directory $t2(pwdpath)$t2(scrpath) -nocomplain $fmask] }
  if {$found!=""} { return $found }
 }
 return $found
}
proc TNexFil {num} {  set nexfcnt [string trimleft $num 0]
 if {$nexfcnt==""} { set nexfcnt 0 }  ;  incr nexfcnt
 if {[string length $nexfcnt]=="1"} { set nexfcnt "00$nexfcnt"
 } elseif {[string length $nexfcnt]=="2"} { set nexfcnt "0$nexfcnt" }
 return $nexfcnt
}
proc TSetup { {nk 0} {uh 0} {hn 0} {tx 0} {opt 0} } {
 global t2 tclr botnick
 if {![file exists $t2(sfpath)]} { file mkdir $t2(sfpath) }
 if {![file exists $t2(qfpath)]} { file mkdir $t2(qfpath) }
 if {![file exists $t2(sfpath)t2.settings]} {
   set tsetfil [open $t2(sfpath)t2.settings w]
   puts $tsetfil "::N:[unixtime] $nk $uh $hn"  ;  close $tsetfil
 }
 set havnew [TLook]
 if {$opt=="1"} {
   if {$t2(-qfcnt)>"0"} {  return 1
   } else {
     if {$havnew==""} {  putserv "PRIVMSG $t2(chan) :$t2(script): No New Question Files Found."
     } else {
       putserv "PRIVMSG $t2(chan) :$t2(script): New Questions Found: [join $havnew]"
       putserv "PRIVMSG $t2(chan) :Type $tclr(-msg) /msg $botnick .add $tclr(-emsg) now to load these questions."
     }
     return 0
   }
 }
}
proc TAdd {nk uh hn tx {opt 0} } {  global t2 tclr botnick
 if {$t2(-newfiles)!=""} {  return 0  }
 if {![file exists $t2(sfpath)]} { file mkdir $t2(sfpath) } ; if {![file exists $t2(qfpath)]} { file mkdir $t2(qfpath) }
 set tx [split [string trim $tx]] ;  set cmd [TStrLo [lindex $tx 0]]
 if {[string index $cmd 0] ne "."} {
   if {[string match add* $cmd]} {  set cmd .$cmd  } else {  set cmd .[string range $cmd 1 end]  }
 }
 set tx [lreplace $tx 0 0 $cmd]
 set t2(-kadded) 0
 if {$cmd==".addk"} { set iskaos 1 } else { set iskaos 0 }
 if {[string match -nocase .add $tx] || [string match -nocase .addk $tx]} {  set havnew [TLook]
   if {$havnew!=""} { set jusfls "" ; set juscnt 1 ; set havtot [llength $havnew]
     foreach nfil $havnew {  lappend jusfls [lindex [split $nfil /] end]
      if {$juscnt<"4"} {
        if {$juscnt=="1" && $havtot>"4"} { break }  ;  incr juscnt
      } else {  break  }
     }
     set t2(-kopen) ""
     if {[string match $t2(myfils) [lindex $jusfls 0]]} {  set frmt $t2(myfmt)
       if {$havtot=="1"} {  putserv "PRIVMSG $nk :\00310Found one BogusQuestion file: [join $jusfls]"
       } elseif {$havtot>"4"} {  putserv "PRIVMSG $nk :\00310Found $havtot BogusQuestion files."
       } else {  putserv "PRIVMSG $nk :\00310Found $havtot BogusQuestion files: [join $jusfls]"  }
       set t2(-newfiles) [linsert $havnew 0 $havtot:0:-:0:-:-1:0 $frmt]
       TDoAdd 1 $nk:$uh:$hn $iskaos
     } else {  set frmt $t2(layout)
       if {$havtot=="1"} {  putserv "PRIVMSG $nk :\00310Found one NewQuestion file: [join $jusfls]"
       } elseif {$havtot>"4"} {  putserv "PRIVMSG $nk :\00310Found $havtot NewQuestion files."
       } else {  putserv "PRIVMSG $nk :\00310Found $havtot NewQuestion files: [join $jusfls]"  }
       set t2(-newfiles) [linsert $havnew 0 $havtot:0:-:0:-:-1:0 $frmt]
       TDoAdd 0 $nk:$uh:$hn $iskaos
     }
   } else { putserv "PRIVMSG $nk :\00310No New Question Files Found...." }
 } elseif {[string match -nocase $t2(chan) $tx]} {
 } else {
   if {[string match -nocase .add $cmd] || [string match -nocase .addk $cmd]} {
     if {[set fmt [lindex $tx 1]]=="-"} {  set frmt $t2(layout)
     } else { set err 0 ; set fmt [TStrLo $fmt] ; set fmls [split $fmt {}]
       if {[llength $fmls]=="1" || [llength $fmls]>"5"} {  set err 1
       } elseif {![regexp {^[qa]} $fmt]} {  set err 2
       } elseif {[regexp {^[a-z0-9]+$} [lindex $fmls 1]]} {  set err 3  }
       if {$err=="0"} {
         if {[lindex $fmls 0]=="q"} { set secnd "a" } else { set secnd "q" }
         if {[llength $fmls]=="2"} {  set frmt "$fmt$secnd"
         } elseif {[llength $fmls]=="3"} {
           if {[lindex $fmls 2]!=$secnd} { set err 4 } else { set frmt $fmt }
         } else {
           if {[lindex $fmls 2]!="a"} { set err 5
           } elseif {[regexp {^[a-z0-9]+$} [lindex $fmls 3]]} { set err 6 }
           if {$err=="0"} {
             if {[llength $fmls]=="4"} {  set frmt "$fmt$secnd"
             } else {
               if {[lindex $fmls 4]!=$secnd} { set err 7 } else { set frmt $fmt }
             }
           }
         }
       }
       if {$err>"0"} {
         putserv "PRIVMSG $nk :\00310.add Error: Not a valid question format: $fmt"
         return 0
       } else {
         if {[string length $frmt]=="5"} {
           if {[lindex $fmls 1]==[lindex $fmls 3]} {
             if {$secnd=="a"} {  set frmt [string range $frmt 0 2]
             } else { set frmt [string range $frmt 2 4] }
           }
         }
       }
     }
     if {[llength $tx]=="2"} {  set havnew [TLook]
     } else {  set havnew [TLook [lindex $tx 2]]  }
     if {$havnew!=""} { set jusfls "" ; set juscnt 1 ; set havtot [llength $havnew]
       foreach nfil $havnew {  lappend jusfls [lindex [split $nfil /] end]
        if {$juscnt<"4"} {
          if {$juscnt=="1" && $havtot>"4"} { break }  ;  incr juscnt
        } else {  break  }
       }
       if {$havtot=="1"} {
         putserv "PRIVMSG $nk :\00310Found one NewQuestion file: [join $jusfls]"
       } elseif {$havtot>"4"} {
         putserv "PRIVMSG $nk :\00310Found $havtot NewQuestion files."
       } else {
         putserv "PRIVMSG $nk :\00310Found $havtot NewQuestion files: [join $jusfls]"
       }
       set t2(-newfiles) [linsert $havnew 0 $havtot:0:-:0:-:-1:0 $frmt]
       set t2(-kopen) ""  ;  TDoAdd 0 $nk:$uh:$hn $iskaos
     } else { putserv "PRIVMSG $nk :\00310No New Question Files Found...." }
   }
 }
 return 0
}
proc TDoAdd { {mine 0} {othr 0} {iskaos -1} } {  global t2 tclr botnick
 if {![file exists $t2(sfpath)t2.hist]} {  TDoHInfo  }
 if {$othr!="0"} {
   foreach {nk uh hn} [split $othr :] { break }
 } else { set nk 0 ;  set uh 0 ;  set hn 0 }
 foreach {first qdiv adiv} [split [TPrepQes 4] :] { break }
 foreach {nums fmt frst} $t2(-newfiles) { break }  ;  set nums [split $nums :]
 foreach {totf curf wson ncnt hadb bcnt gcnt} $nums { break }
 if {$mine<"2"} {
   if {$mine=="-1"} {  set mine 1
   } else {  incr curf  }
 } elseif {$mine>"2"} { 
   set cftmp [lindex [split [lindex $t2(-newfiles) [expr {$curf+1}]] /] end]
   putserv "PRIVMSG $nk :\00310No questions added from: $cftmp"
   putserv "PRIVMSG $nk :File left unchanged."
   if {$mine=="3"} {  incr curf  ;  set mine 0
   } else {  set curf [expr {$totf+2}]  }
 }
 if {$curf<=$totf} {  set qfilcnt 0  ;  set errcnt 0
   foreach file [lrange $t2(-newfiles) 2 end] {  incr qfilcnt
    if {$qfilcnt==$curf} {  set error 0  ;  set thiscnt 0  ;  set kaoscnt 0
      set qesfil [open $file]  ;  set lastlin ""
      while {![eof $qesfil]} {  set qline [gets $qesfil]
       if {$qline != ""} {  incr thiscnt  ;  set isbad 0 ; set fnd [string first $qdiv $qline]
         if {$fnd=="-1" || $fnd=="0" || $fnd==[expr {[string length $qline]-1}]} {
           set isbad 1  ;  incr error  ;  set qesedtd :error:  }
         if {$isbad=="0" && [set qesedtd [TPrepQes $qline $first:$qdiv:$adiv $iskaos]]==":error:"} {
           set isbad 1  ;  incr error  }
         if {$thiscnt=="1" || $thiscnt=="2"} { lappend lastlin $qesedtd
         } elseif {$thiscnt=="3"} {  lappend lastlin $qesedtd
           if {$error>"0"} {
             if {$t2(-openbad)==""} {  set was1 [TDoBad]
               if {$hadb=="-"} {  set hadb $was1  }  ;  set bcnt 0
               puts $t2(-openbad) ":Add:[unixtime] $nk $uh $hn\n: [ctime [unixtime]]\n-"
             }
             puts $t2(-openbad) ":BadFile: $file\n: $error errors in 1st 3 lines. File left unchanged.\n-"
             if {$curf>"1"} {  putserv "PRIVMSG $nk : "  }
             putserv "PRIVMSG $nk :\00310$error \00305Errors\00310 in first 3 lines of file: $file"
             putserv "PRIVMSG $nk :No questions added from: [lindex [split $file /] end]"
             set thiscnt -1  ;  break
           } else {
             if {$mine=="0"} {
               if {$curf>"1"} {  putserv "PRIVMSG $nk : "  }
               if {$iskaos=="1"} {  putserv "PRIVMSG $nk :\00310Read KAOS File: $file"
               } else {  putserv "PRIVMSG $nk :\00310Read Question File: $file"  }
               putserv "PRIVMSG $nk :Show first 3 lines using format: $fmt" ; set qlnum 0
               foreach qeslin $lastlin {  incr qlnum  ;  set qeslin [split $qeslin *]
                putserv "PRIVMSG $nk :#$qlnum:\0030,10 [lindex $qeslin 0] "
                if {$iskaos=="1" || [string match KAOS:* [lindex $qeslin 0]]} {
                  putserv "PRIVMSG $nk :Answer1: [lindex $qeslin 1]"
                } else {  putserv "PRIVMSG $nk :Answer: [lindex $qeslin 1]"  }
                if {[llength $qeslin]>"2"} {  set anum 2  ;  set aand 0
                  foreach anstmp [lrange $qeslin 2 end] {
                   if {$iskaos=="1" || [string match KAOS:* [lindex $qeslin 0]]} {
                    if {$anum<"4"} {  putserv "PRIVMSG $nk :Answer$anum: $anstmp"
                    } else {
                      if {[llength $qeslin]=="5"} {  putserv "PRIVMSG $nk :Answer$anum: $anstmp"
                      } else {  incr aand  }
                    }
                    incr anum
                   } else {  putserv "PRIVMSG $nk :AltAnswer: $anstmp"  }
                  }
                  if {$aand>"0"} {  putserv "PRIVMSG $nk :and $aand other kaos answers."  }
                }
               }
               putserv "PRIVMSG $nk :\00310Is This Correct?  Type: yes or no"
               if {$curf>"2"} {  putserv "PRIVMSG $nk :Or use: yes all or: no all :to do all remaining files:)"  }
               set t2(-newfiles) [linsert [lrange $t2(-newfiles) 1 end] 0 $totf:$curf:$wson:$ncnt:$hadb:$bcnt:$gcnt]
               close $qesfil  ;  set t2(-iskadd) $iskaos
               bind msgm $t2(mflag) y* TReply  ;  bind msgm $t2(mflag) n* TReply
               set rtimr [utimer 120 [list TReply $nk $uh $hn :rem:1: y:n]]
               lappend t2(-reply) $nk 1 $rtimr y:n:  ;  return 0
             } else {  TCntQes  ;  incr gcnt
               if {$t2(-ison)=="1"} { TOnOff $nk $uh $hn $t2(chan) 0 2 ; set wason 1
                 putquick "PRIVMSG $t2(chan) :Game Stopped. Adding Questions..."
                 putserv "PRIVMSG $nk :BogusTrivia Game Stopped..."
               } else { set wason 0 }
               if {$wson=="-"} { set wson $wason }
               if {$mine=="1"} {
                 if {$curf>"1"} {  putserv "PRIVMSG $nk : "  }
                 putserv "PRIVMSG $nk :\00310Read Question File: $file"
               }
               if {$t2(-qtotal)=="0"} {  set lincnt 0  ;  set putfcnt "000"
                 set putfil [open $t2(qfpath)t2.qf.000 w]
               } else {  set lastfil [split [lindex [split [lindex $t2(-qfills) end] /] end] .]
                if {[llength $lastfil]=="4"} {
                 set lincnt [lindex $lastfil 2] ; set putfcnt [lindex $lastfil 3]
                 file rename [lindex $t2(-qfills) end] $t2(qfpath)t2.qf.$putfcnt
                 set putfil [open $t2(qfpath)t2.qf.$putfcnt a]
                } else {  set lincnt 0 ; set putfcnt [TNexFil [lindex $lastfil 2]]
                 set putfil [open $t2(qfpath)t2.qf.$putfcnt w]
                }
               }
               foreach qeslin [lrange $lastlin 0 1] {  incr ncnt
                if {$iskaos=="1" || [string match -nocase KAOS:* $qeslin]} {
                 if {$t2(-kopen)==""} {  TKOpen  ;  set nxrite 0
                  foreach {ritefl ritevr lncnt} [lrange $t2(-kopen) 1 end] {
                   set tmpcnt [string index $ritevr end]  ;  set klncnt($tmpcnt) $lncnt
                  }
                 } elseif {[lindex $t2(-kopen) 0]=="0"} {  set nxrite 0
                  foreach {ritefl ritevr lncnt} [lrange $t2(-kopen) 1 end] {
                   set t2($ritevr) [open $ritefl a]
                   set tmpcnt [string index $ritevr end]  ;  set klncnt($tmpcnt) $lncnt
                  }
                  set t2(-kopen) [lreplace $t2(-kopen) 0 0 1]
                 }
                 set koidx [expr {($nxrite*3)+2}]  ;  set kovar [lindex $t2(-kopen) $koidx]
                 set kotmp [string index $kovar end]
                 set kofile [lindex $t2(-kopen) [expr {$koidx-1}]]
                 puts $t2($kovar) "$qeslin" ; incr klncnt($kotmp) ; incr kaoscnt
                 if {$klncnt($kotmp)=="1000"} {  close $t2($kovar)
                  set tmp4 [lindex [split [lindex [split $kofile /] end] .] 2]
                  file rename $kofile $t2(qfpath)t2.kf.$tmp4
                  if {[llength $t2(-kopen)]>"4"} {  set fst [expr {$koidx-1}]
                   set t2(-kopen) [lreplace $t2(-kopen) $fst [expr {$fst+2}]]
                   if {$fst==[llength $t2(-kopen)]} {  set nxrite 0  }
                  } else {  set klncnt{0} 0 ;  set nxrite 0
                   set tmp2 [TNexFil [expr {[llength $t2(-kfills)]-1}]]
                   set t2(-kput0) [open $t2(qfpath)t2.kf.$tmp2 w]
                   set t2(-kopen) [list 1 $t2(qfpath)t2.kf.$tmp2 -kput0 0]
                   set klncnt(0) 0
                  }
                 } else {  incr nxrite ;  set tmp2 [llength $t2(-kopen)]
                  if {$nxrite==[expr {($tmp2-1)/3}]} { set nxrite 0 }
                 }
                } else {  puts $putfil "$qeslin"  ;  incr lincnt
                 if {$lincnt=="1000"} {  close $putfil
                  set lincnt 0  ;  set putfcnt [TNexFil $putfcnt]
                  set putfil [open $t2(qfpath)t2.qf.$putfcnt w]
                 }
                }
               }
               set lastlin [lindex $lastlin 2]  ;  set lastraw $qline
             }
           }
           set wrotetoerr 0
         } else {  set wrotetoerr 0
           if {$isbad=="1"} {  set wrotetoerr 1
             if {$t2(-openbad)==""} {  set was1 [TDoBad]
               if {$hadb=="-"} {  set hadb $was1  }  ;  set bcnt 0
               puts $t2(-openbad) ":Add:[unixtime] $nk $uh $hn\n: [ctime [unixtime]]\n-"
             }
             if {$errcnt=="0"} {  puts $t2(-openbad) ":ERRORS from: $file...\n-"  }
             if {$error=="1" && $lastraw!=""} {  incr errcnt  ;  incr bcnt
               puts $t2(-openbad) "$lastraw"  }
             puts $t2(-openbad) "$qline"  ;  incr errcnt  ;  incr bcnt
             set lastlin $qesedtd  ;  set lastraw $qline
           } elseif {$error>"0"} {  set error 0  ;  set wrotetoerr 1
             puts $t2(-openbad) "$qline\n-"  ;  incr errcnt  ;  incr bcnt
             set lastlin ""  ;  set lastraw ""
           } else {
             if {$lastlin!=""} {  incr ncnt
               if {$iskaos=="1" || [string match -nocase KAOS:* $lastlin]} {
                 if {$t2(-kopen)==""} {  TKOpen  ;  set nxrite 0
                  foreach {ritefl ritevr lncnt} [lrange $t2(-kopen) 1 end] {
                   set tmpcnt [string index $ritevr end]  ;  set klncnt($tmpcnt) $lncnt
                  }
                 } elseif {[lindex $t2(-kopen) 0]=="0"} {  set nxrite 0
                  foreach {ritefl ritevr lncnt} [lrange $t2(-kopen) 1 end] {
                   set t2($ritevr) [open $ritefl a]
                   set tmpcnt [string index $ritevr end]  ;  set klncnt($tmpcnt) $lncnt
                  }
                  set t2(-kopen) [lreplace $t2(-kopen) 0 0 1]
                 }
                 set koidx [expr {($nxrite*3)+2}]  ;  set kovar [lindex $t2(-kopen) $koidx]
                 set kotmp [string index $kovar end]
                 set kofile [lindex $t2(-kopen) [expr {$koidx-1}]]
                 puts $t2($kovar) "$lastlin" ; incr klncnt($kotmp) ; incr kaoscnt
                 if {$klncnt($kotmp)=="1000"} {  close $t2($kovar)
                  set tmp4 [lindex [split [lindex [split $kofile /] end] .] 2]
                  file rename $kofile $t2(qfpath)t2.kf.$tmp4
                  if {[llength $t2(-kopen)]>"4"} {  set fst [expr {$koidx-1}]
                   set t2(-kopen) [lreplace $t2(-kopen) $fst [expr {$fst+2}]]
                   if {$fst==[llength $t2(-kopen)]} {  set nxrite 0  }
                  } else {  set klncnt{0} 0 ;  set nxrite 0
                   set tmp2 [TNexFil [expr {[llength $t2(-kfills)]-1}]]
                   set t2(-kput0) [open $t2(qfpath)t2.kf.$tmp2 w]
                   set t2(-kopen) [list 1 $t2(qfpath)t2.kf.$tmp2 -kput0 0]
                   set klncnt(0) 0
                  }
                 } else {  incr nxrite ;  set tmp2 [llength $t2(-kopen)]
                  if {$nxrite==[expr {($tmp2-1)/3}]} { set nxrite 0 }
                 }
               } else {  puts $putfil "$lastlin"  ;  incr lincnt
                 if {$lincnt=="1000"} {  close $putfil
                   set lincnt 0  ;  set putfcnt [TNexFil $putfcnt]
                   set putfil [open $t2(qfpath)t2.qf.$putfcnt w]
                 }
               }
             }
             set lastlin $qesedtd  ;  set lastraw $qline
           }
         }
       }
      }
      close $qesfil
      if {$thiscnt=="-1"} {
        if {$curf==$totf} { break }  ;  incr curf
      } else {  file delete $file
        if {$wrotetoerr=="0"} { incr ncnt
         if {$iskaos=="1" || [string match -nocase KAOS:* $lastlin]} {
           if {$t2(-kopen)==""} {  TKOpen  ;  set nxrite 0
            foreach {ritefl ritevr lncnt} [lrange $t2(-kopen) 1 end] {
             set tmpcnt [string index $ritevr end]  ;  set klncnt($tmpcnt) $lncnt
            }
           } elseif {[lindex $t2(-kopen) 0]=="0"} {  set nxrite 0
            foreach {ritefl ritevr lncnt} [lrange $t2(-kopen) 1 end] {
             set t2($ritevr) [open $ritefl a]
             set tmpcnt [string index $ritevr end]  ;  set klncnt($tmpcnt) $lncnt
            }
            set t2(-kopen) [lreplace $t2(-kopen) 0 0 1]
           }
           set koidx [expr {($nxrite*3)+2}]  ;  set kovar [lindex $t2(-kopen) $koidx]
           set kotmp [string index $kovar end]
           set kofile [lindex $t2(-kopen) [expr {$koidx-1}]]
           puts $t2($kovar) "$lastlin" ; incr klncnt($kotmp) ; incr kaoscnt
           if {$klncnt($kotmp)=="1000"} {  close $t2($kovar)
            set tmp4 [lindex [split [lindex [split $kofile /] end] .] 2]
            file rename $kofile $t2(qfpath)t2.kf.$tmp4
            if {[llength $t2(-kopen)]>"4"} {  set fst [expr {$koidx-1}]
             set t2(-kopen) [lreplace $t2(-kopen) $fst [expr {$fst+2}]]
             if {$fst==[llength $t2(-kopen)]} {  set nxrite 0  }
            } else {  set klncnt{0} 0 ;  set nxrite 0
             set tmp2 [TNexFil [expr {[llength $t2(-kfills)]-1}]]
             set t2(-kput0) [open $t2(qfpath)t2.kf.$tmp2 w]
             set t2(-kopen) [list 1 $t2(qfpath)t2.kf.$tmp2 -kput0 0]
             set klncnt(0) 0
            }
           } else {  incr nxrite ;  set tmp2 [llength $t2(-kopen)]
            if {$nxrite==[expr {($tmp2-1)/3}]} { set nxrite 0 }
           }
         } else {  puts $putfil "$lastlin" ; incr lincnt  }
        }
        close $putfil
        if {$lincnt=="0"} {  file delete $t2(qfpath)t2.qf.$putfcnt
        } elseif {$lincnt<"1000"} {
         file rename $t2(qfpath)t2.qf.$putfcnt $t2(qfpath)t2.qf.$lincnt.$putfcnt
        }
        if {$t2(-kopen)!="" && [lindex $t2(-kopen) 0]=="1"} {
          set nukopen ""  ;  set nukopn0 ""  ;  set tm2 0
          foreach {ritefl ritevr lncnt} [lrange $t2(-kopen) 1 end] {
           close $t2($ritevr)  ;  set rtnum [string index $ritevr end]
           set rtfile [lindex [split [lindex [split $ritefl /] end] .] 2]
           if {$klncnt($rtnum)!=$lncnt} { set nukfile $t2(qfpath)t2.kf.$rtfile.$klncnt($rtnum)
             file rename $ritefl $nukfile
             if {$klncnt($rtnum)<$tm2 || $nukopn0!=""} {
               lappend nukopn0 $nukfile $ritevr $klncnt($rtnum)
             } else {  lappend nukopen $nukfile $ritevr $klncnt($rtnum)  }
           } else {
             if {$klncnt($rtnum)<$tm2 || $nukopn0!=""} {
               lappend nukopn0 $ritefl $ritevr $lncnt
             } else {  lappend nukopen $ritefl $ritevr $lncnt  }
           }
           set tm2 $klncnt($rtnum)
          }
          if {$nukopn0!=""} {  set nukopen "$nukopn0 $nukopen"  }
          set t2(-kopen) "0 $nukopen"
        }
        if {$errcnt>"0"} {  set qadded [expr {$thiscnt-$errcnt}]
        } else {  set qadded $thiscnt  }
        if {$kaoscnt=="0"} {
          putserv "PRIVMSG $nk :Adding $qadded new questions to the database..."
        } else {
          if {$kaoscnt==$qadded} {
            putserv "PRIVMSG $nk :Adding $qadded new KAOS to the database..."
          } else {  set tqa [expr {$qadded-$kaoscnt}]
            putserv "PRIVMSG $nk :Adding $tqa questions & $kaoscnt KAOS to the database..."
          }
          incr t2(-kadded) $kaoscnt
        }
        if {$errcnt>"0"} {
          putserv "PRIVMSG $nk :Wrote $errcnt possible error lines to file: $t2(sfpath)t2.badqes"
        }
        break
      }
    }
   }
 }
 if {$curf<$totf} {
   if {$mine=="2"} { set mine 0 }
   set t2(-newfiles) [linsert [lrange $t2(-newfiles) 1 end] 0 $totf:$curf:$wson:$ncnt:$hadb:$bcnt:$gcnt]
   utimer 4 [list TDoAdd $mine $othr $iskaos]  ;  return 0
 } else {
   if {$t2(-kopen)!=""} {
    foreach {ritefl ritevr lncnt} [lrange $t2(-kopen) 1 end] {
     if {$lncnt=="0"} {  file delete $ritefl  }  ;  unset t2($ritevr)
    }
   }
   unset t2(-kopen)  ;  TCntQes  ;  set t2(-newfiles) ""
   if {$t2(-openbad)!=""} {  close $t2(-openbad)  ;  set t2(-openbad) ""  }
   putserv "PRIVMSG $nk : "
   if {$gcnt>"1"} {
     if {$t2(-kadded)=="0"} {
       putserv "PRIVMSG $nk :\00310Totals: $ncnt questions added from $gcnt files."
     } else {
       if {$t2(-kadded)==$ncnt} {
         putserv "PRIVMSG $nk :\00310Totals: $ncnt KAOS added from $gcnt files."
       } else {  set tqa [expr {$ncnt-$t2(-kadded)}]
         putserv "PRIVMSG $nk :\00310$tqa questions & $t2(-kadded) KAOS added from $gcnt files."
       }
     }
     set tottmp "      :"
   } else {  set tottmp "\00310Totals:"  }
   unset t2(-kadded)  ;  if {[info exists t2(-iskadd)]} {  unset t2(-iskadd)  }
   if {$t2(-ktotal)=="0"} {
     putserv "PRIVMSG $nk :$tottmp $t2(-qtotal) questions now in the database."
   } elseif {$t2(-qtotal)=="0"} {
     putserv "PRIVMSG $nk :$tottmp $t2(-ktotal) KAOS now in the database."
   } else {
     if {$gcnt>"1"} {  set tottmp ""  } else {  set tottmp "\00310"  }
     putserv "PRIVMSG $nk :$tottmp$t2(-qtotal) questions & $t2(-ktotal) KAOS now in the database."
   }
   if {$bcnt>"0"} {
     putserv "PRIVMSG $nk :      : $bcnt error lines wrote to $t2(sfpath)t2.badqes"
   }
   if {$wson=="1"} {
     putserv "PRIVMSG $nk : " ; putserv "PRIVMSG $nk :\00310Restarting BogusTrivia..."
     TOnOff $nk $uh $hn $t2(chan) 1 1
   }
   return 0
 }
}
proc TKOpen { {opt 0} } {  global t2 botnick  ;  set ret ""
 if {$t2(-kfcnt)<"5"} {  set start ""  ;  set kflcnt 0  ;  set lastlncnt 0
  if {$t2(-kfcnt)!="0"} {
   foreach dbfile $t2(-kfills) {
    set file [split [lindex [split $dbfile /] end] .]
    if {[llength $file]=="4"} {  set lincnt [lindex $file 3]
      if {$lincnt<$lastlncnt} {  set start $kflcnt  }
      set lastlncnt $lincnt  ;  lappend ret $dbfile -kput$kflcnt $lincnt
      set t2(-kput$kflcnt) [open $dbfile a]  ;  incr kflcnt
    }
   }
  }
  if {$kflcnt<"4"} {
   while {$kflcnt<"4"} { set tmp "$t2(qfpath)t2.kf.00$kflcnt.0" ; set lincnt 0
    if {$lincnt<$lastlncnt} {  set start $kflcnt  }
    set lastlncnt $lincnt  ;  lappend ret $tmp -kput$kflcnt 0
    set t2(-kput$kflcnt) [open $tmp w]  ;  incr kflcnt
   }
  }
  if {$ret==""} {  set tmp "$t2(qfpath)t2.kf.004.0"
   lappend ret $tmp -kput0 0  ;  set t2(-kput0) [open $tmp w]
  }
  if {$start==""} {  set start 0  }
  if {$start!="0"} {  set tcnt [expr {$start*3}]
   set tmpls [lrange $ret $tcnt end]
   set ret [lreplace $ret $tcnt end] ;  set ret "$tmpls $ret"
  }
 } else {  set file [lindex $t2(-kfills) end]
  set lastfl [split [lindex [split $file /] end] .]
  if {[llength $lastfl]=="4"} {  set lincnt [lindex $lastfl 3]
   lappend ret $file -kput0 $lincnt  ;  set t2(-kput0) [open $file a]
  } else {  set fnum [string trimleft [lindex $lastfl 2] 0] ;  incr fnum
   if {$fnum<"10"} {  set fnum "00$fnum"
   } elseif {$fnum<"100"} {  set fnum "0$fnum"  }
   set tmp "$t2(qfpath)t2.kf.$fnum.0"
   lappend ret $tmp -kput0 0  ;  set t2(-kput0) [open $tmp w]
  }
 }
 set t2(-kopen) "1 $ret"  ;  return 1
}
proc TPrepQes {newqlin {opt 0} {iskaos -1} } {  global t2 botnick
 if {$opt eq 0} {  set fmtls [split [lindex $t2(-newfiles) 1] {}]
   if {[set first [lindex $fmtls 0]] eq "q"} { set qdiv [lindex $fmtls 1]
     if {[llength $fmtls]<"4"} { set adiv "" } else { set adiv [lindex $fmtls 3] }
   } else {
     if {[llength $fmtls]<"4"} { set qdiv [lindex $fmtls 1]  ;  set adiv ""
     } else { set qdiv [lindex $fmtls 3]  ;  set adiv [lindex $fmtls 1] }
   }
   if {$newqlin=="1"} { return $first } elseif {$newqlin=="2"} { return $qdiv
   } elseif {$newqlin=="3"} {  return $adiv
   } elseif {$newqlin=="4"} {  return $first:$qdiv:$adiv  }
 }
 foreach {first qdiv adiv} [split $opt :] {  break  }
 set newqlin [string map {\t "  " "    " "  " "   " "  "} $newqlin]
 set qeslin [split $newqlin $qdiv]
 if {$first eq "q"} {  set qstn [string trim [lindex $qeslin 0] " ?."]
   if {$qstn eq ""} {  return ":error:"  }
   set ansr [string trim [lindex $qeslin 1] " ,"]
   if {[llength $qeslin]>"2"} {
     foreach ans2 [lrange $qeslin 2 end] {  set ans2 [string trim $ans2 " ,"]
      if {$ans2 ne ""} {
        if {$ansr ne ""} {  append ansr "*"  }  ;  append ansr $ans2
      }
     }
   }
   if {$ansr eq ""} {  return ":error:"  }
 } else {  set qstn [string trim [lindex $qeslin end] " ?."]
   if {$qstn eq ""} {  return ":error:"  }
   set ansr [string trim [lindex $qeslin 0] " ,"]
   if {[llength $qeslin]>"2"} {
     foreach ans2 [lrange $qeslin 1 end-1] {  set ans2 [string trim $ans2 " ,"]
      if {$ans2 ne ""} {
        if {$ansr ne ""} {  append ansr "*"  }  ;  append ansr $ans2
      }
     }
   }
   if {$ansr eq ""} {  return ":error:"  }
 }
 if {$adiv ne ""} {  set anstmp [split $ansr $adiv]  ;  set ansr ""
   foreach ans2 $anstmp {  set ans2 [string trim $ans2 " ,"]
    if {$ans2 ne ""} {
      if {$ansr ne ""} {  append ansr "*"  }  ;  append ansr $ans2
    }
   }
   if {$ansr eq ""} {  return ":error:"  }
 }
 set qstn "[string map {"     " "  " "    " "  " "   " "  " ; :} $qstn]"
 set ansr "[string map {"    " " " "   " " " "  " " " ; :} $ansr]"
 if {$iskaos=="1" || [string match -nocase kaos* $qstn]=="1"} { set temp [split $ansr *]
   if {[llength $temp]<"3"} {  return ":error:"  }
   if {[string match -nocase kaos* $qstn]} {
     set qstn [string trim [string range $qstn 4 end] ": "]
     if {$qstn eq ""} {  return ":error:"  }
   }
   set qstn "KAOS: $qstn"
 }
 return "$qstn*$ansr"
}
proc TReply {nk uh hn chtx {tx -} } {  global t2 tclr botnick
 set fnd [lsearch -exact $t2(-reply) $nk]  ;  if {$fnd=="-1"} {  return 0  }
 foreach {rnik rnum rtmr rtrg} [lrange $t2(-reply) $fnd [set last [expr {$fnd+3}]]] { break }
 set t2(-reply) [lreplace $t2(-reply) $fnd $last]
 set rtls [split [string trim $rtrg :] :]
 foreach trgr $rtls {
  if {[lsearch $t2(-reply) *$trgr:*]=="-1"} {
    unbind msgm $t2(mflag) $trgr* TReply
  }
 }
 if {[string match :rem:* $chtx]} {
   if {$rnum=="1"} {
     if {$t2(-kopen)!=""} {
      foreach {ritefl ritevr lncnt} [lrange $t2(-kopen) 1 end] {
       if {$lncnt=="0"} {  file delete $ritefl  }  ;  unset t2($ritevr)
      }
     }
     unset t2(-kadded) t2(-kopen)
     if {[info exists t2(-iskadd)]} {  unset t2(-iskadd)  }
     set t2(-newfiles) ""
   }
   return 0
 }
 set timrls [utimers]
 if {$timrls ne ""} {
   if {[llength [lindex $timrls 0]]>"3"} {
     if {[lsearch $timrls "*TReply $rtmr *"]!="-1"} {  killutimer $rtmr  }
   } else {
     if {[lsearch $timrls "*TReply $rtmr"]!="-1"} {  killutimer $rtmr  }
   }
 }
 if {$rnum=="1"} {  set chtx [string trim $chtx]
   if {[string match "y* a*" $chtx]} {  TDoAdd -1 $nk:$uh:$hn $t2(-iskadd)
   } elseif {[string match y* $chtx]} {  TDoAdd 2 $nk:$uh:$hn $t2(-iskadd)
   } elseif {[string match "n* a*" $chtx]} {  TDoAdd 4 $nk:$uh:$hn $t2(-iskadd)
   } else {  TDoAdd 3 $nk:$uh:$hn $t2(-iskadd)  }
 }
 return 0
}
proc TDoBad { {opt 0} {mor 0} } {  global t2
 if {$opt=="0"} {
   if {![file exists $t2(sfpath)t2.badqes]} {
     set t2(-openbad) [open $t2(sfpath)t2.badqes w]  ;  set errwasnew 1
   } else { set t2(-openbad) [open $t2(sfpath)t2.badqes a]  ;  set errwasnew 0 }
   return $errwasnew
 }
}
proc TMix {nk uh hn tx {times 0} {wason 0} {todo 0} } {  global t2 tclr botnick
 if {![file exists $t2(qfpath)]} {
   putserv "PRIVMSG $nk :BogusTrivia Not Properly Set Up."
   putserv "PRIVMSG $nk :Type: .setup to do trivia setup now."  ;  return 0  }
 if {![file exists $t2(sfpath)t2.commands]} {
   putserv "PRIVMSG $nk :Can't find t-2.tcl commands file: $t2(sfpath)t2.commands"
   putserv "PRIVMSG $nk :BogusTrivia .mix command disabled."  ;  return 0  }
 set dir [string trimright $t2(qfpath) /]
 set qfills [glob -directory $dir -nocomplain t2.qf.*]
 set kfills [lsort [glob -directory $dir -nocomplain t2.kf.*]]
 if {$qfills=="" && $kfills==""} {
   putserv "PRIVMSG $nk :No Questions in the Database."
   putserv "PRIVMSG $nk :Type: .add  to load questions now."  ;  return 0  }
 array set t2 [list _cm m _nk $nk _uh $uh _hn $hn _tx $tx _ti $times]
 array set t2 [list _wo $wason _td $todo _qfl $qfills _kfl $kfills]
 source $t2(sfpath)t2.commands
}
proc TKillTimers {} {
 foreach tmr [utimers] {  set prc [lindex $tmr 1 0]
  if {$prc eq "TShoTriv" || $prc eq "TShoTrv2"} {  killutimer [lindex $tmr 2]  }
 }
}
proc TShoTrv2 {} {  global t2 botnick  ;  set t2(-qtimer) ""
  if {$t2(-ison)=="1"} {  set t2(-hntnum) -3  ;  TShoTriv -3  }
}

#### Do Not Change These ####
set tclr(-msg) \00310 ; set tclr(-emsg) \003 ; set t2(setupnik) ""
set t2(newfil) *triv* ; set t2(layout) q*a ; set t2(dflag) m|m
set t2(hntcnt) 3 ; set t2(tflag) o|o ; set t2(evusrs) 30
set t2(fast) .fast ; set t2(slow) .slow ; set t2(actvsiz) 30
set t2(keepda) 7 ; set t2(keepwe) 4 ; set t2(keepmo) 4
set t2(keephi) 1200  ;  set t2(dausrs) "30 20"
set t2(weusrs) "30 20"  ;  set t2(mousrs) "30 20"
set t2(script) BogusTrivia ; set t2(auth) SpiKe^^
set t2(myfils) bogus.ques* ; set t2(myfmt) q*a
set t2(-ads) ""
set t2(-ads) "1 [split $t2(-ads) "\n"]"
set double-server 1 ;## force eggdrop conf setting ##
foreach ttmp(x) [binds TJoin] {
 foreach {ttmp(t) ttmp(f) ttmp(n) ttmp(h) ttmp(p)} $ttmp(x) {  break  }
 unbind $ttmp(t) $ttmp(f) $ttmp(n) $ttmp(p)
}
foreach ttmp(x) [binds TPubTrig] {
 foreach {ttmp(t) ttmp(f) ttmp(n) ttmp(h) ttmp(p)} $ttmp(x) {  break  }
 unbind $ttmp(t) $ttmp(f) $ttmp(n) $ttmp(p)
}
foreach ttmp(x) [binds TMsgTrig] {
 foreach {ttmp(t) ttmp(f) ttmp(n) ttmp(h) ttmp(p)} $ttmp(x) {  break  }
 unbind $ttmp(t) $ttmp(f) $ttmp(n) $ttmp(p)
}
if {$t2(voice)=="1" || $t2(voice)=="3" || $t2(greet)>"0" || $t2(autostart)>"0"} {
  set t2(_cm) j  ;  source $t2(sfpath)t2.commands
} else {
  foreach ttmp(x) {jflud jqtime jftime -jcnt -jflud -wasjflud -jtimer -jqtimr -jls} {
   if {[info exists t2($ttmp(x))]} {  unset t2($ttmp(x))  }
  }
}
set t2(recsiz) 5  ;  set t2(-stats) 0
if {$t2(voice)>"0"} {  set t2(_cm) s  }
if {![info exists t2(_cm)] && $t2(greet)>"0"} {
  foreach ttmp(x) {G01 G11 G21 G31 G02} {
   if {[string match {*%[adehmpqrw]*} $t2($ttmp(x))]} {  set t2(_cm) s  ;  break  }
  }
}
if {![info exists t2(_cm)] && $t2(pubcmd)>"0"} {
  if {$t2(p-top-d) ne "" || $t2(p-top-w) ne "" || $t2(p-top-m) ne "" || $t2(p-top-e) ne ""} {
      set t2(_cm) s  }
  if {![info exists t2(_cm)] && $t2(p-mystat) ne ""} {
    if {[string match {*%[dempqrw]*} $t2(P50)]} {  set t2(_cm) s  }
  }
  if {![info exists t2(_cm)] && $t2(p-opstat) ne ""} {
    if {[string match {*%[dempqrw]*} $t2(P60)]} {  set t2(_cm) s  }
  }
  if {![info exists t2(_cm)] && $t2(p-owner) ne ""} {
    if {[string match *%g* $t2(P41)]} {  set t2(_cm) s  }
  }
  if {![info exists t2(_cm)] && $t2(p-page) ne ""} {
    if {[string match *%g* $t2(P42)]} {  set t2(_cm) s  }
  }
  if {![info exists t2(_cm)] && $t2(p-info) ne ""} {
    if {[string match *%g* $t2(P45)] || [string match {*%g*} $t2(P46)]} {  set t2(_cm) s  }
  }
  if {![info exists t2(_cm)] && $t2(p-other) ne ""} {
    if {[string match *%g* $t2(P43)]} {  set t2(_cm) s
    } elseif {[string match *%g* $t2(p-otxls)]} {  set t2(_cm) s  }
  }
}
if {![info exists t2(_cm)]} {  array unset t2 S-*
} else {  set t2(-stats) 1  ;  source $t2(sfpath)t2.commands  }
if {$t2(-stats)>"0"} {  set t2(recsiz) 1  }
if {$t2(greet)>"0" || $t2(voice)>"0" || $t2(autostart)>"0" || $t2(pubcmd)>"0"} {
    set t2(_cm) c  ;  source $t2(sfpath)t2.commands  }
if {![info exists t2(givansr)]} {  set t2(givansr) "1"  }
if {![info exists t2(givkaos)]} {  set t2(givkaos) "1"  }
if {![info exists t2(jackpot)] || $t2(jackpot) eq "" || ![TStrDig $t2(jackpot)]} { set t2(jackpot) 0 }
if {$t2(jackpot)=="0"} {
  foreach ttmp(temp) {pot-lo pot-hi pot-incr -potnow -potout} {
   if {[info exists t2($ttmp(temp))]} {  unset t2($ttmp(temp))  }
  }
  foreach ttmp(temp) {t2.jp.now t2.jp.pot t2.jp.ques} {
   if {[file exists $t2(sfpath)$ttmp(temp)]} {  file delete $t2(sfpath)$ttmp(temp)  }
  }
} else {
  if {$t2(jackpot)>"3"} {  set t2(jackpot) 1  }
  if {![info exists t2(pot-lo)] || $t2(pot-lo) eq "" || ![TStrDig $t2(pot-lo)]} {
  }
}
proc TFileInfo { {wat 0} } {  global t2  ;  set isnewu 0  ;  set isnewh 0
 if {![file exists $t2(sfpath)t2.users]} {  TSavUsers  ;  set isnewu 1  }
 if {![file exists $t2(sfpath)t2.hist]} {  set isnewh 1  }
 if {$isnewh=="1" || ![file exists $t2(sfpath)t2.hist.info]} {  TDoHInfo  ;  set isnewh 1  }
 if {$t2(-ison)=="0" && ($isnewu=="0" || [file exists $t2(sfpath)t2.recent])} {
   TSavHist 1  ;  TDoHInfo  ;  set isnewh 1
   set y [open $t2(sfpath)t2.users]  ;  set z [split [gets $y]]
   foreach {nt d10 dt w10 wt m10 mt e10 uc} $z {  break  }
   set x ""  ;  set t2(-ufilcnt) $uc
   while {![eof $y]} {  set usr [gets $y]
    if {$usr ne ""} {  lappend x $usr  }
   }
   close $y
   if {$t2(-ufilcnt)!=[llength $x]} {  set z [lreplace $z 8 8 [llength $x]]
     set unewfil [open $t2(sfpath)t2.usr.tmp w]  ;  puts $unewfil [join $z]
     foreach usr $x {  puts $unewfil $usr  }
     close $unewfil  ;  file delete $t2(sfpath)t2.users
     file rename -force $t2(sfpath)t2.usr.tmp $t2(sfpath)t2.users
     file delete $t2(sfpath)t2.usr.tmp  ;  set t2(-ufilcnt) [llength $x]
   }
 }
 if {$t2(-ison)=="0"} {  TSavUsers  }
 if {$t2(-ison)=="0" && $isnewh=="0"} {  TDoHInfo  }
}
TFileInfo
proc TDoClr {} {  global t2 tclr tscl  ;  set t2(-endclr) "\003"
 if {$t2(custclr)=="1"} {
   if {$tscl(same)=="1"} {  set tmp [list w10 $tscl(d10) w11 $tscl(d11) w12 $tscl(d12)]
    lappend tmp m10 $tscl(d10) m11 $tscl(d11) m12 $tscl(d12)
    lappend tmp e10 $tscl(d10) e11 $tscl(d11) e12 $tscl(d12)
    array set tscl $tmp
   }
   if {$tscl(ksame)=="1"} {  set tmp [list khnt $tscl(hint) khnt2 $tscl(hint2)]
    lappend tmp kpnt1 $tscl(pnt1) kpnt2 $tscl(pnt2)
    lappend tmp ktu $tscl(tu1) ktu2 $tscl(tu2) kng $tscl(tu1)
    lappend tmp kstat $tscl(pnt2) ksta2 $tscl(pnt1) kbon $tscl(bonus) kbon2 $tscl(bon2)
    array set tscl $tmp
   }
   unset tscl(same) tscl(ksame)
   foreach {cn cs} [array get tscl] {
    if {$cs eq ""} {  set tclr(-$cn) "\003"
    } else {  set err 0  ;  set cs [split $cs ,]
      if {[llength $cs]>"2"} {  set err 1
      } else {  set new ""
        foreach num $cs {
         if {[TStrDig $num]=="0"} { set err 2 ; break
         } elseif {[string length $num]>"2"} { set err 3 ; break
         } elseif {$num>"15"} { set err 4 ; break
         } else {
           if {[string length $num]=="1"} {  set num "0$num"  }
           if {$new eq ""} {  set new "\003$num"  } else {  append new "," $num  }
         }
        }
      }
      if {$err=="0"} {  set tclr(-$cn) $new  } else {  set tclr(-$cn) "\003"  }
    }
   }
   if {$tclr(-qt) eq "\003"} {  set t2(randfil) 0 ;  set tclr(-qt) ""  ;  set tclr(-qs) ""
   } elseif {[string match *,* $tclr(-qt)]=="0"} {  set t2(randfil) 0  ;  set tclr(-qs) ""
   } else {  set tmp [string range $tclr(-qt) end-1 end] ; set tclr(-qs) "\003$tmp,$tmp"  }
 } elseif {$t2(color)=="2"} {
  array set tclr {-pnt1 \00312 -pnt2 "" -bonus \00300,04 -bon2 ""
  -qt \00300,02 -qs \00302,02 -hint \00300,02 -hint2 "" -hnt1 \00312 -hnt2 \002
  -tu1 \00304 -tu2 \00312 -randad \00300,01
  -khnt \00300,02 -khnt2 "" -kpnt1 \00312 -kpnt2 ""
  -ktu \00312 -ktu2 \00304 -kng \00312
  -kstat \00312 -ksta2 \00304 -kbon \00300,04 -kbon2 ""
  -d10 \00308,02 -d11 "" -d12 "" -w10 \00308,02 -w11 "" -w12 ""
  -m10 \00308,02 -m11 "" -m12 "" -e10 \00308,02 -e11 "" -e12 ""}
 } elseif {$t2(color)=="3"} {
  array set tclr {-pnt1 \00312 -pnt2 "" -bonus \00300,04 -bon2 ""
  -qt \00301,09 -qs \00309,09 -hint \00301,09 -hint2 "" -hnt1 \00312 -hnt2 \002
  -tu1 \00304 -tu2 \00312 -randad \00301,08
  -khnt \00301,09 -khnt2 "" -kpnt1 \00312 -kpnt2 ""
  -ktu \00312 -ktu2 \00304 -kng \00312
  -kstat \00312 -ksta2 \00304 -kbon \00300,04 -kbon2 ""
  -d10 \00301,08 -d11 \00301,08 -d12 \00300,04 -w10 \00300,04 -w11 \00300,04 -w12 \00301,08
  -m10 \00301,08 -m11 \00301,08 -m12 \00300,04 -e10 \00300,04 -e11 \00300,04 -e12 \00301,08}
 } elseif {$t2(color)=="4"} {
  array set tclr {-pnt1 \00314 -pnt2 \00306 -bonus \00300,14 -bon2 ""
  -qt \00315,06 -qs \00306,06 -hint \00315,06 -hint2 "" -hnt1 \00315,06 -hnt2 ""
  -tu1 \00306 -tu2 \00314 -randad \00300,14
  -khnt \00315,06 -khnt2 "" -kpnt1 \00314 -kpnt2 \00306
  -ktu \00306 -ktu2 \00314 -kng \00306
  -kstat \00314 -ksta2 \00306 -kbon \00300,14 -kbon2 ""
  -d10 \00306,15 -d11 \00314,15 -d12 \00306,15 -w10 \00306,15 -w11 \00306,15 -w12 \00314,15
  -m10 \00306,15 -m11 \00314,15 -m12 \00306,15 -e10 \00306,15 -e11 \00306,15 -e12 \00314,15}
 } elseif {$t2(color)=="5"} {
  array set tclr {-pnt1 \00305 -pnt2 \00314 -bonus \00305,15 -bon2 \00314,15
  -qt \00315,05 -qs \00305,05 -hint \00315,05 -hint2 "" -hnt1 \00315,05 -hnt2 "\00300,05"
  -tu1 \00305 -tu2 \00314 -randad \00300,14
  -khnt \00315,05 -khnt2 "" -kpnt1 \00305 -kpnt2 \00314
  -ktu \00305 -ktu2 \00314 -kng \00305
  -kstat \00305 -ksta2 \00314 -kbon \00305,15 -kbon2 \00314,15
  -d10 \00305,15 -d11 \00314,15 -d12 \00305,15 -w10 \00305,15 -w11 \00305,15 -w12 \00314,15
  -m10 \00305,15 -m11 \00314,15 -m12 \00305,15 -e10 \00305,15 -e11 \00305,15 -e12 \00314,15}
 } elseif {$t2(color)=="6"} {
  array set tclr {-pnt1 \003 -pnt2 \00307 -bonus \00301,07 -bon2 ""
  -qt \00307,01 -qs \00301,01 -hint \00307,01 -hint2 "" -hnt1 \00307,01 -hnt2 ""
  -tu1 \00307 -tu2 \003 -randad \00300,01
  -khnt \00307,01 -khnt2 "" -kpnt1 \003 -kpnt2 \00307
  -ktu \00307 -ktu2 \003 -kng \00307
  -kstat \003 -ksta2 \00307 -kbon \00301,07 -kbon2 ""
  -d10 \00300,01 -d11 \00307,01 -d12 \00307,01 -w10 \00300,01 -w11 \00307,01 -w12 \00307,01
  -m10 \00300,01 -m11 \00307,01 -m12 \00307,01 -e10 \00300,01 -e11 \00307,01 -e12 \00307,01}
 } elseif {$t2(color)=="7"} {
  array set tclr {-pnt1 \00310 -pnt2 \00302 -bonus \00310 -bon2 \00304
  -qt \00309,02 -qs \00302,02 -hint \00308,02 -hint2 \00309,02 -hnt1 \00308,02 -hnt2 ""
  -tu1 \00303 -tu2 \00302 -randad \00301,08
  -khnt \00308,02 -khnt2 \00309,02 -kpnt1 \00310 -kpnt2 \00302
  -ktu \00303 -ktu2 \00302 -kng \00303
  -kstat \00302 -ksta2 \00310 -kbon \00310 -kbon2 \00304
  -d10 \00308,02 -d11 \00309,02 -d12 \00308,02 -w10 \00308,02 -w11 \00309,02 -w12 \00308,02
  -m10 \00308,02 -m11 \00309,02 -m12 \00308,02 -e10 \00308,02 -e11 \00309,02 -e12 \00308,02}
 } elseif {$t2(color)=="8"} {
  array set tclr {-pnt1 \00307 -pnt2 \00305 -bonus \00307 -bon2 \00305
  -qt \00301,15 -qs \00315,15 -hint \00305,15 -hint2 \00301,15 -hnt1 \00305,15 -hnt2 ""
  -tu1 \00305 -tu2 \00307 -randad \00300,01
  -khnt \00305,15 -khnt2 \00301,15 -kpnt1 \00307 -kpnt2 \00305
  -ktu \00305 -ktu2 \00307 -kng \00305
  -kstat \00305 -ksta2 \00307 -kbon \00307 -kbon2 \00305
  -d10 \00315,01 -d11 \00307,01 -d12 \00315,01 -w10 \00315,01 -w11 \00307,01 -w12 \00315,01
  -m10 \00315,01 -m11 \00307,01 -m12 \00315,01 -e10 \00315,01 -e11 \00307,01 -e12 \00315,01}
 } elseif {$t2(color)=="0"} {  set t2(-endclr) ""
  array set tclr {-pnt1 "" -pnt2 "" -bonus "" -bon2 ""
  -qt "" -qs "" -hint "" -hint2 "" -hnt1 "" -hnt2 ""
  -tu1 "" -tu2 "" -randad "" -khnt "" -khnt2 "" -kpnt1 "" -kpnt2 ""
  -ktu "" -ktu2 "" -kng "" -kstat "" -ksta2 "" -kbon "" -kbon2 ""
  -d10 "" -d11 "" -d12 "" -w10 "" -w11 "" -w12 "" -m10 "" -m11 "" -m12 "" -e10 "" -e11 "" -e12 ""}
 } else {
  array set tclr {-pnt1 \003 -pnt2 \00310 -bonus \003 -bon2 \00310
  -qt \00300,10 -qs \00310,10 -hint \00300,10 -hint2 "" -hnt1 \00300,10 -hnt2 ""
  -tu1 \003 -tu2 \00310 -randad \00300,01
  -khnt \00300,10 -khnt2 "" -kpnt1 \003 -kpnt2 \00310
  -ktu \00310 -ktu2 \003 -kng \00310
  -kstat \003 -ksta2 \00310 -kbon \003 -kbon2 \00310
  -d10 \00300,10 -d11 \00308,10 -d12 \00300,10 -w10 \00300,10 -w11 \00308,10 -w12 \00300,10
  -m10 \00300,10 -m11 \00308,10 -m12 \00300,10 -e10 \00300,10 -e11 \00308,10 -e12 \00300,10}
 }
 if {$t2(custclr)!="1" && ($t2(greet)>"0" || $t2(voice)>"0" || $t2(autostart)>"0" || $t2(pubcmd)>"0")} { TDOMorClr }
 array unset tscl
}
TDoClr
proc TCntQes { {wat 0} } {  global t2 tclr botnick
 if {![file exists $t2(sfpath)]} { file mkdir $t2(sfpath) }
 if {![file exists $t2(qfpath)]} { file mkdir $t2(qfpath) }
 set dir [string trimright $t2(qfpath) /]
 set qfills [glob -directory $dir -nocomplain t2.qf.*]
 if {$qfills ne ""} {
  set tlast ""  ;  set tlist ""  ;  set filcnt 0  ;  set qestot 0
  foreach qesfil $qfills {  incr filcnt
   set temp [split [lindex [split $qesfil /] end] .]
   if {[llength $temp]=="3"} {  incr qestot 1000  ;  lappend tlist $qesfil
   } else {  set tmct [string trimleft [lindex $temp 2] 0]
     if {$tmct eq ""} {  set tmcnt 0  }
     incr qestot $tmct  ;  set tlast $qesfil
   }
  }
  set tlist [lsort $tlist]  ;  if {$tlast ne ""} { lappend tlist $tlast }
  set t2(-qtotal) $qestot ; set t2(-qfills) $tlist ; set t2(-qfcnt) $filcnt
 } else {  set t2(-qtotal) 0 ;  set t2(-qfills) "" ;  set t2(-qfcnt) 0  }
 if {[file exists $t2(sfpath)t2.qcount] && $wat=="0"} {
  set tqcntfil [open $t2(sfpath)t2.qcount r]
  set tnum [gets $tqcntfil] ;  close $tqcntfil
  if {[TStrDig $tnum] && $tnum < $t2(-qtotal)} {
   set t2(-qcount) $tnum
   if {$t2(-qfills) ne ""} {
    if {[string length $tnum]<"4"} { set t2(-qflnow) [lindex $t2(-qfills) 0]
    } else {
     set t2(-qflnow) [lindex $t2(-qfills) [string range $tnum 0 end-3]]
    }
   } else { file delete $t2(sfpath)t2.qcount }
  } else { file delete $t2(sfpath)t2.qcount }
 }
 if {![file exists $t2(sfpath)t2.qcount]} {
  set tqcntfil [open $t2(sfpath)t2.qcount w]
  puts $tqcntfil "0"  ;  close $tqcntfil
  set t2(-qcount) 0  ;  set t2(-qflnow) ""
  if {$t2(-qfills) ne ""} {  set t2(-qflnow) [lindex $t2(-qfills) 0]  }
 }
 set kfills [lsort [glob -directory $dir -nocomplain t2.kf.*]]
 if {[file exists $t2(sfpath)t2.kcount] && $wat=="0"} {
   if {$kfills eq ""} {  file delete $t2(sfpath)t2.kcount
   } else {  set tkcntfil [open $t2(sfpath)t2.kcount r]
     set tnum [gets $tkcntfil]  ;  close $tkcntfil
     if {[TStrDig $tnum]} {  set t2(-kcount) $tnum
     } else {  file delete $t2(sfpath)t2.kcount  }
   }
 }
 if {![file exists $t2(sfpath)t2.kcount] && $kfills ne ""} {  set t2(-kcount) 0
  set tkcntfil [open $t2(sfpath)t2.kcount w]  ;  puts $tkcntfil "0"  ;  close $tkcntfil
 }
 if {$kfills ne ""} {  set filcnt 0 ;  set qestot 0 ;  set flnow "" ;  set twas 0
  foreach kaosfl $kfills {  incr filcnt  ;  set temp [split [lindex [split $kaosfl /] end] .]
   if {[llength $temp]=="3"} {  incr qestot 1000  } else {  incr qestot [lindex $temp 3]  }
   if {$t2(-kcount)>=$twas && $t2(-kcount)<$qestot} {  set flnow $kaosfl  }
   set twas $qestot
  }
  set t2(-ktotal) $qestot  ;  set t2(-kfills) $kfills  ;  set t2(-kfcnt) $filcnt
  if {$flnow eq ""} { set t2(-kflnow) [lindex $kfills 0] ;  set t2(-kcount) 0
   set tkcntfil [open $t2(sfpath)t2.kcount w]  ;  puts $tkcntfil "0"  ;  close $tkcntfil
  } else {  set t2(-kflnow) $flnow  }
  if {$t2(-ktotal)<"25"} {  set t2(kaos) 0
    if {$t2(-setkaos)>"0"} {  putlog "KAOS Disabled: Requires at least 25 kaos questions to run."  }
  } else {  set t2(kaos) $t2(-setkaos)  }
 } else {  set t2(-ktotal) 0 ;  set t2(-kfills) "" ;  set t2(-kfcnt) 0 ;  set t2(kaos) 0  }
}
TCntQes
if {![file exists $t2(pwdpath)$t2(scrpath)t-2.html.tcl]} {
  if {[info exists t2(-html)]} {  unset t2(-html)  }
  if {[info exists t2(-hactv)]} {  unset t2(-hactv)  }
  if {[info exists t2(hdowat)]} {  unset t2(hdowat)  }
  if {[info exists t2(-hcnt)]} {  unset t2(-hcnt)  }
  if {[info exists t2(-hnew)]} {  unset t2(-hnew)  }
} else {  set t2(hdowat) read  ;  source $t2(pwdpath)$t2(scrpath)t-2.html.tcl  }
if {$t2(bakupu)>"0" || $t2(bakuph)>"0"} {
  proc TBakUp {wat chk} {  global t2 botnick  ;  set now [unixtime]
   if {$wat eq "u"} {  set msk *.users.*.bak
     if {![file exists $t2(sfpath)t2.users]} {  return 0  }
   } else {  set msk *.hist.*.bak
     if {![file exists $t2(sfpath)t2.hist]} {  return 0  }
   }
   if {$chk=="1"} {  set save 0
     set bls [lsort -decreasing [glob -directory $t2(sfpath) -tails -nocomplain $msk]]
     if {$bls ne ""} {  set da [strftime %j $now]
       set first [lindex [split [lindex $bls 0] .] 2]
       if {[strftime %j $first]!=$da} {  set save 1
         if {$t2(limit)>"0"} {  set t2(-lchek) 2  }
       } elseif {$wat eq "u" && $t2(bakhow)>"1"} {
         set hr [string trimleft [strftime %H $now] 0]  ;  if {$hr eq ""} { set hr 0 }
         set fhr [string trimleft [strftime %H $first] 0]  ;  if {$fhr eq ""} { set fhr 0 }
         if {$fhr<"12" && $hr>"11"} {  set save 1  }
       }
     } else {  set save 1  }
     if {$save=="0"} {  return 0  }
   }
   if {$wat eq "u"} {  set tmp users  } else {  set tmp hist  }
   file copy -force $t2(sfpath)t2.$tmp $t2(sfpath)t2.$tmp.$now.bak
   set bls [lsort -decreasing [glob -directory $t2(sfpath) -tails -nocomplain $msk]]
   if {[llength $bls]>$t2(bakup$wat)} {
     foreach x [lrange $bls $t2(bakup$wat) end] {  file delete $t2(sfpath)$x  }
   }
  }
  if {$t2(bakupu)>"0"} {  TBakUp u 1  }
  if {$t2(bakuph)>"0"} {  TBakUp h 1  }
}
proc TMidnite {mn hr da mo yr} {  global t2 botnick nick
 if {$t2(-ison)=="0"} {
   if {$hr=="00"} {  TSavHist 1  ;  TDoHInfo
     if {$t2(-stats)>"0"} {  TSetStat  }
     if {$t2(bakupu)>"0"} {  TBakUp u 0  }
     if {$t2(bakuph)>"0"} {  TBakUp h 0  }
   } else {
     if {[info exists t2(-html)] && $t2(-html) eq "d2"} {
         set t2(hdowat) active  ;  source $t2(pwdpath)$t2(scrpath)t-2.html.tcl  }
     if {$t2(bakupu)>"0" && $t2(bakhow)>"1"} {  TBakUp u 0  }
   }
 }
}
foreach ttmp(-x) [binds TMidnite] {
 foreach {ttmp(typ) ttmp(flg) ttmp(nam) ttmp(hit) ttmp(prc)} $ttmp(-x) {  break  }
 unbind $ttmp(typ) $ttmp(flg) $ttmp(nam) $ttmp(prc)
}
bind time - "00 00 * * *" TMidnite
if {[info exists t2(-html)] && $t2(-html) eq "d2"} {  bind time - "00 12 * * *" TMidnite
} elseif {$t2(bakupu)>"0" && $t2(bakhow)>"1"} {  bind time - "00 12 * * *" TMidnite  }
if {![string match *Bogus* ${ctcp-version}]} {
  set ctcp-version "${ctcp-version}  with BogusTrivia v$t2(ver) by SpiKe^^ (www.mytclscripts.com)"
}
array unset ttmp

putlog "$tclr(-msg)$t2(script)$tclr(-emsg) Loaded."
