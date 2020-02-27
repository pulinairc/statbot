#---------------------------------------------------------------------#
# incith:xrl                                             $Rev:: 94  $ #
# $Id:: incith-xrl.tcl 94 2009-01-21 05:53:33Z incith               $ #
#                                                                     #
# performs automatic and manual (un)shortening of URLs.               #
# currently supported: xrl.us, tinyurl.com, x0.no                     #
# tested on Eggdrop v1.6.19 & Windrop v1.6.17                         #
#                                                                     #
# Usage:                                                              #
#   .chanset #channel +xrl                                            #
#   !shorten <url> (be sure to look at the service_type variable)     #
#   !lengthen <http://xrl.us/a1b2> <a1b2>                             #
#     - you must specify the whole URL if you use 'service_type 0'    #
#                                                                     #
# ChangeLog (m/d/y):                                                  #
#   1/17/09: added botnet code.  license changed to GPLv3.            #
#   1/15/09: 2.5e released.                                           #
#   1/14/09: x0.no added, various fixes and cleanups.                 #
#                                                                     #
# TODO:                                                               #
#   - store last URL for each nickname, !lasturl/!shorten <nick>      #
#   - Local caching of URLs, as not to 'flood' xrl.us?                #
#   - Optional redundancy on failed shortens.                         #
#   - Suggestions/Thanks/Bugs/Ideas, e-mail at bottom of header.      #
#                                                                     #
# LICENSE (GPLv3):                                                    #
#   This program is free software: you can redistribute it and/or     #
#   modify it under the terms of the GNU General Public License as    #
#   published by the Free Software Foundation, either version 3 of    #
#   the License, or (at your option) any later version.               #
#                                                                     #
#   This program is distributed in the hope that it will be useful,   #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of    #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              #
#                                                                     #
#   See the GNU General Public License for more details.              #
#   (http://www.gnu.org/licenses/gpl-3.0.txt)                         #
#                                                                     #
# Copyright (C) 2009, Jordan                                          #
# http://incith.com ~ incith@gmail.com ~ irc.freenode.net/#incith     #
#---------------------------------------------------------------------#
package require http 2.3
setudef flag xrl

# 0 (zero) will disable an optional variable, 1 or above enables
#
namespace eval incith::xrl {
  # the bind prefix/command char(s) ({!} or {! .} etc, separate with space)
  variable command_chars {! .}

  # binds for shortening a url manually ("one two") as many as you need.
  # I don't want to make each service a separate procedure, so you can either use them all or
  # choose a specific one to use with service_type below, and adjust your shorten_binds.
  variable shorten_binds {shorten xrl tiny x0}

  # !lasturl will show the last stored URL for a nick or channel
  variable lasturl_binds {lasturl}

  # binds for lengthening a url manually ({one two}) as many as you need.
  # x0.no has no un-shorten feature.
  variable xrl_lengthen_binds {lengthen unxrl}
  variable tinyurl_lengthen_binds {untiny}

  # which host should we use to shorten url's with?
  # 0: make use of all of them (first !shorten will use xrl, then tinyurl, etc)
  # 1: xrl.us
  # 2: tinyurl.com
  # 3: x0.no
  variable service_type 3

  # bind/allow private messages?
  variable private_messages 1

  # send public/channel output to the user instead?
  variable public_to_private 0

  # send replies as notices instead of private messages?
  variable notices 0

  # only send script 'errors' as notices? (not enough input etc)
  variable notice_errors_only 0

  # if you're using a proxy, enter it here {example.com:3128}
  variable proxy {}

  # minimum length a url has to be to auto-shorten it (0 disables auto-shorten)
  variable minimum_length 30

  # if your bots participate in a botnet, you can enable this variable
  # and load the script on all of the bots, but only one bot will respond
  # to xrl requests.  if that bot quits, the next bot in line will start.
  # there is no reason to disable this variable that I can think of.
  variable botnet 1
}

# script begins
namespace eval incith::xrl {
  global botnet-nick nick
  if {${botnet-nick} == ""} { set botnet-nick ${nick} }
  variable version {incith-xrl-r94}
  array set static {}
  if {${incith::xrl::botnet} >= 1} {
    set static(botnet,${botnet-nick},time) [clock seconds]
  } else {
    set static(botnet,${botnet-nick},time) "noswarm"
  }
  if {![info exists static(botnet,bots)]} {
    set static(botnet,bots) ${botnet-nick}
  }
}

bind pubm -|- "*" incith::xrl::message_handler
if {$incith::xrl::private_messages >= 1} {
  bind msgm -|- "*" incith::xrl::message_handler
}

# bind the botnet binds
if {${incith::xrl::botnet} >= 1} {
  bind bot - incith:xrl incith::xrl::bot_msg
  bind link - * incith::xrl::bot_link
  # it really depends what works better for you, checking if
  # the bot is onchan or just making sure they are linked.
  # bind disc - * incith::xrl::bot_disc
}

namespace eval incith::xrl {
  proc bot_msg {from cmd text} {
    global botnet-nick
    upvar #0 incith::xrl::static static
    if {${incith::xrl::debug} >= 1} {
      putlog "${incith::xrl::version} (botmsg): <${from}> ${cmd} ${text}"
    }

    # receiving a bots load time
    if {[string match "time ?*" $text]} {
      regexp -- {time (.*)} $text - time
      set static(botnet,${from},time) $time
      # make sure this bot is in our bot list
      if {![string match "*${from}*" $static(botnet,bots)]} {
        putlog "${incith::xrl::version} (botnet): ${from} has joined the incith:xrl swarm."
        append static(botnet,bots) ";${from}"
        regsub -all -- {;;} $static(botnet,bots) {;} static(botnet,bots)
        set static(botnet,bots) [string trimright $static(botnet,bots) {;}]
      }
    }
  }

  proc bot_link {bot hub} {
    global botnet-nick
    upvar #0 incith::xrl::static static
    # send our time to the bots
    putallbots "incith:xrl time $static(botnet,${botnet-nick},time)"
  }

  proc bot_disc {bot} {
    global botnet-nick
    upvar #0 incith::xrl::static static
    if {[string match "*${bot}*" $static(botnet,bots)]} {
      if {$static(botnet,${bot},time) != "noswarm"} {
        putlog "${incith::xrl::version} (botnet): ${bot} has left the incith:xrl swarm."
      }
    }
    # remove this bot from our bot list
    regsub -all -- $bot $static(botnet,bots) {} static(botnet,bots)
    regsub -all -- {;;} $static(botnet,bots) {;} static(botnet,bots)
    set static(botnet,bots) [string trimright $static(botnet,bots) {;}]
    # remove their time?  If they just lost link, they might still be [onchan]
    # unset static(botnet,${bot},time)
  }
}


namespace eval incith::xrl {
  proc message_handler {nick uhand hand args} {
    global botnick botnet-nick
    upvar #0 incith::xrl::static static
    set input(who) $nick
    if {[llength $args] >= 2} { # public message
      set input(where) [lindex $args 0]
      if {${incith::xrl::public_to_private} >= 1} {
        set input(chan) $input(who)
      } else {
        set input(chan) $input(where)
      }
      set input(query) [lindex $args 1]
      if {[channel get $input(where) xrl] != 1} {
        return
      }
    } else {                    # private message
      set input(where) "private"
      set input(chan) $input(who)
      set input(query) [lindex $args 0]
      if {${incith::xrl::private_messages} <= 0} {
        return
      }
    }

    # botnet
    if {${incith::xrl::botnet} >= 1 && $input(where) != "private"} {
      foreach bot [split $static(botnet,bots) ";"] {
        # skip ourselves, bots not on the input channel, and bots not participating
        if {${bot} == ${botnet-nick} || ![onchan ${bot} $input(where)] || $static(botnet,${bot},time) == "noswarm"} {
          continue
        # bots that load first will serve first.  change < to > to reverse.
        } elseif {$static(botnet,$bot,time) < $static(botnet,${botnet-nick},time)} {
          putlog "${incith::xrl::version} (botnet): $bot loaded before me."
          return
        # should 2 bots have the same time, set a new random time (this did happen in testing)
        } elseif {$static(botnet,${bot},time) == $static(botnet,${botnet-nick},time)} {
          putlog "${incith::xrl::version} (botnet): $bot had the same load time as me!"
          set static(botnet,${botnet-nick},time) [expr [clock seconds] + int(rand()*60)+1]
          putallbots "incith:xrl time $static(botnet,${botnet-nick},time)"
          return
        }
      }
      # looks like we're serving, make sure we keep the botnet up to date
      putallbots "incith:xrl time $static(botnet,${botnet-nick},time)"
    }

    # used below
    set input(query) [string trim $input(query)]
    set input(who_sane) [make_sane_nick $input(who)]

    # urlre2 is a mod I did to the original to support www as a valid prefix, if I could have
    # done it better please contact me.
    set urlre {((https?)://((?:(?:(?:(?:(?:[a-zA-Z0-9][-a-zA-Z0-9]*)?[a-zA-Z0-9])[.])*(?:[a-zA-Z][-a-zA-Z0-9]*[a-zA-Z0-9]|[a-zA-Z])[.]?)|(?:[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+)))(?::((?:[0-9]*)))?(/(((?:(?:(?:(?:[a-zA-Z0-9\-_.!~*.():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)(?:;(?:(?:[a-zA-Z0-9\-_.!~*.():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*))*)(?:/(?:(?:(?:[a-zA-Z0-9\-_.!~*.():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)(?:;(?:(?:[a-zA-Z0-9\-_.!~*.():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*))*))*))(?:[?]((?:(?:[;/?:@&=+$,a-zA-Z0-9\-_.!~*.()]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)))?))?)}
    set urlre2 {((https?://|www[0-9]*\.)((?:(?:(?:(?:(?:[a-zA-Z0-9][-a-zA-Z0-9]*)?[a-zA-Z0-9])[.])*(?:[a-zA-Z][-a-zA-Z0-9]*[a-zA-Z0-9]|[a-zA-Z])[.]?)|(?:[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+)))(?::((?:[0-9]*)))?(/(((?:(?:(?:(?:[a-zA-Z0-9\-_.!~*.():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)(?:;(?:(?:[a-zA-Z0-9\-_.!~*.():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*))*)(?:/(?:(?:(?:[a-zA-Z0-9\-_.!~*.():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)(?:;(?:(?:[a-zA-Z0-9\-_.!~*.():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*))*))*))(?:[?]((?:(?:[;/?:@&=+$,a-zA-Z0-9\-_.!~*.()]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)))?))?)}

    # check for lasturl
    foreach command_char [split [string trim $incith::xrl::command_chars] " "] {
      foreach bind [split [string trim $incith::xrl::lasturl_binds] " "] {
        # no input given
        if {[string match -nocase "${command_char}${bind}" $input(query)] == 1} {
          ipl $input(who) $input(where) $input(query)
          send_output $input(chan) "Syntax: ${command_char}${bind} <nick|channel>"
          return 1
        }
        if {[string match -nocase "${command_char}${bind} *" $input(query)] == 1} {
          ipl $input(who) $input(where) $input(query)
          regexp -nocase -- "${command_char}${bind}\\s*(.*)\\s*$" $input(query) - input(query)
          if {[info exists static([string tolower $input(query)],last_url)]} {
            set input(query_sane) [make_sane_nick $input(query)]
            send_output $input(chan) "$input(query_sane) last url: $static([string tolower $input(query)],last_url)"
          } else {
            send_output $input(chan) "$input(query) has no last URL." $input(who)
          }
          return 1
        }
      }
    }

    # check for !shorten
    foreach command_char [split [string trim $incith::xrl::command_chars] " "] {
      foreach bind [split [string trim $incith::xrl::shorten_binds] " "] {
        # no input given
        if {[string match -nocase "${command_char}${bind}" $input(query)] == 1} {
          ipl $input(who) $input(where) $input(query)
          if {$input(where) != "private" && [info exists static($input(chan),last_url)]} {
            send_output $input(chan) "[shorten $static($input(chan),last_url) $input(chan)] (from $static([string tolower $input(chan)],last_nick): $static([string tolower $input(chan)],last_url))"
          } else {
            send_output $input(chan) "Syntax: ${command_char}${bind} <long url|nickname>" $input(who)
          }
          return 1
        }
        if {[string match -nocase "${command_char}${bind} *" $input(query)] == 1} {
          ipl $input(who) $input(where) $input(query)
          regexp -nocase -- "${command_char}${bind}\\s*(.*)\\s*$" $input(query) - input(query)
          regexp -nocase -- "${urlre2}" $input(query) - url

          if {![info exists static([string tolower $input(query)],last_url)]} {
            if {![info exists url]} { set url $input(query) }
            if {[string match -nocase "*xrl.us*" $url] || [string match -nocase "*tinyurl.com*" $url] || [string match -nocase "*x0.no*" $url]} {
              send_output $input(chan) "Invalid URL." $input(who)
              return 1
            }
            send_output $input(chan) "\002Lyhennetty osoite:\002 [shorten $url $input(chan)]"
            return 1
          } else {
            set input(query_sane) [make_sane_nick $input(query)]
            send_output $input(chan) "shortening $input(query_sane) last url: [shorten $static([string tolower $input(query)],last_url) $input(chan)] ($static([string tolower $input(query)],last_url))"
          }
          return 1
        }
      }
    }

    # check for xrl !lengthen
    foreach command_char [split [string trim $incith::xrl::command_chars] " "] {
      foreach bind [split [string trim $incith::xrl::xrl_lengthen_binds] " "] {
        # no input given
        if {[string match -nocase "${command_char}${bind}" $input(query)] == 1} {
          ipl $input(who) $input(where) $input(query)
          # log it
          send_output $input(chan) "Syntax: ${command_char}${bind} <short url>" $input(who)
          return 1
        }
        if {[string match -nocase "${command_char}${bind} *" $input(query)] == 1} {
          ipl $input(who) $input(where) $input(query)
          regexp -nocase -- "${command_char}${bind}\\s*(.*)\\s*$" $input(query) - input(query)
          set url $input(query)
          if {[string match {*xrl.us*} $url] == 1} {
            regexp -nocase -- {xrl\.us/(.+)$} $url - url
          }
          send_output $input(chan) "Pidennetty osoite: [xrl_lengthen $url]"
          return 1
        }
      }
    }

    # check for tinyurl !lengthen
    foreach command_char [split [string trim $incith::xrl::command_chars] " "] {
      foreach bind [split [string trim $incith::xrl::tinyurl_lengthen_binds] " "] {
        # no input given
        if {[string match -nocase "${command_char}${bind}" $input(query)] == 1} {
          ipl $input(who) $input(where) $input(query)
          # log it
          send_output $input(chan) "Syntax: ${command_char}${bind} <short url>" $input(who)
          return 1
        }
        if {[string match -nocase "${command_char}${bind} *" $input(query)] == 1} {
          ipl $input(who) $input(where) $input(query)
          regexp -nocase -- "${command_char}${bind}\\s*(.*)\\s*$" $input(query) - input(query)
          set url $input(query)
          if {[string match -nocase {*tinyurl.com*} $url] == 1} {
            regexp -nocase -- {tinyurl\.com/(.+)$} $url - url
          }
          send_output $input(chan) "Pidennetty osoite: [tinyurl_lengthen $url]"
          return 1
        }
      }
    }

    # check for auto-shorten
    if {[regexp -- "${urlre2}" $input(query) - auto_shorten_url] == 1} {
      # ignore urls the bot says
      if {$input(who) == $botnick} {
        return
      }

      if {[info exists auto_shorten_url] == 1} {
        # store it
        if {$input(where) != "private"} {
          if {![string match -nocase "*tinyurl.com*" $auto_shorten_url] && ![string match -nocase "*xrl.us*" $auto_shorten_url] && ![string match -nocase "*x0.no*" $auto_shorten_url]} {
            set static([string tolower $input(chan)],last_url) $auto_shorten_url
            set static([string tolower $input(who)],last_url) $auto_shorten_url
            set static([string tolower $input(chan)],last_nick) $input(who)
          }
        }

        # check length of url
        if {[string length $auto_shorten_url] < $incith::xrl::minimum_length || $incith::xrl::minimum_length == 0} {
          return
        } else {
          ipl $input(who) $input(where) "auto-shortening $auto_shorten_url"
          # shorten it
          set url [shorten $auto_shorten_url $input(chan)]
          if {[info exists url]} {
            send_output $input(chan) "\002Lyhennetty osoite\002: $url"
            return 1
          }
        }
        return
      }
      return
    }
  }

  # [send_output] : sends $data appropriately out to $where
  #
  proc send_output {where data {isErrorNick {}}} {
    if {${incith::xrl::notices} >= 1} {
      putquick "NOTICE $where :${data}"
    } elseif {${incith::xrl::notice_errors_only} >= 1 && $isErrorNick != ""} {
      putquick "NOTICE $isErrorNick :${data}"
    } else {
      putquick "PRIVMSG $where :${data}"
    }
  }

  # [ipl] : a neat/handy putlog procedure
  #
  proc ipl {who {where {}} {what {}}} {
    if {$where == "" && $what == ""} {
      # first argument only = data only
      putlog "${incith::xrl::version}: ${who}"
    } elseif {$where != "" && $what == ""} {
      # two arguments = who and data
      putlog "${incith::xrl::version}: <${who}> ${where}"
    } else {
      # all three...
      putlog "${incith::xrl::version}: <${who}/${where}> ${what}"
    }
  }

  # reused code
  proc make_sane_nick {nick} {
    if {[string match -nocase "*s" $nick]} {
      append nick {'}
    } else {
      append nick {'s}
    }
    return $nick
  }

  # tiny.cc
  # memurl.com
  # kortlink.dk (korturl.dk?)

  # SHORTEN
  # chooses a shortening service to use
  #
  proc shorten {input where} {
    upvar #0 incith::xrl::static static
    set input [fix_bad_codes $input]
    if {![info exists static($where,last_service)]} {
      set static($where,last_service) 1
    }

    # xrl
    if {$incith::xrl::service_type == 1 || ($static($where,last_service) == 1 && $incith::xrl::service_type == 0)} {
      set url [xrl_shorten $input]
    }
    # tinyurl
    if {$incith::xrl::service_type == 2 || ($static($where,last_service) == 2 && $incith::xrl::service_type == 0)} {
      set url [tinyurl_shorten $input]
    }
    # x0.no
    if {$incith::xrl::service_type == 3 || ($static($where,last_service) == 3 && $incith::xrl::service_type == 0)} {
      set url [x0_shorten $input]
    }
    # basically 1 = xrl, 2 = tiny, etc, going from 1 to 2, 2 to 3, and 3 back to 1, to repeat our cycle
    if {$incith::xrl::service_type == 0} {
      set static($where,last_service) [string map {1 2 2 3 3 1} $static($where,last_service)]
    }
    if {[info exists url]} {
      return $url
    } else {
      return "Unknown error, sorry."
    }
  }

  # XRL_SHORTEN
  # shortens a long url with xrl.us
  #
  proc xrl_shorten {input} {
    set query "http://metamark.net/api/rest/simple?long_url=$input"
    # setup the timeout, for use below
    set timeout [expr round(1000 * 15)]
    # setup proxy information, if any
    if {[string match {*:*} ${incith::xrl::proxy}] == 1} {
      set proxy_info [split ${incith::xrl::proxy} ":"]
    }
    if {[info exists proxy_info] == 1} {
      ::http::config -proxyhost [lindex $proxy_info 0] -proxyport [lindex $proxy_info 1]
    }
    set html [::http::geturl "$query" -timeout $timeout]
    set url [lindex [split [::http::data $html] \n] 0]
    if {[info exists url]} {
      return $url
    } else {
      return "Could not shorten link, unknown error.  Please try again."
    }
  }
  # XRL_LENGTHEN
  # returns the url that a shortened url points to
  #
  proc xrl_lengthen {input} {
    set query "http://metamark.net/api/rest/simple?short_url=${input}"
    # setup the timeout, for use below
    set timeout [expr round(1000 * 15)]
    # setup proxy information, if any
    if {[string match {*:*} ${incith::xrl::proxy}] == 1} {
      set proxy_info [split ${incith::xrl::proxy} ":"]
    }
    if {[info exists proxy_info] == 1} {
      ::http::config -proxyhost [lindex $proxy_info 0] -proxyport [lindex $proxy_info 1]
    }
    set html [::http::geturl "$query" -timeout $timeout]
    set url [lindex [split [::http::data $html] \n] 0]
    if {[info exists url]} {
      return [unfix_bad_codes $url]
    } else {
      return "Could not un-shorten link, unknown error. Please try again."
    }
  }

  # TINYURL_SHORTEN
  # shortens a long url with tinyurl.com
  #
  proc tinyurl_shorten {input} {
    set query "http://tinyurl.com/create.php?url=$input"
    # setup the timeout, for use below
    set timeout [expr round(1000 * 15)]
    # setup proxy information, if any
    if {[string match {*:*} ${incith::xrl::proxy}] == 1} {
      set proxy_info [split ${incith::xrl::proxy} ":"]
    }
    if {[info exists proxy_info] == 1} {
      ::http::config -proxyhost [lindex $proxy_info 0] -proxyport [lindex $proxy_info 1]
    }
    set html [::http::data [::http::geturl "$query" -timeout $timeout]]
    regexp -- {<small>\[<a href="(.+?)" target="_blank">Open in new window</a>\]</small></blockquote>} $html - url
    if {[info exists url]} {
      return $url
    } else {
      return "Could not shorten link, unknown error.  Please try again."
    }
  }
  # TINYURL_LENGTHEN
  # returns the url that a shortened url points to
  #
  proc tinyurl_lengthen {input} {
    set query "http://preview.tinyurl.com/${input}"
    # setup the timeout, for use below
    set timeout [expr round(1000 * 15)]
    # setup proxy information, if any
    if {[string match {*:*} ${incith::xrl::proxy}] == 1} {
      set proxy_info [split ${incith::xrl::proxy} ":"]
    }
    if {[info exists proxy_info] == 1} {
      ::http::config -proxyhost [lindex $proxy_info 0] -proxyport [lindex $proxy_info 1]
    }
    set html [::http::data [::http::geturl "$query" -timeout $timeout]]
    if {[string match -nocase {*Unable to find site's URL*} $html] == 1} {
      return "ERROR: Unable to find site's URL to redirect to."
    }
    regexp -- {<a id="redirecturl" href="(.+?)">Proceed to this site\.</a>} $html - url
    if {[info exists url]} {
      return $url
    } else {
      return "Could not shorten link, unknown error.  Please try again."
    }
  }

  # X0_SHORTEN
  # shortens a long url with x0.no
  #
  proc x0_shorten {input} {
    set input_url "http://x0.no"
    # setup the timeout, for use below
    set timeout [expr round(1000 * 15)]
    # setup proxy information, if any
    if {[string match {*:*} ${incith::xrl::proxy}] == 1} {
      set proxy_info [split ${incith::xrl::proxy} ":"]
    }
    if {[info exists proxy_info] == 1} {
      ::http::config -proxyhost [lindex $proxy_info 0] -proxyport [lindex $proxy_info 1]
    }
    set html [::http::data [::http::geturl "$input_url" -query "longurl=${input}" -timeout $timeout]]
    regexp -- {<p class="success">Lawl, here: <a href="(.+?)">.+?</a></p>} $html - url
    regexp -- {<p class="error">(.+?)</p>} $html - error
    if {[info exists url]} {
      return $url
    } elseif {[info exists error]} {
      return "x0.no: $error"
    } else {
      return "Could not shorten link, unknown error.  Please try again."
    }
  }


  # [fix_bad_codes]: fixes up certain characters
  #
  proc fix_bad_codes {input} {
    # regsub -all -- {\%} $input {%25} input
    # regsub -all -- {\~} $input {%7E} input
    regsub -all -- {\&} $input {%26} input
    regsub -all -- {\;} $input {%3B} input
    regsub -all -- {\?} $input {%3F} input
    regsub -all -- {\[} $input {%5B} input
    regsub -all -- {\]} $input {%5D} input
    return $input
  }

  # [unfix_bad_codes] : makes urls sane again
  # http://forum.egghelp.org/viewtopic.php?p=81304#81304
  #
  proc unfix_bad_codes {text} { 
    set url "" 
    regsub -all {\%([0-9a-fA-F][0-9a-fA-F])} $text {[format %c 0x\1]} text 
    set text [subst $text] 
    foreach byte [split [encoding convertto utf-8 $text] ""] {
      scan $byte %c i 
      if { $i < 33 || $i > 127 } { 
        append url [format %%%02X $i] 
      } else { 
        append url $byte 
      } 
    } 
    return $url 
  }
}

# the script has loaded.
namespace eval incith::xrl {
  putallbots "incith:xrl time $static(botnet,${botnet-nick},time)"
}
incith::xrl::ipl "loaded."

# EOF
