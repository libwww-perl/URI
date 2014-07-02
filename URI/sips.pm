package URI::sips;

use strict;
use warnings;

require URI::sip;
our @ISA=qw(URI::sip);

sub default_port { 5061 }

sub secure { 1 }

1;
