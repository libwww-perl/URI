use strict;
use warnings;

use Test::More;

use URI;

my $uri = URI->new('rsync://foo:bar@example.com');
like $uri->as_string, qr/foo:bar\@example\.com/, 'userinfo is included';

$uri->password(undef);
like $uri->as_string, qr/foo\@example\.com/, 'set password to undef';

$uri = URI->new('rsync://0:bar@example.com');
$uri->password(undef);
like $uri->as_string, qr/0\@example\.com/, '... also for username "0"';

done_testing;
