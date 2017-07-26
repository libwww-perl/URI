use strict;
use warnings;

use Test::Needs 'Storable';

system($^X, "-Iblib/lib", "t/storable-test.pl", "store");
system($^X, "-Iblib/lib", "t/storable-test.pl", "retrieve");

unlink('urls.sto');
