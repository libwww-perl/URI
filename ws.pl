# https://rt.cpan.org/Ticket/Display.html?id=50696
# http://en.wikipedia.org/wiki/Internationalized_domain_name
# http://search.cpan.org/~roburban/IDNA-Punycode-0.03/
use utf8;
use strict;
use URI;

my $u = URI->new("http://➡.ws/");
print $u, "\n";
