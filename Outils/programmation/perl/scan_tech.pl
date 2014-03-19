#!/usr/bin/perl -w
# Script de parsage des fichiers technos type .lib, .inc, .mod, .eldo
# Extraction des modèles et subckt

use strict;
use warnings;
use Cwd;
use Data::Dumper;
use Getopt::Long;
use File::Find ;


## Settings


################################################################################
# Déclaration des variables, tableaux, hashes
################################################################################
my ($o_verb, $o_help, $o_debug);
my $term_sep='################################################################################';
my $numberspice=qr/(?:[+-]?\d+(?:\.\d+)?(?:meg|[afgnmpu]|e[+-]?\d+)?)|(?:[+-]?\.\d+(?:meg|[afgnmpu]|e[+-]?\d+)?)/i;

my $fh;
my %file = (
"lib" => {},
"mod" => {},
"eldo" => {}
);

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
  print ("  -d, --debug   : Debug information (very verbose)\n\n");
  print ("  -h, --help    : Help command display\n\n");
  print ("  -v, --verbose : Debug purpose\n\n");
}

sub printv { print @_ if (defined $o_verb || defined $o_debug) ; }
sub printd { print @_ if (defined $o_debug) ; }

################################################################################
#Main function start
################################################################################
check_options();

my $path = '/nfs/work-crypt/ic/common/xfab/xh018/mentor/v4_0/eldo/v4_0_4/lpmos' ;
#my $path = '/nfs/work-crypt/ic/common//altis/1.2.2/eldo/models' ;
printv("Directory under scan : $path\n");

find ( sub { if (/\.(mod|lib|eldo)$/i ) { 
    @{$file{$1}{$File::Find::dir}}=() if (!$file{$1}{$File::Find::dir}) ;
    push @{$file{$1}{$File::Find::dir}} , $_ ;
  }
}
, $path ) ;

print Dumper \%file ;

printv ("$term_sep\nProcessing .mod model files ...\n");
foreach my $filepath ( keys %{$file{mod}} ) {
  printd ("$term_sep\nScanning in directory $filepath\n");
  foreach ( @{$file{mod}{$filepath}} ) {
    printv ("\n\tScanning file $_\n");
    open ($fh, "<", "$filepath/$_") or die ("Failed to open $_ : $!");
    LINE: while (<$fh>) {
## Print de certaines informations contenues dans les entêtes, commentaires ... syntaxe pour la techno xfab018
      printv("\t\tIn comment --> Device found : $1\n") if ( /^\*\s+Device\s+:\s+(.*)/i ) ;
      printv("\t\tIn comment --> Description found : $1\n") if ( /^\*\s+Desc\s+:\s+(.*)/i ) ;
      printv("\t\tIn comment --> Model found : $1\n") if ( /^\*\s+Model\s+:\s+(.*)/i ) ;
      printv("\t\tIn comment --> TERMINALS found : $1\n") if ( /^\*\s+TERMINALS\s*:\s+(.*)/i ) ;
      printv("\t\tIn comment --> VARIABLES found : $1\n") if ( /^\*\s+VARIABLES\s*:\s+(.*)/i ) ;
## Cas de rencontre de structure subckt
      if ( /^\s*\.subckt\s+(\S+)\s+(.*)/i ) {
        printv ("\n\t\tStructural --> Found subckt definition : name : $1 ;\n");
        my $subckt_arg = $2 ;
        while (<$fh>) {
          next if /^\s*$/ ;
          next if /^\*/ ;
          next if /^\s*\+\s*!.*/ ;
          printd("\t\t\t\tSubckt argument goes on\n") and $subckt_arg .= " $1" if /^\+\s*(.*)/ ;
          if (!/^\+/) { ## Si ça ne commence pas par un + ou un commentaire, l'instatiation du subckt est terminée. Un peu de print et on revient à LINE
            $subckt_arg =~ s/\s*=\s*/=/g;
            my @subckt_arg = split /\s+/, $subckt_arg;
            my %subckt_arg;
            @{$subckt_arg{param}} = grep ( /\w+=[+-]?\w+/, @subckt_arg ) ;
            @{$subckt_arg{pin}} = grep ( /^\w+$/, @subckt_arg ) ;
            #print Dumper \%subckt_arg ;
            printd("\t\t\t\tSubckt arguments definition end. Full argument list : $subckt_arg\n") ;
            printv("\t\t\t\tSubckt arguments definition end.\n\t\t\t\t-->Pin list : ") ;
            printv ("$_ ") foreach @{$subckt_arg{pin}} ; 
            printv ("\n\t\t\t\t-->Parameter list : ") ;
            printv ("$_ ") foreach @{$subckt_arg{param}} ;
            printv ("\n") ;
            #getc if ($o_debug==1);
            redo LINE;
            }
        }
      } elsif ( /^\s*\.model\s+(\S+)\s+(\w+)(.*)/i ) {
        printv ("\t\tStructural --> Found model definition : name : $1 ; type : $2\n");
        my $model_arg = $3 ;
      }
    }
    printd ("\tEnd scanning file\n");
    close $fh;
  }
}

printv ("$term_sep\nProcessing .lib library files ...\n");
foreach my $filepath ( keys %{$file{lib}} ) {
  printd ("$term_sep\nScanning in directory $filepath\n");
  foreach ( @{$file{lib}{$filepath}} ) {
    printv ("\n\tScanning file $_\n");
    open ($fh, "<", "$filepath/$_") or die ("Failed to open $_ : $!");
    while (<$fh>) {
## Print de certaines informations contenues dans les entêtes, commentaires ... syntaxe pour la techno xfab018
## Cas de rencontre de structure subckt
      if ( /^\s*\.lib\s+(\w+)/i ) {
        printv ("\n\t\tLibrary definition found : name : $1 ;\n");
        while (<$fh>) {
          next if /^\s*$/ ;
          next if /^\*/ ;
          next if /^\s*\+\s*!.*/ ;
          printd("\t\t\t-->Found include command : file : $1\n") if /^\.inc\s+(.+)/i ;
          if (/^\.end/i) { ## Si ça commence par .end ou .endl on sort
            printd("\t\tEnd library\n") ;
            last;
            }
        }
      }
    }
    printd ("\tEnd scanning file\n");
    close $fh;
  }
}

