use strict;
use warnings;

use Test::More tests => 48;

use URI ();

my $foo = URI->new("Foo:opaque#frag");

is(ref($foo), "URI::_foreign");

is($foo->as_string, "Foo:opaque#frag");

is("$foo", "Foo:opaque#frag");

# Try accessors
ok($foo->_scheme eq "Foo" && $foo->scheme eq "foo" && !$foo->has_recognized_scheme);

is($foo->opaque, "opaque");

is($foo->fragment, "frag");

is($foo->canonical, "foo:opaque#frag");

# Try modificators
my $old = $foo->scheme("bar");

ok($old eq "foo" && $foo eq "bar:opaque#frag");

$old = $foo->scheme("");
ok($old eq "bar" && $foo eq "opaque#frag");

$old = $foo->scheme("foo");
$old = $foo->scheme(undef);

ok($old eq "foo" && $foo eq "opaque#frag");

$foo->scheme("foo");


$old = $foo->opaque("xxx");
ok($old eq "opaque" && $foo eq "foo:xxx#frag");

$old = $foo->opaque("");
ok($old eq "xxx" && $foo eq "foo:#frag");

$old = $foo->opaque(" #?/");
$old = $foo->opaque(undef);
ok($old eq "%20%23?/" && $foo eq "foo:#frag");

$foo->opaque("opaque");


$old = $foo->fragment("x");
ok($old eq "frag" && $foo eq "foo:opaque#x");

$old = $foo->fragment("");
ok($old eq "x" && $foo eq "foo:opaque#");

$old = $foo->fragment(undef);
ok($old eq "" && $foo eq "foo:opaque");


# Compare
ok($foo->eq("Foo:opaque") &&
   $foo->eq(URI->new("FOO:opaque")) &&
   $foo->eq("foo:opaque"));

ok(!$foo->eq("Bar:opaque") &&
   !$foo->eq("foo:opaque#"));


# Try hierarchal unknown URLs

$foo = URI->new("foo://host:80/path?query#frag");

is("$foo", "foo://host:80/path?query#frag");

# Accessors
is($foo->scheme, "foo");

is($foo->authority, "host:80");

is($foo->path, "/path");

is($foo->query, "query");

is($foo->fragment, "frag");

# Modificators
$old = $foo->authority("xxx");
ok($old eq "host:80" && $foo eq "foo://xxx/path?query#frag");

$old = $foo->authority("");
ok($old eq "xxx" && $foo eq "foo:///path?query#frag");

$old = $foo->authority(undef);
ok($old eq "" && $foo eq "foo:/path?query#frag");

$old = $foo->authority("/? #;@&");
ok(!defined($old) && $foo eq "foo://%2F%3F%20%23;@&/path?query#frag");

$old = $foo->authority("host:80");
ok($old eq "%2F%3F%20%23;@&" && $foo eq "foo://host:80/path?query#frag");


$old = $foo->path("/foo");
ok($old eq "/path" && $foo eq "foo://host:80/foo?query#frag");

$old = $foo->path("bar");
ok($old eq "/foo" && $foo eq "foo://host:80/bar?query#frag");

$old = $foo->path("");
ok($old eq "/bar" && $foo eq "foo://host:80?query#frag");

$old = $foo->path(undef);
ok($old eq "" && $foo eq "foo://host:80?query#frag");

$old = $foo->path("@;/?#");
ok($old eq "" && $foo eq "foo://host:80/@;/%3F%23?query#frag");

$old = $foo->path("path");
ok($old eq "/@;/%3F%23" && $foo eq "foo://host:80/path?query#frag");


$old = $foo->query("foo");
ok($old eq "query" && $foo eq "foo://host:80/path?foo#frag");

$old = $foo->query("");
ok($old eq "foo" && $foo eq "foo://host:80/path?#frag");

$old = $foo->query(undef);
ok($old eq "" && $foo eq "foo://host:80/path#frag");

$old = $foo->query("/?&=# ");
ok(!defined($old) && $foo eq "foo://host:80/path?/?&=%23%20#frag");

$old = $foo->query("query");
ok($old eq "/?&=%23%20" && $foo eq "foo://host:80/path?query#frag");

# Some buildup trics
$foo = URI->new("");
$foo->path("path");
$foo->authority("auth");

is($foo, "//auth/path");

$foo = URI->new("", "http:");
$foo->query("query");
$foo->authority("auth");
ok($foo eq "//auth?query" && $foo->has_recognized_scheme);

$foo->path("path");
is($foo, "//auth/path?query");

$foo = URI->new("");
$old = $foo->path("foo");
ok($old eq "" && $foo eq "foo" && !$foo->has_recognized_scheme);

$old = $foo->path("bar");
ok($old eq "foo" && $foo eq "bar");

$old = $foo->opaque("foo");
ok($old eq "bar" && $foo eq "foo");

$old = $foo->path("");
ok($old eq "foo" && $foo eq "");

$old = $foo->query("q");
ok(!defined($old) && $foo eq "?q");

