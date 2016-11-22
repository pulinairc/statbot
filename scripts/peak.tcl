##################################
### ChanPeak.tcl               ###
### Version 1.3                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

###############################################################################
## This script keeps a record of the peak amount of users in a channel. The  ##
## channel peak can be viewed from dcc chat or via pub command. It can also  ##
## optionally announce to the channel or broadcast a partyline notice when a ##
## channel's peak record is broken.                                          ##
###############################################################################

##############
## COMMANDS ##
#############################################################
## DCC ## .chanset <channel> +/-peak                       ##
######### Enables or disables peak-trackingfor a channel.  ##
######### ------------------------------------------------ ##
######### .peak <channel> (Can be changed)                 ##
######### Shows the peak for a channel.                    ##
#############################################################
## PUB ## !peak [channel] (Can be changed)                 ##
######### Shows the peak for the specified channel. If no  ##
######### channel is specified, the current channel's peak ##
######### will be displayed.                               ##
#############################################################

##########################################################
## Just load the script, edit the settings, and rehash. ##
##########################################################

###########################################################
# Set the flag required to use the pub peak command here. #
###########################################################

set chanpeak_setting(pflag) "-|-"

###########################################################
# Set the flag required to use the dcc peak command here. #
###########################################################

set chanpeak_setting(dflag) "-|-"

##################################
# Set the pub peak command here. #
##################################

set chanpeak_setting(cmd_pub) "!peak"

##################################
# Set the dcc peak command here. #
##################################

set chanpeak_setting(cmd_dcc) "peak"

###################################
# Enable use of bold in DCC chat? #
###################################

set chanpeak_setting(bold) 1

############################################
# Prefix "CHANPEAK:" in DCC chat messages? #
############################################

set chanpeak_setting(CHANPEAK:) 1

######################################
# Announce new peaks to the channel? #
######################################

set chanpeak_setting(announce) 0

#########################################
# Broadcast new peaks to the partyline? #
#########################################

set chanpeak_setting(cast) 1

###################################
# Set the database filename here. #
###################################

set chanpeak_setting(db) "/var/www/html/peak.db"

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002CHANPEAK:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002CHANPEAK:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

setudef flag peak
bind join - * chanpeak_join
bind dcc $chanpeak_setting(dflag) $chanpeak_setting(cmd_dcc) chanpeak_dcc
bind pub $chanpeak_setting(pflag) $chanpeak_setting(cmd_pub) chanpeak_pub

proc chanpeak_readarray {array file} {
   upvar $array ours
   if {[catch {open $file r} fd]} { return }
   if {[array exists ours]} { unset ours }
   foreach line [split [read $fd] \n] {
      if {[string range $line 0 2] != "%!%" || [scan [string range $line 3 end] {%[^!]!!!%s} name data] != 2} { continue }
      if {![info exists data]} { set data "" }
      set ours($name) $data
   }
   close $fd
}
proc chanpeak_savearray {array file} {
   upvar $array ours
   if {![array exists ours] || [catch {open $file w} fd]} { return }
   foreach entry [array names ours] { puts $fd "%!%$entry!!!$ours($entry)" }
   close $fd
}
if {[file exists $chanpeak_setting(db)]} { chanpeak_readarray chanpeak_peak $chanpeak_setting(db) }
proc chanpeak_dopre {} {
   if {!$::chanpeak_setting(CHANPEAK:)} { return "" }
   if {!$::chanpeak_setting(bold)} { return "CHANPEAK: " }
   return "\002Kävijäennätys:\002 "
}
proc chanpeak_dcc {hand idx text} {
   if {$text == ""} { putdcc $idx "[chanpeak_dopre]Usage: .$::chanpeak_setting(cmd_dcc) <channel>" ; return }
   if {![info exists ::chanpeak_peak([string tolower [set chan [lindex [split $text] 0]]])]} { putdcc $idx "[chanpeak_dopre]Kävijäennätystä ei löydy kanavalle $chan." ; return }
   set list [split $::chanpeak_peak([string tolower $chan]) @]
   putdcc $idx "[chanpeak_dopre]Käyttäjäennätys kanavalle $chan on [lindex $list 0] käyttäjää. Ennätys saavutettiin [lindex $list 1] [lindex $list 2] [lindex $list 3]."
}
proc chanpeak_pub {nick uhost hand chan text} {
   if {[set chan2 [lindex [split $text] 0]] == ""} { set chan2 $chan }
   if {![info exists ::chanpeak_peak([string tolower $chan2])]} { puthelp "PRIVMSG $chan :Kävijäennätystä kanavalle $chan2 ei ole olemassa." ; return }
   set list [split $::chanpeak_peak([string tolower $chan2]) @]
   puthelp "PRIVMSG $chan :Käyttäjäennätys kanavalle $chan2 on [lindex $list 0] käyttäjää. Ennätys saavutettiin [lindex $list 1] [lindex $list 2] [lindex $list 3]."
}
proc chanpeak_join {nick uhost hand chan} {
   global chanpeak_peak
   if {[lsearch -exact [channel info $chan] +peak] == -1} { return }
   if {[info exists chanpeak_peak([string tolower $chan])]} {
      set peak $chanpeak_peak([string tolower $chan])
   } {
      set peak "0@[clock format [clock seconds] -format %D]@[clock format [clock seconds] -format "%I:%M"]@[clock format [clock seconds] -format "%p"]"
   }
   set peak [split $peak @]
   if {[lindex $peak 0] >= [set users [llength [chanlist $chan]]]} { return }
   if {$::chanpeak_setting(announce)} { puthelp "PRIVMSG $chan :Uusi $chan käyttäjäennätys! $users users. Edellinen oli [lindex $peak 1] [lindex $peak 2] [lindex $peak 3]." }
   if {$::chanpeak_setting(cast)} { dccbroadcast "Uusi $chan-käyttäjäennätys! $users users. Edellinen: [lindex $peak 1] [lindex $peak 2] [lindex $peak 3]." }
   set ::chanpeak_peak([string tolower $chan]) "$users@[clock format [clock seconds] -format %D]@[clock format [clock seconds] -format {%I:%M}]@[clock format [clock seconds] -format %p]"
   chanpeak_savearray chanpeak_peak $::chanpeak_setting(db)
}
putlog "\002CHANPEAK:\002 ChanPeak.tcl Version 1.3 by Wcc is loaded."
