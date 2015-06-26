#!perl -T

use strict;
use warnings;

use Test::More;

plan tests => 1;

use URI::file;
$ENV{PATH} = "/bin:/usr/bin";

my $cwd = eval { URI::file->cwd };
is($@, '', 'no exceptions');

