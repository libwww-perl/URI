package URI::_server;
require URI::_generic;
@ISA=qw(URI::_generic);

use strict;
use URI::Escape ();

sub userinfo
{
    my $self = shift;
    my $old = $self->authority;

    if (@_) {
	my $new = $old;
	$new = "" unless defined $new;
	$new =~ s/^[^@]*@//;  # remove old stuff
	my $ui = shift;
	if (defined $ui) {
	    $ui =~ s/@/%40/g;   # protect @
	    $new = "$ui\@$new";
	}
	$self->authority($new);
    }
    return undef if !defined($old) || $old !~ /^([^@]*)@/;
    return $1;
}

sub host
{
    my $self = shift;
    my $old = $self->authority;
    if (@_) {
	my $tmp = $old;
	$tmp = "" unless defined $tmp;
	my $ui;
	$ui = $1 if $tmp =~ s/^([^@]*@)//;
	$tmp =~ s/^[^:]*//;        # get rid of old host
	my $new = shift;
	if (defined $new) {
	    $new =~ s/[@]/%40/g;   # protect @
	    $tmp = ($new =~ /:/) ? $new : "$new$tmp";
	}
	$tmp = "$ui$tmp" if defined $ui;
	$self->authority($tmp);
    }
    return undef if !defined($old) || $old !~ /^(?:[^@]*@)?([^:]*)/;
    return $1;
}

sub port
{
    my $self = shift;
    my $old = $self->authority;
    if (@_) {
	my $new = $old;
	$new =~ s/:.*$//;
	my $port = shift;
	$new .= ":$port" if defined $port;
	$self->authority($new);
    }
    return $1 if defined($old) && $old =~ /:(\d+)$/;
    $self->default_port;
}

sub default_port { undef }

sub canonical
{
    my $self = shift;
    my $scheme = $self->scheme;
    my $host = $self->host;
    if ($scheme =~ /[A-Z]/ || $host =~ /[A-Z]/) {
	my $other = $self->clone;
	$other->scheme(lc $scheme);
	$other->host(lc $host);
	return $other;
    }
    $self;
}

1;
