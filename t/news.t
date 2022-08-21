use strict;
use warnings;

use Test::More tests => 8;

use URI ();

my $u = URI->new("news:comp.lang.perl.misc");

ok($u->group eq "comp.lang.perl.misc" &&
   !defined($u->message) &&
   $u->port == 119 &&
   $u eq "news:comp.lang.perl.misc");


$u->host("news.online.no");
ok($u->group eq "comp.lang.perl.misc" &&
   $u->port == 119 &&
   $u eq "news://news.online.no/comp.lang.perl.misc");

$u->group("no.perl", 1 => 10);
is($u, "news://news.online.no/no.perl/1-10");

my @g = $u->group;
is_deeply(\@g, ["no.perl", 1, 10]);

$u->message('42@g.aas.no');
#print "$u\n";
ok($u->message eq '42@g.aas.no' &&
   !defined($u->group) &&
   $u eq 'news://news.online.no/42@g.aas.no');


$u = URI->new("nntp:no.perl");
ok($u->group eq "no.perl" &&
   $u->port == 119);

$u = URI->new("snews://snews.online.no/no.perl");

ok($u->group eq "no.perl" &&
   $u->host  eq "snews.online.no" &&
   $u->port == 563);

$u = URI->new("nntps://nntps.online.no/no.perl");

ok($u->group eq "no.perl" &&
   $u->host  eq "nntps.online.no" &&
   $u->port == 563);
