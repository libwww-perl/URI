package URI::file::Mac;

use strict;

sub extract_authority
{
    undef;
}

sub split_path
{
    my($class, $path) = @_;
    my @pre;
    if ($path =~ s/^(:+)//) {
	if (length($1) == 1) {
	    @pre = (".") unless length($path);
	} else {
	    @pre = ("..") x (length($1) - 1);
	}
	return(@pre, "") unless length($path);
	# XXX if $path now contains a sequence of "." and ".." we are
	# now in trouble...
    } else {
	@pre = ("");
    }
    (@pre, split(/:/, $path, -1));
}

sub file
{
    shift;  # class
    shift;  # authority;
    for (@_) {
	return if /\0/;
	return if /:/;  # Should we?
    }
    my $pre = "";
    if ($_[0] eq "") {
	# absolute
	shift;
    } else {
	$pre = ":";
	while (@_) {
	    next if $_[0] eq ".";
	    last if $_[0] ne "..";
	    $pre .= ":";
	} continue {
	    shift(@_);
	}
    }
    $pre . join(":", @_);
}

sub dir
{
    my $class = shift;
    my $path = $class->file(@_);
    $path .= ":" unless $path =~ /:$/;
    $path;
}

1;
