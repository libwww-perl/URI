package URI::_query;

use strict;
use warnings;
use Carp;

use URI ();
use URI::Escape qw(uri_unescape);

our $VERSION = '1.77';

sub query
{
    my $self = shift;
    $$self =~ m,^([^?\#]*)(?:\?([^\#]*))?(.*)$,s or die;

    if (@_) {
	my $q = shift;
	$$self = $1;
	if (defined $q) {
	    $q =~ s/([^$URI::uric])/ URI::Escape::escape_char($1)/ego;
	    utf8::downgrade($q);
	    $$self .= "?$q";
	}
	$$self .= $3;
    }
    $2;
}

# ->query_elements(['keyword'],[key=>'value']);
# ->query_elements(['keyword'],[key=>'value'],$delimiter);
sub query_elements {
    my $self = shift;
    my $old = $self->query;

    if (@_) {
        # get delimiter
        my $delim;
        if (!ref($_[-1])) {
            $delim = pop;
        }
        if (!$delim) {
            $delim = $1 if $old && $old =~ /([&;])/;
            $delim ||= $URI::DEFAULT_QUERY_FORM_DELIMITER || "&";
        }

        my @query;
        for my $elem (@_) {
            my ($is_keyword,$key,$vals);
            if (ref($elem) eq "HASH" && keys(%$elem)==1) {
                ($is_keyword,$key,$vals) = ( 0, %$elem );
            }
            elsif (ref($elem) eq "ARRAY") {
                ($is_keyword,$key,$vals) = ( 1, undef, $elem );
            }
            else {
                croak "query_elements accepts only a list of 1-key hashref or arrayrefs";
            }

            if ($is_keyword) {
                my @keywords = map {
                    my $key = $_;
                    $key =~ s/([;\/?:@&=+,\$\[\]%])/ URI::Escape::escape_char($1)/eg;
                    $key
                } @$vals;
                push(@query, join('+', @keywords)) if @keywords;
            }
            else {
                $key = '' unless defined $key;
                $key =~ s/([;\/?:@&=+,\$\[\]%])/ URI::Escape::escape_char($1)/eg;
                $key =~ s/ /+/g;
                $vals = [ref($vals) eq "ARRAY" ? @$vals : $vals];
                for my $val (@$vals) {
                    $val = '' unless defined $val;
                    $val =~ s/([;\/?:@&=+,\$\[\]%])/ URI::Escape::escape_char($1)/eg;
                    $val =~ s/ /+/g;
                    push(@query, "$key=$val");
                }
            }
        }
        if (@query) {
            $self->query(join($delim, @query));
        }
        else {
            $self->query(undef);
        }
    }

    return if !defined($old) || !length($old) || !defined(wantarray);
    map { /=/
              ? { map { s/\+/ /g; uri_unescape($_) } split(/=/, $_, 2) }
              : [ map { uri_unescape($_) } split(/\+/, $_, -1) ]
          } split(/[&;]/, $old);
}

# Handle ...?foo=bar&bar=foo type of query
sub query_form {
    my $self = shift;
    my @old_elements = $self->query_elements;
    if (@_) {
        # Try to set query string
        my $delim;
        my $r = $_[0];
        if (ref($r) eq "ARRAY") {
            $delim = $_[1];
            @_ = @$r;
        }
        elsif (ref($r) eq "HASH") {
            $delim = $_[1];
            @_ = map { $_ => $r->{$_} } sort keys %$r;
        }
        $delim = pop if @_ % 2;

        my @query;
        while (my($key,$vals) = splice(@_, 0, 2)) {
            push @query, {$key => $vals};
        }
        if (@query) {
            $self->query_elements(@query,$delim);
        }
        else {
            $self->query_elements([]);
        }
    }

    return if !@old_elements || !defined(wantarray);
    map { %$_ } grep { ref($_) eq "HASH" } @old_elements;
}

# Handle ...?dog+bones type of query
sub query_keywords
{
    my $self = shift;
    my @old_elements = $self->query_elements;
    if (@_) {
        # Try to set query string
        $self->query_elements(ref($_[0])?$_[0]:[@_]);
    }

    return if !@old_elements || !defined(wantarray);
    map { @$_ } grep { ref($_) eq "ARRAY" } @old_elements;
}

# Some URI::URL compatibility stuff
sub equery { goto &query }

1;
