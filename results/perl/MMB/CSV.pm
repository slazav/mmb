package MMB::CSV;

use strict;
use warnings;

sub quote{
  my $word = shift;
  return '' if !defined $word;
  $word =~ s/\"/\\\"/g;
  return "\"$word\"";
}

sub DumpH{
  my $out = '"N", "dist", "gps", "name", "comm", "people", "comm_u"';
  foreach (@_){
    $out.= ", ".quote($_);
  }
  return $out;
}

sub Dump{
  my $data=shift;
  return if !defined($data);

  my @comm_u = (exists $data->{comm_u})? @{$data->{comm_u}}:();

  my $out =
    quote($data->{N}). ", ". 
    quote($data->{dist}). ", ".
    quote(($data->{gps} eq 'on')? 'gps':''). ", ".
    quote($data->{name}). ", ".
    quote($data->{comm}). ", ".
    quote(join('; ', @{$data->{people}})). ", ".
    quote(join('; ', @comm_u));
  foreach (@_){
    $out.= ", ".quote($data->{$_});
  }
  return $out;
}

1;