#!perl -Tw

use Test;

plan tests => 1;

use URI::file;

my $cwd = eval { URI::file->cwd };
ok($@, '');

