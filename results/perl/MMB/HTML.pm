package MMB::HTML;

use strict;
use warnings;

sub res_place{
  my $r = defined($_[0])?
              "<td align=center><font size=\"+1\">$_[0]</font></td>\n":
              "<td></td>\n";
  my $m = defined($_[1])?
              "<td align=center><font color=\"#F00000\" size=\"+1\">$_[1]</font></td>\n":
              "<td></td>\n";
  return $r.$m;
}

sub res_place1{
  my $r = defined($_[0])?
              "<td align=center>$_[0]</td>\n":
              "<td></td>\n";
  my $m = defined($_[1])?
              "<td align=center>$_[1]</td>\n":
              "<td></td>\n";
  return $r.$m;
}

sub people{
  my $data=shift;
  return if !defined($data);

  my $out='';

  my $gps = (exists($data->{gps}) && ($data->{gps} eq 'on'))?
    "\n<br><font color=\"#880000\">(gps)</font>":'';

  $out.= "\n<td valign=top align=right><a name=\"$data->{N}\"></a>$data->{N}$gps</td>\n";

  $out.= "<td valign=top align=left>";
  $out.= "<b><u>$data->{name}</b></u><br>\n" if exists $data->{name};
  $out.= "<b><font size=-1 color=\"#880000\">($data->{comm})</font></b><br>\n" if exists $data->{comm};

  my @p  = @{$data->{people}};

  for (my $i = 0; $i<=$#p; $i++){
    $out.= "<br>" if ($i != 0);
    $out.= $p[$i];

    $out.= "<br><font size=-1 color=\"#880000\">-- ${$data->{comm_p}}[$i]</font>\n"
      if (exists $data->{comm_p}) && (defined ${$data->{comm_p}}[$i]);
  }
  $out.= "</td>\n";
  return $out;
}


our $counter = '
<!--Rating@Mail.ru COUNTEr--><a target=_top
href="http://top.mail.ru/jump?from=991443"><img
src="http://d0.c2.bf.a0.top.list.ru/counter?id=991443;t=49"
border=0 height=31 width=88
alt="Рейтинг@Mail.ru"/></a><!--/COUNTER-->
';

our $styles = '
<style type="TEXT/CSS">
TH {font-family: sans-serif; font-size:15px; background-color: #A0A0A0;}
TD {font-family: sans-serif; font-size:15px; background-color: #C0C0C0;}
</style>
';


1;