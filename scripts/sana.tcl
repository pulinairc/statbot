#########################################################################################
##
## sana(kirja) v1.31
##
## Hakee suomenkielisestä / englanninkielisestä sanasta selityksen ja käännöksen.
## Lähteinä toimivat
##
## Suomenkieliset selitykset:		http://www.cs.tut.fi/~jkorpela/siv/laaja.html
## Suomi-Englanti:			http://212.213.217.194
## Englanninkieliset selitykset:	http://www.m-w.com
## Englanti-Suomi:			http://212.213.217.194
##
## Huom! kannattaa tuhota vanha laaja.html cellgenin cachedirrikasta
##
## v1.31: ääkköset eivät toimineet !!
## v1.30: conf(channels) lisätty
##


package require cellgen 2.50
namespace eval sana {
set scriptversion 1.30

::cell::registerautoupdate $scriptversion "http://cell.isoveli.org/scripts/sana.tcl"

## Kanavat joissa toimitaan, erottele välilyönnillä
set conf(channels) "#pulina #kuurosokeat"

## Käännetäänkö sana aina Suomi-Englanti-Suomi?
set conf(translation) 1

## Annetaanko sanasta aina selitys (webster)
set conf(explanation_eng) 1

## Annetaanko sanasta aina selitys (suomalainen sivistyssanakirja)
set conf(explanation_fin) 1

## Millä switchillä annetaan selitys jos se muuten on estetty?
set conf(explanation_switch) "ext"

## sivisttyssanakirjan kotskaborttaali
set conf(findic) "http://www.cs.tut.fi/~jkorpela/siv/laaja.html"




bind pub - !sana sana::sanapub
bind pub - .sana sana::sanapub
bind msg - sana sana::sanamsg
bind msg - .sana sana::sanamsg
variable runcount 0
variable giveupcount [expr $conf(explanation_fin)+$conf(explanation_eng)+$conf(translation)]

proc sanamsg {nick uhost handle args} {
	return [sanapub $nick $uhost $handle $nick $args]
}

proc sanapub {nick uhost handle chan args} {

	variable conf
	variable runcount
	variable testcount

	foreach ch $conf(channels) { if {[regexp -nocase -- "^$ch\$" $chan]} { set ok 1 } }
	if {![info exists ok]} { return 0 }

	regsub -all -- {\{|\}} $args "" args
	if {[regsub -all -- " *\\m$conf(explanation_switch)\\M *" $args {} args]} { set long 1} else { set long 0 }

	incr runcount
	set testcount($runcount) 0
	set args [split $args " "]
	set word [lindex $args 0]
	set filters ""
	if {[llength $args] > 1} { set filters [lrange $args 1 end] }

	if {$conf(explanation_eng) || $long}	{ sana::eng_dictionary $word [list $nick $chan $word $filters $runcount $long]	}
	if {$conf(translation)}			{ sana::translation $word [list $nick $chan $word $filters $runcount $long]		}
	if {$conf(explanation_fin) || $long}	{ sana::fin_dictionary $word [list $nick $chan $word $filters $runcount $long]	}

	cell::wait 2

	return 1
}


proc showresults { explist arguments } {

	variable testcount
	variable runcount
	variable giveupcount

	set nick [lindex $arguments 0]
	set chan [lindex $arguments 1]
	set word [lindex $arguments 2]
	set filters [lindex $arguments 3]
	set runcount [lindex $arguments 4]
	set long [lindex $arguments 5]

	set flood [sana::getfloodstring $explist $nick $chan]
	incr testcount($runcount)
	if {![sana::floodtext $word $filters $flood $chan]} {
		if { $testcount($runcount) == 3 || ($long == 0 && $testcount($runcount) == $giveupcount)} {
			putserv "PRIVMSG $chan :!sana($word ($filters)): Ei tietoa."
		}
	} else { set testcount($runcount) 0 }


	return 1
}


proc floodtext {word filters flood chan} {

	set pre "!sana($word"
	if {$filters != ""} { append pre " + $filters" }
	append pre "): "

	if {$flood != ""} {
		set fl [split $flood \n]
		foreach flood $fl {
			if {$flood != ""} { putserv "PRIVMSG $chan :$pre$flood" }
		}
		return 1
	}

	return 0
}


proc checkfilters {string filters} {
	if {$filters == ""} { return 1 }
	foreach filter $filters { if {![regexp $filter $string]} { return 0 } }
	return 1
}


proc getfloodstring { wordlist nick chan} {

	if {$wordlist == ""} { return "" }
	set flood ""
	foreach i $wordlist { 
		regsub -all -- ".*\n" $flood {} jee
		if {$nick != $chan} {
			if {[expr [string length $jee] + 2 + [string length $i]] > 470 && $jee != ""} { append flood "\n" }
		}
		append flood ", $i"
		if {$nick == $chan && [regexp " " $i]} { append flood "\n" }
	}
	regsub -all -- "^, " $flood "" flood
	regsub -all -- "\n, " $flood "\n" flood
	return $flood
}


proc eng_dictionary {word arguments} {
	set url "http://www.m-w.com/cgi-bin/dictionary?book=Dictionary&va=$word"
	set token [cell::geturl $url ::sana::eng_dictionary_cb $arguments]
}


proc eng_dictionary_cb { token } {

	set arguments [cell::getcbargs $token]
	set foo [split [cell::geturldata $token] \n]
	set explist ""
	set count 0
	set filters [lindex $arguments 3]

	foreach i $foo {
		if {[regexp -- "<b>:</b>" $i]} {
			regsub -all -- "<br>- .*" $i "" i
			regsub -all -- "<br>" $i "|" i
			set i [split $i "|"]
			foreach exp $i {
				regsub -all -- "^: |^. : " [cell_formattext $exp] {} flood
				regsub -all -- " : " $flood ": " flood
				if {[checkfilters $flood $filters] && $count < 3} {
					lappend explist $flood
					incr count
				}
			}
		}
	}

	sana::showresults $explist $arguments
}


proc fin_dictionary {word arguments} {
	variable conf

	set filename "$::cell::conf(cachepath)/laaja.html"
	if {![file exists $filename] || ([expr [unixtime]-[file mtime $filename]] > 2592000)} {
		set data [cell_geturl $conf(findic) ""]
		set fp [open $filename w]
		puts $fp $data
		close $fp
	} else {
		set fp [open $filename r]
		set data [read $fp]
		close $fp
	}

	# cell::geturlcache $conf(findic) ::sana::fin_dictionary_cb $arguments
	fin_dictionary_cb $data $arguments
}


proc fin_dictionary_cb {data arguments} {

	set foo [split $data \n]
	set word [lindex $arguments 2]
	set filters [lindex $arguments 3]
	set explist ""
	set count 0
	set lines 0

	foreach i $foo {
		incr lines
		if {[regexp -- "<p><a name=\"$word\"" $i]} {
			regsub -all -- {</a>[\t ]*=[ \t]*} $i {} i
			if {[checkfilters $i $filters] && $count < 3} {
				lappend explist [::cell::formattext $i]
				incr count
			}
		}
	}

	sana::showresults $explist $arguments
}


proc translation {word arguments} {
	regsub -all -- {[äÄ]} $word {%E4} word
	regsub -all -- {[Öö]} $word {%F6} word
	cell::geturl "http://www.tracetech.net:8081/?word=$word" ::sana::translation_cb $arguments
}


proc translation_cb { token } {

	set arguments [cell::getcbargs $token]

	set flood ""
	set wordlist ""
	set foo [cell::geturldata $token]
	set filters [lindex $arguments 3]
	set foo [split $foo \n]

	foreach i $foo {
		if {[regexp "<td><font color=#0000ee>" $i]} {
			set sana [cell_formattext $i]
			if {[checkfilters $i $filters]} {
				regsub -all -- "\n" $sana {} sana
				lappend wordlist $sana
			}
		}
	}

	sana::showresults $wordlist $arguments
}

}
#end sana namespace


putlog "Script loaded: \002sana(kirja) v$sana::scriptversion by (c)cell\002"
