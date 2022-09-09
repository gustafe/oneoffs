#! /usr/bin/env perl
use Modern::Perl '2015';
###
# inspired by https://lobste.rs/s/xqazh2/julia_used_multiple_dispatch_it_s_super
my %utterances = (
    0.5 => "it is not very effective",
    1   => "it is normal effective",
    2   => "it is super effective!",
    0   => "it has no effect",
   -1   => "type not recognized!"
		  
);

my @types = qw/normal fire water electric grass ice fighting poison ground/;
my %allowed = map { $_=>1 } @types;

# first key is attacker, second is defender, value is effect
my $effects = {
    fire  => { fire => 0.5, grass => 2,   ice    => 2, water => 0.5 },
    water => { fire => 2,   grass => 0.5, ground => 2, water => 0.5 },
    electric => { water => 2, electric => 0.5, grass => 0.5, ground => 0 },
    grass =>
        { fire => 0.5, water => 2, grass => 0.5, poison => 0.5, ground => 2 },
    ice => { fire => 0.5, water => 0.5, grass => 2, ice => 0.5, ground => 2 },
    fighting => { normal => 2, ice      => 2,   poison => 0.5 },
    poison   => { grass  => 2, poison   => 0.5, ground => 0.5 },
    ground   => { fire   => 2, electric => 2,   grass  => 0.5, poison => 2 },
};

sub result {
    my ( $attacker, $defender ) = @_;
    if (!$allowed{$attacker} or !$allowed{$defender}) {
	return -1;
    }
    if ( exists $effects->{$attacker}->{$defender} ) {
        return $effects->{$attacker}->{$defender};
    }
    else {
        return 1;
    }
}
push @types, 'clown';
for ( my $i = 0; $i < scalar @types; $i++ ) {
    for ( my $j = 0; $j < scalar @types; $j++ ) {
        say "$types[$i] attacks $types[$j], ",
            $utterances{ result( $types[$i], $types[$j] ) };
    }
}
