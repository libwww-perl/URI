package URI;  # $Id: URI.pm,v 1.15 1998/09/14 15:01:55 aas Exp $

use strict;
use vars qw($VERSION $DEFAULT_SCHEME $STRICT $DEBUG);
use vars qw($ABS_REMOTE_LEADING_DOTS $ABS_ALLOW_RELATIVE_SCHEME);

$VERSION = "0.09_01";

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


sub _no_scheme_ok { 0 }

sub _scheme
{
    my $self = shift;

    unless (@_) {
	return unless $$self =~ /^($scheme_re):/o;
	return $1;
    }

    my $old;
    my $new = shift;
    if (defined($new) && length($new)) {
	Carp::croak("Bad scheme '$new'") unless $new =~ /^$scheme_re$/o;
	$old = $1 if $$self =~ s/^($scheme_re)://o;
	my $newself = URI->new("$new:$$self");
	$$self = $$newself; 
	bless $self, ref($newself);
    } else {
	if ($self->_no_scheme_ok) {
	    $old = $1 if $$self =~ s/^($scheme_re)://o;
	    Carp::carp("Oops, opaque part now look like scheme")
		if $^W && $$self =~ m/^$scheme_re:/o
	} else {
	    $old = $1 if $$self =~ m/^($scheme_re):/o;
	}
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
    $self  = URI->new($self, $other) unless ref $self;
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
represent Uniform Resource Identifier (URI) references as specified
in RFC 2396.

A Uniform Resource Identifier is a compact string of characters for
identifying an abstract or physical resource.  A Uniform Resource
Identifier can be further classified either a Uniform Resource Locator
(URL) or a Uniform Resource Name (URN).  The distinction between URL
and URN is not reflected in the abstractions provided by the C<URI>
class.

An absolute URI reference consist of three parts.  A I<scheme>, a
I<scheme specific part> and a I<fragment> identifier.  A subset of URI
references share a common syntax for hierarchical namespaces.  For
those the scheme specific part is further broken down into
I<authority>, I<path> and I<query> components.  These can also take
the form of relative URI references, where the scheme (and usually
also the authority) component is missing, but implied by the context
of the URI reference usage.  The three forms of URI reference syntax
is summarized as follows:

  <scheme>:<scheme-specific-part>#<fragment>
  <scheme>://<authority><path>?<query>#<fragment>
  <path>?<query>#<fragment>

The components that a URI reference can be divided into depend on the
I<scheme>.  The C<URI> class provide methods to get and set the
individual components.  The set of methods available for a specific
URI object depend on the scheme.

=head1 CONSTRUCTORS

The following methods to construct new C<URI> objects are provided:

=over 4

=item $uri = URI->new( $str, [$scheme] )

This constructs a new URI object.  The string representation of a URI
is given as an argument together with an optional scheme
specification.  The constructor will determine the scheme, map this to
an appropriate URI subclass, construct a new object of this class and
return it.

The $scheme is only needed when $str takes a relative form.  The
$scheme argument can then either be a simple string that denotes the
scheme, a string containing an absolute URI reference or an absolute
C<URI> object.

=item $uri = URI::file->new( $filename, [$os] )

This constructs a new file:-URI from a file name.  See the section
about file methods below.

=item $uri->clone

This method returns a copy of the $uri.

=back

=head1 COMMON METHODS

The following methods are available for all C<URI> objects.

Methods that give access to components of a URI will always return the
value of the component.  The value returned will be C<undef> if the
component was not present.  If an accessor method is given an argument
it will update the corresponding component in addition to returning
the old value.  Passing an undefined argument will remove the
component (if possible).

=over 4

=item $uri->scheme( [$new_scheme] )

When called without an argument it will return the scheme of the $uri.
If the $uri is relative, $uri->scheme will return undef.  If called
with an argument we will update the scheme of the $uri and return the
old value.  The method will croak if the new scheme name is illegal;
scheme names must begin with a letter and must consist of only
US-ASCII letters, numbers, and a few special marks: ".", "+", "-".
Passing an undefined argument to $uri->scheme will make the URI
relative (if possible).

Scheme names should be treated as case insensitive.  The scheme
returned by $uri->scheme is always lowercased.  If you want the scheme
just as it was written in the URI, i.e. not necessarily lowercased,
you can use the $uri->_scheme method instead.

=item $uri->opaque( [$new_opaque] )

The scheme specific part can be accessed with this method.  The value
is escaped.

=item $uri->path( [$new_path] )

This method access the same stuff as $uri->opaque unless the URI
support the common/generic syntax for hierarchical namespaces where the
path is more restricted.

=item $uri->fragment( [$new_frag] )

The fragment identifier of a URI reference can be accessed with this
method.  The value is escaped.

=item $uri->as_string

This method convert a URI object to a plain string.  URI objects are
also converted to plain strings automatically by overloading.

=item $uri->canonical

This method will return a normalized version of the URI.  The rules
for normalization is scheme dependent.  It usually involves
lowercasing of the scheme and host name components.  Removal of
explicit port specification that match the default port and unescaping
of octets that can be represented by plain characters.

=item $uri->eq( $other_uri )

=item URI::eq( $first_uri, $other_uri )

This method test whether two URI references are equal.  The method can
also be used as a plain function and can then also test two string
arguments.

If you need to test whether two URI objects are the same, you can use
the '==' operator.

=item $uri->abs( $base_uri )

This method will return an absolute URI reference.  If $uri already
was absolute, then it is just returned.  If the $uri was relative then
a new URI is created.

=item $uri->rel( $base_uri )

This method will return a relative URI reference if possible.

=back

=head1 GENERIC METHODS

The following methods are available to schemes that use the
common/generic syntax for hierarchical namespaces.

=over 4

=item $uri->authority( [$new_authority] )

=item $uri->path( [$new_path] )

=item $uri->path_query( [$new_path_query] )

=item $uri->path_segments( [$segment,...] )

=item $uri->query( [$new_query] )

=item $uri->query_form( [$key => $value,...] )

=item $uri->query_keywords( [$keywords,...] )

=back

=head1 SERVER METHODS

Schemes where the I<authority> component denote a Internet host will
have the following methods available in addition to the generic
methods.

=over 4

=item $uri->userinfo( [$new_userinfo] )

=item $uri->host( [$new_host] )

=item $uri->port( [ $new_port] )

$uri->_port()

=item $uri->default_port;

=back

=head1 SCHEME SPECIFIC SUPPORT

The following URI schemes are specifically supported.  For C<URI>
objects not belonging to one of these you can only use the common and
generic methods.

=over 4

=item B<data>:

The I<data> URI scheme is specified in RFC 2397.  It allows inclusion
of small data items as "immediate" data, as if it had been included
externally.

C<URI> objects belonging to the data scheme support the common methods
and two new methods to access their scheme specific components;
$uri->media_type and $uri->data.

=item B<file>:

An old speficication of the I<file> URI scheme is found in RFC 1738.
A new RFC 2396 based specification in not available yet, but file URI
references are in common use.

URI::file constructors: URI::file->new, URI::file->new_abs,
URI::file->cwd

C<URI> objects belonging to the file scheme support the common and
generic methods.  In addition we provide two methods to map file URI
back to local file names; $uri->file and $uri->dir.

=item B<ftp>:

An old speficication of the I<ftp> URI scheme is found in RFC 1738.  A
new RFC 2396 based specification in not available yet, but ftp URI
references are in common use.

C<URI> objects belonging to the ftp scheme support the common,
generic and server methods.  In addition we provide two methods to
access the userinfo components: $uri->user and $uri->password

=item B<gopher>:

The I<gopher> URI scheme is specified in
<draft-murali-url-gopher-1996-12-04> and will hopefully soon be
available as a RFC 2396 based specification.

C<URI> objects belonging to the gopher scheme support the common,
generic and server methods. In addition we support some methods to
access gopher specific path components: $uri->gopher_type,
$uri->selector, $uri->search, $uri->string.

=item B<http>:

The I<http> URI scheme is specified in
<draft-ietf-http-v11-spec-rev-04> (which will become an RFC soon).
The scheme is used to reference objects hosted by a HTTP server.

C<URI> objects belonging to the http scheme support the common,
generic and server methods.

=item B<https>:

The I<http> URI scheme is a Netscape invention which is commonly
implemented.  It's syntax is equal of that of http, but the default
port is different.

=item B<mailto>:

The I<mailto> URI scheme is specified in RFC 2368.  The scheme was
originally used to designate the Internet mailing address of an
individual or service.  It has been extended to allow setting mail
header fields and the message body.

C<URI> objects belonging to the mailto scheme support the common
methods and the generic query methods.  In addition we support the
following mailto specific methods: $uri->to, $uri->headers.

=item B<news>:

The I<news>, I<nntp> and I<snews> URI schemes are specified in
<draft-gilman-news-url-01> and will hopefully soon be available as a
RFC 2396 based specification.

=item B<nntp>:

See I<news> schme.

=item B<pop>:

The I<pop> URI scheme is specified in RFC 2384. The scheme is used to
reference a POP3 mailbox.

C<URI> objects belonging to the pop scheme support the common, generic
and server methods.  In addition we provide two methods to access the
userinfo components: $uri->user and $uri->auth


=item B<rlogin>:

An old speficication of the I<rlogin> URI scheme is found in RFC
1738. C<URI> objects belonging to the rlogin scheme support the
common, generic and server methods.

=item B<snews>:

See I<news> scheme.  It's syntax is equal of that of news, but the default
port is different.

=item B<telnet>:

An old speficication of the I<telnet> URI scheme is found in RFC
1738. C<URI> objects belonging to the telnet scheme support the
common, generic and server methods.

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
