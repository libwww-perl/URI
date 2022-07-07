use strict;
use warnings;

use Test::More;

use URI ();

my $u = URI->new('mailto:gisle@aas.no');
is $u->to, 'gisle@aas.no', 'parsing normal URI sets to()';
is $u, 'mailto:gisle@aas.no', '... and stringification works';

my $old = $u->to('larry@wall.org');
is $old, 'gisle@aas.no', 'to() returns old value';
is $u->to, 'larry@wall.org', '... and sets new value';
is $u, 'mailto:larry@wall.org', '... and stringification works';

$u->to("?/#");
is $u->to, "?/#", 'to() accepts chars that need escaping';
is $u, 'mailto:%3F/%23', '... and stringification escapes them';

my @h = $u->headers;
ok @h == 2 && "@h" eq "to ?/#", '... and headers() returns the correct values';

$u->headers(
    to      => 'gisle@aas.no',
    cc      => 'gisle@ActiveState.com,larry@wall.org',
    Subject => 'How do you do?',
    garbage => '/;?#=&',
);

@h = $u->headers;
ok @h == 8
  && "@h" eq
'to gisle@aas.no cc gisle@ActiveState.com,larry@wall.org Subject How do you do? garbage /;?#=&',
  'setting multiple headers at once works';
is $u->to, 'gisle@aas.no', '... and to() returns the new value';

#print "$u\n";
is $u,
'mailto:gisle@aas.no?cc=gisle%40ActiveState.com%2Clarry%40wall.org&Subject=How+do+you+do%3F&garbage=%2F%3B%3F%23%3D%26',
  '... and stringification works';

$u = URI->new("mailto:");
$u->to("gisle");
is $u, 'mailto:gisle', 'starting with an empty URI and setting to() works';

$u = URI->new('mailto:user+detail@example.com');
is $u->to, 'user+detail@example.com', 'subaddress with `+` parsed correctly';
is $u, 'mailto:user+detail@example.com', '... and stringification works';

TODO: {
    local $TODO = "We can't handle quoted local parts without properly parsing the email addresses";
    $u = URI->new('mailto:"foo bar+baz"@example.com');
    is $u->to, '"foo bar+baz"@example.com', 'address with quoted local part containing spaces is parsed correctly';
    is $u, 'mailto:%22foo%20bar+baz%22@example.com', '... and stringification works';
}

# RFC 5321 (4.1.3) - Address Literals

# IPv4
$u = URI->new('mailto:user@[127.0.0.1]');
is $u->to, 'user@[127.0.0.1]', 'IPv4 host name';
is $u, 'mailto:user@[127.0.0.1]', '... and stringification works';

# IPv6
$u = URI->new('mailto:user@[IPv6:fe80::e828:209d:20e:c0ae]');
is $u->to, 'user@[IPv6:fe80::e828:209d:20e:c0ae]', 'IPv4 host name';
is $u, 'mailto:user@[IPv6:fe80::e828:209d:20e:c0ae]', '... and stringification works';

done_testing;
