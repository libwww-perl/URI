package URI;  # $Id: URI.pm,v 1.13 1998/09/13 20:45:35 aas Exp $

use strict;
use vars qw($VERSION $DEFAULT_SCHEME $STRICT $DEBUG);
use vars qw($ABS_REMOTE_LEADING_DOTS $ABS_ALLOW_RELATIVE_SCHEME);

$VERSION = "0.10";

$DEFAULT_SCHEME ||= "http";

my %implements;  # mapping from scheme to implementor class

# Some "official" character classes

use vars qw($reserved $mark $unreserved $uric $scheme_re);
$reserved   = q(;/?:@&=+$,);
$mark       = q(-_.!~*'());                                    #'; emacs
$unreserved = "A-Za-z0-9\Q$mark\E";
$uric       = quotemeta($reserved) . $unreserved . "%";

$scheme_re  = '[a-zA-Z][a-zA-Z0-9.+\-]*';

use Carp ();
use URI::Escape ();

use overload ('""'     => sub { ${$_[0]} },
	      '=='     => sub { overload::StrVal($_[0]) eq
                                overload::StrVal($_[1])
                              },
              fallback => 1,
             );

sub new
{
    my($class, $url, $base) = @_;
    $url = defined ($url) ? "$url" : "";   # stringify

    # Get rid of potential wrapping
    $url =~ s/^<(?:URL:)?(.*)>$/$1/;  # 
    $url =~ s/^"(.*)"$/$1/;
    $url =~ s/^\s+//;
    $url =~ s/\s+$//;

    my $scheme;
    my $impclass;
    if ($url =~ m/^($scheme_re):/so) {
	$scheme = $1;
    } else {
	if ($impclass = ref($base)) {
	    $scheme = $base->scheme;
	} elsif ($base && $base =~ m/^($scheme_re)(?::|$)/o) {
	    $scheme = $1;
	} elsif ($DEFAULT_SCHEME && !$STRICT) {
	    $scheme = $DEFAULT_SCHEME;
	} else {
	    Carp::croak("Unable to determine scheme for '$url'");
	}
    }
    $impclass ||= implementor($scheme) ||
	do {
	    Carp::croak("URI scheme '$scheme' is not supported")
		if $STRICT;
	    
	    require URI::_generic;
	    $impclass = 'URI::_generic';
	};

    return $impclass->_init($url, $base, $scheme);
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

    # turn scheme into a valid perl identifier by a simple tranformation...
    $ic =~ s/\+/_P/g;
    $ic =~ s/\./_O/g;
    $ic =~ s/\-/_/g;

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


sub _scheme
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
	Carp::croak("Bad scheme '$new'") unless $new =~ /^$scheme_re$/o;
	my $newself = URI->new("$new:$$self");
	$$self = $$newself; 
	bless $self, ref($newself);
    } elsif ($$self =~ m/^$scheme_re:/o) {
	Carp::carp("Opaque part look like scheme") if $^W;
    }

    return $old;
}

sub scheme
{
    my $scheme = shift->_scheme(@_);
    return unless defined $scheme;
    lc($scheme);
}


sub opaque
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

    $$self = defined($old_scheme) ? $old_scheme : "";
    $$self .= $new_opaque;
    $$self .= $old_frag if defined $old_frag;

    $old_opaque;
}

*path = \&opaque;  # alias


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
    my $scheme = $self->_scheme || "";
    my $uc_scheme = $scheme =~ /[A-Z]/;
    my $lc_esc    = $$self =~ /%(?:[a-f][a-fA-F0-9]|[A-F0-9][a-f])/;
    if ($uc_scheme || $lc_esc) {
	my $other = $self->clone;
	$other->_scheme(lc $scheme) if $uc_scheme;
	$$other =~ s/(%(?:[a-f][a-fA-F0-9]|[A-F0-9][a-f]))/uc($1)/ge
	    if $lc_esc;
	return $other;
    }
    $self;
}

# Compare two URIs, subclasses will provide a more correct implementation
sub eq {
    my($self, $other) = @_;
    $other = URI->new($other, $self) unless ref $other;
    ref($self) eq ref($other) &&                # same class
	$self->canonical->as_string eq $other->canonical->as_string;
}

# generic-URI transformation methods
sub abs { $_[0]; }
sub rel { $_[0]; }

1;

__END__

=head1 NAME

URI - Uniform Resource Identifiers (absolute and relative)

=head1 SYNOPSIS

 $u1 = URI->new("http://www.perl.com");
 $u2 = URI->new("foo", "http");
 $u3 = $u2->abs($u1);
 $u4 = $u3->clone;
 $u5 = URI->new("HTTP://WWW.perl.com:80")->canonical;

 $str = $u->as_string;
 $str = "$u";

 $scheme = $u->scheme;
 $opaque = $u->opaque;
 $path   = $u->path;
 $frag   = $u->fragment;

 $u->scheme("ftp");
 $u->host("ftp.perl.com");
 $u->path("cpan/");

=head1 DESCRIPTION

This module implements the C<URI> class.  Objects of this class
represent Uniform Resource Identifiers (URI) references as specified
in RFC 2396.

A Uniform Resource Identifier is a compact string of characters for
identifying an abstract or physical resource.  A Uniform Resource
Identifier can be further classified either a Uniform Resource Locator
(URL) or a Uniform Resource Name (URN).  The distinction between URL
and URN is not reflected in the abstractions provided by the C<URI>
class.

The following methods are provided:

=over 4

=item $uri = URI->new( $str, [$scheme] )

=item $uri->clone

=item $uri->scheme( [$new_scheme] )

$uri->_scheme

=item $uri->opaque( [$new_opaque] )

=item $uri->path( [$new_path] )

=item $uri->fragment( [$new_frag] )

=item $uri->as_string

=item $uri->eq( $other_uri )

=item $uri->abs( $base_uri )

=item $uri->rel( $base_uri )

=back

Generic methods:

=over 4

=item $uri->query( [$new_query] )

=item $uri->query_form( [$key => $value,...] )

=item $uri->query_keywords( [$keywords,...] )

=item $uri->authority( [$new_authority] )

=item $uri->path_query( [$new_path_query] )

=item $uri->path_segments( [$segment,...] )

=back

Server methods:

=over 4

=item $uri->userinfo( [$new_userinfo] )

=item $uri->host( [$new_host] )

=item $uri->port( [ $new_port] )

$uri->_port()

=item $uri->default_port;

=back

=head1 SEE ALSO

L<URI::WithBase>, L<URI::Escape>, L<URI::Heuristic>

RFC 2396

=head1 COPYRIGHT

Copyright 1995-1998 Gisle Aas.

Copyright 1995 Martijn Koster.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHORS / ACKNOWLEDGMENTS

This module is based on the C<URI::URL> module, which in turn was
(distantly) based on the C<wwwurl.pl> code in the libwww-perl for
perl4 developed by Roy Fielding, as part of the Arcadia project at the
University of California, Irvine, with contributions from Brooks
Cutter.

C<URI::URL> was developed by Gisle Aas, Tim Bunce, Roy Fielding and
Martijn Koster with input from other people on the libwww-perl mailing
list.

=cut
