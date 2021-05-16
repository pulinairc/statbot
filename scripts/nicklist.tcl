# *********************************************************************************************
# Write Channel Nicklist 2 File -- By SpOoK
#
# Used to retrive the channels nicklist so it can be displayed on a webpaged
# Change set channel "#yourchanel" to reflect the channel you want to output the nicklist for.
#
# To set the update time change the value after "timer x make". There are 2 instances of this.
# default update time is now 5 mins
#
# Revisions:
# v1.1 - Added bind controls, nicklist is now generated upon join/kick or nick change.
#      - Nicklist is now sorted alphabetically for oped/voiced/normal users
# v1.0 - Initial Release
# **********************************************************************************************

set ver "1.1" 
set dumpfile "/var/www/botit.pulina.fi/public_html/nicklist.txt" 
set channel "#pulina" 

# Bind Events we want to catch...
# Note: Remove the following 6 lines for timer only update. Reccomended for larger channels.
bind sign - "$channel %" nicklist:make
bind part - "$channel %" nicklist:make
bind splt - "$channel %" nicklist:make
bind join - "$channel %" nicklist:make
bind kick - "$channel %" nicklist:make
bind nick - "$channel %" nicklist:make

if {![info exists nicklist_running]} {   
    timer 5 nicklist:make                      
    set nicklist_running 1                 
  }                                   

proc nicklist:make {args} { 

global dumpfile channel botnick

set nicklist [chanlist $channel]
set nicklist [lsort -dictionary [lrange $nicklist 0 end]]

set templist ""
set oplist ""
set voicelist ""
set userlist ""

set outputfile [open $dumpfile w]

foreach user $nicklist {
    if {([isop $user $channel])} {
    	lappend oplist $user
       } elseif {([isvoice $user $channel])} {
    	lappend voicelist $user
    	} else {
   	 lappend userlist $user
   }
}


foreach chanlistnicks "\{$oplist\} \{$voicelist\} \{$userlist\}" {
            foreach usernick $chanlistnicks {
                if {[isop $usernick $channel]} {set control "@"} {set control ""}
                if {[isvoice $usernick $channel]} {set control "+"}
                    puts $outputfile $control$usernick
  }
}

close $outputfile

putlog "Saving $channel NickList..." 
timer 5 nicklist:make
return 1
} 

putlog "Script loaded: \002Write Channel Nicklist to File v$ver by SpOoK\002" 
