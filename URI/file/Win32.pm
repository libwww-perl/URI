package URI::file::Win32;

sub extract_authority
{
    my $class = shift;
    return $1 if $_[0] =~ s,^\\\\([^\\]+),,;  # UNC

    if ($_[0] =~ s,^([a-zA-Z]:),,) {
	my $auth = $1;
	$auth .= "." if $_[0] !~ m,^[\\/],;   # XXX relative
	return $auth;
    }
    return $1 if $_[0] =~ s,^([a-zA-Z]:),,;
    return;
}

sub split_path
{
    my($class, $path) = @_;
    $path =~ s,[/\\][/\\]+,/,g;       # \\    --> \
    $path =~ s,([/\\]\.)+[/\\],/,g;   # \.\.\ --> \
    split(/[\\\/]/, $path, -1);
}

sub file
{
    shift; # class;
    my $auth = shift;
    my $rel;
    if ($auth) {
	if ($auth =~ /^([a-zA-Z]:)(.?)/) {
	    $auth = uc($1);
	    $rel++ if $2;
	} elsif ($auth eq "localhost") {
	    $auth = "";
	} else {
	    $auth = "\\\\" . $auth;  # UNC
	}
    } else {
	$auth = "";
    }
    for (@_) {
	return if /\0/;
	return if /\//;
	#return if /\\/;        # URLs with "\" is not uncommon
    }
    my $path = join("\\", @_);
    $path =~ s/^\\// if $rel;
    $path = $auth . $path;
    $path =~ s,\\([a-zA-Z])[:|],\u$1:,;
    $path;
}

*dir = \&file;

1;
