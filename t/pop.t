use strict;
use warnings;

use Test::More tests => 8;

use URI ();

my $u = URI->new('pop://aas@pop.sn.no');

ok($u->user eq "aas" &&
   !defined($u->auth) &&
   $u->host eq "pop.sn.no" &&
   $u->port == 110 &&
   $u eq 'pop://aas@pop.sn.no');

$u->auth("+APOP");
ok($u->auth eq "+APOP" &&
   $u eq 'pop://aas;AUTH=+APOP@pop.sn.no');

$u->user("gisle");
ok($u->user eq "gisle" &&
   $u eq 'pop://gisle;AUTH=+APOP@pop.sn.no');

$u->port(4000);
is($u, 'pop://gisle;AUTH=+APOP@pop.sn.no:4000');

$u = URI->new("pop:");
$u->host("pop.sn.no");
$u->user("aas");
$u->auth("*");
is($u, 'pop://aas;AUTH=*@pop.sn.no');

$u->auth(undef);
is($u, 'pop://aas@pop.sn.no');

$u->user(undef);
is($u, 'pop://pop.sn.no');

# Try some funny characters too
$u->user('får;k@l');
ok($u->user eq 'får;k@l' &&
   $u eq 'pop://f%E5r%3Bk%40l@pop.sn.no');
