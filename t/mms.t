use strict;
use warnings;

use Test::More tests => 8;

use URI ();

my $u = URI->new("<mms://66.250.188.13/KFOG_FM>");

#print "$u\n";
is($u, "mms://66.250.188.13/KFOG_FM");

is($u->port, 1755);

# play with port
my $old = $u->port(8755);
ok($old == 1755 && $u eq "mms://66.250.188.13:8755/KFOG_FM");

$u->port(1755);
is($u, "mms://66.250.188.13:1755/KFOG_FM");

$u->port("");
ok($u eq "mms://66.250.188.13:/KFOG_FM" && $u->port == 1755);

$u->port(undef);
is($u, "mms://66.250.188.13/KFOG_FM");

is($u->host, "66.250.188.13");

is($u->path, "/KFOG_FM");
