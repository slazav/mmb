package reg;

use strict;
use warnings;
use MMB::Names;

#################################################################
sub data_read{
  my $file = shift;
  my $data = shift;

  my @fields = ('name', 'gps', 'dist', 'maps', 'mail', 'md5',
    'u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8', 'u9');

  die "Не могу найти файл: $file\n" if (!open(DAT, "$file"));

  my $n=0;
  foreach(<DAT>){
    my $l = $_;
    if ($l=~/^n:\s+(\d+)\s*$/) {$n=$1;}
    foreach (@fields){
      if ($l=~/^$_:\s+(.*)\s*$/) {
        die "повторяется поле $_ в записи $n\n" 
          if exists ($data->[$n]->{$_});
        $data->[$n]->{$_}=$1;
      }
    }
  }
  for ($n=0; $n<= $#{$data}; $n++){
    next if (!defined($data->[$n]));
    foreach (@fields){ 
      $data->[$n]->{$_}='' if !exists $data->[$n]->{$_};
    }
  }
  close(DAT);
  die "Пустой файл: $file\n" if ($#{$data} == -1);
  return $data;
}
#################################################################

sub count_dist{
  my @data=@{shift()};
  my $dist_regexp = shift;

  my $nu=0;
  my $nc=0;
  my $ng=0;

  for (my $n=0; $n<= $#data; $n++){
    next if ((!defined($data[$n])) || 
      (defined($dist_regexp) && ($data[$n]->{dist}!~/$dist_regexp/)));
    $nc++;
    $ng++ if ($data[$n]->{gps} eq 'on');
    foreach (1..9){
      $nu++ if ($data[$n]->{"u$_"} ne '');
    }
  }
  return ($nc, $nu, $ng);
}

#################################################################
sub html_cell{
  my @data=@{shift()};
  my $n = shift;
  my %comm = defined($_[0])? %{shift()}:();

  return if !defined($data[$n]);

  my $out='';
  my $u0=1;
  $out.= "<td valign=top align=right><a name=\"$n\"></a>$n</td>";
  $out.= "<td valign=top align=left>";
#  if ($data[$n]->{name} ne ''){$out.= $data[$n]->{name};}
#  else
#    {$out.= "<font color=\"#006000\">$data[$n]->{u1}</font>"; $u0=2;}
#  $out.= "\n&nbsp;&nbsp;<font color=\"#880000\">(gps)</font>"
#    if ($data[$n]->{gps} eq 'on');
#  $out.= "\n<font color=\"#006000\">";
#  foreach ($u0..9){
#    $out.= "\n<br>".$data[$n]->{"u$_"}
#      if ($data[$n]->{"u$_"} ne '');
#  }
#  $out.= "\n</font></td>";
  if ($data[$n]->{name} ne ''){$out.= "<b><u>".$data[$n]->{name}."</b></u>";}
  else {
    $out.= "$data[$n]->{u1}"; $u0=2;
    if (exists($comm{"$n-1"})) { $out.= "<br><font size=-1 color=\"#880000\">(".$comm{"$n-1"}.")</font>";}
  }
  if (exists($comm{$n})) { $out.= "<br><b><font size=-1 color=\"#880000\">(".$comm{$n}.")</font></b>";}
  $out.= "\n&nbsp;&nbsp;<font color=\"#880000\">(gps)</font>"
    if ($data[$n]->{gps} eq 'on');
  foreach ($u0..9){
    $out.= "\n<br>".$data[$n]->{"u$_"}
      if ($data[$n]->{"u$_"} ne '');
    if (exists($comm{"$n-$_"})) { $out.= "<br><font size=-1 color=\"#880000\">(".$comm{"$n-$_"}.")</font>";}
  }
  $out.= "\n</td>";
  return $out;
}
#################################################################

sub tex_cell{
  my @data=@{shift()};
  my $n = shift;

  my $out='';


  $data[$n]->{name}=~s/\"([^\"]*)\"/<<$1>>/g;
  $data[$n]->{name}=~s/_/\\_/g;

  $out.= "\\sffamily\\mbox{\\bfseries \\hbox to 22pt{\\hfil $n.~}$data[$n]->{name}}\\hfill";
  $out.= "\\textit{gps}"
    if ($data[$n]->{gps} eq 'on');
  foreach (1..9){
    $out.= "\\par\n\\mbox{\\hspace{22pt}".$data[$n]->{"u$_"}. "\\hfill}"
      if ($data[$n]->{"u$_"} ne '');
  }
  return $out;
}

sub tex_cell_new{
  my $data=shift();
  my $n=shift();

  return "\\sffamily\\mbox{\\bfseries \\hbox to 22pt{\\hfil $n.~} }\\hfill". 
    "\\par\n\\mbox{\\hspace{22pt}\\hfill}".
    "\\par\n\\mbox{\\hspace{22pt}\\hfill}"
    if (!defined($data));

  my $out='';

  $data->{name}=~s/\"([^\"]*)\"/<<$1>>/g;
  $data->{name}=~s/_/\\_/g;

  $out.= "\\sffamily\\mbox{\\bfseries \\hbox to 22pt{\\hfil $n.~}$data->{name}}\\hfill";
  $out.= "\\textit{gps}"
    if ($data->{gps} eq 'on');
  foreach (1..9){
    $out.= "\\par\n\\mbox{\\hspace{22pt}".$data->{"u$_"}. "\\hfill}"
      if ($data->{"u$_"} ne '');
  }
  return $out;
}

1;
__END__
#################################################################

sub modif_names{
  my @data=@{shift()};

  my $Rus = '[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ]';
  my $rus = '[абвгдеёжзийклмнопрстуфхцчшщъыьэюя\/\-]';

  for (my $n=0; $n<=$#data; $n++){
    next if !defined($data[$n]);
    foreach(1..9){
      next if $data[$n]->{"u$_"} eq '';

      my ($n1,$n2,$y);

      $data[$n]->{"u$_"} =~ s/Петр /Пётр /;
      $data[$n]->{"u$_"} =~ s/Леня /Лёня /;
      $data[$n]->{"u$_"} =~ s/Семен /Семён /;
      $data[$n]->{"u$_"} =~ s/Артем /Артём /;
      $data[$n]->{"u$_"} =~ s/Алена /Алёна /;
      $data[$n]->{"u$_"} =~ s/Аленка /Алёнка /;
      $data[$n]->{"u$_"} =~ s/Петр,/Пётр,/;
      $data[$n]->{"u$_"} =~ s/Леня,/Лёня,/;
      $data[$n]->{"u$_"} =~ s/Семен,/Семён,/;
      $data[$n]->{"u$_"} =~ s/Артем,/Артём,/;
      $data[$n]->{"u$_"} =~ s/Алена,/Алёна,/;
      $data[$n]->{"u$_"} =~ s/Аленка,/Алёнка,/;
      $data[$n]->{"u$_"} =~ s/\([^\)]*\)//g;
 
      if ($data[$n]->{"u$_"} =~ 
        /^($Rus?$rus*)[,\s]+($Rus?$rus*\.?)[,\s]*(\d+)/){
        ($n1,$n2,$y) = ($1,$2,$3);
      }
      elsif ($data[$n]->{"u$_"} =~
        /^($Rus?$rus*)[,\s]+($Rus?$rus*\.?)[,\s]+$Rus?$rus*\.?[,\s]*(\d+)/){
        ($n1,$n2,$y) = ($1,$2,$3);
      }
      elsif ($data[$n]->{"u$_"} =~
        /^($Rus?$rus*)[,\s]+($Rus?$rus*\.?)/){
        ($n1,$n2,$y) = ($1,$2,'');
      }
      else {print STDERR "Looks strange: ", $data[$n]->{"u$_"}, "\n"; next;}

      $y += 1900 if ($y ne '') && ($y<100);

      my $un=1;
      foreach (@MMB::names){
        if ($n1 eq $_){
          my $nn=$n1;
          $n1=$n2;
          $n2=$nn;
        }
        $un=0 if ($n2 eq $_);
      }
      my $old = $data[$n]->{"u$_"};
      if ($y ne '') {$data[$n]->{"u$_"} = "$n1 $n2, $y";}
      else {$data[$n]->{"u$_"} = "$n1 $n2";}
      print STDERR "$old --> ", $data[$n]->{"u$_"},"\n" if ($data[$n]->{"u$_"} ne $old);
      print STDERR "Unknown name: $n1 $n2, $y\n" if ($un==1);
    }
  }
}
#################################################################


1;