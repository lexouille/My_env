#!/usr/bin/perl -w
# This is a template for perl scripts

use strict;
use warnings;
use feature qw/switch/; ## Structures given ... when
use Cwd;  ## opendir, readdir, closedir & quelques autres fonctions ; Ref : http://www.perlmonks.org/?node_id=74013
use File::Find ; ## Navigation des les arborescences ; Ref : http://www.perlmonks.org/?node_id=217166
use Data::Dumper; ## Affichage du contenu des tableaux, hashes
use Getopt::Long; ## Fonctions pour les récupérations d'arguments ; GetOptions ...

## Settings


################################################################################
# Déclaration des variables, tableaux, hashes
################################################################################
my ($o_verb, $o_help, $o_debug);
my $term_sep='################################################################################';
my $numberspice=qr/(?:[+-]?\d+(?:\.\d+)?(?:meg|[tgkmunpfa]|e[+-]?\d+)?)|(?:[+-]?\.\d+(?:meg|[tgkmunpfa]|e[+-]?\d+)?)/i;

################################################################################
# Gestion des fichiers d'entrée sortie
################################################################################

################################################################################
# Définition des fonctions communes
################################################################################
sub check_options {
  Getopt::Long::Configure ("bundling");
  GetOptions(
    'd' => \$o_debug, 'debug'	=> \$o_debug,
    'h' => \$o_help,  'help'	=> \$o_help,
    'v' => \$o_verb,  'verbose'	=> \$o_verb,
  );
  help() if(defined ($o_help)) ;
}

sub help() {
  print "$term_sep\n";
  print ("Usage fonction sim_eldo : sim_eldo [args]\n");
  print "$term_sep\n";
  print ("Arguments  :\n\n");
  print ("  -d, --debug   : Debug information (very verbose)\n\n");
  print ("  -h, --help    : Help command display\n\n");
  print ("  -v, --verbose : Debug purpose\n\n");
  exit 1;
}

sub printv { print @_ if (defined $o_verb || defined $o_debug) ; }
sub printd { print @_ if (defined $o_debug) ; }

sub print_usage() {
  print "Usage: $0 [-v] ]\n";
}

################################################################################
# Définition des fonctions spécifiques au script
################################################################################

################################################################################
#Main function start
################################################################################
check_options();

my %h = (
  "sitesinfos" => {
    "sitesamis" => {
      "http://www.egaliteetreconciliation.fr/" => "idem" ,
      "http://fawkes-news.blogspot.fr/" => "idem" ,
      "http://anticons.wordpress.com/" => "idem" ,
      "http://lesmoutonsenrages.fr/" => "idem" ,
      "http://echelledejacob.blogspot.fr/" => "idem" ,
      "http://leschroniquesderorschach.blogspot.fr/" => "idem" ,
      "http://www.panamza.com/" => "idem" ,
      "http://bistrobarblog.over-blog.com/" => "idem" ,
      "http://www.dedefensa.org/" => "idem" ,
      "http://www.cercledesvolontaires.fr/" => "idem" ,
      "http://mk-polis2.eklablog.com/" => "idem" ,
      "http://lesmoutonsenrages.fr/" ,
      "http://www.nexus.fr/" => "idem" } ,
    "sitespasamis" => {
      "http://www.lemonde.fr/" => "idem" ,
       }
  } ,
  "sitesrecherches" => [
    "https://www.google.fr/" ,
    "https://duckduckgo.com/" ]
) ;

print Dumper \%h ;

