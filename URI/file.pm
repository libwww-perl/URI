package URI::file;

use strict;
use vars qw(@ISA);

require URI::_generic;
@ISA = qw(URI::_generic);
set_type($^O);

sub set_type
{
    my($OS) = @_;
    pop(@ISA) if @ISA > 1;

    my $class = {
		 os2     => "OS2",
		 MacOS   => "Mac",
		 MSWin32 => "Win32",
		 Win32   => "Win32"
		}->{$OS} || "Unix";
    $class = "URI::file::$class";

    eval "require $class";
    warn $@ if $@;
    die $@ if $@;
    push(@ISA, $class);
}

sub path { shift->path_query(@_) }
sub host { shift->authority(@_)  }

sub new
{
    my($class, $path) = @_;
    my $uri = URI->new("", "file");
    if (my $host = $class->extract_host($path)) {
	$uri->authority($host);
    }
    $uri->path_segments($class->split_path($path));
    $$uri = "file:$$uri" if $$uri =~ m,^/,;  # fixup
    $uri;
}

sub new_abs
{
    my $class = shift;
    $class->new(@_)->abs($class->curdir);
}

sub curdir
{
    my $class = shift;
    require Cwd;
    $class->new(Cwd::fastcwd());
}

1;
