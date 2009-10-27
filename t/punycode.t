#!perl -w

use strict;
use utf8;
use Test::More tests => 5;
use URI::_punycode qw(encode_punycode decode_punycode);

my %RFC_3492 = (
    A => {
        desc => "Arabic (Egyptian)",
	unicode => udecode("u+0644 u+064A u+0647 u+0645 u+0627 u+0628 u+062A u+0643 u+0644 u+0645 u+0648 u+0634 u+0639 u+0631 u+0628 u+064A u+061F"),
	ascii => "egbpdaj6bu4bxfgehfvwxn",
    },
    S => {
	unicode => "\$1.00",
	ascii =>   "\$1.00",
    },
);

is encode_punycode("bücher"), "bcher-kva", "http://en.wikipedia.org/wiki/Punycode example encode";
is decode_punycode("bcher-kva"), "bücher", "http://en.wikipedia.org/wiki/Punycode example decode";

for my $test_key (sort keys %RFC_3492) {
    my $test = $RFC_3492{$test_key};
    is encode_punycode($test->{unicode}), $test->{ascii}, "$test_key encode";
    is decode_punycode($test->{ascii}), $test->{unicode}, "$test_key decode" unless $test_key eq "S";
}

sub udecode {
    my $str = shift;
    my @u;
    for (split(" ", $str)) {
	/^u\+[\dA-F]{2,4}$/ || die "Unexpected ucode: $_";
	push(@u, chr(hex(substr($_, 2))));
    }
    return join("", @u);
}
