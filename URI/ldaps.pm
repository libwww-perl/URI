package URI::ldaps;

use strict;
use warnings;

require URI::ldap;
our @ISA=qw(URI::ldap);

sub default_port { 636 }

sub secure { 1 }

1;
