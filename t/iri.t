use strict;
use warnings;

use utf8;
use Test::More;
use Config;

if (defined $Config{useperlio}) {
    plan tests=>26;
} else {
    plan skip_all=>'this perl doesn\'t support PerlIO layers';
}

use URI;
use URI::IRI;

my $u;

binmode Test::More->builder->output, ':encoding(UTF-8)';
binmode Test::More->builder->failure_output, ':encoding(UTF-8)';

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

$u = URI->new("http://example.com/B\xFCcher");
is $u->as_string, "http://example.com/B%FCcher";
is $u->as_iri, "http://example.com/B%FCcher";

$u = URI::IRI->new("http://example.com/B\xFCcher");
is $u->as_string, "http://example.com/Bücher";
is $u->as_iri, "http://example.com/Bücher";

# draft-duerst-iri-bis.txt claims this should map to xn--rsum-bad.example.org
$u = URI->new("http://r\xE9sum\xE9.example.org");
is $u->as_string, "http://xn--rsum-bpad.example.org";

$u = URI->new("http://xn--rsum-bad.example.org");
is $u->as_iri, "http://r\x80sum\x80.example.org";

$u = URI->new("http://r%C3%A9sum%C3%A9.example.org");
is $u->as_string, "http://r%C3%A9sum%C3%A9.example.org";
is $u->as_iri, "http://r\xE9sum\xE9.example.org";

$u = URI->new("http://➡.ws/");
is $u, "http://xn--hgi.ws/";
is $u->host, "xn--hgi.ws";
is $u->ihost, "➡.ws";
is $u->as_iri, "http://➡.ws/";

# draft-duerst-iri-bis.txt examples (section 3.7.1):
is(URI->new("http://www.example.org/D%C3%BCrst")->as_iri, "http://www.example.org/D\xFCrst");
is(URI->new("http://www.example.org/D%FCrst")->as_iri, "http://www.example.org/D%FCrst");
TODO: {
    local $TODO = "some chars (like U+202E, RIGHT-TO-LEFT OVERRIDE) need to stay escaped";
is(URI->new("http://xn--99zt52a.example.org/%e2%80%ae")->as_iri, "http://\x{7D0D}\x{8C46}.example.org/%e2%80%ae");
}

# try some URLs that can't be IDNA encoded (fallback to encoded UTF8 bytes)
$u = URI->new("http://" . ("ü" x 128));
is $u, "http://" . ("%C3%BC" x 128);
is $u->host, ("\xC3\xBC" x 128);
TODO: {
    local $TODO = "should ihost decode UTF8 bytes?";
    is $u->ihost, ("ü" x 128);
}
is $u->as_iri, "http://" . ("ü" x 128);
