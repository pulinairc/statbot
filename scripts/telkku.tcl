# telkku.tcl - TV shows for Eggdrop IRC bot
# by Roni "rolle" Laukkarinen
# rolle @ irc.quakenet.org, rolle_ @ IRCnet

# Updated when:
set versijonummero "0.4.20150618"
#------------------------------------------------------------------------------------
# Elä herran tähen mäne koskemaan tai taivas putoaa niskaas!
# Minun reviiri alkaa tästä.

package require Tcl 8.5
package require http 2.1
package require tdom

bind pub - !tv pub:telkku

set tvurl "http://telkussa.fi/RSS/Channel/1" 

proc pub:telkku { nick uhost hand chan text } { 

    if {[string trim $text] ne ""} {

        if {[string trim $text] eq "tv1"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/1" 
        }

        if {[string trim $text] eq "tv2"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/2" 
        }

        if {[string trim $text] eq "mtv3"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/3" 
        }

        if {[string trim $text] eq "nelonen"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/4" 
        }

        if {[string trim $text] eq "subtv"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/5" 
        }

        if {[string trim $text] eq "yleteema"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/14" 
        }

        if {[string trim $text] eq "jim"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/56" 
        }

        if {[string trim $text] eq "liv"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/63" 
        }

        if {[string trim $text] eq "mtv"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/63" 
        }

        if {[string trim $text] eq "hero"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/103" 
        }

        if {[string trim $text] eq "fox"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/77" 
        }

        if {[string trim $text] eq "ava"} { 
            set tvurl "http://telkussa.fi/RSS/Channel/60" 
        }

    } else {
        
        global tvurl
        putserv "PRIVMSG $chan :\002!tv\002 kanava (oletus: 1-5, tämänhetkiset kanavat: tv1, tv2, mtv3, nelonen, subtv, yleteema, jim, mtv, hero, fox, ava)"
    
    }

    set kanavasivu [::http::data [::http::geturl $tvurl]]
    set doc [dom parse $kanavasivu]
    set root [$doc documentElement]
    set titleList [$root selectNodes /rss/channel/item/title/text()]
    set ohjelmanimi [lindex $titleList 0]
    set descList [$root selectNodes /rss/channel/item/description/text()]
    set kuvaus [lindex $descList 0]

    if {[string trim $text] ne ""} {

            putserv "PRIVMSG $chan :\002$text\002: \002[encoding convertfrom utf-8 [$ohjelmanimi nodeValue]]\002 - Kuvaus: [encoding convertfrom utf-8 [$kuvaus nodeValue]]"            

    } else {


            set tv1_tvurl "http://telkussa.fi/RSS/Channel/1"
            set tv1_kanavasivu [::http::data [::http::geturl $tv1_tvurl]]
            set tv1_doc [dom parse $tv1_kanavasivu]
            set tv1_root [$tv1_doc documentElement]
            set tv1_titleList [$tv1_root selectNodes /rss/channel/item/title/text()]
            set tv1_ohjelmanimi [lindex $tv1_titleList 0]

            set tv2_tvurl "http://telkussa.fi/RSS/Channel/2"
            set tv2_kanavasivu [::http::data [::http::geturl $tv2_tvurl]]
            set tv2_doc [dom parse $tv2_kanavasivu]
            set tv2_root [$tv2_doc documentElement]
            set tv2_titleList [$tv2_root selectNodes /rss/channel/item/title/text()]
            set tv2_ohjelmanimi [lindex $tv2_titleList 0]

            set mtv3_tvurl "http://telkussa.fi/RSS/Channel/3"
            set mtv3_kanavasivu [::http::data [::http::geturl $mtv3_tvurl]]
            set mtv3_doc [dom parse $mtv3_kanavasivu]
            set mtv3_root [$mtv3_doc documentElement]
            set mtv3_titleList [$mtv3_root selectNodes /rss/channel/item/title/text()]
            set mtv3_ohjelmanimi [lindex $mtv3_titleList 0]

            set nelonen_tvurl "http://telkussa.fi/RSS/Channel/4"
            set nelonen_kanavasivu [::http::data [::http::geturl $nelonen_tvurl]]
            set nelonen_doc [dom parse $nelonen_kanavasivu]
            set nelonen_root [$nelonen_doc documentElement]
            set nelonen_titleList [$nelonen_root selectNodes /rss/channel/item/title/text()]
            set nelonen_ohjelmanimi [lindex [split [lindex $nelonen_titleList 0] ":"] 0]

            set subtv_tvurl "http://telkussa.fi/RSS/Channel/5"
            set subtv_kanavasivu [::http::data [::http::geturl $subtv_tvurl]]
            set subtv_doc [dom parse $subtv_kanavasivu]
            set subtv_root [$subtv_doc documentElement]
            set subtv_titleList [$subtv_root selectNodes /rss/channel/item/title/text()]
            set subtv_ohjelmanimi [lindex [split [lindex $subtv_titleList 0] ":"] 0]

            putserv "PRIVMSG $chan :\002(tv1)\002: [encoding convertfrom utf-8 [$tv1_ohjelmanimi nodeValue]], \002(tv2)\002: [encoding convertfrom utf-8 [$tv2_ohjelmanimi nodeValue]], \002(mtv3)\002: [encoding convertfrom utf-8 [$mtv3_ohjelmanimi nodeValue]], \002(nelonen)\002: [encoding convertfrom utf-8 [$nelonen_ohjelmanimi nodeValue]], \002(subtv)\002: [encoding convertfrom utf-8 [$subtv_ohjelmanimi nodeValue]]"

    }
}

# Kukkuluuruu.
putlog "Rolle's telkku.tcl (version $versijonummero) LOADED!"