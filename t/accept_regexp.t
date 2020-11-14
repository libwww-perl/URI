use strict;
use warnings;

use URI::Escape;

print "1..1\n";

my $value = "omg(<go\?\$>)";

# I expected this to work, but I missed to read the documentation carefully.
# So this issue is a feature request to allow this
my $regex = qr/[^a-zA-Z0-9-._~:\/?#[\]\@!\$&\'\(\)*+,;=]/;

print "not " unless( eval { uri_escape($value, $regex) } );
print "ok 1\n";


