use strict;
use warnings;

use Test::More tests => 4;

use URI ();

my $u = URI->new("urn:oid");

$u->oid(1..10);

#print "$u\n";

is($u, "urn:oid:1.2.3.4.5.6.7.8.9.10");

is($u->oid, "1.2.3.4.5.6.7.8.9.10");

ok($u->scheme eq "urn" && $u->nid eq "oid");

is($u->oid, $u->nss);
