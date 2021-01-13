use strict;
use warnings;

use Test::More tests => 12;

use URI::Escape qw(%escapes uri_escape uri_escape_utf8 uri_unescape);

is uri_escape("|abc�"), "%7Cabc%E5";

is uri_escape("abc", "b-d"), "a%62%63";

# New escapes in RFC 3986
is uri_escape("~*'()"), "~%2A%27%28%29";
is uri_escape("<\">"), "%3C%22%3E";

is uri_escape(undef), undef;

is uri_unescape("%7Cabc%e5"), "|abc�";

is_deeply [uri_unescape("%40A%42", "CDE", "F%47H")], [qw(@AB CDE FGH)];

is $escapes{"%"}, "%25";

is uri_escape_utf8("|abc�"), "%7Cabc%C3%A5";

skip "Perl 5.8.0 or higher required", 3 if $] < 5.008;

ok !eval { print uri_escape("abc" . chr(300)); 1 };
like $@, qr/^Can\'t escape \\x\{012C\}, try uri_escape_utf8\(\) instead/;

is uri_escape_utf8(chr(0xFFF)), "%E0%BF%BF";
