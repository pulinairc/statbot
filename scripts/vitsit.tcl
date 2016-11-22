bind pub - !vitsi pub:vitsi
bind pub w !lis‰‰vitsi pub:addvitsi

proc pub:addvitsi { nick uhost handle channel arg } {
	if { $arg == "" } {
		putserv "NOTICE $nick :K‰yttˆ: !lis‰‰vitsi <vitsi>"
		return 0
	}
	set vitsi [open "/home/rolle/eggdrop/scripts/vitsit.txt" a]
	puts $vitsi "$arg"
	close $vitsi
	putserv "NOTICE $nick :vitsi Lis‰‰ vitsi komennolla !lis‰‰vitsi <vitsi>"
}

proc pub:vitsi { nick uhost handle channel arg } {
	set vitsifile [open "/home/rolle/eggdrop/scripts/vitsit.txt" r]
	set i 0
	while { [eof $vitsifile] != 1 } {
		incr i 1
		set vitsi($i) [gets $vitsifile]
	}
	set w [rand $i]
	set outvitsi $vitsi($w)
	putserv "PRIVMSG $channel :$outvitsi"
}

putlog "Script loaded: \002Vitsit 1.1\002"
