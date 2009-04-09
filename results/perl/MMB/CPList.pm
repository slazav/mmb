package MMB::CPList;

use strict;
use warnings;

#############################################################

# работа со списками КП
# номера могут быть следующего вида: a,b,c,d,e,a1,a2,a3,a4,1,2,3,4,5
# склеиваться они должны в такие группы: a-e,a1-a4,1-5

# значения для сортировки 1,2,3,4,5,a,a0,a1,a2,a3,b,b1,b2...
sub a2i{
  my $x = shift;
  if ($x =~ /^\d+$/) {return $x;}
  if ($x =~ /^([a-zA-Z])(\d+)$/) {return 1000*ord(lc($1))+$2;}
  if ($x =~ /^([a-zA-Z])$/)      {return 1000*ord(lc($1))-1;}
  die "unknown value $_\n";
}
sub i2a{
  my $x = shift;
  if ((($x+1)%1000) == 0) {return chr(($x+1)/1000);}
  if ($x>999) {return chr($x/1000).($x%1000);}
  return $x;
}
# увеличение номера: 1->2  a->b  a1->a2
sub iinc{
  my $x = shift;
  if (($x+1)%1000 ==0) {return $x+1000;}
  return $x+1;
}
sub ainc{
  return i2a(iinc(a2i(shift)));
}

# можно ли два значения объединить в группу
sub igtest{
  my $x = shift;
  my $y = shift;

  if ((($x+1)%1000==0) && (($y+1)%1000==0) && (($y+1)/1000 > ($x+1)/1000)){ return 1; }
  if ((($x+1)%1000!=0) && (($y+1)%1000!=0) && ($y > $x) && ($y-$x < 1000)){ return 1; }
  return 0;
}
sub agtest{
  return igtest(a2i($_[0]), a2i($_[1]));
}
###################

# разбиение строки вида A,b,10-25,8,23 в список:
sub unpack_list{
  my $l=lc(shift);
  my @ret;
  my $e;
  return () if $l=~/^\s*$/;

  while(1){
    if (($l=~s/^([0-9a-z]+),//)==1){ 
      push @ret, $1;
    }
    elsif (($l=~s/^([0-9a-z]+)-([0-9a-z]+),//)==1){
      die "unpack_list: bad group $1-$2\n" unless agtest($1, $2);
      for (my $cp = $1; $cp ne $2; $cp=ainc($cp)){
        push @ret, $cp;
      }
      push @ret, $2;
    } else {last;}
  }

  if ($l=~/^([0-9a-z]+)$/){
    push @ret, $1;
  } elsif ($l=~/^([0-9a-z]+)-([0-9a-z]+)$/){
    die "bad group $1-$2\n" unless agtest($1, $2);
    for (my $cp = $1; $cp ne $2; $cp=ainc($cp)){
      push @ret, $cp;
    }
    push @ret, $2;
  }
  else {die "unpack_list: bad list $_[0]\n";}
  return @ret;
}

# сборка списка КП в строку с дефисами
sub pack_list{
  my @list = sort{a2i($a)<=>a2i($b)} (@_);

#print "list: ", join " ", @list, "\n";
#foreach(@list){
#  print a2i($_), " ";
#}
#print "\n";

  my $ret;
  return '' if $#list==-1;
  my $prev = a2i(shift @list);
  my $spacer=',';
  $ret = i2a($prev);

  foreach (@list){

    if (a2i($_) == $prev){
      warn "pack_list: duplicated entries: ", join(" ",@list), "\n";
    } elsif (a2i($_) == iinc($prev)){
      $spacer='-';
      $prev = a2i($_);
    } else {
      if ($spacer eq '-'){ 
        $ret.=$spacer.i2a($prev).','.$_;
        $spacer=',';
        $prev = a2i($_);
      } else {
        $prev=a2i($_);
        $ret.=$spacer.i2a($prev);
      }
    }
  }
  if ($spacer eq '-') {$ret.=$spacer.i2a($prev);}
  return $ret;
}

sub repack_list{
  return pack_list(unpack_list($_[0]));
}

# вырезать из списка 1 все значения, не встречающиеся в списке 2
sub cut{
  my @l1 = unpack_list(shift);
  my @l2 = unpack_list(shift);
  my @ret;
  foreach my $v1 (@l1){
    my $found=0;
    foreach my $v2 (@l2){
      if ($v1 eq $v2) {$found=1; last;}
    }
    push @ret, $v1 if ($found);
  }
  return pack_list(@ret);
}

#############################################################
# Подсчет штрафа за невзятые КП
# Получаем список невзятых КП и ссылку на таблицу штрафов: список КП -> штраф
sub cp_pen{
  my @kp  = unpack_list(shift);
  my $tab = shift;

  my %tab1;
  foreach (keys %{$tab}){
    my @k = unpack_list($_);
    my $p = $tab->{$_};
    foreach (@k){
      warn "cp_pen: duplicated entrie $_ in penalty list\n" if exists $tab1{$_};
      $tab1{$_} = $p;
    }
  }
  my $res=0;
  foreach (@kp){
    die "cp_pen: unknown cp $_" if !exists($tab1{$_});
    $res+=$tab1{$_};
  }
  return $res;
}
#############################################################

1;