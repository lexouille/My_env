#!/usr/bin/perl -w

use strict;
use warnings;
use feature qw/switch/; #Pour given ... when
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Text::Wrap;
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
#print Dumper \%voltage_def;
#print Dumper \%temp_def;
my $eldo_sep="\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*";
my $term_sep='################################################################################';

my ($verbose,$help,$scan,$init)=(0,0,0,0);
my (@process,@voltage,@temp,@pvt,@mc,@param,@testbench);
my (@corner_mos,@corner_bip,@corner_res,@corner_cap);
my (@paramlist,%paramlist,%tbenchlist);
my ($mc,$step_param,@step,@step_param);

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

my $number=qr/[+-]?\d+(?:\.\d)?(?:meg|[afgnmpu])*/; #A compléter avec les exposants
#syn match s_number  "\<[0-9]\+\.[0-9]*\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="
#"floating point number, starting with a dot, optional exponent
#syn match s_number  "\.[0-9]\+\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="
#"integer number with optional exponent
#syn match s_number  "\<[0-9]\+\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="

################################################################################
# Gestion des fichiers d'entrée sortie
################################################################################
# Définition du path de travail. Une fois le script complet, pwd
my $path="/home/wiking/test/";

opendir (PATH, $path) or die $!;

my $caracfile = $path . "carac.inc";
my $netlistfile = $path . "netlist.cir";
my $eldofile = $path . "carac";
my $basenetlistfile ;

my ($netlistFH,$caracFH,$eldoFH,$basenetlistFH);

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
## Fonction suppression des doublons dans un tableau
## usage : @tableau_sans_doublons = doublons_grep (\@tableau_avec_doublons?);
  my ($ref_tabeau) = @_;
  my %hash_sans_doublon;
  return grep { !$hash_sans_doublon{$_}++ } @{$ref_tabeau};
}

sub stdin_answer {
## Fonction "Je te pose une question" avec un range de réponses
## Usage réponse_de_retour = stdin_answer ('Question', @liste_de_réponses_possible);
  my @in = @_ ; 
  my $question = shift @in ;
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
}

sub init {
  print "$term_sep\n";
  print ("Initialization phase : Generation of simulation files...\n");
  print "\nFile and Directory list found :\n";
  my %file = ();
  my @file = readdir PATH;
  $index=0;
  foreach (@file) {
    $index++;
    $file{$_}=$index;
    print "\n\t$index --> $_";
    print "\t-- .cir file found" if /\.cir$/; 
    print "\t-- .inc file found" if /\.inc$/; }
  print "\n";
  #print Dumper \%file if ($verbose == 1 ); 
  my @cirfile = grep /\.cir$/, @file;
  my @incfile = grep /\.inc$/, @file;
  if ($file{'netlist.cir'}) {
    $choice = stdin_answer ('netlist.cir file detected. Do you want to overwrite it ?','yes','no');
    if ($choice eq 'yes') {
      system ( "rm" , $path."netlist.cir") ;
      opendir (PATH, $path) or die $!;
      %file = ();
      @file = readdir PATH;
      $index=0;
      foreach (@file) {
        $index++;
        $file{$_}=$index;
        print "\n\t$index --> $_"; }
      print "\n";
      $choice = stdin_answer ('Select file to use for generation of netlist.cir',@file);
      $basenetlistfile = $path.$choice ;
      print $basenetlistfile and getc;
      open ($basenetlistFH, "<$basenetlistfile") or die ("open : $!");
      scan_netlist($basenetlistFH); 
      make_netlistfile();
      } elsif ($choice eq 'no') {
      $choice = stdin_answer ("Do you want to :\n 1-->make a backup copy of netlist.cir and regenerate it from another file ?\n 2-->keep netlist.cir as is ?",1,2) ;
        if ( $choice == 1 ) { # Backup et régén
          system ( "cp", $path."netlist.cir", $path."netlist_bkp".$date.".cir");
          opendir (PATH, $path) or die $!;
          %file = ();
          @file = readdir PATH;
          $index=0;
          foreach (@file) {
            $index++;
            $file{$_}=$index;
            print "\n\t$index --> $_"; }
          print "\n";
          $choice = stdin_answer ('Select file to use for generation of netlist.cir',@file);
          $basenetlistfile = $path.$choice ;
          open ($basenetlistFH, "<$basenetlistfile") or die ("open : $!");
          scan_netlist($basenetlistFH); 
          make_netlistfile();
        } elsif ( $choice == 2 ) {
          $basenetlistfile = $path."netlist.cir" ;
          open ($basenetlistFH, "<$basenetlistfile") or die ("open : $!");
          scan_netlist($basenetlistFH); 
          }
      }
    } else { # Si le fichier netlist.cir n'existe pas : création à partir d'un fichier au choix
      $choice = stdin_answer ('Select file to use for generation of netlist.cir',@file) ;
      $basenetlistfile = $path.$choice ;
      open ($basenetlistFH, "<$basenetlistfile") or die ("open : $!");
      scan_netlist($basenetlistFH); 
      make_netlistfile();
    }
## Test existance carac et carac.inc, overwrite éventuel
  if ($file{'carac.inc'}) {
    $choice = stdin_answer ('carac.inc file exists. Overvrite it ?','yes','no') ;
    system ( "cp", "./carac_template.inc", $path."carac.inc") if ($choice eq 'yes');
  } else {
    print "Generation of carac.inc file from template\n";
    system ( "cp", "./carac_template.inc", $path."carac.inc");
  }
  if ($file{'carac'}) {
    $choice = stdin_answer ('carac file exists. Overvrite it ?','yes','no') ;
    system ( "cp", "./carac_template.inc", $path."carac") if ($choice eq 'yes');
  } else {
    print "Generation of carac.inc file from template\n";
    system ( "cp", "./carac_template.inc", $path."carac");
  }
  print ("Ending initialization phase.\n");
  print "$term_sep\n\n";
}

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
      foreach (keys %split) { push @paramlist , ($_,$split{$_}) ; print "\tParameter definition line $. ; name : $_ ; Default value $split{$_}\n" if ($verbose == 1 ) ; }
    } elsif ( /^\.define_testbench\s+(\w+)/i ) {
      print "\tTestbench definition found line $. ; name : $1\n" if ($verbose == 1 );
      my $t = $1;
      $t =~ tr/A-Z/a-z/;
      ++$tbenchlist{$t};
    } elsif ( /^\.lib include\.inc\s+(\w+)/i) {
      print "\tModel definition found line $. ; name : $1\n" if ($verbose == 1 );
    } elsif ( /^\.step\s+param\s+(\w+)\s+(incr|dec|oct|lin|list|file)[\s+|\s*=\s*]([\w+\.?\w* +]+)/i) { #Détection .step sur un paramètre unique
      $step{$1}{'incr_spec'}=$2;
      @{$step{$1}{'arg'}}=split(/\s+/,$3);
      print "\tParameter step found line $. ; Single param : $1 ; Incr_spec : $step{$1}{'incr_spec'} ; Incr_arg : @{$step{$1}{'arg'}}\n" if ($verbose == 1 );
    } elsif ( /^\.step\s+param\s+\(([\w+\s+]+)\)\s+(incr|dec|oct|lin|list|file)[\s+|\s*=\s*]((:?(.*)\s+)+)/i ) { #Détection .step sur des paramètres multiples
      $step{$1}{'incr_spec'}=$2;
      @{$step{$1}{'arg'}}=split(/\s+/,$3);
      print "\tParameter step found line $. ; Multi param : $1 ; Incr_spec : $step{$1}{'incr_spec'} ; Incr_arg : @{$step{$1}{'arg'}}\n" if ($verbose == 1 );
    }
  }
  %paramlist=@paramlist;
  print Dumper \%paramlist if ($verbose == 1 ) ;
  #print Dumper \%tbenchlist if ($verbose == 1 ) ;
  print Dumper \%step if ( $verbose == 1 ) ;
  print ("Ending carac file scan phase.\n");
  print "$term_sep\n\n";
} # End scan_carac sub

sub scan_netlist {
  ($fh)=@_;
  print "$term_sep\n";
  print ("Scan phase : Netlist file scan...\n");
  while (<$fh>) {
    if (/^\.subckt\s+(.*)/i) {
## Detection structure commençant par .subckt. Increment de l'indice subckt, reset du tableau arglist et des autres tables
      $arglist=();
      @arglist=();
      $subckt_nr++;

## Affectation du nom du subckt, de sa position dans le fichier. On stocke la position dans la netlist de base
      @arglist = split( /\s+/, $1 ) ;
      $sckt_name = shift(@arglist) ; $arglist = join (" ",@arglist) if ( ! @arglist == 0) ; # On ne join que si la table arglist est non vide, cas correspondant à scktname seul sur la première ligne
      push @{$subckt{$sckt_name}{'argument'}}, $arglist if ($arglist) ;
      #print "@arglist\n$arglist\n";
      $subckt{$sckt_name}{'number'} = $subckt_nr;
      $subckt{$sckt_name}{'subckt_pos'}=$.;
## Debug
      print "  -->Found subckt definition ; Subckt number $subckt{$sckt_name}{'number'}\n" if ( $verbose ==1 ) ;
      print "\tName : $sckt_name\n" if ( $verbose ==1 ) ;
      print "\tLine position : $subckt{$sckt_name}{'subckt_pos'}\n" if ( $verbose ==1 ) ;
## Fin traitement première ligne de structure

## Traitement de la suite de la déclaration du subckt. While dans un autre while.
      while (<$fh>) {
        next if /^\s*$/ ; #Rien si ligne vide
        if (! /^\+/) { # Si ça n'a pas commencé par une ligne vide ou un + on sort de la déclaration du subckt et on commence à remplir/parcourir le body
          push @{$subckt{$sckt_name}{'allbody'}}, $_ ;
          push @{$subckt{$sckt_name}{'comment'}}, $_ if /^\*/ ;
          push @{$subckt{$sckt_name}{'body'}}, $_ ;
          last; 
        }
        next if /^\+ ! Pin List/i; # Saut de l'execution pour lignes spéciales
        next if /^\+ ! Param List/; # Saut de l'execution pour lignes spéciales
        next if /^\+ ! Comments/; # Saut de l'execution pour lignes spéciales
        push @{$subckt{$sckt_name}{'arg_comments'}}, $1 and next if (/^\+\s+!(.*)/);
        chomp $_;
        push @arglist , ( split /\s+/, $_ ) ;
        push @{$subckt{$sckt_name}{'argument'}}, $_ ;
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
  print "\tAnalysis of subckt declaration\n" if ($verbose == 1 );
  foreach (@arglist) {
    if ( /(\w+)=(\w+)/ ) {
      print "\tFound parameter definition ; name $1 ; basevalue : $2\n" if ($verbose == 1 );
      $param_index++;
      $subckt{$sckt_name}{'paramlist'}{$1}{'position'}=$param_index;
      $subckt{$sckt_name}{'paramlist'}{$1}{'basevalue'}=$2;
    } else {
      print "\tFound pin : $_\n" if ($verbose == 1 );
      $pin_index++;
      $subckt{$sckt_name}{'pinlist'}{$_}{'position'}=$pin_index;
    }
  }
  print "\tSubckt declaration summary ; $pin_index pins found ; $param_index parameters found\n" if ($verbose == 1 );
## Traitement du body du subckt
 print "\tEntering body of subckt\n" if ($verbose == 1 );
 while (<$fh>) {
        if (/^\.ends/i) {
          print "\tEnd of $sckt_name definition\n\n" if ($verbose == 1 ) ;
          last ;
        }# Test fin de subckt
## Ici à modifier, il ne prends pas les sauts de ligne dans le allbody et le body ne dois pas prendre les commentaires
        push @{$subckt{$sckt_name}{'allbody'}}, $_ ;
        next if /^\s*$/ ;
        push @{$subckt{$sckt_name}{'comment'}}, $_ if /^\*/ ;
        push @{$subckt{$sckt_name}{'body'}}, $_ ;
        }
## Fin de boucle if sur le subckt
      } else { # On est alors dans du body de netlist
        push @netlist_fullbody , $_; # Ici le body est à modifier, il prends tous les sauts de ligne, commentaires ...
        push @netlist_body , $_ if !/(^\*)|(^\s*$)/;
        push @netlist_comment , $_ if /^\*/;
      }
  } # Fin de boucle sur le fichier
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
    if (/^\.param\s+vddgo1\s*=\s*($number)\s+vddgo2\s*=\s*($number)\s+vddio\s*=\s*($number)/i) {
      print "\tFound voltage domain definition line $. : vddgo1 : $1 ; vddgo2 : $2 ; vddio : $3\n" if ($verbose == 1 );
      print "\tNo voltage argument specified or step required, voltage definition unmodified\n" and print ( $eldoFH $_) if ( (!@voltage || scalar(@voltage) > 1) && $verbose == 1 ) ;
      if ( scalar(@voltage) == 1 ) { ## Corner unique => modification du .param
        print "\tNew voltage domain definition : vddgo1 : ${$voltage_def{$voltage[0]}}[0] ; vddgo2 : ${$voltage_def{$voltage[0]}}[1] ; vddio : ${$voltage_def{$voltage[0]}}[2]\n" if ($verbose == 1 ) ;
        print ( $eldoFH "\.param vddgo1=${$voltage_def{$voltage[0]}}[0] vddgo2=${$voltage_def{$voltage[0]}}[1] vddio=${$voltage_def{$voltage[0]}}[2]\n") ;
      }

#Traitement des définition de température
    } elsif (/^\.param\s+tval=\s*($number)/i) {
      print "\tFound temperature definition line $. : temp : $1\n" if ($verbose == 1 );
      print "\tNo temperature argument specified or step required, temperature definition unmodified\n" and print ( $eldoFH $_) if ( (!@temp || scalar(@temp) > 1) && $verbose == 1 ) ;
      if ( scalar(@temp) == 1 ) { ## Corner unique => modification du .param
        print "\tNew temperature definition : temp : $temp[0]\n" if ( scalar(@temp) == 1 && $verbose == 1 );
        print ( $eldoFH "\.param tval=$temp[0]\n") ;
      }

#Traitement des include librairie techno, corner, etc ...
    } elsif (/^\.lib\s+include\.inc\s+(\w+)/i) {
    #} elsif (/^\.lib\s+include\.inc/i) {
      print "\tFound model definition line $. : $1\n" if ($verbose == 1 );
#Aucun corner spécifié :  simulation avec librairies définies dans le fichier carac.inc => on laisse inchangé
#Sinon, on ne recopie rien, écriture à la fin du fichier
      if ( !@process ) { print ( $eldoFH $_ ) } else { next; }

#Traitement des step param
    #} elsif ( /^\.step\s+param\s+(\w+)|\(([\w+\s+]+)\)\s+/i ) { # Ici, problème, il reconnait le multi param sur les alims alors que c'est commenté ? formule de base
    #} elsif ( /^\.step\s+param\s+(.*)/i ) { 
      #print "\tFound parameter step line $. : rest of line : $1\n" if ($verbose == 1 ) ;
      #Old version
      #print "\tFound parameter step line $. : single param : $1\n" if (defined $1 && $verbose == 1 );
      #@t = split /\s/,$2 and print "\tFound parameter step line $. : multi param : @t\n" if (defined $2 && $verbose == 1 );
    
    } elsif ( /^\.step\s+param\s+(\w+)\s+(incr|dec|oct|lin|list|file)/i) { #Détection .step sur un paramètre unique
      print "\tParameter step found line $. ; Single param : $1 ; Incr_spec : $2 ;\n" if ($verbose == 1 );
      print "\tUser defined step on this parameter ; This step will be removed from carac file\n" and next if (exists $step_param{$1});
      print ( $eldoFH $_ ) and next; 
    } elsif ( /^\.step\s+param\s+\(([\w+\s+]+)\)\s+(incr|dec|oct|lin|list|file)/i ) { #Détection .step sur des paramètres multiples
      print "\tParameter step found line $. ; Multi param : $1 ; Incr_spec : $2 ;\n" if ($verbose == 1 );
      push @step , split / /,$1;
      foreach (@step) { print "\tUser defined step on this parameter ; This step will be removed from carac file\n" and next if (exists $step_param{$_}); }
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
      $t =~ tr/A-Z/a-z/;
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

#Fin du parcours de CARACFILE, on place à la fin les corners et les steps si besoin est 

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
    print ($eldoFH ".include include.inc common\n\n"); # Ici, vérifier que c'est nécessaire niveau ELDO
    print ($eldoFH ".lib include.inc mc\n\n");
  }

#Ecriture de la liste des corners dans le cas de corners multiples : .alter nécessaire
  if (scalar(@corner_mos) >= 1 || scalar (@corner_bip) >= 1 || scalar (@corner_res) >= 1 || scalar(@corner_cap) >= 1) {
    push @corner_mos,"typ" if scalar(@corner_mos) == 0;
    push @corner_bip,"btyp" if scalar(@corner_bip) == 0;
    push @corner_res,"rtyp" if scalar(@corner_res) == 0;
    push @corner_cap,"ctyp" if scalar(@corner_cap) == 0;
    print ($eldoFH "$eldo_sep\n\*\*\*\* Corner modification by perl script\n$eldo_sep\n");
    print ($eldoFH ".lib include.inc common\n\n");
    foreach my $arg_mos (@corner_mos) {
      foreach my $arg_bip (@corner_bip) {
        foreach my $arg_res (@corner_res) {
          foreach my $arg_cap (@corner_cap) {
            print ($eldoFH ".alter ") and print ($eldoFH join ('_', ($arg_mos,$arg_bip,$arg_res,$arg_cap)) ) and print ($eldoFH "\n\n") if ( scalar(@process) > 1 ) ;
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
  foreach $sckt_name ( sort { $subckt{$a}{'subckt_pos'} <=> $subckt{$b}{'subckt_pos'} } keys %subckt ) {
    print ( $netlistFH ".subckt $sckt_name\n");
    print ( $netlistFH "+ ! Pin List\n");
    if ( exists $subckt{$sckt_name}{'pinlist'} ) {
      @arglist = ();
      foreach $arglist ( sort { $subckt{$sckt_name}{'pinlist'}{$a}{'position'} <=> $subckt{$sckt_name}{'pinlist'}{$b}{'position'} } keys %{$subckt{$sckt_name}{'pinlist'}} ) {
        push @arglist, $arglist; }
      print ( $netlistFH wrap($initial_tab, $other_tab, @arglist));
      print ( $netlistFH "\n"); }
    print ( $netlistFH "+ ! Param List\n");
    if ( exists $subckt{$sckt_name}{'paramlist'} ) {
      @arglist = ();
      foreach $arglist ( sort { $subckt{$sckt_name}{'paramlist'}{$a}{'position'} <=> $subckt{$sckt_name}{'paramlist'}{$b}{'position'} } keys %{$subckt{$sckt_name}{'paramlist'}} ) {
        push @arglist, $arglist."=".$subckt{$sckt_name}{'paramlist'}{$arglist}{'basevalue'}; }
      print ( $netlistFH wrap($initial_tab, $other_tab, @arglist));
      print ( $netlistFH "\n"); }
    print ( $netlistFH "+ ! Comments\n");
    if ( exists $subckt{$sckt_name}{'arg_comments'} ) {
      print ( $netlistFH wrap($comment_tab, $comment_tab, @{$subckt{$sckt_name}{'arg_comments'}})); print ($netlistFH "\n"); }
    print ( $netlistFH "\n");
    foreach (@{$subckt{$sckt_name}{'allbody'}}) {
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
  f_process_help();
  f_voltage_help();
  f_temp_help();
  f_pvt_help();
  f_mc_help();
  f_param_help();
  f_tbench_help();
  exit(1);
}

sub f_process_help() {
  print ("  -process : Active and passive device model selection\n");
  print ("     usage : process=typ/fs/sf/ss/ff/btyp/bmin/bmax/rtyp/rmin/rmax/ctyp/cmin/cmax\n");
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
  print ("     usage : pvt=PVT/PV1T/PV2T ... single or multiple choice\n\n");}

sub f_mc_help() {
  print ("  -mc      : Monte-Carlo Simulation\n");
  print ("     usage : mc=lot/dev/devx,nbruns,nbbins\n\n");}

sub f_param_help() {
  print ("  -param   : Internal parameter selection. Must be defined in carac.inc file\n");
  print ("     usage : param=param_name,incr_spec,arg1,arg2,arg3,...\n");
  print ("           : param=(param_name1 param_name2, ...),incr_spec,(arg11 arg21 ...),(arg12 arg22 ...),...\n");
  print ("           : param=param_name,file,filename\n\n");}

sub f_tbench_help() {
  print ("  -tbench : Testbench selection\n");
  print ("    usage : tbench=tbench1,tbench2 ... single or multiple\n\n");}

################################################################################
#Récupération des paramètres en argument de la fonction
################################################################################
GetOptions("verbose!" => \$verbose,"help!" => \$help,"scan!" => \$scan,"init!" => \$init,"process=s" => \@process,"voltage=s" => \@voltage,"temp=s" => \@temp,"pvt=s" => \@pvt,"mc=s" => \@mc,"param=s" => \@param,"testbench=s" => \@testbench);

f_help() if ( $help == 1 );
init() and exit(1) if ( $init == 1 );

filehandle();
scan_carac();
scan_netlist($netlistFH);
exit(1) if ($scan == 1);

## Suppression des doublons mapping des arguments dans tables / hashes
print "$term_sep\n";
print "Beginning processing input arguments...\n";
if (@process) {
  @process =  split /,/, join (',', @process );
  map {tr/A-Z/a-z/} @process;
  @process = doublons_grep(\@process);
  @corner_mos = grep ( /^typ|ff|ss|fs|sf/i , @process);
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
  @pvt = grep ( /pvt|p1vt|p2vt/i , @pvt);
  if ( @pvt == 0 ) {
  print "\tSyntax error on pvt argument \n\n" ;
  f_pvt_help() and exit ; }
  print ("\tTable \@pvt : @pvt\n") if ($verbose == 1 );
  print ("\tProcess / Voltage / Temp and pvt defined ...\n\tPriority on pvt. Individual Process / Voltage / Temp ignored.\n") if ( (@process || @voltage || @temp) && @pvt);
  @corner_mos = qw(typ ff ss fs sf);
  @corner_bip = qw(btyp bmin bmax);
  @corner_res = qw(rtyp rmin rmax);
  @corner_cap = qw(ctyp cmin cmax);
  print ("\tTable \@corner_mos : @corner_mos\n\tTable \@corner_bip : @corner_bip\n\tTable \@corner_res : @corner_res\n\tTable \@corner_cap : @corner_cap\n") if ($verbose == 1 );
  @voltage = qw(vmin vnom vmax);
  print ("\tTable \@voltage : @voltage\n") if ($verbose == 1 );
  @temp = qw(0 25 50);
  print ("\tTable \@temp : @temp\n") if ($verbose == 1 );
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

if (@testbench) {
  @testbench = split /,/, join (',',@testbench);
  map {tr/A-Z/a-z/} @testbench;
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



