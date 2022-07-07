use strict;
use warnings;

use Test::More;
use File::Basename ();
use Digest::MD5    ();

use URI ();

# Check if we really test the distribution's ./lib/URI.pm and not another installed version.
# Note: Breaks if the module source (lib) is modified during the build process (blib).

open my $wanted_fh, '<', File::Basename::dirname( $0 ) . '/../lib/URI.pm'  or  die $!;
open my $used_fh,   '<', $INC{'URI.pm'}                                    or  die $!;

my $md5_wanted = Digest::MD5->new()->addfile( $wanted_fh )->hexdigest;
my $md5_used   = Digest::MD5->new()->addfile( $used_fh   )->hexdigest;

ok( "$md5_used" eq "$md5_wanted", "Expected version of URI used." )
  ? note     "Current version of URI: $URI::VERSION"
  : BAIL_OUT "Test is run against the wrong version $URI::VERSION of module URI ($INC{'URI.pm'})! Please check your environment.";

done_testing;
