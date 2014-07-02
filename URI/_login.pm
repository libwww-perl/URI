package URI::_login;

use strict;
use warnings;

require URI::_server;
require URI::_userpass;
our @ISA = qw(URI::_server URI::_userpass);

# Generic terminal logins.  This is used as a base class for 'telnet',
# 'tn3270', and 'rlogin' URL schemes.

1;
