
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
#  t-2.html.tcl  Must be in the /scripts directory to run!        #
#  Does Not Require a source line in your eggdrop conf file!      #
#                                                                 #
###################################################################


###################################################################
##                  Bogustrivia HTML Features                    ##
###################################################################
#                                                                 #
# 1.  Bot Generated HTML Stats w/ On|Off Option                   #
# 2.  Single Stat Pages or An Entire Site                         #
# 3.  Active, History & Extended History Options                  #
# 4.  Custom Naming of Stat Pages                                 #
# 5.  Track And Display Any Number of Events                      #
# 6.  Custom Templates & CSS with Included Themes                 #
#                                                                 #
###################################################################


###################################################################
##                   BogusHTML Version History                   ##
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

