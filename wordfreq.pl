#!/usr/bin/perl
use strict;
use warnings;

# input: /usr/share/dict/words
my %data;
my $count;
while (<>) {
    chomp;
    # skip proper names: starting with a capital letter
    next if m/^[A-Z]/;
    # skip posssive form
    next if m/\'/;
    my @chars = split //, $_;
    foreach my $c (@chars) {
	$data{$c}++;
	$count++;
    }
}
foreach my $c ( sort keys %data ) {
    next if $data{$c}<200;
    printf("%s\t%d\t%.1f%%\n",
	   $c, $data{$c}, $data{$c}/$count*100);
}
