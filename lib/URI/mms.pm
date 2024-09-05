package URI::mms;

use strict;
use warnings;

our $VERSION = '5.30';

use parent 'URI::http';

sub default_port { 1755 }

1;
