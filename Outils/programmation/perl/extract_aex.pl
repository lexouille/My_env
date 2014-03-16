#!/usr/bin/perl -w
# This is a template for perl scripts

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Math::BigFloat;
use List::Util qw(max);

## Settings


################################################################################
# Déclaration des variables, tableaux, hashes
################################################################################
my ($o_verb, $o_help,$o_infile,$o_outfile);
my ($infile,$outfile);
my $term_sep='################################################################################'."\n";
my $extract_count=-1;
my (%h,%maxmin);
my (@paramlist,@extractlist,@alterindex);

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
    'i=s' => \$o_infile,
    'o=s' => \$o_outfile,
  );

  if(defined ($o_help)){
  help();
  exit 1;
  }
}

sub filehandle {
  print ("File $o_infile not found.\n") if ( !(-f $o_infile) );
  open ($infile, "<$o_infile") or die ("open : $!");

  print ("File $o_outfile not found.\n") if ( !(-f $o_outfile) );
  open ($outfile, ">$o_outfile") or die ("open : $!");
}

sub help() {
  print "$term_sep\n";
  print ("Extraction of aex files : ./extract_aex [args]\n");
  print "$term_sep\n";
  print ("Arguments  :\n\n");
  print ("  -h, --help    : Help command display\n\n");
  print ("  -v, --verbose : Debug purpose\n\n");
  exit 1;
}

sub printv {
  print @_ if (defined $o_verb) ;
}

################################################################################
#Main function start
################################################################################
check_options();
filehandle();

while (<$infile>) {
  next if /^version/i ; # A voir, le no de la version est inutile
  next if /^extract for/i ;
  next if /^title/i ;
  if (/^\s*$/) { #séparateur entre les différentes extractions : incrément du compteur, set des param_set et extract, reset des tables extractlist et paramlist si ce n'est pas le premier espace
    $extract_count++ ;
    %{$h{$extract_count}{"param_set"}}=@paramlist and %{$h{$extract_count}{"extract"}}=@extractlist and @{$h{$extract_count}{"alter_index"}}=@alterindex and @extractlist=() and @paramlist=() if ($extract_count>=1) ;
    next ;
  } elsif (/\s*alter\s+index\s+\d+\s+(.*)/i) { # alter index pour la partie pvt
    printv("alter index (pvt type) : $1\n"); #print $extract_count,$1; getc;
    @alterindex=split /_/,$1 ;
  } elsif (/\s*temperature\s+=\s+($numberspice)/i) {
    #${$h{$extract_count}{"temp"}}=$1; # Ici, à voir si c'est nécessaire ...
    push @paramlist,("Temperature",$1);
    printv("Temperature def : $1\n");
  } elsif (/\s*param\s+(.*)/i) {
    push @paramlist,(split(/[\s=]+/,$1)) unless $1 =~ /tval/i;
  } elsif (/\s*\*(.*)/i) { # Structure \s+* : résultat d'extraction
    push @extractlist,(split(/[\s=]+/,$1));
    printv("Extract : $1\n");
  }
  if (eof) {
    $extract_count++ ; 
    %{$h{$extract_count}{"param_set"}}=@paramlist and %{$h{$extract_count}{"extract"}}=@extractlist and @{$h{$extract_count}{"alter_index"}}=@alterindex ;
  }
}

#print Dumper \@paramlist;
#my %param=@paramlist;
#print Dumper \%h;

print "\n$term_sep";
print "Extraction Result Summary :\n";

print "\tExtraction run count : $extract_count\n";
my $extract_parsed=keys %{$h{"1"}{"extract"}} ; print "\tNumber of extract parsed : $extract_parsed\n";
my $extract_param=keys %{$h{"1"}{"param_set"}} ; print "\tNumber of extract param (including temperature) : $extract_param\n";

printf($outfile "\n");
printf($outfile "%-18s","RUN INDEX");
printf($outfile "%-15s%-15s%-15s%-15s", "MOS CORNER", "BIP CORNER", "RES CORNER", "CAP CORNER") ;
printf($outfile "%-18s","$_") foreach (keys %{$h{'1'}{"param_set"}}) ;
printf($outfile "%-18s","$_") foreach (keys %{$h{'1'}{"extract"}}) ;

printf($outfile "\n\n");

foreach my $key (sort { $a <=> $b } keys %h ) {
  #print("Run number $key\t");
  printf($outfile "%-18s","Run number $key");
  @{$h{$key}{"alter_index"}} = qw(UserDef UserDef UserDef UserDef) unless $h{$key}{"alter_index"};
  printf($outfile "%-15s", $_) foreach (@{$h{$key}{"alter_index"}}) ;
  foreach (keys %{$h{$key}{"param_set"}}) {
    printf($outfile "%-18s","$h{$key}{'param_set'}{$_}") ;
  }
  foreach (keys %{$h{$key}{"extract"}}) {
    printf($outfile "%-18s","$h{$key}{'extract'}{$_}") ;
    #Old version avec debug
    #$maxmin{$_}{'max'}{'val'} = Math::BigFloat->new($h{$key}{'extract'}{$_}) and printv("init max $maxmin{$_}{'max'}{'val'}\n") if (!exists $maxmin{$_}{'max'}{'val'}) ;
    #$maxmin{$_}{'min'}{'val'} = Math::BigFloat->new($h{$key}{'extract'}{$_}) and printv("init min $maxmin{$_}{'min'}{'val'}\n") if (!exists $maxmin{$_}{'min'}{'val'}) ;

# Initialisation des min, max et key avec les premières valeurs
    $maxmin{$_}{'max'}{'val'} = Math::BigFloat->new($h{$key}{'extract'}{$_})and $maxmin{$_}{'min'}{'param_set'} = $key  if (!exists $maxmin{$_}{'max'}{'val'}) ; 
    $maxmin{$_}{'min'}{'val'} = Math::BigFloat->new($h{$key}{'extract'}{$_}) and $maxmin{$_}{'max'}{'param_set'} = $key if (!exists $maxmin{$_}{'min'}{'val'}) ;

    if ( $maxmin{$_}{'min'}{'val'}->bcmp(Math::BigFloat->new($h{$key}{'extract'}{$_}))==1 ) { #comparaison valeur actuelle min <-> valeur trouvée
      $maxmin{$_}{'min'}{'param_set'} = $key ;
      $maxmin{$_}{'min'}{'val'} = Math::BigFloat->new($h{$key}{'extract'}{$_}) ;
      $maxmin{$_}{'min'}{'rval'} = $maxmin{$_}{'min'}{'val'}->bsstr() ;
      #printv("overwrite min on extract $_ : $maxmin{$_}{'min'}\n") ;
    }

    if ( $maxmin{$_}{'max'}{'val'}->bcmp(Math::BigFloat->new($h{$key}{'extract'}{$_}))==-1 ) { #comparaison valeur actuelle max <-> valeur trouvée
      $maxmin{$_}{'max'}{'param_set'} = $key ;
      $maxmin{$_}{'max'}{'val'} = Math::BigFloat->new($h{$key}{'extract'}{$_}) ;
      $maxmin{$_}{'max'}{'rval'} = $maxmin{$_}{'max'}{'val'}->bsstr() ; #Passage en notation scientifique
      #printv("overwrite max on extract $_ : $maxmin{$_}{'max'}\n") ;
    }
 
  }
  printf($outfile "\n");
}

printf($outfile "\n$term_sep");
printf($outfile "Extraction Result Summary :\n");

printf($outfile "\tExtraction run count : $extract_count\n");
printf($outfile "\tNumber of extract parsed : $extract_parsed\n");
printf($outfile "\tNumber of extract param (including temperature) : $extract_param\n");

foreach (keys %maxmin) {
  printf("%s%.4E%s", "\tMaximum value on parameter $_ : " , $maxmin{$_}{'max'}{'rval'} , " : Run index : $maxmin{$_}{'max'}{'param_set'}\n");
  printf("%s%.4E%s", "\tMinimum value on parameter $_ : " , $maxmin{$_}{'min'}{'rval'} , " : Run index : $maxmin{$_}{'min'}{'param_set'}\n");
  printf($outfile "%s%.4E%s", "\tMaximum value on parameter $_ : " , $maxmin{$_}{'max'}{'rval'} , " : Run index : $maxmin{$_}{'max'}{'param_set'}\n");
  printf($outfile "%s%.4E%s", "\tMinimum value on parameter $_ : " , $maxmin{$_}{'min'}{'rval'} , " : Run index : $maxmin{$_}{'min'}{'param_set'}\n");
}

printf($outfile "$term_sep\n");
print "$term_sep\n";

