package URI::mailto;  # RFC 2368

require URI;
require URI::_query;
@ISA=qw(URI URI::_query);

use strict;

sub to
{
    my $self = shift;
    my $old = $self->opaque_part;
    if (@_) {
	my $new = shift;
	$new = "" unless defined $new;
	$old =~ s/^[^?]+//;
	$self->opaque_part("$new$old");
    }
    $old =~ s/\?.*//s;
    $old;
}

sub headers
{
    my $self = shift;
    my @old = $self->query_form;

    if (@_) {
	my @new = @_;

	# strip out any "to" fields
	my @to;
	for (my $i=0; $i < @new; $i += 2) {
	    #print ">$i $old[$i]\n";
	    if (lc($new[$i]) eq "to") {
		push(@to, (splice(@new, $i, 2))[1]);  # remove header
		redo;
	    }
	}

	$self->query_form(@new);
	$self->to(join(",",@to)) if @to;
    }

    # strip out any "to" fields
    for (my $i=0; $i < @old; $i += 2) {
	#print ">$i $old[$i]\n";
	if (lc($old[$i]) eq "to") {
	    splice(@old, $i, 2);  # remove header
	    redo;
	}
    }
    @old;
}

1;
