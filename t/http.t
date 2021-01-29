use strict;
use warnings;

print "1..16\n";

use URI ();

my $u = URI->new("<http://www.example.com/path?q=f�o>");

#print "$u\n";
print "not " unless $u eq "http://www.example.com/path?q=f%F4o";
print "ok 1\n";

print "not " unless $u->port == 80;
print "ok 2\n";

# play with port
my $old = $u->port(8080);
print "not " unless $old == 80 && $u eq "http://www.example.com:8080/path?q=f%F4o";
print "ok 3\n";

$u->port(80);
print "not " unless $u eq "http://www.example.com:80/path?q=f%F4o";
print "ok 4\n";

$u->port("");
print "not " unless $u eq "http://www.example.com:/path?q=f%F4o" && $u->port == 80;
print "ok 5\n";

$u->port(undef);
print "not " unless $u eq "http://www.example.com/path?q=f%F4o";
print "ok 6\n";

my @q = $u->query_form;
print "not " unless @q == 2 && "@q" eq "q f�o";
print "ok 7\n";

$u->query_form(foo => "bar", bar => "baz");
print "not " unless $u->query eq "foo=bar&bar=baz";
print "ok 8\n";

print "not " unless $u->host eq "www.example.com";
print "ok 9\n";

print "not " unless $u->path eq "/path";
print "ok 10\n";

print "not " if $u->secure;
print "ok 11\n";

$u->scheme("https");
print "not " unless $u->port == 443;
print "ok 12\n";

print "not " unless $u eq "https://www.example.com/path?foo=bar&bar=baz";
print "ok 13\n";

print "not " unless $u->secure;
print "ok 14\n";

$u = URI->new("http://%65%78%61%6d%70%6c%65%2e%63%6f%6d/%70%75%62/%61/%32%30%30%31/%30%38/%32%37/%62%6a%6f%72%6e%73%74%61%64%2e%68%74%6d%6c");
print "not " unless $u->canonical eq "http://example.com/pub/a/2001/08/27/bjornstad.html";
print "ok 15\n";

print "not " unless $u->has_recognized_scheme;
print "ok 16\n";
