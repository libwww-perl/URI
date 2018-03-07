#!perl -T

use strict;
use warnings;

use Test::More tests => 3;
use URI;

my $uri = URI->new('tel:+16045551234');
isa_ok($uri, 'URI', 'tel: builds a URI object');
is($uri->scheme(), 'tel', 'scheme = tel');

$uri = URI->new('5555309', 'tel');
isa_ok($uri, 'URI', 'passing in scheme "tel" builds a URI object');
