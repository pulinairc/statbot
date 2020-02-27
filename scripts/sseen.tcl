#  ----------------------------------------------------------
#  
#   SSeen v 0.2.22
#   Author: samu (IRC: samu@pirc.pl)
#
#  ----------------------------------------------------------
#
#  This is a very, very simple !seen script, which will not
#  only tell you where did the bot last seen specified nick,
#  but also where.
#
#  TODO: A simple tracking of nick changes.
#
#  ----------------------------------------------------------
#  Config section
#  ----------------------------------------------------------

set dateformat {%Y/%m/%d %H:%M:%S};	# Specify the date
					# format.

#  ----------------------------------------------------------
#
#  Then just do .chanset #channel +sseen, which will set both
#  on which channel will he log users activity, but also on
#  which will users be able to use the !seen command.
#
#  ----------------------------------------------------------

bind pubm - * public_msg_save
bind sign - * public_msg_save
bind pub - !seen pub_show_seen

set ver "0.2.22"


setudef flag sseen

proc _showcurtime { } {
	global dateformat
	set _curtime [clock seconds]
	set _curtime [string map {"\n" ""} [clock format $_curtime -format $dateformat]]
	return "$_curtime"
}

proc public_msg_save {nick userhost handle channel text} {
	global lastseen
	global lastchan
	if {[channel get $channel sseen]} {
		set lastseen($nick) [_showcurtime]
		set lastchan($nick) $channel
	}
}

proc pub_show_seen {nick userhost handle channel text} {
	global lastseen
	global lastchan
	if {[channel get $channel sseen]} {
		set text [lindex $text 0]
		if {$text == $nick} {
			putquick "PRIVMSG $channel :Koitapa ryypätä vähemmän? Olen kuullut että muisti pelaa silloin paljon paremmin..."
			return 0;
		} else {
			if {[info exists lastseen($text)]} {
				putserv "PRIVMSG $channel :Nimimerkki $text nähty viimeksi $lastseen($text) kanavalla $lastchan($text)."
			} else {
				putserv "PRIVMSG $channel :Nimimerkkiä $text ei ole nähty vielä."
			}
		}
	}
}

putlog "SSeen $ver by samu (www.samaelszafran.pl) loaded!"

