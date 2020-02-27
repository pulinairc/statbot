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

BogusTrivia Users Wanted:)

BogusTrivia is a full featured trivia script for Eggdrop & Windrop.
Originally designed to mimic the popular mIRC trivia, it makes a 
smooth transition for channel owners wanting to eliminate a
second mIRC client.

You will no longer find the BogusTrivia html generator included
with any release of BogusTrivia.  It is available for download
as an add-on script to enhance BogusTrivia 2.06.3+ for those
users wanting html player stat pages.  The new version of the
html webpage generator is called BogusHTML 2.06.4 and can be
downloaded from my web site at:  http://www.mytclscripts.com


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

I've included new ReadMe files to make it easier to find the exact
information you need to install & get the most out of BogusTrivia.
As Always your comments, suggestions & bug reports are essential
to bring you the best trivia script possible.

Whether you're an existing user or new to BogusTrivia, I recommend
you read over all the included ReadMe files.

Thanks go out to all the Channel Owners and Players that beta tested
and continue to use BogusTrivia.


-------------------------------------------------------------------
BogusTrivia Script Upgrade Notes:

  While upgrading from an older version of BogusTrivia should be a
  smooth process, the new t-2.settings.tcl Must be edited.

  It is recommended you backup your existing bot prior to upgrading.


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


-------------------------------------------------------------------
BogusTrivia Script Translation Notes:

  Translate Day & Month Names:
  Users wishing to use their own language for channel output may
  edit the t-2.tcl file to change the Day & Month Names.
  On or about line 1077 of the t-2.tcl begins...

   ##################################################
   #########  Translate Day & Month Names  ##########
   ###                                            ###
   ###   Remove the # from the lines below and    ###
   ###    edit each name in the list.             ###
   ###                                            ###
   ## -> To use the defaults, don't edit these! <- ##
   ##################################################

  ...followed by the scripts output defaults. Using the
  instructions above, change as necessary. 

-------------------------------------------------------------------
Important Notes Regarding the RESTART GAME PLAY ON REJOIN Feature:

  This feature allows BogusTrivia to resume game play when returning
  to your channel after a bad bot shut down (usually by a cron job).

  It is recommeded you enable this feature ONLY if you have enabled
  the option to back up your user and history files.

  Having this feature enabled has been indicated in two reported
  cases of sudden unexplained loss of user file and/or history file.


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

