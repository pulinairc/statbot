#!/usr/bin/env perl

# Reads a html document on stdin, returns title on stdout.

use strict;
use warnings;
use HTML::HTML5::Parser;
 
my $parser = HTML::HTML5::Parser->new;

$parser->compat_mode('quirks'); # maximum compatibility!1
my $doc = $parser->parse_fh('STDIN');

my $title = $doc->getElementsByTagName('title')->string_value;

$title =~ s/\s+/ /gm;

print $title,"\n";
