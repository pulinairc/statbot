#----------------------------------------------------------
# NickPlus by phil - Version 1.0 (First public release)
# See it in action at treochat.net
# *uses a PHP script to display and format
#
# Writes the current nicklist to a file to be used in other
# scripts or displayed on a web page.  Supports the nick
# prefixes ~, &, @, %, and + (common to UnrealIRCDs).
#
#----------------------------------------------------------- 

set ver "1.0"
# Change dumpfile to the path where you'd like the file to be written.
set dumpfile "/home/rolle/public_html/nickplus.txt" 
# Change channel to the channel whos nicklist you'd like to write.
set channel "#pulina" 

# You may remove these binds if you'd like to only use the 5 minute timer
bind sign - "$channel %" nickplus:sendnames
bind part - "$channel %" nickplus:sendnames
bind splt - "$channel %" nickplus:sendnames
bind join - "$channel %" nickplus:sendnames
bind kick - "$channel %" nickplus:sendnames
bind nick - "$channel %" nickplus:sendnames
bind mode - "$channel %" nickplus:sendnames

# Leave the rest well enough alone :)
bind raw - "353" nickplus:make

proc nickplus:sendnames {args} {
global channel
putserv "NAMES $channel"
}

proc nickplus:make {from keyword argz} {

global dumpfile channel botnick

set nicklist [split [lindex [split [string trim $argz] ":"] 1] " "]

set masterlist ""
set flist ""
set plist ""
set olist ""
set hlist ""
set vlist ""
set rlist ""

foreach user $nicklist {
if {[string first "~" $user] == 0} {
lappend flist $user
} elseif {[string first "&" $user] == 0} {
lappend plist $user
} elseif {[string first "@" $user] == 0} {
lappend olist $user
} elseif {[string first "%" $user] == 0} {
lappend hlist $user
} elseif {[string first "+" $user] == 0} {
lappend vlist $user
} else {
lappend rlist $user
}
}

set flist [lsort -dictionary $flist]
set plist [lsort -dictionary $plist]
set olist [lsort -dictionary $olist]
set hlist [lsort -dictionary $hlist]
set vlist [lsort -dictionary $vlist]
set rlist [lsort -dictionary $rlist]

foreach user $flist {
lappend masterlist $user
}
foreach user $plist {
lappend masterlist $user
}
foreach user $olist {
lappend masterlist $user
}
foreach user $hlist {
lappend masterlist $user
}
foreach user $vlist {
lappend masterlist $user
}
foreach user $rlist {
lappend masterlist $user
}

set outputfile [open $dumpfile w]

foreach user $masterlist { 
puts $outputfile $user
}

close $outputfile

putlog "NickPlus : Written"

return 1
}
if {![info exists nickplus_running]} {   
timer 300 nickplus:sendnames                     
set nickplus_running 1                 
}  
nickplus:sendnames
putlog "Script loaded: \002NickPlus\002"
