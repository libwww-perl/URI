package URI::http;
use base 'URI::_generic';

use strict;
use URI::Escape qw(uri_unescape %escapes);

sub default_port { 80 }

# Handle ...?dog+bones type of query
sub keywords
{
    my $self = shift;
    my $old = $self->{'query'};
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

# Handle ...?foo=bar&bar=foo type of query
sub query_form {
    my $self = shift;
    my $old = $self->{'query'};
    if (@_) {
        # Try to set query string
        my @query;
        while (my($key,$vals) = splice(@_, 0, 2)) {
            $key = '' unless defined $key;
            $key =~ s/(\W)/$escapes{$1}/g;
            $vals = [$vals] unless ref $vals;
            for my $val (@$vals) {
                $val = '' unless defined $val;
                $val =~ s/(\W)/$escapes{$1}/g;
                push(@query, "$key=$val");
            }
        }
        $self->query(join('&', @query));
    }
    return if !defined($old) || !length($old) || !defined(wantarray);
    map { s/\+/ /g; uri_unescape($_) }
         map { /=/ ? split(/=/, $_, 2) : ($_ => '')} split(/&/, $old);
}

1;
