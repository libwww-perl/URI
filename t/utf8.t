#!perl

use strict;
use warnings;

use utf8;

use Test::More 'no_plan';
use URI;

is(URI->new('http://foobar/mooi€e')->as_string, 'http://foobar/mooi%E2%82%ACe');

my $uri = URI->new('http:');
$uri->query_form("mooi€e" => "mooi€e");
is( $uri->query, "mooi%E2%82%ACe=mooi%E2%82%ACe" );
