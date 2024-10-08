use strict;
use warnings;

use Test::More tests => 6;

use URI ();
my $uri;

$uri = URI->new("ssh://user\@ssh.example.com/path");

is($uri->scheme, 'ssh');
is($uri->host, 'ssh.example.com');
is($uri->port, 22);
is($uri->secure, 1);
is($uri->user, 'user');
is($uri->password, undef);
