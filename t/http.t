use strict;
use warnings;

use Test::More tests => 16;

use URI ();

my $u = URI->new("<http://www.example.com/path?q=fôo>");

#print "$u\n";
is($u, "http://www.example.com/path?q=f%F4o");

is($u->port, 80);

# play with port
my $old = $u->port(8080);
ok($old == 80 && $u eq "http://www.example.com:8080/path?q=f%F4o");

$u->port(80);
is($u, "http://www.example.com:80/path?q=f%F4o");

$u->port("");
ok($u eq "http://www.example.com:/path?q=f%F4o" && $u->port == 80);

$u->port(undef);
is($u, "http://www.example.com/path?q=f%F4o");

my @q = $u->query_form;
is_deeply(\@q, ["q", "fôo"]);

$u->query_form(foo => "bar", bar => "baz");
is($u->query, "foo=bar&bar=baz");

is($u->host, "www.example.com");

is($u->path, "/path");

ok(!$u->secure);

$u->scheme("https");
is($u->port, 443);

is($u, "https://www.example.com/path?foo=bar&bar=baz");

ok($u->secure);

$u = URI->new("http://%65%78%61%6d%70%6c%65%2e%63%6f%6d/%70%75%62/%61/%32%30%30%31/%30%38/%32%37/%62%6a%6f%72%6e%73%74%61%64%2e%68%74%6d%6c");
is($u->canonical, "http://example.com/pub/a/2001/08/27/bjornstad.html");

ok($u->has_recognized_scheme);
