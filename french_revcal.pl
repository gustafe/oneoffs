#! /usr/bin/env perl
use 5.016;
use warnings;
use autodie;
use utf8;
use DateTime::Calendar::FrenchRevolutionary;
###

#my $now = DateTime->now;

#my $frc = DateTime::Calendar::FrenchRevolutionary->now();
my $frc = DateTime::Calendar::FrenchRevolutionary->new(year=>229,month=>6,day=>13,hour=>9, minute=>99, second=>99);
# Use the date "18 Brumaire VIII"

binmode (STDOUT, ":utf8");
say $frc->strftime("%A, %d %B %EY %H:%M:%S (%EJ)");
say $frc->abt_hms();
say $frc->hms();
say $frc->iso8601();
#say $frc->local_rd_as_seconds();
