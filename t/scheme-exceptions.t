use strict;
use warnings;

use Test::More;
use URI ();

require URI::_foreign;    # load this before disabling @INC
my $count = 0;
local @INC = (sub { ++$count; return });
for (0 .. 1) {
    my $uri = URI->new('notreal://foo/bar');
    is($count, 1,  'only attempt to load the scheme package once');
    is($@,     '', 'no exception when trying to load a scheme handler class');
    ok($uri->isa('URI'), 'but URI still instantiated as foreign');
    diag $count;
}

done_testing;
