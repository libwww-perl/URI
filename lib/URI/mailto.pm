package URI::mailto;    # RFC 2368

use strict;
use warnings;

our $VERSION = '5.38';

use parent qw(URI URI::_query);

use URI::Escape qw(uri_escape uri_unescape);

sub to {
    my $self = shift;
    my @old  = $self->headers;
    if (@_) {
        my @new = @old;

        # get rid of any other to: fields
        for (my $i = 0; $i < @new; $i += 2) {
            if (lc($new[$i] || '') eq "to") {
                splice(@new, $i, 2);
                redo;
            }
        }

        my $to = shift;
        $to = "" unless defined $to;
        unshift(@new, "to" => $to);
        $self->headers(@new);
    }
    return unless defined wantarray;

    my @to;
    while (@old) {
        my $h = shift @old;
        my $v = shift @old;
        push(@to, $v) if lc($h) eq "to";
    }
    join(",", @to);
}


sub headers {
    my $self = shift;

    # The trick is to just treat everything as the query string...
    my $opaque = "to=" . $self->opaque;
    $opaque =~ s/\?/&/;

    if (@_) {
        my @new = @_;

        # strip out any "to" fields
        my @to;
        for (my $i = 0; $i < @new; $i += 2) {
            if (lc($new[$i] || '') eq "to") {
                push(@to, (splice(@new, $i, 2))[1]);    # remove header
                redo;
            }
        }

        # RFC 6068 section 2: these would otherwise end the address or start
        # another header.
        my $new = uri_escape(join(q{,}, @to), q{%?&;});
        $self->opaque($new);
        $self->query_form(@new) if @new;
    }
    return unless defined wantarray;

    # I am lazy today...
    URI->new("mailto:?$opaque")->query_form;
}

# Recipient plus signs are literal (RFC 6068, section 5). Decode the
# original values so percent-encoded spaces remain distinct from plus signs.
sub query_form {
    my $self   = shift;
    my $query  = $self->query;
    my @fields = $self->SUPER::query_form(@_);
    if (@_) {

        # The form encoder uses + for spaces; recipient + must stay literal.
        my $new = $self->query;
        if (defined $new) {
            $new =~ s{((?:^|[&;])to=)([^&;]*)}{
                my ($prefix, $value) = ($1, $2);
                $value =~ s/\+/%20/g;
                "$prefix$value";
            }gie;
            $self->query($new);
        }
    }
    my @raw = defined $query ? split(/[&;]/, $query) : ();
    for (my $i = 0; $i < @fields; $i += 2) {
        if (lc($fields[$i]) eq q{to}) {
            my (undef, $value) = split(/=/, $raw[$i / 2], 2);
            $fields[$i + 1] = uri_unescape($value) if defined $value;
        }
    }
    return @fields;
}

1;
