# netbots.tcl v4.10 (8 August 2005)
# Copyright 1998-2005 by slennox
# http://www.egghelp.org/

## netbots.tcl settings file ##

## Please read netbots.txt and components.txt before using this script ##

# netbots.tcl settings
set nb_flag N
set nb_key "xaeKa9ai"
#set nb_group(cats) "Burmese,Persian,Siamese"
#set nb_group(dogs) "Doberman,Whippet"
set nb_defctrl "*"
set nb_owner 0
set nb_ctrlbots ""
set nb_max 3
set nb_timeout 180
set nb_netupdate 2
set nb_nettcl 0
# The two lines below serve as a small example of how nb_set can be used. Change "NoteBot" to the bot you'd like to receive update notifications from and "YourNick" to your user handle on the bot.
set nb_update ""
nb_set NoteBot nb_update "YourNick"
set nb_chon 1
set nb_broadcast ""
set nb_cmdcast 0
set nb_castfilter "addhost ident .chpass .newpass .note"

#set nb_servers {
#  irc.talktome.com
#  irc.blahblahblah.org:6664
#  irc.chinwaggers.net
#}

# aidle.tcl settings
set nb_component(aidle) 0
set ai_msgbots 0
set ai_chans ""
set ai_time 60
set ai_uidle 0
set ai_msgs {
  "*yawn*"
  "la la la"
  "hello"
  "rofl"
}

# botnetop.tcl settings
set nb_component(botnetop) 0
set bop_delay 20
set bop_maxreq 3
set bop_modeop 0
set bop_linkop 1
set bop_icheck 0
set bop_hcheck 1
set bop_osync 0
set bop_addhost 0
set bop_log 2

# chanlimit.tcl settings
set nb_component(chanlimit) 0
set cl_chans ""
set cl_echans ""
set cl_limit 10
set cl_grace 2
set cl_timer 10
set cl_server 0
set cl_log 1
set cl_priority ""

# extras.tcl settings
set nb_component(extras) 0
set ex_cleanup 0
set ex_clearbans 0
set ex_newuser "YourNick"
set ex_opall 0
set ex_telnethost ""

# logfile.tcl settings
set nb_component(logfile) 0
set lg_email "user@domain.com"
set lg_maillog ""
set lg_maxsize 1024

# mainserver.tcl settings
set nb_component(mainserver) 0
set ms_mservers {
  irc.chitchat.net:6668
}
set ms_servers {
  irc.talktome.com
  irc.blahblahblah.org:6664
  irc.chinwaggers.net
}
set ms_chktime 120
set ms_tryagn 300
set ms_autoreset 0
set ms_note "YourNick"
set ms_chans "#yourchannel"
set ms_needbot 1

# mass.tcl settings
set nb_component(mass) 0
set ma_reason "closing temporarily"

# repeat.tcl settings
set nb_component(repeat) 0
set rp_chans ""
set rp_echans ""
set rp_efficient 1
set rp_exempt "f|f"
set rp_warning 0
set rp_kflood 3:60
set rp_kreason "stop repeating"
set rp_bflood 5:60
set rp_breason "repeat flood"
set rp_sflood 3:240
set rp_sreason "stop repeating"
set rp_slength 40
set rp_mtime 240
set rp_mreason "multiple repeat floods"
set rp_btime 60

# sentinel.tcl settings
set nb_component(sentinel) 0
set sl_bcflood 5:30
set sl_bmflood 6:20
set sl_ccflood 5:20
set sl_txflood 8:30
set sl_boflood 4:20
set sl_jflood 6:20
set sl_nkflood 6:20
set sl_txlength 200
set sl_nclength 1
set sl_tsunami 10
set sl_linecap 80:30
set sl_locktimes {i:120 m:60}
set sl_shortlock 0
set sl_ban 1440
set sl_boban 1440
set sl_globalban 0
set sl_wideban 1
set sl_banmax 100
set sl_igtime 240
set sl_masktype 0
set sl_bfmaxbans 19
set sl_note "YourNick"
set sl_cfnotice "Channel locked temporarily due to flood, sorry for any inconvenience this may cause :-)"
set sl_bfnotice "Channel locked temporarily due to full ban list, sorry for any inconvenience this may cause :-)"
set sl_lockcmds 2
set sl_lockflags "o"
set sl_bxsimul 0

# superbitch.tcl settings
set nb_component(superbitch) 0
set sb_chans ""
set sb_canop "m|m"
set sb_canopflags "o|o"
set sb_canopany "b|-"
set sb_remove 0
set sb_note "YourNick"
set sb_checkop 0

# These lines make sure your bot and netbots directories are secure by
# setting their permissions to rwx------.
catch {exec chmod 700 [pwd]}
catch {exec chmod 700 $nb_dir}
