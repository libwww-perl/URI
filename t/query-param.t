use strict;
use warnings;

use Test::More tests => 19;

use URI;
use URI::QueryParam;

my $u = URI->new("http://www.sol.no?foo=4&bar=5&foo=5");

is_deeply(
    $u->query_form_hash,
    { foo => [ 4, 5 ], bar => 5 },
    'query_form_hash get'
);

$u->query_form_hash({ a => 1, b => 2});
ok $u->query eq "a=1&b=2" || $u->query eq "b=2&a=1", 'query_form_hash set';

$u->query("a=1&b=2&a=3&b=4&a=5");
is join(':', $u->query_param), "a:b", 'query_param list keys';

is $u->query_param("a"), "1", "query_param scalar return";
is join(":", $u->query_param("a")), "1:3:5", "query_param list return";

is $u->query_param(a => 11 .. 15), 1, "query_param set return";

is $u->query, "a=11&b=2&a=12&b=4&a=13&a=14&a=15", "param order";

is join(":", $u->query_param(a => 11)), "11:12:13:14:15", "old values returned";

is $u->query, "a=11&b=2&b=4";

is $u->query_param_delete("a"), "11", 'query_param_delete';

is $u->query, "b=2&b=4";

$u->query_param_append(a => 1, 3, 5);
$u->query_param_append(b => 6);

is $u->query, "b=2&b=4&a=1&a=3&a=5&b=6";

$u->query_param(a => []);  # same as $u->query_param_delete("a");

is $u->query, "b=2&b=4&b=6", 'delete by assigning empty list';

$u->query(undef);
$u->query_param(a => 1, 2, 3);
$u->query_param(b => 1);

is $u->query, 'a=1&a=2&a=3&b=1', 'query_param from scratch';

$u->query_param_delete('a');
$u->query_param_delete('b');

ok ! $u->query;

is $u->as_string, 'http://www.sol.no';

$u->query(undef);
$u->query_param(a => 1, 2, 3);
$u->query_param(b => 1);

is $u->query, 'a=1&a=2&a=3&b=1';

$u->query_param('a' => []);
$u->query_param('b' => []);

ok ! $u->query;

is $u->as_string, 'http://www.sol.no';
