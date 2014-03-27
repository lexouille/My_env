#!/usr/bin/perl
use strict;
use warnings;
use feature qw/switch/; #Pour given ... when
use Data::Dumper;
use File::Find;

################################################################################
#### Test doublons dans les tableaux
################################################################################
#sub doublons_tranche {
  #my ($ref_tabeau) = @_;

  #my %hash_sans_doublon;    # Comme un hash ne peut pas avoir deux clés identiques,
                            ## utilser ces clé permet d'avoir un tableau unique
  #@hash_sans_doublon{ @{$ref_tabeau} } = ();    # Pas besoin de surcharger le hash avec des valeurs inutiles
                                                ## et ensuite, on renvoie le tableau des clés uniques
  #return keys %hash_sans_doublon;
#}

#sub doublons_grep {
  #my ($ref_tabeau) = @_;

  #my %hash_sans_doublon;

  #return grep { !$hash_sans_doublon{$_}++ } @{$ref_tabeau};
#}

#my @tab1=(1,2,3,"mot1","mot2","MOT1");
#my @tab2=(1,1,2,3,3,"mot1","mot2","mot2","MOT1");

#my @tab1_dt=doublons_tranche(\@tab1);
#my @tab1_dg=doublons_grep(\@tab1);
#my @tab2_dt=doublons_tranche(\@tab2);
#my @tab2_dg=doublons_grep(\@tab2);

#print ("tab originaux : \n@tab1\n@tab2\n");

#print ("tab1_dt : @tab1_dt\n");
#print ("tab1_dg : @tab1_dg\n");
#print ("tab2_dt : @tab2_dt\n");
#print ("tab2_dg : @tab2_dg\n");

#foreach my $id (@tab2_dt)
#{
  #print("$id\n");
#}
#foreach my $id (@tab2_dg)
#{
  #print("$id\n");
#}

# En principe, tranche un peu plus rapide que grep, mais ça reste comparable

#use strict;
#use warnings;
#use feature qw( say);
#my %h;
#while( my $l = <F> ) { # parcourir le fichier
  #chomp $l;
  #++$h{$l} # autovivification
#}
 
#while ( my ( $k, $v ) = each  %h ) {
  #my @l = split ",", $k;
  #say $l[1]," s'est connecté ", $v, " fois au serveur ", $l[2], " le ", $l[0]
#}

# A tester
# http://fr.openclassrooms.com/forum/sujet/perl-compter-le-nombre-de-doublons-d-un-tableau-69897

################################################################################

################################################################################
#### Test pour wrapper du texte
################################################################################

##Part1
#use Text::Wrap;
#my @text=qw(Ceci est une ligne de texte longue pour tester wrap. Avec certains caractères spéciaux comme . , ; + * / \, on pourrait en rajouter d'autres);
##my @text=qw(Ceci est une ligne de texte longue pour tester wrap Avec certains caractères spéciaux mais on va commencer avec une longue liste de mots);
#local $Text::Wrap::columns = 80;
#my $initial_tab = "";	# Tab before first line
#my $subsequent_tab = "+";	# All other lines flush left
#print wrap($initial_tab, $subsequent_tab, @text);
#print fill($initial_tab, $subsequent_tab, @text);
#my $lines = wrap($initial_tab, $subsequent_tab, @text);
#my @paragraphs = fill($initial_tab, $subsequent_tab, @text);

#Part2
#use Text::Wrap qw(wrap $columns $huge);
#$columns = 132;	# Wrap at 132 characters
#$huge = 'die';
#$huge = 'wrap';
#$huge = 'overflow';

#Part3
#use Text::Wrap;
#$Text::Wrap::columns = 72;
#print wrap('', '', @text);

# Références intéressantes ici
# http://perldoc.perl.org/Text/Wrap.html
#http://www.perlmonks.org/?node_id=37337

################################################################################

################################################################################
#### Test les hash de hash ou hash multiples
################################################################################

#my %h=();
#my $pinlist1="pin11 pin12 pin13";
#my $ref_h=\%h;
#my $pinlist2="pin21 pin22 pin23 pin24";
#my @pinlist1=qw(pin11 pin12 pin13);
#my @pinlist2=qw(pin21 pin22 pin23 pin24);
#my @pinlist3=qw(pin31 pin32 pin33);
#my @pinlist4=qw(pin41 pin42 pin43 pin44);

#$h{"key1"}{"pinlist1"}=\@pinlist1;
#$h{"key1"}{"pinlist2"}=\@pinlist2;
#$h{"key2"}{"pinlist1"}=\@pinlist3;
#$h{"key2"}{"pinlist2"}=\@pinlist4;

#print ("basetable1 : @pinlist1\n");
#print ("basetable2 : @pinlist2\n");
#print ("Hash key1 :\n");
#print ("pinlist1 : @{$ref_h->{key1}{pinlist1}}\n");
#print ("pinlist2 : @{$ref_h->{key1}{pinlist2}}\n");

#foreach my $key_l1 (keys %{$ref_h})
#{
  #foreach my $key_l2 (keys %{$ref_h->{$key_l1}})
  #{
    ##print ("Clés : lvl1 : $key_l1, lvl2 : $key_l2\n");
    ##print ("Valeur correspondante : @{$ref_h->{$key_l1}{$key_l2}}\n");
    #print ("Parcours de la table :\n");
    #foreach my $id (@{$ref_h->{$key_l1}{$key_l2}})
    #{
      #print ("Clés : lvl1 : $key_l1, lvl2 : $key_l2 ; valeur $id \n");
    #}
  #}
#}

#my @pinlist4=qw(pin51 pin52 pin53 pin54);
## Si ici on ne fait pas repointer, le hash et sa table conservent leurs valeurs
## commenter / decommenter la ligne dessous pour voir les effets
#$h{"key2"}{"pinlist2"}=\@pinlist4;

#print ("Print après MAJ tableau");
#foreach my $key_l1 (keys %{$ref_h})
#{
  #foreach my $key_l2 (keys %{$ref_h->{$key_l1}})
  #{
    ##print ("Clés : lvl1 : $key_l1, lvl2 : $key_l2\n");
    ##print ("Valeur correspondante : @{$ref_h->{$key_l1}{$key_l2}}\n");
    #print ("Parcours de la table :\n");
    #foreach my $id (@{$ref_h->{$key_l1}{$key_l2}})
    #{
      #print ("Clés : lvl1 : $key_l1, lvl2 : $key_l2 ; valeur $id \n");
    #}
  #}
#}

#print Dumper(%h);

# Test avec J

#%param = () ;
#$param{tab} = [ 35 , 14 , 326, 436 ] ;
#$param{hash} = { 'toi' => { 'nom' => 'Alex' , 'age' => 31 } , 'moi' => { 'nom' => 'J' , 'ville' => 'Grenoble' } } ;
#my %gate = ( 'nom' => 'add' , 'io' => '4' ) ;
#push(@{$param{hash}{porte}}, \%gate ) ;
#print Dumper \%param ;
#map {} grep {} map {} split(,);

## Test divers
#my ($scalaire1,$scalaire2)=(255,"scalaire");
#my @tableau=(0,1,2,"mot",$scalaire1,$scalaire2);
#print Dumper \@tableau;
#my %tableH=( "clé1" => "val1", "clé2" => "val2", "clé3" => 1);
#print Dumper \%tableH;
#my @tableau2;
#@tableau2=( [0,1,2,$scalaire1] , [3,4,5,$scalaire2]);
#print "\$#tableau2 = $#tableau2\n";
#for my $i (0..$#tableau2) {
   #for my $j (0..$#{$tableau2[$i]}) {        
      #print "Premier index \$i = $i, Dexième index \$j = $j, Valeur : $tableau2[$i][$j]\n";
   #}
#}
#my %tableH2=( "clé1" => { "clé11" => "val11", "clé12" => "val12" } , "clé2" => { "clé21" => "val21", "clé22" => "val22" });
#print Dumper \%tableH2;

#my %coord_;
#$coord_{"AB"}{1} = [420,520,870];
#$coord_{"AB"}{2} = [220,520,470];
#$coord_{"AB"}{6} = [320,320,270];
#$coord_{"AB"}{7} = [520,720,370];
#$coord_{"AB"}{8} = [620,520,670];
#$coord_{"PL"}{12} = [420,520,570];
#$coord_{"PL"}{13} = [220,520,170];
#$coord_{"B"}{2} = [320,720,670];
#$coord_{"B"}{4} = [520,520,170];
#$coord_{"B"}{5} = [620,820,370];
#foreach my $key1 (sort keys %coord_)
#{
        #foreach my $key2 (sort keys %{$coord_{$key1}})
        #{
                #printf "%s %d = X:%d, Y:%d, Z:%d\n",
                        #$key1, $key2, @{$coord_{$key1}{$key2}};
        #}

#}
#print Dumper \%coord_;

#my %voltage_def = ( "vnom"  => [ 1.5, 2.5 , 3.3 ] , 
                    #"vmin"  => [1.35, 2.25, 2.97] ,
                    #"vmax"  => [1.65, 2.75, 3.63] ,
                    #"v1min" => [1.35, 2.5 , 3.3 ] ,
                    #"v1max" => [1.65, 2.5 , 3.3 ] ,
                    #"v2min" => [ 1.5, 2.25, 2.97] ,
                    #"v2max" => [ 1.5, 2.75, 3.63] );
#print Dumper \%voltage_def;
#print "Elément hash : ${$voltage_def{vnom}}[1]";
#print "Table hash : @{$voltage_def{vnom}}";

#http://stackoverflow.com/questions/160175/traversing-a-multi-dimensional-hash-in-perl
#http://www.perlmonks.org/?node_id=248430

################################################################################

#my $filein = "./temp";
#my $fileres = "./tempres";
#open (FILEr, "<$filein") or die ("open : $!");
#open (FILEw, ">$fileres") or die ("open : $!");
#while (<FILEr>) {
  ##print $_;
  #$_ =~ s/ *(.+)/\[$1\]/;
  ##print $_;
  #print (FILEw $_);
#}

#my $path = qx/pwd/;

#my $ls = qx/ls $path/ ;
#print $ls;
#my @ls = split /\n/, $ls;
#print "\nFile and Directory list found :\n$ls\n@ls\n";
#getc;
#my @pl = grep ( /\w+\.pl$/ , @ls);
#print @pl;

## Fonction génériquen de sub quesion/réponse
#sub stdin_answer {
  #my @in = @_ ; 
  #my $question = shift @in ; map ( {tr/A-Z/a-z/} @in );#Si case insensitive
  #my %answer;
  #my $g_answer;
  #print "$question\n";
  #foreach (@in) { $answer{$_}++; }
  #$g_answer = <STDIN>; chomp $g_answer;
  #$g_answer =~ tr/A-Z/a-z/;
  #while ( !exists ( $answer{$g_answer} ) ) {
    #print "Wrong answer ; possible choices : @in\n$question\n";
    #$g_answer = <STDIN>; chomp $g_answer;
    #$g_answer =~ tr/A-Z/a-z/;
  #}
  #return $g_answer;
#}

#my @answerlist=('réponse1','réponse2');
#my @choice = ('Quelle est la question',@answerlist);
#my $result = stdin_answer (@choice);
#print $result;

#my %hash;
#my @stack;
#push @stack,\%hash;
#my %h; my @t;
#$h{'S1'}{'call'}="1toto 1titi 1tata S2 S3";
#$h{'S2'}{'call'}="2toto 2titi 2tata S4 S3 S5";
#$h{'S3'}{'call'}="3toto 3titi 3tata S4 S7";
#$h{'S4'}{'call'}="4toto 4titi 4tata";
#$h{'S5'}{'call'}="5toto 5titi 5tata S6";
#$h{'S6'}{'call'}="6toto 6titi 6tata";
#$h{'S7'}{'call'}="7toto 7titi 7tata S8 S9";

#foreach my $key (keys %h) {
  ##print "$h{$key}{'call'}\n";
  #@t=split / /,$h{$key}{'call'} ;
  #foreach (@t) {
    ##print "$_\n";
    #print "$key a un child : $_\n" if (exists $h{$_}) ;
    #$hash{$key}{"child"}=$_;
  #}
#}

#find(\&print_name_if_dir, "/nfs/home/aferret/Documents/Outils");

#sub print_name_if_dir
#{
    #print  "$_\n" if -d;
#}
#print Dumper \%h;

my %subckt = ( "sckt_name" => { "temp" => { "pinlist" => {
"1" => "toto" ,
"2" => "toto" ,
"3" => "toto" ,
"4" => "toto" ,
"5" => "toto" ,
"6" => "toto" ,
"7" => "toto" ,
"8" => "toto" ,
"9" => "toto" ,
"10" => "toto" ,
"11" => "toto" ,
"12" => "toto" ,
"13" => "toto" ,
"14" => "toto" ,
"15" => "toto" ,
"16" => "toto" ,
"17" => "toto" ,
"18" => "toto" ,
"19" => "toto" ,
"20" => "toto" ,
"21" => "toto" ,
"23" => "toto" ,
"24" => "toto" ,
"26" => "toto" ,
"27" => "toto" ,
"28" => "toto" ,
"29" => "toto" ,
"30" => "toto" ,
"36" => "toto" ,
"41" => "toto" } } } );
print Dumper \%subckt;

foreach ( sort { $a <=> $b } keys %{$subckt{sckt_name}{temp}{pinlist}} ) {
  print "key : $_;\n"}

################################################################################
#### Test math big float
################################################################################
#use Math::BigFloat;

#http://perldoc.perl.org/Math/BigFloat.html
#http://search.cpan.org/~flora/Math-BigInt-1.95/lib/Math/BigFloat.pm
#Pour l'affichage sprintf
#http://www.perlmonks.org/?node_id=20519

#my $inf = Math::BigFloat->binf();
#my $n1 = new Math::BigFloat '123.456E-2';
#my $n2 = new Math::BigFloat '123.456E-3';
#my $n3 = new Math::BigFloat '123.457E-3';
#my $is = $i -> bsstr();
#print $n1->bcmp($n2),"\n";
#print $n1->bcmp($n3),"\n";
#print $n2->bcmp($n3),"\n";
#print $n2->bcmp($inf),"\n";

################################################################################
#### Test numbers
################################################################################
#my $numberspice=qr/(?:[+-]?\d+(?:\.\d+)?(?:meg|[afgnmpu]|e[+-]?\d+)?)|(?:[+-]?\.\d+(?:meg|[afgnmpu]|e[+-]?\d+)?)/i; #A compléter avec les exposants - Done
#my @test=qw(0 1 0.1 .05 -1.5 50.00006 -10 150n 200f 1e-05 150E6 -10e-6);
#print "Base table\n";
#print $_," " foreach @test;
#print "\nResult grab\n";
#foreach (@test) {
  #print $_,"\t",$1,"\n"if /($numberspice)/;
#}

## Validé

################################################################################
#### Test R/W file
################################################################################
## Fonction génériquen de sub quesion/réponse
#sub stdin_answer {
  #my @in = @_ ; 
  #my $question = shift @in ; map ( {tr/A-Z/a-z/} @in );#Si case insensitive
  #my %answer;
  #my $g_answer;
  #print "$question\n";
  #foreach (@in) { $answer{$_}++; }
  #$g_answer = <STDIN>; chomp $g_answer;
  #$g_answer =~ tr/A-Z/a-z/;
  #while ( !exists ( $answer{$g_answer} ) ) {
    #print "Wrong answer ; possible choices : @in\n$question\n";
    #$g_answer = <STDIN>; chomp $g_answer;
    #$g_answer =~ tr/A-Z/a-z/;
  #}
  #return $g_answer;
#}

#my $path=`pwd`; chomp $path; $path .="/" ;

#print $path,"\n";
#opendir (PATH, $path) or die $!;

#sub outputfile { # prend en parametre un nom de fichier pour écriture
## prend en parametre un nom de fichier pour écriture
## vérifie s'il existe et demande confirmation d'overwrite
## le crée sinon
## retourne le filehandle
## usage : outputfile("nom_du_fichier")
  #my $_outputfile;
  #my $_outputfile_filehandle;
  #($_outputfile)=@_;
  #my $_other_outputfile=$_outputfile;
  #if (!(-f $_outputfile)) {
    #system ( "touch" , $path.$_outputfile) ;
    #open ($_outputfile_filehandle, ">$_outputfile") or die ("Open : $!");
  #} else {
    #my $choice = stdin_answer ("le fichier existe déjà remplacer ?",'Yes','No');
    #if ($choice eq "yes") {
      #open ($_outputfile_filehandle, ">$_outputfile") or die ("Open : $!") ;
      #} else {
        #while ($_other_outputfile eq $_outputfile) { print "Select new name :\n" ; $_other_outputfile = <STDIN> ; chomp $_other_outputfile ;}
        #system ( "touch" , $path.$_other_outputfile) ;
        #open ($_outputfile_filehandle, ">$_outputfile") or die ("Open : $!");
      #}
  #}
  #return $_outputfile_filehandle ;
#} # End sub outputfile ... manque le return

#outputfile("toto");
## Validé ...

################################################################################
#### Test Question réponse avec réponse multiple ?
################################################################################

#sub doublons_grep {
### Fonction d'élimination des doublons dans un tableau
### Usage : @tableau_de_retour = doublons_grep (\@tableau_à_traiter);
  #my ($ref_tabeau) = @_;
  #my %hash_sans_doublon;
  #return grep { !$hash_sans_doublon{$_}++ } @{$ref_tabeau};
#}

#sub stdin_answer_mult {
### Fonction question avec un range de réponses ; réponse multiple retournée sous forme de tableau ; Elimination des doublons
### Retourne un résultat s'il en trouve au moins un et élimine les autres. Case sensitive
### Usage : @réponse_de_retour = stdin_answer_mult ('Question', @liste_de_réponses_possible)n
  #my @in = @_ ; 
  #my $question = shift @in ;
  #my %answer;
  #my @g_answer;
  #print "$question\n";
  #foreach (@in) { $answer{$_}++ ; }
  #@g_answer = split /\s+/, <STDIN>;
  #@g_answer = doublons_grep(\@g_answer);
  #@g_answer = grep { $answer{$_} } @g_answer;
  #while(@g_answer==0) {
    #print "Answer is not in the possible range ; choices : @in\n$question\n";
    #@g_answer = split /\s+/, <STDIN>;
    #@g_answer = doublons_grep(\@g_answer);
    #@g_answer = grep { $answer{$_} } @g_answer;
  #}
  #return @g_answer;
#} # End stdin_answer_mult sub

#my @answerlist=('réponse1','réponse2','réponse3','etc');
#my @choice = ('Quelle est la réponse',@answerlist);
#my @result = stdin_answer_mult (@choice);
#print @result;

## Validé

################################################################################
#### tout un fichier en lowercase
################################################################################
## sous vim n ou N en selection visuelle
##perl -pe '$_= lc($_)' input.txt > output.txt

