package URI::file::Mac;

sub extract_host
{
    undef;
}

sub split_path
{
    my($class, $path) = @_;
    split(/:/, $path);
}

1;
