use strict;
use warnings;

use Test::More tests => 9;

use URI ();

my $u = URI->new("<rtsp://media.example.com/fôo.smi/>");

#print "$u\n";
is($u, "rtsp://media.example.com/f%F4o.smi/");

is($u->port, 554);

# play with port
my $old = $u->port(8554);
ok($old == 554 && $u eq "rtsp://media.example.com:8554/f%F4o.smi/");

$u->port(554);
is($u, "rtsp://media.example.com:554/f%F4o.smi/");

$u->port("");
ok($u eq "rtsp://media.example.com:/f%F4o.smi/" && $u->port == 554);

$u->port(undef);
is($u, "rtsp://media.example.com/f%F4o.smi/");

is($u->host, "media.example.com");

is($u->path, "/f%F4o.smi/");

$u->scheme("rtspu");
is($u->scheme, "rtspu");

