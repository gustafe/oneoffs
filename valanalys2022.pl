#! /usr/bin/env perl
use Modern::Perl '2015';
###
use Data::Dump qw/dump/;
use Template;
use List::Util qw/sum/;
use utf8;
binmode( STDOUT, ':encoding(UTF-8)' );

# data source: https://www.val.se/valresultat/riksdag-region-och-kommun/2022/radata-och-statistik.html#Slutligtvalresultat

# parties
my %riksdagspartier = (
    'Moderaterna'   => { total => 1_237_428, abbrev => 'M', pos => 7 },
    'Centerpartiet' => { total => 434_945,   abbrev => 'C', pos => 4 },
    'Liberalerna (tidigare Folkpartiet)' =>
        { total => 298_542, abbrev => 'L', pos => 5 },
    'Kristdemokraterna' => { total => 345_712, abbrev => 'KD', pos => 6 },
    'Arbetarepartiet-Socialdemokraterna' =>
        { total => 1_964_474, abbrev => 'S', pos => 3 },
    'Vänsterpartiet' => { total => 437_050, abbrev => 'V', pos => 1 },
    'Miljöpartiet de gröna' =>
        { total => 329_242, abbrev => 'MP', pos => 2 },
    'Sverigedemokraterna' => { total => 1_330_325, abbrev => 'SD', pos => 8 },
    'Övriga anmälda partier' =>
        { total => 100_076, abbrev => 'Övr', pos => 99 },
);

my $sum;
for my $party ( keys %riksdagspartier ) {
    $sum += $riksdagspartier{$party}->{total};
}
my %rdp_procentandel;
for my $party ( keys %riksdagspartier ) {
    $rdp_procentandel{$party} = $riksdagspartier{$party}->{total} / $sum * 100;
}

# read detailed data
my $filename
    = './Slutlig-rostdata-per-distrikt-riksdagsvalet-med-distriktkoder.csv';

open F, "<:encoding(UTF-8)", $filename or die "can't open $filename: $!";

my %partier;
my %distriktsdata;

my $current_valkrets;
while (<F>) {
    next if $. == 1;    # skip first empty line

    chomp;
    s/\r//gm;
    my @line = split( /;/, $_ );
    if ( $. == 2 ) {    # partier
        for my $idx ( 0 .. $#line ) {
            $line[$idx] =~ s/^\s//;
            $partier{$idx} = $line[$idx];
        }
        next;
    }
    next if ( $line[1] eq '' and $line[2] eq '' );  # skip last summation line
    if ( $line[1] ne '' and $line[2] eq '' ) {      # valkrets
        $current_valkrets = $line[1];
    }
    if ( $line[2] ne '' ) {                         # valdistrikt
        my $distriktkod = $line[1];
        my $total       = $line[$#line];
        for my $idx ( 3 .. $#line - 1 ) {
            if ( $line[$idx] ne '' ) {
                $distriktsdata{$distriktkod}->{ $partier{$idx} }->{num}
                    = $line[$idx];
                $distriktsdata{$distriktkod}->{ $partier{$idx} }->{pct}
                    = $line[$idx] / $total * 100;
            }

        }
        $distriktsdata{$distriktkod}->{Totalsumma}   = $total;
        $distriktsdata{$distriktkod}->{Valkrets}     = $current_valkrets;
        $distriktsdata{$distriktkod}->{Distriktnamn} = $line[2];
    }

}
close F;

my %stats;
my %max_riksdag;
sub print_distrikt;
for my $d ( keys %distriktsdata ) {
    my $sum_squares;
    for my $h ( keys %{ $distriktsdata{$d} } ) {
        next
            if ( $h eq 'Distriktnamn'
            or $h eq 'Valkrets'
            or $h eq 'Totalsumma' );
        if ( exists $rdp_procentandel{$h} ) {
            $sum_squares
                += ( $rdp_procentandel{$h} - $distriktsdata{$d}->{$h}->{pct} )
                **2;
        }
        next unless exists $riksdagspartier{$h};
        if ( exists $max_riksdag{$h} ) {
            $max_riksdag{$h}->{max} = {
                code => $d,
                pct  => $distriktsdata{$d}{$h}{pct},
                num  => $distriktsdata{$d}{$h}{num}
                }
                if $distriktsdata{$d}{$h}{pct} > $max_riksdag{$h}->{max}{pct};
            $max_riksdag{$h}->{min} = {
                code => $d,
                pct  => $distriktsdata{$d}{$h}{pct},
                num  => $distriktsdata{$d}{$h}{num}
                }
                if $distriktsdata{$d}{$h}{pct} < $max_riksdag{$h}->{min}{pct};
        }
        else {
            $max_riksdag{$h}->{max} = {
                code => $d,
                pct  => $distriktsdata{$d}{$h}{pct},
                num  => $distriktsdata{$d}{$h}{num}
            };
            $max_riksdag{$h}->{min} = {
                code => $d,
                pct  => $distriktsdata{$d}{$h}{pct},
                num  => $distriktsdata{$d}{$h}{num}
            };
        }
    }
    $stats{$d} = $sum_squares;
}

my @max_distrikt;

for my $p ( keys %max_riksdag ) {
    $max_distrikt[ $riksdagspartier{$p}->{pos} - 1 ]
        = $max_riksdag{$p}{max}{code};
}
my %distrikt_stats;

for my $d_id ( keys %distriktsdata ) {

    for my $p ( keys %{ $distriktsdata{$d_id} } ) {

        next
            if ( $p eq 'Distriktnamn'
            or $p eq 'Valkrets'
            or $p eq 'Totalsumma' );
        next if $riksdagspartier{$p};
        $distrikt_stats{$p}{total} += $distriktsdata{$d_id}{$p}{num};
        if ( exists $distrikt_stats{$p}{max_num} ) {
            if ( $distriktsdata{$d_id}{$p}{num} > $distrikt_stats{$p}{max_num}
                and $distriktsdata{$d_id}{Distriktnamn} !~ /Uppsamling/ )
            {

                $distrikt_stats{$p}{max_num} = $distriktsdata{$d_id}{$p}{num};
                $distrikt_stats{$p}{max_id}  = $d_id;
            }
        }
        else {
            $distrikt_stats{$p}{max_num} = $distriktsdata{$d_id}{$p}{num};
            $distrikt_stats{$p}{max_id}  = $d_id;
        }
    }
}

my @sorted = sort { $stats{$a} <=> $stats{$b} } keys %stats;
my $min    = $sorted[0];
my $max    = $sorted[-1];
my @abbrevs;
my @totals;
for my $p (
    sort { $riksdagspartier{$a}{pos} <=> $riksdagspartier{$b}{pos} }
    keys %riksdagspartier
    )
{
    push @abbrevs, $riksdagspartier{$p}{abbrev} if $riksdagspartier{$p}{pos};
    push @totals,  $rdp_procentandel{$p};
}
my $table;
push @$table, [ 'Närmast',       @{ print_distrikt($min) } ];
push @$table, [ 'Längst ifrån', @{ print_distrikt($max) } ];
my $count = 1;
for my $p (
    sort { $riksdagspartier{$a}{pos} <=> $riksdagspartier{$b}{pos} }
    keys %riksdagspartier
    )
{
    if ( defined $max_distrikt[ $riksdagspartier{$p}{pos} - 1 ] ) {
        my $data_row
            = print_distrikt(
            $max_distrikt[ $riksdagspartier{$p}{pos} - 1 ] );
        my $elem = $data_row->[$count];
        $data_row->[$count] = "<strong>$elem</strong>";
        push @$table, [ "Mest $riksdagspartier{$p}{abbrev}", @{$data_row} ];

    }
    $count++;
}
my @max_ovr;
for my $p (
    sort {
               $distrikt_stats{$b}{total} <=> $distrikt_stats{$a}{total}
            || $distriktsdata{ $distrikt_stats{$a}{max_id} }{Totalsumma}
            <=> $distriktsdata{ $distrikt_stats{$b}{max_id} }{Totalsumma}
    } keys %distrikt_stats
    )
{
    push @max_ovr,
        [
        $p,
        $distriktsdata{ $distrikt_stats{$p}{max_id} }{Distriktnamn} . ' ('
            . $distriktsdata{ $distrikt_stats{$p}{max_id} }{Valkrets} . ')',
        $distrikt_stats{$p}{max_num},
        commify( $distrikt_stats{$p}{total} )
        ];
}

my $tt    = Template->new( { INCLUDE_PATH => "./", ENCODING => 'UTF-8' } );
my %tdata = (
    abbrevs   => \@abbrevs,
    totals    => [ map {tr/./,/r} map { sprintf( "%.02f", $_ ) } @totals ],
    all_votes => commify(
        sum map { $riksdagspartier{$_}->{total} } keys %riksdagspartier
    ),
    table   => $table,
    max_ovr => \@max_ovr,
);
my $out = '';
$tt->process( "table.tt", \%tdata ) or die $tt->error;

sub print_distrikt {

    # return percentages per party in the Riksdag for a valdistrikt
    my ($code) = @_;
    my @out;
    my $rest_p;
    for my $p ( keys %{ $distriktsdata{$code} } ) {
        next
            if ( $p eq 'Distriktnamn'
            or $p eq 'Valkrets'
            or $p eq 'Totalsumma' );

        if ( exists $riksdagspartier{$p} ) {
            $out[ $riksdagspartier{$p}->{pos} - 1 ]
                = $distriktsdata{$code}{$p}->{pct};
        }
        else {
            $rest_p += $distriktsdata{$code}{$p}->{num};
        }
    }
    push @out,
        ( $rest_p ? $rest_p : 0 ) / $distriktsdata{$code}{Totalsumma} * 100;
    push @out, $stats{$code};
    my $return = [
        $distriktsdata{$code}{Distriktnamn}
            . '<br />('
            . $distriktsdata{$code}{Valkrets} . ')',
        map { commify($_) } map {tr/./,/r} map { sprintf( "%.2f", $_ ) } @out
    ];
    push @$return, commify( $distriktsdata{$code}->{Totalsumma} );

    return $return;
}

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1;F202x\#\&/g;
    return scalar reverse $text;
}
