# html2.tcl -- a lot like ques3.tcl, but i wrote this one myself and to my
#             likings plus improvemnets for eggdrop1.3.4!
#
# fixed - doesn't display chan voices twice..
#
# original version by kn0 <keith@cs.oswego.edu>
# edited for eggdrop1.3.x by prime <unkonwn>
# set these....
# do this for every channel you want
set web_chans(#pulina) pulina.html

# what directory are your web pages in? or what directory do you want this to
# be in?

set web_dir /var/www/

# how often do you want the page to be updated? (in minutes)

set web_update 1

foreach i [timers] {
    if {[lindex $i 1] == "web_write"} {
        killtimer [lindex $i 2]
    }
}

if ![info exists web_topic] {set web_topic(*) "*"}
foreach i [channels] {set web_topic($i) ""}
proc web_write {} {
    global web_dir web_update botnick nick web_topic web_chans
    foreach i [array names web_chans] {
        set wpage $web_dir$web_chans($i)
        set web_page $web_chans($i)
        set web_chan $i
        set a [open $wpage w]
        if {$web_topic($i) == ""} {
            set web_topic($i) ""
        }
		#puts $a "<!doctype html>"
		#puts $a "<head>"
        #puts $a "<title>#pulina irkkaajalista (p‰iv. [time] [date])</title>"
		#puts $a "<link rel=\"stylesheet\" type=\"text/css\" href=\"pulina_users.css\" />"
		#puts $a "</head>"
		#puts $a "<body>"
        #puts $a "<div class\"wrapper\">"
#		puts $a "<h2>Topic: $web_topic($i)</h2>"
        #if {![onchan $botnick $web_chan]} {
        #    puts $a "<h3>kummitus ei ole juuri nyt kanavalla</h3>"
        #}
        #puts $a "<h3>$web_chan, [getchanmode $web_chan] ([llength [chanlist $web_chan]] k‰ytt‰j‰‰)</h3>"
		puts $a "<b class=\"paikalla\">[llength [chanlist $web_chan]]</b><br />"

        set chanlist [chanlist $web_chan]
        set chanlist "$botnick [lsort [lrange $chanlist 1 end]]"
        set oplist ""
        set vlist ""
        set noplist ""
        set noplist2 ""
        foreach i $chanlist {if [isop $i $web_chan] {lappend oplist $i} {lappend noplist $i}}
        foreach i $noplist {
            if [isvoice $i $web_chan] {
                lappend vlist $i
            } {
                lappend noplist2 $i
            }
        }
        set noplist $noplist2
        foreach i "\{$oplist\} \{$noplist\} \{$vlist\}" {
            foreach b $i {
                set c ""
                if {[isop $b $web_chan]} {set q "<span class=\"opmark\">@</span>"} {set q ""}
                if {[isvoice $b $web_chan]} {set q "<span class\"voicemark\">+</span>"}
                if {[matchattr [nick2hand $b $web_chan] b]} {append c ", (bot)"}
               if {$botnick == $b} {
#                    puts $a "<li>$q$b <b>&larr; min‰!</b></li>"
puts $a "";
                }
                if {$botnick != $b} {
                    set hand [nick2hand $b $web_chan]
                    puts $a "<span class=\"irkkaaja\" title=\"[getchanhost $b $web_chan], idle [getchanidle $b $web_chan] min$c\">$q$b</span> "
                    #if {[getchaninfo $hand $web_chan] != "" && ![matchattr $b b] && $hand != "*"} {
                    #    puts $a "<i>info: [getchaninfo [nick2hand $b $web_chan] $web_chan]</i>"
                    #}
                }
            }
        }
		
        #if {[chanbans $web_chan] != ""} {
        #    puts $a "<h2>Bans</h2>"
	#		puts $a "<ul class=\"banlist\">"
    #        foreach c [chanbans $web_chan] {
    #            puts $a "<li>$c</li>"
    #        }
    #        puts $a "</ul>"
    #    }
    #    puts $a "T‰m‰ sivu p‰ivittyy $web_update minuutin v‰lein."
#		puts $a "</body>"
#		puts $a "</html>"
        close $a
    }
    timer $web_update web_write
}
bind topc - * web_topic
proc web_topic {nick uhost handle channel vars} {
    global web_topic web_chans
    if {[lsearch [array names web_chans] $channel] != "-1"} {
        set web_topic($channel) $vars
    }
}
web_write
putlog "Script loaded: \002html2\002 by \037prime\037 - writing: [array names web_chans] :stats files"
