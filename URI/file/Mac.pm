package URI::file::Mac;

sub extract_host
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
    } else {
	@pre = ("");
    }
    (@pre, split(/:/, $path, -1));
}

1;
