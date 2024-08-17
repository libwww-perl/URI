use strict;
use warnings;

use Test::More tests => 76;

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

my $username = 'u1!"#$%&\'()*+,-./;<=>?@[\]^_`{|}~';
my $exp_username = 'u1!%22%23$%&\'()*+,-.%2F;%3C=%3E%3F@%5B%5C%5D%5E_%60%7B%7C%7D~';
my $password = 'p1!"#$%&\'()*+,-./;<=>?@[\]^_`{|}~';
my $exp_password = 'p1!%22%23$%&\'()*+,-.%2F;%3C=%3E%3F@%5B%5C%5D%5E_%60%7B%7C%7D~';
my $path = 'path/to/page';
my $query = 'a=b&c=d';
my %host = (
    '[::1]' => {
        host => '::1',
        port => 80,
    },
    '[::1]:8080' => {
        host => '::1',
        port => 8080,
    },
    '127.0.0.1' => {
        host => '127.0.0.1',
        port => 80,
    },
    '127.0.0.1:8080' => {
        host => '127.0.0.1',
        port => 8080,
    },
    'localhost' => {
        host => 'localhost',
        port => 80,
    },
    'localhost:8080' => {
        host => 'localhost',
        port => 8080,
    },
);

foreach my $host (keys %host) {
    my $uri = URI->new("http://${username}:${password}\@${host}/${path}?${query}");
    is($uri->scheme, 'http');
    is($uri->userinfo, "${exp_username}:${exp_password}");
    is($uri->host, $host{$host}->{host});
    is($uri->port, $host{$host}->{port});
    is($uri->path, "/${path}");
    is($uri->query, $query);
    is($uri->authority, "${exp_username}:${exp_password}\@${host}");
    is($uri->as_string, "http://${exp_username}:${exp_password}\@${host}/${path}?${query}");
    is($uri->as_iri, "http://${exp_username}:${exp_password}\@${host}/${path}?${query}");
    is($uri->canonical, "http://${exp_username}:${exp_password}\@${host}/${path}?${query}");
}

