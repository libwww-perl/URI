package URI::URL;

require URI::WithBase;
@ISA=qw(URI::WithBase);

use strict;
use vars qw(@EXPORT $VERSION);

$VERSION = "5.00_00";

# Provide as much as possible of the old URI::URL interface for backwards
# compatibility...

require Exporter;
*import = \&Exporter::import;
@EXPORT = qw(url);

# Easy to use constructor
sub url ($;$) { URI::URL->new(@_); }

sub newlocal
{
    die "NYI";
}

sub print_on
{
    my $self = shift;
    require Data::Dumper;
    print STDERR Data::Dumper::Dumper($self);
}

sub crack
{
    # should be overridden by subclasses
    my $self = shift;
    ($self->scheme,  # 0: scheme
     undef,          # 1: user
     undef,          # 2: passwd
     undef,          # 3: host
     undef,          # 4: port
     undef,          # 5: path
     undef,          # 6: params
     undef,          # 7: query
     undef           # 8: fragment
    )
}

sub full_path
{
    my $self = shift;
    my $path = $self->query_path;
    $path = "/" unless length $path;
    $path;
}

sub netloc
{
    shift->authority(@_);
}

sub user;
sub password;

sub epath  { shift->SUPER::path(@_); }
sub equery { shift->SUPER::query(@_); }
sub eparams;

sub path;
sub query;
sub params;

sub frag { shift->fragment(@_); }
sub keywords { shift->query_keywords(@_); }

# mailto:
sub address { shift->to(@_); }

1;
