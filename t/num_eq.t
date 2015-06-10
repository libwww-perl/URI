# Test URI's overloading of numeric comparison for checking object
# equality

use strict;
use warnings;
use Test::More 'no_plan';

use URI;

my $uri1 = URI->new("http://foo.com");
my $uri2 = URI->new("http://foo.com");

# cmp_ok() has a bug/misfeature where it strips overloading
# before doing the comparison.  So use a regular ok().
ok $uri1 == $uri1, "==";
ok $uri1 != $uri2, "!=";
