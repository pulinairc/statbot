namespace eval gTranslator { 

# Factor this out into a helper 
proc getJson url { 
  set tok [http::geturl $url] 
  set res [json::json2dict [http::data $tok]] 
  http::cleanup $tok 
  return $res 
} 
# How to decode _decimal_ entities; WARNING: high magic factor within! 
proc decodeEntities str { 
  set str [string map {\[ {\[} \] {\]} \$ {\$} \\ \\\\} $str] 
  subst [regsub -all {&#(\d+);} $str {[format %c \1]}] 
} 

bind pub - !tr gTranslator::translate 
proc translate { nick uhost handle chan text } { 
  package require http 
  package require json 
  set lngto [string tolower [lindex [split $text] 0]] 
  set text [http::formatQuery q [join [lrange [split $text] 1 end]]] 
  set dturl "http://ajax.googleapis.com/ajax/services/language/detect?v=1.0&q=$text" 

  set lng [dict get [getJson $dturl] responseData language] 

  if { $lng == $lngto } { 
    putserv "PRIVMSG $chan :\002Virhe\002 kääntäessä $lng kielelle $lngto." 
    return 0 
  } 
  set trurl "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&langpair=$lng%7c$lngto&$text" 
  putlog $trurl 

  set res [getJson $trurl] 

  putlog $res 
  #putserv "PRIVMSG $chan :Language detected: $lng" 

  set translated [decodeEntities [dict get $res responseData translatedText]] 

  putserv "PRIVMSG $chan :$translated" 
#  putserv "PRIVMSG $chan :[encoding convertto utf-8 $translated]" 
} 
} 