use strict;
use warnings;

use Test::More tests => 11;

use URI ();

my $u = URI->new('sip:phone@domain.ext');
ok($u->user eq 'phone' &&
	$u->host eq 'domain.ext' &&
	$u->port eq '5060' &&
	$u eq 'sip:phone@domain.ext');

$u->host_port('otherdomain.int:9999');
ok($u->host eq 'otherdomain.int' &&
   $u->port eq '9999' &&
   $u eq 'sip:phone@otherdomain.int:9999');

$u->port('5060');
$u = $u->canonical;
ok($u->host eq 'otherdomain.int' &&
   $u->port eq '5060' &&
   $u eq 'sip:phone@otherdomain.int');

$u->user('voicemail');
ok($u->user eq 'voicemail' &&
   $u eq 'sip:voicemail@otherdomain.int');

$u = URI->new('sip:phone@domain.ext?Subject=Meeting&Priority=Urgent');
ok($u->host eq 'domain.ext' &&
   $u->query eq 'Subject=Meeting&Priority=Urgent');

$u->query_form(Subject => 'Lunch', Priority => 'Low');
my @q = $u->query_form;
ok($u->host eq 'domain.ext' &&
   $u->query eq 'Subject=Lunch&Priority=Low' &&
   @q == 4 && "@q" eq "Subject Lunch Priority Low");

$u = URI->new('sip:phone@domain.ext;maddr=127.0.0.1;ttl=16');
ok($u->host eq 'domain.ext' &&
   $u->params eq 'maddr=127.0.0.1;ttl=16');

$u = URI->new('sip:phone@domain.ext?Subject=Meeting&Priority=Urgent');
$u->params_form(maddr => '127.0.0.1', ttl => '16');
my @p = $u->params_form;
ok($u->host eq 'domain.ext' &&
   $u->query eq 'Subject=Meeting&Priority=Urgent' &&
   $u->params eq 'maddr=127.0.0.1;ttl=16' &&
   @p == 4 && "@p" eq "maddr 127.0.0.1 ttl 16");

$u = URI->new_abs('sip:phone@domain.ext', 'sip:foo@domain2.ext');
is($u, 'sip:phone@domain.ext');

$u = URI->new('sip:phone@domain.ext');
is($u, $u->abs('http://www.cpan.org/'));

is($u, $u->rel('http://www.cpan.org/'));
