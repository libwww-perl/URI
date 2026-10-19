use strict;
use warnings;

use Test::More;

use URI ();

subtest 'parse and modify a full userinfo' => sub {
    my $uri = URI->new('smb://domain;user:password@server/share$/path');

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
};

# GH#199: a percent-escaped ';' in the userinfo is data, not the authdomain
# delimiter.  URI::_emailauth (pop/smtp) and URI::_userpass (ftp) both split
# the raw userinfo before unescaping it; URI::smb must do the same.
subtest 'escaped ; in the username' => sub {
    my $uri = URI->new('smb://user%3Bname@server/share$/path');
    is($uri->user,       'user;name', 'escaped ; stays in the username');
    is($uri->authdomain, undef, 'escaped ; does not invent an authdomain');
};

subtest 'escaped ; in the authdomain' => sub {
    my $uri = URI->new('smb://dom%3Bain;user@server/share$/path');
    is($uri->authdomain, 'dom;ain', 'escaped ; stays in the authdomain');
};

subtest 'only the first raw ; is a delimiter' => sub {
    my $uri = URI->new('smb://a;b;c@server/share$/path');
    is($uri->authdomain, 'a',   'authdomain');
    is($uri->user,       'b;c', 'user');
};

subtest 'user setter escapes ;' => sub {
    my $uri = URI->new('smb://server/share$/path');
    $uri->user('user;name');
    is($uri->as_string, 'smb://user%3Bname@server/share$/path', 'as_string');
    is($uri->user,      'user;name',                            'round-trips');
};

# ':' is the user/password delimiter, so it must be escaped on write too.
subtest 'user setter escapes :' => sub {
    my $uri = URI->new('smb://server/share$/path');
    $uri->user('admin:pw');
    is($uri->as_string, 'smb://admin%3Apw@server/share$/path', 'as_string');
    is($uri->user,      'admin:pw', ': in the username round-trips');
    is($uri->password,  undef, ': in the username does not invent a password');
};

subtest 'setting either half keeps the other half and the password' => sub {
    my $uri = URI->new('smb://dom%3Bain;old:pa%3Ass@server/share$/path');
    $uri->user('new;x');
    is(
        $uri->as_string,
        'smb://dom%3Bain;new%3Bx:pa%3Ass@server/share$/path',
        'user setter keeps authdomain and password'
    );
    $uri->authdomain('d:e;f');
    is(
        $uri->as_string,
        'smb://d%3Ae%3Bf;new%3Bx:pa%3Ass@server/share$/path',
        'authdomain setter escapes : and ;'
    );
    is($uri->authdomain, 'd:e;f', 'authdomain round-trips');
    is($uri->password,   'pa:ss', 'password survives both setters');
};

# A literal '%' is data and must not be decoded on the way back.
subtest 'user setter escapes %' => sub {
    my $uri = URI->new('smb://server/share$/path');
    $uri->user('a%3Bb');
    is($uri->as_string, 'smb://a%253Bb@server/share$/path', 'as_string');
    is($uri->user,      'a%3Bb', 'literal % round-trips');
};

# The password is cut off before splitting, so a ';' in it is not a delimiter.
subtest '; in the password' => sub {
    my $uri = URI->new('smb://u:p;w@server/share$/path');
    is($uri->user,       'u',   'user is left alone');
    is($uri->authdomain, undef, 'no authdomain is invented');
    is($uri->password,   'p;w', 'password is kept');
    $uri->authdomain('D');
    is(
        $uri->as_string,
        'smb://D;u:p;w@server/share$/path',
        'authdomain setter keeps the password'
    );
};

subtest 'escaped ; before the raw delimiter' => sub {
    my $uri = URI->new('smb://a%3Bb;c;d@server/share$/path');
    is($uri->authdomain, 'a;b', 'escaped ; stays in the authdomain');
    is($uri->user,       'c;d', 'raw ; after the delimiter stays in the user');
};

subtest 'lowercase %3b' => sub {
    my $uri = URI->new('smb://user%3bname@server/share$/path');
    is($uri->user, 'user;name', 'lowercase %3b is data too');
};

subtest 'double-encoded ;' => sub {
    my $uri = URI->new('smb://a%253Bb@server/share$/path');
    is($uri->user,       'a%3Bb', 'userinfo is decoded exactly once');
    is($uri->authdomain, undef,   'double-encoded ; is not a delimiter');
};

subtest 'user setter with an empty password' => sub {
    my $uri = URI->new('smb://d;u:@server/share$/path');
    $uri->user('x');
    is($uri->as_string, 'smb://d;x:@server/share$/path', 'as_string');
    is($uri->password,  '', 'empty password stays empty');
};

subtest 'user setter on a password-only userinfo' => sub {
    my $uri = URI->new('smb://:pw@server/share$/path');
    $uri->user('bob');
    is($uri->as_string, 'smb://bob:pw@server/share$/path', 'as_string');
    is($uri->password,  'pw',                              'password is kept');
};

done_testing();
