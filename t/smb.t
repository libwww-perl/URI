use strict;
use warnings;

use Test::More tests => 44;

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

# GH#199: a percent-escaped ';' in the userinfo is data, not the authdomain
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

# ':' is the user/password delimiter, so it must be escaped on write too.
$uri = URI->new('smb://server/share$/path');
$uri->user('admin:pw');
is(
    $uri->as_string,
    'smb://admin%3Apw@server/share$/path',
    'R7 setter escapes :'
);
is($uri->user,     'admin:pw', 'R8 : in the username round-trips');
is($uri->password, undef, 'R9 : in the username does not invent a password');

# Setting either half keeps the other half and the password.
$uri = URI->new('smb://dom%3Bain;old:pa%3Ass@server/share$/path');
$uri->user('new;x');
is(
    $uri->as_string,
    'smb://dom%3Bain;new%3Bx:pa%3Ass@server/share$/path',
    'R10 user setter keeps authdomain and password'
);
$uri->authdomain('d:e;f');
is(
    $uri->as_string,
    'smb://d%3Ae%3Bf;new%3Bx:pa%3Ass@server/share$/path',
    'R11 authdomain setter escapes : and ;'
);
is($uri->authdomain, 'd:e;f', 'R12 authdomain round-trips');
is($uri->password,   'pa:ss', 'R13 password survives both setters');

# A literal '%' is data and must not be decoded on the way back.
$uri = URI->new('smb://server/share$/path');
$uri->user('a%3Bb');
is($uri->as_string, 'smb://a%253Bb@server/share$/path', 'R14 setter escapes %');
is($uri->user,      'a%3Bb', 'R15 literal % round-trips');

# The password is cut off before splitting, so a ';' in it is not a delimiter.
$uri = URI->new('smb://u:p;w@server/share$/path');
is($uri->user, 'u', 'R16 ; in the password leaves the user alone');
is($uri->authdomain, undef,
    'R17 ; in the password does not invent an authdomain');
is($uri->password, 'p;w', 'R18 ; in the password is kept');
$uri->authdomain('D');
is(
    $uri->as_string,
    'smb://D;u:p;w@server/share$/path',
    'R19 authdomain setter keeps a password containing ;'
);

$uri = URI->new('smb://a%3Bb;c;d@server/share$/path');
is($uri->authdomain, 'a;b', 'R20 escaped ; before the raw delimiter');
is($uri->user,       'c;d', 'R21 raw ; after the delimiter');

$uri = URI->new('smb://user%3bname@server/share$/path');
is($uri->user, 'user;name', 'R22 lowercase %3b is data too');

$uri = URI->new('smb://a%253Bb@server/share$/path');
is($uri->user,       'a%3Bb', 'R23 userinfo is decoded exactly once');
is($uri->authdomain, undef,   'R24 double-encoded ; is not a delimiter');

$uri = URI->new('smb://d;u:@server/share$/path');
$uri->user('x');
is(
    $uri->as_string,
    'smb://d;x:@server/share$/path',
    'R25 user setter keeps an empty password'
);
is($uri->password, '', 'R26 empty password stays empty');

$uri = URI->new('smb://:pw@server/share$/path');
$uri->user('bob');
is(
    $uri->as_string,
    'smb://bob:pw@server/share$/path',
    'R27 user setter on a password-only userinfo'
);
is($uri->password, 'pw', 'R28 password-only userinfo keeps its password');
