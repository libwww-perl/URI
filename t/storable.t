use strict;
use warnings;

use Test::Needs 'Storable';

my $inc = -d "blib/lib" ? "blib/lib" : "lib";
system($^X, "-I$inc", "t/storable-test.pl", "store");
system($^X, "-I$inc", "t/storable-test.pl", "retrieve");

unlink('urls.sto');
