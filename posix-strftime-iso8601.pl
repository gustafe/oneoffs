#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(strftime);

#my $now = gmtime();
print POSIX::strftime("%FT%TZ", gmtime()), "\n";
