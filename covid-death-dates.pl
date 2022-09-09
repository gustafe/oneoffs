#! /usr/bin/env perl
use Modern::Perl '2015';
###
# https://www.folkhalsomyndigheten.se/smittskydd-beredskap/utbrott/aktuella-utbrott/covid-19/statistik-och-analyser/bekraftade-fall-i-sverige/
use DateTime;

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1;F202x\#\&/g;
    return scalar reverse $text;
}


my @data;
say "<table>";
printf("<tr><th>%10s</th><th>%6s</th><th>%5s</th><th>%10s</th></tr>\n",
      'Date','Deaths','Days','Deaths/day');
while (<DATA>) {
    chomp;
    my ( $year, $month, $day, $deaths )= $_ =~ m/(\d{4})-(\d{2})-(\d{2}) (\d+)/;
    my $dt = DateTime->new(year=>$year,month=>$month,day=>$day);
    push @data, {date=>$dt,deaths=>$deaths};
}
for (my $i= 0; $i<=$#data; $i++) {
    my $deaths = $data[$i]{deaths}-$data[$i-1]{deaths} if $i>0; 
    my $days = $data[$i]{date}->delta_days($data[$i-1]{date})->delta_days() if $i>0;
    printf("<tr><td>%10s</td><td>%14s</td><td>%4d</td><td>%6.01f</td></tr>\n",
	   $data[$i]{date}->strftime("%Y-%m-%d"),
	   commify($data[$i]{deaths}), $days?$days:0, ($deaths and $days)?$deaths/$days:0);
    
}
say "</table>";
__DATA__
2020-03-11 1
2020-04-09 1000
2020-04-19 2000
2020-05-02 3000
2020-05-18 4000
2020-06-11 5000
2020-11-01 6000
2020-11-27 7000
2020-12-12 8000
2020-12-23 9000
2021-01-02 10000
2021-01-14 11000
2021-01-27 12000
2021-03-01 13000
2021-04-24 14000
2021-10-27 15000
2022-01-26 16000
2022-02-15 17000
2022-03-12 18000
2022-05-27 19000
