package URI::icap;

use strict;
use warnings;
use base qw(URI::http);

our $VERSION = 5.20;

sub default_port { return 1344 }

1;
