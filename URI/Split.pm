package URI::Split;

use strict;

use vars qw(@ISA @EXPORT_OK);
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(uri_split uri_join);

use URI::Escape ();

sub uri_split {
     return $_[0] =~ m,(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?,;
}

sub uri_join {
    my($scheme, $auth, $path, $query, $frag) = @_;
    my $uri = defined($scheme) ? "$scheme:" : "";
    $path = "" unless defined $path;
    if (defined $auth) {
	$auth =~ s,([/?\#]),$URI::Escape::escapes{$1},g;
	$uri .= "//$auth";
	$path = "/$path" if length($path) && $path !~ m,^/,;
    }
    elsif ($path =~ m,^//,) {
	$uri .= "//";  # XXX force empty auth
    }
    unless (length $uri) {
	$path =~ s,(:),$URI::Escape::escapes{$1}, while $path =~ m,^[^:/?\#]+:,;
    }
    $path =~ s,([?\#]),$URI::Escape::escapes{$1},g;
    $uri .= $path;
    if (defined $query) {
	$query =~ s,(\#),$URI::Escape::escapes{$1},g;
	$uri .= "?$query";
    }
    $uri .= "#$frag" if defined $frag;
    $uri;
}

1;
