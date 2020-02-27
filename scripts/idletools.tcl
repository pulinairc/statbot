##################################################
##                                              ##
##             I d l E   T o o l Z              ##
##                                              ##
####  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ####
##                                              ##
##     This script has a objective to take of   ##
##   op/voice to persons with superior idle     ##
##   value pre-defined. When the ppl lose the   ##
##   idle the script give it back the taken     ##
##   mode. This script it's configurated by     ##
##   console.                                   ##
##                                              ##
####  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ####
##                                              ##
##                  e-mail:      mafiaz@gmx.net ##
##                  irc: MafiaZ @ irc.ptnet.org ##
##################################################

##################################################
###################  Settings  ###################


# Sets auto/off (1/0) check idle
set itz_timer_on_off "1"

# Interval between verifications of idle, in minutes
set itz_between_checkz "5"

# Maximum idle that a op/voice can have, in minutes
set itz_max_idle "720"

# Channels to look idle; leave "ALL" to look for in all
set itz_check_channels "#pulina"

# It does not verify bots (1 not verify; 0 verify)
set itz_not_check_botz "1"

# List of nicks that they are not verified
set itz_exclude_nicks "Hupakko Kabri kummitus mustikkasoppa Q Reijo rolle Speadfreak |Halko| Halko"


################  End of Settings  ###############
##################################################

##################################################
########### Do NOT edit anything HERE! ###########

set itz_list_of_voicez {}
set itz_list_of_opz {}

proc itz_lista {hand idx args} {
	global itz_list_of_opz itz_list_of_voicez

	putcmdlog "#$hand# idlelist of IdleToolZ"
	putdcc $idx "Ops:"
	foreach n $itz_list_of_opz {
		set nk [lindex $n [expr 0]]		
		set ch [lindex $n [expr 1]]		
		putdcc $idx ">> $nk ($ch)"
	}
	putdcc $idx "Voices:"
	foreach n $itz_list_of_voicez {
		set nk [lindex $n [expr 0]]		
		set ch [lindex $n [expr 1]]		
		putdcc $idx ">> $nk ($ch)"
	}
}

proc itz_set_ii {hand idx args} {
	global itz_between_checkz
	set itz_between_checkz $args

	putcmdlog "#$hand# setinterval of IdleToolZ"
	putdcc $idx "Time between idle checks is set to: $args"
}

proc itz_set_is {hand idx args} {
	global itz_timer_on_off
	set itz_timer_on_off $args

	putcmdlog "#$hand# setidlestatus of IdleToolZ"
	if {$itz_timer_on_off == 1} {
		putdcc $idx "Check idle status: AUTO"

		itz_run_timer
	} else {
		putdcc $idx "Check idle status: OFF"
	}
}

proc itz_set_mi {hand idx args} {
	global itz_max_idle
	set itz_max_idle $args

	putcmdlog "#$hand# setmaxidle of IdleToolZ"
	putdcc $idx "Max idle is set to: $args"
}

proc itz_set_cc {hand idx args} {
	global itz_check_channels

	putcmdlog "#$hand# setidlechans of IdleToolZ"
	if {[string tolower $args] == "all"} {
		set res "ALL"
	} else {
		set res ""
		foreach ch $args {
			set res "$res $ch"
		}
	}
	set itz_check_channels $res

	putdcc $idx "Check channels is set to: $itz_check_channels"
}

proc itz_add_en {hand idx args} {
	global itz_exclude_nicks
	
	putcmdlog "#$hand# addexclnick of IdleToolZ"
	if {[llength $args] >= 0} {
		set tmp [join $args " "]
		set itz_exclude_nicks "$tmp $itz_exclude_nicks"
	}
	putdcc $idx "Exclude nicks is set to: $itz_exclude_nicks"
}

proc itz_rem_en {hand idx args} {
	global itz_exclude_nicks

	putcmdlog "#$hand# remexclnick of IdleToolZ"
	set res ""
	foreach item $itz_exclude_nicks {
		if {[lsearch [string tolower [join $args " "]] [string tolower $item]] < 0} {
			set res "$res$item "
		}
	}
	set itz_exclude_nicks $res
	putdcc $idx "Exclude nicks is set to: $itz_exclude_nicks"
}

proc itz_rem_all_en {hand idx args} {
	global itz_exclude_nicks

	putcmdlog "#$hand# remallexclnick of IdleToolZ"
	set itz_exclude_nicks ""
	putdcc $idx "Exclude nicks is set to: $itz_exclude_nicks"
}

proc itz_get_ii {hand idx args} {
	global itz_between_checkz

	putcmdlog "#$hand# getinterval of IdleToolZ"
	putdcc $idx "Time between idle checks is: $itz_between_checkz"
}

proc itz_get_mi {hand idx args} {
	global itz_max_idle

	putcmdlog "#$hand# getmaxidle of IdleToolZ"
	putdcc $idx "Max idle is: $itz_max_idle"
}

proc itz_get_cc {hand idx args} {
	global itz_check_channels

	putcmdlog "#$hand# getidlechans of IdleToolZ"
	putdcc $idx "Check channels is: $itz_check_channels"
}

proc itz_get_en {hand idx args} {
	global itz_exclude_nicks

	putcmdlog "#$hand# getexclnicks of IdleToolZ"
	putdcc $idx "Exclude nicks is: $itz_exclude_nicks"
}

proc itz_get_all {hand idx args} {
	global itz_between_checkz itz_max_idle itz_check_channels itz_exclude_nicks itz_timer_on_off

	putcmdlog "#$hand# getidleall of IdleToolZ"
	if {$itz_timer_on_off == 1} {
		putdcc $idx "Check idle status: AUTO"
	} else {
		putdcc $idx "Check idle status: OFF"
	}
	putdcc $idx "Time between idle checks: $itz_between_checkz"
	putdcc $idx "Max idle: $itz_max_idle"
	putdcc $idx "Check channels is: $itz_check_channels"
	putdcc $idx "Exclude nicks: $itz_exclude_nicks"
}

proc itz_run_timer {} {
	global itz_timer_on_off itz_between_checkz

	if {(![string match "*itz_whois_engine*" [timers]]) && ($itz_timer_on_off == 1)} {
		timer $itz_between_checkz itz_whois_engine
	}
}

proc itz_checkidle {hand idx args} {
	putcmdlog "#$hand# checkidle of IdleToolZ"
	itz_whois_engine
}

proc itz_idlehelp {hand idx args} {
	putcmdlog "#$hand# idlehelp of IdleToolZ"
	putdcc $idx "Help of Idle ToolZ:"
	putdcc $idx "checkidle - Checks for people width idle;"
	putdcc $idx "setidlestatus (owners only) - Set auto/off (0/1) check idle;"
	putdcc $idx "idlelist - List of the people who are in idle and had lost op/voice;"
	putdcc $idx "getidleall - List of all the configurations;"
	putdcc $idx "setinterval (owners only) - Sets interval between verifications of idle, in minutes;"
	putdcc $idx "setmaxidle (owners only) - Sets maximum idle that a op/voice can have, in minutes;"
	putdcc $idx "setidlechans (owners only) - Sets channels to look idle; leave \"ALL\" to look for in all;"
	putdcc $idx "addexclnick (owners only) - Adds nicks to the list of that they are not verified;"
	putdcc $idx "remexclnick (owners only) - Removes nicks of the list of that they are not verified;"
	putdcc $idx "remallexclnick (owners only) - Removes all nicks of the list of that they are not verified;"
	putdcc $idx "getinterval - Gets interval between verifications of idle;"
	putdcc $idx "getmaxidle - Gets maximum idle that a op/voice can have;"
	putdcc $idx "getidlechans - Gets channels to look idle;"
	putdcc $idx "getexclnicks - List of nicks that they are not verified;"
}

proc itz_check {nick int argumentz} {
	global itz_max_idle itz_check_channels itz_list_of_opz itz_list_of_voicez
	
	set nick [lindex $argumentz 1]
	set lnick [string tolower $nick]
	set itz_idle [lindex $argumentz 2]
	set itz_idle_in_minutes [expr $itz_idle / 60]

	if {$itz_check_channels == "ALL"} {
		set itz_chan_temp [channels]
	} else {
		set itz_chan_temp $itz_check_channels
	}

	foreach itz_chan $itz_chan_temp {
		set itz_mods ""
		set itz_nks ""

		if {[onchan $lnick $itz_chan]} {
			set tmp "$nick $itz_chan"

			if {$itz_idle_in_minutes > $itz_max_idle} {
				if {[isop $lnick $itz_chan]} {
					putlog "DEOP ($itz_chan): $nick - Idle: $itz_idle_in_minutes minutes"
					set itz_mods "$itz_mods-o"
					set itz_nks "$itz_nks $lnick"
					if {[lsearch $itz_list_of_opz $tmp] == -1} {
						lappend itz_list_of_opz $tmp
					}
				}
				if {[isvoice $lnick $itz_chan]} { 
					putlog "DEVOICE ($itz_chan): $nick - Idle: $itz_idle_in_minutes minutes"
					set itz_mods "$itz_mods-v"
					set itz_nks "$itz_nks $lnick"
					if {[lsearch $itz_list_of_voicez $tmp] == -1} {
						lappend itz_list_of_voicez $tmp
					}
				}
			} else {
				set pos [lsearch $itz_list_of_opz $tmp]
				if {$pos != -1} {
					if {$itz_idle_in_minutes < $itz_max_idle} {
						putlog "OP ($itz_chan): $nick - Idle: $itz_idle_in_minutes minutes"
						set itz_mods "$itz_mods+o"
						set itz_nks "$itz_nks $lnick"

						set itz_list_of_opzt {}
						foreach n $itz_list_of_opz {
							if {$n != $tmp} {
								lappend itz_list_of_opzt $n
							}
						}
						set itz_list_of_opz {}
						foreach n $itz_list_of_opzt {
							lappend itz_list_of_opz $n
						}
					}
				}

				set pos [lsearch $itz_list_of_voicez $tmp]
				if {$pos != -1} {
					if {$itz_idle_in_minutes < $itz_max_idle} {
						putlog "VOICE ($itz_chan): $nick - Idle: $itz_idle_in_minutes minutes"
						set itz_mods "$itz_mods+v"
						set itz_nks "$itz_nks $lnick"

						set itz_list_of_voicezt {}
						foreach n $itz_list_of_voicez {
							if {$n != $tmp} {
								lappend itz_list_of_voicezt $n
							}
						}
						set itz_list_of_voicez {}
						foreach n $itz_list_of_voicezt {
							lappend itz_list_of_voicez $n
						}
					}
				}
			}
			putserv "MODE $itz_chan $itz_mods $itz_nks"
		}
	}

}

proc itz_whois_engine {} {
	global itz_check_channels botnick itz_not_check_botz itz_list_of_opz itz_list_of_voicez itz_exclude_nicks
	
	if {$itz_check_channels == "ALL"} {
		set itz_chan_temp [channels]
	} else {
		set itz_chan_temp $itz_check_channels
	}
	set tmp_ch [join $itz_chan_temp " "]
	putlog "Checking for idle: $tmp_ch"

	foreach itz_chan $itz_chan_temp {
		foreach coisa [chanlist $itz_chan] { 
			if {[isop $coisa $itz_chan] || [isvoice $coisa $itz_chan]} {
				set pos [lsearch [string tolower $itz_exclude_nicks] [string tolower $coisa]]
				if {$itz_not_check_botz == 1} {
					if {(![matchattr [nick2hand $coisa $itz_chan] b]) && ($coisa != $botnick) && ($pos == -1)} {
						putserv "WHOIS $coisa $coisa"
					}
				}
				if {$itz_not_check_botz == 0} {
					if {$coisa != $botnick && ($pos == -1)} {
						putserv "WHOIS $coisa $coisa"
					}
				}
			} 
		} 
	}

	set itz_list_of_opzt {}
	foreach n $itz_list_of_opz {
		set nk [lindex $n 0]
		if {[onchan $nk [lindex $n 1]]} {
			putserv "WHOIS $nk $nk"
			lappend itz_list_of_opzt $n
		}
	}
	set itz_list_of_opz {}
	foreach n $itz_list_of_opzt {
		lappend itz_list_of_opz $n
	}

	set itz_list_of_voicezt {}
	foreach n $itz_list_of_voicez {
		set nk [lindex $n 0]
		if {[onchan $nk [lindex $n 1]]} {
			putserv "WHOIS $nk $nk"
			lappend itz_list_of_voicezt $n
		}
	}

	set itz_list_of_voicez {}
	foreach n $itz_list_of_voicezt {
		lappend itz_list_of_voicez $n
	}

	itz_run_timer
}

itz_run_timer

bind dcc -|- checkidle itz_checkidle

bind dcc n setinterval itz_set_ii
bind dcc n setmaxidle itz_set_mi
bind dcc n setidlechans itz_set_cc
bind dcc n addexclnick itz_add_en
bind dcc n remexclnick itz_rem_en
bind dcc n remallexclnick itz_rem_all_en
bind dcc n setidlestatus itz_set_is

bind dcc -|- idlelist itz_lista
bind dcc -|- getinterval itz_get_ii
bind dcc -|- getmaxidle itz_get_mi
bind dcc -|- getidlechans itz_get_cc
bind dcc -|- getexclnicks itz_get_en
bind dcc -|- getidleall itz_get_all

bind dcc -|- idlehelp itz_idlehelp

bind raw - 317 itz_check

putlog "Script loaded: \002idle tools\002"

################### END OF FILE ##################
##################################################
