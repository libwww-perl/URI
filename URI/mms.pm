package URI::mms;

use strict;
use warnings;

require URI::http;
our @ISA=qw(URI::http);

sub default_port { 1755 }

1;
