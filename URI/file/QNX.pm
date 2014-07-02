package URI::file::QNX;

use strict;
use warnings;

require URI::file::Unix;
our @ISA=qw(URI::file::Unix);

sub _file_extract_path
{
    my($class, $path) = @_;
    # tidy path
    $path =~ s,(.)//+,$1/,g; # ^// is correct
    $path =~ s,(/\.)+/,/,g;
    $path = "./$path" if $path =~ m,^[^:/]+:,,; # look like "scheme:"
    $path;
}

1;
