use strict;
use warnings;

use Test::More tests => 6;

use URI ();
my $uri;

$uri = URI->new("sftp://user\@ssh.example.com/path");

is($uri->scheme, 'sftp');
is($uri->host, 'ssh.example.com');
is($uri->port, 22);
is($uri->secure, 1);
is($uri->user, 'user');
is($uri->password, undef);
