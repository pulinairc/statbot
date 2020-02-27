################################################
#################### ABOUT #####################
################################################
#
# FMIWeather-0.1 by Fredrik Bostrom
# for Eggdrop IRC bot
# Released 2008-05-08
#
# Usage:
# !fmi
#   - gets the most recent weather observation
#     from fmi.fi, kumpula site
#
################################################
######## DON'T EDIT BEOYND THIS LINE! ##########
################################################

package require tdom
package require http

bind pub - !fmi pub:fmi
bind pub - !saa pub:fmi
bind pub - !keli pub:fmi
bind pub - !sää pub:fmi

set fmiurl "http://ilmatieteenlaitos.fi/saa/Helsinki"

proc pub:fmi {nick host handle chan text} {
    if {[string trim $text] ne ""} {
	set text [string toupper $text 0 0]
	set fmiurl "http://ilmatieteenlaitos.fi/saa/$text"
    } else {
	global fmiurl
    }
    set page [::http::data [::http::geturl $fmiurl]]
    set doc [dom parse -html $page]
    set root [$doc documentElement]
    
    ### get the city 
    # due to some oddity in the html, we take the city from the 
    # graph alt-text
    set cityNode [$root selectNodes {//img[@class='forecast-gram']}]
    set cityHtml [$cityNode asHTML]

    # regexp the alt text and the city
    regexp {alt="(.*?)"} $cityHtml cityMatch city1
    set city [lindex [split $city1 " "] 0]

    putserv "PRIVMSG $chan :$city"

    ### get the sun times
    set sunNode [$root selectNodes {//p[@class='sun-times']}]

    # get the html
    set sunHtml [$sunNode asHTML]

    # remove the surrounding <p> tags
    regsub -all {</??p.*?>} $sunHtml {} sunHtml

    # make <b></b> into \002
    regsub -all {</?strong>} $sunHtml {?} sunHtml

    set sunHtml [string map {"\n" ""} $sunHtml]
    set sunHtml [string map {"?" "\002"} $sunHtml]
    putserv "PRIVMSG $chan :$sunHtml"
    
    ### get the weather observations
    set titleNode [$root selectNodes {//p[@class='observation-text']}]

    set obsHtml [$titleNode asHTML]

    # remove the surrounding <p> tags
    regsub -all {</??p.*?>} $obsHtml {} obsHtml

    # remove em tags
    regsub -all {</?em>} $obsHtml {} obsHtml

    # remove linebreaks
    #regsub -all {\n} $obsHtml {}

    # make <b></b> into \002
    regsub -all {</?strong>} $obsHtml {?} obsHtml

    # make <br/> into @ and split on that
    regsub -all {<br>} $obsHtml @ obsHtml

    set obsParts [split $obsHtml @]

    foreach line $obsParts {
	set line [string map {"\n" ""} $line]
	set line [string map {"?" "\002"} $line]
	putserv "PRIVMSG $chan :$line"
    }
}

###################################
putlog "FMI weather script loaded!"
###################################
