use strict;
use warnings;

use Test::More;

use URI ();

my $uri;

$uri = URI->new("http://www.example.com/foo/bar/");
is($uri->rel("http://www.example.com/foo/bar/"),    "./");
is($uri->rel("HTTP://WWW.EXAMPLE.COM/foo/bar/"),    "./");
is($uri->rel("HTTP://WWW.EXAMPLE.COM/FOO/BAR/"),    "../../foo/bar/");
is($uri->rel("HTTP://WWW.EXAMPLE.COM:80/foo/bar/"), "./");

$uri = URI->new("http://www.example.com/foo/bar");
is($uri->rel("http://www.example.com/foo/bar"), "bar");
is($uri->rel("http://www.example.com/foo"),     "foo/bar");

# GH#205: leading empty path segments must survive a rel/abs round trip
for my $case (
    [q{http://good.example/a///evil.example/x}, q{http://good.example/a/b}],
    [q{http://h/a//x},                          q{http://h/a/}],
    [q{http://h//x},                            q{http://h//y}],
    [q{http://h//x#f},                          q{http://h//x}],
    [q{http://h///x?q#f},                       q{http://h/}],
    [q{http://h/a//x},                          q{http://h/a/b/c}],
    )
{
    my ($u, $base) = @$case;
    is(URI->new($u)->rel($base)->abs($base),
        $u, "rel/abs round trip of $u against $base");
}

done_testing();
