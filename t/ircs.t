use strict;
use warnings;

use Test::More tests => 4;

use URI ();
my $uri;

$uri = URI->new("ircs://PerlUser\@irc.perl.org");

is($uri, "ircs://PerlUser\@irc.perl.org");
is($uri->scheme, 'ircs');
is($uri->port, 994);
is($uri->secure, 1);
