package URI::http;

require URI::_server;
@ISA=qw(URI::_server);

sub default_port { 80 }

sub canonical
{
    my $self = shift;
    my $other = $self->SUPER::canonical;
    if (defined($other->authority) &&
        !length($other->path) && !defined($other->query)) {
	$other = $other->clone if $other == $self;
	$other->path("/");
	return $other;
    }
    # XXX should also unescape any unreserved uric characters
    $other;
}

1;
