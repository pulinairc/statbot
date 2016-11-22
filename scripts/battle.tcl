################################################
#################### ABOUT #####################
################################################
#
# Battle-1.0 by Fredrik Bostrom
# for Eggdrop IRC bot
#
# Usage:
# !{vote,battle} opt1,opt2,...,optn
#   - calculates which one of the options are
#     most likely to win, and displays the 
#     result. 
#   - note: if something battles against 
#     chuck norris, it will always lose
#
################################################
######### DON'T EDIT BEYOND THIS LINE ##########
################################################

bind pub - "!battle" pub:choose
bind pub - "!vote" pub:choose

proc pub:choose {nick host handle chan text} {
    if {[string trim $text] eq ""} {
	putserv "PRIVMSG $chan :$nick: Give me something to evaluate!"
	return
    }

    set range 100
    set options [split $text ,]
    set count [llength $options]
    set chuck 0
    set norris false

    for {set i 0} {$i < $count} {incr i} {
	set option [string trim [lindex $options $i]]
	if {[string tolower $option] eq "chuck norris"} {
	    set chuck $i
	    set norris true;
	}
    }

    # randomize the values for all options but the last
    for {set i 0} {$i < $count-1} {incr i} {
	set option [string trim [lindex $options $i]]
	if {$norris == true} {
	    if {$i == $chuck} {
		set value 100
	    } else {
		set value 0
	    }
	} else {
	    set value [expr {int(rand()*$range)}]
	}
	append values [string trim [lindex $options $i]]:\ $value%\ -\ 
	incr range -$value
    }
    # the last option gets the rest
    append values [string trim [lindex $options [expr $count-1]]]:\ $range%

    putserv "PRIVMSG $chan :$nick: $values"
}

###################################
putlog "Script loaded: \002Battle 1.0\002"
###################################
