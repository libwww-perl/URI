use strict;
use warnings;

use URI ();
use Test::More;

my $url = URI->new('http://[fe80::e828:209d:20e:c0ae]:375');

is($url->host, 'fe80::e828:209d:20e:c0ae', 'host');
is($url->port, 375,                        'port');

my $url2 = URI->new('http://[fe80::e828:209d:20e:c0ae]');
is($url2->host, 'fe80::e828:209d:20e:c0ae', 'host');
is($url2->port, 80,                         'port');

my $url3 = URI->new('http://[fe80::e828:209d:20e:c0ae]:');
is($url3->host, 'fe80::e828:209d:20e:c0ae', 'host');
is($url3->port, 80,                         'port');

done_testing();
