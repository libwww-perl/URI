use strict;
use warnings;

use Test::More tests => 21;

use URI::Escape qw( %escapes uri_escape uri_escape_utf8 uri_unescape );

is uri_escape("|abcå"), "%7Cabc%E5";

is uri_escape("abc", "b-d"), "a%62%63";

# New escapes in RFC 3986
is uri_escape("~*'()"), "~%2A%27%28%29";
is uri_escape("<\">"), "%3C%22%3E";

is uri_escape(undef), undef;

is uri_unescape("%7Cabc%e5"), "|abcå";

is_deeply [uri_unescape("%40A%42", "CDE", "F%47H")], [qw(@AB CDE FGH)];

is
    uri_escape ('/', '/'),
    '%2F',
    'it should accept slash in unwanted characters',
    ;

is
    uri_escape ('][', ']['),
    '%5D%5B',
    'it should accept regex char group terminator in unwanted characters',
    ;

is
    uri_escape ('[]\\', '][\\'),
    '%5B%5D%5C',
    'it should accept regex escape character at the end of unwanted characters',
    ;

is
    uri_escape ('[]\\${}', '][\\${`kill -0 -1`}'),
    '%5B%5D%5C%24%7B%7D',
    'it should recognize scalar interpolation injection in unwanted characters',
    ;

is
    uri_escape ('[]\\@{}', '][\\@{`kill -0 -1`}'),
    '%5B%5D%5C%40%7B%7D',
    'it should recognize array interpolation injection in unwanted characters',
    ;

is
    uri_escape ('[]\\%{}', '][\\%{`kill -0 -1`}'),
    '%5B%5D%5C%25%7B%7D',
    'it should recognize hash interpolation injection in unwanted characters',
    ;

is
    uri_escape ('a-b', '-bc'),
    'a%2D%62',
    'it should recognize leading minus',
    ;

is
    uri_escape ('a-b', '^-bc'),
    '%61-b',
    'it should recognize leading ^-'
    ;

is
    uri_escape ('a-b-1', '[:alpha:][:digit:]'),
    '%61-%62-%31',
    'it should recognize character groups'
    ;

is $escapes{"%"}, "%25";

is uri_escape_utf8("|abcå"), "%7Cabc%C3%A5";

skip "Perl 5.8.0 or higher required", 3 if $] < 5.008;

ok !eval { print uri_escape("abc" . chr(300)); 1 };
like $@, qr/^Can\'t escape \\x\{012C\}, try uri_escape_utf8\(\) instead/;

is uri_escape_utf8(chr(0xFFF)), "%E0%BF%BF";
