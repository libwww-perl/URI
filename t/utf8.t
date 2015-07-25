use strict;
use warnings;

use utf8;

use Test::More 'no_plan';
use URI;

is(URI->new('http://foobar/mooi€e')->as_string, 'http://foobar/mooi%E2%82%ACe');

my $uri = URI->new('http:');
$uri->query_form("mooi€e" => "mooi€e");
is( $uri->query, "mooi%E2%82%ACe=mooi%E2%82%ACe" );
is( ($uri->query_form)[1], "mooi\xE2\x82\xACe" );

# RT#70161
use Encode;
$uri = URI->new(decode_utf8 '?Query=%C3%A4%C3%B6%C3%BC');
is( ($uri->query_form)[1], "\xC3\xA4\xC3\xB6\xC3\xBC");
is( decode_utf8(($uri->query_form)[1]), 'äöü');
