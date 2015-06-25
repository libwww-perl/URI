use strict;
use warnings;

use Test::More;

# ABSTRACT: Make sure query_form(\%hash) is sorted

use URI;

my $base = URI->new('http://example.org/');

my $i = 1;

my $hash = { map { $_ => $i++ } qw( a b c d e f ) };

$base->query_form($hash);

is("$base","http://example.org/?a=1&b=2&c=3&d=4&e=5&f=6", "Query parameters are sorted");

done_testing;


