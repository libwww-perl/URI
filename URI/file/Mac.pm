package URI::file::Mac;

sub extract_host
{
    undef;
}

sub split_path
{
    my($class, $path) = @_;
    $path = ":$path" unless $path =~ s/^://;
    split(/:/, $path);
}

1;
