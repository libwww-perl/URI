package URI::rsync;  # http://rsync.samba.org/

# rsync://[USER@]HOST[:PORT]/SRC

use strict;
use warnings;

require URI::_server;
require URI::_userpass;

our @ISA=qw(URI::_server URI::_userpass);

sub default_port { 873 }

1;
