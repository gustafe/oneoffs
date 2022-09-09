#! /usr/bin/env perl
use Modern::Perl '2015';
###

my %hash = ( b => 42, x => 12, z => 1 );
say "    ==> dump the hash";
foreach my $key ( keys %hash ) {
    say "    $key $hash{$key}";
}
say "    ==> order by key";
foreach my $key ( sort { $a cmp $b } keys %hash ) {

    # we use 'cmp' here because the keys are strings
    say "    $key $hash{$key}";
}
say "    ==> order by value";
foreach my $key ( sort { $hash{$a} <=> $hash{$b} } keys %hash ) {

    # we use '<=>' because the values are numbers
    say "    $key $hash{$key}";
}
say "    ==> add a new key with the same value as an existing one";
$hash{y} = 12;
foreach my $key ( sort { $hash{$a} <=> $hash{$b} || $a cmp $b } keys %hash ) {
    say "    $key $hash{$key}";
}
