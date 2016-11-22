# kummitus IRC bot

Current version of the eggdrop bot kummitus (Finnish for "ghost"). Mostly Finnish stuff. Some scripts programmed by [Roni "rolle" Laukkarinen](https://github.com/ronilaukkarinen), others downloaded from [egghelp.org](http://www.egghelp.org/tcl.htm).

Feel free to send a pull request if you spot any bugs.

## Scripts loaded

- **cellgen.tcl** - Containing a group of frequently used functions when scripting an eggdrop bot.
- **userinfo.tcl** - Enhances the `whois' output utilizing the `whois-fields' option of eggdrop 1.1-grant and later versions.  It adds the functionality of whois.tcl used in pre-1.1-grant versions.
- **alltools.tcl** - TCL Functions
- **compat.tcl** - Quickly maps old Tcl functions to the new ones
- **toolbox.tcl** - Part of the ASCEND Tcl/Tk Interface.
- **sysinfo.tcl** - Shows the system information of the bot's machine.
- **remind.tcl** - Add reminders
- **rolle.tcl** - General #pulina related commands
- **pvm.tcl** - Get current Finnish date and other info about the day
- **toptod.tcl** - Displays top-10 IRC chatters today with !toptod
- **valimatkat.tcl** - Fetches the kilometres between locations
- **battle.tcl** - The infamous battle script
- **keksi.tcl** - Makes up things to do
- **html2.tcl** - Prints info about the current users on channel. Used for [this page](http://peikko.us/pulina.html) which is in use in [official channel website pulina.fi](https://www.pulina.fi).
- **[horoskooppi.tcl](https://github.com/pulinairc/horoskooppi)** - Fetches Finnish horoschope from Iltalehti. Has its own repo [here](https://github.com/pulinairc/horoskooppi).
- **randommovies.tcl** - Suggest a random movie from IMDb
- **[eggdrop-fmi.tcl](https://github.com/pulinairc/eggdrop-fmi)** - Fetches Finnish weather from ilmatieteenlaitos.fi. Has its own repo [here](https://github.com/pulinairc/eggdrop-fmi).
- **[telkku.tcl](https://github.com/pulinairc/eggdrop-fmi)** - A TV script for eggdrop. Fetches Finnish TV programs to IRC channel. Has its own repo [here](https://github.com/pulinairc/telkku).
- **peak.tcl** - Keeps a record of the peak amount of users in a channel.
- **urltitle.tcl** - Detects URL from IRC channels and prints out the title
- **lilyurl_logger.tcl** - Scans links in IRC channels and returns titles and tinyurl, and logs to a webpage.
- **olenaa.tcl** - Joo mäki oon servu. :P

## Contributing

### Fixing bugs

Feel free to clone repo or do minor edits to the scripts if you spot any bugs.

### Making your own script

If you have ideas how to improve the bot or even rewrite it in python, feel free to do so. However, currently you can code your own scripts in TCL with these simple steps:

1. Fork this repo
2. Create a new tcl file to scripts folder
3. Edit [kummitus.conf](https://github.com/pulinairc/kummitus/blob/master/kummitus.conf) and add line `source /home/rolle/pulinairc-repos/kummitus/scripts/yourscript.tcl` where **yourscript.tcl** is obviously the actual file name.
4. Do a pull request
5. Wait for merge

You can install your own eggdrop for development or we can test it live!!!11

## Full filetree of ~/eggdrop

As of 2016-11-22:

````
cache
core
data
DEBUG
doc
eggdrop
eggdrop-1.6.19
eggdrop-1.6.21
eggdrop.chan
eggdrop.chan~bak
eggdrop.conf
eggdrop_ircnet.chan
eggdrop_ircnet.chan~bak
eggdrop.user
eggdrop.user.back2
eggdrop.user~bak
errors.log
filesys
gseen.conf
gseen.dat
help
home
https:
infos.log
kummitus.conf
kummitus_ircnet.conf
kysymykset.txt
language
linkit
links_alajarve1a
links_alajarvela
links_allysyn
links_ALTHiR
links_aniC
links_Anic
links_Anicyna
links_Aswa
links_Avaruusnuija
links_Barrelrider
links_Beat
links_blitzzer
links_Blitzzer
links_carlla
links_Carrlla
links_chq-
links_comah
links_dafis
links_discodahliaargh
links_doukki
links_Downbeat
links_Egmont
links_Eponyymi
links_Eraseri
links_Fannyanniina
links_filanca
links_FIN|M1xu
links_firewalker
links_fusil
links_fusili
links_futuristi
links_fveitsi
links_fveitsi_
links_gerry_
links_Gerrye
links_Haavi
links_Hcc
links_hekez
links_Hekez-
links_HelvetinEnkeli
links_HelvetinPerkele
links_helyes
links_Henkkuli
links_Hexa
links_Hiiva
links_HJP
links_HoocH_
links_hoorleekare
links_Hoorleekare
links_HURR_DURR_DERP
links_incdd
links_jan_
links_jan__
links_JaskaJ
links_JASMINE683
links_Jellona
links_jennamon
links_Jokurandom
links_Kauhukomedia
links_Kiazma
links_kit
links_klbz
links_Kopsu
links_kuolematon
links_kuonalasti
links_Lareynax
links_laughing
links_Lavagulin
links_lithi
links_luxan
links_M1xu
links_Majesty
links_mann
links_mansi
links_matkum
links_maza-
links_Merikarhu
links_Metsamies
links_midii
links_mippe
links_miru
links_moelsky
links_Monster1
links_Morgan
links_Morgan_
links_Muffinssi
links_mustikkasoppa
links_mynta
links_myntae
links_Naama
links_Neidori
links__neito_
links_Nekroman
links_Nettiritari
links_Nicd
links_Niffu
links_Nisha
links_nokkosmies
links_Nulleeet
links_paveq
links_petkele
links_PHILPANDA
links_pippau
links_psailosoof
links_Psychoman
links_Puusto
links_RapuRauta
links_Reijo
links_Reijo^
links_rengel
links_rolle
links_RouVix
links_rouzna
links_s13ge
links_s13gshell
links_Safti
links_SAFTI
links_samis
links_samiy
links_Schim
links_scolorscale
links_Scrin
links_\ScriNSA
links_Sgtmurder
links_Sikanaama
links_sirhoksu
links_SnowflakeBlond
links_Soothe
links_TABATHA364
links_tani
links_Tattoo
links_Temehi
links_tietopankki
links_tiipe
links_TiTii
links_Tompsimondi
links_topsi
links_Tuhomunmo
links_Tuhoutumaton
links_Tukkis
links_TukkiSS
links_Tvhovtvmaton
links_vike91
links_Vike91
links_viznut
links_vpv
links_Wootteri
links_Yaccu
links_ylitalo
links_Yoa
links_zertap
logs
megahal.aux
megahal.ban
megahal.brn
megahal.brn.2015
megahal.brn.backup
megahal.brn.tuhottu.27.4.2010
megahal.brn.varmuuskopio-0911231451
megahal.brn.wat.tuhottu.3.4.2012
megahal.data
megahal.dic
megahal.grt
megahal.learnfile
megahal.learnfile.backup
megahal.old
megahal.phr
megahal.swp
megahal.trn
modules
modules-1.6.19
modules-1.6.21
pulinacomments.db
pulina.db
ques
quotes.txt
README
scripts
scrobd_errors.log
scrobd_infos.log
scrobd.pid
sqlite3-tcl-3.7.8-1.1.2.x86_64.rpm
sqlite-autoconf-3080100
sqlite-autoconf-3080100.tar.gz
sqlite-tcl-3.7.16-77.3.x86_64.rpm
src
t2.badqes
t2.commands
t2.hist
t2.hist.1333486806.bak
t2.hist.info
t2.kcount
t2.qcount
t2.settings
tcl8.5.15
tcl8.5.15-src.tar.gz
tcllib
tdom-0.8.2-6.el6.i686.rpm
tDOM-0.8.3
tDOM-0.8.3.tgz
text
tk-32bit-8.5.11-2.1.2.x86_64.rpm
tls1.6
tls1.6-src.tar.gz
twitter.dat
twitter.last_id
urllog.db
urllog.sqlite
urlmagic.db
userfiles.backup
webby.txt
````
