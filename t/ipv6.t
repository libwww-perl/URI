#!perl

use strict;
use warnings;

use URI ();
use Test::More;

my $url = URI->new('http://[fe80::e828:209d:20e:c0ae]:375');

is( $url->host, 'fe80::e828:209d:20e:c0ae', 'host' );
is( $url->port, 375, 'port' );

done_testing();
