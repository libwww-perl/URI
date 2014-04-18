package URI::ftps;

require URI::ftp;
@ISA=qw(URI::ftp);

sub default_port { 990 }

sub secure { 1 }

1;
