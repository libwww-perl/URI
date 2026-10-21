package URI::ircs;

use strict;
use warnings;

our $VERSION = '5.41';

use parent 'URI::irc';

sub default_port {994}

sub secure {1}

1;
