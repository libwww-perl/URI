package URI::file::Mac;

sub extract_host
{
    my $class = shift;
    return $1 if $_[0] =~ s,^\\\\([^\\]+),,;
    return;
}

sub split_path
{
    my($class, $path) = @_;
    $path = "/$path" if $path =~ m/^[a-zA-Z]:/;
    $path =~ s,[/\\][/\\]+,/,g;
    $path =~ s,([/\\]\.)+[/\\],/,g;
    split(/[\\\/]/, $path, -1);
}

1;
