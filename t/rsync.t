use strict;
use warnings;

use Test::More tests => 4;

use URI ();

my $u = URI->new('rsync://gisle@example.com/foo/bar');

is($u->user, "gisle");

is($u->port, 873);

is($u->path, "/foo/bar");

$u->port(8730);

is($u, 'rsync://gisle@example.com:8730/foo/bar');

