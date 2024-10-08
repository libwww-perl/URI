use strict;
use warnings;

use Test::More tests => 4;

use URI ();
my $uri;

$uri = URI->new("ftpes://ftp.example.com/path");

is($uri->scheme, 'ftpes');
is($uri->port, 21);
is($uri->secure, 1);
is($uri->encrypt_mode, 'explicit');
