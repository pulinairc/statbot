########################################################################
###  Define.tcl v.1.0                                                ###
###        Define.tcl v1.0 has been made and development             ###
###                             BY                                   ###
###        (c) SnowBot (ha0) Script Team Development (c)             ###
###  *** Copyright (C) 1999-2002 Clovis  #Mania @ DalNet ***         ###
###  The purpose from this script is for educational only            ###
###  Not available for commercial purpose                            ###
###  For contact you can email me at hendra_asianto@hotmail.com      ###
###  Our Homepage on www.snowbot.s5.com or visit our chan on #mania  ###
########################################################################
#######################################################################
## --- Don't change anything below here if you don't know how ! --- ###
## ---------------------------------------------------------------- ###
#Just the binds
bind pub - !define pub_define
bind msg - define msg_define
bind dcc - define dcc_define

# Version number - DON'T TOUCH!
set Snowver "1.0"

### Start Call Command

## Pubic Define proc
proc pub_define {nick uhost hand channel arg} {
  global Defword Defsym botnick
  if {$arg == "" || [llength $arg] > 1} {
    putserv "NOTICE $nick :Käyttö: !define <selitys>"
    putserv "NOTICE $nick :      Example: !define [lindex $Defsym [rand [llength $Defword]]]"
    return 0
  }
  set this [lsearch -exact $Defsym [string trimleft [string toupper $arg] .]]
  if {$this > -1} {
    putserv "PRIVMSG $channel :\002$arg\002: [lindex $Defword $this]"
    return 1
  } else {
    putserv "PRIVMSG $channel :Tarkoitusta ei löydetty asialle nimeltä \002$arg\002"
    return 0
  }
}

## MSG Define proc
proc msg_define {nick uhost hand arg} {
 global Defword Defsym botnick
 if {$arg == "" || [llength $arg] > 1} {
    putserv "NOTICE $nick :Käyttö:(/msg) $botnick define <selitys>"
    putserv "NOTICE $nick :Esimerkki:(/msg) $botnick define [lindex $Defsym [rand [llength $Defword]]]"
    return 0
  }
  set this [lsearch -exact $Defsym [string trimleft [string toupper $arg] .]]
  if {$this > -1} {
    putserv "NOTICE $nick  :\002$arg\002: [lindex $Defword $this]"
    return 1
  } else {
    putserv "NOTICE $nick  :Tarkoitusta ei löydetty asialle nimeltä \002$arg\002"
    return 0
  }
}

## DCC Define proc
proc dcc_define {hand idx arg} {
  global Defword Defsym botnick
  if {$arg == "" || [llength $arg] > 1} {
    putdcc $idx "Käyttö: !define <selitys>"
    putdcc $idx "Esimerkki: define .[lindex $Defsym [rand [llength $Defword]]]"
    return 0
  }
  set this [lsearch -exact $Defsym [string trimleft [string toupper $arg] .]]
  if {$this > -1} {
    putdcc $idx "\002$arg\002: [lindex $Defword $this]"
    return 1
  } else {
    putdcc $idx "Tarkoitusta ei löydetty asialle nimeltä \002$arg\002"
    return 0
  }
}

# Define Meaning
set Defword {
 "Hendra Asianto Tcl" "Hendra Asianto Tcl Crew's" "tonight" "to you, too" "as a matter of fact" "Address" "as far as I know" "Away From Keyboard" "Artificial Intelligence"
 "all f****d up" "all right" "army of lamers (ok, ok, America On-Line, too)" "as soon as possible" 
 "American Standard Code for Information Interchange" "Automatic Teller Machine" "at the moment"
 "Arizona" "[Gor] necklaces - usually expensive ones" "[Gor] belly - a standard slave girl position"
 "Be Back In A Bit" "Be Back In A Few" "Be Back Soon" "because" "breakdown" "bondage, discipline, sado-masochism"
 "the author of the eggdrop bot, and of many of their scripts" "big grin" "[Gor] slave beads, necklaces used for ornamenting slave girls"
 "Basic Input Output System" "BInary digiT - a 1 or a 0" "but in the meantime" "black leather jacket" "Bend Over, Here It Comes Again"
 "big red switch [hacker term]" "bulls**t" "better than life" "By The Way" "bring your own booze" "bring your own rocket launcher"
 "Be Right Back" "Be Back Later" "Be Back in a Flash" "HyperText Transfer Protocol - the main protocol used to communicate between web broswers and web servers"
 "File Transfer Protocol" "Age / Sex / Location" "Tools Command Language" "Internet Relay Chat"
 "ROBOT - a program that simulates a person, in order to enhance the running of a channel (also: back on topic)"
 "Hyper-Text Mark-up Language .. used in writing web pages" "Internasional Network" 
 "8 bits - memory needed to store one character" "ciao for now" "California" "[Gor] Challenge" "complete body dysfunction" 
 "call for discussion" "call for vote" "Canadian National" "Canadian National Railway" "because OR cosine" "Canadian Pacific"
 "Canadian Pacific Railway" "Cardio-Pulminory Resuscitation" "Can't Remember Stuff (polite version)" "Connecticut" "see you later"
 "see you" "see you later" "because" "complete waste of time" "see you OR cover your a**" "Dominance / submission lifestyle" 
 "damned if i know" "difficult data retrieval (hacking)" "dude" "do I look like I give a f**k?" "do it yourself" "dead on arrival" "dude"
 "Disk Operating System" "Dots Per Inch" "dominance and submission" "the bot program written by Robey Pointer, in C, for the linux operating system"
 "elite" "elite" "elite" "elite" "excuse me for jumping in" "end of discussion" "easy" "female" "face to face OR flesh to flesh" "frequently argued issue" "frequently asked questions"
 "for better or worse" "f**k off and die" "friend of a friend" "falling off chair laughing" "[Gor] Chain" "fools seldom differ" "f**ked up beyond all belief" "f**ked up beyond all reason/recognition/repair"
 "for what it's worth" "for your amusement" "for your information" "f**k you, I'm vested" "f**k you, you sack of s**t" "grin" "Georgia (the state)" "get a life" "god" "get back to work"
 "going for coffee" "grinning from ear to ear" "Gotta Go Potty/Pee" "go jump in a g*d-damned volcano you f**king cave newt" "Great Minds Think Alike" "home stone; also, the planet Gor; also, a Kaissa piece" "grinning, running & ducking"
 "grumble" "girls" "Got To Go" "government" "Great Understanding, Relatively Useless" "hot Asian babe" "have a nice day" "[Gor] faster" "Hurry Back" "ha ha only kidding"
 "Horny Net Geek" "hope this helps" "in any case" "in any event" "i see" "I don't get it" "in my considered opinion" "in my humble opinion" "in my not so humble opinion" "in my opinion"
 "in my personal experience" "in my very humble opinion" "input/output" "intuitively obvious to the most casual observer" "in other words" "Internet Provider" "in real life" "if you know what I mean" "if you see what I mean" "just in case" "just kidding"
 "channel services bot on KrushNet" "channel services bot on Chatnet" "[Gor] without qualification, THE game; the Gorean version of chess" "[Gor] female slave" "[Gor] male slave" "cool" "keep it simple stupid" "Kiss My A**"
 "let's all get naked and f**k" "[Gor] Leash" "Laughing My A** Off" "Laughing Out Loud" "Love Of My Life" "Long Time No See"
 "love" "love" "love" "mit freundlichen Gruessen" "Male" "Merry Meet" "Message of the Day - on an irc server this can be seen with: /motd" "Merry Part" "MicroSoft's Disk Operating System" "my two cents worth" "Mind Your Own Business"
 "not applicable" "[Gor] Kneel" "no comment" "[Gor] Victory" "New Jersey" "Never Mind" "no reply necessary" "midway in the dictionary between nun and nut" "New York" "New York city" "Of Course" "Oklahoma" "oh no, not again" "Operating System"
 "Over The Knees" "on the other hand" "people can't memorize computer industry acronyms" "people dressed in black" "Prince Edward Island" "(Practical Extraction and Report Language) or (pathologically Eclectic Rubbish Lister)- both are endorsed by Larry Wall, Perl's creator" "pain in the a**"
 "Pittsburgh" "please" "Private Message" "peeing my pants" "Province of Quebec" "Channel Services bot on GalaxyNet" "research and development" "Random Access Memory" "hello again" "Rolling On the Floor Laughing" "Read-Only Memory"
 "Rolling On the Floor Laughing My A** Off" "rape and pillage" "repetitive stress injury" "real soon now" "Read The F***ing Manual" "sigh or smile" "read the documentation" "surpasses all previous f**k-ups [well-known in U.S. military during the 1940's and 1950's and in other branches of the U.S. federal government]"
 "silent but deadly" "search and destroy" "sado-masochism" "somebody had to say it" "situation normal, all f**ked up" "significant other" "that part of a search engine that surfs the web, storing the URLs and indexing the key words and text of each page it finds"
 "sexually transmitted disease" "standard temperature and pressure OR a brand of engine oil" "kitkatz" "tits and asses" "temporary autonomous zone (mobile or transient location free of economic and social interference by the state)" "that's all for now" "there ain't no such thing as a free lunch" "talking by typing OR Thunder Bay Television"
 "Tough F***ing Luck" "thanks" "thanks in advance" "three-letter acronym" "Too Much Information" "too much knowledge" "terms of service" "telepathy" "the powers that be" "true" "tell someone who cares" "tell someone who cares" "Ta Ta For Now"
 "Talk To You Later" "transvestite" "to whom it may concern" "texas" "Thank You" "opus" "Thank You Very Much" "Universal Resource Locator" "very big grin" "Virginia" "village idiot" "cservice bot on Undernet" "with" "what it is we do" "wouldn't it be lovely if" "world"
 "32-bit extensions and a graphical shell for a 16-bit patch to an 8-bit operating system originally coded for a 4-bit microprocessor, written by a 2-bit company that can't stand 1-bit of competition." "Write Once, Read Many" "without" "with respect to" "What The F**K" "Way To Go" "was"
 "when we do what it is we do" "what you see is what you get" "what you see is totally worthless in real life" "women" "cservice bot on several networks" "Christian" "yet another bloody acronym" "you ask for it, you get it" "your guess is as good as mine" "you get what you pay for" "your milieage may vary"
 "You're Welcome" 
 }

#Define symbols
set Defsym {
 HAO HA0 2NITE 2U2 AAMOF ADDY AFAIK AFK AI AFU AIGHT AOL ASAP ASCII ATM ATM AZ BANA BARA 
 BBIAB BBIAF BBS B/C B-D BDSM BELDIN <BG> BINA BIOS BIT BITMT BLJ BOHICA
 BRS BS BTL BTW BYOB BYORL  
 BRB BBL BBIIAF HTTP FTP ASL TCL IRC BOT HTML INTERNET
 BYTE C4N CA CANJELLNE CBD 
 CFD CFV CN CNR COS CP
 CPR CPR CRS CT CUL 
 CU CUL8R CUZ CWOT CYA D/S
 DAMIFINO DDR DEWD DILLIGAF DIY DOA DOOD 
 DOS DPI DS EGGDROP
 ELEET L33T '3L1T3 31337 EMFJI EOD EZ F F2F FAI FAQ 
 FBOW FOAD FOAF FOCL FORA FSD FUBAB FUBAR  
 FWIW FYA FYI FYIV FYYSOS <G> GA GAL GAWD GBTW
 GFC GFETE GGP GJIAGDVYFCN GMTA GOR GR&D
 GRMBL GRRLZ GTG GUVMENT GURU HAB HAND HARTA HB HHOK
 HNG HTH IAC IAE IC IDGI IMCO IMHO IMNSHO IMO 
 IMPE IMVHO I/O IOTTMCO IOW IP IRL IYKWIM IYSWIM JIC J/K  
 K K9 KAISSA KAJIRA KAJIRUS KEWL KISS KMA
 LAGNAF LESHA LMAO LOL LOML LTNS 
 LUFF LUV LURVE MFG M MM MOTD MP MSDOS MTCW MYOB
 N/A NADU NC NIKOS NJ NM NRN NURSE NY NYC OFC OK ONNA OS
 OTK OTOH PCMCIA PDB PEI PERL PITA
 PGH PLS PM PMP PQ Q R&D RAM REHI ROFL ROM
 ROFLMAO R&P RSI RSN RTFM <S> RTD SAPFU 
 SBD S&D S/M SHTSI SNAFU SO SPIDER 
 STD STP STREAKER T&A TAZ TAFN TANSTAAFL TBT 
 TFL THX TIA TLA TMI TMK TOS T-P TPTB TROO TSWC TTBOMK TTFN
 TTYL TV TWIMC TX TY TYPO TYVM URL <VBG> VA VI W W/ WIIWD WIBLI WIRLD
 WINDOWS WORM W/O WRT WTF WTG WUZ
 WWDWIID WYSIWYG WYSITWIRL WYMYN X XTIAN YABA YAFIYGI YGIAGAM YGWYPF YMMV
 yw
}

putlog "Script loaded: \002Define.tcl\002"    
