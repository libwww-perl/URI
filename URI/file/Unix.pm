package URI::file::Unix;

use strict;

sub extract_authority
{
    undef;
}

sub split_path
{
    my($class, $path) = @_;
    $path =~ s,//+,/,g;
    $path =~ s,(/\.)+/,/,g;
    $path = "./$path" if $path =~ m,^[^:/]+:,,; # look like "scheme:"
    map { s/%/%25/g; s/;/%3B/g; $_; } split("/", $path, -1);
}

sub file
{
    shift;  # class;
    shift;  # authority
    for (@_) {
	return if /\0/;
	return if /\//;  # should we?
    }
    my $path = join("/", @_);
}

*dir = \&file;

1;
