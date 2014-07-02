package URI::telnet;

use strict;
use warnings;

require URI::_login;
our @ISA = qw(URI::_login);

sub default_port { 23 }

1;
