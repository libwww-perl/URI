#!perl -Tw

use strict;
use warnings;

use Test;

plan tests => 1;

use URI::file;
$ENV{PATH} = "/bin:/usr/bin";

my $cwd = eval { URI::file->cwd };
ok($@, '');

