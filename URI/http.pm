package URI::http;

require URI::_server;
@ISA=qw(URI::_server);

sub default_port { 80 }

1;
