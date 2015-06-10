use strict;
use warnings;

use utf8;
use Test::More tests => 15;
use URI::_punycode qw(encode_punycode decode_punycode);

my %RFC_3492 = (
    A => {
	unicode => udecode("u+0644 u+064A u+0647 u+0645 u+0627 u+0628 u+062A u+0643 u+0644 u+0645 u+0648 u+0634 u+0639 u+0631 u+0628 u+064A u+061F"),
	ascii => "egbpdaj6bu4bxfgehfvwxn",
    },
    B => {
	unicode => udecode("u+4ED6 u+4EEC u+4E3A u+4EC0 u+4E48 u+4E0D u+8BF4 u+4E2D u+6587"),
	ascii => "ihqwcrb4cv8a8dqg056pqjye",
    },
    E => {
	unicode => udecode("u+05DC u+05DE u+05D4 u+05D4 u+05DD u+05E4 u+05E9 u+05D5 u+05D8 u+05DC u+05D0 u+05DE u+05D3 u+05D1 u+05E8 u+05D9 u+05DD u+05E2 u+05D1 u+05E8 u+05D9 u+05EA"),
	ascii => "4dbcagdahymbxekheh6e0a7fei0b",
    },
    J => {
	unicode => udecode("U+0050 u+006F u+0072 u+0071 u+0075 u+00E9 u+006E u+006F u+0070 u+0075 u+0065 u+0064 u+0065 u+006E u+0073 u+0069 u+006D u+0070 u+006C u+0065 u+006D u+0065 u+006E u+0074 u+0065 u+0068 u+0061 u+0062 u+006C u+0061 u+0072 u+0065 u+006E U+0045 u+0073 u+0070 u+0061 u+00F1 u+006F u+006C"),
	ascii => "PorqunopuedensimplementehablarenEspaol-fmd56a",
    },
    K => {
	unicode => udecode("U+0054 u+1EA1 u+0069 u+0073 u+0061 u+006F u+0068 u+1ECD u+006B u+0068 u+00F4 u+006E u+0067 u+0074 u+0068 u+1EC3 u+0063 u+0068 u+1EC9 u+006E u+00F3 u+0069 u+0074 u+0069 u+1EBF u+006E u+0067 U+0056 u+0069 u+1EC7 u+0074"),
	ascii => "TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g",
    },
    O => {
	unicode => udecode("u+3072 u+3068 u+3064 u+5C4B u+6839 u+306E u+4E0B u+0032"),
	ascii => "2-u9tlzr9756bt3uc0v",
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
	/^[uU]\+[\dA-F]{2,4}$/ || die "Unexpected ucode: $_";
	push(@u, chr(hex(substr($_, 2))));
    }
    return join("", @u);
}
