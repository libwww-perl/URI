package URI::file::Unix;

sub extract_host
{
    undef;
}

sub split_path
{
    my($class, $path) = @_;
    $path =~ s,//+,/,g;
    $path =~ s,(/\.)+/,/,g;
    $path = "./$path" if $path =~ m,^[^:/]+:,,; # look like "scheme:"
    split("/", $path, -1);
}

#-------------------------

sub local_file
{
    my $self = shift;
    my @path = $self->path_segments;
    File::Spec->catfile(@path);
}

sub local_dir
{
    my $self = shift;
    my @path = $self->path_segments;
    File::Spec->catdir(@path);
}

sub local_path
{
    my $self = shift;
    my @path = $self->path_segments;
    if ($path[-1] eq "") {
	pop(@path);
	File::Spec->catdir(@path);
    } else {
	File::Spec->catfile(@path);
    }
}

1;
