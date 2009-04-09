#!/usr/bin/perl -w
use strict;
use CGI   ':standard';
use Fcntl ':flock';
use Digest::MD5 'md5_hex';
#use Mail::Send;

## файл со всеми данными.
## должен быть недоступен по http!
my $dfile = '/home/slazav/mmb07.dat'; 
#my $dfile = '/home/slazav/mmb_data';

## адрес скрипта
#my $script='http://localhost/mb/reg05l.pl';
my $script='http://slazav.mccme.ru/perl/reg07.pl';

my @data; # массив данных обо всех командах

my @fields = ('md5', 'name', 'mail', 
 'u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8', 'u9', 
 'dist', 'maps', 'gps');

# для двух вариантов дистанции
#my @dcolor = ("#CCFFCC", "FFFFFF");
my @dname = ("А", "Б");

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
  <head><title>ММБ: $msg</title></head>
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
    print_html("Ошибка: не могу найти файл данных!"); 
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
    print_html("Ошибка: не могу открыть файл данных для записи!");
    exit();
  }

  my $n;
  for ($n=0; $n<= $#data; $n++){
    next if (!defined($data[$n]->{u1}));
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
      <title>ММБ: Регистрация команд</title>
      <META HTTP-EQUIV="no-cache">
    </head>
    <body>

    <h3 align=center> Московский марш-бросок<br>
    11-13 мая 2007 года</h3><hr>
    <h3 align=center>Регистрация команд</h3>

    <p><table border=0 cellpadding=5><tr><td valign=top>

    <p>Регистрация работает до 24 апреля 2007г включительно.

    <!-- p><font color="#FF0000"> Регистрация закрыта. Последней успела
    команда с номером 666. Вы можете вносить изменения и добавлять
    новые команды, но наличие карт и карточек для команд с номерами
    большими 666 не гарантируется. Такие команды смогут стартовать
    после 24:00 пятницы 11 мая (время старта будет считаться как у
    всех). </font -->

    <p>Прежде, чем регистрироваться для участия в марш-броске,
    прочитайте <a href="http://slazav.mccme.ru/mmb/pol07.htm">Положение</a>.

    <p>По всем вопросам обращайтесь по адресу
    <a href="mailto:slazav\@narod.ru">slazav\@narod.ru</a> (Слава Завьялов).

    <p>Обязательно укажите хотя бы одного участника, необходимое
    количество комплектов карт и выберете вариант дистанции (А или Б).

    <p>После регистрации вам будет сообщен номер вашей команды и
    пароль. Запишите пароль: он понадобится, если вы захотите 
    <a href="#red">редактировать информацию или удалить команду</a>. 

    <p>Укажите свой адрес (можно несколько, через запятую), если вы
    хотите получить по электронной почте информацию о месте старта (за
    неделю до соревнований) и результаты марш-броска. На один из этих
    адресов <a href="#pass">по специальному запросу</a> может быть
    автоматически выслан ваш пароль. Адреса не будут публиковаться в
    интернете и использоваться каким-либо другим образом. 

    </td><td valign=top width="50%" align=right> *;

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
    <hr><h3 align=center>Список зарегистрированных команд</h3>
    <table border=0 align=center cellpadding=8><tr>
    <th>Дистанция А (60 км)</th>
    <th>Дистанция Б (80 км)</th>
    </tr>
    <tr>
  *;

  foreach (0,1){
  print qq* 
    <td valign=top><p><table border=1 cellspacing=0 cellpadding=5 align=center>
    <tr><th>Номер</th><th>Название</th><th>Участники</th>
    <th>Карты</th><th>GPS</th></tr>
  *;

  my $n;
  my $nu=0;
  my $nc=0;
  my $nm=0;
  my $ng=0;
  for ($n=0; $n<= $#data; $n++){
    next if (!defined($data[$n]));
    next if ($data[$n]->{dist} ne $_);
   
    $nc++;
    print "<tr><td valign=top align=center>$n</td>";
    if ($data[$n]->{name} ne ''){ print "<td valign=top>$data[$n]->{name}</td>\n";}
    else { print "<td>&nbsp</td>\n";}
    print "    <td>$data[$n]->{u1}\n"; $nu++;
    if ($data[$n]->{u2} ne '') {print "    <br>$data[$n]->{u2}\n"; $nu++;}
    if ($data[$n]->{u3} ne '') {print "    <br>$data[$n]->{u3}\n"; $nu++;}
    if ($data[$n]->{u4} ne '') {print "    <br>$data[$n]->{u4}\n"; $nu++;}
    if ($data[$n]->{u5} ne '') {print "    <br>$data[$n]->{u5}\n"; $nu++;}
    if ($data[$n]->{u6} ne '') {print "    <br>$data[$n]->{u6}\n"; $nu++;}
    if ($data[$n]->{u7} ne '') {print "    <br>$data[$n]->{u7}\n"; $nu++;}
    if ($data[$n]->{u8} ne '') {print "    <br>$data[$n]->{u8}\n"; $nu++;}
    if ($data[$n]->{u9} ne '') {print "    <br>$data[$n]->{u9}\n"; $nu++;}
    print "    </td>\n";
    print "    <td align=center valign=top>$data[$n]->{maps}</td>\n"; $nm+=$data[$n]->{maps};
    if ($data[$n]->{gps} eq 'on') 
      {print "    <td align=center valign=top>+\n"; $ng++;}
    else 
      {print "    <td align=center valign=top>&nbsp;</td>\n";}
    print "</tr>\n";
  }
  print qq*
    <tr><th>итого: </th>
    <th>команд: $nc</th>
    <th>человек: $nu</th>
    <th>карт: $nm</th>
    <th>gps: $ng</th></tr>
    </table></td>
  *;
  } #foreach dist

  print qq*
    </tr></table><br><br>
  *;


  print qq* <hr><a name="red"></a> 
  <h3>Редактировать информацию о команде:</h3>*; 
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
     print_html("Команда удалена");
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
    print_html('Пароль выслан на указанный адрес');
  } else {
    print_html('Ошибка при отправке пароля!');
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
Subject: mmb2007 password
Content-Type: text/plain; charset="koi8-r"


    Ваша команда была зарегистрирована на
    участие в Московском марш-броске 2007
    http://slazav.mccme.ru/mmb

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
      
# return `echo \'$msg\' | mail -s \"$subj\" -a \'$h1\' -a \'$h2\' $mail`;
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
  foreach (1..9){
    if ($data->{"u$_"} !~ /$namesreg/)
      {$err .= "Запрещенные символы в имени $_-го участника<br>\n";}
  }
  if ($data->{mail} !~ /$namesreg/) 
    {$err .= "Запрещенные символы в контактом адресе<br>\n";}
  if (($data->{dist} ne "0") && ($data->{dist} ne "1")) {$err .= "Не указан вариант дистанции!<br>\n";}
  if ($data->{maps} !~ /^\d+$/) {$err .= "Количество карт должно быть неотрицательным чиcлом!<br>\n";}
  if ($data->{u1} eq '')      {$err .= "Должен быть указан хотя бы один участник!<br>\n" ;}
  $data->{gps} = 'off' if ($data->{gps} ne 'on');
  # Проверить, нет ли команды с таким названием названием. 
  # Если название пустое - проверить, нет ли команды с таким первым
  # участником (защита от релоада).
  if ($data->{name} ne ''){
    for (my $i = 0; $i<=$#data; $i++){
      next if ($i == $n);
      if ($data[$i]->{name} eq $data->{name}) 
        {$err .= "Команда с таким именем уже существует!<br>\n" ;}
    }
  } elsif ($data->{u1} ne ''){
    for (my $i = 0; $i<=$#data; $i++){
      next if ($i == $n);
      if ($data[$i]->{u1} eq $data->{u1}) 
        {$err .= "А вы, похоже, уже регистрировались!<br>\n";}
    }
  } 
  $err = '<font color="#FF0000">'.$err.'</font>' if $err ne '';
  return $err;
}


sub pass_gen{
  my $pass='';
  for (my $i=0; $i<6; $i++) {$pass.=('a'..'z', 0..9)[rand 36];}
  return $pass;
}

sub html_data{
  my $n = shift;
  my $pass = shift;

  my $F  = '<font color="#FF0000"><b>';
  my $F_ = '</b></font>';

  my $out ='';

  $out.= qq* <p> Ваш номер: $F$n$F_, ваш пароль: $F$pass$F_*;
  if ($data[$n]->{name} ne ''){
    $out.= qq* <p> Команда: $F $data[$n]->{name} $F_ *;}
  else{
    $out.= qq* <p> Команда без названия *;}
  $out.= qq* <p> Участники:<br> *;
  foreach (1..9){
    $out.= qq*  $_. $F $data[$n]->{"u$_"} $F_ <br> * 
      if ('' ne $data[$n]->{"u$_"});
  }
  $out.= qq*
  <p> Вариант дистанции: $F $dname[$data[$n]->{dist}]  $F_ 
  <p> Количество комплектов карт: $F $data[$n]->{maps}  $F_ 
  <p> Контактный адрес: $F $data[$n]->{mail}  $F_ *;
  $out.= qq*  не указан * if ('' eq $data[$n]->{"mail"});

  $out.= "<p> $F Команда собирается пользоваться GPS $F_" 
    if ($data[$n]->{gps} eq 'on');

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
  Номер команды:  <input name="n" type="text" maxlength="3" size="3" value="$n">
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
  my $A = ($data->{dist} eq '0')?'checked':'';
  my $B = ($data->{dist} eq '1')?'checked':'';

  my $out = qq* 
    <p><form name="$type" method="get" action="$script">
    <input name="type" type="hidden" value="$type"> *;
  $out.= qq*
    <input name="n" type="hidden" value="$n">
    <input name="pass" type="hidden" value="$pass"> * if $type eq 'red2';
  $out.= qq*
    Название команды:
     <input name="name"  type="text" maxlength="21" size="21" value="$data->{name}"><br>
    Участники (Фамилия, Имя, год рождения):<br> *;
  foreach (1..9){
    my $def = $data->{"u$_"};
    $out.= qq* 
     $_. <input name="u$_" type="text" maxlength="80" size="40" value="$def"><br>*;
  }
  $out.= qq*
    Нужное количество комплектов карт:
     <input name="maps" type="text" size="2" maxlength="2" value="$data->{maps}"><br>
    Вариант дистанции:
     А (60 км)<input name="dist" type="radio" $A value="0">
     Б (80 км)<input name="dist" type="radio" $B value="1"><br><br>
    Контактный адрес:
     <input name="mail"  type="text" maxlength="80" size="21" value="$data->{mail}"><br>
    Команда будет пользоваться GPS:
     <input name="gps" type="checkbox" $G><br>*;
  if ($type eq "red2"){
    $out.= qq*
    <input type="submit" name="Send" value="-- Исправить информацию о команде --"><br>
    <input type="submit" name="Send" value="-- Удалить команду --">*;
  }
  else{
    $out.= qq*
    <input type="submit" name="Send" value="-- Зарегистрироваться --">*;
  }
  $out.= qq* </form> *;
  return $out;
}
