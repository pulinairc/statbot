##################################################################
#
#	toptod by (c)cell '2001
#	version 1.12.1
#
# 1.12.1->		poistetti toptod(savedir) optio turhana
# 1.12  ->		scripta omassa namespacessaan
# 1.1	->		osaa resumea listan restartin tms j?keen. tekee my? history-tiedostoa
#			tulevaisuuden statistiikkafeatureita varten
# 1.08	-> 1.1		sanoja osataan logittaa multpippeleilt?kanavilta
# 1.08			homma toimii
#
#
namespace eval toptod {
set scriptversion 1.12.1

# kanavat joilta sanoja lasketaan PIENELL?KIRJOITETTUNA, pilkulla erotettuina esim. "#foo,#bar"
set toptod(todlogchannel) "#pulina"

# (toptod tallentaa tietonsa cellgenin cachedirrikkaan tai bottidirrikkaan jos cellgeni?ei l?dy)

###################################################################

#bind pub - !toptod toptod::julkinentop
#proc julkinentop {nick host hand chan arg} {
#   puthelp "NOTICE $nick :Käytä privaa ilman huutomerkkiä alussa, tähän tapaan: /msg kummitus toptod"
#   }


bind pubm - * toptod::count_words_tod
bind pubm - * toptod::savetohtml
bind pub - !pojot toptod::toptodpub
bind pub - !top toptod::toptodpub
bind pub - .toptod toptod::toptodpub
bind pub - !toptod toptod::toptodpub
bind msg - toptod toptod::toptodmsg
bind time - "00 00 % % %" toptod::cleartod

proc getsavedir {} {
	if {[info exists ::cell::conf(confpath)]} { return $::cell::conf(confpath) }
	return "."
}

proc savetohtml {min hour day month year} {
	variable toptod

	# Tämä sisältää itse tallentamisen (kökköä, tiedän) t. rolle
	foreach i [split $toptod(todlogchannel) ","] { toptod::toptodpub $i - - $i "" }

}

proc cleartod {min hour day month year} {
	variable toptod

# floodii kanavalle joka keskiyö
#	foreach i [split $toptod(todlogchannel) ","] { toptod::toptodpub $i - - $i "" }

	set toptod(todnicklist) ""
	set toptod(todwordcount) ""
	set toptod(todlastcomlist) ""

	putlog "today-stats cleared"
}


proc count_words_tod {nick uhost hand chan text} {

	variable toptod

	regsub -all -- {\[|\]} $nick {} nick
	regsub -all -- {\[|\]} $hand {} hand

	set chan [string tolower $chan]
	set ok 0
	foreach i [split $toptod(todlogchannel) ","] { if {$chan == $i} { set ok 1 } }
	if {$ok == 0} {return 0}
	if {[matchattr $hand "b"]} { return 0 }

	set nik $hand
	if {$nik == "*"} { set nik $nick }

	set num [lsearch $toptod(todnicklist) $chan:$nik]
	if {$num == -1} {
		set num [llength $toptod(todnicklist)]
		lappend toptod(todnicklist) "$chan:$nik"
		lappend toptod(todwordcount) "0.$num"
		lappend toptod(todlastcomlist) ""
	}

	regsub -all -- "  " $text " " text
	regsub -all "\"|\{|\}" $text "x" text

	if {[lindex $toptod(todlastcomlist) $num] == $text} { return 0 }

	set words [lindex [split [lindex $toptod(todwordcount) $num] "."] 0]
	set words [expr "$words+[llength [split $text " "]]"]
	set toptod(todwordcount) [lreplace $toptod(todwordcount) $num $num "$words.$num"]
	set toptod(todlastcomlist) [lreplace $toptod(todlastcomlist) $num $num $text]

	toptod::savetoptod toptod.save w [clock format [clock seconds] -format %d-%m-%Y]

# rolle koittaa saada botin voicettamaan toptodissa olevat:
        pushmode $chan +v $nick

}


proc resumetoptod {} {

	variable toptod
	set dir [getsavedir]
	set virhe [catch {set fiilu [open /var/www/toptod.save]}]

	if {$virhe != 1} {
#		putlog "resuming toptod.."
putlog ""
		set savedate [gets $fiilu]
		if {$savedate == [clock format [clock seconds] -format %d-%m-%Y]} {
			set toptod(todnicklist) [gets $fiilu]
			set toptod(todwordcount) [gets $fiilu]
			set toptod(todlastcomlist) ""
			for {set i 0} {$i<[llength $toptod(todnicklist)]} {incr i} { lappend toptod(todlastcomlist) "-" }
			if {[llength $toptod(todnicklist)] != [llength $toptod(todwordcount)]} {
				putlog "toptod statistics corrupted - reseting"
  	                        set toptod(todnicklist) ""
        	                set toptod(todwordcount) ""
				set toptod(todlastcomlist) ""
			}
		}
		close $fiilu
	} else {
#		putlog "Sanaenn?yksi?ei ladattu, ehk?botti on ollut v?? aikaa down?"
	}
}


proc savetoptod {name accessmode date} {
	variable toptod
	set cdate [clock format [clock seconds] -format %d-%m-%Y]

	if {$accessmode != "a"} {
		set dir [getsavedir]
		set virhe [catch {set fiilu [open /var/www/toptod.save]}]
	        if {$virhe != 1} {
	                set savedate [gets $fiilu]
	                if {$savedate != $cdate} {
				set varanicklist $toptod(todnicklist)
				set varawordcount $toptod(todwordcount)
	                        set toptod(todnicklist) [gets $fiilu]
	                        set toptod(todwordcount) [gets $fiilu]
				close $fiilu
				putlog "appending toptod history file"
				toptod::savetoptod "toptodhistory.save" a $savedate
                                set toptod(todnicklist) $varanicklist
                                set toptod(todwordcount) $varawordcount
	                } else { close $fiilu }
		} else { putlog "errori" }
	}

	set dir [getsavedir]
        set virhe [catch {set fiilu [open /home/rolle/public_html/$name $accessmode 0770]}]

	if {$virhe != 1} {
		puts $fiilu $date
                puts $fiilu $toptod(todnicklist)
		puts $fiilu $toptod(todwordcount)
		close $fiilu
	} else {
		putlog "unable to save toptod file to/home/rolle/public_html/$name"
	}
}


proc toptodmsg {nick uhost hand text} {
	variable toptod
	foreach i [split $toptod(todlogchannel) ","] { toptod::toptodpub $nick - - "show:$i" "" }
}

proc toptodpub {nick uhost hand chan text} {

	variable toptod

	set le 0
	set flood ""
	set sortedlist [lsort -decreasing -real $toptod(todwordcount)]
	set to $nick

	if {[lindex [split $chan ":"] 0] == "show"} {
		set chan [lindex [split $chan ":"] 1]
		append flood "$chan: "
		set to $nick
# rolle koittaa saada botin voicettamaan toptodissa olevat:
		pushmode $chan +v $nick
	}

	set chan [string tolower $chan]
	if {$text > 0} { set ecount $text } else { set ecount 10 }


# ei tod. ole nick sitten toi $nick muuttuja tossa listassa

	set pippeli 0
	set le [expr $ecount-10]
	set skipcount $le

	for {} {$le < $ecount && $pippeli < 200} {} {
		if {$le >= 0 && $le < [llength $sortedlist]} {

			set nick [lindex $sortedlist $pippeli]
			set nickindex [lindex [split $nick "."] 1]

			if {$nickindex != ""} {
				if {[lindex [split [lindex $toptod(todnicklist) $nickindex] ":"] 0] == $chan} {
					incr skipcount -1
					if {$skipcount < 0} {
						append flood "[expr $le+1]. [lindex [split [lindex $toptod(todnicklist) $nickindex] ":"] 1]"
						append flood "([lindex [split $nick "."] 0]) "
						incr le

# rolle koittaa saada botin voicettamaan toptodissa olevat:
				                pushmode $chan +v $nick

					} else { putlog "skip" }
				}
			}
		}
		incr pippeli
	}

	set htmlpage [ open "/home/rolle/public_html/toptod.html" w+ ]
	puts $htmlpage "
	$flood
	"
	close $htmlpage

	putserv "NOTICE $to :$flood"
#	puthelp "PRIVMSG $chan :$flood"
}

catch {
	set toptod(todnicklist) ""
	set toptod(todwordcount) ""
	set toptod(todlastcomlist) ""
	toptod::resumetoptod
} error
if {$error != "" && $error != 0} { putlog "ERROR (toptod.tcl): $error" }

}
putlog "Script loaded: \002Toptod $toptod::scriptversion\002"
