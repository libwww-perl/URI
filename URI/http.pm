package URI::http;

require URI::_server;
@ISA=qw(URI::_server);

use strict;

sub default_port { 80 }

sub canonical
{
    my $self = shift;
    my $other = $self->SUPER::canonical;

    # Technically, x-www-form-urlencoded data should use plus signs
    # and CR/LF, as it otherwise breaks HTML/4.01
    if ($$other =~ /^[^\?]+\?(.+)/) {
        my $query = $1;
        $query =~ s/ |%20/+/g;
        $query =~ s/(?<!%0D)%0A/%0D%0A/g;
        $$other =~ s/^[^\?]+\?\K.+/$query/g;
    }

    my $slash_path = defined($other->authority) &&
        !length($other->path) && !defined($other->query);

    if ($slash_path) {
	$other = $other->clone if $other == $self;
	$other->path("/");
    }
    $other;
}

1;
