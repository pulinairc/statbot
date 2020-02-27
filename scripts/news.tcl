# News Syndication for Atom and RSS feeds
# Copyright (C) 2004-2006 perpleXa
#
# http://perplexa.ugug.co.uk / #perpleXa on QuakeNet
#
# Using parsexmldata funtion of rss-synd.tcl.
# Copyright (C) 2005 Andrew Scott
#
# Redistribution, with or without modification, are permitted provided
# that redistributions retain the above copyright notice, this condition
# and the following disclaimer.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.
#
# Requirements:
#  - fsck 1.10+ package (available at http://perplexa.ugug.co.uk)
#  - http 2.4+ package (comes with tcl)
#
# Supported feeds:
#  - Atom 1.0
#  - RSS 1.0
#  - RSS 2.0
#
# To add your own feeds, simply customise the config file.
# Use the syntax shown in news.conf.

package require fsck 1.10;
package require http;

namespace eval news {
  # Location of this script's config file.
  # Default set to the same directory where the script is.
  # Set to something like:
  #  variable theconfig "/etc/news.conf";
  # If you want to change it.
  variable theconfig [file join [file dirname [info script]] "news.conf"];

  # Don't change stuff below this line.
  variable version "6.9";
  variable client "Mozilla/5.0 (compatible; Y!J; for robot study; keyoshid)";
  variable sections;
  array unset sections;
  bind time -|- * [namespace current]::check;
#  bind pub -|- "-news" [namespace current]::public;
bind pub -|- !rss [namespace current]::public;
  namespace export *;
}

proc news::check {args} {
  variable feedsdata;
  variable client;
  http::config -useragent $client;
  set now [unixtime];
  set timeout [getconfigitem "core" "timeout" "60"];
  foreach section [getconfigsections] {
    set u [getconfigitem $section "uri" ""];
    set l [getconfigitem $section "postlimit" [getconfigitem "core" "postlimit" "3"]];
    set c [getconfigitem $section "channels" ""];
    if {(!(($now/60) % [getconfigitem $section "interval" [getconfigitem "core" "interval" "60"]]) || \
        ![info exists feedsdata($section)]) && $u != ""} {
      catch {
        # Using asynchronous connections w/ callbacks.
        http::geturl $u -command [list [namespace current]::callback $c $section $l] -timeout [expr $timeout * 1000];
      }
    }
  }
}

proc news::public {nick host hand chan argv} {
  variable feedsdata;
  set cargc [splitline $argv cargv 1];
  if {$cargc<1} {
    puthelp "NOTICE $nick :Not enough parameters.";
    return 0;
  }
  set feed [lindex $cargv 0];
  foreach section [getconfigsections] {
    if {![string compare -nocase $feed $section]} {
      if {[info exists feedsdata($section)]} {
        set items [llength $feedsdata($section)];
        set string [getconfigitem $section "trigstring" [getconfigitem "core" "trigstring" "%title - %link"]];
        set limit [getconfigitem $section "publimit" [getconfigitem "core" "publimit" "3"]];
        if {!$limit} {set limit $items;}
        for {set i $limit} {$i} {incr i -1} {
          set elem [lindex $feedsdata($section) end-[expr $i-1]];
          if {![llength $elem]} {break;}
          announce $chan [formatoutput $string $section [lindex $elem 2] [lindex $elem 0]];
        }
        return 1;
      }
      puthelp "NOTICE $nick :No news received yet. Please try again later.";
      return 0;
    }
  }
  puthelp "NOTICE $nick :Invalid feed. (use one of: [join [getconfigsections] ", "])";
  return 0;
}

proc news::callback {chans feed limit token} {
  variable feedsdata;
  upvar 0 $token state;
  if {![string equal -nocase $state(status) "ok"]} {
    return 0;
  }
  if {([http::code $token] == 301) || ([http::code $token] == 302)} {
    foreach {key value} $state(-headers) {
      if {![string compare -nocase $key "Location"]} {
        set timeout [getconfigitem "core" "timeout" "60"];
        catch {
          http::geturl $value -command [list [namespace current]::callback $chans $feed $limit] -timeout [expr $timeout * 1000];
        }
        break;
      }
    }
    if {![info exists timeout]} {
      Error "news" WARNING "Got relocated feed ($feed) without location header.";
    }
    http::cleanup $token;
    return 0;
  }
  putquick "PING :[unixtime]";
  set data [parse [http::data $token]];
  http::cleanup $token;
  if {![llength $data]} {
    Error "news" ERROR "Failed to parse the $feed feed.";
    return 0;
  }
  set title [lindex $data 0];
  set new 0; set temp [list];
  set fetched [info exists feedsdata($feed)];
  set string [getconfigitem $feed "timestring" [getconfigitem "core" "timestring" "\[%b%feed%b\] %title - %link"]];
  set data [lsort -integer -decreasing -index 0 [lrange $data 1 end]];
  # unfortunately this part is O(n^2)
  foreach elem $data {
    if {$fetched} {
      set found 0;
      foreach item $feedsdata($feed) {
        if {![string compare [lindex $elem 1] [lindex $item 1]]} {
          set found 1;
          break;
        }
      }
      if {!$found} {
        if {[incr new] <= $limit || !$limit} {
          announce $chans [formatoutput $string $title [lindex $elem 2]];
        }
      }
    }
    lappend temp $elem;
  }
  set feedsdata($feed) $temp;
}

proc news::parse {data} {
  set items [list];
  set id 0;
  foreach {tag value} [parsexmldata $data] {
    # Atom 1.0
    if {![string compare -nocase $tag "feed"]} {
      foreach {subtag subvalue} $value {
        if {![string compare -nocase $subtag "title"]} {
          lappend items [decode $subvalue];
        } elseif {![string compare -nocase $subtag "entry"]} {
          set subtags [list];
          foreach {subtag2 subvalue2} $subvalue {
            lappend subtags $subtag2 [decode $subvalue2];
          }
          lappend items [list [incr id] [md5 $subtags] $subtags];
        }
      }
      break;
    # RSS 1.0
    } elseif {![string compare -nocase $tag "rdf:RDF"]} {
      foreach {subtag subvalue} $value {
        if {![string compare -nocase $subtag "channel"]} {
          foreach {subtag2 subvalue2} $subvalue {
            if {![string compare -nocase $subtag2 "title"]} {
              lappend items [decode $subvalue2];
            }
          }
        } elseif {![string compare -nocase $subtag "item"]} {
          set subtags [list];
          foreach {subtag2 subvalue2} $subvalue {
            lappend subtags $subtag2 [decode $subvalue2];
          }
          lappend items [list [incr id] [md5 $subtags] $subtags];
        }
      }
      break;
    # RSS 2.0
    } elseif {![string compare -nocase $tag "rss"]} {
      foreach {subtag subvalue} $value {
        if {![string compare -nocase $subtag "channel"]} {
          foreach {subtag2 subvalue2} $subvalue {
            if {![string compare -nocase $subtag2 "title"]} {
              lappend items [decode $subvalue2];
            } elseif {![string compare -nocase $subtag2 "item"]} {
              set subtags [list]; catch {unset link;}
              foreach {subtag3 subvalue3} $subvalue2 {
                lappend subtags $subtag3 [decode $subvalue3];
                if {![string compare -nocase $subtag3 "link"]} {
                  set link $subvalue3;
                }
              }
              lappend items [list [incr id] [md5 $subtags] $subtags];
            }
          }
        }
      }
      break;
    }
  }
  return $items;
}

proc news::parsexmldata {data} {
  set i 0;
  set news [list];
  set length [string length $data];
  for {set ptr 1} {$ptr <= $length} {incr ptr} {
    set section [string range $data $i $ptr];
    if {[llength [set match [regexp -inline -- {<(.[^ \n\r>]+)(?: |\n|\r\n|\r|)(.[^>]+|)>} $section]]] > 0} {
      set i [expr { $ptr + 1 }];
      set tag [lindex $match 1];
      if {([info exists current(tag)]) && ([string match -nocase $current(tag) [string map {"/" ""} $tag]])} {
        set subdata [string range $data $current(pos) [expr {$ptr - ([string length $tag] + 2)}]];
        if {[set cdata [lindex [regexp -inline -nocase -- {^(?:\s*)<!\[CDATA\[(.[^\]>]*)\]\]>} $subdata] 1]] != ""} {
          set subdata $cdata;
        }
        set result [parsexmldata $subdata];
        if {[info exists current(tmp)]} {lappend news "=$current(tag)" $current(tmp);}
        if {[llength $result] > 0} {
          lappend news $current(tag) $result;
        } else {
          regsub -nocase -all -- {\s+} $subdata " " subdata;
          lappend news $current(tag) [string trim $subdata];
        }
        unset current;
      } elseif {(![string match {[!\?]*} $tag]) && (![info exists current(tag)])} {
        set tmp [list];
        if {[lindex $match 2] != ""} {
          set values [regexp -inline -all -- {(?:\s*)(.[^=]+)="(.[^"]+)"} [lindex $match 2]];
          foreach {regmatch regtag regval} $values {
            lappend tmp $regtag $regval;
          }
        }
        if {([regexp {/(\s*)$} [lindex $match 2]]) && ([llength $tmp] > 0)} {
          lappend news "=$tag" $tmp;
        } else {
          set current(tag) [string map {"\r" "" "\n" "" "\t" ""} $tag];
          if {[llength $tmp] > 0} {set current(tmp) $tmp;}
          set current(pos) $i;
        }
        unset tmp;
      }
    }
  }
  return $news;
}

proc news::announce {chans message} {
  set noctrl [list];
  set nostrp [list];
  set chans [expr {([string compare $chans ""]) ? [split $chans " "] : [channels]}];
  foreach chan $chans {
    if {![validchan $chan]} continue;
    if {[string first "c" [lindex [split [getchanmode $chan]] 0]] >= 0} {
      lappend noctrl $chan;
    } else {
      lappend nostrp $chan;
    }
  }
  if {[llength $noctrl]} {
    set noctrl [join $noctrl ","];
    puthelp "PRIVMSG $noctrl :[stripcodes uacgbr $message]";
  }
  if {[llength $nostrp]} {
    set nostrp [join $nostrp ","];
    puthelp "PRIVMSG $nostrp :$message";
  }
}

proc news::initconfig {args} {
  variable theconfig;
  variable sections;
  if {[catch {cat $theconfig} stream]} {
    Error "news" FATAL "Couldn't load config file.";
  }
  strcom stream;
  set section "";
  foreach buf [split $stream "\n"] {
    set buf [string trim $buf];
    if {([string range $buf 0 1] == "//") || [string length $buf] < 3} continue;
    if {[string index $buf 0] == "\["} {
      set cp [string first "\]" $buf];
      if {$cp > 0} {
        set section [string range $buf 1 [expr $cp-1]];
        if {![info exists sections($section)]} {
          set sections($section) "";
        }
      }
    } else {
      if {$section == ""} continue;
      set cp [string first "=" $buf];
      if {$cp > 0} {
        set key [string range $buf 0 [expr $cp-1]];
        set value [string range $buf [expr $cp+1] end];
        for {set i 0} {$i < [llength $sections($section)]} {incr i} {
          if {![string compare $key [lindex [lindex $sections($section) $i] 0]]} {
            set sections($section) [lreplace $sections($section) $i $i];
          }
        }
        lappend sections($section) [list $key $value];
      }
    }
  }
}

proc news::getconfigitem {section key defaultvalue} {
  variable sections;
  if {![info exists sections($section)]} {
    return $defaultvalue;
  }
  foreach item $sections($section) {
    if {![string compare $key [lindex $item 0]]} {
      return [lindex $item 1];
    }
  }
  return $defaultvalue;
}

proc news::getconfigsections {args} {
  variable sections;
  set list [list];
  foreach section [array names sections] {
    if {![string compare $section "core"]} continue;
    lappend list $section;
  }
  return $list;
}

proc news::formatoutput {string feed data {id 0}} {
  set buf [regexp -inline -nocase -all -- {%([a-z\.]+)} $string];
  foreach {match item} $buf {
    if {[regexp -nocase -- {^%(b|c|r|u|x|%|feed|id)$} $match]} continue;
    if {[llength [split $item "."]] == 2} {
      set tag [lindex [split $item "."] 0];
      set attr [lindex [split $item "."] 1];
      foreach {entry subdata} $data {
        if {![string compare -nocase $entry "=$tag"]} {
          foreach {tag value} $subdata {
            if {![string compare -nocase $tag $attr]} {
              set string [string map [list $match $value] $string];
            }
          }
        }
      }
    } else {
      foreach {tag value} $data {
        if {![string compare -nocase $item $tag]} {
          set string [string map [list $match $value] $string];
        }
      }
    }
  }
  return [string map [list "%b" "\002" "%c" "\003" "%r" "\026" "%u" "\037" \
                           "%x" "\017" "%%" "%" "%feed" $feed "%id" $id] $string];
}

proc news::decode {content} {
  if {![string match *&* $content]} {
    return $content;
  }
  set escapes {
    &nbsp; \x20 &quot; \x22 &amp; \x26 &apos; \x27 &ndash; \x2D
    &lt; \x3C &gt; \x3E &tilde; \x7E &euro; \x80 &iexcl; \xA1
    &cent; \xA2 &pound; \xA3 &curren; \xA4 &yen; \xA5 &brvbar; \xA6
    &sect; \xA7 &uml; \xA8 &copy; \xA9 &ordf; \xAA &laquo; \xAB
    &not; \xAC &shy; \xAD &reg; \xAE &hibar; \xAF &deg; \xB0
    &plusmn; \xB1 &sup2; \xB2 &sup3; \xB3 &acute; \xB4 &micro; \xB5
    &para; \xB6 &middot; \xB7 &cedil; \xB8 &sup1; \xB9 &ordm; \xBA
    &raquo; \xBB &frac14; \xBC &frac12; \xBD &frac34; \xBE &iquest; \xBF
    &Agrave; \xC0 &Aacute; \xC1 &Acirc; \xC2 &Atilde; \xC3 &Auml; \xC4
    &Aring; \xC5 &AElig; \xC6 &Ccedil; \xC7 &Egrave; \xC8 &Eacute; \xC9
    &Ecirc; \xCA &Euml; \xCB &Igrave; \xCC &Iacute; \xCD &Icirc; \xCE
    &Iuml; \xCF &ETH; \xD0 &Ntilde; \xD1 &Ograve; \xD2 &Oacute; \xD3
    &Ocirc; \xD4 &Otilde; \xD5 &Ouml; \xD6 &times; \xD7 &Oslash; \xD8
    &Ugrave; \xD9 &Uacute; \xDA &Ucirc; \xDB &Uuml; \xDC &Yacute; \xDD
    &THORN; \xDE &szlig; \xDF &agrave; \xE0 &aacute; \xE1 &acirc; \xE2
    &atilde; \xE3 &auml; \xE4 &aring; \xE5 &aelig; \xE6 &ccedil; \xE7
    &egrave; \xE8 &eacute; \xE9 &ecirc; \xEA &euml; \xEB &igrave; \xEC
    &iacute; \xED &icirc; \xEE &iuml; \xEF &eth; \xF0 &ntilde; \xF1
    &ograve; \xF2 &oacute; \xF3 &ocirc; \xF4 &otilde; \xF5 &ouml; \xF6
    &divide; \xF7 &oslash; \xF8 &ugrave; \xF9 &uacute; \xFA &ucirc; \xFB
    &uuml; \xFC &yacute; \xFD &thorn; \xFE &yuml; \xFF
  };
  set content [string map $escapes $content];
  set content [string map [list "\]" "\\\]" "\[" "\\\[" "\$" "\\\$" "\\" "\\\\"] $content];
  regsub -all -- {&#([[:digit:]]{1,5});} $content {[format %c [string trimleft "\1" "0"]]} content;
  regsub -all -- {&#x([[:xdigit:]]{1,4});} $content {[format %c [scan "\1" %x]]} content;
  regsub -all -- {&#?[[:alnum:]]{2,7};} $content "?" content;
  return [subst $content];
}

news::initconfig;
putlog "Script loaded: \002News syndication v$news::version by perpleXa\002";
