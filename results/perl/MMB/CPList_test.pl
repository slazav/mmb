#!/usr/bin/perl -w
use strict;
use CPList;

my $test_str1 = "1,2,6,a,b,d,a1,a2,a5,a14,b1,b2,c1,c2";
my $test_str2 = "1-8,9-14,1,2,3,a-d,b,a1-a4,b1-b2";

foreach (split /,/, $test_str1){
  my $ka  = $_;
  my $ki  = MMB::CPList::a2i($ka);
  print "$ka -- ", $ki, 
        " -- ", MMB::CPList::i2a($ki),
        " +1 ", MMB::CPList::i2a(MMB::CPList::iinc($ki)), 
        " -- ", MMB::CPList::ainc($ka), 
        "\n";
}

sub print_test{
  my $x = shift;
  my $y = shift;
  print "group $x - $y ", (MMB::CPList::agtest($x, $y) ? 'ok':'fail'), "\n";
}

print_test(1,5);
print_test(5,1);

print_test("a","a1");
print_test("a","d");
print_test("a2","a15");
print_test("a2","c1");
print_test("a0","c");
print_test("a5","b");
print_test("a","a");

print $test_str2, "\n";
my @cp=MMB::CPList::unpack_list($test_str2);
print join " ", @cp, "\n";
print MMB::CPList::pack_list(@cp), "\n\n";

print MMB::CPList::cp_pen($test_str2, {"1-9", 30, "10-14", 20, "a-d", 25, "a1-a10", 28, "b1-b2", 100}), "\n";

print MMB::CPList::repack_list("1-13,23-24,43,45"), "\n";
print MMB::CPList::repack_list("1-13,23,24"), "\n";
