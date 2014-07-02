package URI::tn3270;

use strict;
use warnings;

require URI::_login;
our @ISA = qw(URI::_login);

sub default_port { 23 }

1;
