package URI::_generic;
require URI;
@ISA=qw(URI);

use strict;
use vars qw(@ISA);
use URI::Escape qw(uri_unescape);

sub authority
{
    my $self = shift;
    $$self =~ m,^((?:$URI::scheme_re:)?)(?://([^/?\#]*))?(.*)$,os or die;

    if (@_) {
	my $auth = shift;
	$$self = $1;
	if (defined $auth) {
	    $auth =~ s/([^$URI::achar])/$URI::Escape::escapes{$1}/go;
	    $$self .= "//$auth";
	}
	my $rest = $3;
	$$self .= "/" if length($rest) && $rest !~ m,^[/?\#],;
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
	$new_path =~ s/([^$URI::ppchar])/$URI::Escape::escapes{$1}/go;
	$$self .= "/" if length($$self) &&
                         length($new_path) && $new_path !~ m,^/,;
	$$self .= $new_path . $rest;
    }
    $2;
}

sub query
{
    my $self = shift;
    $$self =~ m,^([^?\#]*)(?:\?([^\#]*))?(.*)$,s or die;
    
    if (@_) {
	my $q = shift;
	$$self = $1;
	if (defined $q) {
	    $q =~ s/([^$URI::uric])/$URI::Escape::escapes{$1}/go;
	    $$self .= "?$q";
	}
	$$self .= $3;
    }
    $2;
}

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
    return undef unless defined $old;
    return $1 if $old =~ /:(\d+)$/;
    $self->default_port;
}

sub default_port { undef }

sub abs_path
{
    my $self = shift;
    my $tmp = $self->abs_path_query;
    $tmp =~ s/\?.*//s;
    $tmp;
}

sub abs_path_query
{
    my $self = shift;
    $$self =~  m,^[^/?\#]*(?://([^/?\#]*))?([^\#]*),s or die;
    my $tmp = $1;
    $tmp = "/$tmp" unless $tmp =~ m,^/,;
    $tmp;
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
		$seg[0] =~ s/([^$URI::pchar])/$URI::Escape::escapes{$1}/go;
		$_ = join(";", @seg);
	    } else {
		s/([^$URI::pchar])/$URI::Escape::escapes{$1}/go;
	    }
	}
	$self->path(join("/", @arg));
    }
    return $path unless wantarray;
    $path = "/$path" if defined $self->{'authority'} && $path !~ m,^/,;
    map {/;/ ? _split_segment($_) : uri_unescape($_) } split('/', $path, -1);
}


sub _split_segment
{
    my @segment = split(';', shift, -1);
    $segment[0] = uri_unescape($segment[0]);
    \@segment;
}


sub abs
{
    my $self = shift;
    my $abs = $self->clone;
    my $base = shift || return $abs;
    my $allow_scheme = shift;

    $base = URI->new($base) unless ref $base;

    #my($scheme, $authority, $path, $query, $fragment) =
    #   @{$self}{qw(scheme authority path query fragment)};
    my $scheme    = $self->scheme;
    my $authority = $self->authority;
    my $path      = $self->path;
    my $query     = $self->query;
    my $fragment  = $self->fragment;

    if ($scheme) {
	return $abs unless $allow_scheme;
	return $abs if lc($scheme) ne lc($base->scheme);
    }
    $abs->scheme($base->scheme);
    return $abs if defined $authority;
    $abs->authority($base->authority);
    return $abs if $path =~ m,^/,;

    if (!length($path) && !defined($query)) {
	# we are empty, reference to base (all modifications to $abs wasted)
	$abs = $base->clone;
	$abs->fragment($fragment);
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
	} elsif ($p[$i] eq ".." && $p[$i-1] ne "..") {
	    splice(@p, $i-1, 2);
	    if ($i > 1) {
		$i--;
		push(@p, "") if $i == @p;
	    }
	} else {
	    $i++;
	}
    }
    $p[-1] = "" if @p && $p[-1] eq ".";  # trailing "/."
    $abs->path("/" . join("/", @p));
    $abs;
}

# The oposite of $url->abs.  Return a URI which is much relative as possible
sub rel {
    my $self = shift;
    my $base = shift;
    my $rel = $self->clone;
    return $rel unless $base;
    $base = URI->new($base) unless ref $base;

    #my($scheme, $auth, $path) = @{$rel}{qw(scheme authority path)};
    my $scheme = $rel->scheme;
    my $auth   = $rel->authority;
    my $path   = $rel->path;

    if (!defined($scheme) && !defined($auth)) {
	# it is already relative
	return $rel;
    }

    #my($bscheme, $bauth, $bpath) = @{$base}{qw(scheme authority path)};
    my $bscheme = $base->scheme;
    my $bauth   = $base->authority;
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
    } else {
        # Add one "../" for each path component left in the base path
        $path = ('../' x $bpath =~ tr|/|/|) . $path;
	$path = "./" if $path eq "";
        $rel->path($path);
    }

    $rel;
}


sub canonical_notyet
{
    my $self = shift;
    my $other = $self->clone;
}

1;
