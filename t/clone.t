use strict;
use warnings;

use Test::More tests => 2;

use URI::URL ();

my $b = URI::URL->new("http://www/");

my $u1 = URI::URL->new("foo", $b);
my $u2 = $u1->clone;

$u1->base("http://yyy/");

#use Data::Dump; Data::Dump::dump($b, $u1, $u2);

is $u1->abs->as_string, "http://yyy/foo";

is $u2->abs->as_string, "http://www/foo";
