#!/usr/bin/perl
 
use Term::ProgressBar 2.00;
use constant MAX => 100_000;
my $max = MAX;

  my $progress = Term::ProgressBar->new({
      name  => 'Powers',
      count => $max,
      ETA   => 'linear',
  });
  $progress->max_update_rate(1);
  my $next_update = 0;
 
  for (0..$max) {
      my $is_power = 0;
      for (my $i = 0; 2**$i <= $_; $i++) {
      if ( 2**$i == $_ ) {
          $is_power = 1;
          $progress->message(sprintf "Found %8d to be 2 ** %2d", $_, $i);
      }
  }
 
  $next_update = $progress->update($_)
    if $_ > $next_update;
}
$progress->update($max)
    if $max >= $next_update;


__END__

my $progress = Term::ProgressBar->new({name => 'Powers', count => $max, remove => 1});
$progress->minor(0);
my $next_update = 0;
 
for (0..$max) {
    my $is_power = 0;
    for (my $i = 0; 2**$i <= $_; $i++) {
        $is_power = 1 if 2**$i == $_;
    }
 
    $next_update = $progress->update($_) if $_ >= $next_update;
}
 
$progress->update($max) if $max >= $next_update;


my $progress = Term::ProgressBar->new($max);
 
for (0..$max) {
    my $is_power = 0;
    for (my $i = 0; 2**$i <= $_; $i++) {
        $is_power = 1 if 2**$i == $_;
    }
 
    $progress->update($_)
}


my $progress = Term::ProgressBar->new(MAX);
 
for (0..MAX) {
    my $is_power = 0;
    for (my $i = 0; 2**$i <= $_; $i++) {
        $is_power = 1 if 2**$i == $_;
    }
 
    if ($is_power) {
        $progress->update($_);
    }
}
