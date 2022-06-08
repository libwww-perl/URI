package URI::_generic;

use strict;
use warnings;

use parent qw(URI URI::_query);

use URI::Escape qw(uri_unescape);
use Carp ();

our $VERSION = '5.11';

my $ACHAR = URI::HAS_RESERVED_SQUARE_BRACKETS ? $URI::uric : $URI::uric4host;  $ACHAR =~ s,\\[/?],,g;
my $PCHAR = $URI::uric;                                                        $PCHAR =~ s,\\[?],,g;

sub _no_scheme_ok { 1 }

our $IPv6_re;
{ #-- "borrowed" from SALVAs Regexp::IPv6 - https://metacpan.org/dist/Regexp-IPv6/source/lib/Regexp/IPv6.pm
  #TODO: Should be made a dependency of this module.
  my $IPv4 = "((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))";
  my $G = "[0-9a-fA-F]{1,4}";

  my @tail = ( ":",
               "(:($G)?|$IPv4)",
               ":($IPv4|$G(:$G)?|)",
               "(:$IPv4|:$G(:$IPv4|(:$G){0,2})|:)",
               "((:$G){0,2}(:$IPv4|(:$G){1,2})|:)",
               "((:$G){0,3}(:$IPv4|(:$G){1,2})|:)",
               "((:$G){0,4}(:$IPv4|(:$G){1,2})|:)" );

  $IPv6_re = $G;
  $IPv6_re = "$G:($IPv6_re|$_)" for @tail;
  $IPv6_re = qq/:(:$G){0,5}((:$G){1,2}|:$IPv4)|$IPv6_re/;
  $IPv6_re =~ s/\(/(?:/g;
  $IPv6_re = qr/$IPv6_re/;
}


sub _looks_like_raw_ip6_address {
  my $addr = shift;
  #TODO: use Regexp::IPv6
  return 1 if $addr and $addr =~ /^$IPv6_re$/;
  return 0;
}


sub authority
{
    my $self = shift;
    $$self =~ m,^((?:$URI::scheme_re:)?)(?://([^/?\#]*))?(.*)$,os or die;

    if (@_) {
	my $auth = shift;
	$$self = $1;
	my $rest = $3;
	if (defined $auth) {
	    $auth =~ s/([^$ACHAR])/ URI::Escape::escape_char($1)/ego;
            if ( my ($user, $host) = $auth =~ /^(.*@)?([^@]+)$/ ) { #-- special escape userinfo part
              $user ||= '';
              $user =~ s/([^$URI::uric4user])/ URI::Escape::escape_char($1)/ego;
              $user =~ s/%40$/\@/; # recover final '@'
              $host = "[$host]" if _looks_like_raw_ip6_address( $host );
              $auth = $user . $host;
            }
	    utf8::downgrade($auth);
	    $$self .= "//$auth";
	}
	_check_path($rest, $$self);
	$$self .= $rest;
    }
    $2;
}

sub path
{
    my $self = shift;
    $$self =~ m,^((?:[^:/?\#]+:)?(?://[^/?\#]*)?)([^?\#]*)(.*)$,s or die;

    if (@_) {
	$$self = $1;
	my $rest = $3;
	my $new_path = shift;
	$new_path = "" unless defined $new_path;
	$new_path =~ s/([^$PCHAR])/ URI::Escape::escape_char($1)/ego;
	utf8::downgrade($new_path);
	_check_path($new_path, $$self);
	$$self .= $new_path . $rest;
    }
    $2;
}

sub path_query
{
    my $self = shift;
    $$self =~ m,^((?:[^:/?\#]+:)?(?://[^/?\#]*)?)([^\#]*)(.*)$,s or die;

    if (@_) {
	$$self = $1;
	my $rest = $3;
	my $new_path = shift;
	$new_path = "" unless defined $new_path;
	$new_path =~ s/([^$URI::uric])/ URI::Escape::escape_char($1)/ego;
	utf8::downgrade($new_path);
	_check_path($new_path, $$self);
	$$self .= $new_path . $rest;
    }
    $2;
}

sub _check_path
{
    my($path, $pre) = @_;
    my $prefix;
    if ($pre =~ m,/,) {  # authority present
	$prefix = "/" if length($path) && $path !~ m,^[/?\#],;
    }
    else {
	if ($path =~ m,^//,) {
	    Carp::carp("Path starting with double slash is confusing")
		if $^W;
	}
	elsif (!length($pre) && $path =~ m,^[^:/?\#]+:,) {
	    Carp::carp("Path might look like scheme, './' prepended")
		if $^W;
	    $prefix = "./";
	}
    }
    substr($_[0], 0, 0) = $prefix if defined $prefix;
}

sub path_segments
{
    my $self = shift;
    my $path = $self->path;
    if (@_) {
	my @arg = @_;  # make a copy
	for (@arg) {
	    if (ref($_)) {
		my @seg = @$_;
		$seg[0] =~ s/%/%25/g;
		for (@seg) { s/;/%3B/g; }
		$_ = join(";", @seg);
	    }
	    else {
		 s/%/%25/g; s/;/%3B/g;
	    }
	    s,/,%2F,g;
	}
	$self->path(join("/", @arg));
    }
    return $path unless wantarray;
    map {/;/ ? $self->_split_segment($_)
             : uri_unescape($_) }
        split('/', $path, -1);
}


sub _split_segment
{
    my $self = shift;
    require URI::_segment;
    URI::_segment->new(@_);
}


sub abs
{
    my $self = shift;
    my $base = shift || Carp::croak("Missing base argument");

    if (my $scheme = $self->scheme) {
	return $self unless $URI::ABS_ALLOW_RELATIVE_SCHEME;
	$base = URI->new($base) unless ref $base;
	return $self unless $scheme eq $base->scheme;
    }

    $base = URI->new($base) unless ref $base;
    my $abs = $self->clone;
    $abs->scheme($base->scheme);
    return $abs if $$self =~ m,^(?:$URI::scheme_re:)?//,o;
    $abs->authority($base->authority);

    my $path = $self->path;
    return $abs if $path =~ m,^/,;

    if (!length($path)) {
	my $abs = $base->clone;
	my $query = $self->query;
	$abs->query($query) if defined $query;
	my $fragment = $self->fragment;
	$abs->fragment($fragment) if defined $fragment;
	return $abs;
    }

    my $p = $base->path;
    $p =~ s,[^/]+$,,;
    $p .= $path;
    my @p = split('/', $p, -1);
    shift(@p) if @p && !length($p[0]);
    my $i = 1;
    while ($i < @p) {
	#print "$i ", join("/", @p), " ($p[$i])\n";
	if ($p[$i-1] eq ".") {
	    splice(@p, $i-1, 1);
	    $i-- if $i > 1;
	}
	elsif ($p[$i] eq ".." && $p[$i-1] ne "..") {
	    splice(@p, $i-1, 2);
	    if ($i > 1) {
		$i--;
		push(@p, "") if $i == @p;
	    }
	}
	else {
	    $i++;
	}
    }
    $p[-1] = "" if @p && $p[-1] eq ".";  # trailing "/."
    if ($URI::ABS_REMOTE_LEADING_DOTS) {
        shift @p while @p && $p[0] =~ /^\.\.?$/;
    }
    $abs->path("/" . join("/", @p));
    $abs;
}

# The opposite of $url->abs.  Return a URI which is as relative as possible
sub rel {
    my $self = shift;
    my $base = shift || Carp::croak("Missing base argument");
    my $rel = $self->clone;
    $base = URI->new($base) unless ref $base;

    #my($scheme, $auth, $path) = @{$rel}{qw(scheme authority path)};
    my $scheme = $rel->scheme;
    my $auth   = $rel->canonical->authority;
    my $path   = $rel->path;

    if (!defined($scheme) && !defined($auth)) {
	# it is already relative
	return $rel;
    }

    #my($bscheme, $bauth, $bpath) = @{$base}{qw(scheme authority path)};
    my $bscheme = $base->scheme;
    my $bauth   = $base->canonical->authority;
    my $bpath   = $base->path;

    for ($bscheme, $bauth, $auth) {
	$_ = '' unless defined
    }

    unless ($scheme eq $bscheme && $auth eq $bauth) {
	# different location, can't make it relative
	return $rel;
    }

    for ($path, $bpath) {  $_ = "/$_" unless m,^/,; }

    # Make it relative by eliminating scheme and authority
    $rel->scheme(undef);
    $rel->authority(undef);

    # This loop is based on code from Nicolai Langfeldt <janl@ifi.uio.no>.
    # First we calculate common initial path components length ($li).
    my $li = 1;
    while (1) {
	my $i = index($path, '/', $li);
	last if $i < 0 ||
                $i != index($bpath, '/', $li) ||
	        substr($path,$li,$i-$li) ne substr($bpath,$li,$i-$li);
	$li=$i+1;
    }
    # then we nuke it from both paths
    substr($path, 0,$li) = '';
    substr($bpath,0,$li) = '';

    if ($path eq $bpath &&
        defined($rel->fragment) &&
        !defined($rel->query)) {
        $rel->path("");
    }
    else {
        # Add one "../" for each path component left in the base path
        $path = ('../' x $bpath =~ tr|/|/|) . $path;
	$path = "./" if $path eq "";
        $rel->path($path);
    }

    $rel;
}

1;
