use strict;
use warnings;

use Test::More tests => 22;

use URI ();
my $uri;

$uri = URI->new('smb://domain;user:password@server/share$/path');

is($uri->scheme,     'smb');
is($uri->authdomain, 'domain');
is($uri->user,       'user');
is($uri->password,   'password');
is($uri->host,       'server');
is($uri->port,       445);
is($uri->sharename,  'share$');
is($uri->path,       '/share$/path');

$uri->userinfo(undef);

is($uri->authdomain, undef);
is($uri->user,       undef);
is($uri->password,   undef);
is($uri->as_string,  'smb://server/share$/path');

# test that domain without user is not allowed
$uri->authdomain('DOMAIN');
is($uri->as_string, 'smb://server/share$/path');

$uri->user('Administrator');
is($uri->as_string, 'smb://Administrator@server/share$/path');

$uri->authdomain('DOMAIN');
is($uri->as_string, 'smb://DOMAIN;Administrator@server/share$/path');

# GH: a percent-escaped ';' in the userinfo is data, not the authdomain
# delimiter.  URI::_emailauth (pop/smtp) and URI::_userpass (ftp) both split
# the raw userinfo before unescaping it; URI::smb must do the same.
$uri = URI->new('smb://user%3Bname@server/share$/path');
is($uri->user,       'user;name', 'R1 escaped ; stays in the username');
is($uri->authdomain, undef,       'R2 escaped ; does not invent an authdomain');

$uri = URI->new('smb://dom%3Bain;user@server/share$/path');
is($uri->authdomain, 'dom;ain', 'R3 escaped ; stays in the authdomain');

$uri = URI->new('smb://a;b;c@server/share$/path');
is($uri->authdomain, 'a',   'R4a only the first raw ; is a delimiter');
is($uri->user,       'b;c', 'R4b only the first raw ; is a delimiter');

$uri = URI->new('smb://server/share$/path');
$uri->user('user;name');
is(
    $uri->as_string,
    'smb://user%3Bname@server/share$/path',
    'R5 setter escapes ;'
);
is($uri->user, 'user;name', 'R6 setter round-trips');

