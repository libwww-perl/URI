package URI::WithBase;

use strict;
use vars qw($AUTOLOAD);
use URI;

use overload '""' => "as_string", fallback => 1;

sub as_string;

sub new
{
    my($class, $uri, $base) = @_;
    my $ibase = $base;
    if ($base && UNIVERSAL::isa($base, "URI::WithBase")) {
	$base = $base->abs;
	$ibase = $base->[0];
    }
    bless [URI->new($uri, $ibase), $base], $class;
}

sub _init
{
    my $class = shift;
    my($str, $base, $scheme) = @_;
    die "Assertion failed" unless UNIVERSAL::isa($base, "URI::WithBase");
    $base = $base->abs;
    my $ibase = $base->[0];
    bless [URI->new($str, $ibase), $base], $class;
}

sub eq
{
    my($self, $other) = @_;
    $other = $other->[0] if UNIVERSAL::isa($other, "URI::WithBase");
    $self->[0]->eq($other);
}

sub AUTOLOAD
{
    my $self = shift;
    my $method = substr($AUTOLOAD, rindex($AUTOLOAD, '::')+2);
    return if $method eq "DESTROY";
    $self->[0]->$method(@_);
}

sub base {
    my $self = shift;
    my $base  = $self->[1];

    if (@_) { # set
	my $new_base = @_;
	$new_base = $new_base->abs if ref($new_base);  # ensure absoluteness
	$self->[1] = $new_base;
    }
    return unless defined wantarray;

    # The base attribute supports 'lazy' conversion from URL strings
    # to URL objects. Strings may be stored but when a string is
    # fetched it will automatically be converted to a URL object.
    # The main benefit is to make it much cheaper to say:
    #   URI::WithBase->new($random_url_string, 'http:')
    if (defined($base) && !ref($base)) {
	$base = URI->new($base);
	$self->[1] = $base unless @_;
    }
    $base;
}

sub clone
{
    my $self = shift;
    bless [$self->[0]->clone, $self->[0]], ref($self);
}

sub abs
{
    my $self = shift;
    my $base = shift || $self->base || return $self->clone;
    bless [$self->[0]->abs($base, @_), $base], ref($self);
}

sub rel
{
    my $self = shift;
    my $base = shift || $self->base || return $self->clone;
    bless [$self->[0]->rel($base, @_), $base], ref($self);
}

1;
