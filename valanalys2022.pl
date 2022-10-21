#! /usr/bin/env perl
use Modern::Perl '2015';
###
use Data::Dump qw/dump/;
use Template;
use utf8;
binmode(STDOUT, ':encoding(UTF-8)');

# data source: https://www.val.se/valresultat/riksdag-region-och-kommun/2022/radata-och-statistik.html#Slutligtvalresultat

# parties
my %top_level = (
'Moderaterna'=>{total=>1_237_428,abbrev=>'M',pos=>7},
'Centerpartiet'=>{total=>434_945,abbrev=>'C',pos=>4},
'Liberalerna (tidigare Folkpartiet)'=>{total=>298_542,abbrev=>'L',pos=>5},
'Kristdemokraterna'=>{total=>345_712,abbrev=>'KD',pos=>6},
'Arbetarepartiet-Socialdemokraterna'=>{total=>1_964_474,abbrev=>'S',pos=>3},
'Vänsterpartiet'=>{total=>437_050,abbrev=>'V',pos=>1},
'Miljöpartiet de gröna'=>{total=>329_242,abbrev=>'MP',pos=>2},
'Sverigedemokraterna'=>{total=>1_330_325,abbrev=>'SD',pos=>8},
'Övriga anmälda partier'=>{total=>100_076,abbrev=>'Övr',pos=>99},);

my $sum;
for my $party (keys %top_level) {
    $sum += $top_level{$party}->{total};
}
my %percentages;
for my $party (keys %top_level) {
    $percentages{$party} = $top_level{$party}->{total}/$sum * 100 ;
}
for my $p (sort {$top_level{$a}->{pos} <=> $top_level{$b}->{pos} } keys %top_level) {
    say "$p ($top_level{$p}->{abbrev}) $percentages{$p}";
}
# read detailed data
my $filename = './Slutlig-rostdata-per-distrikt-riksdagsvalet-med-distriktkoder.csv';

open F, "<:encoding(UTF-8)",$filename or die "can't open $filename: $!";

my %headings;
my %data;

sub print_distrikt {
    my ( $code )= @_;
    my @out;
    my $rest_p;
    for my $p (keys %{$data{$code}}) {
	next if ($p eq 'Distriktnamn' or $p eq 'Valkrets' or $p eq 'Totalsumma' );
	
	if (exists $top_level{$p}) {
	    $out[$top_level{$p}->{pos}-1] = $data{$code}{$p}->{pct};
	} else {
	    $rest_p += $data{$code}{$p}->{num};
	}
    }
    push @out, ($rest_p?$rest_p:0) / $data{$code}{Totalsumma} * 100;
    
    say join(" ",$data{$code}{Distriktnamn}.' ('.$data{$code}{Valkrets}.')', map {sprintf("%.2f",$_)} @out);
    return [$data{$code}{Distriktnamn}.' ('.$data{$code}{Valkrets}.')', map {sprintf("%.2f",$_)} @out];
}

my $current_valkrets;
while (<F>) {
    next if $. == 1; # skip first empty line

    chomp;
    s/\r//gm;
    my @line = split(/;/, $_);
    if ($.==2) { # headings
	for my $idx (0.. $#line) {
	    $line[$idx] =~ s/^\s//;
	    $headings{$idx}= $line[$idx];
	}
	next;
    }
    next if ( $line[1] eq '' and $line[2] eq ''); # skip last summation line
    if ($line[1] ne '' and $line[2] eq '') { # valkrets
	$current_valkrets = $line[1];
    }
    if ($line[2] ne '') { # valdistrikt
	my $distriktkod = $line[1];
	my $total = $line[$#line];
	for my $idx (3..$#line-1) {
	    if ($line[$idx] ne '' ) {
		$data{$distriktkod}->{$headings{$idx}}->{num} = $line[$idx];
		$data{$distriktkod}->{$headings{$idx}}->{pct} = $line[$idx]/$total*100;
	    }

	    
	}
	$data{$distriktkod}->{Totalsumma} = $total;
	$data{$distriktkod}->{Valkrets} = $current_valkrets;
	$data{$distriktkod}->{Distriktnamn} = $line[2];
    }

}
close F;

my %stats;
my %min_max;
for my $d (keys %data) {
    my $sum_squares;
    for my $h (keys %{$data{$d}}) {
	next if ( $h eq 'Distriktnamn' or $h eq 'Valkrets' or $h eq 'Totalsumma');
	if (exists $percentages{$h}) {
	    $sum_squares += ( $percentages{$h}-$data{$d}->{$h}->{pct})**2;
	}
	next unless exists $top_level{$h};
	if (exists $min_max{$h}) {
	    $min_max{$h}->{max} = {code=>$d, pct=>$data{$d}{$h}{pct}, num=>$data{$d}{$h}{num}} if $data{$d}{$h}{pct}>$min_max{$h}->{max}{pct};# and $data{$d}{Distriktnamn} !~ /Uppsamling/; 
	    $min_max{$h}->{min} = {code=>$d, pct=>$data{$d}{$h}{pct},num=>$data{$d}{$h}{num}} if $data{$d}{$h}{num}<$min_max{$h}->{min}{num};
	} else {
	    $min_max{$h}->{max}={code=>$d, pct=>$data{$d}{$h}{pct},num=>$data{$d}{$h}{num}};
	    $min_max{$h}->{min}={code=>$d, pct=>$data{$d}{$h}{pct},num=>$data{$d}{$h}{num}};
	}
    }
    $stats{$d} = $sum_squares;
}

my @max_distrikt;

for my $p (keys %min_max) {
    $max_distrikt[$top_level{$p}->{pos}-1] = $min_max{$p}{max}{code};
#    say "$p max: $data{$min_max{$p}{max}{code}}->{Distriktnamn} ($data{$min_max{$p}{max}{code}}->{Valkrets}) ".sprintf("%.02f%%",$min_max{$p}->{max}{pct})." ".$min_max{$p}->{max}{num};
}


my @sorted  = sort {$stats{$a}<=>$stats{$b} } keys %stats;
my $min = $sorted[0];
my $max = $sorted[-1];
my @abbrevs; my @totals;
for my $p (sort {$top_level{$a}{pos}<=>$top_level{$b}{pos}} keys %top_level) {
    push @abbrevs, $top_level{$p}{abbrev} if $top_level{$p}{pos};
    push @totals, $percentages{$p};
}
my $table;
push @$table, ['Närmast', @{print_distrikt($min)}];
push @$table, ['Längst ifrån', @{print_distrikt($max)}];
for my $p (sort {$top_level{$a}{pos}<=>$top_level{$b}{pos}} keys %top_level) {
    if (defined $max_distrikt[$top_level{$p}{pos}-1]) {
	push @$table, ["Mest $top_level{$p}{abbrev}", @{    print_distrikt( $max_distrikt[$top_level{$p}{pos}-1]) }];
    }
}
my $tt= Template->new( {INCLUDE_PATH=>"./", ENCODING=>'UTF-8'});
my %tdata = ( abbrevs =>\@abbrevs,
	     totals => [map {sprintf("%.02f", $_)}@totals]			,
	      table=>$table,
	   );
my $out='';
$tt->process("table.tt", \%tdata) or die $tt->error;
say join(" ", "Parti", @abbrevs);
say join("  ", "Riket", map {sprintf("%.02f", $_)} @totals);
print "Mest normal: " ;print_distrikt( $min );
print "Mest avvikande: "; print_distrikt( $max );
for my $p (sort {$top_level{$a}{pos}<=>$top_level{$b}{pos}} keys %top_level) {
    print "Max $top_level{$p}{abbrev}: ";
    print_distrikt( $max_distrikt[$top_level{$p}{pos}-1]) if defined $max_distrikt[$top_level{$p}{pos}-1];
}

__END__
for my $p (sort keys %min_max) {
    
    say "$p max: $data{$min_max{$p}{max}{code}}->{Distriktnamn} ($data{$min_max{$p}{max}{code}}->{Valkrets}) ".sprintf("%.02f%%",$min_max{$p}->{max}{pct})." ".$min_max{$p}->{max}{num};
}


  for my $d (sort keys %data) {
    say "==> $d $data{$d}->{Distriktnamn} ($data{$d}->{Valkrets}): $data{$d}->{Totalsumma} röster";
    for my $h (sort keys %{$data{$d}}) {
	next if ( $h eq 'Distriktnamn' or $h eq 'Valkrets' or $h eq 'Totalsumma');
	say "$h $data{$d}->{$h}{num} ".sprintf("%.02f", $data{$d}->{$h}{pct});
    }
}


