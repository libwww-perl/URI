use strict;
use warnings;

use Test::More;
use File::Basename ();

use URI ();

# Check if we really test the distribution's ./lib/URI.pm and not another installed version.

my $inode_wanted = (stat( File::Basename::dirname( $0 ) . '/../lib/URI.pm' ))[1];
my $inode_used   = (stat( $INC{'URI.pm'} ))[1];

is( "$inode_wanted", "$inode_used", "Expected version of URI used." )
  ? note     "Current version of URI: $URI::VERSION"
  : BAIL_OUT "Test is run against the wrong version $URI::VERSION of module URI ($INC{'URI.pm'})! Please check your environment.";

done_testing;
