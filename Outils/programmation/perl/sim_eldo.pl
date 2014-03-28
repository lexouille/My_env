#!/usr/bin/perl -w

use strict;
use warnings;
use feature qw/switch/; #Pour given ... when
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Text::Wrap;
use File::Basename ;

use vars qw(@EXPORT) ; 
local $Text::Wrap::columns = 80;
my $initial_tab = "+ ";
my $other_tab = "+ ";
my $comment_tab = "+ ! ";
my $no_tab = "";

################################################################################
# Déclaration des variables, tableaux, hashes
################################################################################
my $date = `date --iso-8601=minutes`;chomp $date;
print ("\n");

my ($index,$choice);

my %alim_def = (
"ats130rf" => { ## begin ats130rf
  "dvss" => { "vhdl" => { "min" => -0.01 , "max" => 0.01 } } ,
  "avss" => { "vhdl" => { "min" => -0.01 , "max" => 0.01 } } ,
  "dvddgo1" => { "vhdl" => { "min" => 1.0 , "max" => 2.0 } , "process" => { "vnom" => 1.5 , "vmin" => 1.35 , "vmax" => 1.65 } } ,
  "dvddgo2" => { "vhdl" => { "min" => 1.8 , "max" => 3.2 } , "process" => { "vnom" => 2.5 , "vmin" => 2.25 , "vmax" => 2.75 } } ,
  "avddgo1" => { "vhdl" => { "min" => 1.0 , "max" => 2.0 } , "process" => { "vnom" => 1.5 , "vmin" => 1.35 , "vmax" => 1.65 } } ,
  "avddgo2" => { "vhdl" => { "min" => 1.8 , "max" => 3.2 } , "process" => { "vnom" => 2.5 , "vmin" => 2.25 , "vmax" => 2.75 } } ,
  "avddio" =>  { "vhdl" => { "min" => 2.2 , "max" => 4.4 } , "process" => { "vnom" => 3.3 , "vmin" => 2.97 , "vmax" => 3.63 } } 
} , ## end ats130rf
"xh018" => { ## begin xh018
  "dvss" => { "vhdl" => { "min" => -0.01 , "max" => 0.01 } } ,
  "avss" => { "vhdl" => { "min" => -0.01 , "max" => 0.01 } } ,
  "dvddgo1" => { "vhdl" => { "min" => 1.0 , "max" => 2.0 } , "process" => { "vnom" => 1.5 , "vmin" => 1.35 , "vmax" => 1.65 } } ,
  "dvddgo2" => { "vhdl" => { "min" => 1.8 , "max" => 3.2 } , "process" => { "vnom" => 2.5 , "vmin" => 2.25 , "vmax" => 2.75 } } ,
  "avddgo1" => { "vhdl" => { "min" => 1.0 , "max" => 2.0 } , "process" => { "vnom" => 1.5 , "vmin" => 1.35 , "vmax" => 1.65 } } ,
  "avddgo2" => { "vhdl" => { "min" => 1.8 , "max" => 3.2 } , "process" => { "vnom" => 2.5 , "vmin" => 2.25 , "vmax" => 2.75 } } ,
  "avddio" =>  { "vhdl" => { "min" => 2.2 , "max" => 4.4 } , "process" => { "vnom" => 3.3 , "vmin" => 2.97 , "vmax" => 3.63 } } 
} ## end xh018
) ;

#print Dumper \%alim_def and exit ;

## Ici, je pense qu'on peut mettre tout ça dans un tableau unique
## Je le commence au dessus, il faudra migrer et faire de le non reg plus tard
my %voltage_def = ( "vnom"  => [ 1.5, 2.5 , 3.3 ] , 
                    "vmin"  => [1.35, 2.25, 2.97] ,
                    "vmax"  => [1.65, 2.75, 3.63] ,
                    "v1min" => [1.35, 2.5 , 3.3 ] ,
                    "v1max" => [1.65, 2.5 , 3.3 ] ,
                    "v2min" => [ 1.5, 2.25, 2.97] ,
                    "v2max" => [ 1.5, 2.75, 3.63] );
my %temp_def = ( "tnom"  => 0  , 
                 "tmin"  => 25 ,
                 "tmax"  => 50 );

## Ici inutile à terme ; voir alim_def au dessus
my %vhdl_def = ( "avddgo1" => 
                { "min" => 1.0 ,
                  "max" => 2.0 } ,
                 "avddgo2" => 
                { "min" => 1.0 ,
                  "max" => 2.0 } ,
                 "avddio" => 
                { "min" => 1.0 ,
                  "max" => 2.0 } ) ;

#print Dumper \%voltage_def;
#print Dumper \%temp_def; exit ;
#print Dumper \%vhdl_def; exit;
my $eldo_sep='********************************************************************************';
my $vhdl_sep='--------------------------------------------------------------------------------';
my $veri_sep='////////////////////////////////////////////////////////////////////////////////';
my $term_sep='################################################################################';

my ($verbose,$help,$scan,$init)=(0,0,0,0);
my $techno = "xh018";
my (@gen,@process,@voltage,@temp,@pvt,@mc,@param,@testbench);
my (@corner_mos,@corner_bip,@corner_res,@corner_cap);
my (@paramlist,%paramlist,%tbenchlist);
my ($mc,$step_param,@step,@step_param);

my $key ;

my ($t1,$t2,$t3,$t4);
my (@t1,@t2,@t3,@t4);

my ($t,@t);
my ($k,$v) = () ;
my ( %param , %step , %mc , %step_param );

my (@netlist_fullbody,@netlist_body,@netlist_comment);
my %subckt;
my $subckt_nr = 0 ;
my $sckt_name;
my (@arglist,$arglist);
my ($pin_index,$param_index) = (0,0) ;
my ($instance,$instance_type,$instance_name);

my $numberspice=qr/(?:[+-]?\d+(?:\.\d+)?(?:meg|[afgnmpu]|e[+-]?\d+)?)|(?:[+-]?\.\d+(?:meg|[afgnmpu]|e[+-]?\d+)?)/i;

################################################################################
# Gestion des fichiers d'entrée sortie
################################################################################
# Définition du path de travail.
#my $path="/nfs/work-crypt/ic/usr/aferret/altis/simulation/inv/eldoD/schematic/netlist/";
my $path=`pwd`; chomp $path; $path .="/" ;
## Boulot
my $commonpath = "/nfs/home/aferret/Documents/Outils/programmation/perl/";
## Home
#my $commonpath = $path;

opendir (PATH, $path) or die $!;

my $caracfile = $path . "carac.inc";
my $netlistfile = $path . "netlist.cir";
my $eldofile = $path . "carac";
my $basenetlistfile ; my $lc_netlistfile ;

my ($netlistFH,$caracFH,$eldoFH,$basenetlistFH,$lc_netlistFH);

my $fh;

sub filehandle {
  print ("Scanning for simulation files in path $path ...\n");

  print ("File $caracfile not found. Check directory or init.\n") if ( !(-f $caracfile) );
  open ($caracFH, "<$caracfile") or die ("open : $!");

  print ("File $netlistfile not found. Check directory or init.\n") if ( !(-f $netlistfile) );
  open ($netlistFH, "<$netlistfile") or die ("open : $!");

  print ("File $eldofile not found. Check directory or init.\n") if ( !(-f $eldofile) );
  open ($eldoFH, ">$eldofile") or die ("open : $!");
  print ("Scanning done ;\n\tNetlist file : $netlistfile\n\tCarac file : $caracfile\n\tFile launched by eldo simulator : $eldofile\n\n");
}

################################################################################
# Définition des fonctions
################################################################################
sub doublons_grep {
## Fonction suppression des doublons dans un hash. Retourne les clés dans l'ordre.
## usage : @tableau_sans_doublons = doublons_grep (\@tableau_avec_doublons?);
  my ($ref_tabeau) = @_;
  my %hash_sans_doublon;
  return grep { !$hash_sans_doublon{$_}++ } @{$ref_tabeau};
}

## uniq on array
push(@EXPORT,'uniq') ;
sub uniq {
  my @ret=() ;
  while ( my $item = shift @_ ) { push(@ret,$item) unless grep {/^\Q$item/} @ret ; }
  return @ret ;
}

sub stdin_answer {
## Fonction "Je te pose une question" avec un range de réponses ; réponse unique
## Usage réponse_de_retour = stdin_answer ('Question', @liste_de_réponses_possible);
  my @in = @_ ; 
  my $question = shift @in ; map ( {tr/A-Z/a-z/} @in );#Si case insensitive
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

sub stdin_answer_mult {
## Fonction question avec un range de réponses ; réponse multiple retournée sous forme de tableau ; Elimination des doublons
## Retourne un résultat s'il en trouve au moins un et élimine les autres. Case sensitive
## Usage : @réponse_de_retour = stdin_answer_mult ('Question', @liste_de_réponses_possible)n
  my @in = @_ ; 
  my $question = shift @in ;
  my %answer;
  my @g_answer;
  print "$question\n";
  foreach (@in) { $answer{$_}++ ; }
  @g_answer = split /\s+/, <STDIN>;
  @g_answer = doublons_grep(\@g_answer);
  @g_answer = grep { $answer{$_} } @g_answer;
  while(@g_answer==0) {
    print "Answer is not in the possible range ; choices : @in\n$question\n";
    @g_answer = split /\s+/, <STDIN>;
    @g_answer = doublons_grep(\@g_answer);
    @g_answer = grep { $answer{$_} } @g_answer;
  }
  return @g_answer;
} # End stdin_answer_mult sub

sub outputfile { # prend en parametre un nom de fichier pour écriture
# prend en parametre un nom de fichier pour écriture
# vérifie s'il existe et demande confirmation d'overwrite
# le crée sinon
# retourne le filehandle
# usage : outputfile("nom_du_fichier")
  my $_outputfile;
  my $_outputfile_filehandle;
  ($_outputfile)=@_;
  my $_other_outputfile=$_outputfile;
  if (!(-f $_outputfile)) {
    system ( "touch" , $path.$_outputfile) ;
    open ($_outputfile_filehandle, ">$_outputfile") or die ("Open : $!");
  } else {
    my $choice = stdin_answer ("le fichier existe déjà remplacer ?",'Yes','No','y','n');
    if ($choice eq "yes"||"y") {
      open ($_outputfile_filehandle, ">$_outputfile") or die ("Open : $!") ;
      } else {
        while ($_other_outputfile eq $_outputfile) { print "Select new name :\n" ; $_other_outputfile = <STDIN> ; chomp $_other_outputfile ;}
        system ( "touch" , $path.$_other_outputfile) ;
      }
  }
  return $_outputfile_filehandle;
} # End sub outputfile

sub init { # Initialisation du répertoire
# Génération du fichier netlist.cir à partir d'un fichier s'il n'existe pas
# Génération du carac.inc et du carac à partir des templates s'ils n'existent pas
  print "$term_sep\n";
  print ("Initialization phase : Generation of simulation files...\n");
  print "\nFiles found :\n";
  my %file; 
  my @file = readdir PATH;
  foreach (@file) {
    printf ("%-40s", "\n\t --> $_") and $file{$_}++ if (-f $_);
    print "\t-- .cir file found" if /\.cir$/; 
    print "\t-- .inc file found" if /\.inc$/; }
  print "\n";
  my @cirfile = grep /\.cir$/, @file;
  my @incfile = grep /\.inc$/, @file;
  $lc_netlistfile = $path."temp.cir" ;

  if ($file{'netlist.cir'}) {
    $choice = stdin_answer ('netlist.cir file detected. Do you want to overwrite it ?','yes','no');
    if ($choice eq 'yes') {
      system ( "rm" , $path."netlist.cir") ;
      opendir (PATH, $path) or die $!;
      @file = readdir PATH;
      foreach (@file) {
        printf ("%-40s", "\n\t --> $_") if (-f $_);}
      print "\n";
      $choice = stdin_answer ('Select file to use for generation of netlist.cir',@file);
      $basenetlistfile = $path.$choice ;
      system ("touch", $lc_netlistfile) ;
      open ($basenetlistFH, "<$basenetlistfile") or die ("open : $!");
      open ($lc_netlistFH, ">$lc_netlistfile") or die ("open : $!");
      while (<$basenetlistFH>) { printf( $lc_netlistFH  lc $_ ) ; }
      close ($lc_netlistFH) ; open ($lc_netlistFH, "<$lc_netlistfile") or die ("open : $!");
      scan_netlist($lc_netlistFH); 
      make_netlistfile();
      system ("rm", $lc_netlistfile) ;
      } elsif ($choice eq 'no') {
      $choice = stdin_answer ("Do you want to :\n 1-->make a backup copy of netlist.cir and regenerate it from another file ?\n 2-->keep netlist.cir as is ?",1,2) ;
        if ( $choice == 1 ) { # Backup et régén
          system ( "cp", $path."netlist.cir", $path."netlist_bkp".$date.".cir");
          opendir (PATH, $path) or die $!;
          @file = readdir PATH;
          $index=0;
          foreach (@file) {
            printf ("%-40s", "\n\t --> $_") if (-f $_);}
          print "\n";
          $choice = stdin_answer ('Select file to use for generation of netlist.cir',@file);
          $basenetlistfile = $path.$choice ;
          system ("touch", $lc_netlistfile) ;
          open ($basenetlistFH, "<$basenetlistfile") or die ("open : $!");
          open ($lc_netlistFH, ">$lc_netlistfile") or die ("open : $!");
          while (<$basenetlistFH>) { printf( $lc_netlistFH  lc $_ ) ; }
          close ($lc_netlistFH) ; open ($lc_netlistFH, "<$lc_netlistfile") or die ("open : $!");
          scan_netlist($lc_netlistFH); 
          make_netlistfile();
          system ("rm", $lc_netlistfile) ;
        } elsif ( $choice == 2 ) {
          $basenetlistfile = $path."netlist.cir" ;
          open ($basenetlistFH, "<$basenetlistfile") or die ("open : $!");
          scan_netlist($basenetlistFH); 
          }
      }
    } else { # Si le fichier netlist.cir n'existe pas : création à partir d'un fichier au choix
      $choice = stdin_answer ('Select file to use for generation of netlist.cir',@file);
      $basenetlistfile = $path.$choice ;
      system ("touch", $lc_netlistfile) ;
      open ($basenetlistFH, "<$basenetlistfile") or die ("open : $!");
      open ($lc_netlistFH, ">$lc_netlistfile") or die ("open : $!");
      while (<$basenetlistFH>) { printf( $lc_netlistFH  lc $_ ) ; }
      close ($lc_netlistFH) ; open ($lc_netlistFH, "<$lc_netlistfile") or die ("open : $!");
      scan_netlist($lc_netlistFH); 
      make_netlistfile();
      system ("rm", $lc_netlistfile) ;
    }
## Test existance carac et carac.inc, overwrite éventuel
  if ($file{'carac.inc'}) {
    $choice = stdin_answer ('carac.inc file exists. Overvrite it ?','yes','no') ;
    system ( "cp", $commonpath."carac_template.inc", $path."carac.inc") if ($choice eq 'yes');
  } else {
    print "Generation of carac.inc file from template\n";
    system ( "cp", $commonpath."carac_template.inc", $path."carac.inc");
  }
  if ($file{'carac'}) {
    $choice = stdin_answer ('carac file exists. Overvrite it ?','yes','no') ;
    system ( "cp", $commonpath."carac_template.inc", $path."carac") if ($choice eq 'yes');
  } else {
    print "Generation of carac.inc file from template\n";
    system ( "cp", $commonpath."/carac_template.inc", $path."carac");
  }
  print ("Ending initialization phase.\n");
  print "$term_sep\n\n";
} # End sub init

sub gen_model { # Génération des modèles VHDL et Verilog à partir des subckt de la netlist
  my $bmodel ; my $bmodel_FH ;
  ($bmodel)=@_; #Ici, faire un foreach ?
  my @key;
  my ($bextension,$bname); my @bmodel ;
  my %pin ; my @pin ; my $pintype ;
  print "\n$term_sep\n";
  print "\nNo Subckt definition found in the netlist. Check file or scan.\n\n" and exit unless (%subckt) ; ## Ici, à check ?

##Génération des modèles veriloga
  if ($bmodel eq "veri") {
    $bname = "Verilog" ; $bextension = ".va";
    print ("Generation of $bname behavioral models ...\n") ; 
##Sélection des instance à modéliser
    print "\n\t-->Subckt list in netlist :\n" ; print "$_\n" foreach ( keys %subckt ) ;
    my @bmodel = stdin_answer_mult ('Select subckt to be modeled',( keys %subckt )); my $model ;

##Génération des fichiers modèle
    foreach $model (@bmodel) {
      print "\n$term_sep\nGeneration of verilog model file for $model\n" ;
      $bmodel_FH = outputfile($model.$bextension) ;
      print ($bmodel_FH "$veri_sep\n//\n//\tCompagny : ASYGN\n//\tEngineer : \n//\n//\tCreation Date : $date\n//\tModule type : $bname\n//\tDesign name :\n//\tModule name : $model\n//\tProject name :\n//\tTool versions :\n//\tDescription : \n//\n//\tDependencies : \n//\n//\tRevision : \n//\tAdditionnal comments : \n//\n$veri_sep\n\n\n"); #Entête
      print ($bmodel_FH "`include \"example.v\"\n//Insert here other module/libraires definition\n\n\n"); #Définition des modules/librairies communes

##Définition du module avec ses pins
      print($bmodel_FH "module $model (\n") ;
      foreach ( sort { $a <=> $b } keys %{$subckt{$model}{pinlist}} ) { ## Définitions ports du module
        print ($bmodel_FH "\t$subckt{$model}{pinlist}{$_}{name},\n") if ($subckt{$model}{pinlist}{$_}{single}) ;
        if ($subckt{$model}{pinlist}{$_}{vector} && $subckt{$model}{pinlist}{$_}{vector}{bit} eq "lsb") {
          print ($bmodel_FH "\t") ;
          print ($bmodel_FH $subckt{$model}{pinlist}{$_}{dir}) unless ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
          print ($bmodel_FH $subckt{$model}{pinlist}{$_}{type}) unless ($subckt{$model}{pinlist}{$_}{type} eq "custom");
          print ($bmodel_FH "_") unless ($subckt{$model}{pinlist}{$_}{type} eq "custom" || $subckt{$model}{pinlist}{$_}{dir} eq "unknown");
          print ($bmodel_FH "$subckt{$model}{pinlist}{$_}{vector}{name},\n") ;
          }
        }
      print ($bmodel_FH ");\n\n"); #Fin de définition du module, définition des types I/O pour les pins
      
      ## Définitions des I/O associés aux ports
      print ($bmodel_FH "// I/O port definition\n");
      foreach ( sort { $a <=> $b } keys %{$subckt{$model}{pinlist}} ) { 
        if ($subckt{$model}{pinlist}{$_}{type} eq "alim") {
          print "\tAlim pin found : $subckt{$model}{pinlist}{$_}{name} will be defined as inout\n" if ( $verbose ==1 ) ;
          print ($bmodel_FH "inout $subckt{$model}{pinlist}{$_}{name} ; // Power port\n");
        } elsif ($subckt{$model}{pinlist}{$_}{type} ne "alim") {
          if ($subckt{$model}{pinlist}{$_}{single}) {
            print "\tSingle pin found : $subckt{$model}{pinlist}{$_}{name} type $subckt{$model}{pinlist}{$_}{type}\n" if ( $verbose == 1 ) ;
            print ($bmodel_FH "input ") if ($subckt{$model}{pinlist}{$_}{dir} eq "i");
            print ($bmodel_FH "output ") if ($subckt{$model}{pinlist}{$_}{dir} eq "o");
            print ($bmodel_FH "inout ") if ($subckt{$model}{pinlist}{$_}{dir} eq "io");
            print ($bmodel_FH "input/output/inout ") if ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH "$subckt{$model}{pinlist}{$_}{name} ;");
            if ($subckt{$model}{pinlist}{$_}{dir} eq "unknown") {print ($bmodel_FH "//Custom definition -> user modification required\n") } else {print ($bmodel_FH "\n")}
          } elsif ($subckt{$model}{pinlist}{$_}{vector}{bit} eq "lsb") {
            print "\tVector pin found : $subckt{$model}{pinlist}{$_}{vector}{name} type $subckt{$model}{pinlist}{$_}{type}\n" if ( $verbose == 1 ) ;
            print ($bmodel_FH "input ") if ($subckt{$model}{pinlist}{$_}{dir} eq "i");
            print ($bmodel_FH "output ") if ($subckt{$model}{pinlist}{$_}{dir} eq "o");
            print ($bmodel_FH "inout ") if ($subckt{$model}{pinlist}{$_}{dir} eq "io");
            print ($bmodel_FH "input/output/inout ") if ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH "[$subckt{$model}{pinlist}{$_}{vector}{max}:$subckt{$model}{pinlist}{$_}{vector}{min}] ") ;
            print ($bmodel_FH $subckt{$model}{pinlist}{$_}{dir}) unless ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH $subckt{$model}{pinlist}{$_}{type}) unless ($subckt{$model}{pinlist}{$_}{type} eq "custom");
            print ($bmodel_FH "_") unless ($subckt{$model}{pinlist}{$_}{type} eq "custom" || $subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH "$subckt{$model}{pinlist}{$_}{vector}{name} ;");
            if ($subckt{$model}{pinlist}{$_}{dir} eq "unknown") {print ($bmodel_FH "//Custom definition -> user modification required\n") } else {print ($bmodel_FH "\n")}
          }
        }
      } ## Fin de définition des types I/O pour les pins
      ## Définitions des wires associés aux ports
      print ($bmodel_FH "\n// Port wire definition\n");
      foreach ( sort { $a <=> $b } keys %{$subckt{$model}{pinlist}} ) { 
        if ($subckt{$model}{pinlist}{$_}{single}) {
            print ($bmodel_FH "wire $subckt{$model}{pinlist}{$_}{name} ; ");
            print ($bmodel_FH "// input wire \n") if ($subckt{$model}{pinlist}{$_}{dir} eq "i");
            print ($bmodel_FH "// output wire \n") if ($subckt{$model}{pinlist}{$_}{dir} eq "o");
            print ($bmodel_FH "// inout wire \n") if ($subckt{$model}{pinlist}{$_}{dir} eq "io");
            print ($bmodel_FH "// custom wire \n") if ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
        } elsif ($subckt{$model}{pinlist}{$_}{vector}{bit} eq "lsb") {
            print ($bmodel_FH "wire [$subckt{$model}{pinlist}{$_}{vector}{max}:$subckt{$model}{pinlist}{$_}{vector}{min}] ") ;
            print ($bmodel_FH $subckt{$model}{pinlist}{$_}{dir}) unless ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH $subckt{$model}{pinlist}{$_}{type}) unless ($subckt{$model}{pinlist}{$_}{type} eq "custom");
            print ($bmodel_FH "_") unless ($subckt{$model}{pinlist}{$_}{type} eq "custom" || $subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH "$subckt{$model}{pinlist}{$_}{vector}{name} ; ");
            print ($bmodel_FH "// input wire \n") if ($subckt{$model}{pinlist}{$_}{dir} eq "i");
            print ($bmodel_FH "// output wire \n") if ($subckt{$model}{pinlist}{$_}{dir} eq "o");
            print ($bmodel_FH "// inout wire \n") if ($subckt{$model}{pinlist}{$_}{dir} eq "io");
            print ($bmodel_FH "// custom wire \n") if ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
        }
      }
      ## Définitions des wires internes
      print ($bmodel_FH "\n// Internal wire definition\n\t//Define here internal wire\n\n");

## Fin ports/wires. Ecriture des composants s'il y en a.
      if ($subckt{$model}{dependency}) {
        my $instance = -1 ;
        print "\n\tDependency have been found. Trying to define them in the component section. Please check connectivity & syntax ...\n" if ( $verbose == 1 );
        print ($bmodel_FH "\n$veri_sep\n// Component section\n$veri_sep\n\n");
        foreach (@{$subckt{$model}{dependency}}) {
          $instance++;
          my ($key) = keys $_ ;
          print "\t-->Defining component $key\n" if ( $verbose == 1 );
          print($bmodel_FH "\t// Component $key definition. Please check syntax & connectivity\n\t$key ${$subckt{$model}{dependency}[$instance]}{$key}{sckt_ref} (\n");
          my $index=0;
          foreach my $pin (sort {$a <=> $b} keys %{$subckt{${$subckt{$model}{dependency}[$instance]}{$key}{sckt_ref}}{pinlist}}) {
          #foreach my $pin (@{$subckt{$model}{dependency}[$instance]{$key}{pinlist}}) {
            printf($bmodel_FH "\t\t");
            printf($bmodel_FH "%-20s",".$subckt{${$subckt{$model}{dependency}[$instance]}{$key}{sckt_ref}}{pinlist}{$pin}{name}");
            printf($bmodel_FH "\t\t");
            printf($bmodel_FH "%-20s","(${$subckt{$model}{dependency}[$instance]}{$key}{pinlist}[$index])");
            printf($bmodel_FH "\t,\n");
            $index++; 
          }
          print ($bmodel_FH "\t);\n\t// Component $key definition end.\n\n");
        }
        print ($bmodel_FH "$veri_sep\n// End component section\n$veri_sep\n\n");
      }
      ## Reste du code avec définition des modules par connection
      #print ($bmodel_FH "\nendmodule //End module $model\n\n");
      close $bmodel_FH;
    }
  } ## End if model verilog
  print "\n$term_sep\nGeneration of verilog model file done\n" ;

##Génération des modèles vhdl
  if ($bmodel eq "vhdl") { 
    $bname = "VHDL" ; $bextension = ".hdl";
    print ("Generation of $bname behavioral models ...\n") ; 
##Sélection des instance à modéliser
    print "\n\t-->Subckt list in netlist :\n" ; print "$_\n" foreach ( keys %subckt ) ;
    my @bmodel = stdin_answer_mult ('Select subckt to be modeled',( keys %subckt )); my $model ;

##Génération des fichiers modèle
    foreach $model (@bmodel) {
      print "\n$term_sep\nGeneration of vhdl model file for $model\n" ;
      $bmodel_FH = outputfile($model.$bextension) ;
      print ($bmodel_FH "$vhdl_sep\n--\n--\tCompagny : ASYGN\n--\tEngineer : \n--\n--\tCreation Date : $date\n--\tDesign name :\n--\tModule type : $bname\n--\tModule name : $model\n--\tProject name :\n--\tTool versions :\n--\tDescription : \n--\n--\tDependencies : \n--\n--\tRevision : \n--\tAdditionnal comments : \n--\n$vhdl_sep\n\n\n"); #Entête
      print ($bmodel_FH "library ieee, discipline;\nuse IEEE.STD_LOGIC_1164.all;\nuse IEEE.numeric_std.all;\nuse work.internal_bus.all;\n--Insert here other libraires definition\n\n\n"); #Définition des librairies communes
## Définitions des génériques
      print($bmodel_FH "ENTITY $model is \n\n--Generic variable definition\nGENERIC (\n"); 
      foreach ( keys %{$subckt{$model}{pinlist}} ) { ## Définitions des génériques de tests sur les alims si on les trouve dans le hash alim_def{$techno}
        if ($alim_def{$techno}{$subckt{$model}{pinlist}{$_}{name}}) {
          print "\tAlim pin found : $subckt{$model}{pinlist}{$_}{name} Max / Min value for vhdl test : $alim_def{$techno}{$subckt{$model}{pinlist}{$_}{name}}{vhdl}{max} $alim_def{$techno}{$subckt{$model}{pinlist}{$_}{name}}{vhdl}{min}\n" if ( $verbose ==1 ) ;
          print ($bmodel_FH "\tg_$subckt{$model}{pinlist}{$_}{name}"."_min : real := $alim_def{$techno}{$subckt{$model}{pinlist}{$_}{name}}{vhdl}{min} ; -- Generic for power tests\n");
          print ($bmodel_FH "\tg_$subckt{$model}{pinlist}{$_}{name}"."_max : real := $alim_def{$techno}{$subckt{$model}{pinlist}{$_}{name}}{vhdl}{max} ; -- Generic for power tests\n");
        }
      }
      print ($bmodel_FH "\t--g_generic_name : real := generic_value ;\n\t--g_generic_name : realvector (0 TO XX) := (gen_val1, gen_val2, ...,gen_valXX) ;\n);\n\n"); #Fin de définintion des génériques

##Début de définintion des ports
      print($bmodel_FH "--I/O Block definition\nPORT(\n"); 
      foreach ( sort { $a <=> $b } keys %{$subckt{$model}{pinlist}} ) { ## Définition des alims comme des ports de type terminal - electrical
        if ($alim_def{$techno}{$subckt{$model}{pinlist}{$_}{name}}) {
          print "\tAlim pin found : $subckt{$model}{pinlist}{$_}{name} will be defined as terminal, type electrical\n" if ( $verbose ==1 ) ;
          print ($bmodel_FH "\tterminal $subckt{$model}{pinlist}{$_}{name} : electrical ; -- Power port\n");
        }
      }
      foreach ( sort { $a <=> $b } keys %{$subckt{$model}{pinlist}} ) { ## Définitions des autres ports, ordre original
        if ($subckt{$model}{pinlist}{$_}{type} ne "alim") {
          if ($subckt{$model}{pinlist}{$_}{single}) {
            print "\tStandard pin found : $subckt{$model}{pinlist}{$_}{name} type $subckt{$model}{pinlist}{$_}{type}\n" if ( $verbose == 1 ) ;
            print ($bmodel_FH "\tterminal") if ($subckt{$model}{pinlist}{$_}{type} eq "a");
            print ($bmodel_FH "\tsignal") if ($subckt{$model}{pinlist}{$_}{type} eq "d");
            print ($bmodel_FH "\tsignal/terminal") if ($subckt{$model}{pinlist}{$_}{type} eq "custom");
            print ($bmodel_FH " $subckt{$model}{pinlist}{$_}{name} : in") if ($subckt{$model}{pinlist}{$_}{dir} eq "i");
            print ($bmodel_FH " $subckt{$model}{pinlist}{$_}{name} : out") if ($subckt{$model}{pinlist}{$_}{dir} eq "o");
            print ($bmodel_FH " $subckt{$model}{pinlist}{$_}{name} : inout") if ($subckt{$model}{pinlist}{$_}{dir} eq "io");
            print ($bmodel_FH " $subckt{$model}{pinlist}{$_}{name} : in/out/inout") if ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH " electrical ; \n") if ($subckt{$model}{pinlist}{$_}{type} eq "a") ;
            print ($bmodel_FH " std_ulogic ; \n") if ($subckt{$model}{pinlist}{$_}{type} eq "d") ;
            print ($bmodel_FH " electrical/std_ulogic ;") if ($subckt{$model}{pinlist}{$_}{type} eq "custom") ;
            print ($bmodel_FH " -- Custom definition -> user modification required\n") if ($subckt{$model}{pinlist}{$_}{type} eq "custom" || $subckt{$model}{pinlist}{$_}{dir} eq "unknown") ;
          } elsif ($subckt{$model}{pinlist}{$_}{vector} && $subckt{$model}{pinlist}{$_}{vector}{bit} eq "lsb") {
            print "\tStandard vector lsb found : $subckt{$model}{pinlist}{$_}{vector}{name} type $subckt{$model}{pinlist}{$_}{type}\n" if ( $verbose == 1 ) ;
            print ($bmodel_FH "\tterminal ") if ($subckt{$model}{pinlist}{$_}{type} eq "a");
            print ($bmodel_FH "\tsignal ") if ($subckt{$model}{pinlist}{$_}{type} eq "d");
            print ($bmodel_FH "\tsignal/terminal ") if ($subckt{$model}{pinlist}{$_}{type} eq "custom");
            print ($bmodel_FH $subckt{$model}{pinlist}{$_}{dir}) unless ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH $subckt{$model}{pinlist}{$_}{type}) unless ($subckt{$model}{pinlist}{$_}{type} eq "custom");
            print ($bmodel_FH "_") unless ($subckt{$model}{pinlist}{$_}{type} eq "custom" || $subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH "$subckt{$model}{pinlist}{$_}{vector}{name} : in") if ($subckt{$model}{pinlist}{$_}{dir} eq "i");
            print ($bmodel_FH "$subckt{$model}{pinlist}{$_}{vector}{name} : out") if ($subckt{$model}{pinlist}{$_}{dir} eq "o");
            print ($bmodel_FH "$subckt{$model}{pinlist}{$_}{vector}{name} : inout") if ($subckt{$model}{pinlist}{$_}{dir} eq "io");
            print ($bmodel_FH "$subckt{$model}{pinlist}{$_}{vector}{name} : in/out/inout") if ($subckt{$model}{pinlist}{$_}{dir} eq "unknown");
            print ($bmodel_FH " electrical_vector($subckt{$model}{pinlist}{$_}{vector}{max} downto $subckt{$model}{pinlist}{$_}{vector}{min}) ; \n") if ($subckt{$model}{pinlist}{$_}{type} eq "a") ;
            print ($bmodel_FH " std_ulogic_vector($subckt{$model}{pinlist}{$_}{vector}{max} downto $subckt{$model}{pinlist}{$_}{vector}{min}) ; \n") if ($subckt{$model}{pinlist}{$_}{type} eq "d") ;
            print ($bmodel_FH " electrical/std_ulogic_vector($subckt{$model}{pinlist}{$_}{vector}{max} downto $subckt{$model}{pinlist}{$_}{vector}{min}) ;") if ($subckt{$model}{pinlist}{$_}{type} eq "custom") ;
            print ($bmodel_FH " -- Custom definition -> user modification required\n") if ($subckt{$model}{pinlist}{$_}{type} eq "custom" || $subckt{$model}{pinlist}{$_}{dir} eq "unknown") ;
          }
        }
      } #Fin des définitions des ports, fin de l'ENTITY, passage à la suite
      print ($bmodel_FH ");\n\nEND ENTITY $model;\n\nARCHITECTURE FUNCTIONNAL OF $model IS\n\n--Quantity and signal definitions\n");
      foreach ( keys %{$subckt{$model}{pinlist}} ) { ## Définition des signaux pour les power tests
        if ($alim_def{$techno}{$subckt{$model}{pinlist}{$_}{name}}) {
          print ($bmodel_FH "\tsignal s_test_$subckt{$model}{pinlist}{$_}{name} : boolean = false ; -- Power test purpose\n\tquantity v_$subckt{$model}{pinlist}{$_}{name} --To be completed acoording to alim type : power/ground\n");
        }
      }
      print ($bmodel_FH "\t--signal s_signalname : boolean/std_ulogic/integer/real/signed/unsigned := basevalue ;\n\nBEGIN\n\n--Power tests\n");
      foreach ( keys %{$subckt{$model}{pinlist}} ) { ## Ecriture des power tests
        if ($alim_def{$techno}{$subckt{$model}{pinlist}{$_}{name}}) {
          print ($bmodel_FH "\ts_test_$subckt{$model}{pinlist}{$_}{name} <= true when v_$subckt{$model}{pinlist}{$_}{name}\'above(g_${subckt{$model}{pinlist}{$_}{name}}_min)\n\tand not v_$subckt{$model}{pinlist}{$_}{name}\'above(g_${subckt{$model}{pinlist}{$_}{name}}_max) and domain=time_domain\n\telse false;\n");
        }
      }
      print ($bmodel_FH "--Repports in transcript for power tests\n");
      foreach ( keys %{$subckt{$model}{pinlist}} ) { ## Ecriture repports de power tests dans le transcript
        if ($alim_def{$techno}{$subckt{$model}{pinlist}{$_}{name}}) {
          print ($bmodel_FH "\tassert s_test_$subckt{$model}{pinlist}{$_}{name} or s_enable_fct = 0.0 \n\treport \"$model : $subckt{$model}{pinlist}{$_}{name} powercheck failure ; voltage value out of bound\" severity warning;\n");
        }
      }
## Fin des power tests/ecriture transcripts. Ecriture des composants s'il y en a.
      if ($subckt{$model}{dependency}) {
        my $instance = -1 ;
        print "\n\tDependency have been found. Trying to define them in the component section. Please check connectivity & syntax ...\n" if ( $verbose == 1 );
        print ($bmodel_FH "\n$vhdl_sep\n-- Component section\n$vhdl_sep\n\n");
        foreach (@{$subckt{$model}{dependency}}) {
          $instance++;
          my ($key) = keys $_ ;
          print "\t-->Defining component $key\n" if ( $verbose == 1 );
          print($bmodel_FH "\t-- Component $key definition. Please check syntax & connectivity\n\t$key entity ${$subckt{$model}{dependency}[$instance]}{$key}{sckt_ref} port map (\n");
          my $index=0;
          foreach my $pin (sort {$a <=> $b} keys %{$subckt{${$subckt{$model}{dependency}[$instance]}{$key}{sckt_ref}}{pinlist}}) {
          #foreach my $pin (@{$subckt{$sckt_name}{dependency}[$instance]{$key}{pinlist}}) {
            printf($bmodel_FH "\t\t");
            printf($bmodel_FH "%-20s","$subckt{${$subckt{$model}{dependency}[$instance]}{$key}{sckt_ref}}{pinlist}{$pin}{name}");
            printf($bmodel_FH "=>\t\t");
            printf($bmodel_FH "%-20s","${$subckt{$model}{dependency}[$instance]}{$key}{pinlist}[$index]");
            printf($bmodel_FH "\t,\n");
            $index++; 
          }
          print ($bmodel_FH "\t);\n\t-- Component $key definition end.\n\n");
        }
      }
      print ($bmodel_FH "\nEND ARCHITECTURE FUNCTIONNAL\n\n");
      close $bmodel_FH;
    }
  print "\n$term_sep\nGeneration of VHDL model file done\n" ;
  } ## End VHDL model generation
  #print Dumper \%subckt;
  #print Dumper \%pin;
  #print Dumper \@pin;
} # End sub gen_model

sub scan_carac {
  print "$term_sep\n";
  print ("Scan phase : Carac file scan...\n");
  while (<$caracFH>) {
    next if /^\*/ ;
    next if /^\s*$/ ;
    if (/^\.param\s+(.*)/i) { # Il va peut être falloir ajouter un autre while pour prendre en compte les \n + 
      #Old version
      #$1 =~ s/\s*=\s*/=/g;
      #print "\$1 : $1\n" ;
      #push @paramlist , split(/[\s=]+/,$1) ;
      #%paramlist=split(/[\s=]+/,$1) ;
      #foreach my $p (split(/\s+/,$_)) {
      #  ($k,$v) = ( $p =~ /(\w+)=([\+-\.\w]+)/ ) and $param{$k}=$v ;
      #}
      #foreach(keys(%paramlist)) {
        #print "\tParameter definition line $. ; name : $_ ; Default value $paramlist{$_}\n" if ($verbose == 1 ) ;
      #}
      my %split=split(/[\s=]+/,$1) ;
      foreach (keys %split) { push @paramlist , ($_,$split{$_}) ; print "\tParameter definition line $. ; name : $_ ; Default value $split{$_}\n" ; }
    } elsif ( /^\.define_testbench\s+(\w+)/i ) {
      print "\tTestbench definition found line $. ; name : $1\n";
      my $t = $1;
      #$t =~ tr/A-Z/a-z/;
      ++$tbenchlist{$t};
    } elsif ( /^\.lib include\.inc\s+(\w+)/i) {
      print "\tModel definition found line $. ; name : $1\n" ;
    } elsif ( /^\.step\s+param\s+(\w+)\s+(incr|dec|oct|lin|list|file)[\s+|\s*=\s*]([\w+\.?\w* +]+)/i) { #Détection .step sur un paramètre unique
      $step{$1}{'incr_spec'}=$2;
      @{$step{$1}{'arg'}}=split(/\s+/,$3);
      print "\tParameter step found line $. ; Single param : $1 ; Incr_spec : $step{$1}{'incr_spec'} ; Incr_arg : @{$step{$1}{'arg'}}\n";
    } elsif ( /^\.step\s+param\s+\(([\w+\s+]+)\)\s+(incr|dec|oct|lin|list|file)[\s+|\s*=\s*]((:?(.*)\s+)+)/i ) { #Détection .step sur des paramètres multiples
      $step{$1}{'incr_spec'}=$2;
      @{$step{$1}{'arg'}}=split(/\s+/,$3);
      print "\tParameter step found line $. ; Multi param : $1 ; Incr_spec : $step{$1}{'incr_spec'} ; Incr_arg : @{$step{$1}{'arg'}}\n";
    }
  }
  %paramlist=@paramlist;
  #print Dumper \%paramlist if ($verbose == 1 ) ;
  #print Dumper \%tbenchlist if ($verbose == 1 ) ;
  #print Dumper \%step if ( $verbose == 1 ) ;
  print ("Ending carac file scan phase.\n");
  print "$term_sep\n\n";
} # End scan_carac sub

sub scan_netlist {
  ($fh)=@_;
  print "$term_sep\n";
  print ("Scan phase : Netlist file scan...\n");
  while (<$fh>) {
    if (/^\.subckt\s+(\S+)(?:\s+)?(.*)?$/i) { ## Detection structure commençant par .subckt. Increment de l'indice subckt, reset du tableau arglist et des autres tables
      $arglist=() ; @arglist=() ; $subckt_nr++;

## Affectation du nom du subckt, de sa position dans le fichier. On stocke la position dans la netlist de base. Traitement de la première ligne de définition du subckt
      @arglist = split( /\s+/, $2 ) if ( $2 ) ;
      $sckt_name = $1 ; $arglist = join (" ",@arglist) if ( ! @arglist == 0 ) ; # On ne join que si la table arglist est non vide, cas correspondant à scktname seul sur la première ligne
      push @{$subckt{$sckt_name}{argument}}, $2 if ($2) ;
## Debug
      #print "@arglist\n$arglist\n";
      $subckt{$sckt_name}{number} = $subckt_nr;
      $subckt{$sckt_name}{subckt_pos}=$.;
      print "  -->Found subckt definition ; Subckt number $subckt{$sckt_name}{number}\n" ;
      print "\tName : $sckt_name\n" if ( $verbose ==1 ) ;
      print "\tLine position : $subckt{$sckt_name}{subckt_pos}\n" if ( $verbose ==1 ) ;
## Fin traitement première ligne de structure

## Traitement de la suite de la déclaration du subckt. While dans un autre while.
      while (<$fh>) {
        next if /^\s*$/ ; #Rien si ligne vide
        if (! /^\+/) { # Si ça n'a pas commencé par une ligne vide ou un + on sort de la déclaration du subckt et on commence à remplir/parcourir le body
          push @{$subckt{$sckt_name}{allbody}}, $1."\n" if (/^\s*(.*)/) ;
          push @{$subckt{$sckt_name}{comment}}, $_ if (/^\*/) ;
          push @{$subckt{$sckt_name}{body}}, $1 if (/^\s*(.*)/) ;
          last; 
        }
        next if /^\+ ! Pin List/i; # Saut de l'execution pour lignes spéciales
        next if /^\+ ! Param List/; # Saut de l'execution pour lignes spéciales
        next if /^\+ ! Comments/; # Saut de l'execution pour lignes spéciales
        push @{$subckt{$sckt_name}{arg_comments}}, $1 and next if (/^\+\s+!(.*)/);
        chomp $_;
        push @arglist , ( split /\s+/, $_ ) ;
        push @{$subckt{$sckt_name}{argument}}, $_ ;
        }
## Séparation des pins et paramètres. Affectation des positions dans la déclaration et des valeurs de base
  $pin_index = 0 ;
  $param_index = 0;
  $arglist = join (" ",@arglist);
  $arglist =~ s/\+|param|://g;
  $arglist =~ s/^ *//g; # Ici c'est pour effecer l'éventuel premier espace, arrive parfois
  $arglist =~ s/ +/ /g;
  $arglist =~ s/\s*=\s*/=/g;
  @arglist = split /\s+/, $arglist;
##Debug
  #print "Table traitée : @arglist\n";
  print "\tAnalysis of subckt declaration\n";
  foreach (@arglist) {
    if ( /(\w+)=(\w+)/ ) {
      print "\tFound parameter definition ; name $1 ; basevalue : $2\n" if ($verbose == 1 );
      $param_index++;
      $subckt{$sckt_name}{paramlist}{$param_index}{name}=$1;
      $subckt{$sckt_name}{paramlist}{$param_index}{basevalue}=$2;
    } elsif (/([\w\.<>\[\]]+)/) { ## Ici, soucis avec le case sensitive, vérifier si la syntax spice marche avec [], autres ?
## Définition des pins : On associe I/O, A/D, custom et pin unique / vecteur. Attention, io_Vect<3:0> (io) écrase Vect (custom) ??
      print "\tFound pin : $1\n";
      #my $pin = $1 ; $pin =~ tr/[A-Z]/[a-z]/ ;
      $pin_index++;
      if ( $alim_def{$techno}{$_} ) {
        $subckt{$sckt_name}{pinlist}{$pin_index} = { "name" => $_ , "type" => "alim" , "dir" => "io" , "single" => 1 };
      } elsif (/^(io|i|o)(a|d)_([0-9a-zA-Z_]+)[<>]{0}$/i) {
        $subckt{$sckt_name}{pinlist}{$pin_index} = { "name" => $_ , "type" => $2 , "dir" => $1 , "single" => 1 };
      } elsif (/^(io|i|o)(a|d)_([0-9a-zA-Z_]+)<(\d+)>$/i) {
        $subckt{$sckt_name}{pinlist}{$pin_index} = { "name" => $_ , "type" => $2 , "dir" => $1 , "vector" => {"name" => $3 , "index" => $4 } } ;
        $subckt{$sckt_name}{pinvector}{$3} = {"min" => $4 , "max" => $4} if (!$subckt{$sckt_name}{pinvector}{$3}) ; 
        $subckt{$sckt_name}{pinvector}{$3}{min} = $4 if ($4<$subckt{$sckt_name}{pinvector}{$3}{min}) ;
        $subckt{$sckt_name}{pinvector}{$3}{max} = $4 if ($4>$subckt{$sckt_name}{pinvector}{$3}{max}) ;
      } elsif (/^([0-9a-zA-Z_]+)[<>]{0}$/i) {
        $subckt{$sckt_name}{pinlist}{$pin_index} = { "name" => $_ , "type" => "custom" , "dir" => "unknown" , "single" => 1 };
      } elsif (/^([0-9a-zA-Z_]+)<(\d+)>$/i) {
        $subckt{$sckt_name}{pinlist}{$pin_index} = { "name" => $_ , "type" => "custom" , "dir" => "unknown" , "vector" => {"name" => $1 , "index" => $2} } ;
        $subckt{$sckt_name}{pinvector}{$1} = {"min" => $2 , "max" => $2} if (!$subckt{$sckt_name}{pinvector}{$1}) ; 
        $subckt{$sckt_name}{pinvector}{$1}{min} = $2 if ($2<$subckt{$sckt_name}{pinvector}{$1}{min}) ;
        $subckt{$sckt_name}{pinvector}{$1}{max} = $2 if ($2>$subckt{$sckt_name}{pinvector}{$1}{max}) ;
      }
    }
  }
  foreach (keys %{$subckt{$sckt_name}{pinlist}}) {
    if ($subckt{$sckt_name}{pinlist}{$_}{vector} && $subckt{$sckt_name}{pinvector}{$subckt{$sckt_name}{pinlist}{$_}{vector}{name}}) {
        $subckt{$sckt_name}{pinlist}{$_}{vector}{min} = $subckt{$sckt_name}{pinvector}{$subckt{$sckt_name}{pinlist}{$_}{vector}{name}}{min} ;
        $subckt{$sckt_name}{pinlist}{$_}{vector}{max} = $subckt{$sckt_name}{pinvector}{$subckt{$sckt_name}{pinlist}{$_}{vector}{name}}{max} ;
        if ($subckt{$sckt_name}{pinlist}{$_}{vector}{index} == $subckt{$sckt_name}{pinlist}{$_}{vector}{min}) {
          $subckt{$sckt_name}{pinlist}{$_}{vector}{bit} = "lsb"
        } elsif ($subckt{$sckt_name}{pinlist}{$_}{vector}{index} == $subckt{$sckt_name}{pinlist}{$_}{vector}{max}) {
          $subckt{$sckt_name}{pinlist}{$_}{vector}{bit} = "msb"
        } else  {
          $subckt{$sckt_name}{pinlist}{$_}{vector}{bit} = "sb"
        }
    }
  }
  delete $subckt{$sckt_name}{pinvector} ;
  print "\tSubckt declaration summary ; $pin_index pins found ; $param_index parameters found\n";
## Traitement du body du subckt
 print "\tEntering body of subckt\n" if ($verbose == 1 );
 while (<$fh>) {
        if (/^\.ends/i) {
          print "\tEnd of $sckt_name definition\n\n" if ($verbose == 1 ) ;
          last ;
        }# Test fin de subckt
## Ici à modifier, il ne prend pas les sauts de ligne dans le allbody et le body ne dois pas prendre les commentaires
        push @{$subckt{$sckt_name}{allbody}}, $1."\n" if (/^\s*(.*)/) ;
        next if /^\s*$/ ;
        push @{$subckt{$sckt_name}{comment}}, $_ if (/^\*/) ;
        push @{$subckt{$sckt_name}{body}}, $1 if (/^\s*(.*)/) ;
      }
## Fin de boucle if sur le subckt
    } else { # On est alors dans du body de netlist
      push @netlist_fullbody , $_; # Ici le body est à modifier, il prends tous les sauts de ligne, commentaires ...
      push @netlist_body , $_ if !/(^\*)|(^\s*$)|(^\.global)|(^\.probe\s+v)|(^\.end)/i; # On push le body si ce n'est pas un commentaire et s'il n'y a pas les commands spécifiées parfois par cadence
      push @netlist_comment , $_ if /^\*/;
    }
  } # Fin de boucle sur le fichier
## Traitements supplémentaires sur les subckt : analyse des dépendaces / autres subckt 
  foreach $sckt_name (keys %subckt) { ## foreach sur tous les subckt
    $instance = -1; ## On commence à -1 pour remplir le tableau à partir de 0 et ne pas avoir de problèmes ...
    print "\t-->Analysis of $sckt_name subckt :\n";
    foreach (@{$subckt{$sckt_name}{body}}) {
      if (/^\s*([cdegijklmpqrstuvwxy]|fns|fnz)([\w<>]+)(?:\s+)?(.*)?/i) { ## Si on trouve une nouvelle définition d'instance, RAZ, incrément de $instance
        @arglist = () ;
        $instance++;
        given ($1) { # Ici, à compléter pour le type d'instance
          when (/c/i) {$instance_type = 'Capacitance';}
          when (/d/i) {$instance_type = 'Diode';}
          when (/fns/i) {$instance_type = 'Eldo S-domain filter';}
          when (/fnz/i) {$instance_type = 'Eldo Z-domain filter';}
          when (/i/i) {$instance_type = 'Current Source';}
          when (/j/i) {$instance_type = 'JFET Transistor';}
          when (/k/i) {$instance_type = 'Coupled Inductor';}
          when (/l/i) {$instance_type = 'Inductor';}
          when (/m/i) {$instance_type = 'MOS Transistor';}
          when (/p/i) {$instance_type = 'Diffusion/Semiconductor Resistor';}
          when (/q/i) {$instance_type = 'Bipolar Transistor';}
          when (/r/i) {$instance_type = 'Resistor';}
          when (/t/i) {$instance_type = 'Transmission Line';}
          when (/v/i) {$instance_type = 'Voltage Source';}
          when (/x/i) {$instance_type = 'Subckt';}
          when (/u/i) {$instance_type = 'Transmission Line';}
          when (/w/i) {$instance_type = 'Transmission Line';}
          when (/y/i) {$instance_type = 'Specific Devices/Transmission Line';}
        }
        $instance_name = $1.$2;
        print "\tInstance n°$instance : name : $instance_name type : $instance_type\n" ;
        ${$subckt{$sckt_name}{instance}}[$instance] = ( {$instance_name => {"type" => $instance_type , "position" => $instance , "arg" => []} } ) ;
        push @{$subckt{$sckt_name}{instance}[$instance]{$instance_name}{arg}} , (split /\s+/, $3) if ($3) ; 
      } elsif (/^\s*\+\s*(.*)/) { # Si la ligne commence par un + : la déclaration de l'instance continue
        push @{$subckt{$sckt_name}{instance}[$instance]{$instance_name}{arg}} , (split /\s+/, $1) ;
      } else { next } # Ici, prendre en compte les commentaires, les lignes vides ?
    }
## Analyse/traitement des dépendances ;
    $instance = -1 ;
    print "\t\t-->Dependency analysis\n";
    foreach (@{$subckt{$sckt_name}{instance}}) { ## $_ dans cette boucle est la référence des hash. C'est par construction avec les push plus haut
      print "\n\t-->Problem encoutered during subckt scan : multiple declaration ; check netlist or programmer ...\n" and exit if (scalar(keys $_)>1) ; ## vérification clé unique dans le tableau
      ($key) = keys $_; ## normalement, clé unique
      #print Dumper $_ and getc ;
      #print Dumper $_->{$key}{arg} and getc ;
      #print "tableau : @{$_->{$key}{arg}}" and getc;
      my @dep = grep {$subckt{$_}} @{$_->{$key}{arg}} ; ## @{} est le tableau dont la référence est entre {}. $_-> est la référence vers un hash un peu plus profond
      if ( !@dep == 0 ) {
        $instance++;
        foreach my $dep (@dep) {
          print "\t\t\t-->Found declared instance $key in $sckt_name ; subckt name : $dep\n" ;
          ${$subckt{$sckt_name}{dependency}}[$instance] = ( {$key => {"sckt_ref" => $dep ,  "pinlist" => [] , "arglist" => []}} ) ;
          push @{$subckt{$sckt_name}{dependency}[$instance]{$key}{pinlist}} , grep (/^[\w<>\[\]]+$/ ,( grep {!$subckt{$_}} @{$_->{$key}{arg}} ) )  ;
          push @{$subckt{$sckt_name}{dependency}[$instance]{$key}{arglist}} , grep (/\w+=\w+/ ,( grep {!$subckt{$_}} @{$_->{$key}{arg}} ) )  ;
        }
      }
    }
#Ici, il faudrait aussi faire la même chose sur le netlist_body
#Au final, on veut extraire la hierarchie des instances
    print "\n";
  } ## end foreach sur tous les subckt
#Debug
  #print Dumper \%subckt ;
  print ("Ending netlist file scan phase.\n");
  print "$term_sep\n\n";
} # end scan_netlist

sub make_eldofile {
  print "$term_sep\n";
  print ("Eldo file creation : workpath : $path\ncarac.inc ==> carac ...\n");
  close ($caracFH);
  open ($caracFH, "<$caracfile") or die ("open : $!");
  while (<$caracFH>) {

## On supprime l'éventuelle dernière ligne commençant par .end
    next if /^\.end$/i ; 

#Traitement des définition de domaines de tension
    if (/^\.param\s+vddgo1\s*=\s*($numberspice)\s+vddgo2\s*=\s*($numberspice)\s+vddio\s*=\s*($numberspice)/i) {
      print "\tFound voltage domain definition line $. : vddgo1 : $1 ; vddgo2 : $2 ; vddio : $3\n" if ($verbose == 1 );
      if (!@voltage || scalar(@voltage) > 1) {
        print "\tNo voltage argument specified or step required, voltage definition unmodified\n" if ($verbose == 1 ) ;
        print ( $eldoFH $_) ; 
      } elsif ( scalar(@voltage) == 1 ) { ## Corner unique => modification du .param
        print "\tNew voltage domain definition : vddgo1 : ${$voltage_def{$voltage[0]}}[0] ; vddgo2 : ${$voltage_def{$voltage[0]}}[1] ; vddio : ${$voltage_def{$voltage[0]}}[2]\n" if ($verbose == 1 ) ;
        print ( $eldoFH "\.param vddgo1=${$voltage_def{$voltage[0]}}[0] vddgo2=${$voltage_def{$voltage[0]}}[1] vddio=${$voltage_def{$voltage[0]}}[2]\n") ;
      }

#Traitement des définition de température
    } elsif (/^\.param\s+tval=\s*($numberspice)/i) {
      print "\tFound temperature definition line $. : temp : $1\n" if ($verbose == 1 );
      if (!@temp || scalar(@temp) > 1) {
        print "\tNo temperature argument specified or step required, temperature definition unmodified\n" if ($verbose == 1 ) ;
        print ( $eldoFH $_) ;
      }
      if ( scalar(@temp) == 1 ) { ## Corner unique => modification du .param
        print "\tNew temperature definition : temp : $temp[0]\n" if ( scalar(@temp) == 1 && $verbose == 1 );
        print ( $eldoFH "\.param tval=$temp[0]\n") ;
      }

#Traitement des include librairie techno, corner, etc ...
    } elsif (/^\.lib\s+include\.inc\s+(\w+)/i) {
    #} elsif (/^\.lib\s+include\.inc/i) {
      print "\tFound model definition line $. : $1\n" if ($verbose == 1 );
#Aucun corner spécifié, pas de mc :  simulation avec librairies définies dans le fichier carac.inc => on laisse inchangé
#Sinon, on ne recopie rien, écriture à la fin du fichier
      print ( $eldoFH $_ ) if ( !@process && !@mc ) ;
      next;

#Traitement des step param
    } elsif ( /^\.step\s+param\s+(\w+)\s+(incr|dec|oct|lin|list|file)/i) { #Détection .step sur un paramètre unique
      print "\tParameter step found line $. ; Single param : $1 ; Incr_spec : $2 ;\n" if ($verbose == 1 );
      print "\tUser defined step on this parameter ; This step will be removed from carac file\n" and next if (exists $step_param{$1});
      print "\tUser pvt command and step parameter on voltage/temperature. Priority on pvt => step removed from carac file\n" and next if ( ($1 =~ /vddgo1|vddgo2|vddio|tval/) && @pvt ) ; 
      print ( $eldoFH $_ ) and next; 
    } elsif ( /^\.step\s+param\s+\(([\w+\s+]+)\)\s+(incr|dec|oct|lin|list|file)/i ) { #Détection .step sur des paramètres multiples
      print "\tParameter step found line $. ; Multi param : $1 ; Incr_spec : $2 ;\n" if ($verbose == 1 );
      push @step , split / /,$1;
      my $grep = grep { exists $step_param{$_} } @step; ## test d'existance du step en commande
      print "\tUser defined step on this parameter ; This step will be removed from carac file\n" and next if ( $grep>0 );
      print "\tUser pvt command and step parameter on voltage/temperature. Priority on pvt => step removed from carac file\n" and next if ( ($1 =~ /vddgo1|vddgo2|vddio|tval/) && @pvt ) ; 
      print ( $eldoFH $_ ) and next;

#Traitement des simulations Monte Carlo
    } elsif (/^\.mc/i) {
      print "\tFound mc simulation command line $. : $_" if ($verbose == 1 );
#Aucun mc défini en argument => on laisse inchangé
#Sinon, on ne recopie rien, écriture à la fin du fichier
      if ( !exists $mc{'mc'} ) {
        print ( $eldoFH $_ ) ;
        print "\tNo Monte-Carlo argument => .mc command unchanged\n" if ($verbose == 1) ;
        } else {
          print "\tUser Monte-Carlo input argument specified => .mc command deleted\n" if ($verbose == 1 );
          next; }

#Traitement des appels de testbenches
    } elsif (/^\.(\w+).*/i) {
      my $t = $1;
      #$t =~ tr/A-Z/a-z/;
      if ( exists $tbenchlist{$t} ) {
        print "\tFound $1 testbench call line $.\n" if ($verbose == 1 ) ; 
        if ( !@testbench ) {
          print "\tNo testbench input argument => testbanch call unchanged\n" if ($verbose == 1) ;
          print ($eldoFH $_); }
          else {
            print "\tUser testbench input argument specified => testbench call deleted\n" if ($verbose == 1 ); }
        } else { print ( $eldoFH $_ ) ; } #La ligne commence par .qqchose, qqchose n'est pas un testbench, on recopie
    }

#Sinon on copie
      else { print ( $eldoFH $_) ; }
  }

#Fin du parcours de CARACFILE, on place à la fin les corners , testbench calls et les steps si besoin est 

#Ecriture des appels de testbenches
  if (@testbench && scalar(@testbench) >= 1 ) {
    print ($eldoFH "$eldo_sep\n\*\*\*\* Testbench call by perl script\n$eldo_sep\n");
    foreach (@testbench) {
      print ($eldoFH ".$_\n");
    }
    print ($eldoFH "\n");
  }

#Ecriture du step en tension
  if (scalar(@voltage) > 1 ) {
    print ($eldoFH "$eldo_sep\n\*\*\*\* Voltage step by perl script\n$eldo_sep\n");
    print ($eldoFH "\.step param (vddgo1 vddgo2 vddio) list");
    foreach (@voltage) {
      print ($eldoFH " (@{$voltage_def{$_}})");
    }
    print ($eldoFH "\n\n");
  }

#Ecriture du step en température
  if (scalar(@temp) > 1 ) {
    print ($eldoFH "$eldo_sep\n\*\*\*\* Temp step by perl script\n$eldo_sep\n");
    print ($eldoFH "\.step param tval list @temp\n\n");
  }

#Ecriture de la commande Monte Carlo
  if ( exists $mc{'mc'} ) {
    print ($eldoFH "$eldo_sep\n\*\*\*\* Monte Carlo by perl script\n$eldo_sep\n");
    print ($eldoFH "\.mc $mc{'nbruns'} nbbins=$mc{'nbbins'} vary=$mc{'mc'}\n\n");
    print ($eldoFH ".lib include.inc common\n\n"); # Ici, vérifier que c'est nécessaire niveau ELDO
    print ($eldoFH ".lib include.inc mc\n\n");
  }

#Ecriture de la liste des corners dans le cas de corners multiples : .alter nécessaire
  if (scalar(@corner_mos) >= 1 || scalar (@corner_bip) >= 1 || scalar (@corner_res) >= 1 || scalar(@corner_cap) >= 1) {
    push @corner_mos,"mostyp" if scalar(@corner_mos) == 0;
    push @corner_bip,"btyp" if scalar(@corner_bip) == 0;
    push @corner_res,"rtyp" if scalar(@corner_res) == 0;
    push @corner_cap,"ctyp" if scalar(@corner_cap) == 0;
    print ($eldoFH "$eldo_sep\n\*\*\*\* Corner modification by perl script\n$eldo_sep\n");
    foreach my $arg_mos (@corner_mos) {
      foreach my $arg_bip (@corner_bip) {
        foreach my $arg_res (@corner_res) {
          foreach my $arg_cap (@corner_cap) {
            print ($eldoFH ".alter ") and print ($eldoFH join ('_', ($arg_mos,$arg_bip,$arg_res,$arg_cap)) ) and print ($eldoFH "\n\n") if ( scalar(@process) > 1 ) ;
            print ($eldoFH ".lib include.inc common\n");
            print ($eldoFH ".lib include.inc $arg_mos\n");
            print ($eldoFH ".lib include.inc $arg_bip\n");
            print ($eldoFH ".lib include.inc $arg_res\n");
            print ($eldoFH ".lib include.inc $arg_cap\n");
            print ($eldoFH "\n"); }}}}}

#Dernière étape, écriture de .end
  print ($eldoFH ".end\n");
  print ("Eldo file creation done.\n");
  print "$term_sep\n\n";
} #end make_eldofile

sub make_netlistfile {
  print "$term_sep\n";
  print ("Netlist file generation...\n");
  if ( !(-f $netlistfile) ) {system ( "touch" , $path."netlist.cir") ;}
  open ($netlistFH, ">$netlistfile") or die ("open : $!");
  print ( $netlistFH "$eldo_sep\n**** Subcircuit definition\n$eldo_sep\n\n");
  foreach $sckt_name ( sort { $subckt{$a}{subckt_pos} <=> $subckt{$b}{subckt_pos} } keys %subckt ) {
    print ( $netlistFH ".subckt $sckt_name\n");
    print ( $netlistFH "+ ! Pin List\n");
    if ( exists $subckt{$sckt_name}{pinlist} ) { ## Ecriture des pins
      @arglist = ();
      foreach ( sort { $a <=> $b } keys %{$subckt{$sckt_name}{pinlist}} ) {
        if ( $subckt{$sckt_name}{pinlist}{$_}{type} eq "alim" || $subckt{$sckt_name}{pinlist}{$_}{type} eq "custom") {
          push @arglist, $subckt{$sckt_name}{pinlist}{$_}{name} ;
        } else {
          push @arglist, $subckt{$sckt_name}{pinlist}{$_}{name} ;
        }
      }
      print ( $netlistFH wrap($initial_tab, $other_tab, @arglist));
      print ( $netlistFH "\n"); }
    print ( $netlistFH "+ ! Param List\n");
    if ( exists $subckt{$sckt_name}{paramlist} ) {
      @arglist = ();
      foreach ( sort { $a <=> $b } keys %{$subckt{$sckt_name}{paramlist}} ) {
        push @arglist, $subckt{$sckt_name}{paramlist}{$_}{name}."=".$subckt{$sckt_name}{paramlist}{$_}{basevalue}; }
      print ( $netlistFH wrap($initial_tab, $other_tab, @arglist));
      print ( $netlistFH "\n"); }
    print ( $netlistFH "+ ! Comments\n");
    if ( exists $subckt{$sckt_name}{arg_comments} ) {
      print ( $netlistFH wrap($comment_tab, $comment_tab, @{$subckt{$sckt_name}{arg_comments}})); print ($netlistFH "\n"); }
    print ( $netlistFH "\n");
    foreach (@{$subckt{$sckt_name}{allbody}}) {
      print ( $netlistFH wrap($no_tab, $other_tab, $_)); }
    print ( $netlistFH "\n");
    print ( $netlistFH ".ends \n\n");
  }
  print ( $netlistFH "$eldo_sep\n**** Main netlist section\n$eldo_sep\n\n");
  foreach (@netlist_body) { print ( $netlistFH $_ ) ; } 
  print ("Ending netlist file generation.\n");
  print "$term_sep\n\n";
} #end make_netlistfile

sub check {
  print ("Check phase : Check simulation files...\n");
  print ("Ending check phase.\n");
}

sub f_help() {
  print "$term_sep\n";
  print ("Usage fonction sim_eldo : sim_eldo [args]\n");
  print "$term_sep\n";
  print ("Arguments  :\n\n");
  print ("  -help    : Help command display\n\n");
  print ("  -verbose : Debug purpose\n\n");
  print ("  -init    : Generation of simulation files\n\n");
  print ("  -check   : Check simulation files\n\n"); #?
  print ("  -scan    : netlist & carac file scan\n\n");
  print ("  -bkp     : simu avec sauvegarde du fichier carac -> carac.bkp\n\n");# ?
  f_gen_help();
  f_process_help();
  f_voltage_help();
  f_temp_help();
  f_pvt_help();
  f_mc_help();
  f_param_help();
  f_tbench_help();
  exit(1);
}

sub f_gen_help() {
  print ("  -gen     : Behavioral model generation from netlist\n");
  print ("     usage : gen=vhdl,veri\n");
  print ("             single or multiple choice\n\n");}

sub f_process_help() {
  print ("  -process : Active and passive device model selection\n");
  print ("     usage : process=mostyp/mosfs/mossf/mosss/mosff/btyp/bmin/bmax/rtyp/rmin/rmax/ctyp/cmin/cmax\n");
  print ("             single choice or process=typ,fs,sf ...\n\n");}

sub f_voltage_help() {
  print ("  -voltage : Voltage domain selection\n");
  print ("     usage : voltage=vnom/vmin/vmax/v1min/v1max/v2min/v2max\n");
  print ("             single choice or voltage=vnom,vmin,v2max ...\n\n");}

sub f_temp_help() {
  print ("  -temp    : Temperature selection\n");
  print ("     usage : temp=25/<decimal>\n");
  print ("             single choice or temp=0,25,50\n\n");}

sub f_pvt_help() {
  print ("  -pvt     : routine Process Voltage Temperature\n");
  print ("     usage : pvt=p/v/t ... single or multiple choice\n\n");}

sub f_mc_help() {
  print ("  -mc      : Monte-Carlo Simulation\n");
  print ("     usage : mc=lot/dev/devx,nbruns,nbbins\n\n");}

sub f_param_help() {
  print ("  -param   : Internal parameter selection. Must be defined in carac.inc file\n");
  print ("     usage : param=param_name,incr_spec,arg1,arg2,arg3,...\n");
  print ("           : param=(param_name1 param_name2, ...),incr_spec,(arg11 arg21 ...),(arg12 arg22 ...),...\n");
  print ("           : param=param_name,file,filename\n\n");}

sub f_tbench_help() {
  print ("  -tbench : Testbench selection. Must be defined in carac.inc file\n");
  print ("    usage : tbench=tbench1,tbench2 ... single or multiple\n\n");}

################################################################################
#Récupération des paramètres en argument de la fonction
################################################################################
GetOptions(
  "verbose!" => \$verbose,
  "help!" => \$help,
  "scan!" => \$scan,
  "init!" => \$init,
  "gen=s" => \@gen,
  "process=s" => \@process,
  "voltage=s" => \@voltage,
  "temp=s" => \@temp,
  "pvt=s" => \@pvt,
  "mc=s" => \@mc,
  "param=s" => \@param,
  "tbench=s" => \@testbench);

f_help() if ( $help == 1 );
init() and exit(1) if ( $init == 1 );

filehandle();
scan_carac();
scan_netlist($netlistFH);
exit(1) if ($scan == 1);

print "$term_sep\n";

print "Beginning processing input arguments...\n";

if (@gen) {
  @gen =  split /,/, join (',', @gen );
  map {tr/A-Z/a-z/} @gen;
  @gen = doublons_grep(\@gen);
  @gen = grep ( /vhdl|veri/i , @gen);
  if ( @gen == 0  ) {
  print "\tSyntax error on gen argument \n\n" ;
  f_gen_help() and exit ; }
  print "\tTable \@gen : @gen\n" if ($verbose == 1 );
  foreach (@gen) {gen_model($_)}
  exit 1;
}

if (@process) {
  @process =  split /,/, join (',', @process );
  map {tr/A-Z/a-z/} @process;
  @process = doublons_grep(\@process);
  @corner_mos = grep ( /mostyp|mosff|mosss|mosfs|mossf/i , @process);
  @corner_bip = grep ( /btyp|bmin|bmax/i , @process);
  @corner_res = grep ( /rtyp|rmin|rmax/i , @process);
  @corner_cap = grep ( /ctyp|cmin|cmax/i , @process);
  if ( @corner_mos == 0 && @corner_bip == 0 && @corner_res == 0 && @corner_cap == 0 ) {
  print "\tSyntax error on process argument \n\n" ;
  f_process_help() and exit ; }
  print "\tTable \@process : @process\n" if ($verbose == 1 );
  print ("\tTable \@corner_mos : @corner_mos\n\tTable \@corner_bip : @corner_bip\n\tTable \@corner_res : @corner_res\n\tTable \@corner_cap : @corner_cap\n") if ($verbose == 1 );
}

if (@voltage) {
  @voltage = split /,/, join (',',@voltage);
  map {tr/A-Z/a-z/} @voltage;
  @voltage = doublons_grep(\@voltage);
  @voltage = grep ( /vnom|vmin|vmax|v1min|v1max|v2min|v2max/i , @voltage);
  if ( @voltage == 0 ) {
  print "\tSyntax error on voltage argument \n\n" ;
  f_voltage_help() and exit ; }
  print ("\tTable \@voltage : @voltage\n") if ($verbose == 1 );
}

if (@temp) {
  @temp = split /,/, join (',',@temp);
  @temp = doublons_grep(\@temp);
  @temp = grep ( /[+-]?\d+\.?\d*/ , @temp);
  if ( @temp == 0 ) {
  print "\tSyntax error on temp argument \n\n" ;
  f_temp_help() and exit ; }
  print ("\tTable \@temp : @temp\n") if ($verbose == 1 );
}

if (@pvt) { 
  @pvt = split /,/, join (',',@pvt);
  map {tr/A-Z/a-z/} @pvt;
  @pvt = doublons_grep(\@pvt);
  @pvt = grep ( /p|v|t/i , @pvt);
  if ( @pvt == 0 ) {
  print "\tSyntax error on pvt argument \n\n" ;
  f_pvt_help() and exit ; }
  print ("\tTable \@pvt : @pvt\n") if ($verbose == 1 );
  print ("\tProcess / Voltage / Temp and pvt defined ...\n\tPriority on pvt. Individual Process / Voltage / Temp ignored.\n") if ( (@process || @voltage || @temp) && @pvt);
  foreach (@pvt) {
    if (/p/) {
    @process = qw(typ ff ss fs sf btyp bmin bmax rtyp rmin rmax ctyp cmin cmax);
    @corner_mos = qw(mostyp mosff mosss mosfs mossf);
    @corner_bip = qw(btyp bmin bmax);
    @corner_res = qw(rtyp rmin rmax);
    @corner_cap = qw(ctyp cmin cmax);
    } elsif (/v/) {
    print ("\tTable \@corner_mos : @corner_mos\n\tTable \@corner_bip : @corner_bip\n\tTable \@corner_res : @corner_res\n\tTable \@corner_cap : @corner_cap\n") if ($verbose == 1 );
    @voltage = qw(vmin vnom vmax);
    print ("\tTable \@voltage : @voltage\n") if ($verbose == 1 );
    } elsif (/t/) {
    @temp = qw(0 25 50);
    print ("\tTable \@temp : @temp\n") if ($verbose == 1 );
    }
  }
}

if (@mc) {
  map {tr/A-Z/a-z/} @mc;
  $mc = join (',',@mc);
  print ("\tProcess / Voltage / Temp or pvt and Monte Carlo defined ...\n\tPriority on Monte Carlo. Individual Process / Voltage / Temp /PVT ignored.\n") if ( (@process || @voltage || @temp || @pvt) && @mc);
  @corner_mos = () ;
  @corner_bip = () ;
  @corner_res = () ;
  @corner_cap = () ;
  @voltage = () ;
  @temp = () ;
  if ( $mc =~ /(lot|dev|devx),(\d+),(\d+)/ ) {
    $mc{'mc'} = $1 and $mc{'nbruns'}=$2 and $mc{'nbbins'}=$3 ;
    print ("\tTable \@mc : @mc\n") if ($verbose == 1 ); }
    else { print "\tSyntax error on pvt argument \n\n" and f_mc_help() and exit ; }
}

if (@param) {
  map {tr/A-Z/a-z/} @param;
  $step_param = join (',',@param);
  if ( $step_param =~ /(\w+),(incr|dec|oct|lin|list|file),([\w+\.?\w*,]+)/ ) {#Détection .step sur un paramètre unique
    $step_param{$1}{'incr_spec'}=$2;
    @step_param=split/ /,$1;
    @{$step_param{$1}{'arg'}}=split(/,/,$3);
    print ("\tTable \@param : @param\n") if ($verbose == 1 ); 
    } elsif ( $step_param =~ /\(([\w+\s+]+)\),(incr|dec|oct|lin|list|file),((:?(.*),)+)/ ) { #Détection .step sur des paramètres multiples
    $step_param{$1}{'incr_spec'}=$2;
    @step_param=split/ /,$1;
    @{$step_param{$1}{'arg'}}=split(/,/,$3);
    } else { print "\tSyntax error on param argument \n\n" and f_param_help() and exit ;
  }
  foreach (@step_param) {if (!exists($paramlist{$_})) {print "Parameter $_ not defined in carac.inc file\n" and f_param_help() and exit; } }
}

if (@testbench) { # A voir, problème de case sensitive sur eldo ou le script
  @testbench = split /,/, join (',',@testbench);
  #map {tr/A-Z/a-z/} @testbench;
  @testbench = doublons_grep(\@testbench);
  foreach (@testbench) { if (!exists( $tbenchlist{$_} )) { print "Syntax error on testbench argument or testbench not defined in carac file\n" and f_tbench_help() and exit ; } }
  print ("\tTable \@testbench : @testbench\n") if ($verbose == 1 );
}
print "Processing input arguments done.\n";
print "$term_sep\n\n";

################################################################################
#Main function start
################################################################################

make_eldofile();

close ( $netlistFH ) ;
close ( $caracFH ) ;
close ( $eldoFH ) ;


