#! /usr/bin/env perl
use Modern::Perl '2015';
use Time::Seconds;
###

sub hum_duration {

    # in: seconds
    # out: nicely formatted string years, months, days
    my ($s) = @_;
    my %pieces = ( year => 0, month => 0, day => 0 );
    my $v = Time::Seconds->new($s);
    my $long_years;

    # check for years
    if ( $v->years > 0 ) {

        # don't bother w/ years > 500
        if ( $v->years > 500 ) {
            $long_years = sprintf( "%.02f years", $v->years );
        }

        # grab the integer part, remove years from duration

        $pieces{year} = int( $v->years );
        $s            = $s - $pieces{year} * 365 * 24 * 3600;
        $v            = Time::Seconds->new($s);
    }
    if ( $v->months > 0 ) {
        $pieces{month} = int( $v->months );
        $s             = $s - $pieces{month} * 30 * 24 * 3600;
        $v             = Time::Seconds->new($s);
    }
    if ( $v->days > 0 ) {
        $pieces{day} = sprintf( "%.0f", $v->days );    # use rounding
    }
    my $out;
    foreach my $u (qw(year month day)) {
        next if $pieces{$u} == 0;
        my $suffix = $pieces{$u} > 1 ? $u . 's' : $u;
        push @$out, $pieces{$u} . ' ' . $suffix;
    }

    #    return join(', ',@$out);
    # http://blog.nu42.com/2013/10/comma-quibbling-in-perl.html - "If
    # the maintenance programmer has issues with the use of the array
    # slice and range operator above, s/he might use this as an
    # opportunity to learn about them."
    return $long_years if ( defined $long_years );
    my $n = @$out;
    return $out->[0] if $n == 1;
    return join(
        ' and ' => join( ', ' => @$out[ 0 .. ( $n - 2 ) ] ),
        $out->[-1],
    );
}

say hum_duration(4921994);
