package URI::icap;

use strict;
use warnings;
use base qw(URI::http);

our $VERSION = 0.07;

sub default_port { return 1344 }

1;
