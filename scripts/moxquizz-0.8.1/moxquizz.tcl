##
### moxquizz.tcl -- quizzbot for eggdrop 1.6.9+
##
### Author: Moxon <moxon@meta-x.de> (AKA Sascha Lüdecke)
##
### Credits:
##       - Artwork was done with heavy support of Michee <Michee@sonnet.de>
##       - Julika loved to discuss and suggested many things.
##       - Imran Ghory provided more than 600 english questions.
##       - Questions have been edited by Michee, Julika, Tobac, Imran and
##         Klinikai_Eset
##       - ManInBlack for supplemental scripting
##       - numerous others, see the README for a more complete list.
##         If you are missing, please tell me!
##
### Copyright (C) 2000 Moxon AKA Sascha Lüdecke
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program; if not, write to the Free Software
##  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
##
###
## $Id: moxquizz.tcl,v 1.175 2002/07/05 19:21:26 chat Exp $

## Version:
set version_moxquizz "0.8.1"

package require msgcat

namespace import -force msgcat::*

###########################################################################
##
## ATTENTION:
##
## Defaults for bot configuration.  Don't edit here, edit the file
## moxquizz.rc instead!
##
###########################################################################


# system stuff
variable quizbasedir        moxquizz
variable datadir            $quizbasedir/quizdata
variable configfile         $quizbasedir/moxquizz.rc
variable intldir            $quizbasedir/intl

variable rankfile           $datadir/rank.data
variable allstarsfile       $datadir/rankallstars.data
variable statsfile          $datadir/stats.data
variable userqfile          $datadir/questions.user.new
variable commentsfile       $datadir/comments.txt

variable quizhelp

# these will be searched in $intldir/$quizconf(language)
variable channeltipfile     channeltips.txt
variable channelrulesfile   channelrules.txt
variable pricesfile         prices.txt
variable helpfile           help.txt


#
# Configuration map
#
variable quizconf

set quizconf(quizchannel)        "#kumiotus"
set quizconf(quizloglevel)       1

# several global numbers
set quizconf(maxranklines)       25
set quizconf(tipcycle)           5
set quizconf(useractivetime)     240
set quizconf(userqbufferlength)  5
set quizconf(winscore)           30
set quizconf(overrunlimit)       15

# timer delays in seconds
set quizconf(askdelay)           15
set quizconf(tipdelay)           30

# safety features and other configs
set quizconf(lastwinner_restriction)  yes
set quizconf(lastwinner_max_games)    2
set quizconf(overrun_protection)      yes
set quizconf(colorize)                yes
set quizconf(monthly_allstars)        yes
set quizconf(channeltips)             yes
set quizconf(pausemoderated)          no
set quizconf(userquestions)           yes
set quizconf(msgwhisper)              no
set quizconf(channelrules)            yes
set quizconf(prices)                  no
set quizconf(stripumlauts)            no
set quizconf(statslog)                yes
set quizconf(aftergameaction)         newgame

set quizconf(language)                en


##
###########################################################################

##
## stuff for the game state
##
# values = stopped, paused, asked, waittoask, halted
variable quizstate "halted"
variable statepaused ""
variable statemoderated ""
variable usergame 0
variable timeasked [unixtime]
variable revoltmax 0
# values = newgame, stop, halt, exit
variable aftergame $quizconf(aftergameaction)
variable channeltips ""
variable channelrules ""
variable prices ""

#
# variables for the ranks and user handling
#
variable timerankreset [unixtime]
variable userlist
variable allstarsarray
variable revoltlist ""
variable lastsolver ""
variable lastsolvercount 0
variable lastwinner ""
variable lastwinnercount 0
variable allstars_starttime 0
variable ignore_for_userquest ""

#
# stuff for the question
#
variable tiplist ""
variable theq
variable qnumber 0
variable qnum_thisgame 0
variable userqnumber 0
variable tipno 0
variable qlist ""
variable qlistorder ""
variable userqlist ""

#
# doesn't fit elsewhere
#
variable whisperprefix "NOTICE"
variable statsfilefd "closed"

##################################################
## bindings

# bot running status
bind dcc P !init moxquiz_init
bind dcc P !aloita moxquiz_stop
bind dcc P !halt moxquiz_halt
bind dcc P !pause moxquiz_pause
bind dcc P !jatka moxquiz_cont
bind dcc P !reset moxquiz_reset
bind dcc m !lopeta moxquiz_exit
bind dcc m !aftergame moxquiz_aftergame

# bot speaking and hopping stuff
bind dcc P !say moxquiz_say
bind dcc P !act moxquiz_action
bind dcc m !allsay moxquiz_say_everywhere
bind dcc m !allact moxquiz_action_everywhere
bind dcc Q !join moxquiz_join
bind dcc Q !part moxquiz_part
bind dcc Q !quizto moxquiz_quizto
bind dcc Q !quizleave moxquiz_quizleave

# commands for the questions
bind dcc P !ratkaise moxquiz_solve
bind dcc P !vihje moxquiz_tip
bind dcc P !skip moxquiz_skipuserquest
bind dcc Q !pisteet moxquiz_set_score

bind dcc m !qsave moxquiz_saveuserquests
bind dcc Q !reload moxquiz_reload


# status and configuration
bind dcc P !status moxquiz_status
bind dcc m !lataa moxquiz_config_load
bind dcc m !tallenna moxquiz_config_save
bind dcc m !aseta moxquiz_config_set

# userquest and other user (public) commands
bind pubm - * moxquiz_pubm
bind pub - !kysy moxquiz_ask
bind pub - !revolt moxquiz_user_revolt

bind msg - !userquest moxquiz_userquest
bind msg - !usercancel moxquiz_usercancel
bind msg - !usertip moxquiz_usertip
bind msg - !usersolve moxquiz_usersolve
bind pub P !nuq moxquiz_userquest_ignore
bind pub P !uq moxquiz_userquest_unignore
bind pub P !listnuq moxquiz_userquest_listignores
bind pub P !clearnuq moxquiz_userquest_clearignores

bind msg - !qhelp moxquiz_help
bind pub - !qhelp moxquiz_pub_help
bind pub - !score moxquiz_pub_score
bind pub - !rank moxquiz_pub_rank
bind pub - !allstars moxquiz_pub_allstars
bind pub - !comment moxquiz_pub_comment
bind dcc - !comment moxquiz_dcc_comment
bind msg - !rules moxquiz_rules
bind pub - !rules moxquiz_pub_rules
bind msg - !version moxquiz_version
bind pub - !version moxquiz_pub_version

# mini funstuff
bind pub - !hi moxquiz_pub_hi
bind ctcp - action moxquiz_purr

# commands to manage players and rank
bind dcc P !allstars moxquiz_allstars
bind dcc m !allstarssend moxquiz_allstars_send
bind dcc m !allstarsload moxquiz_allstars_load
bind dcc P !rank moxquiz_rank
bind dcc Q !rankdelete moxquiz_rank_delete
bind dcc m !rankload moxquiz_rank_load
bind dcc m !ranksave moxquiz_rank_save
bind dcc Q !rankreset moxquiz_rank_reset
bind dcc Q !rankset moxquiz_rank_set


# Some events the bot reacts on
bind nick - * moxquiz_on_nickchanged
bind join - * moxquiz_on_joined
bind mode - "*m" moxquiz_on_moderated
bind evnt - prerehash mx_event
bind evnt - rehash mx_event

## DEBUG
bind dcc n !colors moxquiz_colors

###########################################################################
#
# bot running commands
#
###########################################################################

## reset game
proc moxquiz_reset {handle idx arg} {
    global quizstate
    moxquiz_stop $handle $idx $arg
    moxquiz_rank_reset $handle $idx $arg
    moxquiz_init $handle $idx $arg
}

## initialize
proc moxquiz_init {handle idx arg} {
    global qlist version_moxquizz banner bannerspace quizstate
    global quizconf aftergame

    set quizstate "halted"
    set aftergame $quizconf(aftergameaction)
    if {$quizconf(quizchannel) != ""} {
        mxirc_say $quizconf(quizchannel) [mc "%sHello!  I am a MoxQuizz version %s and ready to squeeze your brain!" "[banner] [botcolor txt]" "[col bold]$version_moxquizz[col bold][botcolor txt]"]
        mxirc_say $quizconf(quizchannel) [mc "%s%d questions in database, just %s!ask%s.  Report bugs and suggestions to moxon@meta-x.de" "[bannerspace] [botcolor txt]" [llength $qlist]  [col bold] "[col bold][botcolor txt]"]
        mx_log "--- Game initialized"
    } else {
        mxirc_dcc $idx "ERROR: quizchannel is set to an empty string, use .!quizto to set one."
    }
    return 1
}

## stop
## stop everything and kill all timers
proc moxquiz_stop {handle idx arg} {
    global quizstate banner bannerspace
    global quizconf
    variable t
    variable prefix [banner]


    ## called directly?
    if {[info level] != 1} {
	set prefix [bannerspace]
    } else {
	set prefix [banner]
    }

    set quizstate "stopped"

    ## kill timers
    foreach t [utimers] {
	if {[lindex $t 1] == "mx_timer_ask" || [lindex $t 1] == "mx_timer_tip"} {
	    killutimer [lindex $t 2]
	}
    }

    mx_log "--- Peli pysäytetty."
    mxirc_say $quizconf(quizchannel) [mc "%s %s pysäytetty." $prefix [botcolor boldtxt]]
    return 1
}


## halt
## halt everything and kill all timers
proc moxquiz_halt {handle idx arg} {
    global quizstate banner bannerspace
    global quizconf

    variable t
    variable prefix [banner]

    ## called directly?
    if {[info level] != 1} {
	set prefix [bannerspace]
    } else {
	set prefix [banner]
    }

    set quizstate "halted"

    ## kill timers
    foreach t [utimers] {
	if {[lindex $t 1] == "mx_timer_ask" || [lindex $t 1] == "mx_timer_tip"} {
	    killutimer [lindex $t 2]
	}
    }

    mx_log "--- Game halted."
    mxirc_say $quizconf(quizchannel) [mc "%s %sTrivia keskeytetty.  Sano !kysy saadaksesi uusia kysymyksiä." $prefix [botcolor boldtxt]]
    return 1
}


## reload questions
proc moxquiz_reload {handle idx arg} {
    global qlist quizconf
    global datadir

    variable alist ""
    variable banks
    variable suffix

    set arg [string trim $arg]
    if {$arg == ""} {
	# get question files
	set alist [glob -nocomplain "$datadir/questions.*"]

	# get suffixes
	foreach file $alist {
	    regexp "^.*\\.(\[^\\.\]+)$" $file foo suffix
	    set banks($suffix) 1
	}

	# report them
	mxirc_dcc $idx "Kysymyspankkeja on saatavilla seuraavasti (nykyinen: $quizconf(questionset)): [lsort [array names banks]]"
    } else {
	if {[mx_read_questions $arg] != 0} {
	    mxirc_dcc $idx "Virhe luettaessa: $arg."
	    mxirc_dcc $idx "[llength $qlist] kysymystä saatavilla."
	} else {
	    mxirc_dcc $idx "Tietokanta ladattu uudestaan, [llength $qlist] kysymystä."
	    set quizconf(questionset) $arg
	}
    }

    return 1
}

## pause
proc moxquiz_pause {handle idx arg} {
    global quizstate statepaused banner timeasked
    global quizconf

    variable qwasopen "."

    if {[regexp "(halted|paused)" $quizstate]} {
	mxirc_dcc $idx "Trivian tila on $quizstate.  Komento ignorattu."
    } else {
	if {$quizstate == "asked"} {
	    foreach t [utimers] {
		if {[lindex $t 1] == "mx_timer_tip"} {
		    killutimer [lindex $t 2]
		}
	    }
	    set qwasopen [mc " after %s." [mx_duration $timeasked]]
	} elseif {$quizstate == "waittoask"} {
	    foreach t [utimers] {
		if {[lindex $t 1] == "mx_timer_ask"} {
		    killutimer [lindex $t 2]
		}
	    }
	}
	set statepaused $quizstate
	set quizstate "paused"
	mx_log "--- Peli pausetettu$qwasopen  Trivian tila oli: $statepaused"
	mxirc_say $quizconf(quizchannel) [mc "%sPeli pysäytetty%s" "[banner] [botcolor boldtxt]" $qwasopen]
    }
    return 1
}


## continue
proc moxquiz_cont {handle idx arg} {
    global quizstate banner bannerspace timeasked
    global theq statepaused usergame statemoderated
    global quizconf

    if {$quizstate != "paused"} {
	mxirc_dcc $idx "Peli ei ole pause-tilassa. Komento ignorattu."
    } else {
	if {$statepaused == "asked"} {
	    if {$usergame == 1} {
		set txt [mc "%sTriviaa jatkettu.  Käyttäjäkysymys on avoinna %s, worth %d point(s):" "[banner] [botcolor boldtxt]" [mx_duration $timeasked] $theq(Score)]
	    } else {
		set txt [mc "%sQuiz continued.  The question open since %s, worth %d point(s):" "[banner] [botcolor boldtxt]" [mx_duration $timeasked] $theq(Score)]
            }
	    mxirc_say $quizconf(quizchannel) $txt
	    mxirc_say $quizconf(quizchannel) "[bannerspace] [botcolor question]$theq(Question)"
	    utimer $quizconf(tipdelay) mx_timer_tip
	} else {
	    mxirc_say $quizconf(quizchannel) [mc "%sQuiz continued.  Since there is no open question, a new one will be asked." "[banner] [botcolor boldtxt]"]
	    utimer 3 mx_timer_ask
	}
	set quizstate $statepaused
	set statepaused ""
	set statemoderated ""
	mx_log "--- Game continued."
    }
    return 1
}

## show module status
proc moxquiz_status {handle idx arg} {
    global quizstate statepaused qlist banner version_moxquizz userlist
    global timeasked uptime
    global usergame userqlist theq qnumber
    global qnum_thisgame aftergame

    global quizconf

    variable askleft 0 rankleft 0 tipleft 0
    variable txt
    variable chansjoined ""

    ## banner and where I am
    set txt "I am [mx_strip_colors [banner]] version $version_moxquizz, up for [mx_duration $uptime]"
    if {$quizconf(quizchannel) == ""} {
	set txt "$txt, not quizzing on any channel."
    } else {
	set txt "$txt, quizzing on channel \"$quizconf(quizchannel)\"."
    }
    mxirc_dcc $idx $txt

    mxirc_dcc $idx "I know the channels [channels]."

    foreach chan [channels] {
	if {[botonchan $chan]} {
	    set chansjoined "$chansjoined $chan"
	}
    }
    if {$chansjoined == ""} {
	set chansjoined " none"
    }
    mxirc_dcc $idx "I currently joined:$chansjoined."

    if {$quizstate == "asked" || $statepaused == "asked"} {
	## Game running?  User game?
	set txt "There is a"
	if {$usergame == 1} {
	    set txt "$txt user"
	}
	set txt "$txt game running."
	if {[mx_userquests_available]} {
	    set txt "$txt  [mx_userquests_available] user quests scheduled."
	} else {
	    set txt "$txt  No user quest is scheduled."
	}
	set txt "$txt  Quiz state is: $quizstate."
	mxirc_dcc $idx $txt

	## Open question?  Quiz state?
	set txt "The"
	if {[info exists theq(Level)]} {
	    set txt "$txt level $theq(Level)"
	}
	set txt "$txt question no. $qnum_thisgame is:"
	if {[info exists theq(Category)]} {
	    set txt "$txt ($theq(Category))"
	}
	mxirc_dcc $idx "$txt \"$theq(Question)\" open for [mx_duration $timeasked], worth $theq(Score) points."
    } else {
	## no open question, no game running
	set txt "There is no question open."
	set txt "$txt  Quiz state is: $quizstate."
	if {[mx_userquests_available]} {
	    set txt "$txt  [mx_userquests_available] user quests scheduled."
	} else {
	    set txt "$txt  No user quest is scheduled."
	}
	mxirc_dcc $idx $txt
    }

    mxirc_dcc $idx "Action after game won: $aftergame"

    foreach t [utimers] {
	if {[lindex $t 1] == "mx_timer_ask"} {
	    set askleft [lindex $t 0]
	}
	if {[lindex $t 1] == "mx_timer_tip"} {
	    set tipleft [lindex $t 0]
	}
    }

    mxirc_dcc $idx "Tipdelay: $quizconf(tipdelay) ($tipleft)  Askdelay: $quizconf(askdelay) ($askleft) Tipcycle: $quizconf(tipcycle)"
    mxirc_dcc $idx "I know about [llength $qlist] normal and [llength $userqlist] user questions.  Question number is $qnumber."
    mxirc_dcc $idx "There are [llength [array names userlist]] known people, winscore is $quizconf(winscore)."
    mxirc_dcc $idx "Game row restriction: $quizconf(lastwinner_restriction), row length: $quizconf(lastwinner_max_games)"
    return 1
}


## exit -- finish da thing and logoff
proc moxquiz_exit {handle idx arg} {
    global rankfile uptime botnick statsfilefd
    global quizconf
    mx_log "--- EXIT requested."
    mxirc_say $quizconf(quizchannel) [mc "%sI am leaving now, after running for %s." "[banner] [botcolor boldtxt]" [mx_duration $uptime]]
    if {$arg != ""} {
	mxirc_say $quizconf(quizchannel) "[bannerspace] $arg"
    }
    # moxquiz_quizleave $handle $idx $arg
    moxquiz_rank_save $handle $idx {}
    moxquiz_saveuserquests $handle $idx "all"
    moxquiz_config_save $handle $idx {}
    if {$statsfilefd != "closed"} { close $statsfilefd }
    mxirc_dcc $idx "$botnick now exits."
    mx_log "--- $botnick exited"
    mx_log "**********************************************************************"

    utimer 10 die
}

## aftergame -- what to do if the game is over (won or desert detection)
proc moxquiz_aftergame {handle idx arg} {
    global aftergame quizstate

    variable thisnext "this"

    if {$quizstate == "stopped" || $quizstate == "halted"} {
	set thisnext "next"
    }

    if {$arg == ""} {
	mxirc_dcc $idx "After $thisnext game I am planning to: \"$aftergame\"."
	mxirc_dcc $idx "Possible values are: exit, halt, stop, newgame."
    } else {
	switch -regexp $arg {
	    "(exit|halt|stop|newgame)" {
		set aftergame $arg
		mxirc_dcc $idx "After $thisnext game I now will: \"$aftergame\"."
	    }
	    default {
		mxirc_dcc $idx "Invalid action.  Chosse from: exit, halt, stop and newgame."
	    }
	}
    }
    return 1
}

####################
# bot control stuff
####################

## echo a text send by /msg
proc moxquiz_say {handle idx arg} {
    global funstuff_enabled botnick
    global quizconf

    variable channel

    set arg [string trim $arg]
    if {[regexp -nocase "^(#\[^ \]+)( +.*)?" $arg foo channel arg]} {
	## check if on channel $channel
	if {[validchan $channel] && ![botonchan $channel]} {
	    mxirc_dcc $idx "Sorry, I'm not on channel \"$channel\"."
	    return
	}
    } else {
	set channel $quizconf(quizchannel)
    }
    set arg [string trim $arg]

    mxirc_say $channel "$arg"
    variable unused "" cmd "" rest ""

    # if it was a fun command, execute it with some delay
    if {$funstuff_enabled &&
    [regexp "^(!\[^ \]+)(( *)(.*))?" $arg unused cmd waste spaces rest] &&
    [llength [bind pub - $cmd]] != 0} {
	if {$rest == ""} {
	    set rest "{}"
	} else {
            set rest "{$rest}"
        }
	eval "[bind pub - $cmd] {$botnick} {} {} {$channel} $rest"
    }
}


## say something on al channels
proc moxquiz_say_everywhere {handle idx arg} {
    if {$arg != ""} {
	mxirc_say_everywhere $arg
    } else {
	mxirc_dcc $idx "What shall I say on every channel?"
    }
}


## act as sent by /msg
proc moxquiz_action {handle idx arg} {
    global quizconf
    variable channel

    set arg [string trim $arg]
    if {[regexp -nocase "^(#\[^ \]+)( +.*)?" $arg foo channel arg]} {
	## check if on channel $channel
	if {[validchan $channel] && ![botonchan $channel]} {
	    mxirc_dc $idx "Sorry, I'm not on channel \"$channel\"."
	    return
	}
    } else {
	set channel $quizconf(quizchannel)
    }
    set arg [string trim $arg]

    mxirc_action $channel "$arg"
}


## say something on al channels
proc moxquiz_action_everywhere {handle idx arg} {
    if {$arg != ""} {
	mxirc_action_everywhere $arg
    } else {
	mxirc_dcc $idx "What shall act like on every channel?"
    }
}


## hop to another channel
proc moxquiz_join {handle idx arg} {
    global quizconf
    if {[regexp -nocase "^(#\[^ \]+)( +.*)?" $arg foo channel arg]} {
	set channel [string tolower $channel]
	if {[validchan $channel] && [botonchan $channel]} {
	    set txt "I am already on $channel."
	    if {$channel == $quizconf(quizchannel)} {
		set txt "$txt  It's the quizchannel."
	    }
	    mxirc_dcc $idx $txt
	} else {
	    channel add $channel
	    channel set $channel -inactive
	    mxirc_dcc $idx "Joined channel $channel."
	}
    } else {
	mxirc_dcc $idx "Please specify channel I shall join. \"$arg\" not recognized."
    }
}


## part an channel
proc moxquiz_part {handle idx arg} {
    global quizconf
    if {[regexp -nocase "^(#\[^ \]+)( +.*)?" $arg foo channel arg]} {
	set channel [string tolower $channel]
	if {[validchan $channel]} {
	    if {$channel == $quizconf(quizchannel)} {
		mxirc_dcc $idx "Cannot leave quizchannel via part.  User !quizleave or !quizto to do this."
	    } else {
		channel set $channel +inactive
		mxirc_dcc $idx "Left channel $channel."
	    }
	} else {
	    mxirc_dcc $idx "I am not on $channel."
	}
    } else {
	mxirc_dcc $idx "Please specify channel I shall part. \"$arg\" not recognized."
    }
}

## quiz to another channel
proc moxquiz_quizto {handle idx arg} {
    global quizconf
    if {[regexp "^#.*" $arg] == 0} {
	mxirc_dcc $idx "$arg not a valid channel."
    } else {
	if {$quizconf(quizchannel) != ""} {
	    # channel set $quizconf(quizchannel) +inactive
	    mxirc_say $quizconf(quizchannel) [mc "Quiz is leaving to %s.  Goodbye!" $arg]
	}
	set quizconf(quizchannel) [string tolower $arg]
	channel add $quizconf(quizchannel)
	channel set $quizconf(quizchannel) -inactive
	mxirc_say $quizconf(quizchannel) [mc "Quiz is now on this channel.  Hello!"]
	mxirc_dcc $idx "quiz to channel $quizconf(quizchannel)."
	mx_log "--- quizto channel $quizconf(quizchannel)"
    }
    return 1
}


## quiz leave a channel
proc moxquiz_quizleave {handle idx arg} {
    global quizconf banner
    if {$arg == ""} {
	mxirc_say $quizconf(quizchannel) [mc "%s Goodbye." [banner]]
    } else {
	mxirc_say $quizconf(quizchannel) "[banner] $arg"
    }
    if {$quizconf(quizchannel) != ""} {
	channel set $quizconf(quizchannel) +inactive
	mx_log "--- quizleave channel $quizconf(quizchannel)"
	mxirc_dcc $idx "quiz left channel $quizconf(quizchannel)"
	set quizconf(quizchannel) ""
    } else {
	mxirc_dcc $idx "I'm not quizzing on any channel."
    }
    return 1
}


###########################################################################
#
# commands for the questions
#
###########################################################################

## something was said. Solution?
proc moxquiz_pubm {nick host handle channel text} {
    global quizstate banner bannerspace
    global timeasked theq aftergame
    global usergame revoltlist
    global lastsolver lastsolvercount
    global lastwinner lastwinnercount
    global botnick
    global userlist channeltips prices
    global quizconf

    variable bestscore 0 lastbestscore 0 lastbest ""
    variable userarray
    variable authorsolved 0 waitforrank 0 gameend 0

    ## only accept chatter on quizchannel
    if {![mx_str_ieq $channel $quizconf(quizchannel)]} {
	return
    }

    ## record that the $nick spoke and create entries for unknown people
    mx_getcreate_userentry $nick $host
    array set userarray $userlist($nick)
    set hostmask $userarray(mask)

    ## not in asking state?
    if {$quizstate != "asked"} {
	return
    }

    # nick has revolted
    if {[lsearch -exact $revoltlist $hostmask] != -1} {
	return
    }

    # tweak umlauts in input
    set text [mx_tweak_umlauts $text]

    if {[regexp -nocase -- $theq(Regexp) $text]} {

        ## ignore games_max in a row winner
        if {[mx_str_ieq [maskhost $host] $lastwinner]
        && $lastwinnercount >= $quizconf(lastwinner_max_games)
        && $quizconf(lastwinner_restriction) == "yes"} {
            mxirc_notc $nick [mc "No, you've won the last %d games." $quizconf(lastwinner_max_games)]
            return
        }

        # nick is author of userquest
        if {([info exists theq(Author)] && [mx_str_ieq $nick $theq(Author)])
        || ([info exists theq(Hostmask)] && [mx_str_ieq [maskhost $host] $theq(Hostmask)])} {
            set authorsolved 1
        }

        ## return if overrunprotection set and limit reached
        if {$quizconf(overrun_protection) == "yes"
            && $userarray(score) == 0
            && [mx_users_in_rank] > 2
            && [mx_overrun_limit_reached]} {
            # [pending] TRANSLATE!
            mxirc_notc $nick [mc "Sorry, overrun protection enabled.  Wait till end of game."]
            return
        }

	## reset quiz state related stuff (and save userquestions)
	mx_answered
	set duration [mx_duration $timeasked]

	# if it wasn't the author
	if {!$authorsolved} {
	    ## save last top score for the test if reset is near (later below)
	    set lastbest [lindex [lsort -command mx_sortrank [array names userlist]] 0]
	    if {$lastbest == ""} {
		set lastbestscore 0
	    } else {
		array set aa $userlist($lastbest)
		set lastbestscore $aa(score)
	    }

	    ## record nick for bonus points
	    if {[mx_str_ieq [maskhost $host] $lastsolver]} {
		incr lastsolvercount
	    } else {
		set lastsolver [maskhost $host]
		set lastsolvercount 1
	    }

	    ## save score (set started time to time of first point)
	    incr userarray(score) $theq(Score)
	    if {$userarray(score) == 1} {
		set userarray(started) [unixtime]
	    }
	    set userlist($nick) [array get userarray]

	    ## tell channel, that the question is solved
	    mx_log "--- solved after $duration by $nick with \"$text\", now $userarray(score) points"
            mx_statslog "solved" [list [unixtime] $nick $duration $userarray(score) $theq(Score)]

	    mxirc_say $channel [mc "%s solved after %s and now has %s<%d>%s points (+%d) on rank %d." "[banner] [botcolor nick]$nick[botcolor txt]" $duration [botcolor nick] $userarray(score) [botcolor txt] $theq(Score) [mx_get_rank_pos $nick]]
	    # remove area of tip generation tags
	    regsub -all "\#(\[^\#\]*\)\#" $theq(Answer) "\\1" answer
	    mxirc_say $channel [mc "%sThe answer was:%s%s" "[bannerspace] [botcolor txt]" "[botcolor norm] [botcolor answer]" $answer]
	    ## honor good games!
	    if {$lastsolvercount == 3} {
		mxirc_say $channel [mc "%sThree in a row!" "[bannerspace] [botcolor txt]"]
		mx_log "--- $nick has three in a row."
                mx_statslog "tiar" [list [unixtime] $nick 3 0]
	    } elseif {$lastsolvercount == 5} {
		mxirc_say $channel [mc "%sCongratulation, five in a row! You receive an extra point." "[bannerspace] [botcolor txt]"]
		mx_log "--- $nick has five in a row.  score++"
                mx_statslog "tiar" [list [unixtime] $nick 5 1]
		moxquiz_rank_set $botnick 0 "$nick +1"
	    } elseif {$lastsolvercount == 10} {
		mxirc_say $channel [mc "%sTen in a row! This is really rare, so you get 3 extra points." "[bannerspace] [botcolor txt]"]
		mx_log "--- $nick has ten in a row.  score += 3"
                mx_statslog "tiar" [list [unixtime] $nick 10 3]
		moxquiz_rank_set $botnick 0 "$nick +3"
	    } elseif {$lastsolvercount == 20} {
		mxirc_say $channel [mc "%sTwenty in a row! This is extremely rare, so you get 5 extra points." "[bannerspace] [botcolor txt]"]
		mx_log "--- $nick has twenty in a row.  score += 5"
                mx_statslog "tiar" [list [unixtime] $nick 20 5]
		moxquiz_rank_set $botnick 0 "$nick +5"
	    }

	    ## rankreset, if above winscore
	    # notify if this comes near
	    set best [lindex [lsort -command mx_sortrank [array names userlist]] 0]
	    if {$best == ""} {
		set bestscore 0
	    } else {
		array set aa $userlist($best)
		set bestscore $aa(score)
	    }

	    set waitforrank 0
	    if {[mx_str_ieq $best $nick] && $bestscore > $lastbestscore} {
		array set aa $userlist($best)
		# tell the end is near
		if {$bestscore >= $quizconf(winscore)} {
                    set price "."

                    if {$quizconf(prices) == "yes"} {
                        set price " [lindex $prices [rand [llength $prices]]]"
                    }

		    mxirc_say $channel [mc "%s%s reaches %d points and wins%s" "[bannerspace] [botcolor txt]" $nick $quizconf(winscore) $price]
		    set now [unixtime]
		    if {[mx_str_ieq [maskhost $host] $lastwinner]} {
			incr lastwinnercount
			if {$lastwinnercount >= $quizconf(lastwinner_max_games)
			&& $quizconf(lastwinner_restriction) == "yes"} {
			    mxirc_say $channel [mc "%s: since you won %d games in a row, you will be ignored for the next game." $nick $quizconf(lastwinner_max_games)]
			}
		    } else {
			set lastwinner [maskhost $host]
			set lastwinnercount 1
		    }
		    # save $nick in allstars table
		    mx_saveallstar $now [expr $now - $aa(started)] $bestscore $nick [maskhost $host]
                    mx_statslog "gamewon" [list $now $nick $bestscore $quizconf(winscore) [expr $now - $aa(started)]]
		    moxquiz_rank $botnick 0 {}
		    moxquiz_rank_reset $botnick {} {}
		    set gameend 1
		    set waitforrank 15
		} elseif {$bestscore == [expr $quizconf(winscore) / 2]} {
		    mxirc_say $channel [mc "%sHalftime.  Game is won at %d points." \
                                        "[bannerspace] [botcolor txt]" $quizconf(winscore)]
		} elseif {$bestscore == [expr $quizconf(winscore) - 10]} {
		    mxirc_say $channel [mc "%s%s has 10 points to go." "[bannerspace] [botcolor txt]" $best]
		} elseif {$bestscore == [expr $quizconf(winscore) - 5]} {
		    mxirc_say $channel [mc "%s%s has 5 points to go." "[bannerspace] [botcolor txt]" $best]
		} elseif {$bestscore >= [expr $quizconf(winscore) - 3]} {
		    mxirc_say $channel [mc "%s%s has %d point(s) to go." \
                                        "[bannerspace] [botcolor txt]" $best [expr $quizconf(winscore) - $bestscore]]
		}

		# show rank at 1/3, 2/3 of and 5 before winscore
		set spitrank 1
		foreach third [list [expr $quizconf(winscore) / 3] [expr 2 * $quizconf(winscore) / 3] [expr $quizconf(winscore) - 5]] {
		    if {$lastbestscore < $third && $bestscore >= $third && $spitrank} {
			moxquiz_rank $botnick 0 {}
			set spitrank 0
			set waitforrank 15
		    }
		}

	    }
	} else {
	    ## tell channel, that the question is solved by author
	    mx_log "--- solved after $duration by $nick with \"$text\" by author"
	    mxirc_say $channel [mc "%s solved own question after %s and gets no points, keeping %s<%d>%s points on rank %d." \
                                "[banner] [botcolor nick]$nick[botcolor txt]" $duration [botcolor nick] $userarray(score) [botcolor txt] [mx_get_rank_pos $nick]]
	    # remove area of tip generation tags
	    regsub -all "\#(\[^\#\]*\)\#" $theq(Answer) "\\1" answer
	    mxirc_say $channel [mc "%sThe answer was:%s%s" "[bannerspace] [botcolor txt]" "[botcolor norm] [botcolor answer]" $answer]
	}

	## Give some occasional tips
	if {$quizconf(channeltips) == "yes" && [rand 30] == 0} {
	    mxirc_say $channel [mc "%sHint: %s" "[bannerspace] [botcolor txt]" [lindex $channeltips [rand [llength $channeltips]]]]
	}

	## check if game has ended and react
	if {!$gameend || $aftergame == "newgame"} {
	    # set up ask timer
	    utimer [expr $waitforrank + $quizconf(askdelay)] mx_timer_ask
	} else {
	    mx_aftergameaction
	}
    }
}


## Tool function to get the question introduction text
proc mx_get_qtext {complete} {
    global theq qnum_thisgame timeasked usergame

    set qtext [list "The question no. %d is" \
               "The question no. %d is worth %d points" \
               "The question no. %d by %s is" \
               "The question no. %d by %s is worth %d points" \
               "The user question no. %d is" \
               "The user question no. %d is worth %d points" \
               "The user question no. %d by %s is" \
               "The user question no. %d by %s is worth %d points" \
               "The level %s question no. %d is" \
               "The level %s question no. %d is worth %d points" \
               "The level %s question no. %d by %s is" \
               "The level %s question no. %d by %s is worth %d points" \
               "The level %s user question no. %d is" \
               "The level %s user question no. %d is worth %d points" \
               "The level %s user question no. %d by %s is" \
               "The level %s user question no. %d by %s is worth %d points" ]


    ## game runs, tell user the question via msg
    set qtextnum 0
    set txt [list $qnum_thisgame]

    if {[info exists theq(Level)]} {
        incr qtextnum 8
        set txt [linsert $txt 0 $theq(Level)]
    }

    if {$usergame == 1} { incr qtextnum 4 }

    if {[info exists theq(Author)]} {
        incr qtextnum 2
        lappend txt $theq(Author)
    }

    if {$theq(Score) > 1} {
        incr qtextnum 1
        lappend txt $theq(Score)
    }

    set txt [linsert $txt 0 mc [lindex $qtext $qtextnum]]
    set txt [eval $txt]

    if {$complete == "long"} {
        set txt [mc "%s, open for %s:" $txt [mx_duration $timeasked]]
        if {[info exists theq(Category)]} {
            set txt "$txt \($theq(Category)\)"
        }
        set txt "$txt $theq(Question)"
    } else {
        set txt "$txt:"
    }

    #return [eval $txt]
    return "[banner] [botcolor boldtxt]$txt"
}

## ask a question, start game
proc moxquiz_ask {nick host handle channel arg} {
    global qlist quizstate botnick banner bannerspace
    global tipno tiplist
    global userqnumber usergame userqlist
    global timeasked qnumber theq
    global qnum_thisgame
    global userlist timerankreset
    global quizconf
    variable anum 0
    variable txt

    ## only accept chatter on quizchannel
    if {![mx_str_ieq $channel $quizconf(quizchannel)]} {
	return
    }

    switch -exact $quizstate {
	"paused" {
	    mxirc_notc $nick [mc "Game is paused."]
	    return 1
	}
	"stopped" {
	    mxirc_notc $nick [mc "Game is stopped."]
	    return 1
	}
    }

    ## record that $nick spoke (prevents desert detection from stopping,
    ## when an user joins and starts the game with !ask)
    if {![mx_str_ieq $nick $botnick]} {
	mx_getcreate_userentry $nick $host
    }

    ## any questions available?
    if {[llength $qlist] == 0 && [mx_userquests_available] == 0} {
	mxirc_say $channel [mc "%sSorry, my database is empty." "[banner] [botcolor boldtxt]"]
    } elseif {$quizstate == "asked"} {
        mxirc_notc $nick [mx_get_qtext "long"]
    } elseif {$quizstate == "waittoask" && ![mx_str_ieq $nick $botnick]} {
	## no, user has to be patient
	mxirc_notc $nick [mc "Please stand by, the next question comes in less than %d seconds." $quizconf(askdelay)]
    } else {
	##
	## ok, now lets see, which question to ask (normal or user)
	##

	## clear old question
	foreach k [array names theq] {
	    unset theq($k)
	}

	if {[mx_userquests_available]} {
	    ## select a user question
	    array set theq [lindex $userqlist $userqnumber]
	    set usergame 1
	    incr userqnumber
	    mx_log "--- asking a user question: $theq(Question)"
	} else {
	    variable ok 0
	    while {!$ok} {
		array set theq [lindex $qlist [mx_next_qnumber]]
		set usergame 0

		# skip question if author is about to win
		if {[info exists theq(Author)] && [info exists userlist($theq(Author))]} {
		    array set auser $userlist($theq(Author))
		    if {$auser(score) >= [expr $quizconf(winscore) - 5]} {
			mx_log "--- skipping question number $qnumber, author is about to win"
			## clear old question
			foreach k [array names theq] {
			    unset theq($k)
			}
		    } else {
			mx_log "--- asking question number $qnumber: $theq(Question)"
			set ok 1
		    }
		} else {
		    mx_log "--- asking question number $qnumber: $theq(Question)"
		    set ok 1
		}
		incr qnumber
	    }
	}
	incr qnum_thisgame
	if {$qnum_thisgame == 1} {
	    set timerankreset [unixtime]
	    mx_log "---- it's the no. $qnum_thisgame in this game, rank timer started at: [unixtime]"
            mx_statslog "gamestart" [list $timerankreset]
	} else {
	    mx_log "---- it's the no. $qnum_thisgame in this game."
	}

	##
	## ok, set some minimal required fields like score, regexp and the tiplist.
	##

	## set regexp to match
	if {![info exists theq(Regexp)]} {
	    ## mask all regexp special chars except "."
	    set aexp [mx_tweak_umlauts $theq(Answer)]
	    regsub -all "(\\+|\\?|\\*|\\^|\\$|\\(|\\)|\\\[|\\\]|\\||\\\\)" $aexp "\\\\\\1" aexp
	    # get #...# area tags for tipgeneration as regexp
	    regsub -all ".*\#(\[^\#\]*\)\#.*" $aexp "\\1" aexp
	    set theq(Regexp) $aexp
	} else {
	    set theq(Regexp) [mx_tweak_umlauts $theq(Regexp)]
	}

	# protect embedded numbers
	if {[regexp "\[0-9\]+" $theq(Regexp)]} {
	    set newexp ""
	    set oldexp $theq(Regexp)
	    set theq(Oldexp) $oldexp

	    while {[regexp -indices "(\[0-9\]+)" $oldexp pair]} {
		set subexp [string range $oldexp [lindex $pair 0]  [lindex $pair 1]]
		set newexp "${newexp}[string range $oldexp -1 [expr [lindex $pair 0] - 1]]"
		if {[regexp -- $theq(Regexp) $subexp]} {
		    set newexp "${newexp}(^|\[^0-9\])${subexp}(\$|\[^0-9\])"
		} else {
		    set newexp "${newexp}${subexp}"
		}
		set oldexp "[string range $oldexp [expr [lindex $pair 1] + 1] [string length $oldexp]]"
	    }
	    set newexp "${newexp}${oldexp}"
	    set theq(Regexp) $newexp
	    #mx_log "---- replaced regexp '$theq(Oldexp)' with '$newexp' to protect numbers."
	}

	## set score
	if {![info exists theq(Score)]} {
	    set theq(Score) 1
	}

        ## obfs question (answer script stopper)
        # [pending] done elsewhere
        ##set theq(Question) [mx_obfs $theq(Question)]

	## set category
	## set anum [lsearch -exact $alist "Category"]
	## if {![info exists theq(Category)} {
	##    set theq(Category) "unknown"
	##}

	## initialize tiplist
	set anum 0
	set tiplist ""
	while {[info exists theq(Tip$anum)]} {
	    lappend tiplist $theq(Tip$anum)
	    incr anum
	}
	# No tips found?  construct standard list
	if {$anum == 0} {
	    set add "·"

	    # extract area of tip generation tags (side effect sets answer)
	    if {![regsub -all ".*\#(\[^\#\]*\)\#.*" $theq(Answer) "\\1" answer]} {
		set answer $theq(Answer)
	    }

	    ## use tipcycle from questions or
	    ## generate less tips if all words shorter than $tipcycle
	    if {[info exists theq(Tipcycle)]} {
		set limit $theq(Tipcycle)
	    } else {
		set limit $quizconf(tipcycle)
		## check if at least one word long enough
		set tmplist [lsort -command mx_cmp_length -decreasing [split $answer " "]]
		# not a big word
		if {[string length [lindex $tmplist 0]] < $quizconf(tipcycle)} {
		    set limit [string length [lindex $tmplist 0]]
		}
	    }

	    for {set anum 0} {$anum < $limit} {incr anum} {
		set tiptext ""
		set letterno 0
		for {set i 0} {$i < [string length $answer]} {incr i} {
		    if {([expr [expr $letterno - $anum] % $quizconf(tipcycle)] == 0) ||
		    ([regexp "\[- \.,`'\"\]" [string range $answer $i $i] foo])} {
			set tiptext "$tiptext[string range $answer $i $i]"
			if {[regexp "\[- \.,`'\"\]" [string range $answer $i $i] foo]} {
			    set letterno -1
			}
		    } else {
			set tiptext "$tiptext$add"
		    }
		    incr letterno
		}
		lappend tiplist $tiptext
	    }

            # reverse tips for numeric questions
            if {[regexp "^\[0-9\]+$" $answer]} {
                set foo ""
                for {set i [expr [llength $tiplist] - 1]} {$i >= 0} {set i [expr $i - 1]} {
                    lappend foo [lindex $tiplist $i]
                }
                set tiplist $foo
            }
	}

	##
	## Now print question header and question
	##

	mxirc_say $channel [mx_get_qtext "short"]

	set txt "[bannerspace] [botcolor question]"
	if {[info exists theq(Category)]} {
	    set txt "$txt\($theq(Category)\) $theq(Question)"
	} else {
	    set txt "$txt$theq(Question)"
	}
	mxirc_say $channel $txt

	set quizstate "asked"
	set tipno 0
	set timeasked [unixtime]
	## set up tip timer
	utimer $quizconf(tipdelay) mx_timer_tip
    }
}


## A user dislikes the question
proc moxquiz_user_revolt {nick host handle channel text} {
    global revoltlist revoltmax tipno botnick quizstate
    global userlist
    global quizconf

    ## only accept revolts on the quizchannel
    if {![mx_str_ieq $channel $quizconf(quizchannel)]} {
	return
    }

    if {$quizstate == "asked"} {
	if {$tipno < 1} {
	    mxirc_action $channel [mc "does not react on revolts before at least one tip was given."]
	    return
	}

	## ensure that the revolting user has an entry
	if {![info exists userlist($nick)]} {
	    mx_getcreate_userentry $nick $host
	}

	## calculate people needed to make a revolution (50% of active users)
	mx_log "--- a game runs, !revolt.  revoltmax = $revoltmax"
	if {$revoltmax == 0} {
	    set now [unixtime]
	    foreach u [array names userlist] {
		array set afoo $userlist($u)
		if {[expr $now - $afoo(lastspoken)] <= $quizconf(useractivetime)} {
		    incr revoltmax
		}
	    }
	    mx_log "---- active people are $revoltmax"
	    # one and two player shoud revolt "both"
	    if {$revoltmax > 2} {
		set revoltmax [expr int(ceil(double($revoltmax) / 2))]
	    }
	    mx_log "---- people needed for a successful revolution: $revoltmax"
	}

	# records known users dislike
	if {[info exists userlist($nick)]} {
	    array set anarray $userlist($nick)
	    set hostmask $anarray(mask)
	    if {[lsearch -exact $revoltlist $hostmask] == -1} {
		mxirc_quick_notc $nick [mc "Since you are revolting, you will be ignored for this question."]
		mxirc_action $channel [mc "sees that %s and %d other dislike the question, you need %d people." \
                                       $nick [llength $revoltlist] $revoltmax]
		lappend revoltlist $hostmask
		set anarray(lastspoken) [unixtime]
		set userlist($nick) [array get anarray]
		mx_log "--- $nick is revolting, revoltmax is $revoltmax"
                mx_statslog "revolt" [list [unixtime] $nick [llength $revoltlist] $revoltmax]
	    }
	}
	if {[llength $revoltlist] >= $revoltmax} {
	    set revoltmax 0
	    mx_log "--- solution forced by revolting."
            mx_statslog "revoltsolve" [list [unixtime] $revoltmax]
	    mxirc_action $channel [mc "will solve the question immediately."]
	    moxquiz_solve $botnick 0 {}
	}
    }
}


## solve question
proc moxquiz_solve {handle idx arg} {
    global quizstate theq banner bannerspace
    global botnick lastsolvercount lastsolver timeasked
    global quizconf

    variable txt
    variable answer
    if {$quizstate != "asked"} {
	mxirc_dcc $idx "There is no open question."
    } else {
	mx_answered
	set lastsolver ""
	set lastsolvercount 0

	if {[mx_str_ieq $botnick $handle]} {
	    set txt [mc "%sAutomatically solved after %s." \
                     "[banner] [botcolor boldtxt]" [mx_duration $timeasked]]
	} else {
	    set txt [mc "%sManually solved after %s by %s" \
                     "[banner] [botcolor boldtxt]" [mx_duration $timeasked] $handle]
	}
	mxirc_say $quizconf(quizchannel) $txt

	# remove area of tip generation tags
	regsub -all "\#(\[^\#\]*\)\#" $theq(Answer) "\\1" answer
	mxirc_say $quizconf(quizchannel) [mc "%sThe answer is:%s%s" \
                                          "[bannerspace] [botcolor txt]" "[botcolor norm] [botcolor answer]" $answer]

	# remove protection of numbers from regexp
	if {[info exists theq(Oldexp)]} {
	    set theexp $theq(Oldexp)
	} else {
	    set theexp $theq(Regexp)
	}

	if {$answer != $theexp} {
	    mxirc_say $quizconf(quizchannel) [mc "%sAnd should match:%s%s" \
                                              "[bannerspace] [botcolor txt]" "[botcolor norm] [botcolor answer]" $theexp]
	}

	mx_log "--- solved by $handle manually."
	# schedule ask
	utimer $quizconf(askdelay) mx_timer_ask
    }
    return 1
}


## show a tip
proc moxquiz_tip {handle idx arg} {
    global tipno quizstate banner bannerspace
    global botnick tiplist
    global quizconf

    if {$quizstate == "asked"} {
	if {$arg != ""} {
	    mxirc_dcc $idx "Extra tip \'$arg\' will be given."
	    set tiplist [linsert $tiplist $tipno $arg]
	}
	if {$tipno == [llength $tiplist]} {
	    # enough tips, solve!
	    set tipno 0
	    moxquiz_solve $botnick 0 {}
	} else {
	    set tiptext [lindex $tiplist $tipno]
	    mxirc_say $quizconf(quizchannel) [mc "%sHint %d:" "[banner] [botcolor boldtxt]" [expr $tipno + 1]]
	    mxirc_say $quizconf(quizchannel) "[bannerspace] [botcolor tip]$tiptext"
	    foreach j [utimers] {
		if {[lindex $j 1] == "mx_timer_tip"} {
		    killutimer [lindex $j 2]
		}
	    }
	    mx_log "----- Tip number $tipno: $tiptext"
	    # only short delay after last tip
	    incr tipno
	    if {$tipno == [llength $tiplist]} {
		utimer 15 mx_timer_tip
	    } else {
		utimer $quizconf(tipdelay) mx_timer_tip
	    }
	}
    } else {
	mxirc_dcc $idx "Sorry, no question is open."
    }
    return 1
}


## schedule a userquest
proc moxquiz_userquest {nick host handle arg} {
    global userqlist ignore_for_userquest
    global quizconf usebadwords badwords
    variable uanswer "" uquestion "" umatch ""
    variable tmptext ""

    if {$quizconf(userquestions) == "no"} {
	mxirc_notc $nick [mc "Sorry, userquestions are disabled."]
	return
    }

    if {[lsearch $ignore_for_userquest [string tolower $nick]] != -1 || [lsearch $ignore_for_userquest [maskhost $host]] != -1} {
        mxirc_notc $nick "Sorry, you are not allowed to post userquestions at this time."
        return
    }

    if {![onchan $nick $quizconf(quizchannel)]} {
	mxirc_notc $nick [mc "Sorry, you MUST be in the quizchannel to ask questions."]
    } else {
	if {[mx_userquests_available] >= $quizconf(userqbufferlength)} {
	    mxirc_notc $nick [mc "Sorry, there are already %d user questions scheduled.  Try again later." $quizconf(userqbufferlength)]
	} elseif {[info exists usebadwords] && $usebadwords && [regexp -nocase "([join $badwords, "|"])" $arg]} {
            mxirc_notc $nick [mc "Sorry, your userquest would trigger the badwords detection and will not be asked."]
        } else {
	    set arg [mx_strip_colors $arg]
            if {$quizconf(stripumlauts) == "yes"} {
                set arg [mx_tweak_umlauts $arg]
            }
	    if {[regexp "^(.+)::(.+)::(.+)$" $arg foo uquestion uanswer umatch] || \
		    [regexp "(.+)::(.+)" $arg foo uquestion uanswer]} {
		set uquestion [string trim $uquestion]
		set uanswer [string trim $uanswer]
		set alist [list "Question" "$uquestion" "Answer" "$uanswer" "Author" "$nick" "Date" [ctime [unixtime]] "TipGiven" "no"]
		if {$umatch != ""} {
		    set umatch [string trim $umatch]
		    lappend alist "Regexp" "$umatch"
		    set tmptext [mc " (regexp \"%s\")" $umatch]
		}
		lappend userqlist $alist

		mxirc_notc $nick [mc "Your quest \"%s\" is scheduled with answer \"%s\"%s and will be asked after %d questions." \
                                  $uquestion $uanswer $tmptext [expr [mx_userquests_available] - 1]]
		mx_log "--- Userquest scheduled by $nick: \"$uquestion\"."
	    } else {
		mxirc_notc $nick [mc "Wrong number of parameters.  Use alike <question>::<answer>::<regexp>.  The regexp is optional and used with care."]
		mxirc_notc $nick [mc "You said: \"%s\".  I recognize this as: \"%s\" and \"%s\", regexp: \"%s\"." \
                                  $arg $uquestion $uanswer $umatch]
		mx_log "--- userquest from $nick failed with: \"$arg\""
	    }
	}
    }
    return
}


## usertip
proc moxquiz_usertip {nick host handle arg} {
    global quizstate usergame theq
    global quizconf

    if {[onchan $nick $quizconf(quizchannel)]} {
	mx_log "--- Usertip requested by $nick: \"$arg\"."
	if {$quizstate == "asked" && $usergame == 1} {
	    if {[info exists theq(Author)] && ![mx_str_ieq $nick $theq(Author)]} {
		mxirc_notc $nick [mc "No, only %s can give tips here!" $theq(Author)]
	    } else {
		moxquiz_tip $nick 0 $arg
                if {$arg != ""} {
                    set theq(TipGiven) "yes"
                }
	    }
	} else {
	    mxirc_notc $nick [mc "No usergame running."]
	}
    } else {
	mxirc_notc $nick [mc "Sorry, you MUST be in the quizchannel to give tips."]
    }
    return 1
}


## usersolve
proc moxquiz_usersolve {nick host handle arg} {
    global quizstate usergame theq

    mx_log "--- Usersolve requested by $nick."
    if {$quizstate == "asked" && $usergame == 1} {
	if {[info exists theq(Author)] && ![mx_str_ieq $nick $theq(Author)]} {
	    mxirc_notc $nick [mc "No, only %s can solve this question!" $theq(Author)]
	} else {
	    moxquiz_solve $nick 0 {}
	}
    } else {
	mxirc_notc $nick [mc "No usergame running."]
    }
    return 1
}


bind msg - !adver mx_adver
## advertisement
proc mx_adver {nick host handle arg} {
    global botnick
    global quizconf

    mxirc_say $quizconf(quizchannel) "[banner] $botnick is a MoxQuizz © by Moxon <moxon@meta-x.de>"
    mxirc_say $quizconf(quizchannel) "[bannerspace] and can be downloaded from http://meta-x.de/moxquizz"

    return 0
}


## usercancel
proc moxquiz_usercancel {nick host handle arg} {
    global quizstate usergame theq userqnumber userqlist
    mx_log "--- Usercancel requested by $nick."
    if {$quizstate == "asked" && $usergame == 1} {
	if {[info exists theq(Author)] && ![mx_str_ieq $nick $theq(Author)]} {
	    mxirc_notc $nick [mc "No, only %s can cancel this question!" $theq(Author)]
	} else {
	    mxirc_notc $nick [mc "Your question is canceled and will be solved."]
	    set theq(Comment) "canceled by user"
	    moxquiz_solve "user canceling" 0 {}
	}
    } elseif {[mx_userquests_available]} {
	array set aq [lindex $userqlist $userqnumber]
	if {[mx_str_ieq $aq(Author) $nick]} {
	    mxirc_notc $nick [mc "Your question \"%s\" will be skipped." $aq(Question)]
	    set aq(Comment) "canceled by user"
	    set userqlist [lreplace $userqlist $userqnumber $userqnumber [array get aq]]
	    incr userqnumber
	} else {
	    mxirc_notc $nick [mc "Sorry, the next question is by %s." $aq(Author)]
	}
    } else {
	mxirc_notc $nick [mc "No usergame running."]
    }
    return 1
}




## ignore nick!*@* and *!ident@*.subdomain.domain for userquests for 45 minutes
proc moxquiz_userquest_ignore {nick host handle channel arg} {
    global quizconf ignore_for_userquest

    regsub -all " +" [string trim $arg] " " arg

    variable nicks [split $arg]
    variable n

    for {set pos 0} {$pos < [llength $nicks]} {incr pos} {
        set n [string tolower [lindex $nicks $pos]]
        mxirc_notc $nick "Ignoring userquestions from $n for 45 minutes."
        lappend ignore_for_userquest $n
        if {[onchan $n $quizconf(quizchannel)]} {
            lappend ignore_for_userquest [maskhost [getchanhost $n $quizconf(quizchannel)]]
        } else {
            lappend ignore_for_userquest "-!-@-"
        }

    }
    timer 45 mx_timer_userquest_ignore_expire
    return 1
}

## unignore nick!*@* and *!ident@*.subdomain.domain for userquests for 45 minutes
proc moxquiz_userquest_unignore {nick host handle channel arg} {
    ## replace each [split $arg] and associated hostmask with some impossible values
    global quizconf ignore_for_userquest

    regsub -all " +" [string trim $arg] " " arg

    variable nicks [split $arg]
    variable n

    for {set pos 0} {$pos < [llength $nicks]} {incr pos} {
        set n [string tolower [lindex $nicks $pos]]
        set listpos [lsearch -exact $ignore_for_userquest $n]
        if {$listpos != -1} {
            set ignore_for_userquest [lreplace $ignore_for_userquest $listpos [expr $listpos + 1] "@" "-!-@-"]
            mxirc_notc $nick "User $n removed from ignore list for userquestions."
        } else {
            mxirc_notc $nick "User $n was not in the ignore list for userquestions."
        }
    }
    return 1
}

## lists current names on ignore for userquestions
proc moxquiz_userquest_clearignores {nick host handle channel arg} {
    variable ignore_for_userquest
    for {set pos 0} {$pos < [llength $ignore_for_userquest]} {incr pos 2} {
        set ignore_for_userquest [lreplace $ignore_for_userquest $pos [expr $pos + 1] "@" "-!-@-"]
    }
    mxirc_notc $nick "Cleared ignore list for userquestions."
    return 1
}

## lists current names on ignore for userquestions
proc moxquiz_userquest_listignores {nick host handle channel arg} {
    variable ignore_for_userquest
    variable nicks ""
    for {set pos 0} {$pos < [llength $ignore_for_userquest]} {incr pos 2} {
        if {[lindex $ignore_for_userquest $pos] != "@"} {
            lappend nicks [lindex $ignore_for_userquest $pos]
        }
    }
    if {$nicks != ""} {
        mxirc_notc $nick "Currently ignored for userquestions: $nicks"
    } else {
        mxirc_notc $nick "Currently ignoring nobody for userquestions."
    }
    return 1
}

## removes the first two elements from ignore_for_userquest (nick and mask)
proc mx_timer_userquest_ignore_expire {} {
    global ignore_for_userquest
    set ignore_for_userquest [lreplace $ignore_for_userquest 0 1]
}

## pubm !score to report scores
proc moxquiz_pub_score {nick host handle channel arg} {
    global allstarsarray userlist
    global quizconf

    variable allstarspos
    variable pos 0
    variable target
    variable self 0

    if {![mx_str_ieq $channel $quizconf(quizchannel)]} {
	return 0
    } else {
        set arg [string trim "$arg"]

        if {$arg != "" && $arg != $nick} {
            set target $arg
        } else {
            set target $nick
            set self 1
        }

	# report rank entries
	if {[info exists userlist($target)]} {
	    array set userarray $userlist($target)
	    if {$userarray(score)} {
		# calc position
		set pos [mx_get_rank_pos $target]
                if {$self} {
                    mxirc_notc $nick [mc "You made %d points and are on rank %d in the current game (%d more needed to win)." \
                                          $userarray(score) $pos [expr $quizconf(winscore) - $userarray(score)]]
                } else {
                    mxirc_notc $nick [mc "%s made %d points and is on rank %d in the current game (%d more needed to win)." \
                                          $target $userarray(score) $pos [expr $quizconf(winscore) - $userarray(score)]]
                }
	    } else {
                if {$self} {
                    mxirc_notc $nick [mc "You did not make any points in this game yet."]
                } else {
                    mxirc_notc $nick [mc "%s did not make any points in this game yet." $target]
                }
	    }
	} else {
            if {$self} {
                mxirc_notc $nick [mc "You are not yet listed for the current game."]
            } else {
                mxirc_notc $nick [mc "%s is not yet listed for the current game." $target]
            }
	}

	# report allstars entries
	if {[mx_get_allstars_pos $target]} {
            if {$self} {
                mxirc_notc $nick [mc "You accumulated %5.3f points in the all-stars table and keep position %d after %d games." \
                                      [lindex $allstarsarray($target) 1] [mx_get_allstars_pos $target] [lindex $allstarsarray($target) 0]]
            } else {
                mxirc_notc $nick [mc "%s accumulated %5.3f points in the all-stars table and keep position %d after %d games." \
                                      $target [lindex $allstarsarray($target) 1] [mx_get_allstars_pos $target] [lindex $allstarsarray($target) 0]]
            }
	} else {
            if {$self} {
                mxirc_notc $nick [mc "You have not yet reached the all-stars table."]
            } else {
                mxirc_notc $nick [mc "%s not yet reached the all-stars table." $target]
            }
	}

	return 1
    }
}



## skipuserquest  -- removes a scheduled userquest
proc moxquiz_skipuserquest {handle idx arg} {
    global userqnumber userqlist
    if {[mx_userquests_available]} {
	mxirc_dcc $idx "Skipping the userquest [lindex $userqlist $userqnumber]"
	incr userqnumber
    } else {
	mxirc_dcc $idx "No usergame scheduled."
    }
    return 1
}


## saveuserquest  -- append all asked user questions to $userqfile
proc moxquiz_saveuserquests {handle idx arg} {
    global userqfile userqlist userqnumber
    variable uptonum $userqnumber
    array set aq ""

    if {[llength $userqlist] == 0 || ($userqnumber == 0 && $arg == "")} {
	mxirc_dcc $idx "No user questions to save."
    } else {
	# save all questions?
	if {[string tolower [string trim $arg]] == "all"} {
	    set uptonum [llength $userqlist]
	}

	mx_log "--- Saving userquestions ..."
	if {[file exists $userqfile] && ![file writable $userqfile]} {
	    mxirc_dcc $idx "Cannot save user questions to \"$userqfile\"."
	    mx_log "--- Saving userquestions ... failed."
	} else {
	    set fd [open $userqfile a+]
	    ## assumes, that userqlist is correct!!
	    for {set anum 0} {$anum < $uptonum} {incr anum} {
		set q [lindex $userqlist $anum]
		# clear old values
		foreach val [array names aq] {
		    unset aq($val)
		}
		array set aq $q

		# write some first elements
		foreach n [list "Question" "Answer" "Regexp"] {
		    if {[info exists aq($n)]} {
			puts $fd "$n: $aq($n)"
			unset aq($n)
		    }
		}

		# spit the rest
		foreach n [lsort -dictionary [array names aq]] {
                    if {[regexp "^Tip\[0-9\]" $n]} {
                        if {$aq(TipGiven) == "yes"} {
                            puts $fd "$n: $aq($n)"
                        }
                    } else {
                        puts $fd "$n: $aq($n)"
                    }
		}
		puts $fd ""
	    }
	    close $fd

	    # prune saved and asked questions
	    for {set i 0} {$i < $userqnumber} {incr i} {
		set userqlist [lreplace $userqlist 0 0]
	    }

	    mxirc_dcc $idx "Saved $userqnumber user questions."
	    mx_log "--- Saving userquestions ... done"

	    ## reset userqnumber
	    set userqnumber 0
	}
    }
    return 1
}


## set score of open question
proc moxquiz_set_score {handle idx arg} {
    ## [pending] obeye state!
    global quizstate theq banner
    global quizconf

    mx_log "--- set_score by $handle: $arg"
    if {![regexp {^[0-9]+$} $arg]} {
	mxirc_dcc $idx "$arg not a valid number."
    } elseif {$arg == $theq(Score)} {
	mxirc_dcc $idx "New score is same as old score."
    } else {
	mxirc_dcc $idx "Setting score for the question to $arg points ([format "%+d" [expr $arg - $theq(Score)]])."
	mxirc_say $quizconf(quizchannel) [mc "%s Setting score for the question to %d points (%+d)." \
                                          [banner] $arg [expr $arg - $theq(Score)]]
	set theq(Score) $arg
    }
    return 1
}

###########################################################################
#
# Commands for help texts
#
###########################################################################



## pubm help wrapper
proc moxquiz_pub_help {nick host handle channel arg} {
    global quizconf

    if {![mx_str_ieq $channel $quizconf(quizchannel)]} {
	return 0
    } else {
	moxquiz_help $nick $host $handle $arg
	return 1
    }
}


## help
proc moxquiz_help {nick host handle arg} {
    global botnick version_moxquizz
    global quizconf quizhelp
    global funstuff_enabled

    variable lines
    variable help
    variable topics [lsort [array names quizhelp]]

    set itmp [lsearch -exact $topics "idx"]
    set topics [lreplace $topics $itmp $itmp]

    set arg [string tolower [string trim $arg]]

    # choose help text
    mx_log "--- help requested by $nick about '$arg'."

    if {[array size quizhelp] == 0} {
        set lines [list [mc "Sorry, there is no help text loaded for the quiz."]]
    } else {

        # elide some help text based on configuration
        if {$quizconf(userquestions) == "no"} {
            set index [lsearch $topics "userquestions"]
            set topics [lreplace $topics $index $index]
        }

        if {![info exists funstuff_enabled] || $funstuff_enabled != 1} {
            set index [lsearch $topics "fun"]
            set topics [lreplace $topics $index $index]
        }


        # select help text
        if {$arg == "" || $arg == "idx"} {
            set lines $quizhelp(idx)
            set ltmp ""
            for {set i 0} {$i < [llength $lines]} {incr i} {
                lappend ltmp [format [lindex $lines $i] $topics]
            }
            set lines $ltmp
        } else {
            if {[lsearch $topics $arg] != -1} {
                set lines $quizhelp($arg)
            } else {
                set lines [list [mc "Can't help you about '%s'.  Choose a topic from: %s" $arg $topics]]
            }
        }
    }

    # dump help
    mxirc_notc $nick [mc "%s Help for %s version %s" [banner] $botnick $version_moxquizz]
    foreach line $lines {
	mxirc_notc $nick $line
    }

    return 1
}


proc mx_read_help {helpfile} {
    global quizhelp

    variable key ""
    variable values ""

    foreach k [array names quizhelp] {
        unset quizhelp($k)
    }

    mx_log "--- Reading help texts from $helpfile"

    if {[file exists $helpfile]} {
        set fd [open $helpfile r]
        while {![eof $fd]} {
            set line [gets $fd]
            switch -regexp $line {
                "^(#.*|[ \t]*)$" { # ignore it
                }
                "^\\[.+\\]" {
                    if {$key != ""} {
                        set quizhelp($key) $values
                    }
                    regexp "^\\\[(.+)\\\]" $line foo key
                    set values ""
                }
                default {
                    lappend values $line
                }
            }
        }
        # save last entry
        set quizhelp($key) $values
        close $fd
        mx_log "--- Sucessfully read [array size quizhelp] help entries."
    } else {
        mx_log "--- ERROR:  $helpfile not found, no help will be available to users."
    }
}


###########################################################################
#
# commands to manage the rankings
#
###########################################################################

## read ranks from $rankfile
proc moxquiz_rank_load {handle idx arg} {
    global rankfile userlist timerankreset
    global lastsolver lastsolvercount qnum_thisgame
    global quizconf
    variable timeranksaved [unixtime]
    variable fd
    variable line
    variable us 0 sc 0 mask ""

    ## clear old userlist (ranks)
    foreach u [array names userlist] {
	unset userlist($u)
    }

    ## load saved scores
    if {[file exists $rankfile] && [file readable $rankfile]} {
	set fd [open $rankfile r]
	while {![eof $fd]} {
	    set line [gets $fd]
	    if {![regexp "#.*" $line]} {
		switch -regexp $line {
		    "^winscore: .+ *$" {
			scan $line "winscore: %d" quizconf(winscore)
		    }
		    "^rankreset: +[0-9]+ *$" {
			scan $line "rankreset: %d" timerankreset
		    }
		    "^lastsolver:" {
			scan $line "lastsolver: %s = %d" lastsolver lastsolvercount
		    }
		    "^ranksave:" {
			scan $line "ranksave: %d" timeranksaved
		    }
		    "^qnumber:" {
			scan $line "qnumber: %d" qnum_thisgame
		    }
		    default {
			scan $line "%d %d : %s at %s" started sc us mask
			set alist [list "mask" $mask "score" $sc "lastspoken" 0 "started" [expr $started + [unixtime] - $timeranksaved]]
			set userlist($us) $alist
		    }
		}
	    }
	}
	close $fd
	mxirc_dcc $idx "Ranks loaded ([llength [array names userlist]]), winscore = $quizconf(winscore), saved at unixtime $timeranksaved."
	mx_log "--- Ranks loaded ([llength [array names userlist]]), winscore = $quizconf(winscore), saved at unixtime $timeranksaved."
    } else {
	mxirc_dcc $idx "Could not read \"$rankfile\"."
	mx_log "---- could not read \"$rankfile\"."
    }
    return 1
}


## save ranks to $rankfile
proc moxquiz_rank_save {handle idx arg} {
    global rankfile userlist
    global lastsolver lastsolvercount timerankreset
    global qnum_thisgame
    global quizconf
    variable fd

    ## save ranks
    if {[llength [array names userlist]] > 0} {
	set fd [open $rankfile w]
	puts $fd "# rankings from $quizconf(quizchannel) at [ctime [unixtime]]."
	puts $fd "winscore: $quizconf(winscore)"
	puts $fd "rankreset: $timerankreset"
	puts $fd "ranksave: [unixtime]"
	puts $fd "qnumber: $qnum_thisgame"
	if {$lastsolver != ""} {
	    puts $fd "lastsolver: $lastsolver = $lastsolvercount"
	}
	foreach u [lsort -command mx_sortrank [array names userlist]] {
	    array set aa $userlist($u)
	    puts $fd [format "%d %d : %s at %s" $aa(started) $aa(score) $u $aa(mask)]
	}
	close $fd
	mx_log "--- Ranks saved to \"$rankfile\"."
	mxirc_dcc $idx "Ranks saved to \"$rankfile\"."
    } else {
	mxirc_dcc $idx "Ranks are empty, nothing saved."
    }
    return 1
}

## set score of a player
proc moxquiz_rank_set {handle idx arg} {
    global userlist botnick
    global quizconf
    variable list
    variable user "" newscore 0 oldscore 0
    variable prefix [banner]

    ## called directly?
    if {[info level] != 1} {
	set prefix [bannerspace]
    }

    mx_log "--- rankset requested by $handle: $arg"
    mx_statslog "rankset" [list [unixtime] $handle $arg]

    set list [split $arg]
    for {set i 0} {$i < [llength $list]} {incr i 2} {
	set user [lindex $list $i]
	set newscore [lindex $list [expr 1 + $i]]
	if {($newscore == "") || ($user == "")} {
	    mxirc_dcc $idx "Wrong number of parameters.  Cannot set \"$user\" to \"$newscore\"."
	} elseif {[regexp {^[\+\-]?[0-9]+$} $newscore] == 0} {
	    mxirc_dcc $idx "$newscore is not a number.  Ignoring set for $user."
	} else {
	    if {![info exists userlist($user)]} {
		if {[onchan $user $quizconf(quizchannel)]} {
		    mx_getcreate_userentry $user [getchanhost $user $quizconf(quizchannel)]
		} else {
		    mxirc_dcc $idx "Could not set rank for $user.  Not in list nor in quizchannel."
		    continue
		}
	    }
	    array set aa $userlist($user)
	    set oldscore $aa(score)
	    if {[regexp {^[\+\-][0-9]+$} $newscore]} {
		set newscore [expr $oldscore + $newscore]
		if {$newscore < 0} {
		    mxirc_dcc $idx "You set the score of $user to $newscore.  Will be corrected to 0."
		    set newscore 0
		}
	    }
	    set aa(score) $newscore
	    set userlist($user) [array get aa]
	    ## did we change something?
	    if {[expr $newscore - $oldscore] != 0} {
		set txt [mc "%s %s has new score %s<%d>%s (%+d) on rank %d." \
                         $prefix "[botcolor nick]$user[botcolor boldtxt]" "[col bold][botcolor nick]" \
                         $newscore [botcolor boldtxt] [expr $newscore - $oldscore] [mx_get_rank_pos $user]]
		set prefix [bannerspace]
		if {![mx_str_ieq $handle $botnick] && [hand2nick $handle] != ""} {
		    set txt [mc "%s  Set by %s." $txt [hand2nick $handle]]
		}
		mxirc_say $quizconf(quizchannel) $txt
	    }

	    mxirc_dcc $idx "$user has new score $newscore ([format "%+d" [expr $newscore - $oldscore]]) on rank [mx_get_rank_pos $user]."
	}
    }
    return 1
}


## delete a player from rank
proc moxquiz_rank_delete {handle idx arg} {
    global userlist

    mx_log "--- rank delete requested by $handle: $arg"

    if {$arg == ""} {
	mxirc_dcc $idx "Tell me whom to delete."
    } else {
	foreach u [split $arg " "] {
	    if {[info exists userlist($u)]} {
		array set aa $userlist($u)
		mxirc_dcc $idx "Nick $u removed from ranks.  Score was $aa(score) points."
		unset userlist($u)
	    } else {
		mxirc_dcc $idx "Nick $u not in ranks."
	    }
	}
    }
    return 1
}


## list ranks by notice to a user
proc moxquiz_pub_rank {nick host handle channel arg} {
    set arg [string trim $arg]
    if {$arg == ""} {
	set arg 10
    } elseif {![regexp "^\[0-9\]+$" $arg]} {
	mxirc_notc $nick [mc "Sorry, \"%s\" is not an acccepted number." $arg]
	return
    }
    mx_spit_rank "NOTC" $nick $arg
}

## show rankings
proc moxquiz_rank {handle idx arg} {
    global quizconf

    set arg [string trim $arg]
    if {$arg == ""} {
	set arg 5
    } elseif {![regexp "^\[0-9\]+$" $arg]} {
	mxirc_dcc $idx "Sorry, \"$arg\" is not an acccepted number."
    }
    mx_spit_rank "CHANNEL" $quizconf(quizchannel) $arg
}

## function to show the rank to a nick or channel
proc mx_spit_rank {how where length} {
    global timerankreset
    global userlist
    global quizconf
    variable pos 1
    variable prevscore 0
    variable entries 0
    variable lines ""

    # anybody with a point?
    foreach u [array names userlist] {
	array set aa $userlist($u)
	if {$aa(score) > 0} {
	    set entries 1
	    break
	}
    }

    # build list
    if {$entries == 0} {
	lappend lines [mc "%sRank list is empty." "[banner] [botcolor highscore]"]
    } else {
	if {$length > $quizconf(maxranklines)} {
	    set length $quizconf(maxranklines)
	    lappend lines [mc "You requested too many lines, limiting to %d." $quizconf(maxranklines)]
	}
	lappend lines [mc "%sCurrent Top %d (game won at %d pts):" \
                       "[banner] [botcolor highscore]" $length $quizconf(winscore)]
	set pos 1
	set prevscore 0
	foreach u [lsort -command mx_sortrank [array names userlist]] {
	    array set aa $userlist($u)
	    if {$aa(score) == 0} { break }
	    if {$pos > $length && $aa(score) != $prevscore} { break }

	    if {$aa(score) == $prevscore} {
		set text "[bannerspace] [botcolor score] = "
	    } else {
		set text [format "[bannerspace] [botcolor score]%2d " $pos]
	    }
	    set text [format "$text[botcolor nickscore]%18s [botcolor score] -- %2d [mc pts]." $u $aa(score)]
	    if {$pos == 1} {
		set text [mc "%s* Congrats! *" "$text[botcolor norm] [botcolor grats]"]
	    }
	    lappend lines $text
	    set prevscore $aa(score)
	    incr pos
	}
	lappend lines [mc "%sRank started %s ago." "[bannerspace] [botcolor txt]" "[mx_duration $timerankreset]"]
    }

    # spit lines
    foreach line $lines {
	if {$how == "NOTC"} {
	    mxirc_notc $where $line
	} else {
	    mxirc_rsay $where $line
	}
    }

    return 1
}


## reset rankings
proc moxquiz_rank_reset {handle idx arg} {
    global timerankreset userlist lastsolver lastsolvercount
    global quizconf qnum_thisgame aftergame rankfile

    ## called directly?
    if {[info level] != 1} {
	set prefix [bannerspace]
    } else {
	set prefix [banner]
    }

    # forget last solver
    set lastsolver ""
    set lastsolvercount 0

    # clear userlist
    foreach u [array names userlist] {
	unset userlist($u)
    }
    set timerankreset [unixtime]
    mxirc_say $quizconf(quizchannel) [mc "%sRanks reset by %s after %d questions." \
                                      "$prefix [botcolor boldtxt]" $handle $qnum_thisgame]
    mxirc_dcc $idx "Ranks are resetted.  Note that the value of aftergame was neither considered nor changed."
    file delete $rankfile
    set qnum_thisgame 0
    mx_log "--- Ranks reset by $handle at [unixtime]."
    return 1
}


## calculate position of nick in the rank table
proc mx_get_rank_pos {nick} {
    global userlist
    variable pos 0
    variable prevscore 0

    if {[llength [array names userlist]] == 0 || \
	![info exists userlist($nick)]} {
	return 0
    }

    # calc position
    foreach name [lsort -command mx_sortrank [array names userlist]] {
	array set afoo $userlist($name)
	if {$afoo(score) != $prevscore} {
	    incr pos
	}

	set prevscore $afoo(score)
	if {[mx_str_ieq $name $nick]} {
	    break
	}
    }
    return $pos
}


## sort routine for the rankings
proc mx_sortrank {a b} {
    global userlist
    array set aa $userlist($a)
    array set bb $userlist($b)
    if {$aa(score) == $bb(score)} {
	return 0
    } elseif {$aa(score) > $bb(score)} {
	return -1
    } else {
	return 1
    }
}


###########################################################################
#
# Commands to handle the allstars list
#
###########################################################################

## send the allstars file
proc moxquiz_allstars_send {handle idx arg} {
    global allstarsfile

    if {[info commands dccsend] == ""} {
	mxirc_dcc $idx "Sorry, module filesys is not loaded, cannot send allstars file."
    } else {
	set result [dccsend $allstarsfile [hand2nick $handle]]
	switch -exact -- $result {
	    0 {
		mxirc_dcc $idx "DCC SEND allstarsfile: will come"
		mx_log  "--- $handle DCC SEND allstarsfile: success"
	    }
	    1 {
		mxirc_dcc $idx "DCC SEND allstarsfile: dcc table full, try again later"
		mx_log  "--- $handle DCC SEND allstarsfile: dcc table full"
	    }
	    2 {
		mxirc_dcc $idx "DCC SEND allstarsfile: can't open socket"
		mx_log  "--- $handle DCC SEND allstarsfile: can't open socket"
	    }
	    3 {
		mxirc_dcc $idx "DCC SEND allstarsfile: file doesn'y exist"
		mx_log  "--- $handle DCC SEND allstarsfile: file doesn'y exist"
	    }
	    4 {
		mxirc_dcc $idx "DCC SEND allstarsfile: queued for later transfer"
		mx_log  "--- $handle DCC SEND allstarsfile: queued for later transfer"
	    }
	}
    }
    return 1
}


## load allstars list
proc moxquiz_allstars_load {handle idx arg} {

    global allstarsarray allstarsfile allstars_starttime
    global quizconf

    variable thismonth 0

    mx_log "--- reading allstars list from $allstarsfile"

    if {$quizconf(monthly_allstars) == "yes"} {
	set thismonth [clock scan [clock format [unixtime] -format "%m/01/%Y"]]
    }

    if {[file exists $allstarsfile] && [file readable $allstarsfile]} {
	# clear old list
	foreach name [array names allstarsarray] {
	    unset allstarsarray($name)
	}
	set allstars_starttime -1

	## read datafile
	set fd [open $allstarsfile r]
	while {![eof $fd]} {
	    set line [gets $fd]
	    if {![regexp "#.*" $line]} {
		if {[scan $line "%d %d : %d %d --  %s %s " time duration sctotal sc us usermask] == 6} {
		    if {$time >= $thismonth} {
			if {$allstars_starttime == -1} {
			    set allstars_starttime $time
			}
			if {[info exists allstarsarray($us)]} {
			    set entry $allstarsarray($us)
			    set allstarsarray($us) [list \
				    [expr [lindex $entry 0] + 1] \
				    [expr [lindex $entry 1] + [mx_allstarpoints $sctotal $sc $duration]] \
				    ]
			} else {
			    set allstarsarray($us) [list \
				    1 \
				    [mx_allstarpoints $sctotal $sc $duration] \
				    ]
			}
		    }
		} else {
		    mx_log "---- allstar line not recognized: \"$line\"."
		}
	    }
	}
	close $fd
	mx_log "---- allstars list successfully read ([llength [array names allstarsarray]] users)."
	mxirc_dcc $idx "Allstars list successfully read ([llength [array names allstarsarray]] users)."
    } else {
	mx_log  "---- could not read \"$allstarsfile\", allstars list set empty."
	mxirc_dcc $idx  "Could not read \"$allstarsfile\", allstars list set empty."
	array set allstarsarray {}
    }
    return 1
}


## list allstars by notice to a user
proc moxquiz_pub_allstars {nick host handle channel arg} {
    set arg [string trim $arg]
    if {$arg == ""} {
	set arg 10
    } elseif {![regexp "^\[0-9\]+$" $arg]} {
	mxirc_notc $nick [mc "Sorry, \"%s\" is not an acccepted number." $arg]
    }
    mx_spit_allstars "NOTC" $nick $arg
}

## show allstars
proc moxquiz_allstars {handle idx arg} {
    global quizconf

    set arg [string trim $arg]
    if {$arg == ""} {
	set arg 5
    } elseif {![regexp "^\[0-9\]+$" $arg]} {
	mxirc_dcc $idx "Sorry, \"$arg\" is not an acccepted number."
	return
    }
    mx_spit_allstars "CHANNEL" $quizconf(quizchannel) $arg
}

## show all-star rankings
proc mx_spit_allstars {how where length} {
    global allstarsarray allstars_starttime
    global quizconf
    variable score
    variable games
    variable numofgames 0
    variable lines ""

    if {[llength [array names allstarsarray]] == 0} {
	lappend lines [mc "%sAllstars list is empty." "[banner] [botcolor boldtxt]"]
    } else {
	# limit num of lines
	if {$length > $quizconf(maxranklines)} {
	    set length $quizconf(maxranklines)
	    lappend lines [mc "Your requested too many lines, limiting to %d." $quizconf(maxranklines)]
	}

	# build table
	set aline "[banner] [botcolor highscore]"
	if {$quizconf(monthly_allstars) == "yes"} {
	    set aline "$aline[clock format $allstars_starttime -format %B] "
	}
	set aline [mc "%sAll-Stars top %d:" $aline $length]
	lappend lines $aline
	set pos 1
	set prevscore 0
	foreach u [lsort -command mx_sortallstars [array names allstarsarray]] {
	    set entry $allstarsarray($u)
	    set games [lindex $entry 0]
	    set score [lindex $entry 1]
	    incr numofgames $games

	    # if {$score == 0} { break }
	    ## continue counting num of games played!!
	    if {$pos > $length && $score != $prevscore} { continue }
	    if {$score == $prevscore} {
		set text "[bannerspace] [botcolor score] = "
	    } else {
		set text [format "[bannerspace] [botcolor score]%2d " $pos]
	    }
	    set text [format "$text[botcolor nickscore]%18s [botcolor score] -- %5.3f [mc pts], %2d [mc games]." $u $score $games]
	    if {$pos == 1} {
		set text [mc "%s* Congrats! *" "$text[botcolor norm] [botcolor grats]"]
	    }
	    lappend lines $text
	    set prevscore $score
	    incr pos
	}
	lappend lines [mc "%sThere were %d users playing %d games." \
                       "[bannerspace] [botcolor boldtxt]" [llength [array names allstarsarray]] $numofgames]
    }

    # spit table
    foreach line $lines {
	if {$how == "NOTC"} {
	    mxirc_notc $where $line
	} else {
	    mxirc_say $where $line
	}
    }

    return 1
}


proc mx_saveallstar {time duration score name mask} {
    global allstarsfile userlist allstarsarray allstars_starttime
    global quizconf botnick
    variable scoretotal 0

    # compute sum of scores in this game
    foreach u [array names userlist] {
	array set afoo $userlist($u)
	incr scoretotal $afoo(score)
    }

    if {$scoretotal == $score} {
	mxirc_action $quizconf(quizchannel) [mc "does not record you in the allstars table, since you played alone."]
	mx_log "--- $name was not saved to allstars since he/she was playing alone."
    } else {
	# save entry
	set fd [open $allstarsfile a]
	puts $fd "$time $duration : $scoretotal $score -- $name $mask"
	close $fd
	if {[info exists allstarsarray($name)]} {
	    set entry $allstarsarray($name)
	    set allstarsarray($name) [list \
		    [expr [lindex $entry 0] + 1] \
		    [expr [lindex $entry 1] + [mx_allstarpoints $scoretotal $score $duration]] \
		    ]
	} else {
	    set allstarsarray($name) [list \
		    1 \
		    [mx_allstarpoints $scoretotal $score $duration] \
		    ]
	}

	# reload allstars table if a new month began
	if {$quizconf(monthly_allstars) == "yes" &&
	$allstars_starttime < [clock scan [clock format [unixtime] -format "%m/01/%Y"]]} {
	    mx_log "--- new month, reloading allstars table"
	    moxquiz_allstars_load $botnick 0 {}
	}

	mxirc_action $quizconf(quizchannel) [mc "records %s with %5.3f points on the all-stars table (now %5.3f points, pos %d)." \
                                             $name [mx_allstarpoints $scoretotal $score $duration] \
                                             [lindex $allstarsarray($name) 1] [mx_get_allstars_pos $name]]
	mx_log "--- saved $name with [mx_allstarpoints $scoretotal $score $duration] points (now [format "%5.3f" [lindex $allstarsarray($name) 1]] points, pos [mx_get_allstars_pos $name]) to the allstars file. Time: $time"
    }
}


## compute position of $nick in allstarsarray
proc mx_get_allstars_pos {nick} {
    global allstarsarray
    variable pos 0
    variable prevscore 0

    if {[llength [array names allstarsarray]] == 0 || \
	![info exists allstarsarray($nick)]} {
	return 0
    }

    # calc position
    foreach name [lsort -command mx_sortallstars [array names allstarsarray]] {
	if {[lindex $allstarsarray($name) 1] != $prevscore} {
	    incr pos
	}

	set prevscore [lindex $allstarsarray($name) 1]
	if {[mx_str_ieq $name $nick]} {
	    break
	}
    }
    return $pos
}


## calculate entry in allstar table
proc mx_allstarpoints {sum score duration} {
    if {$sum == $score} {
	return 0
    } else {
	return [expr (10 * double($sum)) / (log10($score) * $duration)]
    }
}


## sort routine for the allstars
proc mx_sortallstars {a b} {
    global allstarsarray
    variable sca [lindex $allstarsarray($a) 1]
    variable scb [lindex $allstarsarray($b) 1]

    if {$sca == $scb} {
	return 0
    } elseif {$sca > $scb} {
	return -1
    } else {
	return 1
    }
}


###########################################################################
#
# User comment handling
#
###########################################################################

## record a comment
proc moxquiz_pub_comment {nick host handle channel arg} {
    global commentsfile

    set arg [string trim $arg]
    if {$arg != ""} {
	set fd [open $commentsfile a]
	puts $fd "\[[ctime [unixtime]]\] $nick on $channel comments: $arg"
	close $fd

	mxirc_notc $nick [mc "Your comment was logged."]
    } else {
	mxirc_notc $nick [mc "Well, comment something *g*"]
    }
}

## record a comment
proc moxquiz_dcc_comment {handle idx arg} {
    global commentsfile

    set arg [string trim $arg]
    if {$arg != ""} {
	set fd [open $commentsfile a]
	puts $fd "\[[ctime [unixtime]]\] $handle comments: $arg"
	close $fd

	mxirc_dcc $idx "Your comment was logged."
    } else {
	mxirc_dcc $idx "Well, comment something *g*"
    }
}

###########################################################################
#
# Handling of channel tips (regular tips)
#
###########################################################################

## read the list of channeltips
proc mx_read_channeltips {ctipfile} {
    global quizconf channeltips
    variable line ""

    set channeltips ""

    mx_log "--- Reading channeltips from $ctipfile"

    if {$quizconf(channeltips) != "yes"} {
	mx_log "--- Channeltips not read since feature disabled."
    } else {
        if {[file exists $ctipfile]} {
            set fd [open $ctipfile r]
            while {![eof $fd]} {
                set line [gets $fd]
                if {![regexp "^ *$" $line] && ![regexp "^#.*" $line]} {
                    lappend channeltips $line
                }
            }
            close $fd
            mx_log "---- Read [llength $channeltips] channeltips."
        } else {
            mx_log "---- no such file: $ctipfile"
        }
    }

    if {[llength $channeltips] == 0} {
	set quizconf(channeltips) "no"
	mx_log "---- Channeltips disabled since no tips loaded."
    }

    return 1
}

###########################################################################
#
# Handling prices to win
#
###########################################################################

proc mx_read_prices {pricefile} {
    global quizconf prices
    variable line ""

    set prices ""

    mx_log "--- Reading prices from $pricefile"

    if {$quizconf(prices) != "yes"} {
	mx_log "--- Prices not read since feature disabled."
    } else {
        if {[file exists $pricefile]} {
            set fd [open $pricefile r]
            while {![eof $fd]} {
                set line [gets $fd]
                if {![regexp "^ *$" $line] && ![regexp "^#.*" $line]} {
                    lappend prices $line
                }
            }
            close $fd
            mx_log "---- Read [llength $prices] prices."
        } else {
            mx_log "---- no such file: $pricefile"
        }
    }

    if {[llength $prices] == 0} {
	set quizconf(prices) "no"
	mx_log "---- Prices disabled since no prices found."
    }

    return 1
}

###########################################################################
#
# Handling of channel rules
#
###########################################################################

## read rules
proc mx_read_rules {rulesfile} {
    global quizconf channelrules
    variable num 0

    set channelrules ""

    mx_log "--- Loading channel rules from $rulesfile ..."

    if {[file exists $rulesfile]} {
        set fd [open $rulesfile r]
        while {![eof $fd]} {
            gets $fd line

            if {![regexp "^ *#.*$" $line] && ![regexp "^ *$" $line]} {
                lappend channelrules $line
                incr num
            }
        }
        close $fd

        mx_log "---- $num channel rules loaded from $rulesfile"
    } else {
        mx_log "---- no such file: $rulesfile"
    }

    if {$num == 0} {
        set quizconf(channelrules) no
	mx_log "---- Channel rules command disabled, since no rules found."
    }

    return 1
}


## pubm !rules wrapper
proc moxquiz_pub_rules {nick host handle channel arg} {
    global quizconf

    if {![mx_str_ieq $channel $quizconf(quizchannel)]} {
	return 0
    } else {
	moxquiz_rules $nick $host $handle $arg
	return 1
    }
}

## tells a user about the rules
proc moxquiz_rules {nick host handle arg} {
    global quizconf channelrules botnick

    if {$quizconf(channelrules) == "no" || $channelrules == ""} {
	mxirc_notc $nick [mc "No rules loaded.  This doesn't mean there are no rules for this channel.  Beware!"]
	mx_log "WARNING: !rules called by $nick while no rules are loaded."
	return 0
    }


    # dump rules
    mxirc_notc $nick [mc "%s Rules for %s" [banner] $quizconf(quizchannel)]
    foreach line $channelrules {
	mxirc_notc $nick $line
    }

    return 1

}

## pubm !version wrapper
proc moxquiz_pub_version {nick host handle channel arg} {
    global quizconf

    if {![mx_str_ieq $channel $quizconf(quizchannel)]} {
	return 0
    } else {
	moxquiz_version $nick $host $handle $arg
	return 1
    }
}

## tells a user the scritp version
proc moxquiz_version {nick host handle arg} {
    global qlist version_moxquizz
    global quizconf
    variable text

    set text [mc "Welcome to %sversion %s, © by Moxon <moxon@meta-x.de>.  Say \"!ask\" to get the current question or \"!qhelp\" to get an help text." \
              "[banner] [botcolor norm]" $version_moxquizz]

    set text [mc "%s  I know about %d questions." $text [llength $qlist]]
    mxirc_notc $nick [string trim $text]

    return 1
}


###########################################################################
#
# Configuration file reading and writing, setup
#
###########################################################################

# public interface to set the configuration variables from the config file
proc moxquiz_config_set {handle idx arg} {
    global quizconf
    variable key
    variable value
    variable success 0

    # collapse whitespace
    regsub -all " +" $arg " " arg

    # extract key and value
    set list [split $arg]
    for {set i 0} {$i < [llength $list]} {incr i 2} {
	set key [string tolower [lindex $list $i]]
	set value [lindex $list [expr 1 + $i]]

	# first lets see if the key exists
	set keylist [array names quizconf "*$key*"]
	if {[llength $keylist] == 1} { set key [lindex $keylist 0] }

	if {[info exists quizconf($key)]} {
	    if {$value == ""} {
		mxirc_dcc $idx "$key = $quizconf($key)"
	    } else {
		mx_log "--- config tried $key = $value"
		set success 0
		set oldvalue $quizconf($key)
		switch -regexp $oldvalue {
		    "^(yes|no)" {
			if {[regexp "^(yes|no)$" $value]} {
			    set quizconf($key) $value
			    set success 1
			}
		    }
		    "^\[0-9\]+$" {
			if {[regexp "^\[0-9\]+$" $value]} {
			    set quizconf($key) $value
			    set success 1
			}
		    }
		    default {
			set quizconf($key) $value
			set success 1
		    }
		}

		if {$success == 1} {
		    mxirc_dcc $idx "Config $key successfully set to $value."
		    mx_log "-- config $key set to $value."

		    # action on certain variables
		    mx_config_apply $key $oldvalue

		} else {
		    mxirc_dcc $idx "Config $key could not be set to '$value', wrong format."
		    mx_log "-- Config $key could not be set to '$value', wrong format."
		}
		set success 0
	    }
	} else {
	    # dump keys with substring
	    set keylist [lsort [array names quizconf "*$key*"]]
	    if {[llength $keylist] == 0} {
		mxirc_dcc $idx "Sorry, no configuration matches '$key'"
	    } else {
		mxirc_dcc $idx "Matched configuration settings for '$key':"
		for {set j 0} {$j < [llength $keylist]} {incr j 1} {
		    mxirc_dcc $idx "[lindex $keylist $j] = $quizconf([lindex $keylist $j])"
		}
	    }
	}
    }

    # check if arg was empty and dump _all_ known keys then
    if {$arg == ""} {
	set keylist [lsort [array names quizconf]]
	mxirc_dcc $idx "Listing all settings:"
	for {set j 0} {$j < [llength $keylist]} {incr j 1} {
	    mxirc_dcc $idx "[lindex $keylist $j] = $quizconf([lindex $keylist $j])"
	}
    }

    return 1
}


# public interface for readconfig
proc moxquiz_config_load {handle idx arg} {
    global configfile
    mxirc_dcc $idx "Loaded [mx_config_read $configfile] configuration entries."
}


# public interface for readconfig
proc moxquiz_config_save {handle idx arg} {
    global configfile
    mxirc_dcc $idx "Saved [mx_config_write $configfile] configuration entries."
}

# applies a configuration and makes neccessary setup
proc mx_config_apply {key oldvalue} {
    global whisperprefix quizconf botnick intldir fundatadir
    global channeltipfile pricesfile helpfile channelrulesfile
    variable value $quizconf($key)

    switch -exact $key {
	"winscore" {
	    if {$oldvalue != {}} {
		mxirc_say $quizconf(quizchannel) [mc "%sScore to win set from %d to %d (%+d)." \
                                                  [botcolor txt] $oldvalue $value [expr $value - $oldvalue]]
	    }
	}
	"msgwhisper" {
	    if {$value == "yes"} {
		set whisperprefix "PRIVMSG"
	    } else {
		set whisperprefix "NOTICE"
	    }
	}
	"channelrules" {
	    if {$value == "yes"} {
		bind msg - !rules moxquiz_rules
		bind pub - !rules moxquiz_pub_rules
		mx_read_rules $intldir/$quizconf(language)/$channelrulesfile
	    } else {
		unbind msg - !rules moxquiz_rules
		unbind pub - !rules moxquiz_pub_rules
	    }
	}
        "prices" {
            if {$value == "yes"} {
                mx_read_prices $intldir/$quizconf(language)/$pricesfile
            }
        }
        "language" {
            if {[file exists $intldir/$value.msg] || $value == "en"} {
                mx_log "--- changing language from $oldvalue to $value"
                mclocale $value
                if {$value != "en"} {
                    msgcat::mcload $intldir
                }
                mx_read_channeltips $intldir/$quizconf(language)/$channeltipfile
                mx_read_prices $intldir/$quizconf(language)/$pricesfile
                mx_read_rules $intldir/$quizconf(language)/$channelrulesfile
                mx_read_help $intldir/$quizconf(language)/$helpfile

                if {[llength [info commands moxfun_init]] != 0} {
                    set fundatadir $intldir/$quizconf(language)
                    moxfun_init
                }

            } else {
                mx_log "--- Sorry, no $value.msg file in $intldir, staying with old language set."
            }
        }
    }
}

# reads configuration from cfile into global variable quizconf
proc mx_config_read {cfile} {
    global quizconf

    variable num 0

    mx_log "--- Loading configuration from $cfile ..."

    set fd [open $cfile r]
    while {![eof $fd]} {
	gets $fd line
	if {![regexp "^ *#.*$" $line] && ![regexp "^ *$" $line]} {
	    set content [split $line {=}]
	    set key [string trim [lindex $content 0]]
	    set value [string trim [lindex $content 1]]
	    set quizconf($key) $value
	    incr num
	}
    }
    close $fd

    mx_log "--- Configuration loaded: $num settings."

    foreach $key [array names quizconf] {
	mx_config_apply $key {}
    }

    return $num
}


# writes configuration from global quizconf to cfile
proc mx_config_write {cfile} {
    global quizconf

    variable num 0
    variable written ""

    mx_log "--- Saving configuration to $cfile ..."

    set fdin [open $cfile r]
    set fdout [open "$cfile.tmp" w]

    # replace known configs
    while {![eof $fdin]} {
	gets $fdin line
	switch -regexp $line {
	    "(^ *$|^ *#.*$)" {
		puts $fdout $line
	    }
	    "^(.*)=(.*)$" {
		set content [split $line {=}]
		set key [string trim [lindex $content 0]]
		set value [string trim [lindex $content 1]]
		if {[info exists quizconf([string trim $key])]} {
		    puts $fdout "$key = $quizconf([string trim $key])"
		    incr num
		} else {
		    puts $fdout $line
		}
		lappend written [string trim $key]
	    }
	}
    }

    # append "new" configs not mentioned in the file
    set keys [array names quizconf]
    for {set i 0} {$i < [llength $keys]} {incr i} {
	set key [lindex $keys $i]
	if {[lsearch -exact $written $key] == -1} {
	    puts $fdout "$key = $quizconf($key)"
	}
    }

    close $fdin
    close $fdout

    # delete old config
    file rename -force "$cfile.tmp" $cfile

    mx_log "--- Configuration saved: $num settings."
    return $num
}


###########################################################################
#
# Handling of certain events, like +m, nickchanges and others
#
###########################################################################

## player has changed nick.  Adjust ranking
proc moxquiz_on_nickchanged {nick host handle channel newnick} {
    global userlist quizconf
    variable addscore 0 ascore 0

    if {![mx_str_ieq $channel $quizconf(quizchannel)]} {
	return
    }

    mx_log "--- $nick changed to $newnick noted."
    mx_log "---- hostmask: [maskhost $host]"
    mx_statslog "nickchange" [list [unixtime] $nick $newnick]

    # see, if we can collect some old scores
    if {[info exists userlist($newnick)]} {
	mx_log "---- old entry: $userlist($newnick)"
	# check if we know the host
	array set oldentry $userlist($newnick)
	if {$oldentry(mask) == [maskhost $host]} {
	    set addscore $oldentry(score)
	    mx_log "---- adding score: $addscore"
	    if {$addscore != 0} {
		mxirc_notc $newnick [mc "Your old scores of %d were collected, since I know your host." $addscore]
	    }
	} else {
	    set addscore 0
	    mx_log "---- hosts differed, replacing score."
	    if {$oldentry(score) != 0} {
		mxirc_notc $newnick [mc "Your host was new to me, old scores deleted."]
	    }
	}

	# new score gathered, sum up!
	if {[info exists userlist($nick)]} {
	    array set newentry $userlist($nick)
	    incr newentry(score) $addscore
	    set newentry(started) $oldentry(started)
	    set userlist($newnick) [array get newentry]
	    unset userlist($nick)
	}
	# else, the newnick is still in ranks.
	# do nothing.

    } elseif {[info exists userlist($nick)]} {
	set userlist($newnick) $userlist($nick)
	array set afoo $userlist($newnick)
	unset userlist($nick)
	mx_log "---- Known, scores transferred."
	if {$afoo(score) > 0} {
	    mxirc_notc $newnick [mc "I saw you renaming and transferred scores."]
	}
    }
}


## notification when a user joins in
proc moxquiz_on_joined {nick host handle channel} {
    global qlist version_moxquizz userlist
    global quizconf quizstate qnum_thisgame

    variable text

    if {![mx_str_ieq $channel $quizconf(quizchannel)]} {
	return
    }

    set text [mc "Welcome to %sversion %s, © by Moxon <moxon@meta-x.de>.  Say \"!ask\" to get the current question or \"!qhelp\" to get an help text." \
              "[banner] [botcolor norm]" $version_moxquizz]

    if {$quizconf(channelrules) == "yes"} {
	set text [mc "%s  Check the channel rules with !rules." $text]
    }

    mxirc_notc $nick $text

    if {$quizstate == "paused"} {
	set text [mc "The current game is paused after %d questions." $qnum_thisgame]
    } elseif {$qnum_thisgame != 0} {
	set text [mc "There is a game running, %d questions have already been asked." $qnum_thisgame]
    } else {
        set text ""
    }
    set text [mc "%s  I know about %d questions." $text [llength $qlist]]
    mxirc_notc $nick [string trim $text]

    if {[info exists userlist($nick)]} {
	array set aa $userlist($nick)
	if {$aa(mask) == [maskhost $host]} {
	    if {$aa(score) > 0} {
		mxirc_notc $nick [mc "You are listed with %d points on rank %d." $aa(score) [mx_get_rank_pos $nick]]
	    }
	} else {
	    mxirc_notc $nick [mc "Your hostmask is new to me, deleting old scores."]
	    unset userlist($nick)
	}
    }

    mx_log "--- $nick joined the channel."
}


## react if channel gets moderated
proc moxquiz_on_moderated {nick mask handle channel mode victim} {
    global quizconf statemoderated quizstate botnick

    if {$channel == $quizconf(quizchannel) && $quizconf(pausemoderated) == "yes"} {
	switch -exact -- $mode {
	    "+m" {
		if {$quizstate == "asked" || $quizstate == "waittoask"} {
		    set statemoderated $quizstate
		    mx_log "--- Quiz paused since channel got moderated."
		    moxquiz_pause $botnick {} {}
		}
	    }
	    "-m" {
		if {$statemoderated != ""} {
		    set statemoderated ""
		    mx_log "--- Quiz continued since channel no longer moderated."
		    moxquiz_cont $botnick {} {}
		}
	    }
	    default {
		mx_log "!!! ERROR: can't handle mode: $mode on channel $channel."
	    }
	}
    }
    return 1
}

###########################################################################
#
# miscellaneous moxquiz commands not fitting elsewhere
#
###########################################################################


# say Hi to "known" users
proc moxquiz_pub_hi {nick host handle channel arg} {
    global quizconf allstarsarray
    if {[mx_str_ieq $channel $quizconf(quizchannel)] &&
    ([validuser $handle] || [info exists allstarsarray($nick)]) } {
	mxirc_say $quizconf(quizchannel) [mc "Hi %s!  Nice to see you." $nick]
    }
}



# say Hi to "known" users
proc moxquiz_purr {nick host handle channel action arg} {
    global quizconf allstarsarray

    # [pending] translate this
    set tlist [list "purrs." \
                   "meows." \
                   "happily hops around."]

    if {$action == "ACTION" && arg == "pats $botnick" &&
        [mx_str_ieq $channel $quizconf(quizchannel)] &&
        ([validuser $handle] || [info exists allstarsarray($nick)]) } {
        mxirc_action $quizconf(quizchannel) [lindex $tlist [rand [llength $tlist]]]
    }
}


###########################################################################
#
# debug stuff
#
###########################################################################

proc moxquiz_colors {handle idx arg} {
    global quizconf

    mxirc_say $quizconf(quizchannel) "[banner] [botcolor norm]printing colors"

    if {$arg != ""} {
	mxirc_say $quizconf(quizchannel) "NORMAL:"

	mxirc_say $quizconf(quizchannel) "[color norm norm]norm"
	mxirc_say $quizconf(quizchannel) "[color black norm]black"
	mxirc_say $quizconf(quizchannel) "[color blue norm]blue"
	mxirc_say $quizconf(quizchannel) "[color green norm]green"
	mxirc_say $quizconf(quizchannel) "[color red norm]red"
	mxirc_say $quizconf(quizchannel) "[color brown norm]brown"
	mxirc_say $quizconf(quizchannel) "[color purple norm]purple"
	mxirc_say $quizconf(quizchannel) "[color orange norm]orange"
	mxirc_say $quizconf(quizchannel) "[color yellow norm]yellow"
	mxirc_say $quizconf(quizchannel) "[color blue norm]blue"

	mxirc_say $quizconf(quizchannel) "BOLD:"

	mxirc_say $quizconf(quizchannel) "[color norm norm][col bold]norm"
	mxirc_say $quizconf(quizchannel) "[color black norm][col bold]black"
	mxirc_say $quizconf(quizchannel) "[color blue norm][col bold]blue"
	mxirc_say $quizconf(quizchannel) "[color green norm][col bold]green"
	mxirc_say $quizconf(quizchannel) "[color red norm][col bold]red"
	mxirc_say $quizconf(quizchannel) "[color brown norm][col bold]brown"
	mxirc_say $quizconf(quizchannel) "[color purple norm][col bold]purple"
	mxirc_say $quizconf(quizchannel) "[color orange norm][col bold]orange"
	mxirc_say $quizconf(quizchannel) "[color yellow norm][col bold]yellow"
	mxirc_say $quizconf(quizchannel) "[color blue norm][col bold]blue"

	mxirc_say $quizconf(quizchannel) "BOLD underlined:"

	mxirc_say $quizconf(quizchannel) "[color norm norm][col bold][col uline]norm"
	mxirc_say $quizconf(quizchannel) "[color black norm][col bold][col uline]black"
	mxirc_say $quizconf(quizchannel) "[color blue norm][col bold][col uline]blue"
	mxirc_say $quizconf(quizchannel) "[color green norm][col bold][col uline]green"
	mxirc_say $quizconf(quizchannel) "[color red norm][col bold][col uline]red"
	mxirc_say $quizconf(quizchannel) "[color brown norm][col bold][col uline]brown"
	mxirc_say $quizconf(quizchannel) "[color purple norm][col bold][col uline]purple"
	mxirc_say $quizconf(quizchannel) "[color orange norm][col bold][col uline]orange"
	mxirc_say $quizconf(quizchannel) "[color yellow norm][col bold][col uline]yellow"
	mxirc_say $quizconf(quizchannel) "[color blue norm][col bold][col uline]blue"

	mxirc_say $quizconf(quizchannel) "[col bold] bold"
	mxirc_say $quizconf(quizchannel) "[col uline] uline"
    }

    mxirc_say $quizconf(quizchannel) "Botcolors:"

    mxirc_say $quizconf(quizchannel) "[botcolor nick]nick"
    mxirc_say $quizconf(quizchannel) "[botcolor nickscore]nickscore"
    mxirc_say $quizconf(quizchannel) "[botcolor highscore]highscore"
    mxirc_say $quizconf(quizchannel) "[botcolor txt]txt"
    mxirc_say $quizconf(quizchannel) "[botcolor own]own"
    mxirc_say $quizconf(quizchannel) "[botcolor norm]norm"
    mxirc_say $quizconf(quizchannel) "[botcolor ""]none"
    mxirc_say $quizconf(quizchannel) "[botcolor boldtxt]bold txt"
    mxirc_say $quizconf(quizchannel) "[botcolor question]question"
    mxirc_say $quizconf(quizchannel) "[botcolor answer]answer"
    mxirc_say $quizconf(quizchannel) "[botcolor grats]* Congrats *"
    mxirc_say $quizconf(quizchannel) "[botcolor tip]tip"
    mxirc_say $quizconf(quizchannel) "[botcolor score]score"
    return 1
}

###########################################################################
###########################################################################
##
## internal routines
##
###########################################################################
###########################################################################


## ----------------------------------------------------------------------
## Handling of statistics
## ----------------------------------------------------------------------

proc mx_statslog {event params} {
    global quizconf statsfile statsfilefd

    if {$quizconf(statslog) == "no"} { return }

    if {$statsfilefd == "closed"} {
        set statsfilefd [open $statsfile a]
    }

    switch -regexp $event {
        "(revolt|revoltsolve|solved|tiar|gamestart|gamewon|rankset|nickchange)" {
            puts $statsfilefd "$event $params"
            #flush $statsfilefd
        }
        default {
            mx_log "--- ERROR:  unknown event for stats: $event $params"
        }
    }

}


## ----------------------------------------------------------------------
## react on certain events
## ----------------------------------------------------------------------

proc mx_event {type} {
    global botnick quizstate
    switch -exact $type {
	"prerehash" {
	    mx_log "--- Preparing for rehashing"
	    if {$quizstate != "halted"} {
		moxquiz_halt $botnick 0 {}
	    }
	    moxquiz_rank_save $botnick 0 {}
	    moxquiz_saveuserquests $botnick 0 "all"
	    moxquiz_config_save $botnick 0 {}
	    set tmp_logfiles [logfile]
	    mx_log "---- will reopen logfiles: $tmp_logfiles"
	    mx_log "--- Ready for rehashing"
	}
	"rehash" {
	    # [pending] reopen logfiles
	}
    }
}

## ----------------------------------------------------------------------
## mxirc ... stuff to speak
## ----------------------------------------------------------------------

## say something on quizchannel
proc mxirc_say {channel text} {
    putserv "PRIVMSG $channel :[mx_obfs $text]"
}

## say something on quizchannel (raw, no obfs)
proc mxirc_rsay {channel text} {
    putserv "PRIVMSG $channel :$text"
}

## say something on all channels
proc mxirc_say_everywhere {text} {
    foreach channel [channels] {
	if {[validchan $channel] && [botonchan $channel]} {
	    mxirc_say $channel $text
	}
    }
}


## act in some way (/me)
proc mxirc_action {channel text} {
    putserv "PRIVMSG $channel :\001ACTION [mx_obfs $text]\001"
}


## act on all channels
proc mxirc_action_everywhere {text} {
    foreach channel [channels] {
	if {[validchan $channel] && [botonchan $channel]} {
	    mxirc_action $channel $text
	}
    }
}


## say something through another buffer
proc mxirc_quick {channel text} {
    putquick "PRIVMSG $channel :$text"
}


## say something to a user
proc mxirc_msg {nick text} {
    global botnick
    if {![mx_str_ieq $botnick $nick]} {
	puthelp "PRIVMSG $nick :$text"
    }
}


## say something through another buffer
proc mxirc_quick_notc {nick text} {
    global botnick whisperprefix
    if {![mx_str_ieq $botnick $nick]} {
	putquick "$whisperprefix $nick :$text"
    }
}


## notice something to a user (whisper)
proc mxirc_notc {nick text} {
    global botnick whisperprefix
    if {![mx_str_ieq $botnick $nick]} {
	puthelp "$whisperprefix $nick :$text"
    }
}



## notice something to a user
proc mxirc_dcc {idx text} {
    if {[valididx $idx]} {
	putdcc $idx $text
    }
}


## ----------------------------------------------------------------------
## mx.... generic tool functions and internal functions
## ----------------------------------------------------------------------

## func to act according to the value of $aftergame
proc mx_aftergameaction {} {
    global botnick aftergame quizconf

    switch -exact $aftergame {
	"stop" {
	    moxquiz_stop $botnick 0 {}
	    set aftergame $quizconf(aftergameaction)
	}
	"halt" {
	    moxquiz_halt $botnick 0 {}
	    set aftergame $quizconf(aftergameaction)
	}
	"exit" {
	    # sleep some milliseconds
	    moxquiz_stop $botnick 0 {}
	    mxirc_say $quizconf(quizchannel) [mc "Thanks for playing ppl, I'll exit now (and thanks for all the fish)."]
	    utimer 2 mx_timer_aftergame_exit
	}
	"newgame" {
	    # do nothing special here
	    set aftergame $quizconf(aftergameaction)
	}
	default {
	    mx_log "ERROR: Bad aftergame-value: \"$aftergame\" -- halted"
	    moxquiz_halt $botnick 0 {}
	}
    }
}


## timer to shut the bot down from aftergameaction
proc mx_timer_aftergame_exit {} {
    global botnick

    mx_log "--- aftergame timer entered, queuesize = [queuesize]"

    if {[queuesize] != 0} {
	utimer 2 mx_timer_aftergame_exit
    } else {
	moxquiz_exit $botnick 0 {}
    }
}

## func to log stuff
proc mx_log {text} {
    global quizconf
    putloglev $quizconf(quizloglevel) $quizconf(quizchannel) $text
}

## return a duration as a string
proc mx_duration {time} {
    variable dur [duration [expr [unixtime] - $time]]

    regsub -all "seconds" $dur [mc "seconds"] dur
    regsub -all "second" $dur [mc "second"] dur
    regsub -all "minutes" $dur [mc "minutes"] dur
    regsub -all "minute" $dur [mc "minute"] dur
    regsub -all "hours" $dur [mc "hours"] dur
    regsub -all "hour" $dur [mc "hour"] dur
    regsub -all "days" $dur [mc "days"] dur
    regsub -all "day" $dur [mc "day"] dur
    regsub -all "weeks" $dur [mc "weeks"] dur
    regsub -all "week" $dur [mc "week"] dur
    regsub -all "months" $dur [mc "months"] dur
    regsub -all "month" $dur [mc "month"] dur

    return $dur
}

## return if strings are equal case ignored
proc mx_str_ieq {a b} {
    if {[string tolower $a] == [string tolower $b]} {
	return 1
    } else {
	return 0
    }
}

## returns question numbers (guaranteed to return each number once before starting over)
proc mx_next_qnumber {} {
    global qlistorder qlist

    if {[llength $qlistorder] < 1} {
        for {set i 0} {$i < [llength $qlist]} {incr i} {
            lappend qlistorder "$i"
        }
    }
    set pos [rand [llength $qlistorder]]
    set value [lindex $qlistorder $pos]
    set qlistorder [lreplace $qlistorder $pos $pos]
    return $value
}

## read question data
## RETURNS:  0 if no error
##           1 if no file found
proc mx_read_questions {questionset} {
    global qlist qlistorder qnumber datadir
    variable entry
    variable tipno 0
    variable key
    variable errno 0
    # 0=out 1=in
    variable readstate 0

    mx_log "--- Loading questions."


    # keep the old questions safe
    set tmplist $qlist
    set qlist ""

    foreach datafile [glob -nocomplain "$datadir/questions*$questionset"] {

	set fd [open $datafile r]
	while {![eof $fd]} {
	    set line [gets $fd]
	    # an empty line terminates an entry
	    if {[regexp "^ *$" $line]} {
		if {$readstate == 1} {
		    # reject crippled entries
		    if {[info exists entry(Question)]
		    && [info exists entry(Answer)]} {
			lappend qlist [array get entry]
		    } else {
			mx_log "[array get entry] not complete."
		    }
		    set tipno 0
		    unset entry
		}
		set readstate 0
	    } elseif {![regexp "^#.*" $line]} {
		set readstate 1
		set data [split $line {:}]
		if {![regexp "(Answer|Author|Category|Comment|Level|Question|Regexp|Score|Tip|Tipcycle)" [lindex $data 0]]} {
		    mx_log "---- Key [lindex $data 0] unknown!"
		} else {
		    set key [string trim [lindex $data 0]]
		    if {$key == "Tip"} {
			set key "$key$tipno"
			incr tipno
		    }
		    set entry($key) [string trim [join [lrange $data 1 end] ":"]]
		}
	    }
	}
	close $fd

	mx_log "---- now [llength $qlist] questions, added $datafile"
    }

    if {[llength $qlist] == 0} {
	set qlist $tmplist
	mx_log "----- reset to prior questions ([llength $qlist] ones)."
	set errno 1
    }

    mx_log "--- Questions loaded."

    set qlistorder ""
    return $errno
}


## sets back all variables when a question is solved
## and goes to state waittoask (no timer set !!)
proc mx_answered {} {
    global quizstate tipno usergame qlistfinished userqnumber
    global userqlist tiplist revoltlist revoltmax
    variable alist

    if {$quizstate == "asked"} {
	if {$usergame == 1} {
	    ## save usergame
	    set pos [expr $userqnumber - 1]
	    set alist [lindex $userqlist $pos]
	    mx_log "---- userquest stored: $alist"
	    set i 0
	    foreach t $tiplist {
		lappend alist "Tip$i" [lindex $tiplist $i]
		incr i
	    }
	    set userqlist [lreplace $userqlist $pos $pos $alist]
	    ## [pending] save each question to disc immediatly
	}
	set quizstate "waittoask"
	set tipno 0
	set revoltlist ""
	set revoltmax 0

	foreach j [utimers] {
	    if {[lindex $j 1] == "mx_timer_tip"} {
		killutimer [lindex $j 2]
	    }
	}
    }
}


proc mx_timer_ask {} {
    global botnick quizconf
    moxquiz_ask $botnick {} {} $quizconf(quizchannel) {}
}


## give a tip and check if channel is desert!
proc mx_timer_tip {} {
    global userlist botnick banner
    global aftergame timerankreset qnum_thisgame
    global quizconf

    variable desert 1

    foreach u [array names userlist] {
	array set afoo $userlist($u)
	if {$afoo(lastspoken) >= [expr [unixtime] - ($quizconf(tipcycle) * $quizconf(tipdelay) * 2) - $quizconf(askdelay)]} {
	    set desert 0
	    break
	}
    }

    # ask at least one question
    if {$desert && $qnum_thisgame > 2} {
	mxirc_say $quizconf(quizchannel) [mc "%s Channel found desert." [banner]]
        mx_log "--- Channel found desert."
	moxquiz_rank_reset $botnick {} {}
	if {$aftergame != "exit"} {
	    moxquiz_halt $botnick 0 {}
	} else {
	    mx_aftergameaction
	}
    } else {
	moxquiz_tip $botnick 0 {}
    }
}


## compare length of two elements
proc mx_cmp_length {a b} {
    variable la [string length $a] lb [string length $b]
    if {$la == $lb} {
	return 0
    } elseif {$la > $lb} {
	return 1
    } else {
	return -1
    }
}


## returns number of open userquests
proc mx_userquests_available {} {
    global userqlist userqnumber

    set num [expr [llength $userqlist] - $userqnumber]

    if {$num < 0} {
	return 0
    } else {
	return $num
    }
}


## return number of ppl with a point
proc mx_users_in_rank {} {
    global userlist quizconf
    variable num 0

    foreach nick [array names userlist] {
        array set x $userlist($nick)
        if {$x(score) > 0} {
            incr num
        }
    }
    return $num
}


## return score of the leading player in the current game
proc mx_overrun_limit_reached {} {
    global userlist quizconf

    foreach nick [array names userlist] {
        array set x $userlist($nick)
        if {$x(score) >= $quizconf(overrunlimit)} {
            return 1
        }
    }
    return 0
}


## create an entry in the userlist or update an existing
## then entry is returned
proc mx_getcreate_userentry {nick host} {
    global userlist botnick

    ## prevent myself from being added, though this will never happen
    if {[mx_str_ieq $nick $botnick]} {
	return
    }

    if {[info exists userlist($nick)]} {
	array set anarray $userlist($nick)
	set anarray(lastspoken) [unixtime]
	set userlist($nick) [array get anarray]
    } else {
	set userlist($nick) [list "mask" [maskhost $host] "score" 0 "started" [unixtime] "lastspoken" [unixtime]]
	mx_log "---- new user $nick: $userlist($nick)"
	array set anarray $userlist($nick)
    }
}

## convert some latin1 special chars
proc mx_tweak_umlauts {text} {
    regsub -all "ä" $text "ae" text
    regsub -all "ö" $text "oe" text
    regsub -all "ü" $text "ue" text
    regsub -all "Ä" $text "AE" text
    regsub -all "Ö" $text "OE" text
    regsub -all "Ü" $text "UE" text
    regsub -all "ß" $text "ss" text
    regsub -all "è" $text "e" text
    regsub -all "È" $text "E" text
    regsub -all "é" $text "e" text
    regsub -all "É" $text "E" text
    return $text
}

## string
proc mx_obfs {text} {
    variable tmp ""
    for {set i 0} {$i < [string length $text]} {incr i} {
        set x [string index $text $i]
        if {$x != " "} {
            append tmp $x
        } else {
            if {[rand 10] > 3}  {
                append tmp " "
            } else {
                append tmp " "
            }
        }
    }
    return $tmp
}

##################################################
#
# functions for colors
#
##################################################

## strip color codes from a string
proc mx_strip_colors {txt} {
    variable result

    regsub -all "\[\002\017\]" $txt "" result
    regsub -all "\003\[0-9\]\[0-9\]?\(,\[0-9\]\[0-9\]?\)?" $result "" result

    return $result
}

# return botcolor
proc botcolor {thing} {
    global quizconf
    if {$quizconf(colorize) != "yes"} {return ""}
#      if {$thing == "question"} {return "\003[col dblue][col uline]"}
#      if {$thing == "answer"} {return "\003[col dblue]"}
#      if {$thing == "tip"} {return "\003[col dblue]"}
    if {$thing == "question"} {return "[color dblue white][col uline]"}
    if {$thing == "answer"} {return "[color dblue white]"}
    if {$thing == "tip"} {return "[color dblue white]"}
    if {$thing == "nick"} {return "[color lightgreen black]"}
    if {$thing == "nickscore"} {return "[color lightgreen blue]"}
    if {$thing == "highscore"} {return "\003[col turqois][col uline][col bold]"}
#    if {$thing == "txt"} {return "[color red yellow]"}
    if {$thing == "txt"} {return "[color blue lightblue]"}
    if {$thing == "boldtxt"} {return "[col bold][color blue lightblue]"}
    if {$thing == "own"} {return "[color red black]"}
    if {$thing == "norm"} {return "\017"}
    if {$thing == "grats"} {return "[color purple norm]"}
    if {$thing == "score"} {return "[color blue lightblue]"}
    if {$thing == ""} {return "\003"}
}

# internal function, never used from ouside. (doesn't check colorize!)
proc color {fg bg} {
    return "\003[col $fg],[col $bg]"
}

# taken from eggdrop mailinglist archive
proc col {acolor} {
    global quizconf
    if {$quizconf(colorize) != "yes"} {return ""}

    if {$acolor == "norm"} {return "00"}
    if {$acolor == "white"} {return "00"}
    if {$acolor == "black"} {return "01"}
    if {$acolor == "blue"} {return "02"}
    if {$acolor == "green"} {return "03"}
    if {$acolor == "red"} {return "04"}
    if {$acolor == "brown"} {return "05"}
    if {$acolor == "purple"} {return "06"}
    if {$acolor == "orange"} {return "07"}
    if {$acolor == "yellow"} {return "08"}
    if {$acolor == "lightgreen"} {return "09"}
    if {$acolor == "turqois"} {return "10"}
    if {$acolor == "lightblue"} {return "11"}
    if {$acolor == "dblue"} {return "12"}
    if {$acolor == "pink"} {return "13"}
    if {$acolor == "grey"} {return "14"}


    if {$acolor == "bold"} {return "\002"}
    if {$acolor == "uline"} {return "\037"}
#    if {$color == "reverse"} {return "\022"}
}

###########################################################################

## Banner:

proc banner {} {
    return "[botcolor grats]\{MoxQuizz\}[botcolor norm]"
}

# should return as much spaces as the banner needs (for best results)
proc bannerspace {} {
    return "          "
}

###########################################################################
#
# Initialize
#

mx_config_read $configfile

mx_log "**********************************************************************"
mx_log "--- $botnick started"

# this makes sure, that the funstuff will be initialized correcty, if loaded
mx_config_apply "language" $quizconf(language)

mx_read_questions $quizconf(questionset)

moxquiz_rank_load $botnick 0 {}
moxquiz_allstars_load $botnick 0 {}
if {$quizconf(quizchannel) != ""} {
    set quizconf(quizchannel) [string tolower $quizconf(quizchannel)]
    channel add $quizconf(quizchannel)
}
