#!/usr/bin/perl -w

use strict;
use warnings;
use feature qw/switch/; #Pour given ... when
use Getopt::Long;

my ($hex,$dec,$bin);

print "Welcome to this fantastic converter\n";

GetOptions("hex2dec=i" => \$hex,"dec=i" => \$dec ,"bin=i" => \$bin);

print "$hex\n";
print "$dec\n";
print "$bin\n";

my $decvalue = oct( "0b$bin" );
print "$decvalue\n";
my $hexvalue=sprintf("%x", $decvalue);
print "$hexvalue\n";

print "Exit this fantastic converter\n";
