package URI::file;

require URI::_server;
@ISA=qw(URI::_server);  # or _generic?

use strict;

sub path { shift->path_query(@_) }  # XXX

1;


