use strict;
use warnings;

use Test::More;
BEGIN {
    plan skip_all => 'these tests are for authors only!'
        unless -d '.git' || $ENV{AUTHOR_TESTING};
}

eval 'use Test::DistManifest';
if ($@) {
    plan skip_all => 'Test::DistManifest required to test MANIFEST';
}

manifest_ok();
