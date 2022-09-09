#! /usr/bin/env perl
use Modern::Perl '2015';
use Data::Dump qw/dump/;
use Test::More tests => 1;
my $input  = 'aaaabbbcca';
my $target = '[("a", 4), ("b", 3), ("c", 2), ("a", 1)]';
my @list   = split( //, $input );
my @output = ( { c => shift @list, n => 1 } );
while (@list) {
    my $c = shift @list;
    if   ( $c eq $output[-1]->{c} ) { $output[-1]->{n}++ }
    else                            { push @output, { c => $c, n => 1 } }
}
my $string = join( ', ',
    map { sprintf( "(\"%s\", %d)", $_->{c}, $_->{n} ) } @output );
is( "[$string]", $target, "[$string]" );

