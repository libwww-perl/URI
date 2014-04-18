#!perl -w

print "1..12\n";

use URI;

$u = URI->new("irc://PerlUser\@irc.perl.org:6669/#libwww-perl,ischannel,isnetwork?key=bazqux");

#print "$u\n";
print "not " unless $u eq "irc://PerlUser\@irc.perl.org:6669/#libwww-perl,ischannel,isnetwork?key=bazqux";
print "ok 1\n";

print "not " unless $u->port == 6669;
print "ok 2\n";

# add a password
$u->password('foobar');
print "not " unless $u->userinfo eq "PerlUser:foobar";
print "ok 3\n";

@o = $u->options;
print "not " unless @o == 2 && "@o" eq "key bazqux";
print "ok 4\n";

$u->options(foo => "bar", bar => "baz");
print "not " unless $u->query eq "foo=bar&bar=baz";
print "ok 5\n";

print "not " unless $u->host eq "irc.perl.org";
print "ok 6\n";

print "not " unless $u->path eq "/#libwww-perl,ischannel,isnetwork";
print "ok 7\n";

# add a bunch of flags to clean up
$u->path("/SineSwiper,isnick,isnetwork,isserver,needpass,needkey");
$u = $u->canonical;

print "not " unless $u->path eq "/SineSwiper,isuser,isnetwork,needpass,needkey";
print "ok 8\n";

# ports and secure-ness
print "not " if $u->secure;
print "ok 9\n";

$u->port(undef);
print "not " unless $u->port == 6667;
print "ok 10\n";

$u->scheme("ircs");
print "not " unless $u->port == 994;
print "ok 11\n";

print "not " unless $u->secure;
print "ok 12\n";
