#!/usr/bin/perl -w
use strict;
use CGI   ':standard';
use Fcntl ':flock';
use Digest::MD5 'md5_hex';

#my $dfile = '/home/slazav/mmb05.dat'; # ���� �� ����� �������.
my $dfile = '/home/sla/mmb05.dat'; # ���� �� ����� �������.
# ������ ���� ���������� �� http!

#my $script='http://slazav.mccme.ru/perl/reg05.pl';
my $script='http://localhost/mb/reg05.pl';
#my $script='http://vv4/~sla/cgi-bin/mmb_reg.pl';

my @data; # ������ ������ ��� ���� ��������

print "Content-Type: text/html; charset=koi8-r\n\n";
# ������ �� ����� ��������� ������ � ��������

# 3 �������� ������:
# - ��� ����������           type=''
# - ���������� ����� ������� type='reg'
# - ������ �� �������������� type='red1'
# - ��������������           type='red2'

my $namesreg = '^[\d\w �����ţ��������������������������'.
                      '��������������������������������@\.\,_"()-]*$';

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
else {
  read_data();
  print_data();
  exit;
}

##########################################

sub read_data{
  if (!open(DAT, $dfile)) {
    print qq*
      <html>
      <head><title>����������� �� ��� - ������</title></head>
      <body> <h2>������: �� ���� ����� ���� ������!</h2> </body>
      </html>
      *;
    exit();
  }

  my $n=0;
  foreach(<DAT>){
    if (/n:\s+(.*)/) {$n=$1;}
    if (/md5:\s+(.*)/) {$data[$n]->{md5}=$1;}
    if (/name:\s+(.*)/) {$data[$n]->{name}=$1;}
    if (/mail:\s+(.*)/) {$data[$n]->{mail}=$1;}
    if (/u1:\s+(.*)/) {$data[$n]->{u1}=$1;}
    if (/u2:\s+(.*)/) {$data[$n]->{u2}=$1;}
    if (/u3:\s+(.*)/) {$data[$n]->{u3}=$1;}
    if (/u4:\s+(.*)/) {$data[$n]->{u4}=$1;}
    if (/u5:\s+(.*)/) {$data[$n]->{u5}=$1;}
    if (/u6:\s+(.*)/) {$data[$n]->{u6}=$1;}
    if (/u7:\s+(.*)/) {$data[$n]->{u7}=$1;}
    if (/u8:\s+(.*)/) {$data[$n]->{u8}=$1;}
    if (/u9:\s+(.*)/) {$data[$n]->{u9}=$1;}
    if (/maps:\s+(.*)/) {$data[$n]->{maps}=$1;}
    if (/gps:\s+(.*)/)  {$data[$n]->{gps}=$1;}
  }
  close(DAT);
  if ($#data == -1) {$#data=0;}
}

##########################################

sub write_data{
  if (!open(DAT, "> $dfile")) {
    print qq*
      <html>
      <head><title>����������� �� ��� - ������</title></head>
      <body> <h2>������: �� ���� ������� ���� ������!</h2> </body>
      </html>
    *;
    exit();
  }

  my $n;
  for ($n=0; $n<= $#data; $n++){
    next if (!defined($data[$n]->{u1}));
    print DAT "n:\t$n\n";
    print DAT "md5:\t$data[$n]->{md5}\n";
    print DAT "name:\t$data[$n]->{name}\n";
    print DAT "mail:\t$data[$n]->{mail}\n";
    print DAT "u1:\t$data[$n]->{u1}\n";
    print DAT "u2:\t$data[$n]->{u2}\n";
    print DAT "u3:\t$data[$n]->{u3}\n";
    print DAT "u4:\t$data[$n]->{u4}\n";
    print DAT "u5:\t$data[$n]->{u5}\n";
    print DAT "u6:\t$data[$n]->{u6}\n";
    print DAT "u7:\t$data[$n]->{u7}\n";
    print DAT "u8:\t$data[$n]->{u8}\n";
    print DAT "u9:\t$data[$n]->{u9}\n";
    print DAT "maps:\t$data[$n]->{maps}\n";
    print DAT "gps:\t$data[$n]->{gps}\n";
    print DAT "\n";
  }
  close(DAT);
}
##########################################
sub print_data{
  print qq* 
    <html>
    <head>
      <title>���: ����������� ������</title>
      <META HTTP-EQUIV="no-cache">
    </head>
    <body>

    <h3 align=center> ���������� ����-������<br>
    27-29 ��� 2005 ����<br>
    ����������� ������</h3>

    <p><table border=0 cellpadding=5><tr><td valign=top>

    <p>����������� �������� �� 24 ��� 2005�.

    <p>������, ��� ���������������� ��� ������� � ����-������,
    ���������� <a href="http://slazav.mccme.ru/mmb/mmb2005.htm">���������</a>.

    <p>�� ���� �������� ����������� �� ������
    <a href="mailto:slazav\@narod.ru">slazav\@narod.ru</a> (����� ��������).

    <p>����������� ������� ���� �� ������ ��������� � �����������
    ���������� ���������� ����.

    <p>������� ���������� ����� (����� ���������, ����� �������), ����
    �� ������ �������� �� ����������� ����� ���������� � ����� ������
    (�� ������ �� ������������) � ���������� ����-������. ������ ��
    ����� ������������� � ���������.

    <p>����� ����������� ��� ����� ������� ����� ����� ������� �
    ������. �������� ������: �� �����������, ���� �� �������� ��������
    ���������� ��� ������� �������.

    </td><td valign=top width="50%" align=right>

    <form name="reg" method="get" action="$script">
    <input name="type" type="hidden" value="reg">
      �������� �������:&nbsp;<input name="name"  type="text" maxlength="21" size="21"><br>
      ��������� (�������, ���, ��� ��������):<br>
        1. <input name="u1" type="text" maxlength="80" size="40"><br>
        2. <input name="u2" type="text" maxlength="80" size="40" ><br>
        3. <input name="u3" type="text" maxlength="80" size="40" ><br>
        4. <input name="u4" type="text" maxlength="80" size="40" ><br>
        5. <input name="u5" type="text" maxlength="80" size="40" ><br>
        6. <input name="u6" type="text" maxlength="80" size="40" ><br>
        7. <input name="u7" type="text" maxlength="80" size="40" ><br>
        8. <input name="u8" type="text" maxlength="80" size="40" ><br>
        9. <input name="u9" type="text" maxlength="80" size="40" ><br>
        ������ ���������� ���������� ����:&nbsp;<input name="maps" type="text" size="2" maxlength="2"><br>
        ���������� �����:&nbsp;<input name="mail"  type="text" maxlength="80" size="21"><br>
        ������� ����� ������������ GPS:&nbsp;<input name="gps" type="checkbox"><br>
        <input type="submit" name="Send" value="-- ������������������ --">
    </form>
    </td></tr>
    </table></p>
    
    <br>
    <br>

    <h3 align=center>������ ������������������ ������</h3>

    <p><table border=1 cellspacing=0 cellpadding=5 align=center>
    <tr><th>�����</th><th>��������</th><th>���������</th>
    <th>�����</th><th>GPS</th></tr>
  *;

  my $n;
  my $nu=0;
  my $nc=0;
  my $nm=0;
  my $ng=0;
  for ($n=0; $n<= $#data; $n++){
    next if (!defined($data[$n]));
   
    $nc++;
    print "<tr><td valign=top>$n</td>";
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
    <tr><th>�����:</th><th>������: $nc</th><th>�������: $nu</th>
    <th>����: $nm</th><th>gps: $ng</th></tr>
    </table></p>

    <br>
    <br>

    <h3 align=center>������������� ���������� � �������</h3>
    <div align=center>
    <form name="red" method="post" action="$script">
    <input name="type" type="hidden" value="red1">
    �����:  <input name="n" type="text" maxlength="3" size="3">
    ������: <input name="pass" type="text" maxlength="8" size="8">
    <input type="submit" value=">>">
    </form>
    </div>
    </body></html>
  *;
}

##########################################
sub reg{

  my $name = defined(param('name'))? param('name') : '';
  my $mail = defined(param('mail'))? param('mail') : '';
  my $u1 = defined(param('u1'))? param('u1') : '';
  my $u2 = defined(param('u2'))? param('u2') : '';
  my $u3 = defined(param('u3'))? param('u3') : '';
  my $u4 = defined(param('u4'))? param('u4') : '';
  my $u5 = defined(param('u5'))? param('u5') : '';
  my $u6 = defined(param('u6'))? param('u6') : '';
  my $u7 = defined(param('u7'))? param('u7') : '';
  my $u8 = defined(param('u8'))? param('u8') : '';
  my $u9 = defined(param('u9'))? param('u9') : '';
  my $maps = defined(param('maps'))? param('maps') : '';
  my $gps = defined(param('gps'))? param('gps') : 'off';


  my $err='';
  if ($name !~ /$namesreg/) {$err .= "����������� ������� � �������� �������<br>\n";}
  if ($u1   !~ /$namesreg/) {$err .= "����������� ������� � ����� 1-�� ���������<br>\n";}
  if ($u2   !~ /$namesreg/) {$err .= "����������� ������� � ����� 2-�� ���������<br>\n";}
  if ($u3   !~ /$namesreg/) {$err .= "����������� ������� � ����� 3-�� ���������<br>\n";}
  if ($u4   !~ /$namesreg/) {$err .= "����������� ������� � ����� 4-�� ���������<br>\n";}
  if ($u5   !~ /$namesreg/) {$err .= "����������� ������� � ����� 5-�� ���������<br>\n";}
  if ($u6   !~ /$namesreg/) {$err .= "����������� ������� � ����� 6-�� ���������<br>\n";}
  if ($u7   !~ /$namesreg/) {$err .= "����������� ������� � ����� 7-�� ���������<br>\n";}
  if ($u8   !~ /$namesreg/) {$err .= "����������� ������� � ����� 8-�� ���������<br>\n";}
  if ($u9   !~ /$namesreg/) {$err .= "����������� ������� � ����� 9-�� ���������<br>\n";}
  if ($mail !~ /$namesreg/) {$err .= "����������� ������� � ��������� ������<br>\n";}
  if ($maps !~ /^\d+$/) {$err .= "���������� ���� ������ ���� ��������������� ��c���!<br>\n";}
  if ($u1 eq '')      {$err .= "������ ���� ������ ���� �� ���� ��������!<br>\n" ;}
  $gps = 'off' if ($gps ne 'on');

  if ($name ne ''){
    foreach (@data){
      if ($_->{name} eq $name) {$err .= "������� � ����� ������ ��� ����������!<br>\n" ;}
    }
  }
  if ($u1 ne ''){
    foreach (@data){
      if ($_->{u1} eq $u1) {$err .= "� ��, ������, ��� ����������������!<br>\n";}
    }
  }

  my $checked = ($gps eq 'on')?'checked':'';
  if ($err ne ''){
    print qq* 
      <html>
      <head><title>���: ������ ��� �����������</title></head>
      <body> <h3>������:<br><font color="#FF0000">$err</font></h3>
      <p> ���������� ��� ���:
      <p><form name="reg" method="get" action="$script">
      <input name="type" type="hidden" value="reg">
        �������� �������:
          <input name="name"  type="text" maxlength="21" size="21" value="$name"><br>
        ��������� (�������, ���, ��� ��������):<br>
          1. <input name="u1" type="text" maxlength="80" size="40" value="$u1"><br>
          2. <input name="u2" type="text" maxlength="80" size="40" value="$u2"><br>
          3. <input name="u3" type="text" maxlength="80" size="40" value="$u3"><br>
          4. <input name="u4" type="text" maxlength="80" size="40" value="$u4"><br>
          5. <input name="u5" type="text" maxlength="80" size="40" value="$u5"><br>
          6. <input name="u6" type="text" maxlength="80" size="40" value="$u6"><br>
          7. <input name="u7" type="text" maxlength="80" size="40" value="$u7"><br>
          8. <input name="u8" type="text" maxlength="80" size="40" value="$u8"><br>
          9. <input name="u9" type="text" maxlength="80" size="40" value="$u9"><br>
          ������ ���������� ���������� ����:
          <input name="maps" type="text" size="2" maxlength="2" value="$maps"><br>
          ���������� �����:
          <input name="mail"  type="text" maxlength="80" size="21" value="$mail"><br>
          ������� ����� ������������ GPS:
          <input name="gps" type="checkbox" $checked><br>
          <input type="submit" name="Send" value="-- ������������������ --">
      </form>
      <p><a href="$script">��������� � ������� ������.</a>
      </body>
      </html>\n *;
    exit;
  }
  my $i;
  my $pass='';
  for ($i=0; $i<6; $i++) {$pass.=('a'..'z', 0..9)[rand 36];}

  push @data, {name=>$name, maps=>$maps,  mail=>$mail,
               u1=>$u1, u2=>$u2, u3=>$u3, 
               u4=>$u4, u5=>$u5, u6=>$u6, 
               u7=>$u7, u8=>$u8, u9=>$u9,
               gps=>$gps, md5=>md5_hex($pass)};

    print qq*
      <html>
      <head><title>���: ����������� ���������</title></head>
      <body> <h3>����������� ���������</h3>
      <p> ��� �����: <font color="#FF0000">$#data</font>,
            ��� ������: <font color="#FF0000">$pass</font> *;
      if ($name ne ''){
        print qq* <p> �������: <font color="#FF0000">$name</font>*;}
      else{
        print qq* <p> ������� ��� �������� *;}
      print qq* <p> ���������:<br> *;
      print qq*  1. <font color="#FF0000">$u1</font><br> *;
      print qq*  2. <font color="#FF0000">$u2</font><br> * if ('' ne $u2);
      print qq*  3. <font color="#FF0000">$u3</font><br> * if ('' ne $u3); 
      print qq*  4. <font color="#FF0000">$u4</font><br> * if ('' ne $u4); 
      print qq*  5. <font color="#FF0000">$u5</font><br> * if ('' ne $u5); 
      print qq*  6. <font color="#FF0000">$u6</font><br> * if ('' ne $u6); 
      print qq*  7. <font color="#FF0000">$u7</font><br> * if ('' ne $u7); 
      print qq*  8. <font color="#FF0000">$u8</font><br> * if ('' ne $u8); 
      print qq*  9. <font color="#FF0000">$u9</font><br> * if ('' ne $u9); 
    print qq*
      <p> ���������� ���������� ����: <font color="#FF0000">$maps </font>
      <p> ���������� �����: <font color="#FF0000">$mail </font>
    *;
    print "<p><font color=\"#FF0000\">
        ������� ���������� ������������ GPS</font>" if ($gps eq 'on');
    print qq*

      <p><a href="$script">��������� � ������� ������.</a>
      </body>
      </html>
    *;
}
##########################################
sub red1{

  my $n    = param('n');
  my $pass = param('pass');
  my $md5  = md5_hex($pass);

  my $err='';
  if ($n !~ /\d+/) {$err = "����� ������� ������ ���� ����������� ������!";}
  elsif (!defined($data[$n])) {$err = "��� ������� ����� $n!";}
  elsif ($data[$n]->{md5} ne $md5) {$err = "������������ ������!" ;}

  if ($err ne ''){
    print qq* 
      <html>
      <head><title>���: ������</title></head>
      <body> <h3>������:<br><font color="#FF0000">$err</font></h3>
      <p> ���������� ��� ���:
      <p><form name="red" method="post" action="$script">
      <input name="type" type="hidden" value="red1">
      �����:  <input name="n" type="text" maxlength="3" size="3" value="$n">
      ������: <input name="pass" type="text" maxlength="8" size="8">
      <input type="submit" value=">>">
      </form>
      <p><a href="$script">��������� � ������� ������.</a>
      </body>
      </html>\n *;
    exit;
  }
  my $checked = ($data[$n]->{gps} eq 'on')?'checked':'';
  print qq* <html>
    <head><title>���: �������������� ���������� � �������</title></head>
    <body> <h3>�������������� ���������� � �������</h3>
    <p><form name="red2" method="get" action="$script">
    <input name="type" type="hidden" value="red2">
    <input name="n" type="hidden" value="$n">
    <input name="pass" type="hidden" value="$pass">
    �������� �������:
    <input name="name"  type="text" maxlength="21" size="21" value="$data[$n]->{name}"><br>
  ��������� (�������, ���, ��� ��������):<br>
    1. <input name="u1" type="text" maxlength="80" size="40" value="$data[$n]->{u1}" ><br>
    2. <input name="u2" type="text" maxlength="80" size="40" value="$data[$n]->{u2}" ><br>
    3. <input name="u3" type="text" maxlength="80" size="40" value="$data[$n]->{u3}" ><br>
    4. <input name="u4" type="text" maxlength="80" size="40" value="$data[$n]->{u4}" ><br>
    5. <input name="u5" type="text" maxlength="80" size="40" value="$data[$n]->{u5}" ><br>
    6. <input name="u6" type="text" maxlength="80" size="40" value="$data[$n]->{u6}"><br>
    7. <input name="u7" type="text" maxlength="80" size="40" value="$data[$n]->{u7}"><br>
    8. <input name="u8" type="text" maxlength="80" size="40" value="$data[$n]->{u8}"><br>
    9. <input name="u9" type="text" maxlength="80" size="40" value="$data[$n]->{u9}"><br>
    ������ ���������� ���������� ����:
    <input name="maps" type="text" size="2" maxlength="2" value="$data[$n]->{maps}"><br>
    ���������� �����:
    <input name="mail"  type="text" maxlength="80" size="21" value="$data[$n]->{mail}"><br>
    ������� ����� ������������ GPS:
    <input name="gps" type="checkbox" $checked><br>
    <input type="submit" name="Send" value="-- ��������� ���������� � ������� --"><br>
    <input type="submit" name="Send" value="-- ������� ������� --">
    </form>
    <p><a href="$script">��������� � ������� ������.</a>
    </body></html>
    *;
}
##########################################
sub red2{

  my $n    = param('n');
  my $pass = param('pass');
  my $md5 =  md5_hex($pass);


  my $err='';
  if ($n !~ /\d+/) {$err = "����� ������� ������ ���� ����������� ������!";}
  elsif (!defined($data[$n])) {$err = "��� ������� ����� $n!";}
  elsif ($data[$n]->{md5} ne $md5) {$err = "������������ ������!" ;}

  if ($err ne ''){
    print qq* 
      <html>
      <head><title>���: ������ </title></head>
      <body> <h3>������:<br><font color="#FF0000">$err</font></h3>
      <p> ���������� ��� ���:
      <p><form name="red" method="post" action="$script">
      <input name="type" type="hidden" value="red1">
      �����:  <input name="n" type="text" maxlength="3" size="3" value="$n">
      ������: <input name="pass" type="text" maxlength="8" size="8">
      <input type="submit" value=">>">
      </form>
      <p><a href="$script">��������� � ������� ������.</a>
      </body>
      </html>\n *;
    exit;
  }
 
  if (param('Send') =~ /�������/){
    undef($data[$n]);
    print qq*
      <html>
      <head><title>���: ������� �������</title></head>
      <body> <h3>������� �������</h3>
      <p><a href="$script">��������� � ������� ������.</a>
      </body></html>
    *;
  } else {

    my $name = defined(param('name'))? param('name') : '';
    my $mail = defined(param('mail'))? param('mail') : '';
    my $u1 = defined(param('u1'))? param('u1') : '';
    my $u2 = defined(param('u2'))? param('u2') : '';
    my $u3 = defined(param('u3'))? param('u3') : '';
    my $u4 = defined(param('u4'))? param('u4') : '';
    my $u5 = defined(param('u5'))? param('u5') : '';
    my $u6 = defined(param('u6'))? param('u6') : '';
    my $u7 = defined(param('u7'))? param('u7') : '';
    my $u8 = defined(param('u8'))? param('u8') : '';
    my $u9 = defined(param('u9'))? param('u9') : '';
    my $maps = defined(param('maps'))? param('maps') : '';
    my $gps = defined(param('gps'))? param('gps') : 'off';

    my $err='';
    my $i;
    if ($name !~ /$namesreg/) {$err .= "����������� ������� � �������� �������<br>\n";}
    if ($u1   !~ /$namesreg/) {$err .= "����������� ������� � ����� 1-�� ���������<br>\n";}
    if ($u2   !~ /$namesreg/) {$err .= "����������� ������� � ����� 2-�� ���������<br>\n";}
    if ($u3   !~ /$namesreg/) {$err .= "����������� ������� � ����� 3-�� ���������<br>\n";}
    if ($u4   !~ /$namesreg/) {$err .= "����������� ������� � ����� 4-�� ���������<br>\n";}
    if ($u5   !~ /$namesreg/) {$err .= "����������� ������� � ����� 5-�� ���������<br>\n";}
    if ($u6   !~ /$namesreg/) {$err .= "����������� ������� � ����� 6-�� ���������<br>\n";}
    if ($u7   !~ /$namesreg/) {$err .= "����������� ������� � ����� 7-�� ���������<br>\n";}
    if ($u8   !~ /$namesreg/) {$err .= "����������� ������� � ����� 8-�� ���������<br>\n";}
    if ($u9   !~ /$namesreg/) {$err .= "����������� ������� � ����� 9-�� ���������<br>\n";}
    if ($mail !~ /$namesreg/) {$err .= "����������� ������� � ��������� ������<br>\n";}
    if ($maps !~ /^\d+$/) {$err .= "���������� ���� ������ ���� ��������������� ��c���!<br>\n";}
    if ($u1 eq '')      {$err .= "������ ���� ������ ���� �� ���� ��������!<br>\n" ;}
    #if (($gps ne 'on')&&($gps ne '')) {$err = "����������� ����� �������� gps!<br>\n" ;}
    $gps = 'off' if ($gps ne 'on');
    if ($name ne ''){
      for ($i=0; $i<=$#data; $i++){
        next if ($i==$n);
        if ($data[$i]->{name} eq $name) {$err .= "������� � ����� ������ ��� ����������!<br>\n" ;}
      }
    }
    my $checked = ($gps eq 'on')?'checked':'';
    if ($err ne ''){
      print qq* 
        <html>
        <head><title>���: ������ ��� ��������������</title></head>
        <body> <h3>������:<br><font color="#FF0000">$err</font></h3>
        <p> ���������� ��� ���:
        <p><form name="reg" method="get" action="$script">
        <input name="type" type="hidden" value="red2">
        <input name="n" type="hidden" value="$n">
        <input name="pass" type="hidden" value="$pass">
          �������� �������:
            <input name="name"  type="text" maxlength="21" size="21" value="$name"><br>
          ��������� (�������, ���, ��� ��������):<br>
            1. <input name="u1" type="text" maxlength="80" size="40" value="$u1"><br>
            2. <input name="u2" type="text" maxlength="80" size="40" value="$u2"><br>
            3. <input name="u3" type="text" maxlength="80" size="40" value="$u3"><br>
            4. <input name="u4" type="text" maxlength="80" size="40" value="$u4"><br>
            5. <input name="u5" type="text" maxlength="80" size="40" value="$u5"><br>
            6. <input name="u6" type="text" maxlength="80" size="40" value="$u6"><br>
            7. <input name="u7" type="text" maxlength="80" size="40" value="$u7"><br>
            8. <input name="u8" type="text" maxlength="80" size="40" value="$u8"><br>
          9. <input name="u9" type="text" maxlength="80" size="40" value="$u9"><br>
          ������ ���������� ���������� ����:
          <input name="maps" type="text" size="2" maxlength="2" value="$maps"><br>
          ���������� �����:
          <input name="mail"  type="text" maxlength="80" size="21" value="$mail"><br>
          ������� ����� ������������ GPS:
          <input name="gps" type="checkbox" $checked><br>
        <input type="submit" name="Send" value="-- ��������� ���������� � ������� --"><br>
        <input type="submit" name="Send" value="-- ������� ������� --">
      </form>
      <p><a href="$script">��������� � ������� ������.</a>
      </body>
      </html>\n *;
    exit;
    }
  
    $data[$n] = {name=>$name, maps=>$maps, mail=>$mail,
               u1=>$u1, u2=>$u2, u3=>$u3, 
               u4=>$u4, u5=>$u5, u6=>$u6, 
               u7=>$u7, u8=>$u8, u9=>$u9,
               gps=>$gps, md5=>$md5};

    print qq*
      <html>
      <head><title>���: ���������� � ������� ����������</title></head>
      <body> <h3>���������� � ������� ����������</h3>
      <p> ��� �����: <font color="#FF0000">$n</font>,
            ��� ������: <font color="#FF0000">$pass</font> *;
      if ($name ne ''){
        print qq* <p> �������: <font color="#FF0000">$name</font>*;}
      else{
        print qq* <p> ������� ��� �������� *;}
      print qq* <p> ���������:<br> *;
      print qq*  1. <font color="#FF0000">$u1</font><br> *;
      print qq*  2. <font color="#FF0000">$u2</font><br> * if ('' ne $u2);
      print qq*  3. <font color="#FF0000">$u3</font><br> * if ('' ne $u3); 
      print qq*  4. <font color="#FF0000">$u4</font><br> * if ('' ne $u4); 
      print qq*  5. <font color="#FF0000">$u5</font><br> * if ('' ne $u5); 
      print qq*  6. <font color="#FF0000">$u6</font><br> * if ('' ne $u6); 
      print qq*  7. <font color="#FF0000">$u7</font><br> * if ('' ne $u7); 
      print qq*  8. <font color="#FF0000">$u8</font><br> * if ('' ne $u8); 
      print qq*  9. <font color="#FF0000">$u9</font><br> * if ('' ne $u9); 
    print qq*
      <p> ���������� ���������� ����: <font color="#FF0000">$maps </font>
      <p> ���������� �����: <font color="#FF0000">$mail </font>
    *;
    print "<p><font color=\"#FF0000\">
        ������� ���������� ������������ GPS</font>" if ($gps eq 'on');
    print qq*

      <p><a href="$script">��������� � ������� ������.</a>
      </body>
      </html>
    *;
  }
}
