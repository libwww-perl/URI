package URI::http;

require URI::_server;
@ISA=qw(URI::_server);

use strict;
use URI::Escape qw(uri_unescape %escapes);

sub default_port { 80 }

# Handle ...?dog+bones type of query
sub keywords
{
    my $self = shift;
    my $old = $self->query;
    if (@_) {
        # Try to set query string
        $self->query(join('+', map { my $k = $_;
                                     $k =~ s/(\W)/$escapes{$1}/g;
                                     $k }
                                     @_));
    }
    return if !defined($old) || !defined(wantarray);
    map { uri_unescape($_) } split(/\+/, $old, -1);
}

1;
