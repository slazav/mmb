package res;

use strict;
use warnings;
use YAML::Tiny;

#############################################################
# Прочитать таблицу из файла в массив
# Формат таблицы: <номер> <поля разделенные пробелами>
# Поля разделены пробелами, '-' - пустое поле
# Строка с '#' в начале и пустые строки игнорируются
# Лишние поля отсекаются, недостающие поля не заполняются

sub read_table{
  my $file   = shift;      # файла
  my $data   = shift;      # ссылка на массив
  my @fields = @_;         # ссылка на массив с названиями полей

  open IN, $file or die "Can't open $file\n";
  warn "reading $file (@fields)\n";

  foreach(<IN>){
    next if (/^#/);     # комментарии
    next if (/^\s*$/);  # пусто
    my @d = split;
    shift @d if !defined($d[0]); # если в начале были пробелы
    next if $#d==-1;
    die " - строка не начинается с номера ($file:$.)!" if $d[0]!~/\d+/;
    my $n = shift @d;
    ${$data->[$n]}{'N'}=$n;

    for( my $i = 0; $i <= $#fields; $i++){
      next if $i > $#d;
      warn " - повторное чтение поля $fields[$i] для номера $n\n"
        if exists ${$data->[$n]}{$fields[$i]};
      ${$data->[$n]}{$fields[$i]} = ($d[$i] eq '-')? '' : $d[$i];
    }
  }
  close IN;
}

# читаем yaml-файл, перетаскиваем из него нужные поля
sub read_yaml{
  my $file   = shift;      # файла
  my $data   = shift;      # ссылка на массив
  my @fields = @_;         # ссылка на массив с названиями полей

  my @d = YAML::Tiny::LoadFile($file);
  warn "reading yaml-file $file (@fields)\n";

  foreach my $d (@d){
    die "Bad yaml file $file\n" if (!exists $d->{N}) || (!defined $d->{N});
    my $n=$d->{N};
    ${$data->[$n]}{'N'}=$n;

    foreach my $f (@fields){
      next if (!exists $d->{$f}) || (!defined $d->{$f});
      warn "Повторное чтение поля $f для номера $n\n"
        if exists ${$data->[$n]}{$f};
      ${$data->[$n]}{$f} = ($d->{$f} eq '-')? '' : $d->{$f};
    }
  }
}

# чтение комментариев к командам и людям
sub read_comm{
  my $file   = shift;      # файла
  my $data   = shift;      # ссылка на массив

  open IN, $file or die "Can't open comm $file\n";
  warn "reading comments from $file\n";

  foreach(<IN>){
    next if (/^#/);     # комментарии
    next if (/^\s*$/);  # пусто
    warn " - bad format: $_\n" 
      unless (/^\s*(\d+)\s+(\S+)\s+(.+)$/);

    my ($n, $u, $c) = ($1, $2, $3);

    die " - комментарий к несуществующей команде $n"
      if (! defined $data->[$n]);
    if ($u eq '-'){
      warn " - повторное чтение поля comm для номера $n\n"
        if exists ${$data->[$n]}{comm};
      ${$data->[$n]}{comm} = $c;
    }
    else{
      die " - неправильный номер участника $n - $u\n"
        unless $u =~ /\d+/;
      die " - комментарий к несуществующему участнику $n - $u\n"
        unless exists(${${$data->[$n]}{people}}[$u-1]);
      warn " - повторное чтение поля comm для участника $n - $u\n"
        if exists ${${$data->[$n]}{comm_u}}[$u-1];
      ${${$data->[$n]}{comm_u}}[$u-1] = $c;
    }
  }
  close IN;
}








# Перетащить из одного хэша в другой только нужные поля.
# Если $define то неопределенные поля заменяются на ""
sub get_table{
  my $i_data = shift; 
  my $o_data = shift;
  my $define = shift;
  foreach(@_){
    if ((!exists($i_data->{$_}) || !defined($i_data->{$_})) && $define){
      $o_data->{$_} = '';
    } else {
      $o_data->{$_} = $i_data->{$_};
    }
  }
}

# проверить на совпадения поля
sub table_test_eq{
  my $data = shift;

  foreach my $d (@{$data}){
    my @d1;
    foreach (@_){
      if (exists $d->{$_}) {
        push @d1, $d->{$_};
      }
      else {
        push @d1, '';
      }
    }
  }
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