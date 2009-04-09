package res;

use strict;
use warnings;
use YAML::Tiny;

#############################################################
# ��������� ������� �� ����� � ������
# ������ �������: <�����> <���� ����������� ���������>
# ���� ��������� ���������, '-' - ������ ����
# ������ � '#' � ������ � ������ ������ ������������
# ������ ���� ����������, ����������� ���� �� �����������

sub read_table{
  my $file   = shift;      # �����
  my $data   = shift;      # ������ �� ������
  my @fields = @_;         # ������ �� ������ � ���������� �����

  open IN, $file or die "Can't open $file\n";
  warn "reading $file (@fields)\n";

  foreach(<IN>){
    next if (/^#/);     # �����������
    next if (/^\s*$/);  # �����
    my @d = split;
    shift @d if !defined($d[0]); # ���� � ������ ���� �������
    next if $#d==-1;
    die " - ������ �� ���������� � ������ ($file:$.)!" if $d[0]!~/\d+/;
    my $n = shift @d;
    ${$data->[$n]}{'N'}=$n;

    for( my $i = 0; $i <= $#fields; $i++){
      next if $i > $#d;
      warn " - ��������� ������ ���� $fields[$i] ��� ������ $n\n"
        if exists ${$data->[$n]}{$fields[$i]};
      ${$data->[$n]}{$fields[$i]} = ($d[$i] eq '-')? '' : $d[$i];
    }
  }
  close IN;
}

# ������ yaml-����, ������������� �� ���� ������ ����
sub read_yaml{
  my $file   = shift;      # �����
  my $data   = shift;      # ������ �� ������
  my @fields = @_;         # ������ �� ������ � ���������� �����

  my @d = YAML::Tiny::LoadFile($file);
  warn "reading yaml-file $file (@fields)\n";

  foreach my $d (@d){
    die "Bad yaml file $file\n" if (!exists $d->{N}) || (!defined $d->{N});
    my $n=$d->{N};
    ${$data->[$n]}{'N'}=$n;

    foreach my $f (@fields){
      next if (!exists $d->{$f}) || (!defined $d->{$f});
      warn "��������� ������ ���� $f ��� ������ $n\n"
        if exists ${$data->[$n]}{$f};
      ${$data->[$n]}{$f} = ($d->{$f} eq '-')? '' : $d->{$f};
    }
  }
}

# ������ ������������ � �������� � �����
sub read_comm{
  my $file   = shift;      # �����
  my $data   = shift;      # ������ �� ������

  open IN, $file or die "Can't open comm $file\n";
  warn "reading comments from $file\n";

  foreach(<IN>){
    next if (/^#/);     # �����������
    next if (/^\s*$/);  # �����
    warn " - bad format: $_\n" 
      unless (/^\s*(\d+)\s+(\S+)\s+(.+)$/);

    my ($n, $u, $c) = ($1, $2, $3);

    die " - ����������� � �������������� ������� $n"
      if (! defined $data->[$n]);
    if ($u eq '-'){
      warn " - ��������� ������ ���� comm ��� ������ $n\n"
        if exists ${$data->[$n]}{comm};
      ${$data->[$n]}{comm} = $c;
    }
    else{
      die " - ������������ ����� ��������� $n - $u\n"
        unless $u =~ /\d+/;
      die " - ����������� � ��������������� ��������� $n - $u\n"
        unless exists(${${$data->[$n]}{people}}[$u-1]);
      warn " - ��������� ������ ���� comm ��� ��������� $n - $u\n"
        if exists ${${$data->[$n]}{comm_u}}[$u-1];
      ${${$data->[$n]}{comm_u}}[$u-1] = $c;
    }
  }
  close IN;
}








# ���������� �� ������ ���� � ������ ������ ������ ����.
# ���� $define �� �������������� ���� ���������� �� ""
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

# ��������� �� ���������� ����
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
alt="�������@Mail.ru"/></a><!--/COUNTER-->
';

1;