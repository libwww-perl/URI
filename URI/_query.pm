package URI::_query;

use strict;
use URI ();
use URI::Escape qw(uri_unescape);

sub query
{
    my $self = shift;
    $$self =~ m,^([^?\#]*)(?:\?([^\#]*))?(.*)$,s or die;
    
    if (@_) {
	my $q = shift;
	$$self = $1;
	if (defined $q) {
	    $q =~ s/([^$URI::uric])/$URI::Escape::escapes{$1}/go;
	    $$self .= "?$q";
	}
	$$self .= $3;
    }
    $2;
}

# Handle ...?foo=bar&bar=foo type of query
sub query_form {
    my $self = shift;
    my $old = $self->query;
    if (@_) {
        # Try to set query string
        my @query;
        while (my($key,$vals) = splice(@_, 0, 2)) {
            $key = '' unless defined $key;
	    $key =~ s/([=&%])/$URI::Escape::escapes{$1}/g;
	    $vals = [ref($vals) ? @$vals : $vals];
            for my $val (@$vals) {
                $val = '' unless defined $val;
		$val =~ s/([=&%])/$URI::Escape::escapes{$1}/g;
                push(@query, "$key=$val");
            }
        }
        $self->query(join('&', @query));
    }
    return if !defined($old) || !length($old) || !defined(wantarray);
    map { s/\+/ /g; uri_unescape($_) }
         map { /=/ ? split(/=/, $_, 2) : ($_ => '')} split(/&/, $old);
}

# Handle ...?dog+bones type of query
sub query_keywords
{
    my $self = shift;
    my $old = $self->query;
    if (@_) {
        # Try to set query string
	my $k;
        $self->query(join('+', map { $k = $_;
				     $k =~ s/%/%25/g;
                                     $k =~ s/\+/%2B/g;
                                     $k }
                                     @_));
    }
    return if !defined($old) || !defined(wantarray);
    map { uri_unescape($_) } split(/\+/, $old, -1);
}

1;
