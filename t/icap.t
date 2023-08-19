use strict;
use warnings;

use Test::More tests => 16;

use URI ();

my $u = URI->new("<icap://www.example.com/path?q=fôo>");

is($u, "icap://www.example.com/path?q=f%F4o");

is($u->port, 1344);

# play with port
my $old = $u->port(8080);
ok($old == 1344 && $u eq "icap://www.example.com:8080/path?q=f%F4o");

$u->port(1344);
is($u, "icap://www.example.com:1344/path?q=f%F4o");

$u->port("");
ok($u eq "icap://www.example.com:/path?q=f%F4o" && $u->port == 1344);

$u->port(undef);
is($u, "icap://www.example.com/path?q=f%F4o");

my @q = $u->query_form;
is_deeply(\@q, ["q", "fôo"]);

$u->query_form(foo => "bar", bar => "baz");
is($u->query, "foo=bar&bar=baz");

is($u->host, "www.example.com");

is($u->path, "/path");

ok(!$u->secure);

$u->scheme("icaps");
is($u->port, 1344);

is($u, "icaps://www.example.com/path?foo=bar&bar=baz");

ok($u->secure);

$u = URI->new("icaps://%65%78%61%6d%70%6c%65%2e%63%6f%6d/%70%75%62/%61/%32%30%30%31/%30%38/%32%37/%62%6a%6f%72%6e%73%74%61%64%2e%68%74%6d%6c");
is($u->canonical, "icaps://example.com/pub/a/2001/08/27/bjornstad.html");

ok($u->has_recognized_scheme);
