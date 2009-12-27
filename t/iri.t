#!perl -w

use utf8;
use strict;
use Test::More tests => 15;

use URI;

my $u;

$u = URI->new("http://Bücher.ch");
is $u, "http://xn--bcher-kva.ch";
is $u->host, "xn--bcher-kva.ch";
is $u->ihost, "bücher.ch";
is $u->as_iri, "http://bücher.ch";

$u = URI->new("http://example.com/Bücher");
is $u, "http://example.com/B%C3%BCcher";
is $u->as_iri, "http://example.com/Bücher";

$u = URI->new("http://example.com/B%FCcher");  # latin1 encoded stuff
is $u->as_iri, "http://example.com/B%FCcher";  # ...should not be decoded

$u = URI->new("http://➡.ws/");
is $u, "http://xn--hgi.ws/";
is $u->host, "xn--hgi.ws";
is $u->ihost, "➡.ws";
is $u->as_iri, "http://➡.ws/";

# try some URLs that can't be IDNA encoded (fallback to encoded UTF8 bytes)
$u = URI->new("http://" . ("ü" x 128));
is $u, "http://" . ("%C3%BC" x 128);
is $u->host, ("\xC3\xBC" x 128);
TODO: {
    local $TODO = "should ihost decode UTF8 bytes?";
    is $u->ihost, ("ü" x 128);
}
is $u->as_iri, "http://" . ("ü" x 128);
