use strict;
use warnings;

use Test::More tests => 10;

use URI ();
my $uri;

$uri = URI->new("irc://PerlUser\@irc.perl.org:6669/#libwww-perl,ischannel,isnetwork?key=bazqux");

is($uri, "irc://PerlUser\@irc.perl.org:6669/#libwww-perl,ischannel,isnetwork?key=bazqux");
is($uri->port, 6669);

# add a password
$uri->password('foobar');

is($uri->userinfo, "PerlUser:foobar");

my @opts = $uri->options;
is_deeply(\@opts, [qw< key bazqux >]);

$uri->options(foo => "bar", bar => "baz");

is($uri->query, "foo=bar&bar=baz");
is($uri->host, "irc.perl.org");
is($uri->path, "/#libwww-perl,ischannel,isnetwork");

# add a bunch of flags to clean up
$uri->path("/SineSwiper,isnick,isnetwork,isserver,needpass,needkey");
$uri = $uri->canonical;

is($uri->path, "/SineSwiper,isuser,isnetwork,needpass,needkey");

# ports and secure-ness
is($uri->secure, 0);

$uri->port(undef);
is($uri->port, 6667);
