package URI::file::Mac;

require URI::file::Base;
@ISA=qw(URI::file::Base);

use strict;
use URI::Escape qw(uri_unescape);

sub extract_authority
{
    my $class = shift;
    # move volume part to authority
    return $1 if $_[0] =~ s/^([^:]+:):*//;
    return;
}


sub extract_path
{
    my $class = shift;
    my $path = shift;

    my @pre;
    if ($path =~ s/^(:+)//) {
	if (length($1) == 1) {
	    @pre = (".") unless length($path);
	} else {
	    @pre = ("..") x (length($1) - 1);
	}
    }

    $path =~ s,([%/;]),$URI::Escape::escapes{$1},g;

    my @path = split(/:/, $path, -1);
    for (@path) {
	if ($_ eq "." || $_ eq "..") {
	    $_ = "%2E" x length($_);
	}
    }
    (join("/", @pre, @path), 1);
}


sub file
{
    my $class = shift;
    my $uri = shift;
    my @path;

    my $auth = $uri->authority;
    if (defined $auth) {
	if (lc($auth) ne "localhost") {
	    my $u_auth = uri_unescape($auth);
	    if ($u_auth =~ s/:$//) {
		# volume
		$u_auth =~ s/%/%25/g; # blææh (we will uri_unescape below)
		@path = ("", $u_auth);
	    } elsif (!$class->is_this_host($u_auth)) {
		# some other host (use it as volume name)
		@path = ("", $auth);
		# XXX or just return to make it illegal;
	    }
	}
    }
    my @ps = split("/", $uri->path, -1);
    shift @ps if @path;
    push(@path, @ps);

    my $pre = "";
    if (!@path) {
	return;  # empty path; XXX return ":" instead?
    } elsif ($path[0] eq "") {
	# absolute
	shift(@path);
	if (@path == 1) {
	    return if $path[0] eq "";  # not root directory
	    push(@path, "");           # volume only, effectively append ":"
	}
    } else {
	$pre = ":";
	while (@path) {
	    next if $path[0] eq ".";
	    last if $path[0] ne "..";
	    $pre .= ":";
	} continue {
	    shift(@path);
	}
    }
    return unless $pre || @path;
    for (@path) {
	s/;.*//;  # get rid of parameters
	#return unless length; # XXX
	$_ = uri_unescape($_);
	return if /\0/;
	return if /:/;  # Should we?
    }
    $pre . join(":", @path);
}

sub dir
{
    my $class = shift;
    my $path = $class->file(@_);
    return unless defined $path;
    $path .= ":" unless $path =~ /:$/;
    $path;
}

1;
