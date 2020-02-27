##########################################################################
#
# URLLog v2.2.5 by Matti 'ccr' Hamalainen <ccr@tnsp.org>
# (C) Copyright 2000-2012 Tecnic Software productions (TNSP)
#
# This script is freely distributable under GNU GPL (version 2) license.
#
##########################################################################
#
# URL-logger script for EggDrop IRC robot, utilizing SQLite3 database
# This script requires SQLite TCL extension. Under Debian, you need:
# tcl8.5 libsqlite3-tcl (and eggdrop eggdrop-data, of course)
#
# NOTICE! If you are upgrading to URLLog v2.0+ from any 1.x version, you
# may want to run a conversion script against your URL-database file,
# if you wish to preserve the old data.
#
# See convert_urllog_db.tcl for more information.
#
# If you are doing a fresh install, you will need to create the
# initial SQLite3 database with the required table schemas. You
# can do that by running: create_urllog_db.tcl
#
##########################################################################

###
### HTTP options
###
# Set to 1 if you want to enable use of HTTP proxy.
# If you do, you MUST set the proxy settings below too.
set http_proxy 0

# Proxy host and port number (only used if enabled above)
set http_proxy_host ""
set http_proxy_port 8080

# Enable _experimental_ TLS/SSL support. This may not work at all.
# If unsure, leave this option disabled (0).
set http_tls_support 1

set http_tls_cadir "/usr/share/ca-certificates/mozilla"


###
### General options
###

# Filename of the SQLite URL database file
set urllog_db_file "urllog.sqlite"


# 1 = Verbose: Say messages when URL is OK, bad, etc.
# 0 = Quiet  : Be quiet (only speak if asked with !urlfind, etc)
set urllog_verbose 1


# 1 = Enable logging of various script actions into bot's log
# 0 = Don't.
set urllog_logmsg 1


# 1 = Check URLs for validity and existence before adding.
# 0 = No checks. Add _anything_ that looks like an URL to the database.
set urllog_check 1


###
### Search related settings
###

# 0 = No search-commands available
# 1 = Search enabled
set urllog_search 1


# Limit how many URLs should the "!urlfind" command show at most.
set urllog_showmax_pub 3

# Same as above, but for private message search.
set urllog_showmax_priv 6


###
### ShortURL-settings
###

# 1 = Enable showing of ShortURLs
# 0 = ShortURLs not shown in any bot actions
set urllog_shorturl 1

# Max length of original URL to be shown, rest is chopped
# off if the URL is longer than the specified amount.
set urllog_shorturl_orig 30

# Web server URL that handles redirects of ShortURLs
set urllog_shorturl_prefix "http://tnsp.org/u/"


###
### Message texts (informal, errors, etc.)
###

# No such host was found
set urlmsg_nosuchhost "ei tommosta oo!"

# Could not connect host (I/O errors etc)
set urlmsg_ioerror "kraak, virhe yhdynn�ss�."

# HTTP timeout
set urlmsg_timeout "ei jaksa ootella"

# No such document was found
set urlmsg_errorgettingdoc "siitosvirhe"

# URL was already known (was in database)
set urlmsg_alreadyknown "wanha!"
#set urlmsg_alreadyknown "Empiiristen havaintojen perusteella ja t�ll� sovellutusalueella esiintyneisiin aikaisempiin kontekstuaalisiin ilmaisuihin viitaten uskallan todeta, ett� sovellukseen ilmoittamasi tietoverkko-osoite oli kronologisti ajatellen varsin postpresentuaalisesti sopimaton ja ennest��n hyvin tunnettu."

# No match was found when searched with !urlfind or other command
set urlmsg_nomatch "Ei osumia."


###
### Things that you usually don't need to touch ...
###

# What IRC "command" should we use to send messages:
# (Valid alternatives are "PRIVMSG" and "NOTICE")
set urllog_preferredmsg "PRIVMSG"

# The valid known Top Level Domains (TLDs), but not the country code TLDs
# (Now includes the new IANA published TLDs)
set urllog_tlds "org,com,net,mil,gov,biz,edu,coop,aero,info,museum,name,pro,int,xxx"


##########################################################################
# No need to look below this line
##########################################################################
set urllog_name "URLLog"
set urllog_version "2.2.5"

set urllog_tlds [split $urllog_tlds ","]
set urllog_httprep [split "\@|%40|{|%7B|}|%7D|\[|%5B|\]|%5D" "|"] 


set    urllog_ent_str "&#45;|-|&#39;|'|—|-|&rlm;||&#8212;|-|&#8211;|--|&#x202a;||&#x202c;|"
append urllog_ent_str "|&lrm;||&aring;|å|&Aring;|Å|&eacute;|é|&#58;|:|&nbsp;| "
append urllog_ent_str "|&#8221;|\"|&#8220;|\"|&laquo;|<<|&raquo;|>>|&quot;|\""
append urllog_ent_str "|&auml;|ä|&ouml;|ö|&Auml;|Ä|&Ouml;|Ö|&amp;|&|&lt;|<|&gt;|>"
append urllog_ent_str "|&#228;|ä|&#229;|ö|&mdash;|-|&#039;|'|&ndash;|-|&#034;|\""
append urllog_ent_str "|&#124;|-|&#8217;|'|&uuml;|ü|&Uuml;|Ü|&bull;|*|&euro;|€"
append urllog_ent_str "|&rdquo;|\""
set urllog_html_ent [split [encoding convertfrom "utf-8" $urllog_ent_str] "|"]

### Require packages
package require sqlite3
package require http

### Binding initializations
if {$urllog_search != 0} {
  bind pub - !urlfind urllog_pub_urlfind
  bind msg - urlfind urllog_msg_urlfind
}

bind pubm - *.* urllog_checkmsg
bind topc - *.* urllog_checkmsg


### Initialization messages
set urllog_message "$urllog_name v$urllog_version (C) 2000-2012 ccr/TNSP"
putlog "$urllog_message"

### HTTP module initialization
::http::config -useragent "$urllog_name/$urllog_version"
if {$http_proxy != 0} {
  ::http::config -proxyhost $http_proxy_host -proxyport $http_proxy_port
}

if {$http_tls_support != 0} {
  package require tls
  ::http::register https 443 [list ::tls::socket -request 1 -require 1 -cadir $http_tls_cadir]
}

### SQLite database initialization
if {[catch {sqlite3 urldb $urllog_db_file} uerrmsg]} {
  putlog " Could not open SQLite3 database '$urllog_db_file': $uerrmsg"
  exit 2
}


if {$http_proxy != 0} {
  putlog " (Using proxy $http_proxy_host:$http_proxy_port)"
}

if {$urllog_check != 0} {
  putlog " (Additional URL validity checks enabled)"
}

if {$urllog_verbose != 0} {
  putlog " (Verbose mode enabled)"
}

if {$urllog_search != 0} {
  putlog " (Search commands enabled)"
}

#-------------------------------------------------------------------------
### Utility functions
proc urllog_log {arg} {
  global urllog_logmsg urllog_name

  if {$urllog_logmsg != 0} {
    putlog "$urllog_name: $arg"
  }
}


proc urllog_ctime { utime } {

  if {$utime == "" || $utime == "*"} {
    set utime 0
  }

  return [clock format $utime -format "%d.%m.%Y %H:%M"]
}


proc urllog_isnumber {uarg} {

  foreach i [split $uarg {}] {
    if {![string match \[0-9\] $i]} { return 0 }
  }

  return 1
}


proc urllog_msg {apublic anick achan amsg} {
  global urllog_preferredmsg

  if {$apublic == 1} {
    putserv "$urllog_preferredmsg $achan :$amsg"
  } else {
    putserv "$urllog_preferredmsg $anick :$amsg" 
  }
}


proc urllog_verb_msg {anick achan amsg} {
  global urllog_verbose

  if {$urllog_verbose != 0} {
    urllog_msg 1 $anick $achan $amsg
  }
}


proc urllog_convert_ent {udata} {
  global urllog_html_ent
  return [string map -nocase $urllog_html_ent [string map $urllog_html_ent $udata]]
}


proc urllog_escape { str } {
  return [string map {' ''} $str]
}


proc urllog_sanitize_encoding {uencoding} {
  regsub -- "^\[a-z\]\[a-z\]_\[A-Z\]\[A-Z\]\." $uencoding "" uencoding
  set uencoding [string tolower $uencoding]
  regsub -- "^iso-" $uencoding "iso" uencoding
  return $uencoding
}

proc urllog_clean_title {utitle} {
  if {[catch {set utitle [encoding convertto "iso8859-15" $utitle]} cerrmsg]} {
    putlog "Could not convert title encoding: $cerrmsg"
  }
  return $utitle
}

#-------------------------------------------------------------------------
proc urllog_get_short {utime} {
  global urllog_shorturl_prefix

  set ustr "ABCDEFGHIJKLNMOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  set ulen [string length $ustr]

  set u1 [expr $utime / ($ulen * $ulen)]
  set utmp [expr $utime % ($ulen * $ulen)]
  set u2 [expr $utmp / $ulen]
  set u3 [expr $utmp % $ulen]

  return "\[ $urllog_shorturl_prefix[string index $ustr $u1][string index $ustr $u2][string index $ustr $u3] \]"
}


#-------------------------------------------------------------------------
proc urllog_chop_url {url} {
  global urllog_shorturl_orig

  if {[string length $url] > $urllog_shorturl_orig} {
    return "[string range $url 0 $urllog_shorturl_orig]..."
  } else {
    return $url
  }
}

#-------------------------------------------------------------------------
proc urllog_exists {urlStr urlNick urlHost urlChan} {
  global urldb urlmsg_alreadyknown urllog_shorturl

  set usql "SELECT id AS uid, utime AS utime, url AS uurl, user AS uuser, host AS uhost, chan AS uchan, title AS utitle FROM urls WHERE url='[urllog_escape $urlStr]'"
  urldb eval $usql {
    urllog_log "URL said by $urlNick ($urlStr) already known"
    if {$urllog_shorturl != 0} {
      set qstr "[urllog_get_short $uid] "
    } else {
      set qstr ""
    }
    append qstr "($uuser/$uchan@[urllog_ctime $utime])"
    if {[string length $utitle] > 0} {
      set qstr "$urlmsg_alreadyknown - '[urllog_clean_title $utitle]' $qstr"
    } else {
      set qstr "$urlmsg_alreadyknown $qstr"
    }
    urllog_verb_msg $urlNick $urlChan $qstr
    return 0
  }
  return 1
}


#-------------------------------------------------------------------------
proc urllog_addurl {urlStr urlNick urlHost urlChan urlTitle} {
  global urldb urllog_shorturl

  if {$urlTitle == ""} {
    set uins "NULL"
  } else {
    set uins "'[urllog_escape $urlTitle]'"
  }
  set usql "INSERT INTO urls (utime,url,user,host,chan,title) VALUES ([unixtime], '[urllog_escape $urlStr]', '[urllog_escape $urlNick]', '[urllog_escape $urlHost]', '[urllog_escape $urlChan]', $uins)"
  if {[catch {urldb eval $usql} uerrmsg]} {
    urllog_log "$uerrmsg on SQL:\n$usql"
    return 0
  }
  set uid [urldb last_insert_rowid]
  urllog_log "Added URL ($urlNick@$urlChan): $urlStr"


  ### Let's say something, to confirm that everything went well.
  if {$urllog_shorturl != 0} {
    set qstr "[urllog_get_short $uid] "
  } else {
    set qstr ""
  }
  if {[string length $urlTitle] > 0} {
    urllog_verb_msg $urlNick $urlChan "'[urllog_clean_title $urlTitle]' ([urllog_chop_url $urlStr]) $qstr"
  } else {
    urllog_verb_msg $urlNick $urlChan "[urllog_chop_url $urlStr] $qstr"
  }

  return 1
}


#-------------------------------------------------------------------------
proc urllog_http_handler {utoken utotal ucurr} {
  upvar #0 $utoken state

  # Stop fetching data after 3000 bytes, this should be enough to
  # contain the head section of a HTML page.
  if {$ucurr > 64000} {
    set state(status) "ok"
  }
}


#-------------------------------------------------------------------------
proc urllog_checkurl {urlStr urlNick urlHost urlChan} {
  global urllog_tlds urllog_check urlmsg_nosuchhost urlmsg_ioerror
  global urlmsg_timeout urlmsg_errorgettingdoc urllog_httprep
  global urllog_shorturl_prefix urllog_shorturl urllog_encoding
  global http_tls_support

  ### Try to guess the URL protocol component (if it is missing)
  set u_checktld 1
  if {[string match "*www.*" $urlStr] && ![string match "http://*" $urlStr] && ![string match "https://*" $urlStr]} {
    set urlStr "http://$urlStr"
  } elseif {[string match "*ftp.*" $urlStr] && ![string match "ftp://*" $urlStr]} {
    set urlStr "ftp://$urlStr"
  }

  ### Handle URLs that have an IPv4-address
  if {[regexp "(\[a-z\]+)://(\[0-9\]{1,3})\\.(\[0-9\]{1,3})\\.(\[0-9\]{1,3})\\.(\[0-9\]{1,3})" $urlStr u_match u_proto ni1 ni2 ni3 ni4]} {
    # Check if the IP is on local network
    if {$ni1 == 127 || $ni1 == 10 || ($ni1 == 192 && $ni2 == 168) || $ni1 == 0} {
      urllog_log "URL pointing to local or invalid network, ignored ($urlStr)."
      return 0
    }
    # Skip TLD check for URLs with IP address
    set u_checktld 0
  }

  ### Check now if we have an ShortURL here ...
  if {$urllog_shorturl != 0 && [string match "*$urllog_shorturl_prefix*" $urlStr]} {
    urllog_log "Ignoring ShortURL from $urlNick: $urlStr"
    return 0
  }

  ### Get URL protocol component
  set u_proto ""
  if {[regexp "(\[a-z\]+)://" $urlStr u_match u_proto]} {
  }

  ### Check the PORT (if the ":" is there)
  set u_record [split $urlStr "/"]
  set u_hostname [lindex $u_record 2]
  set u_port [lindex [split $u_hostname ":"] end]

  if {![urllog_isnumber $u_port] && $u_port != "" && $u_port != $u_hostname} {
    urllog_log "Broken URL from $urlNick: ($urlStr) illegal port $u_port"
    return 0
  }

  # Default to port 80 (HTTP)
  if {![urllog_isnumber $u_port]} {
    set u_port 80
  }

  ### Is it a http or ftp url? (FIX ME!)
  if {$u_proto != "http" && $u_proto != "https" && $u_proto != "ftp"} {
    urllog_log "Broken URL from $urlNick: ($urlStr) UNSUPPORTED protocol class ($u_proto)."
    return 0
  }

  ### Check the Top Level Domain (TLD) validity
  if {$u_checktld != 0} {
    set u_sane [lindex [split $u_hostname "."] end]
    set u_tld [lindex [split $u_sane ":"] 0]
    set u_found 0

    if {[string length $u_tld] == 2} {
      # Assume all 2-letter domains to be valid :)
      set u_found 1
    } else {
      # Check our list of known TLDs
      foreach itld $urllog_tlds {
        if {[string match $itld $u_tld]} {
          set u_found 1
        }
      }
    }

    if {$u_found == 0} {
      urllog_log "Broken URL from $urlNick: ($urlStr) illegal TLD: $u_tld."
      return 0
    }
  }

  set urlStr [string map $urllog_httprep $urlStr]

  ### Does the URL already exist?
  if {![urllog_exists $urlStr $urlNick $urlHost $urlChan]} {
    return 1
  }

  ### Do we perform additional optional checks?
  if {$urllog_check != 0 && (($http_tls_support != 0 && $u_proto == "https") || $u_proto == "http")} {
    # Ok
  } else {
    # No optional checks, just add the URL, if it does not exist already
    urllog_addurl $urlStr $urlNick $urlHost $urlChan ""
    return 1
  }

  ### Does the document pointed by the URL exist?
  if {[catch {set utoken [::http::geturl $urlStr -progress urllog_http_handler -blocksize 1024 -timeout 3000]} uerrmsg]} {
    urllog_verb_msg $urlNick $urlChan "$urlmsg_ioerror ($uerrmsg)"
    urllog_log "HTTP request failed: $uerrmsg"
    return 0
  }

  if {[::http::status $utoken] == "timeout"} {
    urllog_verb_msg $urlNick $urlChan "$urlmsg_timeout"
    urllog_log "HTTP request timed out ($urlStr)"
    return 0
  }

  if {[::http::status $utoken] != "ok"} {
    urllog_verb_msg $urlNick $urlChan "$urlmsg_errorgettingdoc ([::http::error $utoken])"
    urllog_log "Error in HTTP transaction: [::http::error $utoken] ($urlStr)"
    return 0
  }

  # Fixme! Handle redirects!
  set ucode [::http::ncode $utoken]
  set udata [::http::data $utoken]
  array set umeta [::http::meta $utoken]
  ::http::cleanup $utoken

  if {$ucode >= 200 && $ucode <= 309} {
    set uenc_doc ""
    set uenc_http ""
    set uencoding ""

    # Get information about specified character encodings
    if {[info exists umeta(Content-Type)] && [regexp -nocase {charset\s*=\s*([a-z0-9._-]+)} $umeta(Content-Type) umatches uenc_http]} {
      # Found character set encoding information in HTTP headers
    }

    if {[regexp -nocase -- "<meta.\*\?content=\"text/html.\*\?charset=(\[^\"\]*)\".\*\?/>" $udata umatches uenc_doc]} {
      # Found old style HTML meta tag with character set information
    } elseif {[regexp -nocase -- "<meta.\*\?charset=\"(\[^\"\]*)\".\*\?/>" $udata umatches uenc_doc]} {
      # Found HTML5 style meta tag with character set information
    }

    # Make sanitized versions of the encoding strings
    set uenc_http2 [urllog_sanitize_encoding $uenc_http]
    set uenc_doc2 [urllog_sanitize_encoding $uenc_doc]

    # KLUDGE!
    set uencoding $uenc_http2

    putlog "got charsets : http='$uenc_http', doc='$uenc_doc' / sanitized http='$uenc_http2', doc='$uenc_doc2'"

    # Check if the document has specified encoding
    if {$uenc_doc != ""} {
      # Does it differ from what HTTP says?
      if {$uenc_http != "" && $uenc_doc != $uenc_http && $uenc_doc2 != $uenc_http2} {
        # Yes, we will try reconverting
        set uencoding $uenc_doc2
      }
    } elseif {$uenc_http == ""} {
      # If _NO_ known encoding of any kind, assume the default of iso8859-1    
      set uencoding "iso8859-1"
    }

    # Get the document title, if any
    set urlTitle ""
    if {[regexp -nocase -- "<title>(.\*\?)</title>" $udata umatches urlTitle]} {
      # If character set conversion is required, do it now
      if {$uencoding != ""} {
        putlog "conversion requested from $uencoding"
        if {[catch {set urlTitle [encoding convertfrom $uencoding $urlTitle]} cerrmsg]} {
          urllog_log "Error in charset conversion: $cerrmsg"
        }
      }
      
      # Convert some HTML entities to plaintext and do some cleanup
      set utmp [urllog_convert_ent $urlTitle]
      regsub -all "\r|\n|\t" $utmp " " utmp
      regsub -all "  *" $utmp " " utmp
      set urlTitle [string trim $utmp]
    }

    # Rasiatube hack
    if {[string match "*/rasiatube/view*" $urlStr]} {
      set rasia 0
      if {[regexp -nocase -- "<link rel=\"video_src\"\.\*\?file=(http://\[^&\]+)&" $udata umatches utmp]} {
        regsub -all "\/v\/" $utmp "\/watch\?v=" urlStr
        set rasia 1
      } else {
        if {[regexp -nocase -- "SWFObject.\"(\[^\"\]+)\", *\"flashvideo" $udata umatches utmp]} {
          regsub "http:\/\/www.dailymotion.com\/swf\/" $utmp "http:\/\/www.dailymotion.com\/video\/" urlStr
          set rasia 1
        }
      }
      if {$rasia != 0} {
        urllog_log "RasiaTube mangler: $urlStr"
        urllog_verb_msg $urlNick $urlChan "Korjataan haiseva rasiatube-linkki: $urlStr"
      }
    }

    # Check if the URL already exists, just in case we had some redirects
    if {[urllog_exists $urlStr $urlNick $urlHost $urlChan]} {
      urllog_addurl $urlStr $urlNick $urlHost $urlChan $urlTitle
    }
    return 1
  } else {
    urllog_verb_msg $urlNick $urlChan "$urlmsg_errorgettingdoc ($ucode)"
    urllog_log "$ucode - $urlStr"
  }
}


#-------------------------------------------------------------------------
proc urllog_checkmsg {unick uhost uhand uchan utext} {
  ### Check the nick
  if {$unick == "*"} {
    urllog_log "urllog_checkmsg: nick was wc, this should not happen."
    return 0
  }

  ### Do the URL checking
  foreach str [split $utext " "] {
    if {[regexp "(ftp|http|https)://|www\..+|ftp\..*" $str]} {
      urllog_checkurl $str $unick $uhost $uchan
    }
  }

  return 0
}


#-------------------------------------------------------------------------
### Parse arguments, find and show the results
proc urllog_find {unick uhand uchan utext upublic} {
  global urllog_shorturl urldb
  global urllog_showmax_pub urllog_showmax_priv urlmsg_nomatch

  if {$upublic == 0} {
    set ulimit 5
  } else {
    set ulimit 3
  }

  ### Parse the given command
  urllog_log "$unick/$uhand searched URL: $utext"

  set ftokens [split $utext " "]
  set fpatlist ""
  foreach ftoken $ftokens {
    set fprefix [string range $ftoken 0 0]
    set fpattern [string range $ftoken 1 end]
    set qpattern "'%[urllog_escape $fpattern]%'"

    if {$fprefix == "-"} {
      lappend fpatlist "(url NOT LIKE $qpattern OR title NOT LIKE $qpattern)"
    } elseif {$fprefix == "%"} {
      lappend fpatlist "user LIKE $qpattern"
    } elseif {$fprefix == "@"} {
      # foo
    } elseif {$fprefix == "+"} {
      lappend fpatlist "(url LIKE $qpattern OR title LIKE $qpattern)"
    } else {
      set qpattern "'%[urllog_escape $ftoken]%'"
      lappend fpatlist "(url LIKE $qpattern OR title LIKE $qpattern)"
    }
  }

  if {[llength $fpatlist] > 0} {
    set fquery "WHERE [join $fpatlist " AND "]"
  } else {
    set fquery ""
  }

  set iresults 0
  set usql "SELECT id AS uid, utime AS utime, url AS uurl, user AS uuser, host AS uhost FROM urls $fquery ORDER BY utime DESC LIMIT $ulimit"
  urldb eval $usql {
    incr iresults
    set shortURL $uurl
    if {$urllog_shorturl != 0 && $uid != ""} {
      set shortURL "$shortURL [urllog_get_short $uid]"
    }
    urllog_msg $upublic $unick $uchan "#$iresults: $shortURL ($uuser@[urllog_ctime $utime])"
  }
  
  if {$iresults == 0} {
    # If no URLs were found
    urllog_msg $upublic $unick $uchan $urlmsg_nomatch
  }

  return 0
}


#-------------------------------------------------------------------------
### Finding binded functions
proc urllog_pub_urlfind {unick uhost uhand uchan utext} {
  urllog_find $unick $uhand $uchan $utext 1
  return 0
}


proc urllog_msg_urlfind {unick uhost uhand utext} {
  urllog_find $unick $uhand "" $utext 0
  return 0
}

# end of script