# Random Movies (tehnyt rolle)

bind pub - !elokuva haeleffa
bind pub - !leffa haeleffa

proc haeleffa { nick uhost hand chan rest } { 

package require tdom 
package require http 
set url "http://peikko.us/movielist.php" 
set page [::http::data [::http::geturl $url]] 
set doc [dom parse -html $page] 
set root [$doc documentElement] 
set node [$root selectNodes {//p}] 
set text [[[lindex $node 0] childNodes] nodeValue] 
	
putserv "PRIVMSG $chan :$text" 
}

#proc pub:miitit {nick host hand chan arg} {
#if {$chan == "#pulina"} {
#   puthelp "PRIVMSG $chan :$nick\: http://miitit.pulina.fi"
#   }
#}

putlog "Script loaded: \002randommovies.tcl by rolle\002"