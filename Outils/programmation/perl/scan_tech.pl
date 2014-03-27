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
          if (!/^\+/) { ## Si ça ne commence pas par un + ou un commentaire, l'instantiation du subckt est terminée. Un peu de print et on revient à LINE
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


####################################
push(@EXPORT,'analyze_techno') ;
sub analyze_techno {
  my $debug=1;
  if ( $debug ) { print "DBG BEGIN analyze_techno\n" ; }
  my %res  = () ;
  my $return = 0 ;
  my $ref_to_conf = shift ;
  my @models = () ;
  my %corners = () ;

  # Name
  $res{name} = $ref_to_conf->{name} ;

  # Modèles analogiques (Eldo pour le moment)
  foreach (@{$ref_to_conf->{ELDO}}) {
    push(@models,map {s/\s*$//;$_;} qx/grep -i "^\\.model" $_/) ;
    push(@models,map {s/\s*$//;$_;} qx/grep -i "^\\.subckt" $_/) ;
  }
  @models=uniq(@models) ;
  if ( $debug ) { print "DBG ici models :\n" ; print Dumper \@models ; }

  my @mods = @models ;
  foreach (@mods) {
    if ( /^\s*\.model\s/ ) {
      my ($n,$t) = ( /^\s*\.model\s+(\S+)\s+(\S+)/ ) ;
      die ("$_ : ligne model non reconnue\n") unless ( (defined $n) and (defined $t) ) ;
# TODO case et nfet
      if    ( $t eq "PMOS" ) { $res{devices}{$n}{nbpin} = 4 ; }
      elsif ( $t eq "NMOS" ) { $res{devices}{$n}{nbpin} = 4 ; }
      elsif ( $t eq "PNP" )  { $res{devices}{$n}{nbpin} = 3 ; }
      elsif ( $t eq "NPN" )  { $res{devices}{$n}{nbpin} = 3 ; }
      elsif ( $t eq "D" )    { $res{devices}{$n}{nbpin} = 2 ; }
      else { die("$t : model inconnu\n") ; }
    }
    elsif ( /^\s*\.subckt\s/ ) {
      my $t=0 ;
      s/\w+=.*// ;
      my ($n) = ( /^\s*\.subckt\s+(\S+)/ ) ;
      s/^\s*\.subckt\s+(\S+)// ;
      while ( /[^\s]/ ) { s/\s*(\S+)// ; $t++ ; }
      $res{devices}{$n}{nbpin} = $t ;
    }
  }

  $res{anamod} = [ keys(%{$res{devices}}) ] ;

  map { s/^\s*\.(:?subckt|model)\s*(\w+).*/$2/ } @models ;
  if ( $debug ) { print "DBG là models :\n" ; print Dumper \@models ; }
  
  my @pmos = grep {/\bp(mos|fet)\b/i} @models ;
  my @nmos = grep {/\bn(mos|fet)\b/i} @models ;
  my @pnp  = grep {/\bpnp\b/i}  @models ;
  my @npn  = grep {/\bnpn\b/i}  @models ;

  $res{pmos_all} = [ @pmos ] ;
  $res{nmos_all} = [ @nmos ] ;
  $res{pnp_all}  = [ @pnp  ] ;
  $res{npn_all}  = [ @npn  ] ;

  if ( $debug ) { print Dumper \@nmos ; }

  # Corners
  my %files = () ;
  foreach (@{$ref_to_conf->{ELDO}}) {
    my $fileorig = $_ ;
    my %decount = () ;
    #my $file = $fileorig ;
    my $file = "" ;
    my $corner = "" ;
    my @tab = map {s/^\s*//;s/\s*$//;$_;} grep {!/^\s*$/} qx/grep -iPx '^\\s*\\.\(lib\|endl\|include\|model\|subckt\)\\b.*\$' $_/ ;
    if ( $debug ) { print Dumper \@tab ; }
    while ( my $line = shift(@tab) ) {
      if ( $debug ) { print "DBG Treating $line\n" ; }

      #if ( $file eq $fileorig )      {}
      #elsif ( $decount{$file} == 0 ) { $file = $fileorig ; }
      #else                           { $decount{$file}--;  }
      #if ( $debug ) { print "DBG Décompte de $file : $decount{$file}\n" unless ( $file eq $fileorig ) ; }
      #if ( $debug ) { print "DBG " ; print Dumper \%decount ; }

      if ( $line =~ m=^\s*\.(model|subckt)\s+(\S+)=i ) {
        if ( $debug ) { print "DBG line : $2 est un MODEL ou un SUBCKT\n" ; }
        if ( $corner ne "" ) {
          $corners{$2} = [] unless ( exists $corners{$2} ) ;
          #print "On a $2 et $corner et $file\n" ;
          $files{$2}{$corner} = $file unless ( exists $files{$2}{$corner} ) ;
          push ( @{$corners{$2}} , $corner ) ;
        }
      }
      elsif ( $line =~ m=^\s*\.include\s+(\S+)=i ) {
        if ( $debug ) { print "DBG line : $1 est INCLUDED\n" ; }
        my $inc = $1 ;
        while ( $inc =~ /^['"]/ ) { $inc =~ s/^'(.*)'$/$1/ ; $inc =~ s/^"(.*)"$/$1/ ; }
        $inc = dirname($_)."/".$inc ;
        my @inc = map {s/^\s*//;s/\s*$//;$_;} grep {!/^\s*$/} qx/grep -iPx '^\\s*\\.\(lib\|endl\|include\|model\|subckt\)\\b.*\$' $inc/ ;
        @tab = ( @inc , @tab ) ;
        #$decount{$inc} = scalar(@inc) ;
        #$file = $inc ;
      }
      elsif ( $line =~ m=^\s*\.lib\s+(\S+)(?:\s+(\S+))?=i ) {
        if ( $corner eq "" ) {
          $corner = uc($1) ;
          $file = $_ ;
        }
        else {
          if ( $debug ) { print "DBG $1 est INCLUDE (LIB) avec '$2' \n" ; }
          my $inc = $1 ;
          while ( $inc =~ /^['"]/ ) { $inc =~ s/^'(.*)'$/$1/ ; $inc =~ s/^"(.*)"$/$1/ ; }
          my $typ = $2 if ( $2 ) ;
          if ( $debug ) { print "DBG file : $_\n" ; }
          if ( $debug ) { print "DBG add  : $inc\n" ; }
          if ( $debug ) { print "DBG sec  : $typ\n" if ( $typ ) ; }
          if ( $debug ) { print "DBG final : ".dirname($_)."/".$inc."\n" ; }
          $inc = dirname($_)."/".$inc ;
          
          my @inc = map {s/^\s*//;s/\s*$//;$_;} grep {!/^\s*$/} qx/grep -iPx '^\\s*\\.\(lib\|endl\|include\|model\|subckt\)\\b.*\$' $inc/ ;
          my @add = () ;

          #getc error quand pas de fichier include bien défini !-f
          if ( $typ ) {
            shift(@inc) while ( $inc[0] !~ m/^\s*\.lib\s+$typ/i ) ;
            shift(@inc) ;
            push(@add,shift(@inc)) while ( $inc[0] !~ m/^\s*\.endl/i ) ;
          }

          @tab = ( @add , @tab ) ;
          #$decount{$inc} = scalar(@add) ;
          #$file = $inc ;
        }
      }
      elsif ( $line =~ m=^\s*\.endl=i ) {
        $corner = "" ;
      }
      else { die ("$line : ligne non reconnue\n") ; }
    }
  }
  #foreach (keys(%corners)) { $corners{$_} = [ uniq(map {$_ = uc($_) ;$_;} @{$corners{$_}}) ] ; }
  #if ( $debug ) { print Dumper \%corners ; }

  my @corners = () ;
  foreach (keys(%corners)) {
    die("$_ : Le composant a des corners mais n'a pas été détecté durant la recherche du nombre d'IO") unless ( exists $res{devices}{$_} ) ;
    $res{devices}{$_}{corners} = [ uniq(map {$_ = uc($_) ;$_;} @{$corners{$_}}) ] ;
    push(@corners,@{$res{devices}{$_}{corners}});
  }

  foreach (keys(%files)) {
    die ("$_ : device inconnu\n") unless ( exists ( $res{devices}{$_} ) ) ;
    foreach my $c (keys(%{$files{$_}})) {
      die($res{devices}{$_}{files}{$c}." : valeur déjà attribuée et différente de ce qu'on veut y mettre : $files{$_}{$c}\n") if ( ( exists $res{devices}{$_}{files}{$c} ) and ( $res{devices}{$_}{files}{$c} ne $files{$_}{$c} ) ) ;
      $res{devices}{$_}{files}{$c} = $files{$_}{$c} ;
    }
  }
  # Champ "corners"
  $res{corners} = [ uniq(@corners) ] ;

  ## Numérique
  my @digmod = () ;
  foreach (@{$ref_to_conf->{rtl}}) { push(@digmod,map { m/^\s*module\s+(\w+)\s*(?:\(|;)/ ; } grep {!/^\s*$/} qx/grep -P "^\\s*module\\s+\\w+\\s*(\\(\|;)" $_/) ; }
  $res{digmod} = [ @digmod ] ;

  if ( $debug ) { print "DBG END analyze_techno\n" ; }
  return %res ;
}

#my %h = (  "ELDO" => [ "/home/wiking/freedkits/PTM-MG/library/spice_models.lib" ]  ) ;
#my %h = (  "ELDO" => [ "/nfs/work-crypt/ic/common/altis/1.2.2/eldo/models/c11n_reg_sf_v3-14_07jun_bsim4v43.eldo" ]  ) ;
#my %techno = analyze_techno(\%h);

#print Dumper \%techno ;
