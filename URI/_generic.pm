package URI::_generic;
use strict;
use vars qw(@ISA);

require URI;
@ISA=qw(URI);

use URI::Escape qw(uri_unescape);

sub _parse
{
    my($self, $str) = @_;
    $str =~ m,^
	      (?:([a-zA-Z][a-zA-Z0-9+\-.]*):)?   # optional scheme
	      (?://([^/?\#]*))?                  # optional authority
	      ([^?\#]*)                          # path which can be empty
              (?:\?([^\#]*))?                    # optional query
              (?:\#(.*))?                        # optional fragment
            $,sx or die "This should always match";
    $self->{'scheme'}    = $1  if defined $1;
    $self->{'authority'} = $2  if defined $2;
    $self->{'path'}      = $3; # will always be defined
    $self->{'query'}     = $4  if defined $4;
    $self->{'fragment'}      = $5  if defined $5;
}

sub _as_string
{
    my $self = shift;
    my $str = "";
    my($scheme, $authority, $path, $query, $fragment) =
	@{$self}{qw(scheme authority path query fragment)};
    my $need_abs_path;
    $str = "$scheme:" if $scheme;
    if (defined $authority) {
	$authority =~ s/([^$URI::achar])/$URI::Escape::escapes{$1}/go;
	$str .= "//$authority";
	$need_abs_path++;
    }
    if (defined $path) {
	$path =~ s/([^$URI::ppchar])/$URI::Escape::escapes{$1}/go;
	$path = "/$path" if $need_abs_path && $path !~ m,^/,;
	$str .= "$path";
    }
    if (defined $query) {
	$query =~ s/([^$URI::uric])/$URI::Escape::escapes{$1}/go;
	$str .= "?$query";
    }
    if (defined $fragment) {
	$fragment =~ s/([^$URI::uric])/$URI::Escape::escapes{$1}/go;
	$str .= "#$fragment";
    }
    $str;
}

sub authority { shift->_elem("authority", @_) }
sub path      { shift->_elem("path",      @_) }
sub query     { shift->_elem("query",     @_) }

sub userinfo
{
    my $self = shift;
    my $old = $self->{'authority'};
    if (@_) {
	my $new = $old;
	$new = "" unless defined($new);
	$new =~ s/^[^@]*@//;  # remove old stuff
	my $ui = shift;
	if (defined $ui) {
	    $ui =~ s/@/%40/g;   # protect @
	    $new = "$ui\@$new";
	}
	$self->{'authority'} = $new;
    }
    return undef if !defined($old) || $old !~ /^([^@]*)@/;
    return $1;
}

sub host
{
    my $self = shift;
    my $old = $self->{'authority'};
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
	$self->{'authority'} = $tmp;
    }
    return undef if !defined($old) || $old !~ /^(?:[^@]*@)?([^:]*)/;
    return $1;
}

sub port
{
    my $self = shift;
    my $old = $self->{'authority'};
    if (@_) {
	my $new = $old;
	$new =~ s/:.*$//;
	my $port = shift;
	$new .= ":$port" if defined $port;
	$self->{'authority'} = $new;
    }
    return undef unless defined $old;
    return $1 if $old =~ /:(\d+)$/;
    $self->default_port;
}

sub default_port { undef }

sub abs_path
{
    my $self = shift;
    my($authority, $path, $query) = @{$self}{qw(authority path query)};
    if (defined $authority) {
	if (defined $path) {
	    $path = "/$path" unless $path =~ m,^/,;
	} else {
	    $path = "/";
	}
    } else {
	return undef unless defined($path) && $path =~ m,^/,;
    }
    $path =~ s/([^$URI::ppchar])/$URI::Escape::escapes{$1}/go;
    $path = "/$path" if defined($authority) && $path !~ m,^/,;
    if (defined $query) {
	$query =~ s/([^$URI::uric])/$URI::Escape::escapes{$1}/go;
	$path .= "?$query";
    }
    $path;
}

sub path_segments
{
    my $self = shift;
    my $path = $self->{'path'};
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
	$self->{'path'} = join("/", @arg);
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
}

# The oposite of $url->abs.  Return a URI which is much relative as possible
sub rel {
    my($self, $base) = @_;
    my $rel = $self->clone;
    $base = $self->base unless $base;
    return $rel unless $base;
    $base = URI->new($base) unless ref $base;
    $rel->base($base);

    my($scheme, $auth, $path) = @{$rel}{qw(scheme authority path)};
    if (!defined($scheme) && !defined($auth)) {
	# it is already relative
	return $rel;
    }

    my($bscheme, $bauth, $bpath) = @{$base}{qw(scheme authority path)};
    for ($bscheme, $bauth, $auth) {
	$_ = '' unless defined
    }

    unless ($scheme eq $bscheme && $auth eq $bauth) {
	# different location, can't make it relative
	return $rel;
    }

    for ($path, $bpath) {  $_ = "/$_" unless m,^/,; }

    # Make it relative by eliminating scheme and authority
    $rel->{'scheme'} = undef;
    $rel->{'authority'} = undef;

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
        defined($rel->{'fragment'}) &&
        !defined($rel->{'query'})) {
        $rel->{'path'} = '';
    } else {
        # Add one "../" for each path component left in the base path
        $path = ('../' x $bpath =~ tr|/|/|) . $path;
	$path = "./" if $path eq "";
        $rel->{'path'} = $path;
    }
    $rel->{'_str'} = '';

    $rel;
}

1;
