# math v1.1
# math.tcl http://fury.fi/~joep/eggdrop-scripts.php
#          http://jedah.laatikko.org/tcl/
#
# Simple math script
#
# Usage : !math <math>
#
# Example1: !math 1+1
# Example2: !math 3043*(202+34)
# Example3: !math sqrt(5)*s(5)
# Example4: !math scale=2; 1/2
#
# Uses bc (must be installed). For exact usage read bc man page.
#
# Feel free to use & modify, but please keep the info about
# original author
#
#   joep@fury.fi
#   Jedah @ IRCnet (default scale setting & help)
#
#############################################################################

#############################################################################
#
# Script configuration
#

# Default scale
# For example calculation of 1/1, with scale 2 produces 1.00, scale 5
# produces 1.00000 and so forth.
set default_scale 5
# Users can override the default using "!math scale=20; 1/1"

# IRC Channels, where bot is allowed to show math results.
# Use only channels where the bot is on.
#
# Leave option "allowed_channels_math" empty (default) if you want this
# to work automatically on every bot's channel.
#
# Example1. allow only channels #pastilli ja #peelotus
# set allowed_channels_math { pastilli peelotus }
# set denied_channels_math { }
#
# Example2: deny channels #palle ja #tumplaus. allow everything else
# set allowed_channels_math { }
# set denied_channels_math { palle tumplaus }
#
# Default options allow all channels.
# Option denied_channels_math doesn't affect on MSG queries.
#
set allowed_channels_math { }
set denied_channels_math { }

# Do we require that user is on one of the allowed channels to work with MSG
# 1 = yes (default)
# 0 = no (everyone on IRC can make math queries!)
set required_on_channel_math 1

# math command
set math_command "math"

############################################################################
#                                                                          #
# Don't change anything below                                              #
#                                                                          #
############################################################################

# bindings
bind pub - !$math_command pub_math

proc pub_math {nick uhost hand chan lause} {
    global allowed_channels_math denied_channels_math default_scale
    if { ([lsearch -exact $denied_channels_math [string trimleft [string tolower $chan] "#"]] != -1) } {
        return 0
    }
    set channel [string trimleft [strlwr $chan] "#"]
    if { ([lsearch -exact $allowed_channels_math $channel] != -1) || ([llength $allowed_channels_math] == 0) } {
        if { $lause != "" } {
            set floodi [exec echo "scale=$default_scale; $lause" | bc -l]
            putserv "PRIVMSG $chan :$lause = $floodi"
        } else {
            putserv "PRIVMSG $chan :Perusoperaatioiden lisäksi jakojäännös % ja potenssi ^, funktioita neliöjuuri sqrt(x), sin s(x), cos c(x), atan a(x), logaritmi l(x), e-funktio e(x), tulostuksen tarkkuus esim: \"scale=20; 1/2\"."
        }
    }
}

putlog "Script loaded: \002Math 1.1\002" 
