use strict;
use warnings;

print "1..1\n";

use URI;

my $uri = URI->new("rsync://foo:bar\@example.com");
$uri->password(undef);

print "not " if $uri->as_string =~ /foo:\@example.com/;
print "ok 1\n";
