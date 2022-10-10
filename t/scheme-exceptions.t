use strict;
use warnings;

use Test::More;
use URI ();

plan skip_all => 'this test assumes that URI::notreal does not exist'
    if eval { +require URI::notreal };

for (0..1) {
    my $uri = URI->new('notreal://foo/bar');

    is($@, '', 'no exception when trying to load a scheme handler class');
    ok($uri->isa('URI'), 'but URI still instantiated as foreign');
}

done_testing;
