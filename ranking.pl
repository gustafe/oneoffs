#! /usr/bin/env perl
###

=pod

=head1 Source

<https://lobste.rs/s/ionz4l/ranking_list_algorithm_elixir>

<https://enpo.no/2020/2020-02-19-ranking-list-algorithm-in-elixir.html>

=head1 Rules 

=over 1

=item 1. The ranking starts at 1.

=item 2. If two or more participants share the same number of points, they should get the same ranking.

=item 3. The ranking should indicate how many participants are ranked higher than any given rank.

=back

=begin text

Input data

      %{id: 1, points: 39},
      %{id: 2, points: 26},
      %{id: 3, points: 50},
      %{id: 4, points: 24},
      %{id: 5, points: 39},
      %{id: 6, points: 67},
      %{id: 7, points: 39},
      %{id: 8, points: 50},
      %{id: 9, points: 48},
      %{id: 10, points: 24}

Results

  %{id: 6, points: 67, ranking: 1},
  %{id: 3, points: 50, ranking: 2},
  %{id: 8, points: 50, ranking: 2},
  %{id: 9, points: 48, ranking: 4},
  %{id: 1, points: 39, ranking: 5},
  %{id: 5, points: 39, ranking: 5},
  %{id: 7, points: 39, ranking: 5},
  %{id: 2, points: 26, ranking: 8},
  %{id: 4, points: 24, ranking: 9},
  %{id: 10, points: 24, ranking: 9}

=end text

=cut
use Modern::Perl '2015';
use Test::More;

my %hist;

while (<DATA>) {
    chomp;
    push @{ $hist{$_} }, $.; # assign line number as id, counting from 1
}
my $rank       = 1;
my $teststring = '';
foreach my $score ( sort { $b <=> $a } keys %hist ) {
    foreach my $id ( @{ $hist{$score} } ) {
        printf( "id: %2d, points: %2d, ranking: %d\n", $id, $score, $rank );
        $teststring .= $id . $rank;
    }
    $rank += scalar @{ $hist{$score} };
}

is( $teststring, '613282941555752849109', 'pass' );
done_testing();


__DATA__
39
26
50
24
39
67
39
50
48
24
