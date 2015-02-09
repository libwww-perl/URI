package URI::ircs;

require URI::irc;
@ISA=qw(URI::irc);

sub default_port { 994 }

sub secure { 1 }

1;
