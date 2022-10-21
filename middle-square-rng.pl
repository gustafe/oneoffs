#! /usr/bin/env perl
use Modern::Perl '2015';
###
use utf8;
binmode(STDOUT, ':encoding(UTF-8)');
# http://bit-player.org/2022/the-middle-of-the-square
my %data;
for my $seed (1000..9999) {
    my %seen;
    my $start = $seed;
    my $cycle = 0;
    my $count = 0;
    while (!$cycle) {
	my $square = $start * $start;
	my $new = substr( sprintf("%08d", $square), 2,4);
#	say $new;
	$seen{$new}++;
	$cycle = 1 if $seen{$new}>1;
	$start = $new;
	$count++;

    }
    $data{$seed} = $count;
}

for my $seed (sort {$a<=>$b} keys %data) {
    say "$seed $data{$seed}";
    
}
