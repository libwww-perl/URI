package URI::rlogin;

use strict;
use warnings;

require URI::_login;
our @ISA = qw(URI::_login);

sub default_port { 513 }

1;
