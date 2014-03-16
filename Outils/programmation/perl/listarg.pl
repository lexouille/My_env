#!/usr/bin/perl -w

use strict;
use warnings;
use feature qw/switch/; #Pour given ... when

my $process_args;
my @corner_mos=(0);
my @corner_bip=(0);
my @corner_res=(0);
my @corner_cap=(0);
my @process_list;

sub doublons_grep {
  my ($ref_tabeau) = @_;

  my %hash_sans_doublon;

  return grep { !$hash_sans_doublon{$_}++ } @{$ref_tabeau};
}

my ($arg,@args);

sub f_help()
{
  print ("************************************************************\n");
  print ("Usage fonction sim_eldo : sim_eldo [args]\n");
  print ("************************************************************\n\n");
  print ("Arguments :\n\n");
  print ("  -help   : aide\n\n");
  print ("  -check  : netlist et verification syntaxe eldo\n\n");
  print ("  -param  : affichage des paramètres et des testbenchs dans la netlist\n\n");
  print ("  -bkp    : simu avec sauvegarde du fichier carac -> carac.bkp\n\n");# ?
  f_process_help();
  f_voltage_help();
  f_temp_help();
  f_pvt_help();
  f_mc_help();
  f_param_help();
  f_tbench_help();
  exit(1);
}

sub f_process_help()
{
  print ("  process : choix des process des devices actifs de la techno\n");
  print ("    usage : process=typ/fs/sf/ss/ff/btyp/bmin/bmax/rtyp/rmin/rmax/ctyp/cmin/cmax\n");
  print ("            seul ou process=typ,fs,sf ...\n\n");
}

sub f_voltage_help()
{
  print ("  voltage : choix des domaines de tension\n");
  print ("    usage : voltage=vnom/vmin/vmax/v1min/v1max/v2min/v2max\n");
  print ("            seul ou voltage=vnom,vmin,v2max ...\n\n");
}

sub f_temp_help()
{
  print ("  temp    : choix de la temperature\n");
  print ("    usage : temp=25/<un_decimal>\n");
  print ("            seul ou temp=0,25,50\n\n");
}

sub f_pvt_help()
{
  print ("  pvt     : routine Process Voltage Temperature\n");
  print ("    usage : pvt=PVT/PV1T/PV2T ... Seul ou multiple\n\n");
}

sub f_mc_help()
{
  print ("  mc      : Simulation Monte-Carlo\n");
  print ("    usage : mc=lot,dev,devx,nbruns,nbbins\n\n");
}

sub f_param_help()
{
  print ("  param   : choix des autres paramètres définis\n");
  print ("    usage : param=nom_param=list=val1,val2,val3,...\n");
  print ("         ou param=nom_param=step=valstart,valstop,incr\n\n");
}

sub f_tbench_help()
{
  print ("  tbench  : choix des testbenchs à lancer\n");
  print ("    usage : tbench=tbench1/tbench2 ... Seul ou multiple\n\n");
}

sub f_check()
{
  exit(1);
}

sub f_param()
{
  exit(1);
}

sub f_bkp()
{
  exit(1);
}

sub f_process
{
  $process_args=shift;
  @corner_mos=(0);
  @corner_bip=(0);
  @corner_res=(0);
  @corner_cap=(0);
  @process_list=split( /=|,/ , $process_args );
  shift(@process_list);
  foreach my $sub_arg (@process_list)
  {
    given ( $sub_arg )
    {
      when (/^typ/) {$corner_mos[0]++;push @corner_mos,$sub_arg}
      when (/fs/) {$corner_mos[0]++;push @corner_mos,$sub_arg}
      when (/ff/) {$corner_mos[0]++;push @corner_mos,$sub_arg}
      when (/sf/) {$corner_mos[0]++;push @corner_mos,$sub_arg}
      when (/ss/) {$corner_mos[0]++;push @corner_mos,$sub_arg}
      when (/btyp/) {$corner_bip[0]++;push @corner_bip,$sub_arg}
      when (/bmin/) {$corner_bip[0]++;push @corner_bip,$sub_arg}
      when (/bmax/) {$corner_bip[0]++;push @corner_bip,$sub_arg}
      when (/rtyp/) {$corner_res[0]++;push @corner_res,$sub_arg}
      when (/rmin/) {$corner_res[0]++;push @corner_res,$sub_arg}
      when (/rmax/) {$corner_res[0]++;push @corner_res,$sub_arg}
      when (/ctyp/) {$corner_cap[0]++;push @corner_cap,$sub_arg}
      when (/cmin/) {$corner_cap[0]++;push @corner_cap,$sub_arg}
      when (/cmax/) {$corner_cap[0]++;push @corner_cap,$sub_arg}
      default 
      {
        print ( "Mauvaise syntaxe d'argument : check syntax / -help option\n" ) ;
        f_process_help();
        exit(1)
      } 
    }
  }
  if ( $corner_mos[0] == 0 )
  {
    print ( "Pas d'entrée pour le corner MOS ; simulation en typique\n" ) ;
    $corner_mos[0]++;push @corner_mos,"typ";
  }
  if ( $corner_bip[0] == 0 )
  {
    print ( "Pas d'entrée pour le corner BIP ; simulation en typique\n" ) ;
    $corner_bip[0]++;push @corner_bip,"btyp";
  }
  if ( $corner_res[0] == 0 )
  {
    print ( "Pas d'entrée pour le corner MOS ; simulation en typique\n" ) ;
    $corner_res[0]++;push @corner_res,"rtyp";
  }
  if ( $corner_cap[0] == 0 )
  {
    print ( "Pas d'entrée pour le corner MOS ; simulation en typique\n" ) ;
    $corner_cap[0]++;push @corner_cap,"ctyp";
  }
  shift (@corner_mos); my @corner_mos_sd=doublons_grep(\@corner_mos);
  shift (@corner_bip); my @corner_bip_sd=doublons_grep(\@corner_bip);
  shift (@corner_res); my @corner_res_sd=doublons_grep(\@corner_res);
  shift (@corner_cap); my @corner_cap_sd=doublons_grep(\@corner_cap);
  my @corner_tech=(@corner_mos_sd,@corner_bip_sd,@corner_res_sd,@corner_cap_sd);
  print ( "liste corner_tech : @corner_tech\n" );
  #print ( "liste cornermos : @corner_mos\n" );
  #print ( "liste cornerbip : @corner_bip\n" );
  #print ( "liste cornerres : @corner_res\n" );
  #print ( "liste cornercap : @corner_cap\n" );
}

sub f_voltage
{
  my $voltage_args=shift;
  my @voltage_list=split( /=|,/ , $voltage_args );
  shift(@voltage_list);
  my @corner_voltage=();
  foreach my $sub_arg (@voltage_list) {
    if ($sub_arg =~ m/vnom|vmin|vmax|v1min|v1max|v2min|v2max/) {
      push @corner_voltage,$sub_arg ;
    } else {
      print ( "Mauvaise syntaxe d'argument : check syntax / -help option\n" ) ;
      f_voltage_help();
      exit(1)
    }
  }
  my @corner_voltage_sd=doublons_grep(\@corner_voltage);
  print ( "liste voltage : @corner_voltage_sd\n" );
}

sub f_temp
{
  my $temp_args=shift;
  my @temp_list=split( /=|,/ , $temp_args );
  shift(@temp_list);
  my @corner_temp=();
  #Debug
  #print ( "Entrée dans la fonction temp\n" ) ;
  foreach my $sub_arg (@temp_list)
  {
    given ( $sub_arg )
    {
      when (/\d/) {push @corner_temp,$sub_arg}
      default 
      {
        print ( "Mauvaise syntaxe d'argument : check syntax / -help option\n" ) ;
        f_temp_help();
        exit(1)
      } 
    }
  }
  my @corner_temp_sd=doublons_grep(\@corner_temp);
  print ( "liste temp : @corner_temp_sd\n" );
}

sub f_pvt
{
  my $pvt_args=shift;
  my @pvt_list=split( /=|,/ , $pvt_args );
  shift(@pvt_list);
  my @corner_pvt=();
  #Debug
  #print ( "Entrée dans la fonction pvt\n" ) ;
  foreach my $sub_arg (@pvt_list)
  {
    given ( $sub_arg )
    {
      when (/PVT/) {push @corner_pvt,$sub_arg}
      when (/PV1T/) {push @corner_pvt,$sub_arg}
      when (/PV2T/) {push @corner_pvt,$sub_arg}
      default 
      {
        print ( "Mauvaise syntaxe d'argument : check syntax / -help option\n" ) ;
        f_pvt_help();
        exit(1)
      } 
    }
  }
  my @corner_pvt_sd=doublons_grep(\@corner_pvt);
  print ( "liste pvt : @corner_pvt_sd\n" );
}

sub f_mc
{
  my $mc_args=shift;
  my @mc_type=(0);
  my ($mc_run,$mc_bin);
  my @mc_list=split( /=|,/ , $mc_args );
  shift(@mc_list);
  foreach my $sub_arg (@mc_list)
  {
    given ( $sub_arg )
    {
      when (/lot/) {$mc_type[0]++;push @mc_type,$sub_arg}
      when (/dev/) {$mc_type[0]++;push @mc_type,$sub_arg}
      when (/devx/) {$mc_type[0]++;push @mc_type,$sub_arg}
      when (/nbrun/) {$mc_run=$sub_arg}
      when (/nbbin/) {$mc_bin=$sub_arg}
      default 
      {
        print ( "Mauvaise syntaxe d'argument : check syntax / -help option\n" ) ;
        f_mc_help();
        exit(1)
      } 
    }
  }
  if ( $mc_type[0] == 0 )
  {
    print ( "Pas d'entrée pour le type de Monte Carlo : check syntax / -help option\n" ) ;
    exit(1)
  }
  if ( $mc_type[0] > 1 )
  {
    print ( "Un seul type de Monte Carlo : check syntax / -help option\n" ) ;
    exit(1)
  }
  my @mc_param=($mc_type[2],$mc_run,$mc_bin);
  print ( "liste paramètres MC : @mc_param\n" );
}

sub f_getargs
{
  my $refargs=shift;
  foreach my $sub_arg ( @{$refargs} )
  {
    if ( !($sub_arg =~ m/^(process|voltage|temp|pvt|param|tbench|mc)/) )
    {
      print ( "Mauvaise syntaxe d'argument : check syntax / -help option\n" ) ;
      exit(1) ;
    }
    f_process($sub_arg) if ( $sub_arg=~ m/^process/ ) ;
    f_voltage($sub_arg) if ( $sub_arg =~ m/^voltage/ ) ;
    f_temp($sub_arg) if ( $sub_arg =~ m/^temp/ ) ;
    f_pvt($sub_arg) if ( $sub_arg =~ m/^pvt/ ) ;
    f_mc($sub_arg) if ( $sub_arg =~ m/^mc/ ) ;
  }
}

#Main function start

print ("\n");

if ( ! @ARGV)
#if ( !defined @ARGV) anciennement, mais mis à jour avec version et maintenant plus besoin de defined
{
  print ( "\nSimulation avec paramètres de base du fichier carac.inc\n" ) ;
  print ( "Tous testbenchs, sweep paramétriques et alters utilisés\n" ) ;
}
else
{
  foreach $arg (@ARGV)
  {
    print ( "$arg\n" ) ;
    f_help() if ( $arg =~ m/-help/ ) ;
    f_check() if ( $arg =~ m/-check/ ) ;
    f_param() if ( $arg =~ m/-param/ ) ;
    f_bkp() if ( $arg =~ m/-bkp/ ) ;
    push @args, "$arg";
  }
  f_getargs(\@args) ;
}

print("\n");

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

