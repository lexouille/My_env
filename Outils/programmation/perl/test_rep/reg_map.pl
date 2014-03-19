#!/usr/bin/perl
use strict;
use warnings;

my (%regr,%regw,%regi);
my (@regr,@regw,@regi);
my ($regname,$regpos,$regsize,$regval);
my ($w1,$w2,$w3,$w4,$w5,$w6);
my $idcount;
my ($rcount,$wcount,$icount);
#my $filein = "./reg_map.txt";
my $filein = "./mppa_tca_reg.vhd";
my $fileres = "./reg_map_res.tcl";
open (FILEr, "<$filein") or die ("open : $!");
open (FILEw, ">$fileres") or die ("open : $!");

# Version pour type texte, attention au format
# il reste quelques bugs
#while (<FILEr>) {
  #print $_ and $idcount++ if (/\s+\w+\s+\d\s+\d/);
  ##if ( ($regname,$regpos,$regsize,$regval) = ($_ =~ m/\s+(\w+)\s+(\d)\s+(\d)\s+0x([0-9a-fA-F])/ ) ) {
    ##print ("set reg_pos($regname) $regpos\n") ;
    ##print ("set reg_size($regname) $regsize\n") ;
    ##print ("set reg_val($regname) $regval\n") ;
  ##}
  ##print ("$w2\n") if (($w2 =~ m/\d/) && defined $w2);
  ##$reg_pos{$w1}=$w2 if ($w2 =~ m/\d/);
#}
#print "$idcount\n";

# Version pour type vhd sans modif
while (<FILEr>) {
  # On saute les patterns espace + -- commentaires
  next if (/^\s*--/);

################################################################################
## Reconnaissance des registres d'écriture $w1 nom_reg et $w2 le contenu de la parenthèse
################################################################################
  if ( ($w1,$w2) = ($_ =~ m/\s*(\w+)\s*<=\s*\w+\(([0-9a-zA-Z ]+)\)/ ) ) {
    $wcount++;
# Cas registre de taille 1
    $regw{$w1}{'size'}=1 and $regw{$w1}{'position'}=$w2 if ( ($w2 =~ m/\d/) ); 
# Cas registre de taille > 1
    $regw{$w1}{'size'}=$w3-$w4+1 and $regw{$w1}{'position'}=$w4 if ( ($w3,$w4) = ( $w2 =~ m/(\d+)\sdownto\s(\d+)/) );
    print "Registre d'écriture -- nom : $w1 ; taille : $regw{$w1}{'size'} ; position : $regw{$w1}{'position'}\n";
  }

################################################################################
##Reconnaissance des registres de lecture : pattern type status_i(...) <= name
################################################################################
  if ( ($w1,$w2) = ($_ =~ m/\s*status_i\(([0-9a-zA-Z ]+)\)\s*<=\s*(\w+)/ ) ) {
    $rcount++;
    #Debug
    #print "$_\n$w1\t$w2\n";
 #Cas registre de taille 1
    if ($w1 =~ m/\d/) {
      #Debug
      #print "Registre de lecture : size = 1 ; param = $w1\t$w2\n";
      #Debug
      $regr{$w2}{'size'}=1;
      $regr{$w2}{'position'}=$w1;
    }
 #Cas registre de taille > 1
    if ( ($w3,$w4) = ( $w1 =~ m/(\d+)\sdownto\s(\d+)/) ) {
      #Debug
      #print "Registre de lecture : Size > 1 ; param w1 w2 = $w1\t$w2\n";
      #print "param w3 w4 = $w3\t$w4\n";
      $regr{$w2}{'size'}=$w3-$w4+1;
      $regr{$w2}{'position'}=$w4;
    }
    print "Registre de lecture -- position : $regr{$w2}{'position'} ; taille : $regr{$w2}{'size'} ; Registre associé : $w2\n";
  }

################################################################################
## Reconnaissance des valeur initiales des registres ; cas pour des valeurs binaires
################################################################################
  if ( ($w1,$w2,$w3) = ($_ =~ m/\s*(\w+)\(([0-9a-zA-Z ]+)\)\s*<=\s*["']{1}([01]+)["']{1}/ ) ) {
    #Debug
    #print "Registre d'initialisation : param w1 w2 w3 = $w1\t$w2\t$w3\n";
    #print "Registre d'initialisation : nom : $w1; taille : $regr{$w1}{'size'} ;position : $regr{$w1}{'position'}"
    $icount++;
    if ($w2 =~ m/\d/) {
      $regi{$w1}{$w2}=$w3;
    }
 #Cas registre de taille > 1
    if ( ($w5,$w6) = ( $w2 =~ m/(\d+)\sdownto\s(\d+)/) ) {
      $w2=$w6;
      $regi{$w1}{$w2}=$w3;
    }
    print "Registre d'initialisation --  nom : $w1 ; position : $w2 ; Valeur d'init : $regi{$w1}{$w2}\n";
  }
}

print "Registres en écriture\n";
print ( FILEw "##Registres en écriture\n");
$w1="control_rst_val";
foreach ( sort {$regw{$b}{'position'} <=> $regw{$a}{'position'}} keys %regw) {
#Ancienne version sans sort
#foreach my $key (keys %regw) {
  #print ("$key\n");
  #$regi{$w1}{$regw{$key}{'position'}}=0 if (!exists $regi{$w1}{$regw{$key}{'position'}});
  #print $regi{$w1}{$regw{$key}{'position'}};
  #print ( FILEw "set regw($key) [list $regw{$key}{'position'} $regw{$key}{'size'} $regi{$w1}{$regw{$key}{'position'}}]\n");
  #print ("set regw($key) [list $regw{$key}{'position'} $regw{$key}{'size'} $regi{$w1}{$regw{$key}{'position'}}]\n");

  $regi{$w1}{$regw{$_}{'position'}}=0 if (!exists $regi{$w1}{$regw{$_}{'position'}});
  print ( FILEw "set regw($_) [list $regw{$_}{'position'} $regw{$_}{'size'} $regi{$w1}{$regw{$_}{'position'}}]\n");
  #Debug
  #print ("set regw($_) [list $regw{$_}{'position'} $regw{$_}{'size'} $regi{$w1}{$regw{$_}{'position'}}]\n");
}

#foreach (sort {$hash{$b} cmp $hash{$a}} keys %hash) {
  #print "$_: $hash{$_}\n";
#}
print "Registres en lecture\n";
print ( FILEw "\n##Registres en lecture\n");
foreach ( sort {$regr{$b}{'position'} <=> $regr{$a}{'position'}} keys %regr) {
#Ancienne version sans sort
#foreach my $key (keys %regr) {
  #print ("$key\n");
  #print ( FILEw "set regr($regr{$key}{'name'}) [list $key $regr{$key}{'size'}]\n");
  #print ("set regr($regr{$key}{'name'}) [list $key $regr{$key}{'size'}]\n");
  print ( FILEw "set regr($_) [list $regr{$_}{'position'}) $regr{$_}{'size'}]\n");
  #Debug
  #print ( "set regr($_) [list $regr{$_}{'position'}) $regr{$_}{'size'}]\n");
}
print "Nombre de registres en écriture trouvés : $wcount\n";
print "Nombre de registres d'initialisation trouvés : $icount\n";
print "Nombre de registres en lecture trouvés : $rcount\n";

close ( FILEr ) ;
close ( FILEw ) ;
