package MMB::IO;

use strict;
use warnings;
use YAML::Tiny;

#############################################################
# Прочитать таблицу из файла в массив
# Формат таблицы: <номер> <поля разделенные пробелами>
# Поля разделены пробелами, '-' - пустое поле, '?' - неопределенное поле
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
      if ($d[$i] eq '?'){
        delete ${$data->[$n]}{$fields[$i]};
        next;
      }
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
        if exists ${${$data->[$n]}{comm_p}}[$u-1];
      ${${$data->[$n]}{comm_p}}[$u-1] = $c;
    }
  }
  close IN;
}








# Перетащить из одного хэша в другой только нужные поля.
# Если $define то неопределенные поля заменяются на ""
# ????
#sub get_table{
#  my $i_data = shift; 
#  my $o_data = shift;
#  my $define = shift;
#  foreach(@_){
#    if ((!exists($i_data->{$_}) || !defined($i_data->{$_})) && $define){
#      $o_data->{$_} = '';
#    } else {
#      $o_data->{$_} = $i_data->{$_};
#    }
#  }
#}


# Проверить на определенность поля в заданном хэше
sub test_def{
  my $data = shift;
  foreach (@_){
    return 0 if !defined $data->{$_};
  }
  return 1;
}

# Проверить на совпадения поля в заданном хэше
# Неопределенные поля пропускаются
sub test_eq{
  my $data = shift;
  my $v;
  foreach (@_){
    next if (!exists $data->{$_}) || (!defined $data->{$_});
    if (defined $v){
      return 0 if ($v ne $data->{$_});
    } else {$v = $data->{$_}}
  }
  return 1;
}

# Сравнить число участников в регистрации с данными по активным точкам.
# Если есть комментарии о сходе участников - то это число может уменьшаться...
# test_people(<ссылка на хэш данных> <список полей с числом участников>)
sub test_people{
  my $data   = shift;

  die "test_people: no people\n"
    if !defined ($data->{people});

  # число людей
  my $u = $#{$data->{people}}+1;
  my $s = 0; # о скольких сходах сказано в комментариях

  if (defined ($data->{comm_p})){
    foreach (@{$data->{comm_p}}){
      next if !defined;
      $s++ if (/сош/) || (/сх/);
    }
  }

  if (defined ($data->{comm})) {
    $s=$u if ($data->{comm} =~ /сош/) || ($data->{comm} =~ /сх/);
  }

  foreach (@_){
    next unless exists ($data->{$_});
    return 0 if ($data->{$_} > $u); # участников стало больше!
    return 0 if ($u - $data->{$_} > $s); # число участников уменьшилось более чем на $s
    $s -= $u - $data->{$_}; # сколько еще могут сойти
    $u = $data->{$_};       # новое число участников
  }
  return 1;
}

1;