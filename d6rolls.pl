#! /usr/bin/env perl
use Modern::Perl '2015';
###

sub D {
    my ($sides) = @_;
    return 1 + int rand $sides;
}

sub roll_dice {
my $m = 1;
my $mark = undef;
my $d = D(6);
my $t = D(6);
my $roll =1;
my $history;
push @$history, sprintf("r=%2d d=%2d t=%2d m=%2d", $roll,$d,$t,$m);
if ($d==1) {
    while ($t<4) {
	if ($t==1 and !$m) {
	    $m=1
	} elsif ($t==1 and $m) {
	    $mark = 'fumble'
	} else {
	    $m=0
	}
	$d--;
	$t=D(6);
	$roll++;
	push @$history,  sprintf("r=%2d d=%2d t=%2d m=%2d", $roll,$d,$t,$m);
    }
}

if ($d==6) {
    while ($t>3) {
	if ($t==6 and !$m) {
	    $m=1
	} elsif ($t==6 and $m) {
	    $mark='critical'
	} else {
	    $m=0
	}
	$d++;
	$t=D(6);
	$roll++;
	push @$history, sprintf("r=%2d d=%2d t=%2d m=%2d", $roll,$d,$t,$m);
    }
}
return [ $d, $roll, $mark, $history];
#printf( "score=%d after %d %s ",	 $d, $roll, $roll == 1? 'roll' : 'rolls' );
#defined $mark ? say "($mark)" : say '';

}
my $target = 10;
my $n = 0;
while ($n < $target) {
    my $res = roll_dice;
    if ($res->[1]>1) {
	for my $line ( @{$res->[-1]}) {
	    say $line;
	}
	printf(" score=%2d after  %2d %s ",	 $res->[0], $res->[1], $res->[1] == 1? 'roll' : 'rolls' );
	defined $res->[2] ? say "($res->[2])" : say '';
	$n++;
    }

}



