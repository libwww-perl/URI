package URI::rtsp;

use strict;
use warnings;

require URI::http;
our @ISA=qw(URI::http);

sub default_port { 554 }

1;
