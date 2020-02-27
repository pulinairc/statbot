#  Author: EToS
#  Date: 30/04/2008
#  Filename: twitter.tcl
#  Function: Eggdrop interface to twitters API via Curl
#
#  Notes: Enable with .chanset #channel +twitter
#
#  History:  - added some namespace stuff
#            - added some special char fixing


# work chan flags ..
setudef flag twitter

# vars
set ::setup(trigger)   "!twitter"

set ::setup(apibase)   "http://twitter.com/"
set ::setup(apiupdate) "statuses/update.xml"
set ::setup(url)       $::setup(apibase)$::setup(apiupdate)

set ::setup(user)      "pulinainfo"
set ::setup(pass)      "lk3kRBk6i"
set ::setup(curl)      "/usr/bin/curl"

set ::setup(confirm)   "\002Success!\017 @ $::setup(apibase)$::setup(user)"

# binds
bind pub - $::setup(trigger) twitcl:twitter

############################################


proc twitcl:twitter {nick uhost handle channel text} {
  global twitcl
  set text [twitcl:mapevil $text]

  if {[catch {exec $::setup(curl) -u $::setup(user):$::setup(pass) -s -F status=$text $::setup(url)} result]} {

      putquick "PRIVMSG $channel : \002Err.. Something b0rked!\017"

  } else {

      putquick "PRIVMSG $channel : $::setup(confirm)"
  }

}


# map 'em evil chars
proc twitcl:mapevil {string} {
  global twitcl
  return [string map {\< &lt; \> &gt;} $string]
}


putlog "Script loaded: Twitter v1.1 *BeTA* \00302\002(C) 2008 EToS"