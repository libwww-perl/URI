use strict;
use warnings;

use Test::More;

BEGIN {
  $ENV{URI_HAS_RESERVED_SQUARE_BRACKETS} = 0;
}

use URI ();

sub show {
  diag explain("self: ", shift);
}


#-- test bugfix of https://github.com/libwww-perl/URI/issues/99


is( URI::HAS_RESERVED_SQUARE_BRACKETS, 0, "constant indicates NOT to treat square brackets as reserved characters" );

{
  my $u = URI->new("http://[::1]/path_with_square_[brackets]?par=value[1]");
  is( $u->canonical,
      "http://[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D",
      "sqb in path and request"
    ) or show $u;
}


{
  my $u = URI->new("http://[::1]/path_with_square_[brackets]?par=value[1]#fragment[2]");
  is( $u->canonical,
      "http://[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D#fragment%5B2%5D",
      "sqb in path and request and fragment"
    ) or show $u;
}


{
  my $u = URI->new("http://root[user]@[::1]/path_with_square_[brackets]?par=value[1]#fragment[2]");
  is( $u->canonical,
      "http://root%5Buser%5D@[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D#fragment%5B2%5D",
      "sqb in userinfo, host, path, request and fragment"
    ) or show $u;
}

done_testing;

#TODO: more tests, esp. setter methods
