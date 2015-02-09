package URI::ftpes;

require URI::ftp;
@ISA=qw(URI::ftp);

sub secure { 1 }

sub encrypt_mode { 'explicit' }

1;
