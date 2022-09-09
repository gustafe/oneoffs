#! /usr/bin/env perl
use Modern::Perl '2015';
###

sub fizzbuzz {
    if ($_%3==0 and $_%5==0) {
	return 'fizzbuzz'
    }

    if ($_%3==0) {
	return 'fizz'
    }
    if ($_%5==0) {
	return 'buzz'
    }
    return $_;
}

map {say "$_ => ".fizzbuzz($_)} (1..20);
