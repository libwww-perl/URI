#!perl -w

use strict;
use warnings;

print "1..5\n";

use URI;

{
  my $u = URI->new("<ws://www.perl.com/path?q=fôo>");
  print "not " unless $u->scheme eq "ws";
  print "ok 1\n";
  print "not " unless ref($u) eq "URI::ws";
  print "ok 2\n";
}

{
  my $u = URI->new("<wss://www.perl.com/path?q=fôo>");
  print "not " unless $u->scheme eq "wss";
  print "ok 3\n";
  print "not " unless ref($u) eq "URI::wss";
  print "ok 4\n";
  print "not " unless $u->secure;
  print "ok 5\n";
}

