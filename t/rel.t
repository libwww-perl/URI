#!/usr/bin/perl -w

use strict;
use warnings;

use Test;

plan tests => 6;

use URI;

my $uri;

$uri = URI->new("http://www.example.com/foo/bar/");
ok($uri->rel("http://www.example.com/foo/bar/"), "./");
ok($uri->rel("HTTP://WWW.EXAMPLE.COM/foo/bar/"), "./");
ok($uri->rel("HTTP://WWW.EXAMPLE.COM/FOO/BAR/"), "../../foo/bar/");
ok($uri->rel("HTTP://WWW.EXAMPLE.COM:80/foo/bar/"), "./");

$uri = URI->new("http://www.example.com/foo/bar");
ok($uri->rel("http://www.example.com/foo/bar"), "bar");
ok($uri->rel("http://www.example.com/foo"), "foo/bar");

