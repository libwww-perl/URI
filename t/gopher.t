use strict;
use warnings;

use Test::More tests => 48;

use URI ();

sub check_gopher_uri {
    my ($u, $exphost, $expport, $exptype, $expselector, $expsearch) = @_;
    is("gopher", $u->scheme);
    is($exphost, $u->host);
    is($expport, $u->port);
    is($exptype, $u->gopher_type);
    is($expselector, $u->selector);
    is($expsearch, $u->search);
}

my $u;
$u = URI->new("gopher://host");
check_gopher_uri($u, "host", 70, 1);
$u = URI->new("gopher://host:70");
check_gopher_uri($u, "host", 70, 1);
$u = URI->new("gopher://host:70/");
check_gopher_uri($u, "host", 70, 1);
$u = URI->new("gopher://host:70/1");
check_gopher_uri($u, "host", 70, 1);
$u = URI->new("gopher://host:70/1");
check_gopher_uri($u, "host", 70, 1);
$u = URI->new("gopher://host:123/7foo");
check_gopher_uri($u, "host", 123, 7, "foo");
$u = URI->new("gopher://host/7foo\tbar%20baz");
check_gopher_uri($u, "host", 70, 7, "foo", "bar baz");
$u = URI->new("gopher://host/7foo%09bar%20baz");
check_gopher_uri($u, "host", 70, 7, "foo", "bar baz");
