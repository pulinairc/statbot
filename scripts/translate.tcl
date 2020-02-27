# Babelfish Translator for eggdrop
#
# Description : Uses babelfish.altavista.com to translate text between
# specified languages
#
# Features: Multi-Threaded to prevent stalling out of eggdrop on
# multiple requests.  Allows for private messaging.
#
# Author: eRUPT (erupt@ruptbot.com)


#Allow guests access? (Non +v/+o channel users) [0=Yes, 1=No]
set babelfish(guests) 0

set babelfish(ver) v0.4


#########
#Version History
#
# - 0.1 -
# First release.
#
# - 0.2 -
# Babelfish redid submit forms.
#
#- 0.3 -
# Added more languages.
#
#- 0.3b -
# Shortcut notice error.
#
#- 0.4  -
# Babelfish redid submit forms/urls.
#
###################### 

package require http

bind pub -|- !tr pub_babelfish

proc putnot {nick msg} { putserv "NOTICE $nick :$msg" }

proc fetch_babelfish {nick chan lang text} {
  global tokens
  if {[info tclversion]>8.09} {
    set text [encoding convertto utf-8 $text]
  }
  set querytext [http::formatQuery enc utf8 doig done BabelFishFrontPage yes tt urltext intl 1 urltext $text lp $lang]
  set conn [http::geturl http://babelfish.altavista.com/babelfish/tr -command handle_babelfish -query $querytext]
  set tokens($conn) "$chan $nick [unixtime]"
}

proc handle_babelfish {token} {
  global tokens
  set chan [lindex $tokens($token) 0]
  set nick [lindex $tokens($token) 1]
  set unixtime [lindex $tokens($token) 2]
  unset tokens($token)
  upvar #0 $token http
  if {$http(status)=="error"} {
    if {$http(error)!=""} {
      putserv  "PRIVMSG $chan :\002$nick\002, Virhe: $http(error)"
      return 0
    }
  }
  if {$http(status)=="timeout"} {
    putserv "PRIVMSG $chan :\002$nick\002, Virhe. Aikakatkaisu."
    return 0
  }
#  set count 1
#  set lines [split $http(body) \n]
#  foreach line $lines {
#    putlog "$count: $line"
#    incr count 1
#  }
  catch {
#  regexp "<textarea rows=\"3\" wrap=virtual cols=\"56\" name=\"q\"\>(.*)\n\</textarea>" $http(body) m translated
  regexp {<Div style=padding\:10px; lang=[a-z]*>(.*)</div></td></tr>} $http(body) m translated
  if {![info exists translated]} {
    set translated "No Results."
  }
  if {[info tclversion]>8.09} {
      set translated [encoding convertfrom utf-8 $translated]
  }
  putserv "PRIVMSG $chan :\002$nick\002, \[\002Fetched in [expr [unixtime] - $unixtime]s\002\] $translated"
  } err
  if {$err!=""} { putlog "Tcl Error: $err" }
}

proc pub_babelfish {nick uhost hand chan arg} {
  global tokens babelfish
  if {$arg==""} {
    putnot $nick "Käyttö, esim: !tr en fi bird"
    putnot $nick "Käännös privaan: !tr -p en fi bird"
    putnot $nick "Kielet: englanti(en), espanja(es), saksa(de), portugali(pt), ranska(fr), italia(it), kiina(zh), japani(ja), korea(ko), venäjä(ru)"
    putnot $nick "*Käytä joko kielen englanninkielistä nimeä (esim portugali) tai lyhennettä (esim pt)*"
    return 0
  }
  set private 0
  if {$babelfish(guests)} {
    if {![isop $nick $chan] && ![isvoice $nick $chan]} { set private 1 }
  }
  if {[set index [lsearch -exact $arg "-p"]]!="-1"} {
    set private 1
    lreplace $arg $index $index
  }
  set l1 [string tolower [lindex $arg 0]]
  set l2 [string tolower [lindex $arg 1]]
  set text [lrange $arg 2 end]
  if {$l1=="" || $l2=="" || $text==""} {
    putnot $nick "Käyttö, esim: !tr en fi bird"
    putnot $nick "Kielet: englanti(en), espanja(es), saksa(de), portugali(pt), ranska(fr), italia(it), kiina(zh), japani(ja), korea(ko), venäjä(ru)"
    putnot $nick "*Käytä joko kielen englanninkielistä nimeä (esim portugali) tai lyhennettä (esim pt)*"
    return 0
  }
  array set langs "english en spanish es german de portuguese pt french fr italian it chinese zh japanese ja korean ko russian ru"
  foreach lang [list $l1 $l2] {
    set go 1
    foreach l [array names langs] {
      if {$l==$lang || $langs($l)==$lang} { set go 0 }
    }
    if {$go} {
      putnot $nick "Kieli \002$lang\002 ei näytä olevan oikein."
      putnot $nick "Kielet: englanti(en), espanja(es), saksa(de), portugali(pt), ranska(fr), italia(it), kiina(zh), japani(ja), korea(ko), venäjä(ru)"
     return 0
    }
  }
  foreach array [array names tokens] {
    if {$nick=="[lindex $tokens($array) 1]"} {
      if {[expr [unixtime] - [lindex $tokens($array) 2]]>300} {
  unset tokens($array)
      } else {
    putnot $nick "Sinulla on yksi käännös jo auki. Odota, senkin possu."
    return 0
  }
    }
  }
  foreach l [array names langs] {
    if {[string tolower $l1]==[string tolower $l]} {
      set l1 $langs($l)
    }
    if {[string tolower $l2]==[string tolower $l]} {
      set l2 $langs($l)
    }
  }
  set lang ${l1}_${l2}
  if {$private} { set chan $nick }
  fetch_babelfish $nick $chan $lang $text
  return 1
}

putlog "Script loaded: \002Babelfish Translator for eggdrop $babelfish(ver) by eRUPT(erupt@ruptbot.com)\002"
