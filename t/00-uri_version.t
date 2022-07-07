use strict;
use warnings;

use Test::More;

use URI ();

my $expected_version = '5.12';  #MAINT: Update for each new version.

is( $URI::VERSION, $expected_version, "Expecting URI version $expected_version")
  or BAIL_OUT("Test is run against the wrong version $URI::VERSION of URI.pm ($INC{'URI.pm'})! Please check your environment.");

done_testing;
