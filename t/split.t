use strict;
use warnings;

use Test::More tests => 17;

use URI::Split qw( uri_join uri_split );

sub j { join("-", map { defined($_) ? $_ : "<undef>" } @_) }

is j(uri_split("p")), "<undef>-<undef>-p-<undef>-<undef>";

is j(uri_split("p?q")), "<undef>-<undef>-p-q-<undef>";

is j(uri_split("p#f")), "<undef>-<undef>-p-<undef>-f";

is j(uri_split("p?q/#f/?")), "<undef>-<undef>-p-q/-f/?";

is j(uri_split("s://a/p?q#f")), "s-a-/p-q-f";

is uri_join("s", "a", "/p", "q", "f"), "s://a/p?q#f";

is uri_join("s", "a", "p", "q", "f"), "s://a/p?q#f";

is uri_join(undef, undef, "", undef, undef), "";

is uri_join(undef, undef, "p", undef, undef), "p";

is uri_join("s", undef, "p"), "s:p";

is uri_join("s"), "s:";

is uri_join(), "";

is uri_join("s", "a"), "s://a";

is uri_join("s", "a/b"), "s://a%2Fb";

is uri_join("s", ":/?#", ":/?#", ":/?#", ":/?#"), "s://:%2F%3F%23/:/%3F%23?:/?%23#:/?#";

is uri_join(undef, undef, "a:b"), "a%3Ab";

is uri_join("s", undef, "//foo//bar"), "s:////foo//bar";
