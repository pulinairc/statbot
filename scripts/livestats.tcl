# LiveStats v1.0 (www.idletown.com) by redd (redd@idletown.com)
# Support/Suggestions: http://board.idletown.com/viewforum.php?f=9
# Addon for mIRCStats (www.mircstats.com)
# 06.11.2004	v1.0b1	first public release
# 		v1.0b2	fixed wrong proc reference
#		v1.0b3	added stripcodes proc for < 1.6.17
#		v1.0b4	some configuration description fixes
#			fixed missing &nbsp; in empty tables
#			added some more configuration options
# 07.11.2004	v1.0b5  code optimized
#		v1.0b6  fixed erroneous regsub
#		v1.0b7  again some configuration description fixes
#			added dcc command for manually updating stats (.livestats in partyline)
#		v1.0    beta phase finished
			
	
### CONFIGURATION ###

#- Path options -#

# Absolute path for livestats html output
set livestats(dir) "/var/www/botit.pulina.fi/public_html/livestats/[string tolower ${::network}]/"

# Absolute path to nation flags
set livestats(nation_abs) "/var/www/botit.pulina.fi/public_html/livestats/user/nation/"

# URL or relative path to nation flags
# Examples: (1) www.mydomain.tld/path/to/flags/  (2) /path/to/flags/  (3) ../../../path/to/flags/ when livestats in /path2/to/livestats/
# Alternative: http://www.idletown.com/user/nation/
set livestats(nation_addr) "/user/nation/"

# URL or relative path to mircstats pipe images
# Alternative: http://www.idletown.com/pipead.png
set livestats(mircstats_addr) "/"

# URL or relative path to mircstats style sheet
# Alternative: http://www.idletown.com/style/style.css
set livestats(style) "/style/style.css"


#- General options -#

# Define the timezone of the server
set livestats(timezone) "CET"

# Generates LiveStats for every channel the bot is on except the following
set livestats(echans) "#foo #bar"

# Here you can link com/net/org/edu/gov hosts to the countries they belong to
foreach livestats_tld [array names ::livestats_hosts] { unset ::livestats_hosts($livestats_tld) }
set livestats_hosts(de) "*.de.* *.t-dialin.net *.arcor-ip.net *.mediaWays.net *.ewetel.net *.primacom.net *.mops.net *.kielnet.net *.berlikomm.net *.o-tel-o.net"
set livestats_hosts(at) "*.tele.net"
set livestats_hosts(ch) "*.ch.*"
set livestats_hosts(us) "*.edu"


#- Stats sections -#

# Enable "Channel information" section
set livestats(channel) 1

# Enable "User information" section
set livestats(user) 1

# Enable "Country statistics" section (requires "User information" to be enabled)
set livestats(country) 1

# Enable "Topidler" section
set livestats(topidler) 1

# Maximum amount of users in Topidler table (0 = unlimited)
set livestats(maxidler) 30

# Enable "Misc Information" section
set livestats(misc) 1


#- Style options -#

# Color for operators
set livestats(col_op) "#FF0000"

# Color for half operators
set livestats(col_hop) "#0000FF"

# Color for voiced users
set livestats(col_voice) "#009900"

# Copyright information bar: (0) = normal, (1) = simple
set livestats(smallcopy) 0


### Configuration finished - STOP HERE! ###





### SOURCE ###

set livestats(name) "LiveStats Module"
set livestats(version) "v1.0"

###

bind time - "* * * * *" livestats:update
bind dcc n livestats livestats:dcc:update

###

if { [lindex [split $version] 1] < 1061700 } {
  proc stripcodes { arg str } {
    regsub -all -- "\002|\037|\026|\003(\\d{1,2})?(,\\d{1,2})?" $str "" str;
    return $str
  }
}

if { ![file isdirectory $::livestats(dir)] } {
  file mkdir $::livestats(dir)
}

proc getmax { a b } {
  if { $a > $b } { return $a } { return $b }
}

proc getmin { a b } {
  if { $a < $b } { return $a } { return $b }
}

proc livestats:update { a b c d e } {
  foreach chan [channels] {
    if { ![validchan $chan] } { continue }
    if { ![botonchan $chan] } { continue }
    if { [lsearch -exact [split [string tolower $::livestats(echans)]] [string tolower $chan]] != -1 } { continue }
    
    set genstart [unixtime]
    
    set fs [open ${::livestats(dir)}[string trimleft $chan #].html w]
    close $fs
    set fs [open ${::livestats(dir)}[string trimleft $chan #].html a]
    puts $fs "<html><head><title>$chan LiveStats</title><link rel=stylesheet type=text/css href=${::livestats(style)}></head><body><p><center><br>"
    puts $fs "<table width=95% cellspacing=0 cellpadding=2 border=0><tr><td bgcolor=#000000><center><table width=100% cellspacing=0 border=0><tr><td bgcolor=#FFFFFF><center><font color=#000000 size=5 face=Tahoma>$chan Live</font></center></td></tr></table></center></td></tr></table><br>"
    puts $fs "<span class=txt2>Last Update: [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}] $::livestats(timezone)</span><br><br>"

    if { $::livestats(channel) } {
      puts $fs "<table width=95% cellspacing=0 cellpadding=2 border=0><tr><td bgcolor=#000000><center><table width=100% cellspacing=0 border=0><tr><td bgcolor=#FFFFFF><center><font color=#000000 size=4 face=Tahoma>Channel information</font></center></td></tr></table></center></td></tr></table><br>"
      puts $fs "<div align=center>"
      puts $fs "<table border=1 cellspacing=1 cellpadding=5 class=t2>"
      puts $fs "<tr>"
      puts $fs "<td class=v1 align=left><b>Topic</b></td>"
      
      set topic_f [list]
      foreach string [split [stripcodes bcruag [topic $chan]]] {
        if { ( [string match *@* $string] && [string length $string] > 10 ) || [string match *http://* $string] || [string match *www.* $string] || [string match *.de* $string] || [string match *.com* $string] } {
          set first1 [string first "http" $string]
          if { $first1 != -1 } { set start1 $first1 } { set start1 255 }
          
          set first2 [string first "." $string]
          set start2 [string wordstart $string [expr $first2 - 1]]
          
          set first3 [string first "-" $string]
          if { $first3 != -1 } { set start3 [string wordstart $string [expr $first3 - 1]] } { set start3 255 }
        
          set first4 [string first "@" $string]
          if { $first4 != -1 } { set start4 [string wordstart $string [expr $first4 - 1]] } { set start4 255 }
        
          set start [getmin [getmin [getmin $start1 $start2] $start3] $start4]

          set end1 [expr [string wordend $string [expr [string last "." $string] + 1]] - 1]
          set end2       [string wordend $string [expr [string last "/" $string] + 1]]
          set end3       [string wordend $string [expr [string last "?" $string] + 1]]
          set end4       [string wordend $string [expr [string last "&" $string] + 1]]
          set end5       [string wordend $string [expr [string last "=" $string] + 1]]
          set end6       [string wordend $string [expr [string last "#" $string] + 1]]
          set end [getmax [getmax [getmax [getmax [getmax $end1 $end2] $end3] $end4] $end5] $end6]
        
          set url [string range $string $start $end]
          if { [string match *@* $string] } {
            set url "mailto:$url"
          } elseif { [string first "http://" $url] == -1 } {
            set url "http://$url"
          }
          lappend topic_f "[string range $string 0 [expr $start - 1]]<a href=$url target=_blank><u>[string range $string $start $end]</u></a>[string range $string [expr $end + 1] end]"
        } else {
          lappend topic_f $string
        }
      }
      
      puts $fs "<td class=v4 align=left>[join $topic_f " "]</td>"
      puts $fs "</tr>"
      puts $fs "<tr>"
      puts $fs "<td class=v1 align=left><b>Chanmodes</b></td>"
      puts $fs "<td class=v4 align=left>[lindex [split [getchanmode $chan]] 0]</td>"
      puts $fs "</tr>"
    
      set users [llength [chanlist $chan]]
      set user_total  $users
      set user_op     0
      set user_hop    0
      set user_voice  0
      set user_normal 0    
    
      foreach user [chanlist $chan] {
        if { [isop $user $chan] } {
          incr user_op
        } elseif { [ishalfop $user $chan] } {
          incr user_hop
        } elseif { [isvoice $user $chan] } {
          incr user_voice
        } else {
          incr user_normal
        }
      }
    
      puts $fs "<tr>"
      puts $fs "<td class=v1 align=left><b>Users</b></td>"
      puts $fs "<td class=v4 align=left><b>Total:</b> $users - <font color=${::livestats(col_op)}><b>Operators:</b></font> $user_op ([format %.0f [expr 100 / $user_total * $user_op]]%), <font color=${::livestats(col_hop)}><b>Half Operators:</b></font> $user_hop ([format %.0f [expr 100 / $user_total * $user_hop]]%), <font color=${::livestats(col_voice)}>Voices:</font> $user_voice ([format %.0f [expr 100 / $user_total * $user_voice]]%), <font color=black>Normal Users:</font> $user_normal ([format %.0f [expr 100 / $user_total * $user_normal]]%)</td>"
      puts $fs "</tr>"

      set active [list]
      foreach user [chanlist $chan] {
        if { [isbotnick $user] } { continue }
        if { [matchattr $user b] } { continue }
        if { [getchanidle $user $chan] > 5 } { continue }
        lappend active $user
      }
      if { [llength $active] > 0 } {
        set active [lsort -dictionary $active]
        set active2 [list]
        
        foreach user $active {
          if { [isop $user $chan] } {
            set status "@"
          } elseif { [ishalfop $user $chan] } {
            set status "%"
          } elseif { [isvoice $user $chan] } {
            set status "+"
          } else {
            set status "&nbsp;"
          }
          switch -- $status {
            @       { set user "<font color=${::livestats(col_op)}><b>$user</b></font>" }
            %       { set user "<font color=${::livestats(col_hop)}><b>$user</b></font>" }
            +       { set user "<font color=${::livestats(col_voice)}>$user</font>" }
            default { set user "$user" }
          }
          lappend active2 $user
        }
        
        set active [join $active2 ", "]
      } else {
        set active "No active users!"
      }

      puts $fs "<tr>"
      puts $fs "<td class=v1 align=left width=95><b>Currently Active</b></td>"
      puts $fs "<td class=v4 align=left>$active</td>"
      puts $fs "</tr>"
      puts $fs "</table>"
      puts $fs "</div>"
      puts $fs "<br>"
    }

    if { $::livestats(user) } {
      puts $fs "<table width=95% cellspacing=0 cellpadding=2 border=0><tr><td bgcolor=#000000><center><table width=100% cellspacing=0 border=0><tr><td bgcolor=#FFFFFF><center><font color=#000000 size=4 face=Tahoma>User information</font></center></td></tr></table></center></td></tr></table><br>"
      puts $fs "<div align=center>"
      puts $fs "<table border=1 cellspacing=1 cellpadding=5 class=t2>"
      puts $fs "<tr class=t1>"
      puts $fs "<td class=tinv>&nbsp;</td>"
      puts $fs "<td class=v1 align=center>Nick</td>"
      puts $fs "<td class=v1 align=center>Ident</td>"
      puts $fs "<td class=v1 align=center>Host</td>"
      puts $fs "<td class=v1 align=center>Origin</td>"
      puts $fs "<td class=v1 align=center>Online (d:h:m)</td>"
      puts $fs "<td class=v1 align=center>Idle (d:h:m)</td>"
      puts $fs "</tr>"
    
      foreach user [lsort -dictionary [chanlist $chan]] {
        if { [isop $user $chan] } {
          set status "@"
        } elseif { [ishalfop $user $chan] } {
          set status "%"
        } elseif { [isvoice $user $chan] } {
          set status "+"
        } else {
          set status "&nbsp;"
        }
      
        switch -- $status {
          @       { set nick "<font color=${::livestats(col_op)}><b>$user</b></font>" }
          %       { set nick "<font color=${::livestats(col_hop)}><b>$user</b></font>" }
          +       { set nick "<font color=${::livestats(col_voice)}>$user</font>" }
          default { set nick "$user" }
        }
            
        set userhost [getchanhost $user $chan]
      
        set origin [string tolower [lindex [split $userhost .] [expr [llength [split $userhost .]] - 1]]]
        
        foreach livestats_tld [array names ::livestats_hosts] {
          if { [string length $origin] != 2 || [isnumber $origin] } {
            set hosts $::livestats_hosts($livestats_tld)
            foreach host [split $hosts] {
              if { [string match -noc $host [lindex [split $userhost @] 1]] } { 
                set origin $livestats_tld
                break
              }
            }
          }
        }
      
        if { [file exists ${::livestats(nation_abs)}${origin}.gif] } { 
          set origino "<img src=${::livestats(nation_addr)}${origin}.gif>"
        } else {
          set origino "&nbsp;"
        }

        if { $origino != "&nbsp;" } {
          if { ![info exists ::livestats_origins($origin)] } { 
            set ::livestats_origins($origin) 1
          } else {
            incr ::livestats_origins($origin)
          }
        }
      
        set chanjoin_f ""
        if { [getchanjoin $user $chan] == 0 } {
          set tempuser $::botnick
          append chanjoin_f "> "
        } else {
          set tempuser $user
        }
        set chanjoin [expr [expr [unixtime] - [getchanjoin $tempuser $chan]] / 60]
        set days  [expr $chanjoin / 1440]
        set hours [expr $chanjoin / 60 - [expr $days * 24]]
        set mins  [expr $chanjoin - [expr $days * 1440] - [expr $hours * 60]]
        if { $days != 0 } { append chanjoin_f "$days:" }
        if { $days != 0 && [string length $hours] == 1 } { set hours "0$hours" }
        append chanjoin_f "$hours:"
        if { [string length $mins] == 1 } { set mins "0$mins" }
        append chanjoin_f "$mins"

        set chanidle [getchanidle $user $chan]
        set days  [expr $chanidle / 1440]
        set hours [expr $chanidle / 60 - [expr $days * 24]]
        set mins  [expr $chanidle - [expr $days * 1440] - [expr $hours * 60]]
        set chanidle ""
        if { $days != 0 } { append chanidle "$days:" } 
        if { $days != 0 && [string length $hours] == 1 } { set hours "0$hours" }
        append chanidle "$hours:"
        if { [string length $mins] == 1 } { set mins "0$mins" }
        append chanidle "$mins"
      
        puts $fs "<tr>"
        puts $fs "<td class=v1 align=center>$status</td>"
        puts $fs "<td class=v4 align=left>$nick</td>"
        puts $fs "<td class=v4 align=left>[lindex [split $userhost @] 0]</td>"
        puts $fs "<td class=v4 align=left>[lindex [split $userhost @] 1]</td>"
        puts $fs "<td class=v4 align=center>$origino</td>"
        puts $fs "<td class=v4 align=right>$chanjoin_f</td>"
        puts $fs "<td class=v4 align=right>$chanidle</td>"
        puts $fs "</tr>"
      }
      puts $fs "</table>"
      puts $fs "</div>"
      puts $fs "<br>"

      if { $::livestats(country) } {
        set origins [list]
        foreach livestats_origin [array names ::livestats_origins] {
          lappend origins [list "$livestats_origin" "$::livestats_origins($livestats_origin)"]
          unset ::livestats_origins($livestats_origin)
        }
    
        set origins [lsort -dictionary             -index 0 $origins]
        set origins [lsort -integer    -decreasing -index 1 $origins]
    
        if { [llength $origins] > 0 } {
          puts $fs "<table width=95% cellspacing=0 cellpadding=2 border=0><tr><td bgcolor=#000000><center><table width=100% cellspacing=0 border=0><tr><td bgcolor=#FFFFFF><center><font color=#000000 size=4 face=Tahoma>Country statistics</font></center></td></tr></table></center></td></tr></table><br>"
          puts $fs "<div align=center>"
          puts $fs "<table border=1 cellspacing=1 cellpadding=5 class=t2>"
          puts $fs "<tr class=t1>"
          puts $fs "<td class=tinv>&nbsp;</td>"
          puts $fs "<td class=v1 align=center colspan=2>Country</td>"
          puts $fs "<td class=v1 align=center>TLD</td>"
          puts $fs "<td class=v1 align=center>Users</td>"
          puts $fs "<td class=v1 align=center>&nbsp;</td>"
          puts $fs "</tr>"
    
          set m 0
          set n 0
          set oldcount 0
          set peak 0
          foreach origin $origins {
            set count [lindex $origin 1]
            if { $count > $peak } { set peak $count }
            if { $count != $oldcount } {
              set n $m
              incr n
            }
            incr m
            set oldcount $count
        
            switch -- [lindex $origin 0] {
    	        ac { set countryname "Ascension Island" }
    	        ad { set countryname "Andorra" }
    	        ae { set countryname "United Arab Emirates" }
    	        af { set countryname "Afghanistan" }
    	        ag { set countryname "Antigua and Barbuda" }
    	        ai { set countryname "Anguilla" }
    	        al { set countryname "Albania" }
    	        am { set countryname "Armenia" }
    	        an { set countryname "Netherlands Antilles" }
    	        ao { set countryname "Angola" }
    	        aq { set countryname "Antarctica" }
    	        ar { set countryname "Argentina" }
    	        as { set countryname "American Samoa" }
    	        at { set countryname "Austria" }
    	        au { set countryname "Australia" }
    	        aw { set countryname "Aruba" }
    	        ax { set countryname "Aland Islands" }
              	az { set countryname "Azerbaijan" }
              	ba { set countryname "Bosnia and Herzegovina" }
              	bb { set countryname "Barbados" }
    	      	bd { set countryname "Bangladesh" }
    	      	be { set countryname "Belgium" }
    	      	bf { set countryname "Burkina Faso" }
    	      	bg { set countryname "Bulgaria" }
    	      	bh { set countryname "Bahrain" }
    	      	bi { set countryname "Burundi" }
    	      	bj { set countryname "Benin" }
    	      	bm { set countryname "Bermuda" }
    	      	bn { set countryname "Brunei Darussalam" }
    	      	bo { set countryname "Bolivia" }
    	      	br { set countryname "Brazil" }
    	      	bs { set countryname "Bahamas" }
          	bt { set countryname "Bhutan" }
          	bv { set countryname "Bouvet Island" }
          	bw { set countryname "Botswana" }
          	by { set countryname "Belarus" }
          	bz { set countryname "Belize" }
          	ca { set countryname "Canada" }
          	cc { set countryname "Cocos (Keeling) Islands" }
          	cd { set countryname "Congo, The Democratic Republic of the" }
          	cf { set countryname "Central African Republic" }
          	cg { set countryname "Congo, Republic of" }
          	ch { set countryname "Switzerland" }
          	ci { set countryname "Cote d'Ivoire" }
          	ck { set countryname "Cook Islands" }
          	cl { set countryname "Chile" }
          	cm { set countryname "Cameroon" }
          	cn { set countryname "China" }
          	co { set countryname "Colombia" }
          	cr { set countryname "Costa Rica" }
          	cs { set countryname "Serbia and Montenegro" }
          	cu { set countryname "Cuba" }
          	cv { set countryname "Cape Verde" }
          	cx { set countryname "Christmas Island" }
          	cy { set countryname "Cyprus" }
          	cz { set countryname "Czech Republic" }
          	de { set countryname "Germany" }
          	dj { set countryname "Djibouti" }
          	dk { set countryname "Denmark" }
          	dm { set countryname "Dominica" }
          	do { set countryname "Dominican Republic" }
          	dz { set countryname "Algeria" }
          	ec { set countryname "Ecuador" }
          	ee { set countryname "Estonia" }
          	eg { set countryname "Egypt" }
          	eh { set countryname "Western Sahara" }
          	er { set countryname "Eritrea" }
          	es { set countryname "Spain" }
          	et { set countryname "Ethiopia" }
          	fi { set countryname "Finland" }
          	fj { set countryname "Fiji" }
          	fk { set countryname "Falkland Islands (Malvinas)" }
          	fm { set countryname "Micronesia, Federal State of" }
          	fo { set countryname "Faroe Islands" }
          	fr { set countryname "France" }
          	ga { set countryname "Gabon" }
          	gb { set countryname "United Kingdom" }
          	gd { set countryname "Grenada" }
          	ge { set countryname "Georgia" }
          	gf { set countryname "French Guiana" }
          	gg { set countryname "Guernsey" }
          	gh { set countryname "Ghana" }
          	gi { set countryname "Gibraltar" }
          	gl { set countryname "Greenland" }
          	gm { set countryname "Gambia" }
          	gn { set countryname "Guinea" }
          	gp { set countryname "Guadeloupe" }
          	gq { set countryname "Equatorial Guinea" }
          	gr { set countryname "Greece" }
          	gs { set countryname "South Georgia and the South Sandwich Islands" }
          	gt { set countryname "Guatemala" }
          	gu { set countryname "Guam" }
          	gw { set countryname "Guinea-Bissau" }
          	gy { set countryname "Guyana" }
          	hk { set countryname "Hong Kong" }
          	hm { set countryname "Heard and McDonald Islands" }
          	hn { set countryname "Honduras" }
          	hr { set countryname "Croatia/Hrvatska" }
          	ht { set countryname "Haiti" }
          	hu { set countryname "Hungary" }
          	id { set countryname "Indonesia" }
          	ie { set countryname "Ireland" }
          	il { set countryname "Israel" }
          	im { set countryname "Isle of Man" }
          	in { set countryname "India" }
          	io { set countryname "British Indian Ocean Territory" }
          	iq { set countryname "Iraq" }
          	ir { set countryname "Iran, Islamic Republic of" }
          	is { set countryname "Iceland" }
          	it { set countryname "Italy" }
          	je { set countryname "Jersey" }
          	jm { set countryname "Jamaica" }
          	jo { set countryname "Jordan" }
          	jp { set countryname "Japan" }
          	ke { set countryname "Kenya" }
          	kg { set countryname "Kyrgyzstan" }
          	kh { set countryname "Cambodia" }
          	ki { set countryname "Kiribati" }
          	km { set countryname "Comoros" }
          	kn { set countryname "Saint Kitts and Nevis" }
          	kp { set countryname "Korea, Democratic People's Republic" }
          	kr { set countryname "Korea, Republic of" }
          	kw { set countryname "Kuwait" }
          	ky { set countryname "Cayman Islands" }
          	kz { set countryname "Kazakhstan" }
          	la { set countryname "Lao People's Democratic Republic" }
          	lb { set countryname "Lebanon" }
          	lc { set countryname "Saint Lucia" }
          	li { set countryname "Liechtenstein" }
          	lk { set countryname "Sri Lanka" }
          	lr { set countryname "Liberia" }
          	ls { set countryname "Lesotho" }
          	lt { set countryname "Lithuania" }
          	lu { set countryname "Luxembourg" }
          	lv { set countryname "Latvia" }
          	ly { set countryname "Libyan Arab Jamahiriya" }
          	ma { set countryname "Morocco" }
          	mc { set countryname "Monaco" }
          	md { set countryname "Moldova, Republic of" }
          	mg { set countryname "Madagascar" }
          	mh { set countryname "Marshall Islands" }
          	mk { set countryname "Macedonia, The Former Yugoslav Republic of" }
          	ml { set countryname "Mali" }
          	mm { set countryname "Myanmar" }
          	mn { set countryname "Mongolia" }
          	mo { set countryname "Macau" }
          	mp { set countryname "Northern Mariana Islands" }
          	mq { set countryname "Martinique" }
          	mr { set countryname "Mauritania" }
          	ms { set countryname "Montserrat" }
          	mt { set countryname "Malta" }
          	mu { set countryname "Mauritius" }
          	mv { set countryname "Maldives" }
          	mw { set countryname "Malawi" }
          	mx { set countryname "Mexico" }
          	my { set countryname "Malaysia" }
          	mz { set countryname "Mozambique" }
          	na { set countryname "Namibia" }
          	nc { set countryname "New Caledonia" }
          	ne { set countryname "Niger" }
          	nf { set countryname "Norfolk Island" }
          	ng { set countryname "Nigeria" }
          	ni { set countryname "Nicaragua" }
          	nl { set countryname "Netherlands" }
          	no { set countryname "Norway" }
          	np { set countryname "Nepal" }
          	nr { set countryname "Nauru" }
          	nu { set countryname "Niue" }
          	nz { set countryname "New Zealand" }
          	om { set countryname "Oman" }
          	pa { set countryname "Panama" }
          	pe { set countryname "Peru" }
          	pf { set countryname "French Polynesia" }
          	pg { set countryname "Papua New Guinea" }
          	ph { set countryname "Philippines" }
          	pk { set countryname "Pakistan" }
          	pl { set countryname "Poland" }
          	pm { set countryname "Saint Pierre and Miquelon" }
          	pn { set countryname "Pitcairn Island" }
          	pr { set countryname "Puerto Rico" }
          	ps { set countryname "Palestinian Territory, Occupied" }
          	pt { set countryname "Portugal" }
          	pw { set countryname "Palau" }
          	py { set countryname "Paraguay" }
          	qa { set countryname "Qatar" }
          	re { set countryname "Reunion Island" }
          	ro { set countryname "Romania" }
          	ru { set countryname "Russian Federation" }
          	rw { set countryname "Rwanda" }
          	sa { set countryname "Saudi Arabia" }
          	sb { set countryname "Solomon Islands" }
          	sc { set countryname "Seychelles" }
          	sd { set countryname "Sudan" }
          	se { set countryname "Sweden" }
          	sg { set countryname "Singapore" }
          	sh { set countryname "Saint Helena" }
          	si { set countryname "Slovenia" }
          	sj { set countryname "Svalbard and Jan Mayen Islands" }
          	sk { set countryname "Slovak Republic" }
          	sl { set countryname "Sierra Leone" }
          	sm { set countryname "San Marino" }
          	sn { set countryname "Senegal" }
          	so { set countryname "Somalia" }
          	sr { set countryname "Suriname" }
          	st { set countryname "Sao Tome and Principe" }
          	sv { set countryname "El Salvador" }
          	sy { set countryname "Syrian Arab Republic" }
          	sz { set countryname "Swaziland" }
          	tc { set countryname "Turks and Caicos Islands" }
          	td { set countryname "Chad" }
          	tf { set countryname "French Southern Territories" }
          	tg { set countryname "Togo" }
          	th { set countryname "Thailand" }
          	tj { set countryname "Tajikistan" }
          	tk { set countryname "Tokelau" }
          	tl { set countryname "Timor-Leste" }
          	tm { set countryname "Turkmenistan" }
          	tn { set countryname "Tunisia" }
          	to { set countryname "Tonga" }
          	tp { set countryname "East Timor" }
          	tr { set countryname "Turkey" }
          	tt { set countryname "Trinidad and Tobago" }
          	tv { set countryname "Tuvalu" }
          	tw { set countryname "Taiwan" }
          	tz { set countryname "Tanzania" }
          	ua { set countryname "Ukraine" }
          	ug { set countryname "Uganda" }
          	uk { set countryname "United Kingdom" }
          	um { set countryname "United States Minor Outlying Islands" }
          	us { set countryname "United States" }
          	uy { set countryname "Uruguay" }
          	uz { set countryname "Uzbekistan" }
          	va { set countryname "Holy See (Vatican City State)" }
          	vc { set countryname "Saint Vincent and the Grenadines" }
          	ve { set countryname "Venezuela" }
          	vg { set countryname "Virgin Islands, British" }
          	vi { set countryname "Virgin Islands, U.S." }  
          	vn { set countryname "Vietnam" }
          	vu { set countryname "Vanuatu" }
          	wf { set countryname "Wallis and Futuna Islands" }
          	ws { set countryname "Western Samoa" }
          	ye { set countryname "Yemen" }
          	yt { set countryname "Mayotte" }
          	yu { set countryname "Yugoslavia" }
          	za { set countryname "South Africa" }
          	zm { set countryname "Zambia" }
          	zw { set countryname "Zimbabwe" }
            }
        
            puts $fs "<tr>"
            puts $fs "<td class=v1 align=center>$n</td>"
            puts $fs "<td class=v4 align=center><img src=${::livestats(nation_addr)}[lindex $origin 0].gif></td>"
            puts $fs "<td class=v4 align=left>$countryname</td>"
            puts $fs "<td class=v4 align=center>[lindex $origin 0]</td>"
            puts $fs "<td class=v4 align=right>$count</td>"
            puts $fs "<td class=v4 align=left><img src=${::livestats(mircstats_addr)}pipead.png height=15 width=[expr $count * 100 / $peak] class=ad></td>"
            puts $fs "</tr>"      
          }  
          puts $fs "</table>"
          puts $fs "</div>"
          puts $fs "<br>"
        }
      }
    }

    if { $::livestats(topidler) } {
      set idlelist [list]
      foreach member [chanlist $chan] {
        if { [isbotnick $member] } { continue }
        if { [matchattr $member b] } { continue } 
        lappend idlelist [list "$member" "[getchanidle $member $chan]"] 
      }
      set idlelist [lsort -dictionary             -index 0 $idlelist]
      set idlelist [lsort -integer    -decreasing -index 1 $idlelist]

      if { [llength $idlelist] > 0 } {
        if { $::livestats(maxidler) > 0 && [llength $idlelist] > $::livestats(maxidler) } { set idlelist [lreplace $idlelist $::livestats(maxidler) end] }
        puts $fs "<table width=95% cellspacing=0 cellpadding=2 border=0><tr><td bgcolor=#000000><center><table width=100% cellspacing=0 border=0><tr><td bgcolor=#FFFFFF><center><font color=#000000 size=4 face=Tahoma>Current [llength $idlelist] Topidler</font></center></td></tr></table></center></td></tr></table><br>"
        puts $fs "<div align=center>"
        puts $fs "<table border=1 cellspacing=1 cellpadding=5 class=t2>"
        puts $fs "<tr class=t1>"
        puts $fs "<td class=tinv>&nbsp;</td>"
        puts $fs "<td class=v1 align=center>Nick</td>"
        puts $fs "<td class=v1 align=center>Idletime (d:h:m)</td>"
        puts $fs "</tr>"
    
        set m 0
        set n 0
        set oldchanidle 0
        foreach idler $idlelist {
          set chanidle [lindex $idler 1]
          set days  [expr $chanidle / 1440]
	  set hours [expr $chanidle / 60 - [expr $days * 24]]
	  set mins  [expr $chanidle - [expr $days * 1440] - [expr $hours * 60]]
	  set chanidle ""
	  if { $days != 0 } { append chanidle "$days:" }
	  if { $days != 0 && [string length $hours] == 1 } { set hours "0$hours" }
	  append chanidle "$hours:"
	  if { [string length $mins] == 1 } { set mins "0$mins" }
          append chanidle "$mins"
          if { $chanidle != $oldchanidle } { 
            set n $m
            incr n 
          }
          incr m
          set oldchanidle $chanidle
          puts $fs "<tr>"
          puts $fs "<td class=v1 align=center>$n</td>"
          puts $fs "<td class=v4 align=left>[lindex $idler 0]</td>"
          puts $fs "<td class=v4 align=right>$chanidle</td>"
          puts $fs "</tr>"
        }
        puts $fs "</table>"
        puts $fs "</div>"
        puts $fs "<br>"
      }
    }
 
    if { $::livestats(misc) } {
      puts $fs "<table width=95% cellspacing=0 cellpadding=2 border=0><tr><td bgcolor=#000000><center><table width=100% cellspacing=0 border=0><tr><td bgcolor=#FFFFFF><center><font color=#000000 size=4 face=Tahoma>Misc information</font></center></td></tr></table></center></td></tr></table><br>"
      puts $fs "<div align=center>"
      puts $fs "<table border=1 cellspacing=1 cellpadding=5 class=t2>"
      
      puts $fs "<tr class=t1>"
      puts $fs "<td class=tinv>&nbsp;</td>"
      puts $fs "<td class=v1 align=center>Ban</td>"
      puts $fs "<td class=v1 align=center>Creator</td>"
      puts $fs "</tr>"
      set n 0
      foreach ban [lsort -dictionary [chanbans $chan]] {
        incr n
        puts $fs "<tr>"
        puts $fs "<td class=v1 align=center>$n</td>"
        puts $fs "<td class=v4 align=left>[lindex $ban 0]</td>"
        puts $fs "<td class=v4 align=left>[lindex $ban 1]</td>"
        puts $fs "</tr>"
      }
      if { $n == 0 } { puts $fs "<tr><td class=tinv>&nbsp;</td><td class=v4 colspan=2 align=center>Banlist empty.</td></tr>" }

      puts $fs "<tr><td class=tinv colspan=3>&nbsp;</td></tr>"
    
      puts $fs "<tr class=t1>"
      puts $fs "<td class=tinv>&nbsp;</td>"
      puts $fs "<td class=v1 align=center>Exempt</td>"
      puts $fs "<td class=v1 align=center>Creator</td>"
      puts $fs "</tr>"
      set n 0
      foreach exempt [lsort -dictionary [chanexempts $chan]] {
        incr n
        puts $fs "<tr>"
        puts $fs "<td class=v1 align=center>$n</td>"
        puts $fs "<td class=v4 align=left>[lindex $exempt 0]</td>"
        puts $fs "<td class=v4 align=left>[lindex $exempt 1]</td>"
        puts $fs "</tr>"
      }
      if { $n == 0 } { puts $fs "<tr><td class=tinv>&nbsp;</td><td class=v4 colspan=2 align=center>Exemptlist empty.</td></tr>" }

      puts $fs "<tr><td class=tinv colspan=3>&nbsp;</td></tr>"

      puts $fs "<tr class=t1>"
      puts $fs "<td class=tinv>&nbsp;</td>"
      puts $fs "<td class=v1 align=center>Invite</td>"
      puts $fs "<td class=v1 align=center>Creator</td>"
      puts $fs "</tr>"
      set n 0
      foreach invites [lsort -dictionary [chaninvites $chan]] {
        incr n
        puts $fs "<tr>"
        puts $fs "<td class=v1 align=center>$n</td>"
        puts $fs "<td class=v4 align=left>[lindex $invites 0]</td>"
        puts $fs "<td class=v4 align=left>[lindex $invites 1]</td>"
        puts $fs "</tr>"
      }
      if { $n == 0 } { puts $fs "<tr><td class=tinv>&nbsp;</td><td class=v4 colspan=2 align=center>Invitelist empty.</td></tr>" }
      
      puts $fs "</table>"
      puts $fs "</div>"
    }
    
    set genend [unixtime]
    set gentime [duration [expr $genend - $genstart]]
    
    ### Please do not remove
    
    if { $::livestats(smallcopy) } { 
      puts $fs "<p align=center><table cellpadding=2 class=cr align=center><tr><td class=tinv><a href=http://www.idletown.com/ target=_top>LiveStats $::livestats(version)</a> © redd - Addon for <a href=http://www.nic.fi/~mauvinen/mircstats/>mIRCStats</a> © Ave</td></tr></table>"
    } else {
      puts $fs "<p align=center><table cellpadding=2 class=cr align=center><tr><td class=tinv>This page was created on [clock format [clock scan now] -format {%d.%m.%Y %H:%M}] with <a href=http://www.idletown.com/ target=_top>LiveStats $::livestats(version)</a><br>Run time: $gentime on an eggdrop v[lindex [split $::version] 0] ($::botnick)<br><a href=http://www.idletown.com/ target=_top>LiveStats</a> is &copy by redd - Addon for <a href=http://www.nic.fi/~mauvinen/mircstats/>mIRCStats</a> &copy by Ave</td></tr></table>"
    }
    
    ### Thanks! :)
    
    puts $fs "</body></html>"
    close $fs
  }
  return 1
}

proc livestats:dcc:update { hand idx arg } {
  livestats:update a b c d e
  putdcc $idx "(LiveStats) Successfully updated!"
  return 1
}

#

putlog "TCL LOADED: LiveStats $livestats(version)"
