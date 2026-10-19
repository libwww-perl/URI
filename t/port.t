use strict;
use warnings;

use Test::More;

use URI ();

my $u = URI->new('https://api.good.example/v1/hook');
for my $bad ("443\@evil.example", "443\n") {
    eval { $u->port($bad) };
    like($@, qr/Bad port/, 'port() rejects a non-numeric value');
    is(
        $u->as_string,
        'https://api.good.example/v1/hook',
        'URI unchanged after rejected port'
    );
}

$u->port(8443);
is(
    $u->as_string,
    'https://api.good.example:8443/v1/hook',
    'numeric port still accepted'
);

done_testing();
