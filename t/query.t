use strict;
use warnings;

use Test::More tests => 23;

use URI ();
my $u = URI->new("", "http");
my @q;

$u->query_form(a => 3, b => 4);
is $u, "?a=3&b=4";

$u->query_form(a => undef);
is $u, "?a=";

$u->query_form("a[=&+#] " => " [=&+#]");
is $u, "?a%5B%3D%26%2B%23%5D+=+%5B%3D%26%2B%23%5D";

@q = $u->query_form;
is join(":", @q), "a[=&+#] : [=&+#]";

@q = $u->query_keywords;
ok !@q;

$u->query_keywords("a", "b");
is $u, "?a+b";

$u->query_keywords(" ", "+", "=", "[", "]");
is $u, "?%20+%2B+%3D+%5B+%5D";

@q = $u->query_keywords;
is join(":", @q), " :+:=:[:]";

@q = $u->query_form;
ok !@q;

$u->query(" +?=#");
is $u, "?%20+?=%23";

$u->query_keywords([qw(a b)]);
is $u, "?a+b";

$u->query_keywords([]);
is $u, "";

$u->query_form({ a => 1, b => 2 });
ok $u eq "?a=1&b=2" || $u eq "?b=2&a=1";

$u->query_form([ a => 1, b => 2 ]);
is $u, "?a=1&b=2";

$u->query_form({});
is $u, "";

$u->query_form([a => [1..4]]);
is $u, "?a=1&a=2&a=3&a=4";

$u->query_form([]);
is $u, "";

$u->query_form(a => { foo => 1 });
ok "$u" =~ /^\?a=HASH\(/;

$u->query_form(a => 1, b => 2, ';');
is $u, "?a=1;b=2";

$u->query_form(a => 1, c => 2);
is $u, "?a=1;c=2";

$u->query_form(a => 1, c => 2, '&');
is $u, "?a=1&c=2";

$u->query_form([a => 1, b => 2], ';');
is $u, "?a=1;b=2";

$u->query_form([]);
{
    local $URI::DEFAULT_QUERY_FORM_DELIMITER = ';';
    $u->query_form(a => 1, b => 2);
}
is $u, "?a=1;b=2";
