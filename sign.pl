#! /usr/bin/env perl
use Modern::Perl '2015';
###

sub sign {
    my ( $n ) = @_;
    return ( $n>0 && 1) || ( $n<0 && -1) || ($n==0 && 0)
}

for (<DATA>) {
    chomp;
    say "$_ ",sign( $_ );
}

__END__
1
-1
0
100
-100
