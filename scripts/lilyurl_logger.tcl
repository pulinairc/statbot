# URL 2 IRC by Lily (starlily@gmail.com)
# Scans links in IRC channels and returns titles and tinyurl, and logs to a webpage. 
# Will tag weblog entries NSFW if that appears in the line with the link.
# Has duplicate link detection - displays newest entry only, with link count and poster list.
# For Eggdrop bots. Has only been tested on eggdrop 1.6.19+
# Requires TCL8.4 or greater with http, htmlparse and tls, and the sqlite3 tcl lib. (not mysql!) 
# For deb/ubuntu, the packages needed are tcllib and libsqlite3-tcl. Adjust for your flavor. 

# You must ".chanset #channel +url2irc" for each chan you wish to use this in. 

# This needs to be set to a bot writable dir for the web log pages. 
set url2irc(path) /var/www/pulinalinkit      ;# path to bot writable dir for web log pages

# Optional space separated list of domains/URLs/keywords to ignore. Entries are * expanded both ways, you have been warned.
set url2irc(iglist) "lemonparty.org decentsite.tld/somepath/terriblepicture.jpg"

# You may want to change these, but they are set pretty well. 
set url2irc(maxdays) 3 ;# maximum number of days to save on log page
set url2irc(tlength) 30	 		;# minimum url length for tinyurl (tinyurl is 18 chars..) 
set url2irc(pubmflags) "-|-" 		;# user flags required for use
# Fine tuning, safe to ignore. 
set url2irc(ignore) "bdkqr|dkqr" 	;# user flags script will ignore 
set url2irc(length) 12	 		;# minimum url length for title (12 chars is the shortest url possible, equalling all)
set url2irc(clength) 90			;# log page url display length 
set url2irc(delay) 2 			;# minimum seconds between use
set url2irc(timeout) 90000 		;# geturl timeout 
set url2irc(maxsize) 102400             ;# max page size in bytes  

# 01 - Basic features set 20090521 
# 02 - Build logger web page function and title regexp cleanup 20101130
# 05 - Fix logger for multiple chans, user agent string, web dir check 20101204
# 07 - s/regexp/htmlparse/, truncate long url display on log page 20101212
# 09 - some ::http cleanup volunteered by Steve (thanks!) 20110220: Check Content-Type; only get title for text pages 
#   -    under maxsize, otherwise display mime-type. Follow http redirect (not meta refresh or javascript). 
# 10 - converted to sqlite3, main loop cleanup 20110305
# 11 - secure URL handler, NSFW tagger 20110308
# 12 - site blacklist, comment cleanup, chanflag removal (just one now) 20110309
# 14 - post counts, day dividers, dupe detection - display newest w/ counter and poster list, carryover NSFW flag. 20110110
# 15 - logger index.html 20110311 
# 16 - cleanups, 1.0 version for egghelp. 
# 1.2 - fixed shortlink redirects, dbfile varname change, 20120821
# TODO: urlsearch, sticky/hide
# BUGS: alt langs (fixed in tcl8.5?)

################################################

package require http
package require htmlparse
package require tls
package require sqlite3
set url2irc(last) 111
set udbfile "./urllog.db"
setudef flag url2irc
bind pubm $url2irc(pubmflags) {*://*} pubm:url2irc

proc pubm:url2irc {nick host user chan text} {
global url2irc
global udbfile
global botnick
set url2irc(redirects) 0
  if {([channel get $chan url2irc]) && ([expr [unixtime] - $url2irc(delay)] > $url2irc(last)) && (![matchattr $user $url2irc(ignore)])} {
    regsub "#" $chan "" cname
    if {[string match -nocase "*nsfw*" $text]} { set lflag  NSFW } else { set lflag {} }
    foreach word [split $text] {
      if {[string length $word] >= $url2irc(length) && [regexp {^(f|ht)tp(s|)://} $word] && ![regexp {://([^/:]*:([^/]*@|\d+(/|$))|.*/\.)} $word]} {
        foreach item $url2irc(iglist) {
          if {[string match "*$item*" $word]} {return 0}
        }
        set url2irc(last) [unixtime]
        if {[string length $word] >= $url2irc(tlength)} {
          set newurl [tinyurl $word]
        } else { set newurl "" }
        set urtitle [urltitle $word]
        if {[string length $newurl]} {
          #puthelp "PRIVMSG $chan :\002$urtitle\002 ( $newurl )"
        } else { 
          #puthelp "PRIVMSG $chan :\002$urtitle\002" 
        }
        set lTime [clock seconds]
        sqlite3 ldb $udbfile
          ldb eval {CREATE TABLE IF NOT EXISTS urllog (lTime INTEGER,lchan TEXT,lnick TEXT,lurl TEXT,ltitle TEXT,lflag TEXT)}
          ldb eval {INSERT INTO urllog (lTime, lchan, lnick, lurl, ltitle, lflag)VALUES($lTime,$cname,$nick,$word,$urtitle,$lflag)}
        ldb close
      }
    }
    if {[file isdirectory $url2irc(path)] && [file writable $url2irc(path)]} {
      sqlite3 ldb $udbfile
      set rtime [expr [clock seconds] - ($url2irc(maxdays) * 86400)]
      ldb eval {DELETE FROM urllog WHERE lTime < $rtime}
      set logday 0000
      set htmlpage [ open "$url2irc(path)/index.html" w+ ]
      puts $htmlpage "

<!DOCTYPE html>
<html>
<head>
<meta charset=utf-8 />
<title>#pulina-IRC-kanavalta kerätyt linkit</title>
<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"linkit.css\" />
</head>"
      set lcount [ldb eval {SELECT COUNT(distinct lurl) FROM urllog where lchan = $cname}]
      set tdays [expr (([clock seconds] - [ldb eval {SELECT lTime FROM urllog where lchan = $cname order by rowid asc limit 1}]) / 86400) +1]
      puts $htmlpage "
<body>

<div id=\"wrapper\">
<p class=\"stats\">$lcount linkkiä pastettu kanavalle $tdays päivän aikana.</p>
<ul class=\"linkkilista\">"

      foreach lrowid [ldb eval {SELECT rowid FROM urllog WHERE lchan = $cname order by rowid desc}] {
        set lrurl [ldb eval {SELECT lurl FROM urllog where rowid = $lrowid }]
        set lrucount [ldb eval {SELECT COUNT(1) FROM urllog where lurl = $lrurl AND lchan = $cname}]
        set lrnick [ldb eval {SELECT DISTINCT lnick FROM urllog where lurl = $lrurl AND lchan = $cname}] 
        if {$lrucount > 1 } {
          if {[ldb eval {SELECT rowid from urllog where lurl = $lrurl AND lchan = $cname order by rowid desc limit 1}]!=$lrowid} {
            continue } else {
            regsub -all " " $lrnick "/" lrnick
            set plrnick "$lrnick. Linkitetty: $lrucount kertaa"
          }
        } else {set plrnick $lrnick}
        set lrtitle [ldb onecolumn {SELECT ltitle FROM urllog where rowid = $lrowid }]
        set lrTime [ldb eval {SELECT lTime FROM urllog where rowid = $lrowid }]
        set tstamp [clock format $lrTime -format {%H:%M}]
        if {[ldb eval {SELECT COUNT(1) FROM urllog where lurl = $lrurl AND lchan = $cname and lflag like '%NSFW%'}]} {
          set lrf " <b class=\"not-work-safe\">ei work-safe!</b>)"} else {set lrf ""}
        #if {[string length $lrurl] >=$url2irc(clength)} {
        #  set plrurl "[string replace $lrurl $url2irc(clength) end ] ..."
        #} else { 

set plrurl $lrurl 

#}

        if {[clock format $lrTime -format {%m%d}] != $logday} { 
          
          set weekday [clock format $lrTime -format {%A}]
          set month [clock format $lrTime -format {%B}]

          # if {$weekday == "Sunday"} { 
          #     $weekday = "Sunnuntai"
          # } elseif {$weekday == "Monday"} {
          #     $weekday = "Maanantai"
          # } elseif {$weekday == "Tuesday"} {
          #     $weekday = "Tiistai"
          # } elseif {$weekday == "Wednesday"} {
          #     $weekday = "Keskiviikko"
          # } elseif {$weekday == "Thursday"} {
          #     $weekday = "Torstai"
          # } elseif {$weekday == "Friday"} {
          #     $weekday = "Perjantai"
          # } elseif {$weekday == "Saturday"} {
          #     $weekday = "Lauantai"
          # }

          # if {$month == "January"} { 
          #     $month == "Tammikuu"
          # } elseif {$month == "February"} {
          #     $month == "helmikuu"
          # } elseif {$month == "March"} {
          #     $month == "maaliskuu"
          # } elseif {$month == "April"} {
          #     $month == "huhtikuu"
          # } elseif {$month == "May"} {
          #     $month == "toukokuu"
          # } elseif {$month == "June"} {
          #     $month == "kesäkuu"
          # } elseif {$month == "July"} {
          #     $month == "heinäkuu"
          # } elseif {$month == "August"} {
          #     $month == "elokuu"
          # } elseif {$month == "october"} {
          #     $month == "lokakuu"
          # } elseif {$month == "november"} {
          #     $month == "marraskuu"
          # } elseif {$month == "december"} {
          #     $month == "joulukuu"
          # }

          set plogday [clock format $lrTime -format {%A %B %d}]
          set rolledate [clock format $lrTime -format {%d.%m.%Y}]
          set day [clock format $lrTime -format {%d}]
          #puts $htmlpage "<li class=\"paiva\"><h2 class=\"day\">$weekday, $day. $month<span></span></b></h2></li>"
          set logday [clock format $lrTime -format {%m%d}]
        }
        puts $htmlpage "<li class=\"linkki\"><a href=\"$plrurl\" title=\"Linkittäjä: $plrnick ($rolledate $tstamp)\" target=\"_blank\">$lrtitle</a>$lrf <a class=\"url\" href=\"$plrurl\" target=\"_blank\"><img src=\"https://www.google.com/s2/favicons?domain=$plrurl\" alt=\"favicon\"> $plrurl</a></li>" 
      }
      puts $htmlpage "
</ul>
</div>

<footer>
<a href=\"#\" class=\"refresh\">Tämä on <a href=\"http://www.pulina.fi\">#pulina-kanavan</a>-urlilogittaja, jonka tarjosi ihana bottinne <b>kummitus</b>. Tsekkaa <a href=\"http://peikko.us/urllog.log\">koko urllog.log (on aika massiivinen)</a>. Muistathan myös <a href=\"http://peikko.us/pulinakuvat\">kuvat</a>.</a>
</footer>

</body>
</html>"
      close $htmlpage
      set indexpage [ open "$url2irc(path)/index2.html" w+ ]
      puts $indexpage "<html><head><meta http-equiv=\"refresh\" content=\"600\" /><title>URL Log Index for $botnick</title><head>"
      set ilcount [ldb eval {SELECT COUNT(distinct lurl) FROM urllog}]
      set ichanc [ldb eval {SELECT COUNT(distinct lchan) FROM urllog}]
      puts $indexpage "<body bgcolor=white><p><h1>URL Log Index for $botnick</h1>$ilcount URLs in $ichanc channels<br><small>This page reloads itself every 5 minutes.</small></p><hr>"
      foreach chanid  [ldb eval {SELECT distinct lchan FROM urllog}] {
        set ilcount [ldb eval {SELECT COUNT(distinct lurl) FROM urllog where lchan = $chanid}]
        set ilTime [ldb eval {SELECT lTime from urllog where lchan = $chanid order by rowid desc limit 1}]
        set itstamp [clock format $ilTime -format {%B %d at %H:%M}]
        set iltitle [ldb onecolumn {SELECT ltitle from urllog where lchan = $chanid order by rowid desc limit 1}]
        puts $indexpage "<p><a href=\"./$chanid.html\">\#$chanid</a> - $ilcount URLs - last link posted $itstamp<br>Last link title: <b>$iltitle</b></p><hr>"
      }
      puts $indexpage "<center><small><b>URL 2 IRC</b> by Lily</small></center></body></html>"
      close $indexpage
      ldb close
    } else {
      putlog  "Web log path not valid! Not writing html files."
    }
  }
}

proc urltitle {url} {
global url2irc
set agent "Mozilla/5.0 (X11; Linux i686; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"
  if {[info exists url] && [string length $url]} {
    ::http::register https 443 ::tls::socket
    set http [::http::config -useragent $agent]
    if {[catch {::http::geturl $url -timeout $url2irc(timeout) -validate 1} http]} {
      set status [::http::status $http]
      ::http::cleanup $http
      return $status
    }
    array set meta [::http::meta $http]
    ::http::cleanup $http
    if {[info exists meta(Location)] && [incr url2irc(redirects)] < 10} {
      return [urltitle $meta(Location)]
    }
    if {[info exists meta(Redirect)] && [incr url2irc(redirects)] < 10} {
      return [urltitle $meta(Redirect)]
    }
    if {[info exists meta(Content-Type)]} {
      set content_type [lindex [split $meta(Content-Type) ";"] 0]
    } else {
      set content_type "Unknown"
    }
    if {[info exists meta(Content-Length)]} {
      set content_length $meta(Content-Length)
    } else {
      set content_length 0
    }
    if {$content_length <= $url2irc(maxsize) && [string match -nocase "text/*" $content_type]} {
      set http [::http::config -useragent $agent]
      if {[catch {::http::geturl $url -timeout $url2irc(timeout)} http]} {
        ::http::cleanup $http
        return $content_type
      }
      set data [split [::http::data $http] \n]
      ::http::cleanup $http
    }
    set title ""
    if {[info exists data] && [regexp -nocase {<title>(.*?)</title>} $data match title]} {
      set title [::htmlparse::mapEscapes $title]
      regsub -all {[\{\}\\]} $title "" title
      regsub -all " +" $title " " title
      set title [string trim $title]
      return $title
    } else {
      return "$content_type"
    }
  }
}

proc tinyurl {url} {
global url2irc
  if {[info exists url] && [string length $url]} {
    set http [::http::geturl "http://tinyurl.com/create.php" -query [::http::formatQuery "url" $url] -timeout $url2irc(timeout)]
    set data [split [::http::data $http] \n] ; ::http::cleanup $http
    for {set index [llength $data]} {$index >= 0} {incr index -1} {
      if {[regexp {href="http://tinyurl\.com/\w+"} [lindex $data $index] url]} {
        return [string map { {href=} "" \" "" } $url]
      }
    }
  }
 return ""
}

putlog "Script loaded: lilyurl_logger.tcl"
