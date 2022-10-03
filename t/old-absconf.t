use strict;
use warnings;

use Test::More tests => 6;

use URI::URL qw( url );

# Test configuration via some global variables.

$URI::URL::ABS_REMOTE_LEADING_DOTS = 1;
$URI::URL::ABS_ALLOW_RELATIVE_SCHEME = 1;

my $u1 = url("../../../../abc", "http://web/a/b");

is($u1->abs->as_string, "http://web/abc");

{
    local $URI::URL::ABS_REMOTE_LEADING_DOTS;
    is($u1->abs->as_string, "http://web/../../../abc");
}


$u1 = url("http:../../../../abc", "http://web/a/b");
is($u1->abs->as_string, "http://web/abc");

{
   local $URI::URL::ABS_ALLOW_RELATIVE_SCHEME;
   is($u1->abs->as_string, "http:../../../../abc");
   is($u1->abs(undef,1)->as_string, "http://web/abc");
}

is($u1->abs(undef,0)->as_string, "http:../../../../abc");
