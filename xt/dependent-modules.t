use strict;
use warnings;

use Test::Needs qw( Test::DependentModules );
use Test::DependentModules qw( test_modules );
use Test::More;

my @modules = ('HTTP::Message');

SKIP: {
    skip '$ENV{TEST_DEPENDENTS} not set', scalar @modules
        unless $ENV{TEST_DEPENDENTS};
    test_modules(@modules);
}

done_testing();
