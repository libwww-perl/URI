use strict;
use warnings;

use Test::More;

plan tests => 6;

use URI;

my $uri;

$uri = URI->new("http://www.example.com/foo/bar/");
is($uri->rel("http://www.example.com/foo/bar/"), "./");
is($uri->rel("HTTP://WWW.EXAMPLE.COM/foo/bar/"), "./");
is($uri->rel("HTTP://WWW.EXAMPLE.COM/FOO/BAR/"), "../../foo/bar/");
is($uri->rel("HTTP://WWW.EXAMPLE.COM:80/foo/bar/"), "./");

$uri = URI->new("http://www.example.com/foo/bar");
is($uri->rel("http://www.example.com/foo/bar"), "bar");
is($uri->rel("http://www.example.com/foo"), "foo/bar");

