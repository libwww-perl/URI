package URI;  # $Id: URI.pm,v 1.4 1998/04/09 18:26:57 aas Exp $

use strict;
use vars qw($VERSION $DEFAULT_SCHEME $STRICT $DEBUG);

$VERSION = "0.01";

$DEFAULT_SCHEME ||= "http";
#$STRICT = 0;
#$DEBUG = 0;
$DEBUG = 1;

my %implements;  # mapping from scheme to implementor class

# Some "official" character classes
my $reserved   = q(;/?:@&=+$,);
my $mark       = q(-_.!~*'());                                    #'; emacs
my $unreserved = "A-Za-z0-9\Q$mark\E";

use vars qw($uric $pchar $achar $ppchar);
$uric   = "\Q$reserved\E$unreserved%";
$pchar  = $uric;  $pchar =~ s,\\[/?;],,g;
$achar  = $uric;  $achar =~ s,\\[/?],,g;
$ppchar = $uric;  $ppchar =~ s,\\?,,g;

my $scheme_re = '[a-zA-Z][a-zA-Z0-9.+\-]*';

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
        $scheme = $1 if $url =~ m/^($scheme_re):/o;
	unless ($scheme) {
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
            # use generic as fallback
            require URI::_generic;
            $impclass = 'URI::_generic';
            implementor($scheme, $impclass);  # register it
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
    my $self = bless {}, $class;
    $self->{'_scheme'} = $scheme;
    $self->{'_orig_uri'} = $str if $DEBUG;
    $self->base($base) if $base;
    $self->_parse($str);
    $self;
}


sub _parse
{
    my($self, $str) = @_;
    # <scheme>:<scheme-specific-part>
    $self->{'scheme'} = $1 if $str =~ s/^($scheme_re)://o;
    $self->{'fragment'}   = $1 if $str =~ s/\#(.*)//s;
    $self->{'specific'} = $str;
}


sub implementor
{
    my($scheme, $impclass) = @_;
    unless (defined $scheme) {
        require URI::_generic;
        return 'URI::_generic';
    }
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
        die $@ if $@ && $@ !~ /Can\'t locate/;
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
    # this work as long as none of the components are references themselves
    bless { %$self }, ref $self;
}


sub _elem
{
    my $self = shift;
    my $elem = shift;
    my $old = $self->{$elem};
    if (@_) {
	$self->{$elem} = shift;
	$self->{'_str'} = '';        # void cached string
    }
    $old;
}


sub scheme
{
    my $self = shift;
    my $old = $self->{'scheme'};
    if (@_) {
	my $new_scheme = shift;
	if (defined($new_scheme) && length($new_scheme)) {
	    # reparse URI with new scheme
	    my $str = $self->as_string;
	    $str =~ s/^$scheme_re://o;
	    my $newself = URI->new("$new_scheme:$str");
	    %$self = %$newself;  # copy content
	    bless $self, ref($newself);
	} else {
	    $self->{'scheme'} = undef;
	}
    }
    $old;
}


sub fragment
{
    shift->_elem("fragment", @_);
}


sub as_string
{
    my $self = shift;
    if (my $str = $self->{'_str'}) {
	return $str;  # cached
    }
    $self->{'_str'} = $self->_as_string;  # set cache and return
}


sub _as_string
{
    my $self = shift;
    my $str = "";
    my($scheme, $specific, $fragment) = @{$self}{qw(scheme specific fragment)};
    $str = "$scheme:" if $scheme;
    $specific =~ s/([^$uric])/$URI::Escape::escapes{$1}/go;
    $str .= $specific;
    if (defined $fragment) {
	$fragment =~ s/([^$uric])/$URI::Escape::escapes{$1}/go;
	$str .= "#$fragment";
    }
    $str;
}


sub base {
    my $self = shift;
    my $base  = $self->{'_base'};

    if (@_) { # set
	my $new_base = shift;
	$new_base = $new_base->abs if ref($new_base);  # unsure absoluteness
	$self->{_base} = $new_base;
    }
    return unless defined wantarray;

    # The base attribute supports 'lazy' conversion from URI strings
    # to URI objects. Strings may be stored but when a string is
    # fetched it will automatically be converted to a URI object.
    # The main benefit is to make it much cheaper to say:
    #   URI->new($random_url_string, 'http:')
    if (defined($base) && !ref($base)) {
	$self->{'_base'} = $base = URI->new($base);
    }
    $base;
}


# Compare two URIs, subclasses will provide a more correct implementation
sub eq {
    my($self, $other) = @_;
    $other = URI->new($other, $self) unless ref $other;
    # XXX schemes should be compared case-insensitively
    ref($self) eq ref($other) &&                # same class
	$self->as_string eq $other->as_string;  # same string
}

# This is set up as an alias for various methods
sub _bad_access_method
{
    my $self = shift;
    if ($STRICT) {
	Carp::croak("Illegal method called for $self->{'_scheme'} URI")
    }
    if ($^W && @_) {
	Carp::carp("Setting not effective for $self->{'_scheme'} URI");
    }
    undef;
}

# generic-URI accessor methods
*authority = \&_bad_access_method;
*userinfo  = \&_bad_access_method;
*host      = \&_bad_access_method;
*port      = \&_bad_access_method;
*abs_path  = \&_bad_access_method;
*path      = \&_bad_access_method;
*path_segments = \&_bad_access_method;
*query     = \&_bad_access_method;

# generic-URI transformation methods
sub abs { shift->clone; }
sub rel { shift->clone; }

1;
