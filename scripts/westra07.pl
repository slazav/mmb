#!/usr/bin/perl -w
use strict;
use CGI   ':standard';
use Fcntl ':flock';
use Digest::MD5 'md5_hex';
#use Mail::Send;

## файл со всеми данными.
## должен быть недоступен по http!
my $dfile = '/home/slazav/w07.dat'; 

## адрес скрипта
#my $script='http://localhost/mb/reg05l.pl';
my $script='http://slazav.mccme.ru/perl/westra07.pl';

my @data; # массив данных обо всех командах

my @fields = ('md5', 'name', 'mail');

print "Content-Type: text/html; charset=koi8-r\n\n";

my $namesreg = '^[\d\w абвгдеёжзийклмнопрстуфхцчшщъыьэюя'.
                      'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ@\.\,_"()-]*$';

##########################################
# 4 варианта вызова:
# - без параметров           type=''
# - добавление новой команды type='reg'
# - запрос на редактирование type='red1'
# - редактирование           type='red2'
# - отправка пароля          type='pass'

my $type = defined(param('type'))? param('type'):'';

if ($type eq 'reg'){
  flock(DAT, LOCK_EX);
  read_data();
  reg();
  write_data();
  flock(DAT, LOCK_UN);
  exit;
}
elsif ($type eq 'red1'){
  read_data();
  red1();
  exit;
}
elsif ($type eq 'red2'){
  flock(DAT, LOCK_EX);
  read_data();
  red2();
  write_data();
  flock(DAT, LOCK_UN);
  exit;
}
if ($type eq 'pass'){
  flock(DAT, LOCK_EX);
  read_data();
  chpass();
  write_data();
  flock(DAT, LOCK_UN);
  exit;
}
else {
  read_data();
  print_start_page();
  exit;
}

##########################################

sub print_html{
  my $msg  = shift;
  my $msg1 = shift;
  print qq*
  <html>
  <head><title>$msg</title></head>
  <body> <h3>$msg</h3> 
  $msg1
  <p><a href="$script">Вернуться в начало.</a>
  </body>
  </html>
  *;
  return;
}

##########################################

sub read_data{
  if (!open(DAT, $dfile)){
    print_html("Ошибка","не могу найти файл данных!"); 
    exit();
  }

  my $n=0;
  foreach(<DAT>){
    my $l = $_;
    if ($l=~/n:\s+(.*)/) {$n=$1;}
    foreach (@fields){
      if ($l=~/$_:\s+(.*)/) {$data[$n]->{$_}=$1;}
    }
  }
  close(DAT);
  if ($#data == -1) {$#data=0;}
}

sub write_data{
  if (!open(DAT, "> $dfile")){
    print_html("Ошибка", "не могу открыть файл данных для записи!");
    exit();
  }

  my $n;
  for ($n=0; $n<= $#data; $n++){
    next if (!defined($data[$n]->{name}));
    print DAT "n:\t$n\n";
    foreach (@fields){
      print DAT "$_:\t$data[$n]->{$_}\n";
    }
    print DAT "\n";
  }
  close(DAT);
}
##########################################
sub print_start_page{
  print qq* 
    <html>
    <head>
      <title>Регистрация участников</title>
      <META HTTP-EQUIV="no-cache">
    </head>
    <body>

    <h3 align=center> Ориентирование в Полушкино<br>
    1-2 декабря 2007 года</h3><hr>

    <p><table border=0 cellpadding=5><tr><td valign=top>

    <p>Регистрация участников работает до 24:00 29 ноября (четверг).

    <p>После регистрации вам будет сообщен номер и
    пароль. Запишите пароль: он понадобится, если вы захотите 
    редактировать или удалить информацию. 

    <p>Вы можете указать свой адрес (можно несколько, через запятую).
    На один из этих адресов по специальному запросу может быть
    автоматически выслан ваш пароль. Адреса не будут публиковаться в
    интернете и использоваться каким-либо другим образом. 

    </td><td valign=top width="50%" align=right>
    <h3 align=center>Зарегистрироваться</h3>
    *;

    my $data;
    foreach (@fields){$data->{$_} = '';}
    print html_rr2_form('','',$data);

    print qq*
    </td></tr>
    </table></p>
    <br>
    <br>
  *;

  print qq* 
    <hr><h3 align=center>Список зарегистрированных участников</h3>
  *;

  print qq* 
    <p><table border=1 cellspacing=0 cellpadding=5 align=center>
  *;

  my $n;
  my $nc=0;
  for ($n=0; $n<= $#data; $n++){
    next if (!defined($data[$n]));
    $nc++;
    print "<tr><td align=center>$n</td>";
    print "<td>$data[$n]->{name}</td>\n";
    print "</tr>\n";
  }
  my @endings = ('ов', '', 'а', 'а', 'а', 'ов', 'ов', 'ов', 'ов', 'ов');

  print qq*
    <tr><th>итого: </th>
    <th>$nc участник*;
    if (($nc%100>4)&&($nc%100<21)) {print 'ов';}
    else {print $endings[$nc%10];}
  print qq*</th>
    </table></td>
    <br><br>
  *;


    print qq* <hr><a name="red"></a> 
    <h3>Редактировать информацию:</h3>*; 
    print html_red1_form('','');

    print qq*
    <a name="pass"></a>
    <h3>Выслать новый пароль:</h3>
    <p>Если вы забыли свой пароль или если вы хотите поменять его,
    введите в эту форму номер вашей команды и один из из тех адресов
    электронной почты, которые вы указывали при регистрации.
    Новый пароль будет выслан вам на этот адрес. *;
    print html_pass_form('','');
    
  print qq* </body></html> *;
}

##########################################
sub reg{

  my $data;
  foreach (@fields){
    $data->{$_} = defined(param($_))? param($_):'';
  }
  my $err = chk_data(-1, $data);

  if ($err ne ''){
    print_html($err, '<p> Попробуйте еще раз:'.html_rr2_form('','',$data));
    exit();
  }

  my $pass=pass_gen();
  $data->{md5} = md5_hex($pass);

  push @data, $data;
  print_html('Регистрация завершена', html_data($#data, $pass));
}
##########################################
sub red1{

  my $n    = param('n');
  my $pass = param('pass');
  my $md5  = md5_hex($pass);
  my $err  = chk_pass($n, $md5);

  if ($err ne ''){
    print_html($err, '<p> Попробуйте еще раз:'.html_red1_form($n, $pass));
    exit();
  }
  print_html('Редактирование информации о команде', 
    html_rr2_form($n, $pass, $data[$n]));
}
##########################################
sub red2{

  my $n    = param('n');
  my $pass = param('pass');
  my $md5  = md5_hex($pass);

  my $err  = chk_pass($n, $md5);
  if ($err ne ''){
    print_html($err, '<p> Попробуйте еще раз:'.html_red1_form($n, $pass));
    exit();
  }
 
  if (param('Send') =~ /Удалить/){
     undef($data[$n]);
     print_html("Запись удалена", "");
  } else {

    my $data;
    foreach (@fields){
      $data->{$_} = defined(param($_))? param($_):'';
    }
    my $err = chk_data($n, $data);

    if ($err ne ''){
      print_html($err, '<p> Попробуйте еще раз:'.html_rr2_form($n, $pass, $data));
      exit();
    }

    $data->{md5} = $md5;
    $data[$n] = $data;
    print_html('Информация о команде исправлена', html_data($n, $pass));
  }
}

sub chpass{
  my $n    = param('n');
  my $mail = param('mail');

  my $err=chk_mail($n, $mail);
  if ($err ne ''){
    $err = '<font color="#FF0000">'.$err.'</font>';
    print_html($err, 
      qq* <p>Попробуйте еще раз!
          <p>Но помните: новый пароль будет выслан на указанный адрес,
             только если этот же адрес был введен при регистрации команды! 
      *.html_pass_form($n, $mail));
    exit();
  }

  my $pass=pass_gen();
  if (mail_pass($n, $mail, $pass)==0){
    $data[$n]->{md5} = md5_hex($pass);
    print_html('Пароль выслан на указанный адрес','');
  } else {
    print_html('Ошибка при отправке пароля!','');
    exit();
  }
}

##########################################################
sub mail_pass{

  my $n = shift;
  my $mail = shift;
  my $pass = shift;

  my $date = localtime;

  my $msg=qq*Date: $date
From: slazav\@narod.ru
To: $mail
Subject: Polushkino-2007 password
Content-Type: text/plain; charset="koi8-r"


    Вы были зарегистрированы на
    участие в ориентировании 1-2 декабря 2007 в Полушкино

    По вашему запросу ваш пароль был изменен.
    Ваш номер: $n
    Ваш новый пароль: $pass
    Используя этот пароль, вы можете менять
    информацию о команде.

    Полный список зарегистрировавшихся команд
    смотрите по адресу: $script

    По всем вопросам пишите по адресу
    slazav\@narod.ru (Слава Завьялов) 
*;
      
`echo \'$msg\' | sendmail -t`;
 return;
}

##########################################################

sub chk_pass{
  my $n   = shift;
  my $md5 = shift;
  my $err = '';
  if ($n !~ /^\d+$/) {$err = 'Номер команды должен быть натуральным числом!';}
  elsif (!defined($data[$n])) {$err = "Нет команды номер $n!";}
  elsif ($data[$n]->{md5} ne $md5) {$err = 'Неправильный пароль!';}
  $err = '<font color="#FF0000">'.$err.'</font>' if $err ne '';
  return $err;
}

sub chk_mail{
  my $n    = shift;
  my $mail = shift;
  my $err = '';

  if ($n !~ /^\d+$/) {$err = 'Номер команды должен быть натуральным числом!';}
  elsif (!defined($data[$n])) {$err = "Нет команды номер $n!";}
  elsif ($mail !~ /[a-zA-Z\._\-0-9]+@[a-zA-Z\._\-0-9]+/) 
        {$err = 'Странно выглядит ваш e-mail!';}
  elsif (" $data[$n]->{mail} " !~ /[\s,]$mail[\s,]/) 
        {$err = 'Вы не вводили такой адрес при регистрации!' ;}
  $err = '<font color="#FF0000">'.$err.'</font>' if $err ne '';
  return $err;
}

sub chk_data{
  my $n    = shift; # исключить номер из проверки на повтор имени
  my $data = shift;
  my $err='';

  if ($data->{name} !~ /$namesreg/) 
    {$err .= "Запрещенные символы в названии команды<br>\n";}
  if (($data->{name} eq '')&&($n!=-1)) {$err .= "Напишите о себе подробнее!\n" ;}

  if ($data->{mail} !~ /$namesreg/) 
    {$err .= "Запрещенные символы в контактом адресе<br>\n";}


  # проверить, нет ли уже такого участника (защита от релоада).
  if ($data->{name} ne ''){
    for (my $i = 0; $i<=$#data; $i++){
     next if ($i == $n);
      if ($data[$i]->{name} eq $data->{name}) 
      {$err .= "Участник с таким именем уже существует!<br>\n" ;}
    }
  }

  $err = '<font color="#FF0000">'.$err.'</font>' if $err ne '';
  return $err;
}


sub pass_gen{
  my $pass='';
  for (my $i=0; $i<4; $i++) {$pass.=('a'..'z', 0..9)[rand 36];}
  return $pass;
}

sub html_data{
  my $n = shift;
  my $pass = shift;

  my $F  = '<font color="#FF0000"><b>';
  my $F_ = '</b></font>';

  my $out ='';

  $out.= qq* 
    <p> Ваш номер: $F$n$F_, ваш пароль: $F$pass$F_
    <p> Участник: $F $data[$n]->{name} $F_ 
    <p> Контактный адрес: $F $data[$n]->{mail}  $F_*;
  $out.= qq*  не указан * if ('' eq $data[$n]->{"mail"});

  return $out;
}

sub html_red1_form{
  my $n    = shift;
  my $pass = shift;
  return qq*
  <p><form name="red" method="post" action="$script">
  <input name="type" type="hidden" value="red1">
  Номер:  <input name="n" type="text" maxlength="3" size="3" value="$n">
  Пароль: <input name="pass" type="text" maxlength="8" size="8" value="$pass">
  <input type="submit" value=">>">
  </form>*;
}

sub html_pass_form{
  my $n    = shift;
  my $mail = shift;
  return qq* 
  <p><form name="pass" method="post" action="$script">
  <input name="type" type="hidden" value="pass">
  Номер:  <input name="n" type="text" maxlength="3" size="3" value="$n">
  Адрес: <input name="mail" type="text" maxlength="80" size="21" value="$mail">
  <input type="submit" value=">>">
  </form>*;
}

sub html_rr2_form{
  # формы для регистрации новой команды (reg) $n==0; $pass=='';
  # и для редактирования (red2)
  my $n    = shift;
  my $pass = shift;
  my $data = shift;
 
  my $type = 'red2';
  $type = 'reg' if ($n eq '')&&($pass eq '');

  my $G = ($data->{gps} eq 'on')?'checked':'';

  my $out = qq* 
    <p><form name="$type" method="get" action="$script">
    <input name="type" type="hidden" value="$type"> *;
  $out.= qq*
    <input name="n" type="hidden" value="$n">
    <input name="pass" type="hidden" value="$pass"> * if $type eq 'red2';
  $out.= qq*
    Участник (Фамилия, Имя, год рождения):
     <input name="name"  type="text" maxlength="80" size="21" value="$data->{name}"><br>
    Контактный адрес:
     <input name="mail"  type="text" maxlength="80" size="21" value="$data->{mail}"><br>*;
  if ($type eq "red2"){
    $out.= qq*
    <input type="submit" name="Send" value="-- Исправить --">
    <input type="submit" name="Send" value="-- Удалить --">*;
  }
  else{
    $out.= qq*
    <input type="submit" name="Send" value="-- Зарегистрироваться --">*;
  }
  $out.= qq* </form> *;
  return $out;
}
