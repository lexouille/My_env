#!/usr/bin/perl -w
# Script d'extraction des fichiers .op. Fonctionnel pour les transistors MOS

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
my $numberspice=qr/(?:[+-]?\d+(?:\.\d+)?(?:meg|[afgnmpu]|e[+-]?\d+)?)|(?:[+-]?\.\d+(?:meg|[afgnmpu]|e[+-]?\d+)?)/i;

my %file;
my $fh;
my %h;

################################################################################
# Gestion des fichiers d'entrée sortie
################################################################################

################################################################################
# Définition des fonctions
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

################################################################################
#Main function start
################################################################################
check_options();

#my $path = '/nfs/work-crypt/ic/common/xfab/xh018/mentor/v4_0/eldo/v4_0_4/lpmos' ;
my $path=`pwd`; chomp $path; $path .="/" ;
printv("Directory under scan : $path\n");

find ( sub { if (/\.op(\d+)$/i ) {  ## On va chercher dans path les fichiers de type .op
    $file{$_}=$1;
  }
}
, $path ) ;

print Dumper \%file ;

printv ("$term_sep\nProcessing .op files ...\n");
foreach my $filepath ( keys %file ) {
  open ($fh, "<", "$filepath") or die ("Failed to open $_ : $!");
  while (<$fh>) { ## while sur le fichier
    $h{$file{$filepath}}{alter}=$1 if /alter\s*:\s*(\d+)/i ;
    $h{$file{$filepath}}{param}{$1}=$2 if /(temp)\s*:\s*($numberspice)/i ;
    if ( /param\s*:((?:\s*\w+\s*=\s*$numberspice,?)+)/i ) {
      my %split = split /[\s=,]+/,$1;
      $h{$file{$filepath}}{param}{$_}=$split{$_} foreach (keys %split) ;
    }
    if (/^\("(X_\w+\.\w+)"/i) { ## On trouve un device
      my $name = $1;
      while (<$fh>) { ## while sur le device
        $h{$file{$filepath}}{device}{$name}{model}=$1 if /^\("model"\s+"([\w.]+)\s*"\)/i ;
        $h{$file{$filepath}}{device}{$name}{type}=$1 if /^\("type\s*"\s+"([\w.]+)\s*"\)/i ;
        $h{$file{$filepath}}{device}{$name}{carac}{$1}=$2 if ( /^\("\s*(\w+)\s*"\s*"\s*($numberspice)\s*"\)/i ) ;
        $h{$file{$filepath}}{device}{$name}{region}=$1 if /^\("region"\s+"(\w+)\s*"\s*\)/i ;
        last if /^\)$/ ;
      } ## End while sur le device
    } ## End if
  } ## End while sur le fichier
}

print Dumper \%h ;

