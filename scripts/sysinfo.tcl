# sysinfo.tcl v1.13 [14 December 2009] 
#
# Latest version can be found from http://www.bluedevil.ca/eggdrop/
# 
# If you have any suggestions, questions or you want to report 
# bugs, please feel free to send me an email to burn@bluedevil.ca
#
# This script shows the system information of the bot's machine.
# How much or how little of what the script shows can be changed by 
# editing the sysinfo281.06.pl perl script included within.
# If your IRC network limits the character output and you're getting
# an incomplete output, remove some of the output options in the included
# perl file under:
# "These are the default settings for which information gets displayed."
#
# Thanks to David Rudie who's perl script does 99% of the work.
# Thanks also to imbezol for some modifications to the perl script and some help with tcl.
# The perl and bash scripts must both be chmodded executable for it to work, if they aren't 
# already.
#
# Current MSG Commands:
#    !sysinfo [option]
#
# Current Channel Commands:
#    !sysinfo [option]
#
# Currently the only option is -p which will send sysinfo in a private message
#
# Tested on eggdrop 1.6.13+ with TCL 8.3.4+
#
# Version history:
# v1.00 - The very first version!
# v1.01 - Added little cosmetic things.
# v1.03 - Changed sysinfo perl script to better support *BSD
# v1.04 - Added colour support to perl script
# v1.05 - Fixed the broken colour support
# v1.06 - Removed colour support, too many complaints that it was ugly
#	  Cleaned up some of the code, it was ugly.
# v1.07	- More cleanup, newer verion of sysinfo perl script
#	  should be more compatible with different OSes
# v1.08 - Linux Distro output added to perl script by imbezol
# v1.09 - More minor changes, nothing to write home about ;)
# v1.10 - sysinfo.pl update
# v1.11 - sysinfo.pl updated to sysinfo281.06.pl, put colours back in, included eof to decreease cases of channel spam.
# v1.12 - version by >-]~SkG~[-->
# v1.13 - updated to use sysinfo281.16.pl


# Settings ###

# [0/1] Enable Channel Command? (can the sysinfo be displayed in a channel?)
set sys_enablepublic 1

# [0/1] Enable MSG Command? (can the sysinfo be private messaged?)
set sys_enablemsg 1

# What command prefix do you want to use for channel commands? (example is !sysinfo)
set sys_cmdpfix "!"

# What users can use the sysinfo command? (use this! this script can get your bot flooded
# off of the network, add the S flag to users who can use the command)
set sys_flag "S"

# On what channels do you want to show the sysinfo?
# Note: Set this to "" to make the sysinfo command available on all channels.
set sys_chans "#pulina"

###### You don't need to edit below this ######

# Misc Things

set sys_ver "1.13"
set sys_method "PRIVMSG"

# Bindings

# Channel Command
if {$sys_enablepublic} {
	bind pub - ${sys_cmdpfix}sysinfo pub:sys_sysinfo
}

# MSG Command
if {$sys_enablemsg} {
	bind msg - sysinfo msg:sys_sysinfo
}

# Channel Command

proc pub:sys_sysinfo {nick uhost hand chan arg} {
global sys_cmdpfix sys_flag sys_method sys_ver
set option [string tolower [lindex [split $arg] 0]]
	if {[matchattr $hand $sys_flag]} {
		if {($option != "") && ($option != "-p")} {
#			putserv "PRIVMSG $nick :sysinfo.tcl v$sys_ver commands:"
			putserv "PRIVMSG $nick :   ${sys_cmdpfix}sysinfo        - Näyttää sysinfon kanavalla $chan."
			putserv "PRIVMSG $nick :   ${sys_cmdpfix}sysinfo -p     - Näyttää sysinfon sinulle."
		} else {
			if {$option == ""} {
				putserv "$sys_method $chan :[sys_dosysinfo]"
			} elseif {$option == "-p"} {
				putserv "$sys_method $nick :[sys_dosysinfo]"
			}
		}
	} elseif {[matchattr $hand $sys_flag]} {
		putserv "$sys_method $nick :[sys_dosysinfo]"
	}
return 1
}

# MSG Command

proc msg:sys_sysinfo {nick uhost hand arg} {
global sys_cmdpfix sys_flag sys_method sys_ver
set option [string tolower [lindex [split $arg] 0]]
	if {[matchattr $hand $sys_flag]} {
		if {($option != "")} {
#			putserv "PRIVMSG $nick :sysinfo.tcl v$sys_ver commands:"
			putserv "PRIVMSG $nick :   sysinfo        - Näyttää sysinfon sinulle."
		} else {
			if {$option == ""} {
				putserv "$sys_method $nick :[sys_dosysinfo]"
			}
		}
	} elseif {[matchattr $hand $sys_flag]} {
		putserv "$sys_method $nick :[sys_dosysinfo]"
	}
return 1
}

# Other Procs

proc sys_dosysinfo { } {
	if {[catch {exec scripts/sysinfo.sh} sysinfo]} { set sysinfo "Perl script is not executable or doesn't exist." }
	return "$sysinfo"
}

# End

putlog "Script loaded: \002sysinfo.tcl v$sys_ver by burn <burn@bluedevil.ca>\002" 
