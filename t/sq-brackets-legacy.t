use strict;
use warnings;

use Test::More;

BEGIN {
  $ENV{URI_HAS_RESERVED_SQUARE_BRACKETS} = 1;
}

use URI ();

sub show {
  diag explain("self: ", shift);
}


#-- test bugfix of https://github.com/libwww-perl/URI/issues/99


no warnings; #-- don't complain about the fragment # being a potential comment
my @legacy_tests = qw(
                     ftp://[::1]/
                     http://example.com/path_with_square_[brackets]
                     http://[::1]/and_[%5Bmixed%5D]_stuff_in_path
                     https://[::1]/path_with_square_[brackets]_and_query?par=value[1]&par=value[2]
                     http://[::1]/path_with_square_[brackets]_and_query?par=value[1]#and_fragment[2]
                     https://root[user]@[::1]/welcome.html
                    );
use warnings;

is( URI::HAS_RESERVED_SQUARE_BRACKETS, 1, "constant indicates to treat square brackets as reserved characters (legacy)" );

foreach my $same ( @legacy_tests  ) {
  my $u = URI->new(  $same );
  is( $u->canonical,
      $same,
      "legacy: reserved square brackets not escaped"
    ) or show $u;
}

done_testing;
