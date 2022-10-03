use strict;
use warnings;

use Test::More tests => 5;

use URI::URL qw( url );

# We used to have problems with URLs that used a base that was
# not absolute itself.

my $u1 = url("/foo/bar", "http://www.acme.com/");
my $u2 = url("../foo/", $u1);
my $u3 = url("zoo/foo", $u2);

my $a1 = $u1->abs->as_string;
my $a2 = $u2->abs->as_string;
my $a3 = $u3->abs->as_string;

is($a1, "http://www.acme.com/foo/bar");
is($a2, "http://www.acme.com/foo/");
is($a3, "http://www.acme.com/foo/zoo/foo");

# We used to have problems with URI::URL as the base class :-(
my $u4 = url("foo", "URI::URL");
my $a4 = $u4->abs;
ok($u4 eq "foo" && $a4 eq "uri:/foo");

# Test new_abs for URI::URL objects
is(URI::URL->new_abs("foo", "http://foo/bar"), "http://foo/foo");
