package URI::Split;

use strict;

use vars qw(@ISA @EXPORT_OK);
require Exporter;

@ISA = qw(Exporter);

@EXPORT_OK = qw(uri_split uri_join);

sub uri_split {
     return $_[0] =~ m,(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?,;
}

sub uri_join {
    my($scheme, $auth, $path, $query, $frag) = @_;
    my $uri = defined($scheme) ? "$scheme:" : "";
    if (defined $auth) {
	$uri .= "//$auth";
	$path = "/$path" unless $path =~ m,^/,;
    }
    $uri .= $path;
    $uri .= "?$query" if defined $query;
    $uri .= "#$frag" if defined $frag;
    $uri;
}

1;
