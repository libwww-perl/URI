package URI::_query;  # we fill methods into this namespace still

use strict;

sub query_param {
    my $self = shift;
    my @old = $self->query_form;

    if (@_ == 0) {
	# get keys
	my %seen;
	my @keys;
	for (my $i = 0; $i < @old; $i += 2) {
	    push(@keys, $old[$i]) unless $seen{$old[$i]}++;
	}
	return @keys;
    }

    my $key = shift;
    my @i;

    for (my $i = 0; $i < @old; $i += 2) {
	push(@i, $i) if $old[$i] eq $key;
    }

    if (@_) {
	my @new = @old;
	my @new_i = @i;
	my @vals = map { ref($_) eq 'ARRAY' ? @$_ : $_ } @_;
	#print "VALS:@vals [@i]\n";
	while (@new_i > @vals) {
	    #print "REMOVE $new_i[-1]\n";
	    splice(@new, pop(@new_i), 2);
	}
	while (@vals > @new_i) {
	    my $i = @new_i ? $new_i[-1] + 2 : @new;
	    #print "SPLICE $i\n";
	    splice(@new, $i, 0, $key => pop(@vals));
	}
	for (@vals) {
	    #print "SET $new_i[0]\n";
	    $new[shift(@new_i)+1] = $_;
	}

	$self->query_form(@new);
    }

    return wantarray ? @old[@i] : @i ? $old[$i[0]] : undef;
}

sub query_param_append {
    my $self = shift;
    my $key = shift;
    $self->query_form($self->query_form, $key => \@_);  # XXX
}

sub query_param_delete {
    my $self = shift;
    my $key = shift;
    my @old = $self->query_form;
    my @vals;

    for (my $i = @old - 2; $i >= 0; $i -= 2) {
	next if $old[$i] ne $key;
	push(@vals, (splice(@old, $i, 2))[1]);
    }
    $self->query_form(@old) if @vals;
    return wantarray ? reverse @vals : $vals[-1];
}

sub query_hash {
    my $self = shift;
    my @old = $self->query_form;
    if (@_) {
	$self->query_form(@_ == 1 ? %{shift(@_)} : @_);
    }
    my %hash;
    while (my($k, $v) = splice(@old, 0, 2)) {
	if (exists $hash{$k}) {
	    for ($hash{$k}) {
		$_ = [$_] unless ref($_) eq "ARRAY";
		push(@$_, $v);
	    }
	}
	else {
	    $hash{$k} = $v;
	}
    }
    return \%hash;
}

1;

__END__

