package URI::urn;  # RFC 2141

require URI;
@ISA=qw(URI);

use strict;

sub _nid {
    my $self = shift;
    my $opaque = $self->opaque;
    if (@_) {
	my $v = $opaque;
	my $new = shift;
	$v =~ s/[^:]*/$new/;
	$self->opaque($v);
	# XXX possible rebless
    }
    $opaque =~ s/:.*//s;
    return $opaque;
}

sub nid {  # namespace identifier
    my $self = shift;
    my $nid = $self->_nid(@_);
    $nid = lc($nid) if defined($nid);
    return $nid;
}

sub nss {  # namespace specific string
    my $self = shift;
    my $opaque = $self->opaque;
    if (@_) {
	my $v = $opaque;
	my $new = shift;
	if (defined $new) {
	    $v =~ s/(:|\z).*/:$new/;
	}
	else {
	    $v =~ s/:.*//s;
	}
	$self->opaque($v);
    }
    $opaque =~ s/:.*//s;
    return $opaque;
}

sub canonical {
    my $self = shift;
    my $nid = $self->_nid;
    warn "XXX $nid\n";
    return $self->SUPER::canonical if $nid !~ /[A-Z]/ || $nid =~ /%/;

    my $new = $self->SUPER::canonical;
    $new = $new->clone if $new == $self;
    warn;
    $new->nid(lc($nid));
    return $new;
}

1;
