package URI::ldapi;

use strict;

use vars qw(@ISA);

require URI::_generic;
require URI::_ldap;
@ISA=qw(URI::_ldap URI::_generic);

sub _nonldap_canonical {
    my $self = shift;
    $self->URI::_generic::canonical(@_);
}

1;
