# https://rt.cpan.org/Ticket/Display.html?id=50696
# http://en.wikipedia.org/wiki/Internationalized_domain_name
# http://search.cpan.org/~roburban/IDNA-Punycode-0.03/
use utf8;
use strict;
use URI;
use Encode qw(encode_utf8);

try("http://➡.ws/");
try("http://➡.ws/");
try("http://➡.ws/");
try("http://@➡.ws:8080/");
try("http://Bücher.ch");
try("http://example.com/Bücher");

sub try {
    my $u = shift;
    $u = URI->new($u);
    print "$u --> ", encode_utf8($u->as_unicode), " --> ", $u->host, " --> ", encode_utf8($u->host_unicode), "\n";
}
