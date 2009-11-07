#!perl -w

use utf8;
use strict;
use Test::More tests => 10;

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

$u = URI->new("http://➡.ws/");
is $u, "http://xn--hgi.ws/";
is $u->host, "xn--hgi.ws";
is $u->ihost, "➡.ws";
is $u->as_iri, "http://➡.ws/";
