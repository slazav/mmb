package res;

use strict;
use warnings;

#############################################################
sub read_tbl{
  my $file = shift;      # прочитать из файла
  my $data = shift;      # в массив
  my $w    = shift;      # w полей на команду

  # поля разделены пробелами, '-' - пустое поле
  # в @data все записи должны содержать одно число полей

  my $w0 = 0;
  $w0 = $#{$data->[0]}+1  if defined ${$data->[0]}[0];

  open IN, $file or die "can't find $file\n";

  warn "reading $file\n";
  foreach(<IN>){
    next if (/^#/);
    my @d = split;
    shift @d if !defined($d[0]);
    next if $#d==-1;
    next if $d[0]!~/\d+/;
    my $n = shift @d;
    for (my $i = 0; $i<$w; $i++){
      die "поле ". ($i+$w0). " для команды $n определено дважды\n"
        if defined(${$data->[$n]}[$i+$w0]);
      ${$data->[$n]}[$i+$w0] = $d[$i];
    }
  }
  for (my $n = 0; $n<=$#{$data}; $n++){
    for (my $i = 0; $i<=$w+$w0-1; $i++){
      ${$data->[$n]}[$i] = '' if (!defined(${$data->[$n]}[$i]))||
                               (${$data->[$n]}[$i] eq '-');
    }
  }
  close IN;
}
#############################################################

sub time_conv{
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
#############################################################

# разбиение строки вида A,b,10-25,8,23 в список:
sub split_list{
  my $l=$_[0];
  my @ret;
  my $e;
  return () if $l=~/^\s*$/;
  do{
    $e=0;
    if (($l=~s/^([0-9a-zA-Z]+),//)==1){ 
      push @ret, $1;
      $e=1;
    }
    if (($l=~s/^([0-9]+)-([0-9]+),//)==1){
      my ($a, $b) = ($1, $2);
      ($a, $b) = ($2, $1) if $2<$1;
      foreach ($a..$b){
        push @ret, $_;
      }
      $e=1;
    }
  } while ($e!=0);
  if ($l=~/^([0-9a-zA-Z]+)$/){
    push @ret, $1;
  } elsif ($l=~/^([0-9]+)-([0-9]+)$/){
    my ($a, $b) = ($1, $2);
    ($a, $b) = ($2, $1) if $2<$1;
    foreach ($a..$b){
      push @ret, $_;
    }
  }
  else {print STDERR "split_list: bad list $_[0]\n";}
  return @ret;
}

sub kp_conv{
  my @kp = split_list(shift);
  my %vals = %{shift()};
  my $res=0;
  my @kp1;
  foreach (@kp){
    if (/(\d+)-(\d+)/){
      if ($1>$2) {next;}
      for (my $i=$1; $i<=$2; $i++) {push(@kp1, $i);}
    }
    else {push(@kp1, $_);}
  }
  foreach (@kp1){
    die "unknown KP $_" if !exists($vals{$_});
    $res+=$vals{$_};
  }
  return $res;
}
#############################################################

sub m2t{
  return '' if (!defined($_[0]))||($_[0] eq '');
  return sprintf "%3d:%02d", $_[0]/60, $_[0]%60;
}

#############################################################
our $mmb_count='
<!--Rating@Mail.ru COUNTEr--><a target=_top
href="http://top.mail.ru/jump?from=991443"><img
src="http://d0.c2.bf.a0.top.list.ru/counter?id=991443;t=49"
border=0 height=31 width=88
alt="Рейтинг@Mail.ru"/></a><!--/COUNTER-->
';

1;