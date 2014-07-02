package URI::rtspu;

use strict;
use warnings;

require URI::rtsp;
our @ISA=qw(URI::rtsp);

sub default_port { 554 }

1;
