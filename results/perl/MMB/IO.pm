package MMB::IO;

use strict;
use warnings;
use YAML::Tiny;

#############################################################
# ��������� ������� �� ����� � ������
# ������ �������: <�����> <���� ����������� ���������>
# ���� ��������� ���������, '-' - ������ ����, '?' - �������������� ����
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
      if ($d[$i] eq '?'){
        delete ${$data->[$n]}{$fields[$i]};
        next;
      }
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
        if exists ${${$data->[$n]}{comm_p}}[$u-1];
      ${${$data->[$n]}{comm_p}}[$u-1] = $c;
    }
  }
  close IN;
}








# ���������� �� ������ ���� � ������ ������ ������ ����.
# ���� $define �� �������������� ���� ���������� �� ""
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


# ��������� �� �������������� ���� � �������� ����
sub test_def{
  my $data = shift;
  foreach (@_){
    return 0 if !defined $data->{$_};
  }
  return 1;
}

# ��������� �� ���������� ���� � �������� ����
# �������������� ���� ������������
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

# �������� ����� ���������� � ����������� � ������� �� �������� ������.
# ���� ���� ����������� � ����� ���������� - �� ��� ����� ����� �����������...
# test_people(<������ �� ��� ������> <������ ����� � ������ ����������>)
sub test_people{
  my $data   = shift;

  die "test_people: no people\n"
    if !defined ($data->{people});

  # ����� �����
  my $u = $#{$data->{people}}+1;
  my $s = 0; # � �������� ������ ������� � ������������

  if (defined ($data->{comm_p})){
    foreach (@{$data->{comm_p}}){
      next if !defined;
      $s++ if (/���/) || (/��/);
    }
  }

  if (defined ($data->{comm})) {
    $s=$u if ($data->{comm} =~ /���/) || ($data->{comm} =~ /��/);
  }

  foreach (@_){
    next unless exists ($data->{$_});
    return 0 if ($data->{$_} > $u); # ���������� ����� ������!
    return 0 if ($u - $data->{$_} > $s); # ����� ���������� ����������� ����� ��� �� $s
    $s -= $u - $data->{$_}; # ������� ��� ����� �����
    $u = $data->{$_};       # ����� ����� ����������
  }
  return 1;
}

1;