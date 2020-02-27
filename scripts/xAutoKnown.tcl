# AutoKnown
#
# By:    Zsac
# Email: virus23@digitalops.com
# URL:	 http://clani69.digitalops.com/tcl/
#
# This script watches how long people idle. If they idle for a certain amount
# of time they are added to the bots user list with a custom flag you define.
# Also, if on gamesnet (or if you can successfully edit the commands below)
# the script will attempt to add the person to the channel's peon list.
# The script will also watch for how long people are gone. If they are absent
# for too long the script will remove them from the idler list on the eggy
# and try to remove them from the peon list in the room.
#
# commands .akadd <nick> <channel> (in dcc manually adds someone to your custom flags)
#
# inidb.tcl is required in the running of this script
#
################################################################
# channels to monitor
set ak_channels "#pulina"

# data file for keeping how long people idle ($drvl can be replaced with c:)
set ak_file 	"/home/rolle/eggdrop/scripts/xAutoKnown-dat.ini"

# log file for when action is taken to add or remove idlers ($drvl can be replaced with c:)
set ak_log 	"/home/rolle/eggdrop/scripts/xAutoKnown-log.txt"

# the amount of time between update intervals
set ak_inttime 	"1"

# minutes to idle for addition
set ak_addtime 	"10"

# days absent before removal
set ak_cltime	"1"

# flag to set new users to
set ak_flag 	"-v"

# flags of users not to monitor
set ak_bflag 	"+v"

# command to add peons? set to "" to turn off. command:
# this command will be executed when someone has idled for a certain amount of time and
# is added to the eggdrop user file.
#set ak_addpeoncmd "PRIVMSG ChanServ@Services.GamesNET.net :ADDUSER !CHAN! peon !NICK!"

set ak_addpeoncmd ""

# command to trim peons? set to "" to turn off. command:
# this command will be executed when someone has not idled for a certain amount of time and
# is removed from the eggdrop user file.
#set ak_rempeoncmd "PRIVMSG ChanServ@Services.GamesNET.net :TRIM !CHAN! peon $ak_cltime\d"

set ak_rempeoncmd ""

################################################################

bind dcc n|n akadd 	ak_manadd
bind dcc n|n akcheck 	ak_checknick
bind dcc n|n akclean	ak_clean_proxy

# update the idle times
bind time - "01 * * * *" 	ak_update
bind time - "31 * * * *" 	ak_update

# check for people w/o voice that are +v in the userfile
bind time - "11 * * * *" 	ak_check
# check for users who haven't been seen in long periods of time
bind time - "21 * * * *" 	ak_clean

proc ak_check { min hour day month year } {
	global ak_flag ak_channels ak_addpeoncmd botnick

	set nicklist 	[userlist]
	set time 	0

	for { set x 0 } { $x < [llength $ak_channels] } { incr x } {
		set chan [lindex $ak_channels $x]

		for { set y 0 } { $y < [llength $nicklist] } { incr y } {
			set nick [lindex $nicklist $y]
			if { [matchattr [nick2hand $nick $chan] $ak_flag|$ak_flag $chan] == 1 && [isvoice $nick $chan] == 0 && [isop $nick $chan] == 0 && $nick != $botnick } {
				set cmd [ak_stringsub $ak_addpeoncmd $chan $nick]
				putlog "AutoKnown: Error! Re-adding $nick on $chan to peon list."
				ak_writelog $nick $chan "Error Re-adding $nick on $chan to peon list"
				utimer $time "putserv \"$cmd\""
				set time [expr $time + 30]
				pushmode $chan +v $nick
			}
		}
	}
}

proc ak_checknick { hand idx text } {
	global ak_addtime ak_file

	if { [llength $text] < 2 } {
		putlog "AutoKnown: Invalid command."
		putlog "  .akcheck <nick> <channel>"
		return 0
	}

	set nick [string tolower [lindex $text 0]]
	set chan [string tolower [lindex $text 1]]

	if { [lsearch -all [channels] $chan] < 0 } {
		putlog "AutoKnown: Can't check $nick - invalid channel."
		return 0
	}

	putlog "[maskhost [getchanhost $nick]] $chan"

	if { [maskhost [getchanhost $nick]] != "" } {
		set time [lindex [ini_read $ak_file $chan [maskhost [getchanhost $nick]]] 0]
		if { $time != "\;" } {
			putlog "AutoKnown: $nick has idled in $chan for $time / $ak_addtime minutes."
		} else {
			putlog "AutoKnown: $nick is not found in my datafile."
		}
	} else {
		putlog "AutoKnown: Can't check $nick - not present in any channels I reside on."
	}
}

proc ak_manadd { hand idx text } {
	global ak_addtime ak_file

	if { [llength $text] < 2 } {
		putlog "AutoKnown: Invalid command."
		putlog "  .akadd <nick> <channel>"
		return 0
	}

	set nick [string tolower [lindex $text 0]]
	set chan [string tolower [lindex $text 1]]

	if { [lsearch -all [channels] $chan] < 0 } {
		putlog "AutoKnown: Can't add $nick - invalid channel."
		return 0
	}

	if { [getchanhost $nick] != "" } {
		putlog "AutoKnown: Adding $nick\([maskhost [getchanhost $nick]]\) on $chan to peon list..."
		set nickmask [maskhost [getchanhost $nick]]
		ini_write $ak_file $chan $nickmask "[expr $ak_addtime + 1] [unixtime]"

		ak_update 0 0 0 0 0
	} else {
		putlog "AutoKnown: Can't add $nick - not present in any channels I reside on."
	}
}

proc ak_writelog { nick chan wtype } {
	global ak_log

	if {![file exists $ak_log] || [file size $ak_log] == 0} {
		set filew [open $ak_log w]
		close $filew
	}

	set type "RDWR APPEND"

	set time [ctime [unixtime]]

	set fileo [open $ak_log $type]
	puts $fileo "$time\: $wtype, $nick on $chan."
	close $fileo
}

proc ak_checkchan { chan } {
	global ak_channels

	# found
	if { [lsearch -all $ak_channels $chan] < 0 } {
		return 0 
	} else {
		return 1
	}
}

# formats strings for commands
proc ak_stringsub { string chan nick } {
	regsub -all -- {\\*[]]} $nick "\\\]"	nick
	regsub -all -- {\\*[[]} $nick "\\\["	nick

	set string2 $string

	regsub -all !NICK!  $string2 $nick string2
	regsub -all !CHAN!  $string2 $chan string2

	return $string2
}


proc ak_update { min hour day month year } {
	global ak_channels ak_file ak_addtime ak_addpeoncmd ak_flag ak_bflag ak_inttime botnick

	set stopflags 	"fo$ak_flag$ak_bflag"

	for { set x 0 } { $x < [llength [channels]] } { incr x } {
		set chan [lindex [channels] $x]
		if { [ak_checkchan $chan] == 1 } {
			set nicklist [chanlist $chan]
			for { set y 0 } { $y < [llength $nicklist] } { incr y } {
				set nick 	[lindex $nicklist $y]
				set nickmask 	[maskhost [getchanhost $nick]]

				if { [ini_read $ak_file $chan $nickmask] == "\;" && [matchattr [nick2hand $nick $chan] $stopflags|$stopflags $chan] == 0 && $nick != $botnick } {
					ini_write $ak_file $chan $nickmask "0 [unixtime]"
					putlog "AutoKnown: Adding $nick \[$nickmask\] to ini."
					ak_writelog $nick $chan "Add Ini \($nickmask\)"
				} elseif { [ini_read $ak_file $chan $nickmask] != "\;" && [matchattr [nick2hand $nick $chan] $stopflags|$stopflags $chan] == 0 && $nick != $botnick } {
					set nicktime [lindex [ini_read $ak_file $chan $nickmask] 0]
					if { $nicktime == "\;" } { set nicktime 0 }
					set nicktime [expr $nicktime + $ak_inttime]
					ini_write $ak_file $chan $nickmask "$nicktime [unixtime]"
					if { $nicktime > $ak_addtime && [matchattr [nick2hand $nick $chan] $ak_flag|$ak_flag $chan] == 0 && [nick2hand $nick] == "*" } {
						if { [adduser $nick $nickmask] == 1 } {
							putlog "AutoKnown: Added $nick \[$nickmask\] to Eggy |+$ak_flag list with [expr ($nicktime / 60) / 24] days logged."
							ak_writelog $nick $chan "Add |+$ak_flag Eggy \([expr ($nicktime / 60) / 24] days logged\)"	
							chattr [nick2hand $nick] |+$ak_flag $chan
							ini_remove $ak_file $chan $nickmask
							if { $ak_addpeoncmd != "" } {
								set cmd [ak_stringsub $ak_addpeoncmd $chan $nick]
								putserv "$cmd"
								pushmode $chan +v $nick
								putlog "AutoKnown: Added $nick \[$nickmask\] to Chanserv Peon list with [expr ($nicktime / 60) / 24] days logged."
								putlog "   $cmd"
								ak_writelog $nick $chan "Add Peon Chanserv \([expr ($nicktime / 60) / 24] days logged\)"
							}
						}

					}
				}
			}
		}
	}
}

proc ak_clean_proxy { hand idx args } {
	ak_clean 0 0 0 0 0
}

proc ak_clean { min hour day month year } {
	global ak_channels ak_addtime ak_cltime ak_file ak_rempeoncmd ak_flag

	set nicklist 	[userlist]
	set found 	0
	set succrem 	0

	# find old entries in the eggdrop user file and remove them
	for { set x 0 } { $x < [llength $ak_channels] } { incr x } {
		set chan [lindex $ak_channels $x]
		for { set y 0 } { $y < [llength $nicklist] } { incr y } {
			set nick 	[lindex $nicklist $y]
			set hosts 	[getuser $nick HOSTS]
			set info 	[lindex [getuser $nick LASTON $chan] 0]
			if { $info != "" && $info != 0 && [matchattr $nick $ak_flag|$ak_flag $chan] == 1 } {
				set info [expr ([unixtime] - $info) / 86400]
				# who's ganna use this script in 10000 days? you? me? nah...
				if { $info >= $ak_cltime && $info < 10000 } {
					set succrem [deluser $nick]
					if { $succrem == 1 } {
						putlog "AutoKnown: Removed $nick from Eggy |+$ak_flag list."
						putlog "  $nick : $hosts : $info"
						ak_writelog $nick $chan "Remove |+$ak_flag Eggy \($info days gone\)"
						ini_remove $ak_file $chan $hosts
						if { $ak_rempeoncmd != "" } {
							incr found
						}
					} else {
						putlog "AutoKnown: Error in removing $nick from Eggy |+$ak_flag list."
						ak_writelog $nick $chan "Error Remove |+$ak_flag Eggy \($info days gone\)"
					}
					set succrem 0
				}
			} 
		}
	}

	# find old entries in the ini file and mark them for removal
	set remlist	""
	set sect	""
	set time 	""
	set key		""
	set fileo 	[open $ak_file r]

	while { ![eof $fileo] } {
		set rline [gets $fileo]
		set rline [string trim $rline]

		if { $rline != "" && [string index $rline 0] != "\;" } {
			if { [string index $rline 0] == "\[" && [string index $rline [expr [string length $rline] - 1]] == "\]" } {
				set sect [string range $rline 1 [expr [string length $rline] - 2]]
			} else {
				set key 	[string tolower [string range $rline 0 [expr [string first = $rline] - 1]]]
				set val 	[lindex [string range $rline [expr [string first = $rline] + 1] end] 1]
				set time	[expr [unixtime] - $val]
			}

			# number of seconds since last seen
			if { $time > [expr ($ak_addtime * 60) * 2] && [string trim $time] != "" } {
				append remlist "\{$sect $key  $val\} "
			}
		}
	}

	close $fileo

	# clean the ini file
	for { set x 0 } { $x < [llength $remlist] } { incr x } {
		set sect	[lindex [lindex $remlist $x] 0]
		set key		[lindex [lindex $remlist $x] 1]
		set val		[lindex [lindex $remlist $x] 2]
		set time	[expr [unixtime] - $val]
		ini_remove $ak_file $sect $key
		ak_writelog "$key" "ini" "Remove $chan,$key\=$val from ini file \([expr (($time / 60) / 60) / 24] days gone\)"
	}	
	
	# clean the chanserv user file
	if { $found > 0 && $ak_rempeoncmd != "" } {
		set cmd [ak_stringsub $ak_rempeoncmd $chan $nick]
		putserv "$cmd"
		putlog "AutoKnown: Trimming Chanserv Peon list at $ak_cltime days for $found users absent."
		putlog "   $cmd"
		ak_writelog "none" $chan "Remove Peon Chanserv \($found users gone\)"
	}	
}

putlog "Script loaded: \002AutoKnown by Zsac v1.0.3\002"

# minor fix in ak_clean ini cleaning. logging cleaned as well
# fixed bracket troubles in ak_check
# ak_reset ditched. ini entries now have a timestamp. ak_clean reads the timestamp and removes old entries
# ak_reset is now dependent on the size of the file.
# updated updating... updates twice an hour rather than 4.
# i've used this script long enough. its not beta
# fixed bracket troubles
# fixed checkadd error w/ maskhost
# fixed pushmodes
# added a function to check people who are on the +F list but don't have voice in the channel. it tries to readd them to the chanserv peon list
# added a function that allows one to manually add someone to the +F list through this script
# funky removal of someone who shouldn't have been removed. added safegaurd to try to prevent it from happening again. i guess
# 	this is still beta :^/
# remove function verfied to work
# ability to not add certain flagged users added
# reset function added
# almost not beta
# appears to add users properly
# new flag for users added. script removes old entries for faster operation time
# autovoice added - support for services
# clean user function appears to work
# fixed readding users
# got rid of gethost for getchanhost. no more bracket troubles.
# initial untested release
