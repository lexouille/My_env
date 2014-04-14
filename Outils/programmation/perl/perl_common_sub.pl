
sub build_tree {
use File::Find ;
use File::Path ;
## Construction d'arborescance.
## voir ici : http://www.perlmonks.org/?node_id=63473
  my $node = $_[0] = {};
  my @s;
  find( sub {
    $node = (pop @s)->[1] while @s and $File::Find::dir ne $s[-1][0] ;
    return $node->{$_} = -s if -f;
    push @s, [ $File::Find::name, $node ];
    $node = $node->{$_} = {};
  }, $_[1]);
  $_[0]{$_[1]} = delete $_[0]{'.'};
}

sub doublons_grep {
## Fonction suppression des doublons dans un hash. Retourne les clés dans l'ordre.
## usage : @tableau_sans_doublons = doublons_grep (\@tableau_avec_doublons?);
  my ($ref_tabeau) = @_;
  my %hash_sans_doublon;
  return grep { !$hash_sans_doublon{$_}++ } @{$ref_tabeau};
}

## uniq on array
push(@EXPORT,'uniq') ; ## ?
sub uniq {
  my @ret=() ;
  while ( my $item = shift @_ ) { push(@ret,$item) unless grep {/^\Q$item/} @ret ; }
  return @ret ;
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

sub stdin_answer_mult {
## Fonction question avec un range de réponses ; réponse multiple retournée sous forme de tableau ; Elimination des doublons
## Retourne un résultat s'il en trouve au moins un et élimine les autres. Case sensitive ou insensitive
## Usage : @réponse_de_retour = stdin_answer_mult ('tr/ntr', 'Question', @liste_de_réponses_possible)
  my @in = @_ ; 
  my $tr = shift @in ; 
  my $question = shift @in ; map ( {tr/A-Z/a-z/} @in ) if ($tr eq "tr") ; ## Si case insensitive on lowercase toutes les réponses possibles
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

