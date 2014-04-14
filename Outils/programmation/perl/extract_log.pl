#!/usr/bin/perl -w
# Perl extract log script :
# -parse current directory and get .log file
# -for each .log file, extract message and locatisation for different patterns

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
my $date = `date --iso-8601=minutes`;chomp $date;

my $choice ;
my $file ; my %file ;
my $fh ;
my $outfile="summary.exlog" ; my $outFH ;

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

sub stdin_answer {
## Fonction "Je te pose une question" avec un range de réponses ; réponse unique
## Usage réponse_de_retour = stdin_answer ('tr/nrt', 'Question', @liste_de_réponses_possible);
  my @in = @_ ; 
  my $tr = shift @in ; 
  my $question = shift @in ; map ( {tr/A-Z/a-z/} @in ) if ($tr eq "tr") ; ## Si case insensitive on lowercase toutes les réponses possibles
  my %answer;
  my $g_answer;
  print "\n$term_sep\n$question\n$term_sep\n";
  foreach (@in) { $answer{$_}++; }
  $g_answer = <STDIN>; chomp $g_answer;
  $g_answer =~ tr/A-Z/a-z/;
  while ( !exists ( $answer{$g_answer} ) ) {
    print "Wrong answer ; possible choices : \n"; foreach (@in) {print "$_\n";}
    print "$question\n";
    $g_answer = <STDIN>; chomp $g_answer;
  }
  return $g_answer;
} # End stdin_answer sub

################################################################################
# Définition des fonctions spécifiques au script
################################################################################

################################################################################
#Main function start
################################################################################
check_options();

my $path=`pwd`; chomp $path; $path .="/" ;
printv("\nDirectory under scan : $path\n");

find ( sub { if (/(\S+)\.log$|(summary)\.exlog$/i ) {  ## On va chercher dans path les fichiers de type .log et le fichier summary
    $file{$1}=$_ if $1;
    $file{$2}=$_ if $2;
  }
}
, $path ) ;

print Dumper \%file and print "Dumper %file hash\n" and getc if (defined $o_debug) ;

if ($file{summary}) {
  delete $file{summary} ;
  print "summary\.exlog file found\n" ;
  $choice = stdin_answer('tr','Dou you want to overwrite it ? (automatic backup will be done if no)','yes','no') ;
  if ($choice eq "yes") {
    open ($outFH , ">$outfile" ) ;
  } else {
    system ("cp", "$outfile","summary_bkp$date.exlog") ;
    open ($outFH , ">$outfile" ) ;
  }
} else {
  print "summary\.exlog file not found --> automatic creation\n" ;
  system ("touch", "summary.exlog") ;
}

print ($outFH "$term_sep\n##Summary of extract_log procedure :\n\n##\tDate : $date\n##\tDirectory under scan : $path\n##\tLog file found that are parsed : \n") ;
print ($outFH "##\t$file{$_}\n") foreach keys %file ; 

printv ("$term_sep\nProcessing .log files ...\n");
foreach my $file ( keys %file ) {
  open ($fh, "<", "$file{$file}") or die ("Failed to open $file{$file} : $!");
  print ($outFH "\n$term_sep\n##Processing $file log file ... \n\n") ;
  while (<$fh>) { ## while sur le fichier
    if (/error/i) {
      print ($outFH "##\tError found line $. ; Full line :\n##\t$_\n") ;
    } elsif (/warning/i) {
      print ($outFH "##\tWarning found line $. ; Full line :\n##\t$_\n") ;
    }
  }
  print ($outFH "\n$term_sep\n") ;
}
print ($outFH "\n$term_sep\n## End processing.\n") ;

close ($outFH) ;
