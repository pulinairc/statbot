#################################################################################################
# CodeNinja Quote System v1.0.1                                                                 #
#                                                                                               #
# Commands (<required> [optional]):                                                             #
#  !addquote <quote> (adds a quote)                                                             #
#  !delquote <quote id> (deletes a quote)                                                       #
#  !quote [quote id] (gets a specific or random quote)                                          #
#  !findquote <regexp string> (find quotes matching regexp string)                              #
#  !lastquote (get the last quote added to the database)                                        #
#  !quoteauth <nick> (find quotes added by nick)                                                #
#  !quotechan <#chan> (find quotes added in #chan)                                              #
#                                                                                               #
# Changes                                                                                       #
#  v1.0.1                                                                                       #
#  -Quote file is automatically added upon adding first quote                                   #
#  -Fixed a bug with random quotes                                                              #
#  v1.0.2                                                                                       #
#  -Changed how search commands (e.g. !findquote, !quoteauth, and !quotechan) handle            #
#   excess results                                                                              #
#  -Fixed a var mix-up                                                                          #
#                                                                                               #
# For updates, check out https://sites.google.com/site/codeninjacodes/                          #
#                                                                                               #
# To report bugs, email me at codeninja68@gmail.com                                             #
#                                                                                               #
#################################################################################################

namespace eval codeninja {
    namespace eval quotesys {

        # File to store quotes in
        variable qfile "quotes.txt"

        # Limit of lines before quote is sent to private instead of the channel
        variable plines 6

        # Use notice for private instead of message?
        variable notice 1

        # Maximum number of search results to display (0 for no limit)
        # WARNING: if you do not enable this there is a chance the bot will get booted from the
        # server if there are too many results
        variable flimit 15

        # Line divider to use when adding quotes
        variable div "|"

        # Command character
        variable cmdchar "!"

        # Flags required to delete quotes
        variable dflags "m"
    }
}

# END CONFIG - DO NOT EDIT BELOW THIS

namespace eval codeninja {
    namespace eval quotesys {
        variable ver "v1.0.1"
        proc add {nick uhost hand chan text} {
            if {[string trim $text] == ""} { putserv "PRIVMSG $chan :Quotea ei määritetty."
                return
            }
            set filesock [open ${codeninja::quotesys::qfile} {WRONLY APPEND CREAT}]
            puts $filesock "\{$text\} $nick $chan [unixtime]"
            close $filesock

            putserv "PRIVMSG $chan :Quote lisätty varastoon."
        }
        proc del {nick uhost hand chan text} {
            if {![regexp {^([0-9]+)$} $text]} { putserv "PRIVMSG $chan :Outo quoten ID."
                return
            }
            set filesock [open ${codeninja::quotesys::qfile} r]
            set quotelist [split [string trimright [read $filesock] "\n"] "\n"]
            close $filesock

            if {[lindex $quotelist [expr $text - 1]] == ""} { putserv "PRIVMSG $chan :Outo ID quotella."
                return
            }
            set filesock [open ${codeninja::quotesys::qfile} w]
            set x 0
            foreach quote $quotelist {
                if {$x != [expr $text - 1]} { puts $filesock [string trim $quote "\n"] }
                incr x
            }
            close $filesock
            putserv "PRIVMSG $chan :Quote $text deleted"
        }
        proc get {nick uhost hand chan text} {
            if {![file exists ${codeninja::quotesys::qfile}]} { putserv "PRIVMSG $chan :Ei lainauksia."
                return
            }
            if {[string trim $text] == ""} {
                set filesock [open ${codeninja::quotesys::qfile} r]
                set quotes [split [string trimright [read $filesock] "\n"] "\n"]
                close $filesock

                set qi(id)  [rand [llength $quotes]]
                set qi(all) [lindex $quotes $qi(id)]
                incr qi(id)
                set qi(quote) [lindex $qi(all) 0]
                set qi(nick) [lindex $qi(all) 1]
                set qi(chan) [lindex $qi(all) 2]
                set qi(time) [lindex $qi(all) 3]
            } elseif {[regexp {^([0-9]+)$} $text]} {
                set filesock [open ${codeninja::quotesys::qfile} r]
                set quotes [split [string trimright [read $filesock] "\n"] "\n"]
                close $filesock

                if {$text > [llength $quotes] || $text < 1} { putserv "PRIVMSG $chan :Quotea ei ole olemassa." }

                set qi(id) $text
                set qi(all) [lindex $quotes [expr $text - 1]]
                set qi(quote) [lindex $qi(all) 0]
                set qi(nick) [lindex $qi(all) 1]
                set qi(chan) [lindex $qi(all) 2]
                set qi(time) [lindex $qi(all) 3]
            } else { putserv "PRIVMSG $chan :Invalid quote ID"
                return
            }
            if {[llength [split $qi(quote) ${codeninja::quotesys::div}]] > 5} { set sendmeth "[pmnot] $nick" } else { set sendmeth "PRIVMSG $chan" }
            foreach line [split $qi(quote) ${codeninja::quotesys::div}] {
                putserv "$sendmeth :Quote $qi(id): $line"
            }
            putserv "$sendmeth :Lisäsi $qi(nick) - [clock format $qi(time)]"
        }
        proc find {nick uhost hand chan text} {
            if {[string trim $text] == ""} { putserv "PRIVMSG $chan :Mitäs lainausta tahdot etsiä?"
                return
            }
            set filesock [open ${codeninja::quotesys::qfile} r]
            set quotes [split [string trimright [read $filesock] "\n"] "\n"]
            close $filesock

            set x 1
            set found ""
            foreach quote $quotes {
                if {[regexp -nocase $text [lindex $quote 0]]} { lappend found $x }
                incr x
            }
            if {$found == ""} { putserv "PRIVMSG $chan :No quotes found"
            } elseif {[llength $found] > ${codeninja::quotesys::flimit}} { putserv "PRIVMSG $chan :Seuraavat lainaukset osuivat hakuusi: [lrange $found 0 [expr ${codeninja::quotesys::flimit} - 1]] (first ${codeninja::quotesys::flimit} shown)"
            } else { putserv "PRIVMSG $chan :Seuraavat lainaukset osuivat hakuusi: $found" }
        }
        proc last {nick uhost hand chan text} {
            set filesock [open ${codeninja::quotesys::qfile} r]
            set quotes [split [string trimright [read $filesock] "\n"] "\n"]
            close $filesock

            set qi(id) [llength $quotes]
            set qi(all) [lindex $quotes [expr $qi(id) - 1]]
            set qi(quote) [lindex $qi(all) 0]
            set qi(nick) [lindex $qi(all) 1]
            set qi(chan) [lindex $qi(all) 2]
            set qi(time) [clock format [lindex $qi(all) 3]]

            if {[llength [split $qi(quote) ${codeninja::quotesys::div}]] > ${codeninja::quotesys::plines}} { set sendmeth "NOTICE $nick" } else { set sendmeth "PRIVMSG $chan" }
            foreach line [split $qi(quote) ${codeninja::quotesys::div}] {
                putserv "$sendmeth :Quote ${qi(id)}: $line"
            }
            putserv "$sendmeth :Lisäsi $qi(nick) kanavalla $qi(chan). pvm: $qi(time)"
        }
        proc total {nick uhost hand chan text} {
            set filesock [open ${codeninja::quotesys::qfile} r]
            set quotes [split [string trimright [read $filesock] "\n"] "\n"]
            close $filesock

            set total [llength $quotes]

            putserv "PRIVMSG $chan :Yhteensä $total quotea varastossa."
        }
        proc listauth {nick uhost hand chan text} {
            if {$text == ""} { putserv "PRIVMSG $chan :Invalid syntax"
                return
            }
            set filesock [open ${codeninja::quotesys::qfile} r]
            set quotes [split [string trimright [read $filesock] "\n"] "\n"]
            close $filesock

            set match ""
            set qid 1
            foreach quote $quotes {
                if {[string match -nocase [lindex $quote 1] [lindex $text 0]]} {
                    lappend match $qid
                }
                incr qid
            }
            if {$match == ""} { putserv "PRIVMSG $chan :No quotes found by $text"
            } elseif {[llength $match] > ${codeninja::quotesys::flimit}} { putserv "PRIVMSG $chan :$text lisätty seuraavaan: [lrange $match 0 [expr ${codeninja::quotesys::flimit} - 1]] (first ${codeninja::quotesys::flimit} shown)"
            } else { putserv "PRIVMSG $chan :$text lisätty seuraaviin quoteihin: $match" }
        }
        proc listchan {nick uhost hand chan text} {
            if {$text == ""} { set arg $chan } else { set arg [lindex $text 0] }
            set filesock [open ${codeninja::quotesys::qfile} r]
            set quotes [split [string trimright [read $filesock] "\n"] "\n"]
            close $filesock

            set match ""
            set qid 1

            foreach quote $quotes {
                if {[string match -nocase [lindex $quote 2] $arg]} {
                    lappend match $qid
                }
                incr qid
            }
            if {$match == ""} { putserv "PRIVMSG $chan :Ei quoteja lisätty $arg"
            } elseif {[llength $match] > ${codeninja::quotesys::plines}} { putserv "PRIVMSG $chan :Seuraavat quotet lisätty $arg: [lrange $match 0 [expr ${codeninja::quotesys::flimit} - 1]] (first ${codeninja::quotesys::flimit} shown)"
            } else { putserv "PRIVMSG $chan :Seuraavat quotet lisätty $arg: $match" }
        }
        proc pmnot {} {
            if {${codeninja::quotesys::notice} == 1} { return "NOTICE"
            } else { return "PRIVMSG" }
        }
    }
}

bind pub -|- ${codeninja::quotesys::cmdchar}addquote codeninja::quotesys::add
bind pub ${codeninja::quotesys::dflags} ${codeninja::quotesys::cmdchar}delquote codeninja::quotesys::del
bind pub -|- ${codeninja::quotesys::cmdchar}quote codeninja::quotesys::get
bind pub -|- ${codeninja::quotesys::cmdchar}findquote codeninja::quotesys::find
bind pub -|- ${codeninja::quotesys::cmdchar}lastquote codeninja::quotesys::last
bind pub -|- ${codeninja::quotesys::cmdchar}totalquotes codeninja::quotesys::total
bind pub -|- ${codeninja::quotesys::cmdchar}quoteauth codeninja::quotesys::listauth
bind pub -|- ${codeninja::quotesys::cmdchar}quotechan codeninja::quotesys::listchan

putlog "Script loaded: \002CodeNinja Quote System ${codeninja::quotesys::ver}\002"
