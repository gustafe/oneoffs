#!/usr/bin/perl -w
use strict;
print << "EOH";
<blockquote>
<h4>Imperial System</h4>
<p style="line-height: 1em; font-size: 80%">
<em>mel. Students&aring;ngen</em><br />
<em>Prins Frans Gustaf Oscar</em>
</p>
<p style="line-height: 2em">
EOH
while ( <DATA> ) {
    chomp;
    if ( m/^(.*)\t(.*)$/ ) {
	my ( $acronym, $expansion ) = ( $1, $2 );
	print '<acronym title="' . $expansion . '">' . $acronym . '</acronym>&nbsp;&nbsp;&nbsp;';	
    } else {
	print "<br />\n";
    }
}

print << "EOF";
</p>
</blockquote>
EOF

# <acronym title="$expansion">$1<\/acronym>

__END__
ft	fot
kp	kilopond
K	Kayser
bu	Bushel
B	Beaufort

&Prime;	tum
Gb	Gilbert
Oe	Oersted
lb	pund
rdr	riksdaler
std	standard

st	Stadion
msk	matsked
kn	knop
E	e&ouml;tv&ouml;s

Fr	Franklin
krm	kryddm&aring;tt
c	carat
cSt	centiStoke

&deg;F	grader Fahrenheit

pt	punkt
&ndash;	streck
&Prime;	sekund
&prime;	minut

at	teknisk atmosf&auml;r

hk	h&auml;stkraft
nmi	nautisk mil

M	mach
Ci	curie
dptr	dioptri
cal	kalori

mvp	meter vattenpelare

mvp	meter vattenpelare

ha!	hektar
