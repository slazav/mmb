package MMB::Res;

use strict;
use warnings;

#############################################################

sub tconv{
  my $t = shift;
  my $t0 = shift;
  return '' if $t eq '-';
  return '' if $t =~ /^\s*$/;
  die "bad time format: $t\n" if $t!~/(\d+):(\d\d)/;
  $t = $1*60 + $2;
  die "bad time format: $t\n" if $t0!~/(\d+):(\d\d)/;
  $t0 = $1*60 + $2;
  $t+=24*60 if $t < $t0;
  return $t;
}

sub make_places{
  my $data  = shift;
  my $dist  = shift;
  my $rf    = shift;
  my $pf    = shift;

  # Сколько мест с одинаковым временем,
  # Какие места указывать для данного времени
  my (%rc, %rm);
  for (@{$data}){
    next if !defined $_;
    next if defined($dist) && (!exists($_->{dist}) || ($_->{dist} ne $dist));
    $rc{$_->{$rf}}++ if exists $_->{$rf};
  }
  my $m=1;
  foreach (sort {$a<=>$b} keys %rc){
    $m += $rc{$_};
    if ($rc{$_}==1) {$rm{$_} = $m-1;}
    else {$rm{$_} = ($m-$rc{$_})."-".($m-1);}
  }

  for (@{$data}){
    next if !defined $_;
    next if defined($dist) && (!exists($_->{dist}) || ($_->{dist} ne $dist));
    $_->{$pf} = $rm{$_->{$rf}} if exists $_->{$rf};
  }

}

#############################################################

sub m2t{
  return undef if (!defined($_[0]))||($_[0] !~ /^\d+$/); 
  return sprintf "%d:%02d", $_[0]/60, $_[0]%60;
}

#############################################################
#our $mmb_count='
#<!--Rating@Mail.ru COUNTEr--><a target=_top
#href="http://top.mail.ru/jump?from=991443"><img
#src="http://d0.c2.bf.a0.top.list.ru/counter?id=991443;t=49"
#border=0 height=31 width=88
#alt="Рейтинг@Mail.ru"/></a><!--/COUNTER-->
#';

1;