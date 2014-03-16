#!/usr/bin/perl -w

use strict;
use warnings;
use Text::Wrap;
local $Text::Wrap::columns = 80;
my $initial_tab = "+ ";
my $other_tab = "+ ";
my $no_tab = "";

my $filename = "/nfs/home/aferret/Documents/Outils/programmation/perl/test_rep/VCO_CVtest.cir";
my $filetest = "/nfs/home/aferret/Documents/Outils/programmation/perl/test_rep/test.cir";
my $file = "./filetest.txt";

my $text;

my ($line,@words,$s_words);
my ($subckt,$subckt_name);
my (@arglist,$arg,$s_arglist);
my ($subckt_pos,$subckt_occur);
my (%hsubckt,$hsubckt_key,$hsubckt_ref);

$hsubckt_ref=\%hsubckt;

## Manipulation subckt
open (FILEr, "<$filename") or die ("open : $!");
open (FILEw, ">$filetest") or die ("open : $!");

$subckt=0;

print "\n";

while (<FILEr>) {
    if (/^\.SUBCKT|^\.subckt/) {
## Detection structure commençant par .subckt
## Increment de l'indice subckt, reset du tableau arglist et des autres tables
        $subckt++;
        @arglist=();

## Début traitement première ligne de structure
## Split de la ligne sans . et affectation de @words, taille du tableau
        $line = substr( $_ , 1 ) ;
        @words = split( /\s+/, $line ) ;
        $s_words = scalar(@words);

## Affectation du nom du subckt, de sa position dans le fichier
## 2 shift : le premier retire subckt, l'autre retire sub_name et le stocke
## On stocke la position dans la netlist de base
        shift (@words);
        $subckt_name = shift(@words);
        $hsubckt{$subckt_name}{'subckt_pos'}=$.;
## Debut de l'affectation de la arglist, traitement première ligne
        push @arglist, @words;
## Debug
        print ( "Subckt n° $subckt : name : $subckt_name \n" ) ;
        print ( "Subckt n° $subckt : ligne position : $hsubckt{$subckt_name}{'subckt_pos'} \n" ) ;
## Fin traitement première ligne de structure

## Traitement de la suite de la déclaration du subckt
        while (<FILEr>)
        {
            last if !(/^\+/); # Test début de ligne=+
            next if (/^\+ ! Pin List/); # Saut de l'execution pour lignes spéciales
            next if (/^\+ ! Param List/); # Saut de l'execution pour lignes spéciales
            next if (/^\+ ! Comments/); # Saut de l'execution pour lignes spéciales
            if (/^\+ !/) # Execution spécaile pour les types commentaires
            {
              my $line = substr( $_ , 2 ) ;
              push @{$hsubckt_ref->{$subckt_name}{'comments'}}, $line;
              next
            }
## Split de la ligne sans + et affectation de @words, @arglist, taille du tableau
            my $line = substr( $_ , 1 ) ;
            @words = split( /\s+/, $line ) ;
            #@words = grep { /.+/ } @words ; Utilité
            push @arglist, @words;
        }
        $s_arglist = scalar(@arglist);
## Debug
        print ( "Subckt n° $subckt : arglist : @arglist \n" ) ;
        $hsubckt_key = 'pinlist';
        foreach $arg (@arglist)
        {
          $hsubckt_key = 'paramlist' if ( $arg =~ m/.+=.+/ ) ; # Test paramètre déclaré seul
          $hsubckt_key = 'paramlist' and next if ( $arg =~ m/param:/ ) ; # Test avec syntaxe optionnelle "param:"
          push @{$hsubckt_ref->{$subckt_name}{$hsubckt_key}}, $arg;
## Debug
          print ( "Argument de type : $hsubckt_key ; valeur : $arg\n" );
        }
        print ( "Nombre de args : $s_arglist \n" ) ;
        if ( exists $hsubckt{$subckt_name}{'pinlist'} )
        {
          print ( "Liste des pins : @{$hsubckt_ref->{$subckt_name}{'pinlist'}}\n");
        } else 
        {
          print ("Le subckt $subckt_name ne possède pas de pins\n");
        }
        if ( exists $hsubckt{$subckt_name}{'paramlist'} )
        {
          print ( "Liste des params : @{$hsubckt_ref->{$subckt_name}{'paramlist'}}\n");
        } else 
        {
          print ("Le subckt $subckt_name ne possède pas de paramètre\n");
        }
        if ( exists $hsubckt{$subckt_name}{'comments'} )
        {
          print ( "Liste des commentaires : @{$hsubckt_ref->{$subckt_name}{'comments'}}\n");
        } else 
        {
          print ("Le subckt $subckt_name ne possède pas de commentaires\n");
        }
## Fin traitement de la suite de la arglist

## Traitement du coeur du subckt
        while (<FILEr>)
        {
            last if /^\.ENDS|^\.ends/;
            push @{$hsubckt_ref->{$subckt_name}{'subckt_body'}}, $_;
        }
## FIN traitement du coeur du subckt
    }
}

## Réecriture dans le fichier write
print ( FILEw "\n");

foreach $subckt_name (keys %{hsubckt})
{
  print ( FILEw ".subckt $subckt_name\n");
  print ( FILEw "+ ! Pin List\n");
  if ( exists $hsubckt{$subckt_name}{'pinlist'} )
  {
    print ( FILEw wrap($initial_tab, $other_tab, @{$hsubckt_ref->{$subckt_name}{'pinlist'}}));
    print ( FILEw "\n");
  }
  print ( FILEw "+ ! Param List\n");
  if ( exists $hsubckt{$subckt_name}{'paramlist'} )
  {
    print ( FILEw wrap($initial_tab, $other_tab, @{$hsubckt_ref->{$subckt_name}{'paramlist'}}));
    print ( FILEw "\n");
  }
  print ( FILEw "+ ! Comments\n");
  if ( exists $hsubckt{$subckt_name}{'comments'} )
  {
    print ( FILEw wrap($initial_tab, $other_tab, @{$hsubckt_ref->{$subckt_name}{'comments'}}));
  }
  print ( FILEw "\n");
  foreach $arg (@{$hsubckt_ref->{$subckt_name}{'subckt_body'}})
  {
    print ( FILEw wrap($no_tab, $other_tab, $arg));
  }
  print ( FILEw "\n");
  print ( FILEw ".ends \n\n");
}

print ( "Nombre de subckt dans le fichier $filename : $subckt \n" ) ;

print "\n";

close ( FILEr ) ;
close ( FILEw ) ;


