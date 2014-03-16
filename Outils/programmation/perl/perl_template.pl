#!/usr/bin/perl -w
# This is a template for perl scripts

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;

## Settings


################################################################################
# Déclaration des variables, tableaux, hashes
################################################################################
my ($o_verb, $o_help);
my $term_sep='################################################################################';
my $numberspice=qr/(?:[+-]?\d+(?:\.\d+)?(?:meg|[afgnmpu]|e[+-]?\d+)?)|(?:[+-]?\.\d+(?:meg|[afgnmpu]|e[+-]?\d+)?)/i;

################################################################################
# Gestion des fichiers d'entrée sortie
################################################################################

################################################################################
# Définition des fonctions
################################################################################
sub check_options {
  Getopt::Long::Configure ("bundling");
  GetOptions(
    'v' => \$o_verb, 'verbose'	=> \$o_verb,
    'h' => \$o_help, 'help'	=> \$o_help,
  );

  if(defined ($o_help)){
  help();
  exit 1;
  }
}

sub help() {
  print "$term_sep\n";
  print ("Usage fonction sim_eldo : sim_eldo [args]\n");
  print "$term_sep\n";
  print ("Arguments  :\n\n");
  print ("  -h, --help    : Help command display\n\n");
  print ("  -v, --verbose : Debug purpose\n\n");
}

sub printv {
  print @_ if (defined $o_verb) ;
}

#sub help() {
  #print "$0\n";
  #print <<EOT;
#-v, --verbose
#print extra debugging information
#-h, --help
#print this help message
#EOT
#}

sub print_usage() {
  print "Usage: $0 [-v] ]\n";
}

################################################################################
#Main function start
################################################################################
check_options();

#...code...#
