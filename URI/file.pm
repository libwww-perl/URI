package URI::file;

use strict;
use vars qw(@ISA);

require URI::_generic;
@ISA = qw(URI::_generic);

my %os_class = (
     os2     => "OS2",
     mac     => "Mac",
     MacOS   => "Mac",
     MSWin32 => "Win32",
     win32   => "Win32",
     msdos   => "Win32",
     dos     => "Win32",
);

sub os_class
{
    my($OS) = shift || $^O;

    my $class = "URI::file::" . ($os_class{$OS} || "Unix");
    no strict 'refs';
    unless (defined %{"$class\::"}) {
	eval "require $class";
	die $@ if $@;
    }
    $class;
}

sub path { shift->path_query(@_) }
sub host { shift->authority(@_)  }

sub new
{
    my($class, $path, $os) = @_;
    $path = "" unless defined $path;
    $os = os_class($os);
    my $uri = URI->new("", "file");
    if (my $host = $os->extract_authority($path)) {
	$uri->authority($host);
    }
    $uri->path(join("/", map { s,/,%2F,g; $_ } $os->split_path($path)));
    $$uri = "file:$$uri" if $$uri =~ m,^/,;  # fixup
    $uri;
}

sub new_abs
{
    my $class = shift;
    my $file = $class->new(shift);
    return $file->abs($class->cwd) unless $$file =~ /^file:/;
    $file;
}

sub cwd
{
    my $class = shift;
    require Cwd;
    my $cwd = $class->new(Cwd::fastcwd());
    $cwd .= "/" unless substr($cwd, -1, 1) eq "/";
    $cwd;
}

sub file
{
    my($self, $os) = @_;
    os_class($os)->file($self->authority, $self->path_segments);
}

sub dir
{
    my($self, $os) = @_;
    os_class($os)->dir($self->authority, $self->path_segments);
}

1;
