# topiclogger.tcl v1.01 [11 November 2000]
# Copyright (C) 2000 Teemu Hjelt <temex@iki.fi>
#
# Latest version can be found from http://www.iki.fi/temex/eggdrop/
# 
# If you have any suggestions, questions or you want to report 
# bugs, please feel free to send me email to temex@iki.fi
#
# This script logs topics to a HTML-file.
#
# Tested on eggdrop1.4.4 with TCL 7.6
#
# Version history:
# v1.00 - The very first version!
# v1.01 - Fixed a bug with topics including stars, 
#         questions marks and backslashes. (found by Baerchen)

### Settings ###

## Path to the html-file.
set lt_htmlfile "/var/www/pulinatopics.html"

## What kind of body-tag do you want to use in the html-file?
set lt_bodytag {<BODY BGCOLOR="#FFFFFF" TEXT="#000000" LINK="#0000EE" VLINK="#8318C0" ALINK="#005AAF">}

## What kind of tag do you want to use for stylesheets. 
# Note: Leave this empty if you don't want to use stylesheets.
set lt_styletag {<LINK REL="stylesheet" TYPE="text/css" HREF="stylesheet.css">}

## [0/1] Log when this script does something?
set lt_log 1

## [0/1] Log topics of all channels?
set lt_allchans 1

## If $lt_allchans ISN'T enabled this is a list of channels, where topics SHOULD be stored.
## Otherwise this is a list of channels, where topics SHOULDN'T be stored.
set lt_chans "#lamest #botcentral"

## If the size of the HTML-file is bigger than this 
## (in bytes) then clear the file and start over.
# Note: Set this to 0 to disable.
set lt_maxsize 500000

## [0/1] Enable this if you want to use [strftime] instead of [ctime [unixtime]] to show the time and date.
set lt_enablestrftime 1

## If you have enabled $ct_enablestrftime, then set this to the formatstring for strftime.
# Note: If you don't have a clue what this is, then leave it like it is.
set lt_formatstring "%c"

###### You don't need to edit below this ######

### Misc Things ###

set lt_ver "1.01"

### Bindings ###

bind topc - * topc:lt_topic

### Procs ###

proc topc:lt_topic {nick uhost hand chan topic} {
global botnick lt_ver lt_htmlfile lt_bodytag lt_styletag lt_log lt_allchans lt_chans lt_maxsize lt_enablestrftime lt_formatstring
set found 0
set stop 0
set buffer ""
	if {($topic != "") && ($nick != "*") && ($uhost != "*") && ((($lt_allchans) && ([lsearch -exact [string tolower $lt_chans] [string tolower $chan]] == -1)) || ((!$lt_allchans) && ([lsearch -exact [string tolower $lt_chans] [string tolower $chan]] != -1)))} {
		if {(![file exists $lt_htmlfile]) || (($lt_maxsize != 0) && ([file size $lt_htmlfile] >= $lt_maxsize))} { 
			lt_writeheader 
			if {$lt_log} { putlog "topiclogger: Writing document header." }
		}
		if {(!$lt_enablestrftime) || (($lt_enablestrftime) && ([catch {strftime $lt_formatstring} time]))} {
			set time [ctime [unixtime]]
		}
		regsub -all -- "\\\\" $topic "\\\\\\" topic
		regsub -all -- "\\*" $topic "\\*" topic
		regsub -all -- "\\?" $topic "\\?" topic
		regsub -all -- "<" $topic "\\&lt;" topic
		regsub -all -- ">" $topic "\\&gt;" topic
		set fd [open $lt_htmlfile r]
		while {![eof $fd]} {
			gets $fd str
			if {[string match "*&nbsp;$topic&nbsp;*" $str]} {
				if {$lt_log} { putlog "topiclogger: Already logged topic of $chan" }
				close $fd
				return 0	
			} elseif {$str == "</TABLE><!-- end of [string tolower $chan] -->"} {
				if {$hand != "*"} {
					append buffer "<TR><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;[join $topic]&nbsp;</FONT></TD><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;$nick ($uhost) !$hand!&nbsp;</FONT></TD><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;$time&nbsp;</FONT></TD></TR>\n"
				} else {
					append buffer "<TR><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;[join $topic]&nbsp;</FONT></TD><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;$nick ($uhost)&nbsp;</FONT></TD><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;$time&nbsp;</FONT></TD></TR>\n"				
				}
				append buffer "$str\n"
				set found 1
			} elseif {(!$found) && ($str == "<!-- end of channels -->")} {
				append buffer "<!-- beginning of [string tolower $chan] -->\n"
				append buffer "<FONT FACE=\"Verdana\" SIZE=\"4\"><B>$chan</B></FONT>\n"
				append buffer "<TABLE BORDER=\"0\" CELLPADDING=\"1\" CELLSPACING=\"1\">\n"
				append buffer "<TR><TD BGCOLOR=\"#9AA4AE\"><FONT FACE=\"Verdana\" SIZE=\"2\"><B>&nbsp;Topic&nbsp;</B></FONT></TD><TD BGCOLOR=\"#9AA4AE\"><FONT FACE=\"Verdana\" SIZE=\"2\"><B>&nbsp;Set by&nbsp;</B></FONT></TD><TD BGCOLOR=\"#9AA4AE\"><FONT FACE=\"Verdana\" SIZE=\"2\"><B>&nbsp;Time&nbsp;</B></FONT></TD></TR>\n"
				if {$hand != "*"} {
					append buffer "<TR><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;[join $topic]&nbsp;</FONT></TD><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;$nick ($uhost) !$hand!&nbsp;</FONT></TD><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;$time&nbsp;</FONT></TD></TR>\n"
				} else {
					append buffer "<TR><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;[join $topic]&nbsp;</FONT></TD><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;$nick ($uhost)&nbsp;</FONT></TD><TD BGCOLOR=\"#E3E6E7\"><FONT FACE=\"Verdana\" SIZE=\"2\">&nbsp;$time&nbsp;</FONT></TD></TR>\n"				
				}
				append buffer "</TABLE><!-- end of [string tolower $chan] -->\n"
				append buffer "\n"
				append buffer "<BR><BR>\n"
				append buffer "\n"
				append buffer "$str\n"
			} elseif {$str == "</HTML>"} {
				append buffer "$str"
				set stop 1
			} elseif {!$stop} {
				append buffer "$str\n"
			}
		}
		close $fd
		set fd [open $lt_htmlfile w]
		puts $fd $buffer
		close $fd
		if {$lt_log} { putlog "topiclogger: Logged topic of $chan" }
	}
}

proc lt_writeheader { } {
global botnick lt_ver lt_htmlfile lt_bodytag lt_styletag lt_log lt_allchans lt_chans lt_maxsize lt_enablestrftime lt_formatstring
	set buffer "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n"
	append buffer "<HTML>\n"
	append buffer "<HEAD>\n"
	append buffer "	<TITLE>Topics</TITLE>\n"
	append buffer "\n"
	append buffer "<META http-equiv=\"Content-Type\" CONTENT=\"text/html; charset=iso-8859-1\">\n"
	append buffer "\n"
	if {$lt_styletag != ""} { 
		append buffer "$lt_styletag\n" 
		append buffer "\n"
	}
	append buffer "</HEAD>\n"
	append buffer "\n"
	append buffer "$lt_bodytag\n"
	append buffer "\n"
	append buffer "<BR>\n"
	append buffer "\n"
	append buffer "<CENTER>\n"
	append buffer "\n"
	append buffer "<FONT FACE=\"Verdana\" SIZE=\"6\"><B>Topics</B></FONT><BR>\n"
	append buffer "<FONT FACE=\"Verdana\" SIZE=\"2\">logged by $botnick</FONT>\n"
	append buffer "\n"
	append buffer "<BR><BR><BR>\n"
	append buffer "\n"
	append buffer "<!-- beginning of channels -->\n"
	append buffer "\n"
	append buffer "<!-- end of channels -->\n"
	append buffer "\n"
	append buffer "<FONT FACE=\"Verdana\" SIZE=\"2\"><B>This file was automatically generated by <A HREF=\"http://www.iki.fi/temex/eggdrop/\" TARGET=\"_top\">topiclogger.tcl</A> v$lt_ver by <A HREF=\"mailto:temex@iki.fi\">Sup</A></B></FONT>\n"
	append buffer "\n"
	append buffer "</CENTER>\n"
	append buffer "\n"
	append buffer "<BR><BR>\n"
	append buffer "\n"
	append buffer "</BODY>\n"
	append buffer "</HTML>"
	set fd [open $lt_htmlfile w]
	puts $fd $buffer
	close $fd
}

### End ###

putlog "TCL loaded: topiclogger.tcl v$lt_ver by Sup <temex@iki.fi>"
