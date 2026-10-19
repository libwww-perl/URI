use strict;
use warnings;

use URI ();
use Test::More;

my $url = URI->new('http://[fe80::e828:209d:20e:c0ae]:375');

is($url->host, 'fe80::e828:209d:20e:c0ae', 'host');
is($url->port, 375,                        'port');

my $url2 = URI->new('http://[fe80::e828:209d:20e:c0ae]');
is($url2->host, 'fe80::e828:209d:20e:c0ae', 'host without port');
is($url2->port, 80,                         'default port without port');

my $url3 = URI->new('http://[fe80::e828:209d:20e:c0ae]:');
is($url3->host, 'fe80::e828:209d:20e:c0ae', 'host with empty port');
is($url3->port, 80,                         'default port with empty port');

my $url4 = URI->new('http://[::1]:/');
is($url4->host, '::1', 'loopback host with empty port');

done_testing();
