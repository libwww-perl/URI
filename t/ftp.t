use strict;
use warnings;

use Test::More tests => 13;

use URI ();
my $uri;

$uri = URI->new("ftp://ftp.example.com/path");

is($uri->scheme, "ftp");

is($uri->host, "ftp.example.com");

is($uri->port, 21);

is($uri->user, "anonymous");

is($uri->password, 'anonymous@');

$uri->userinfo("gisle\@aas.no");

is($uri, "ftp://gisle%40aas.no\@ftp.example.com/path");

is($uri->user, "gisle\@aas.no");

is($uri->password, undef);

$uri->password("secret");

is($uri, "ftp://gisle%40aas.no:secret\@ftp.example.com/path");

$uri = URI->new("ftp://gisle\@aas.no:secret\@ftp.example.com/path");
is($uri, "ftp://gisle\@aas.no:secret\@ftp.example.com/path");

is($uri->userinfo, "gisle\@aas.no:secret");

is($uri->user, "gisle\@aas.no");

is($uri->password, "secret");
