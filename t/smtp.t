use strict;
use warnings;

use Test::More tests => 8;

use URI ();

my $u = URI->new('smtp://foobar@smtp.example.com');

ok($u->user eq "foobar" &&
   !defined($u->auth) &&
   $u->host eq "smtp.example.com" &&
   $u->port == 25 &&
   $u eq 'smtp://foobar@smtp.example.com');

$u->auth("+XOAUTH2");
ok($u->auth eq "+XOAUTH2" &&
   $u eq 'smtp://foobar;AUTH=+XOAUTH2@smtp.example.com');

$u->user("bizz");
ok($u->user eq "bizz" &&
   $u eq 'smtp://bizz;AUTH=+XOAUTH2@smtp.example.com');

$u->port(4000);
is($u, 'smtp://bizz;AUTH=+XOAUTH2@smtp.example.com:4000');

$u = URI->new("smtp:");
$u->host("smtp.example.com");
$u->user("foobar");
$u->auth("*");
is($u, 'smtp://foobar;AUTH=*@smtp.example.com');

$u->auth(undef);
is($u, 'smtp://foobar@smtp.example.com');

$u->user(undef);
is($u, 'smtp://smtp.example.com');

# Try some funny characters too
$u->user('sn☃wm@n');
ok($u->user eq 'sn☃wm@n' &&
   $u eq 'smtp://sn%E2%98%83wm%40n@smtp.example.com');
