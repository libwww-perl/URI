use strict;
use warnings;

use Test::Needs { 'Business::ISBN' => 3.005 };

use Test::More tests => 13;

use URI ();
my $u = URI->new("URN:ISBN:0395363411");

ok($u eq "URN:ISBN:0395363411" &&
   $u->scheme eq "urn" &&
   $u->nid eq "isbn");

is($u->canonical, "urn:isbn:0-395-36341-1");

is($u->isbn, "0-395-36341-1");

is($u->isbn_group_code, 0);

is($u->isbn_publisher_code, 395);

is($u->isbn13, "9780395363416");

is($u->nss, "0395363411");

is($u->isbn("0-88730-866-x"), "0-395-36341-1");

is($u->nss, "0-88730-866-x");

is($u->isbn, "0-88730-866-X");

ok(URI::eq("urn:isbn:088730866x", "URN:ISBN:0-88-73-08-66-X"));

# try to illegal ones
$u = URI->new("urn:ISBN:abc");
is($u, "urn:ISBN:abc");

ok($u->nss eq "abc" && !defined $u->isbn);


