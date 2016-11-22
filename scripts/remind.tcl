################################################
#################### ABOUT #####################
################################################
#
# Reminder-0.2 by Fredrik Bostrom
# for Eggdrop IRC bot
#
# Usage:
# !remind nick time message
#   - creates a new reminder for nick in the 
#     current channel at time with message
#   - time is a format parseable by the tcl 
#     command 'clock scan'. If the time consists
#     of several words, it has to be enclosed
#     in "".
#   - examples: 
#     !remind morbaq "tomorrow 10:00" Call Peter 
#     !remind morbaq "2009-12-31 23:59" Happy new year!
#
# !reminders 
#   - lists all active reminders
#
# !cancelReminder id
#   - cancels the reminder with id
#   - the id is the number preceeding the 
#     reminder in the list produced by 
#     !reminders
#   - note: the id may change as new reminders 
#     are added or old reminders removed. Always
#     check the id just before cancelling
#
#
################################################
################ CONFIGURATION #################
################################################

set datafile "/home/rolle/eggdrop/scripts/reminders.dat"

################################################
######## DON'T EDIT BEOYND THIS LINE! ##########
################################################

bind pub - "!muistuta" pub:newReminder
bind pub - "!muistutukset" pub:getReminders
bind pub - "!peruuta" pub:cancelReminder
bind pub n "\$inspectReminders" pub:inspectReminders

array set reminders {}

# save to file
proc saveReminders {} {
    global reminders
    global datafile

    set file [open $datafile w+]
    puts $file [array get reminders] 
    close $file
}

# the run-at-time procedure
proc at {time args} {
    if {[llength $args]==1} {
	set args [lindex $args 0]
    }
    set dt [expr {($time - [clock seconds])*1000}]
    return [after $dt $args]
}

proc printReminder {reminderId {fire "false"}} {
    global reminders

    # get the reminder
    set reminder $reminders($reminderId)

    set when [clock format [lindex $reminder 0] -format "%Y-%m-%d %H:%M"]
    set chan [lindex $reminder 1]
    set who [lindex $reminder 2]
    set timer [lindex $reminder 3]
    set what [lindex $reminder 4]

    if {$fire} {
	putserv "PRIVMSG $chan :$who: $what!!!!!!!!!!!!!!!!!!!!!!! (TÄMÄ ON MUISTUTUS)"
    } else {
	putserv "PRIVMSG $chan :ID: $reminderId, KENELLE: $who, AIKA: $when, SYY: $what"
    }
}

proc fireReminder {reminderId} {
    global reminders

    printReminder $reminderId "true"
    unset reminders($reminderId)
    saveReminders
}

proc pub:newReminder {nick host handle chan text} {
    global reminders

    # parse parameters
    set id [clock seconds]
    set who [lindex $text 0]
    set when [lindex $text 1]
    set time [clock scan $when]
    set what [lrange $text 2 end]

    # create new entry
    set new [list $time $chan $who null $what]

    # activate the event
    set timer [at $time fireReminder $id]

    # putlog "new timer: $timer"

    # set the timer associated with this reminder
    set new [lreplace $new 3 3 $timer]
    # putlog "new reminder: $new"

    set reminders($id) $new
    saveReminders

    putserv "PRIVMSG $chan :$who: SINULLE ON LISÄTTY MUISTUTUS. AIKA: $when, AIHE: \"$what\""
}

proc pub:getReminders {nick host handle chan text} {
    global reminders
    set chanReminders {}
    
    # count all reminders for this channel
    foreach {key value} [array get reminders] {
	if {[lindex $value 1] == $chan} {
	    lappend chanReminders $key
	}
    }

    # count the reminders
    set howMany [llength $chanReminders]

    # do we have reminders?
    if {$howMany < 1} {
	putserv "PRIVMSG $chan :Ei aktiivisia muistutuksia."
	return
    }

    # print reminders for this channel
    putserv "PRIVMSG $chan :$howMany aktiivista muistutusta:"
    foreach key $chanReminders {
	printReminder $key
    }
}

proc pub:cancelReminder {nick host handle chan text} {
    global reminders

    set reminder $reminders($text)
    set timer [lindex $reminder 3]

    # putlog "Cancelling timer: $timer"
    after cancel $timer
    unset reminders($text)
    putserv "PRIVMSG $chan :Muistutus poistettu: $text"

    saveReminders
}

proc pub:inspectReminders {nick host handle chan text} {
    global reminders

    set timerString [after info]
    set reminderString [array get reminders]

    putserv "NOTICE $nick :Reminders: $reminderString"
    putserv "NOTICE $nick :Timers: $timerString"
}

proc initReminders {} {
    global reminders
    
    set reminderString [array get reminders]
    # putlog "Initiating reminders: $reminderString"

    # get current time
    set time [clock seconds]

    # get active timers
    set activeTimers [after info]

    # check for expired reminders and fire them
    foreach {key value} [array get reminders] {
	if {[lindex $value 0] < $time} {
	    fireReminder $key
	} elseif {[lsearch $activeTimers [lindex $value 3]] == -1} {
	    # if the reminder hasn't expired, check if the timer is already set
	    set timerId [at [lindex $value 0] fireReminder $key]
	    set reminders($key) [lreplace $value 3 3 $timerId]
	}
    }
    saveReminders
}


# read the old if they exist
set file [open $datafile]
set content [read $file]
close $file

if {$content == ""} {
    set content {}
}

array set reminders $content

initReminders


###################################
putlog "Script loaded: \002Reminder script\002"
###################################
