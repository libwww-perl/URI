package URI;  # $Id: URI.pm,v 1.7.2.6 1998/09/05 23:52:42 aas Exp $

use strict;
use vars qw($VERSION $DEFAULT_SCHEME $STRICT $DEBUG);

$VERSION = "0.04";

$DEFAULT_SCHEME ||= "http";
#$STRICT = 0;
#$DEBUG = 0;
$DEBUG = 1;

my %implements;  # mapping from scheme to implementor class

# Some "official" character classes
my $reserved   = q(;/?:@&=+$,);
my $mark       = q(-_.!~*'());                                    #'; emacs
my $unreserved = "A-Za-z0-9\Q$mark\E";

use vars qw($uric $pchar $achar $ppchar $scheme_re);
$uric   = "\Q$reserved\E$unreserved%";
$pchar  = $uric;  $pchar  =~ s,\\[/?;],,g;
$achar  = $uric;  $achar  =~ s,\\[/?],,g;
$ppchar = $uric;  $ppchar =~ s,\\[?],,g;

$scheme_re = '[a-zA-Z][a-zA-Z0-9.+\-]*';

#print "$uric\n$achar\n$pchar\n";

use Carp ();
use URI::Escape ();

use overload ( '""' => 'as_string', 'fallback' => 1 );

sub new
{
    my($class, $url, $base) = @_;
    my $self;
    if (ref $url) {
	$self = $url->clone;
	$self->base($base) if $base
    } else {
	$url = "" unless defined $url;
	# Get rid of potential wrapping
        $url =~ s/^<(?:URL:)?(.*)>$/$1/;  # 
	$url =~ s/^"(.*)"$/$1/;
        $url =~ s/^\s+//;
	$url =~ s/\s+$//;

	# We need a scheme to determine which class to use
        my $scheme;
	if ($url =~ m/^($scheme_re):/so) {
	    $scheme = $1;
	} else {
            if (ref $base){
                $scheme = $base->scheme;
	    } elsif ($base && $base =~ m/^($scheme_re):/o) {
                $scheme = $1;
	    } elsif ($DEFAULT_SCHEME && !$STRICT) {
		$scheme = $DEFAULT_SCHEME;
	    } else {
		Carp::croak("Unable to determine scheme for '$url'");
	    }
        }
	my $impclass = implementor($scheme);
        unless ($impclass) {
            Carp::croak("URI scheme '$scheme' is not supported")
		if $STRICT;
	    
	    require URI::_generic;
	    $impclass = 'URI::_generic';
        }
        # hand-off to scheme specific implementation sub-class
        $self = $impclass->_init($url, $base, $scheme);
    }
    $self;
}


sub _init
{
    my $class = shift;
    my($str, $base, $scheme) = @_;
    $str =~ s/([^$uric\#])/$URI::Escape::escapes{$1}/go;
    my $self = bless \$str, $class;
    $self;
}


sub implementor
{
    my($scheme, $impclass) = @_;
    $scheme = lc($scheme);

    if ($impclass) {
	# Set the implementor class for a given scheme
        my $old = $implements{$scheme};
        $impclass->_init_implementor($scheme);
        $implements{$scheme} = $impclass;
        return $old;
    }

    my $ic = $implements{$scheme};
    return $ic if $ic;

    # scheme not yet known, look for internal or
    # preloaded (with 'use') implementation
    $ic = "URI::$scheme";  # default location
    no strict 'refs';
    # check we actually have one for the scheme:
    unless (defined @{"${ic}::ISA"}) {
        # Try to load it
        eval "require $ic";
        die $@ if $@ && $@ !~ /Can\'t locate.*in \@INC/;
        return unless defined @{"${ic}::ISA"};
    }

    $ic->_init_implementor($scheme);
    $implements{$scheme} = $ic;
    $ic;
}


sub _init_implementor
{
    my($class, $scheme) = @_;
    # Remember that one implementor class may actually
    # serve to implement several URI schemes.
}


sub clone
{
    my $self = shift;
    my $other = $$self;
    bless \$other, ref $self;
}


sub scheme
{
    my $self = shift;

    unless (@_) {
	return unless $$self =~ /^($scheme_re):/o;
	return $1;
    }

    my $old;
    $old = $1 if $$self =~ s/^($scheme_re)://o;

    my $new = shift;
    if (defined($new) && length($new)) {
	die "Bad scheme '$new'" unless $new =~ /^$scheme_re$/o;
	my $newself = URI->new("$new:$$self");
	$$self = $$newself; 
	bless $self, ref($newself);
    } elsif ($$self =~ m/^$scheme_re:/) {
	warn "Opaque part look like scheme";
    }

    return $old;
}


sub opaque_part
{
    my $self = shift;

    unless (@_) {
	$$self =~ /^(?:$scheme_re:)?([^\#]*)/o or die;
	return $1;
    }

    $$self =~ /^($scheme_re:)?    # optional scheme
	        ([^\#]*)          # opaque
                (\#.*)?           # optional fragment
              $/sx or die;

    my $old_scheme = $1;
    my $old_opaque = $2;
    my $old_frag   = $3;

    my $new_opaque = shift;
    $new_opaque = "" unless defined $new_opaque;
    $new_opaque =~ s/([^$uric])/$URI::Escape::escapes{$1}/go;

    $$self = "";
    $$self .= $old_scheme if defined $old_scheme;
    $$self .= $new_opaque;
    $$self .= $old_frag if defined $old_frag;

    $old_opaque;
}


sub fragment
{
    my $self = shift;
    unless (@_) {
	return unless $$self =~ /\#(.*)/s;
	return $1;
    }

    my $old;
    $old = $1 if $$self =~ s/\#(.*)//s;

    my $new_frag = shift;
    if (defined $new_frag) {
	$new_frag =~ s/([^$uric])/$URI::Escape::escapes{$1}/go;
	$$self .= "#$new_frag";
    }
    $old;
}


sub as_string
{
    my $self = shift;
    $$self;
}


sub canonical
{
    my $self = shift;

    # Make sure scheme is lowercased
    my $scheme = $self->scheme;
    if ($scheme =~ /[A-Z]/) {
	my $other = $self->clone;
	$other->scheme(lc $scheme);
	return $other;
    }
    # XXX might also want to ensure that we only use either upper or
    # lower case hex digits in %xx escapes.

    $self;
}

# Compare two URIs, subclasses will provide a more correct implementation
sub eq {
    my($self, $other) = @_;
    $other = URI->new($other, $self) unless ref $other;
    ref($self) eq ref($other) &&                # same class
	$self->canonical->as_string eq $other->canonical->as_string;
}

1;

__END__

# This is set up as an alias for various methods
sub _bad_access_method
{
    my $self = shift;
    my $type = ref($self) || "URI";
    if ($STRICT) {
	Carp::croak("Illegal method called for $type");
    }
    if ($^W && @_) {
	Carp::carp("Setting not effective for $type");
    }
    undef;
}

# generic-URI accessor methods
*authority      = \&_bad_access_method;
*userinfo       = \&_bad_access_method;
*host           = \&_bad_access_method;
*port           = \&_bad_access_method;
*abs_path_query = \&_bad_access_method;
*path           = \&_bad_access_method;
*path_segments  = \&_bad_access_method;
*query          = \&_bad_access_method;

# generic-URI transformation methods
sub abs { shift->clone; }
sub rel { shift->clone; }

1;
