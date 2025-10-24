use strict;
use warnings;

use Test::More tests => 15;

use URI ();

# Test leading zeros in non-default ports are stripped in canonical form
my $u = URI->new('http://xyz:08080');
is($u->canonical->port, 8080, 'Leading zero stripped from port 08080');
is($u->canonical, 'http://xyz:8080/', 'Canonical URI has normalized port 8080');

# Test leading zeros in default HTTP port (80)
$u = URI->new('http://xyz:080');
is($u->canonical->port, 80, 'Default port 080 normalized to 80');
is($u->canonical, 'http://xyz/', 'Default port 80 removed from canonical URI');

# Test leading zeros in default HTTPS port (443)
$u = URI->new('https://xyz:0443');
is($u->canonical->port, 443, 'Default port 0443 normalized to 443');
is($u->canonical, 'https://xyz/', 'Default port 443 removed from canonical URI');

# Test multiple leading zeros
$u = URI->new('http://xyz:00443');
is($u->canonical->port, 443, 'Multiple leading zeros stripped from port 00443');
is($u->canonical, 'http://xyz:443/', 'Canonical URI has normalized port 443');

# Test port with single leading zero
$u = URI->new('http://xyz:01234');
is($u->canonical->port, 1234, 'Single leading zero stripped from port 01234');
is($u->canonical, 'http://xyz:1234/', 'Canonical URI has normalized port 1234');

# Test that regular ports without leading zeros are unchanged
$u = URI->new('http://xyz:8080');
is($u->canonical->port, 8080, 'Port 8080 without leading zeros unchanged');
is($u->canonical, 'http://xyz:8080/', 'Canonical URI with port 8080 unchanged');

# Test port 0 (edge case)
$u = URI->new('http://xyz:0');
is($u->canonical->port, 0, 'Port 0 normalized correctly');

# Test FTP with leading zeros on default port
$u = URI->new('ftp://xyz:021');
is($u->canonical->port, 21, 'FTP default port 021 normalized to 21');
is($u->canonical, 'ftp://xyz', 'FTP default port 21 removed from canonical URI');
