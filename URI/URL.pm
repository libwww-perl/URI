package URI::URL;

require URI::WithBase;
@ISA=qw(URI::WithBase);

use strict;
use vars qw(@EXPORT $VERSION);

$VERSION = "5.00_01";

# Provide as much as possible of the old URI::URL interface for backwards
# compatibility...

require Exporter;
*import = \&Exporter::import;
@EXPORT = qw(url);

# Easy to use constructor
sub url ($;$) { URI::URL->new(@_); }

use URI::Escape qw(uri_unescape);

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->[0] = $self->[0]->canonical;
    $self;
}

sub newlocal
{
    die "NYI";
}

sub strict
{
    my $old = $URI::STRICT;
    $URI::STRICT = shift if @_;
    $old;
}

sub print_on
{
    my $self = shift;
    require Data::Dumper;
    print STDERR Data::Dumper::Dumper($self);
}

sub _try
{
    my $self = shift;
    my $method = shift;
    scalar(eval { $self->$method(@_) });
}

sub crack
{
    # should be overridden by subclasses
    my $self = shift;
    (scalar($self->scheme),
     $self->_try("user"),
     $self->_try("password"),
     $self->_try("host"),
     $self->_try("port"),
     $self->_try("path"),
     $self->_try("params"),
     $self->_try("query"),
     scalar($self->fragment),
    )
}

sub full_path
{
    my $self = shift;
    my $path = $self->path_query;
    $path = "/" unless length $path;
    $path;
}

sub netloc
{
    shift->authority(@_);
}

sub epath
{
    my $path = shift->SUPER::path(@_);
    $path =~ s/;.*//;
    $path;
}

sub equery
{
    shift->SUPER::query(@_);
}

sub eparams
{
    my $self = shift;
    my @p = $self->path_segments;
    return unless ref($p[-1]);
    @p = @{$p[-1]};
    shift @p;
    join(";", @p);
}

sub params { shift->eparams(@_); }

sub path {
    my $self = shift;
    my $old = $self->epath(@_);
    return unless defined wantarray;
    return '/' if !defined($old) || !length($old);
    Carp::croak("Path components contain '/' (you must call epath)")
	if $old =~ /%2[fF]/ and !@_;
    $old = "/$old" if $old !~ m|^/| && defined $self->netloc;
    return uri_unescape($old);
}

sub path_components {
    shift->path_segments(@_);
}

sub query {
    my $self = shift;
    my $old = $self->equery(@_);
    if (defined(wantarray) && defined($old)) {
	if ($old =~ /%(?:26|2[bB]|3[dD])/) {  # contains escaped '=' '&' or '+'
	    my $mess;
	    for ($old) {
		$mess = "Query contains both '+' and '%2B'"
		  if /\+/ && /%2[bB]/;
		$mess = "Form query contains escaped '=' or '&'"
		  if /=/  && /%(?:3[dD]|26)/;
	    }
	    if ($mess) {
		Carp::croak("$mess (you must call equery)");
	    }
	}
	# Now it should be safe to unescape the string without loosing
	# information
	return uri_unescape($old);
    }
    undef;

}

sub frag { shift->fragment(@_); }
sub keywords { shift->query_keywords(@_); }

# mailto:
sub address { shift->to(@_); }
sub encoded822addr { shift->to(@_); }

# news:
sub groupart { shift->_group(@_); }
sub article  { shift->message(@_); }

1;
