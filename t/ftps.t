use strict;
use warnings;

use Test::More tests => 4;

use URI ();
my $uri;

$uri = URI->new("ftps://ftp.example.com/path");

is($uri->scheme, 'ftps');
is($uri->port, 990);
is($uri->secure, 1);
is($uri->encrypt_mode, 'implicit');
