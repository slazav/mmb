#!/usr/bin/perl -w
use strict;
use CGI   ':standard';
use Fcntl ':flock';
use Digest::MD5 'md5_hex';
#use Mail::Send;

## ���� �� ����� �������.
## ������ ���� ���������� �� http!
my $dfile = '/home/slazav/mmb07.dat'; 
#my $dfile = '/home/slazav/mmb_data';

## ����� �������
#my $script='http://localhost/mb/reg05l.pl';
my $script='http://slazav.mccme.ru/perl/reg07.pl';

my @data; # ������ ������ ��� ���� ��������

my @fields = ('md5', 'name', 'mail', 
 'u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8', 'u9', 
 'dist', 'maps', 'gps');

# ��� ���� ��������� ���������
#my @dcolor = ("#CCFFCC", "FFFFFF");
my @dname = ("�", "�");

print "Content-Type: text/html; charset=koi8-r\n\n";

my $namesreg = '^[\d\w �����ţ��������������������������'.
                      '��������������������������������@\.\,_"()-]*$';

##########################################
# 4 �������� ������:
# - ��� ����������           type=''
# - ���������� ����� ������� type='reg'
# - ������ �� �������������� type='red1'
# - ��������������           type='red2'
# - �������� ������          type='pass'

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
  <head><title>���: $msg</title></head>
  <body> <h3>$msg</h3> 
  $msg1
  <p><a href="$script">��������� � ������.</a>
  </body>
  </html>
  *;
  return;
}

##########################################

sub read_data{
  if (!open(DAT, $dfile)){
    print_html("������: �� ���� ����� ���� ������!"); 
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
    print_html("������: �� ���� ������� ���� ������ ��� ������!");
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
      <title>���: ����������� ������</title>
      <META HTTP-EQUIV="no-cache">
    </head>
    <body>

    <h3 align=center> ���������� ����-������<br>
    11-13 ��� 2007 ����</h3><hr>
    <h3 align=center>����������� ������</h3>

    <p><table border=0 cellpadding=5><tr><td valign=top>

    <p>����������� �������� �� 24 ������ 2007� ������������.

    <!-- p><font color="#FF0000"> ����������� �������. ��������� ������
    ������� � ������� 666. �� ������ ������� ��������� � ���������
    ����� �������, �� ������� ���� � �������� ��� ������ � ��������
    �������� 666 �� �������������. ����� ������� ������ ����������
    ����� 24:00 ������� 11 ��� (����� ������ ����� ��������� ��� �
    ����). </font -->

    <p>������, ��� ���������������� ��� ������� � ����-������,
    ���������� <a href="http://slazav.mccme.ru/mmb/pol07.htm">���������</a>.

    <p>�� ���� �������� ����������� �� ������
    <a href="mailto:slazav\@narod.ru">slazav\@narod.ru</a> (����� ��������).

    <p>����������� ������� ���� �� ������ ���������, �����������
    ���������� ���������� ���� � �������� ������� ��������� (� ��� �).

    <p>����� ����������� ��� ����� ������� ����� ����� ������� �
    ������. �������� ������: �� �����������, ���� �� �������� 
    <a href="#red">������������� ���������� ��� ������� �������</a>. 

    <p>������� ���� ����� (����� ���������, ����� �������), ���� ��
    ������ �������� �� ����������� ����� ���������� � ����� ������ (��
    ������ �� ������������) � ���������� ����-������. �� ���� �� ����
    ������� <a href="#pass">�� ������������ �������</a> ����� ����
    ������������� ������ ��� ������. ������ �� ����� ������������� �
    ��������� � �������������� �����-���� ������ �������. 

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
    <hr><h3 align=center>������ ������������������ ������</h3>
    <table border=0 align=center cellpadding=8><tr>
    <th>��������� � (60 ��)</th>
    <th>��������� � (80 ��)</th>
    </tr>
    <tr>
  *;

  foreach (0,1){
  print qq* 
    <td valign=top><p><table border=1 cellspacing=0 cellpadding=5 align=center>
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
    <tr><th>�����: </th>
    <th>������: $nc</th>
    <th>�������: $nu</th>
    <th>����: $nm</th>
    <th>gps: $ng</th></tr>
    </table></td>
  *;
  } #foreach dist

  print qq*
    </tr></table><br><br>
  *;


  print qq* <hr><a name="red"></a> 
  <h3>������������� ���������� � �������:</h3>*; 
  print html_red1_form('','');

  print qq*
    <a name="pass"></a>
    <h3>������� ����� ������:</h3>
    <p>���� �� ������ ���� ������ ��� ���� �� ������ �������� ���,
    ������� � ��� ����� ����� ����� ������� � ���� �� �� ��� �������
    ����������� �����, ������� �� ��������� ��� �����������.
    ����� ������ ����� ������ ��� �� ���� �����. *;
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
    print_html($err, '<p> ���������� ��� ���:'.html_rr2_form('','',$data));
    exit();
  }

  my $pass=pass_gen();
  $data->{md5} = md5_hex($pass);

  push @data, $data;
  print_html('����������� ���������', html_data($#data, $pass));
}
##########################################
sub red1{

  my $n    = param('n');
  my $pass = param('pass');
  my $md5  = md5_hex($pass);

  my $err  = chk_pass($n, $md5);

  if ($err ne ''){
    print_html($err, '<p> ���������� ��� ���:'.html_red1_form($n, $pass));
    exit();
  }
  print_html('�������������� ���������� � �������', 
    html_rr2_form($n, $pass, $data[$n]));
}
##########################################
sub red2{

  my $n    = param('n');
  my $pass = param('pass');
  my $md5  = md5_hex($pass);

  my $err  = chk_pass($n, $md5);
  if ($err ne ''){
    print_html($err, '<p> ���������� ��� ���:'.html_red1_form($n, $pass));
    exit();
  }
 
  if (param('Send') =~ /�������/){
     undef($data[$n]);
     print_html("������� �������");
  } else {

    my $data;
    foreach (@fields){
      $data->{$_} = defined(param($_))? param($_):'';
    }
    my $err = chk_data($n, $data);

    if ($err ne ''){
      print_html($err, '<p> ���������� ��� ���:'.html_rr2_form($n, $pass, $data));
      exit();
    }

    $data->{md5} = $md5;
    $data[$n] = $data;
    print_html('���������� � ������� ����������', html_data($n, $pass));
  }
}

sub chpass{
  my $n    = param('n');
  my $mail = param('mail');

  my $err=chk_mail($n, $mail);
  if ($err ne ''){
    $err = '<font color="#FF0000">'.$err.'</font>';
    print_html($err, 
      qq* <p>���������� ��� ���!
          <p>�� �������: ����� ������ ����� ������ �� ��������� �����,
             ������ ���� ���� �� ����� ��� ������ ��� ����������� �������! 
      *.html_pass_form($n, $mail));
    exit();
  }

  my $pass=pass_gen();
  if (mail_pass($n, $mail, $pass)==0){
    $data[$n]->{md5} = md5_hex($pass);
    print_html('������ ������ �� ��������� �����');
  } else {
    print_html('������ ��� �������� ������!');
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


    ���� ������� ���� ���������������� ��
    ������� � ���������� ����-������ 2007
    http://slazav.mccme.ru/mmb

    �� ������ ������� ��� ������ ��� �������.
    ��� �����: $n
    ��� ����� ������: $pass
    ��������� ���� ������, �� ������ ������
    ���������� � �������.

    ������ ������ �������������������� ������
    �������� �� ������: $script

    �� ���� �������� ������ �� ������
    slazav\@narod.ru (����� ��������) 
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
  if ($n !~ /^\d+$/) {$err = '����� ������� ������ ���� ����������� ������!';}
  elsif (!defined($data[$n])) {$err = "��� ������� ����� $n!";}
  elsif ($data[$n]->{md5} ne $md5) {$err = '������������ ������!';}
  $err = '<font color="#FF0000">'.$err.'</font>' if $err ne '';
  return $err;
}

sub chk_mail{
  my $n    = shift;
  my $mail = shift;
  my $err = '';

  if ($n !~ /^\d+$/) {$err = '����� ������� ������ ���� ����������� ������!';}
  elsif (!defined($data[$n])) {$err = "��� ������� ����� $n!";}
  elsif ($mail !~ /[a-zA-Z\._\-0-9]+@[a-zA-Z\._\-0-9]+/) 
        {$err = '������� �������� ��� e-mail!';}
  elsif (" $data[$n]->{mail} " !~ /[\s,]$mail[\s,]/) 
        {$err = '�� �� ������� ����� ����� ��� �����������!' ;}
  $err = '<font color="#FF0000">'.$err.'</font>' if $err ne '';
  return $err;
}

sub chk_data{
  my $n    = shift; # ��������� ����� �� �������� �� ������ �����
  my $data = shift;
  my $err='';

  if ($data->{name} !~ /$namesreg/) 
    {$err .= "����������� ������� � �������� �������<br>\n";}
  foreach (1..9){
    if ($data->{"u$_"} !~ /$namesreg/)
      {$err .= "����������� ������� � ����� $_-�� ���������<br>\n";}
  }
  if ($data->{mail} !~ /$namesreg/) 
    {$err .= "����������� ������� � ��������� ������<br>\n";}
  if (($data->{dist} ne "0") && ($data->{dist} ne "1")) {$err .= "�� ������ ������� ���������!<br>\n";}
  if ($data->{maps} !~ /^\d+$/) {$err .= "���������� ���� ������ ���� ��������������� ��c���!<br>\n";}
  if ($data->{u1} eq '')      {$err .= "������ ���� ������ ���� �� ���� ��������!<br>\n" ;}
  $data->{gps} = 'off' if ($data->{gps} ne 'on');
  # ���������, ��� �� ������� � ����� ��������� ���������. 
  # ���� �������� ������ - ���������, ��� �� ������� � ����� ������
  # ���������� (������ �� �������).
  if ($data->{name} ne ''){
    for (my $i = 0; $i<=$#data; $i++){
      next if ($i == $n);
      if ($data[$i]->{name} eq $data->{name}) 
        {$err .= "������� � ����� ������ ��� ����������!<br>\n" ;}
    }
  } elsif ($data->{u1} ne ''){
    for (my $i = 0; $i<=$#data; $i++){
      next if ($i == $n);
      if ($data[$i]->{u1} eq $data->{u1}) 
        {$err .= "� ��, ������, ��� ����������������!<br>\n";}
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

  $out.= qq* <p> ��� �����: $F$n$F_, ��� ������: $F$pass$F_*;
  if ($data[$n]->{name} ne ''){
    $out.= qq* <p> �������: $F $data[$n]->{name} $F_ *;}
  else{
    $out.= qq* <p> ������� ��� �������� *;}
  $out.= qq* <p> ���������:<br> *;
  foreach (1..9){
    $out.= qq*  $_. $F $data[$n]->{"u$_"} $F_ <br> * 
      if ('' ne $data[$n]->{"u$_"});
  }
  $out.= qq*
  <p> ������� ���������: $F $dname[$data[$n]->{dist}]  $F_ 
  <p> ���������� ���������� ����: $F $data[$n]->{maps}  $F_ 
  <p> ���������� �����: $F $data[$n]->{mail}  $F_ *;
  $out.= qq*  �� ������ * if ('' eq $data[$n]->{"mail"});

  $out.= "<p> $F ������� ���������� ������������ GPS $F_" 
    if ($data[$n]->{gps} eq 'on');

  return $out;
}

sub html_red1_form{
  my $n    = shift;
  my $pass = shift;
  return qq*
  <p><form name="red" method="post" action="$script">
  <input name="type" type="hidden" value="red1">
  �����:  <input name="n" type="text" maxlength="3" size="3" value="$n">
  ������: <input name="pass" type="text" maxlength="8" size="8" value="$pass">
  <input type="submit" value=">>">
  </form>*;
}

sub html_pass_form{
  my $n    = shift;
  my $mail = shift;
  return qq* 
  <p><form name="pass" method="post" action="$script">
  <input name="type" type="hidden" value="pass">
  ����� �������:  <input name="n" type="text" maxlength="3" size="3" value="$n">
  �����: <input name="mail" type="text" maxlength="80" size="21" value="$mail">
  <input type="submit" value=">>">
  </form>*;
}

sub html_rr2_form{
  # ����� ��� ����������� ����� ������� (reg) $n==0; $pass=='';
  # � ��� �������������� (red2)
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
    �������� �������:
     <input name="name"  type="text" maxlength="21" size="21" value="$data->{name}"><br>
    ��������� (�������, ���, ��� ��������):<br> *;
  foreach (1..9){
    my $def = $data->{"u$_"};
    $out.= qq* 
     $_. <input name="u$_" type="text" maxlength="80" size="40" value="$def"><br>*;
  }
  $out.= qq*
    ������ ���������� ���������� ����:
     <input name="maps" type="text" size="2" maxlength="2" value="$data->{maps}"><br>
    ������� ���������:
     � (60 ��)<input name="dist" type="radio" $A value="0">
     � (80 ��)<input name="dist" type="radio" $B value="1"><br><br>
    ���������� �����:
     <input name="mail"  type="text" maxlength="80" size="21" value="$data->{mail}"><br>
    ������� ����� ������������ GPS:
     <input name="gps" type="checkbox" $G><br>*;
  if ($type eq "red2"){
    $out.= qq*
    <input type="submit" name="Send" value="-- ��������� ���������� � ������� --"><br>
    <input type="submit" name="Send" value="-- ������� ������� --">*;
  }
  else{
    $out.= qq*
    <input type="submit" name="Send" value="-- ������������������ --">*;
  }
  $out.= qq* </form> *;
  return $out;
}
