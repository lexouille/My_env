#!/usr/bin/perl -w
# Script d'extraction des fichiers .op. Fonctionnel pour les transistors MOS
# Quelques problèmes, mais qui sont dus aux simulations ELDO, parfois il n'est pas possible de faire un step simultanné sur w et l,
# Il faut alors faire les sims avec l donné et faire une modif sur les .op

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
my ($o_verb, $o_help, $o_debug, $o_mod, $o_ext, $o_plot);
my $term_sep='################################################################################';
my $numberspice=qr/(?:[+-]?\d+(?:\.\d+)?(?:meg|[tgkmunpfa]|e[+-]?\d+)?)|(?:[+-]?\.\d+(?:meg|[tgkmunpfa]|e[+-]?\d+)?)/i;

my $outfile ;

my $index ; my $choice ;

my $path ;
my %file ; my @file ; my %h ; my %op ;
my $alter ; my $file ; my $device ; my %split ; my $param ; my $carac ;
my %minmax ;
my $name ;
my $model ; my $type ;
my %carac ; my $region ;
my $w ; my $l ; my $vgs ; my $vds ;
my $fh ; my $fhtmp ; 
my $ufile ;

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
    'm' => \$o_mod,  'mod'	=> \$o_mod,
    'e' => \$o_ext,  'ext'	=> \$o_ext,
    'p' => \$o_plot,  'plot'	=> \$o_plot,
  );
  help() and exit if(defined ($o_help)) ;
}

sub help() {
  print "$term_sep\n";
  print ("Usage fonction extract_op : extract_op [args]\n");
  print "$term_sep\n";
  print ("Arguments  :\n\n");
  print ("  -d, --debug   : Debug information (very verbose)\n\n");
  print ("  -h, --help    : Help command display\n\n");
  print ("  -v, --verbose : Debug purpose\n\n");
  print ("  -m, --mod     : Modification of .op file required\n\n");
  print ("  -e, --ext     : Extraction of devices parameter\n\n");
  print ("  -p, --plot    : Ploting of device parameter from database\n\n");
  exit;
}

sub printv { print @_ if (defined $o_verb || defined $o_debug) ; }
sub printd { print @_ if (defined $o_debug) ; }

sub stdin_answer {
## Fonction "Je te pose une question" avec un range de réponses ; réponse unique
## Usage réponse_de_retour = stdin_answer ('tr/nrt', 'Question', @liste_de_réponses_possible);
  my @in = @_ ; 
  my $tr = shift @in ; 
  my $question = shift @in ; map ( {tr/A-Z/a-z/} @in ) if ($tr eq "tr") ; ## Si case insensitive on lowercase toutes les réponses possibles
  my %answer;
  my $g_answer;
  print "\n$term_sep\n$question\n#### Possible answers :\n";
  foreach (@in) { $answer{$_}++ ; print "\t-->$_\n"; }
  $g_answer = <STDIN>; chomp $g_answer;
  $g_answer =~ tr/A-Z/a-z/ if ($tr eq "tr") ;
  while ( !exists ( $answer{$g_answer} ) ) {
    print "Wrong answer ; possible choices : \n"; foreach (@in) {print "$_\n";}
    print "$question\n";
    $g_answer = <STDIN>; chomp $g_answer;
  }
  return $g_answer;
} # End stdin_answer sub


sub ext_gen {
  # Structure générique adaptée à différents types de devices
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
      if (/^\("(X_\w+\.m\w+)"/i) { ## On trouve un device de type mos m\w+
        $name = $1;
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

  print Dumper \%h and print "Dumper %h hash\n" and getc if (defined $o_debug) ;

  foreach $file (keys %h) {
    foreach $device (keys %{$h{$file}{device}}) {
      foreach $param (keys %{$h{$file}{param}}) {
        $op{$device}{$file}{param}{$param} = $h{$file}{param}{$param} ;
        #$op{$device}{$file}{alter} = ("alter" => $h{$file}{"alter"}) ; ## ici, à finir
        foreach $carac (keys %{$h{$file}{device}{$device}{carac}}) {
          $op{$device}{$file}{carac}{$carac} = $h{$file}{device}{$device}{carac}{$carac} ;
        }
        $op{$device}{$file}{region} = $h{$file}{device}{$device}{region};
        $op{$device}{$file}{type} = $h{$file}{device}{$device}{type};
        $op{$device}{$file}{model} = $h{$file}{device}{$device}{model};
      }
    }
  }

  print Dumper \%op and print "Dumper %op hash\n" and getc if (defined $o_debug) ; 
  $device = (keys %op)[0] ; 
  $file = (keys %{$op{$device}})[0] ; 
  #print $device."\n".$file."\n" ;

  printf ($outfile "%-30s%-30s","MOS NAME","MOS MODEL");
  printf ($outfile "%-15s", "REGION");
  printf ($outfile "%-5s", "TYPE");
  printf ($outfile "%-15s", $_) foreach (keys %{$op{$device}{$file}{param}});
  printf ($outfile "%-15s", $_) foreach (grep (/v[gdb]s|i[gdsb]|vth|vdsat|gm|gds|@[gdsb]{2}|\@ron/i, keys %{$op{$device}{$file}{carac}}) );
  printf ($outfile "\n\n");

  foreach $device (keys %op) {
    foreach $file (sort {$a <=> $b} keys %{$op{$device}}) {
      printf ($outfile "%-30s%-30s", $device, $op{$device}{$file}{model});
      printf ($outfile "%-15s", $op{$device}{$file}{region} );
      printf ($outfile "%-5s", $op{$device}{$file}{type} );
      printf ($outfile "%-15s", $op{$device}{$file}{param}{$_}) foreach (keys %{$op{$device}{$file}{param}});
      printf ($outfile "%-15s", $op{$device}{$file}{carac}{$_}) foreach (grep (/v[gdb]s|i[gdsb]|vth|vdsat|gm|gds|@[gdsb]{2}|\@ron/i, keys %{$op{$device}{$file}{carac}}) );
      printf ($outfile "\n");
      #print $file."\n" ;
      #printf($outfile "%-18s","Run number $key");
    }
    printf ($outfile "\n");
  }

  close ($outfile) ;

} ## End og ext_gen function

sub ext_mosop {
  # Structure adaptée aux mos en particulier
  printv ("$term_sep\nProcessing .op files ...\n");
  foreach my $filepath ( keys %file ) {
    open ($fh, "<", "$filepath") or die ("Failed to open $filepath : $!");
    while (<$fh>) { ## while sur le fichier
      $alter = $1 if /alter\s*:\s*(\d+)/i ;
      #$h{$file{$filepath}}{alter}=$1 if /alter\s*:\s*(\d+)/i ;
      #$h{$file{$filepath}}{param}{$1}=$2 if /(temp)\s*:\s*($numberspice)/i ;# Ici, prendre en compte tval dabs les paramètres en dessous, il écrit tout le temps param temp alors qu'il peut être constant
      if ( /param\s*:((?:\s*\w+\s*=\s*$numberspice,?)+)/i ) {
        %split = split /[\s=,]+/,$1;
        #$h{$file{$filepath}}{param}{$_}=$split{$_} foreach (keys %split) ;
      }
      if (/^\("(X_\w+\.m\w+)"/i) { ## On trouve un device de type mos m\w+
        my $name = $1;
        while (<$fh>) { ## while sur le device
          $model=$1 if /^\("model"\s+"([\w.]+)\s*"\)/i ;
          $type=$1 if /^\("type\s*"\s+"([\w.]+)\s*"\)/i ;
          $carac{$1}{val}=$2 if ( /^\("\s*(id|gm|gds|cgg|cg[ds]|c[ds]g|c[ds]b|vth|vdsat)\s*"\s*"\s*($numberspice)\s*"\)/i ) ; ## Récupération de certains paramètres caractéristiques des MOS
          #$carac{$1}=$2 if ( /^\("\s*(\w+)\s*"\s*"\s*($numberspice)\s*"\)/i ) ; full version
          $region=$1 if /^\("region"\s+"(\w+)\s*"\s*\)/i ;
          last if /^\)$/ ;
        } ## End while sur le device
        ($w) = map ({$split{$_}} grep {/^w$/i} keys %split) ; ; $w =~ s/0+e/0e/i ;
        ($l) = map ({$split{$_}} grep {/^l$/i} keys %split) ; $l =~ s/0+e/0e/i ;
        ($vgs) = map {$split{$_}} (grep {/vgate/i} keys %split) ; $vgs =~ s/0+e/0e/i ;
        ($vds) = map {$split{$_}} (grep {/vdrain/i} keys %split) ; $vds =~ s/0+e/0e/i ;
        if (defined $o_debug) { ## Debug purpose, switch getc on/off
          print "Summary of analysis of $name device on this set\n";
          print "\tParameter found ; $_ = $split{$_}\n" foreach (keys %split) ;
          print "\tWidth : $w\n" if $w ;
          print "\tLength : $l\n" if $l ;
          print "\tVdrain : $vds\n" if $vds ;
          print "\tVgate : $vgs\n" if $vgs ;
          print "\tAlter : $alter\n" if $alter ;
          print "\tModel : $model\n\tType : $type\n\tRegion : $region\n";
          print "\tCarac : $_ = $carac{$_}{val}\n" foreach (keys %carac) ;
          #getc ;
        }
        $name .="#w_$w#l_$l"; 
        $h{$name}{def} = {"width"=>$w, "length"=>$l, "model"=>$model, "type" => $type} ;
        $h{$name}{step}{$vds}{$vgs}{carac}{param}{$_} = $carac{$_}{val} foreach (keys %carac) ;
        $h{$name}{step}{$vds}{$vgs}{carac}{param}{AV} = $carac{GM}{val}/$carac{GDS}{val}  ;
        $h{$name}{step}{$vds}{$vgs}{carac}{param}{AV} = sprintf("%3.3f", $h{$name}{step}{$vds}{$vgs}{carac}{param}{AV}) ; ## Troncature du AV, sinon ça peut perturber les colonnes
        $h{$name}{step}{$vds}{$vgs}{carac}{region} = $region ;
        #print "$term_sep\n" and getc ;
      } ## End if
    } ## End while sur le fichier
    close ($fh) ;
  }

  print Dumper \%h and print "Dumper %h hash\n" and getc if (defined $o_debug) ;
  foreach my $name (keys %h) {
    $ufile=$name.".dat" ; ## Nom du fichier data de sortie associé au MOS
    system ("touch", $ufile) if (! -f $ufile) ; ## On le créé s'il n'existe pas et on l'ouvre
    open ($fh, ">$ufile") ;
    print ($fh "## Caracterisation of device $name\n") ;
    print ($fh "## Model used : $h{$name}{def}{model}\n## Type : $h{$name}{def}{type}\n## Width : $h{$name}{def}{width}\n## Length : $h{$name}{def}{length}\n") ;
    printf ($fh "%-10s%-15s%-15s","#Region","VDrain","VGate") ;
    $vds = (keys %{$h{$name}{step}})[0] ; $vgs = (keys %{$h{$name}{step}{$vds}})[0] ;
    printf ($fh "%-15s",$_) foreach (sort keys %{$h{$name}{step}{$vds}{$vgs}{carac}{param}}) ;
    print ($fh "\n") ; ## Ecriture de l'entête et des params en heut de colonne
    foreach $vds (sort {$a <=> $b} keys %{$h{$name}{step}}) {
      foreach $vgs (sort {$a <=> $b} keys %{$h{$name}{step}{$vds}}) {
        given ($h{$name}{step}{$vds}{$vgs}{carac}{region}) {
          when (/subthreshold/i) {$region=1;}
          when (/linear/i) {$region=2;}
          when (/saturation/i) {$region=3;}
        }
        ## Ecriture dans le fichier de sortie, old version, ordre en dur
        #printf ($fh "%-10s%-15s%-15s%-15s%-15s",$region,$vds,$vgs,$h{$name}{step}{$vds}{$vgs}{carac}{param}{ID},$h{$name}{step}{$vds}{$vgs}{carac}{param}{GM}) ; 
        printf ($fh "%-10s%-15s%-15s",$region,$vds,$vgs) ; 
        foreach ( sort keys %{$h{$name}{step}{$vds}{$vgs}{carac}{param}}) {
          printf ($fh "%-15s",$h{$name}{step}{$vds}{$vgs}{carac}{param}{$_}) ; 
          if (! $minmax{$name}{$_}{min}) { ## Extraction du maximum et minimum pour les différentes caractéristiques des MOS ; A faire, de même pour vgs, vds ?
            $minmax{$name}{$_}{min}=$h{$name}{step}{$vds}{$vgs}{carac}{param}{$_} ;
          } elsif (! $minmax{$name}{$_}{max}) {
            $minmax{$name}{$_}{max}=$h{$name}{step}{$vds}{$vgs}{carac}{param}{$_} ;
          } else {
            $minmax{$name}{$_}{min}=$h{$name}{step}{$vds}{$vgs}{carac}{param}{$_} if ($minmax{$name}{$_}{min}>$h{$name}{step}{$vds}{$vgs}{carac}{param}{$_}) ;
            $minmax{$name}{$_}{max}=$h{$name}{step}{$vds}{$vgs}{carac}{param}{$_} if ($minmax{$name}{$_}{max}<$h{$name}{step}{$vds}{$vgs}{carac}{param}{$_}) ;
          }
        }
        print ($fh "\n") ;
      }
      print ($fh "\n") ;
      $minmax{$name}{$_}{step}=$minmax{$name}{$_}{max}-$minmax{$name}{$_}{min} and $minmax{$name}{$_}{step}=$minmax{$name}{$_}{step}/15 foreach (keys %{$minmax{$name}}) ; ## Ici, step de 15
    }
    printf ($fh "%-40s","##Minimum for MOS caracteristics") ;
    printf ($fh "%-15s",$minmax{$name}{$_}{min}) foreach (sort keys %{$minmax{$name}}) ; print ($fh "\n") ;
    printf ($fh "%-40s","##Maximum for MOS caracteristics") ;
    printf ($fh "%-15s",$minmax{$name}{$_}{max}) foreach (sort keys %{$minmax{$name}}) ; print ($fh "\n") ;
    print ($fh "\n") ;
    close ($fh) ; ## Fin d'écriture du fichier de data

    $ufile="plot3d_".$name.".gpl" ; ## Nom du fichier de plot3d de sortie associé au MOS
    system ("touch", $ufile) if (! -f $ufile) ; ## On le créé s'il n'existe pas et on l'ouvre
    open ($fh, ">$ufile") ;
    print ($fh "## 3d plotting commands for device $name\n") ;
    print ($fh "## Data file used : $name.dat\n") ;
    print ($fh "## Model used : $h{$name}{def}{model}\n## Type : $h{$name}{def}{type}\n## Width : $h{$name}{def}{width}\n## Length : $h{$name}{def}{length}\n") ;
    print ($fh "set dgrid3d\nset contour surface\n") ;
    foreach (sort keys %{$minmax{$name}}) { ##print des contours pour tous les parametres en commentaires
      $index=1 ;
      print ($fh "##step${_} set cntrparam levels discrete" ) ;
      while ($index<14) { 
        my $level=$minmax{$name}{$_}{min}+$index*$minmax{$name}{$_}{step} ;
        print ($fh ",") if ($index>1) ;
        print ($fh " $level") ;
        $index++ ;
      }
      print ($fh "\n") ;
    }
    $index=1; while ($index<14) {print ($fh "\nset lt $index lw 3") ; $index++ ; } ## Ici aussi, step de 15
    print ($fh "\nset lt $index lw 0.5") ; 
    print ($fh "\nsplot \"$name.dat\" using 2:3:\$col with lines nosurface\n\nunset dgrid3d\nset hidden3d\nset pm3d depthorder hidden3d $index\n") ;
    print ($fh 'set palette model RGB defined (0 "blue", 1 "dark-blue", 1 "red", 2 "dark-red", 2 "yellow", 3 "dark-yellow")') ;
    print ($fh "\nset style fill transparent solid 0.4 border\n") ;
    print ($fh "splot \"$name.dat\" using 2:3:\$col:1 with pm3d title \"\$param (VDrain, VGate) ; MOS type $h{$name}{def}{type}, model $h{$name}{def}{model}: Width= $h{$name}{def}{width}, Length=$h{$name}{def}{length}\"\n\nset grid\n") ;
    print ($fh "set xlabel \"Drain voltage\"\nset ylabel \"Gate voltage\"\n\npause -1\n") ;
    close ($fh) ;
  }
  print Dumper \%minmax and getc if (defined $o_debug);
} ## End of ext_mosop function

sub mod_op { ## Modification des .op, requis dans certains cas où on ne peut pas lancer les simulations en // avec tous les steps
  foreach my $filepath ( keys %file ) {
    open ($fh, "<", "$filepath") or die ("Failed to open $filepath : $!");
    my @toprint ;
    while (<$fh>) { ## while sur le fichier
      if ( /param\s*:(?:\s*\w+\s*=\s*$numberspice,?)+/i ) {
        chomp $_ ; push @toprint, $_.",L = 2.00000E-7\n" ;
      } else {
        push @toprint, $_ ;
      }
    }
    close ($fh) ;
    open ($fh, ">", "$filepath") or die ("Failed to open $filepath : $!");
    print ($fh $_) foreach @toprint ;
    close ($fh) ;
  }
}

sub plot {
  undef %file ;
  opendir (PATH, $path) or die "Unable to open directory $path ; $!" ; @file = grep {$_ if ( (-f $_) && (!/^\./) && (/\.gpl$/))} readdir PATH ; 
  print Dumper \@file and getc if (defined $o_debug) ;
  my %choice ;
  foreach $file (@file) {
    open ($fh, "<", "$file") or die "Unable to open $file file ; $!" ;
    while (<$fh>) {
      $model = $1 if /^## Model used : (?:X_)?(\w+\.\w+).\d+$/i ; ## Ici, cela est caractéristique de la notation de la tecnologie xfab18
      $type = $1 if /^## Type : (\S+)$/i ;
      $w = $1 if /^## Width : (\S+)$/i ;
      $l = $1 if /^## Length : (\S+)$/i ;
    }
    close ($fh) ;
    $choice{$type}{$model}{$w}{$l}=$file ;
  }
  print Dumper \%choice and getc if (defined $o_debug) ;

  print "$term_sep\nSelection of device and parameter to plot\n\n" ;
  $type = stdin_answer ('ntr', 'Select MOS type', (keys %choice));
  $model = stdin_answer ('ntr', 'Select MOS model', (keys %{$choice{$type}}));
  $w = stdin_answer ('ntr', 'Select MOS width', (keys %{$choice{$type}{$model}}));
  $l = stdin_answer ('ntr', 'Select MOS length', (keys %{$choice{$type}{$model}{$w}}));
  print "$choice{$type}{$model}{$w}{$l} gpl file will be used\n" if (defined $o_debug) ;
  $choice = stdin_answer ('ntr', 'Select parameter to plot', qw/AV Cdb Cdg Cgd Cgg Cgs Csb Csg GDS GM ID VDSAT VTH/) ;
  my $col ;
  given ($choice) { ## Les colones sont agencées par ordre alphabétique
    when (/AV/) {$col=4 ;}
    when (/Cdb/) {$col=5 ;}
    when (/Cdg/) {$col=6 ;}
    when (/Cgd/) {$col=7 ;}
    when (/Cgg/) {$col=8 ;}
    when (/Cgs/) {$col=9 ;}
    when (/Csb/) {$col=10 ;}
    when (/Csg/) {$col=11 ;}
    when (/GDS/) {$col=12 ;}
    when (/GM/) {$col=13 ;}
    when (/ID/) {$col=14 ;}
    when (/VDSAT/) {$col=15 ;}
    when (/VTH/) {$col=16 ;}
  }
  open ($fh, "<",$choice{$type}{$model}{$w}{$l}) or die "Unable to open file $choice{$type}{$model}{$w}{$l} ; $!" ;
  my $fhtmp ;
  system ("rm","tmp.gpl") if (-f "tmp.gpl") ;
  system ("touch", "tmp.gpl") ;
  open ($fhtmp, ">", "tmp.gpl") ;
  while (<$fh>) {
    if (/^##step(\w+)\s+(.*)/) {
      print ($fhtmp $2."\n") if ($1 eq $choice) ;
    } elsif (/.*\$col.*\$param/) {
      my $toprint = $_ ;
      $toprint =~ s/\$col/$col/ ;
      $toprint =~ s/\$param/$choice/ ;
      print ($fhtmp $toprint) ;
    } elsif (/\$col/) {
      my $toprint = $_ ;
      $toprint =~ s/\$col/$col/ ;
      print ($fhtmp $toprint) ;
    } else {
      print ($fhtmp $_) ;
    }
  }
  close ($fh) ;
  close ($fhtmp) ;
  #system ("gnuplot", "tmp.gpl") ; ## Ici, pb pour lancer plusieurs plot avec gnuplot
  #system ("rm","tmp.gpl") ;
}

################################################################################
#Main function start
################################################################################
check_options();

#my $path = '/nfs/work-crypt/ic/common/xfab/xh018/mentor/v4_0/eldo/v4_0_4/lpmos' ;
$path=`pwd`; chomp $path; $path .="/" ;
printv("Directory under scan : $path\n");

find ( sub { if (/\.op(\d+)$/i ) {  ## On va chercher dans path les fichiers de type .op
    $file{$_}=$1;
  }
}
, $path ) ;

my $dut="mos" ;

print Dumper \%file and print "Dumper %file hash\n" and getc if (defined $o_debug) ;

ext_mosop if (defined $o_ext) ;
mod_op if (defined $o_mod) ;
plot if (defined $o_plot) ;

