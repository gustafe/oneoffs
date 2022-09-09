#!/usr/bin/perl 

use strict;
use warnings;

sub replace {
    my ($input) = @_;
    $input =~ s(f/(\d+|\d\.\d|\d-\d|\d-\d\.\d|\d\.\d-\d|\d.\d-\d\.\d))(&#x0192;/$1)g;
    return $input;
}

while ( <DATA> )  {
    chomp;
    print join(' ', ($_, '->', replace($_))), "\n";
}

__END__
f/3.5
f/22
Nikkor 18mm f/3.5 lens
Sigma 18-50mm f/3.5-5.6 AF
Nikon 135mm f/2.8.
I have 2 lenses, a Sigma 18-50mm f/3.5-5.6 AF and a Nikkor 18mm f/3.5.
