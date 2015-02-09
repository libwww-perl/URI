#!perl -w

use strict;
use warnings;

print "1..23\n";

use URI;
my $uri;

$uri = URI->new("ftp://ftp.example.com/path");

print "not " unless $uri->scheme eq "ftp";
print "ok 1\n";

print "not " unless $uri->host eq "ftp.example.com";
print "ok 2\n";

print "not " unless $uri->port == 21;
print "ok 3\n";

print "not " unless $uri->secure == 0;
print "ok 4\n";

print "not " if $uri->encrypt_mode;
print "ok 5\n";

print "not " unless $uri->user eq "anonymous";
print "ok 6\n";

print "not " unless $uri->password eq 'anonymous@';
print "ok 7\n";

$uri->userinfo("gisle\@aas.no");

print "not " unless $uri eq "ftp://gisle%40aas.no\@ftp.example.com/path";
print "ok 8\n";

print "not " unless $uri->user eq "gisle\@aas.no";
print "ok 9\n";

print "not " if defined($uri->password);
print "ok 10\n";

$uri->password("secret");

print "not " unless $uri eq "ftp://gisle%40aas.no:secret\@ftp.example.com/path";
print "ok 11\n";

$uri = URI->new("ftp://gisle\@aas.no:secret\@ftp.example.com/path");
print "not " unless $uri eq "ftp://gisle\@aas.no:secret\@ftp.example.com/path";
print "ok 12\n";

print "not " unless $uri->userinfo eq "gisle\@aas.no:secret";
print "ok 13\n";

print "not " unless $uri->user eq "gisle\@aas.no";
print "ok 14\n";

print "not " unless $uri->password eq "secret";
print "ok 15\n";

$uri = URI->new("ftps://ftp.example.com/path");

print "not " unless $uri->scheme eq "ftps";
print "ok 16\n";

print "not " unless $uri->port == 990;
print "ok 17\n";

print "not " unless $uri->secure == 1;
print "ok 18\n";

print "not " unless $uri->encrypt_mode eq 'implicit';
print "ok 19\n";

$uri = URI->new("ftpes://ftp.example.com/path");

print "not " unless $uri->scheme eq "ftpes";
print "ok 20\n";

print "not " unless $uri->port == 21;
print "ok 21\n";

print "not " unless $uri->secure == 1;
print "ok 22\n";

print "not " unless $uri->encrypt_mode eq 'explicit';
print "ok 23\n";
