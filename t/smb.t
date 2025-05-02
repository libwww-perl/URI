use strict;
use warnings;

use Test::More tests => 12;

use URI ();
my $uri;

$uri = URI->new('smb://domain;user:password@server/share/path');

is($uri->scheme, 'smb');
is($uri->authdomain, 'domain');
is($uri->user, 'user');
is($uri->password, 'password');
is($uri->host, 'server');
is($uri->port, 445);
is($uri->sharename, 'share');
is($uri->path, '/share/path');

$uri->userinfo(undef);

is($uri->authdomain, undef);
is($uri->user, undef);
is($uri->password, undef);

is($uri->as_string, 'smb://server/share/path');
