#!/usr/bin/perl -w

use strict;
use warnings;
use feature qw/switch/; #Pour given ... when
use Getopt::Long;

################################################################################
# Déclaration des variables, tableaux, hashes
################################################################################
my (@process,@voltage,@temp,@pvt,@mc,@param,@testbench);
my (@corner_mos,@corner_bip,@corner_res,@corner_cap);
my (%parlist,%tbenchlist);
my $mc;

my ($t1,$t2,$t3,$t4);
my (@t1,@t2,@t3,@t4);

my ($t,@t);
my %step;

################################################################################
# Gestion des fichiers d'entrée sortie
################################################################################
# Gestion fichier include pour les corners . temporaire, à remplacer dans le carac.inc
my $cornerfile = "./corner.inc";
if ( !(-f $cornerfile) ) {
  print (" Le fichier $cornerfile n'existe pas\n");
}
open (CORNERFILE, ">$cornerfile") or die ("open : $!");

my $caracfile = "/nfs/work-crypt/ic/usr/aferret/altis/simulation/inv/eldoD/schematic/netlist/carac.inc";
if ( !(-f $caracfile) ) {
  print (" Le fichier $caracfile n'existe pas\n");
}
open (CARACFILE, "<$caracfile") or die ("open : $!");

################################################################################
# Définition des fonctions
################################################################################
sub doublons_grep {
  my ($ref_tabeau) = @_;
  my %hash_sans_doublon;
  return grep { !$hash_sans_doublon{$_}++ } @{$ref_tabeau};
}


while (<CARACFILE>)
{
  next if /^\*/ ;
  if (/^\.param\s+/i) {
    print $_;
    #my @t = grep ( /[+-]?[0-9]*\.?[0-9]*/ , $_ );
    s/\s*=\s*/=/g;
    @t = split /\s+/,$_;
    chomp @t;
    foreach $t (@t) {
      print " Résultat split : $t\n";}
    @t = grep ( /\w+\s*=\s*([+-]?\d*(\.\d)?[afgnmpu]*|\w+)/ , @t );
    foreach $t (@t) {
      print " Résultat grep : $t\n";}
    }
  if ( ($t) = ( $_ =~ /^\.define_testbench\s+(\w+)/i) ) {
    print "Définition de testbench trouvée ; nom : $t\n";
  }

  if ( ($t) = ( $_ =~ /^\.lib include\.inc\s+(\w+)/i) ) {
    print "Définition de modèle trouvée ; nom : $t\n";
  }

  if ( ($t,$t1) = ( $_ =~ /^\.step param\s+(\w+)\s+((\w+[ \t\r\f]+)+)/i) ) {
    my @par_step = split /\s+/, $t1;
    print "Step param trouvé ; nom : $t ; Incr_spec : @par_step[0] ; Values : \n";
    my @par_step = split /\s+/, $_;
    #map {s/\.step|param//} @par_step;
    print "Extraction par_step : @par_step\n";
  }
}

################################################################################
#Récupération des paramètres en argument de la fonction
################################################################################
GetOptions("process=s" => \@process,"voltage=s" => \@voltage,"temp=s" => \@temp,"pvt=s" => \@pvt,"mc=s" => \$mc,"param=s" => \@param,"testbench=s" => \@testbench);

if (@process) {
  @process =  split /,/, join (',', @process );
  map {tr/A-Z/a-z/} @process;
  @process = doublons_grep(\@process);
  @corner_mos = grep ( /^typ|ff|ss|fs|sf/i , @process);
  @corner_bip = grep ( /btyp|bmin|bmax/i , @process);
  @corner_res = grep ( /rtyp|rmin|rmax/i , @process);
  @corner_cap = grep ( /ctyp|cmin|cmax/i , @process);
  print "@process\n";
  print ("@corner_mos\n@corner_bip\n@corner_res\n@corner_cap\n");
}

if (@voltage) {
  @voltage = split /,/, join (',',@voltage);
  map {tr/A-Z/a-z/} @voltage;
  @voltage = doublons_grep(\@voltage);
  @voltage = grep ( /vnom|vmin|vmax|v1min|v1max|v2min|v2max/i , @voltage);
  print ("@voltage\n");
}

if (@temp) {
  @temp = split /,/, join (',',@temp);
  @temp = doublons_grep(\@temp);
  @temp = grep ( /[+-]?\d+\.?\d*/ , @temp);
  print ("@temp\n");
}

if (@pvt) {
  @pvt = split /,/, join (',',@pvt);
  map {tr/A-Z/a-z/} @pvt;
  @pvt = doublons_grep(\@pvt);
  @pvt = grep ( /pvt|p1vt|p2vt/i , @pvt);
  print ("@pvt\n");
}

if ($mc) {
  grep ( /[lot|dev|devx],\d+,\d+/ , $mc);
  @mc = split /,/, $mc;
  print ("@mc\n");
}

if (@param) {
  @param = split /,/, join (',',@param);
  map {tr/A-Z/a-z/} @param;
  @param = doublons_grep(\@param);
  print ("@param\n");
}

if (@testbench) {
  @testbench = split /,/, join (',',@testbench);
  map {tr/A-Z/a-z/} @testbench;
  @testbench = doublons_grep(\@testbench);
  print ("@testbench\n");
}

################################################################################
#Main function start
################################################################################

print ("\n");


if (@corner_mos == 0 and @corner_bip == 0 and @corner_res == 0 and @corner_cap == 0) {
#Aucun corner spécifié
  print "Aucun corner spécifié : simulation avec librairies définies dans le fichier carac.inc\n" ;
} else {
#Corner Unique défini
  if (scalar(@corner_mos) <= 1 and scalar (@corner_bip) <= 1 and scalar (@corner_res) <= 1 and scalar(@corner_cap) <= 1) {
    print "Pas de corner mos spécifié, corner typ par defaut\n" and push @corner_mos,"typ" if scalar(@corner_mos) == 0;
    print "Pas de corner bipolaire spécifié, corner btyp par defaut\n" and push @corner_bip,"btyp" if scalar(@corner_bip) == 0;
    print "Pas de corner ressistance spécifié, corner rtyp par defaut\n" and push @corner_res,"rtyp" if scalar(@corner_res) == 0;
    print "Pas de corner capacité spécifié, corner ctyp par defaut\n" and push @corner_cap,"ctyp" if scalar(@corner_cap) == 0;
    print (CORNERFILE ".lib include.inc @corner_mos\n");
    print (CORNERFILE ".lib include.inc @corner_bip\n");
    print (CORNERFILE ".lib include.inc @corner_res\n");
    print (CORNERFILE ".lib include.inc @corner_cap\n");
} else {
#Sur un corner, au moins 2 possibilités définies, => alter dans la netlist
  foreach my $arg_mos (@corner_mos) {
    foreach my $arg_bip (@corner_bip) {
      foreach my $arg_res (@corner_res) {
        foreach my $arg_cap (@corner_cap) {
          print (CORNERFILE ".alter ") ; print (CORNERFILE join ('_', ($arg_mos,$arg_bip,$arg_res,$arg_cap)) ); print (CORNERFILE "\n\n");
          print (CORNERFILE ".lib include.inc $arg_mos\n");
          print (CORNERFILE ".lib include.inc $arg_bip\n");
          print (CORNERFILE ".lib include.inc $arg_res\n");
          print (CORNERFILE ".lib include.inc $arg_cap\n");
          print (CORNERFILE "\n");
        }}}}
}
}
close ( CORNERFILE ) ;

#Debug
#print ( "Print de sortie \n@args\n" ) ;

#die("Usage $0 : <n> <n> \n") if ( !defined (@ARGV));
#
#foreach my $i ( 1 .. $ARGV[0] )
#{
#  foreach my $j ( 1 .. $ARGV[1] ) 
#  {
#    printf ( "%4d" , $i*$j ) ;
#  }
#  print("\n") ;
#}

