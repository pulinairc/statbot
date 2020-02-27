# autovoice.tcl - Copyright (c) TEST 1998. All Rights Reserved.
#######################################################################
#		 ______   _____   _____   __  __   __   _____ 		    #
#		|_    _| /     \ /     \ |  \|  | |  | |  ___|		    #
#		  |  |   |  |  | |  |  | |      | |  | |  ___|		    #
#		  |__|   \_____/ \_____/ |__|\__| |__| |_____|		    #
#		  .-=[PC/UCF/DNG/PGC/TRPS/TEST/TSF/MEX/C4N]=-.		    #
#######################################################################


##### DESCRIPTION #####################################################
# This little script will auto +v ppl with the voice flag on the bot.
# The !addvoice is also included to add ppl to the bot with +1 flag.
#######################################################################


##### CONTACT INFO ####################################################
# If you any comments or bug reports, you can either contact me via
# e-mail at t00nie@hotmail.com or on irc #test98 on EFnet.
#######################################################################


#-----------------------------------------------------------------------

##### BINDINGZ #####
bind pub m !addvoice pub:addvoice
bind join 1 *!*@*    pub:onjoin


##### SETTINGZ #####
set tnini "«\002tN!(TST/TSF)\002»"

#######################################################################
#         __  __   _____   ______   __   __   __   __  __   _____     #
#        |  \|  | /     \ |_    _| |  |_|  | |  | |  \|  | /  ___\    #
#        |      | |  |  |   |  |   |   _   | |  | |      | |  \_ \    #
#        |__|\__| \_____/   |__|   |__| |__| |__| |__|\__| \_____/    #
#           ______   _____      _____   ____    __   ______           #
#          |_    _| /     \    |  ___| |    \  |  | |_    _|          #
#            |  |   |  |  |    |  ___| |  |  | |  |   |  |            #
#            |__|   \_____/    |_____| |____/  |__|   |__|            #
#             _____   _____   __      _____   __    __                #
#            |  __ \ |  ___| |  |    /     \ |  |/\|  |               #
#            |  __ < |  ___| |  |__  |  |  | |        |               #
#            |_____/ |_____| |_____| \_____/  \__/\__/                #
#                                                                     #
#######################################################################


##### PROCEDUREZ #####
proc pub:onjoin {nick uhost hand chan} {
  if {[matchattr $hand 1]} {putserv "MODE $chan +v $nick"}
  return 1
}

proc pub:addvoice {nick uhost hand chan arg} {
  global botnick tnini
  if {![matchattr $hand m]} {
    putserv "NOTICE $nick :You don't have access to add VOICE's. $tnini"
    return 0
  }
  set who [lindex $arg 0]
  set userhost [maskhost [getchanhost $who $chan]]
  if {$who == ""} {
    putserv "NOTICE $nick :\002U\002sage\037:\037 !addvoice <nick> $tnini"
    return 0
  }
  if {![onchan $who $chan]} {
    putserv "NOTICE $nick :\002$who\002 isn't on the channel. $tnini"
    return 0
  }
  if {[validuser $who]} {
    putserv "NOTICE $nick :\002$who\002 is already on my userlist. $tnini"
    putserv "NOTICE $nick :Flags of \002$who\002 are: +\002[chattr $who]\002"
    return 0
  }
  if {![adduser $who $userhost]} {
    putserv "NOTICE $nick :Couldn't add \"$who\" to the bot. $tnini"
    return 0
  }
  set flags "+p1-x"
  adduser $who $userhost
  if {[chattr $who $flags] == "*"} {
    putserv "NOTICE $nick :\002$arg\002 isn't known to me. $tnini"
    return 0
  }
  putserv "MODE $chan +v $who"
  putserv "NOTICE $who :You have been added with autovoice. $tnini"
  putserv "NOTICE $who :To set a pass, type '/msg $botnick PASS <password>'"
  putserv "NOTICE $who :For a list of commands, type '/msg $botnick HELP'"
  putserv "NOTICE $who :For invites, type /msg $botnick invite <pass> \[<#channel>\]"
  putserv "NOTICE $who :Enjoy!"
  putserv "NOTICE $nick :\002$who\002 has been added with autovoice."
  save
  return 1
}

putlog "Script loaded: \002AutoVoice v1.0 TCL (c) TEST 1998\002 by \002t00nie\002"
