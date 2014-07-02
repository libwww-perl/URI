package URI::https;

use strict;
use warnings;

require URI::http;
our @ISA=qw(URI::http);

sub default_port { 443 }

sub secure { 1 }

1;
