#!perl -w

print "1..10\n";

use strict;
use URI::Split qw(uri_split uri_join);

sub j { join("-", map { defined($_) ? $_ : "<undef>" } @_) }

print "not " unless j(uri_split("p")) eq "<undef>-<undef>-p-<undef>-<undef>";
print "ok 1\n";

print "not " unless j(uri_split("p?q")) eq "<undef>-<undef>-p-q-<undef>";
print "ok 2\n";

print "not " unless j(uri_split("p#f")) eq "<undef>-<undef>-p-<undef>-f";
print "ok 3\n";

print "not " unless j(uri_split("p?q/#f/?")) eq "<undef>-<undef>-p-q/-f/?";
print "ok 4\n";

print "not " unless j(uri_split("s://a/p?q#f")) eq "s-a-/p-q-f";
print "ok 5\n";

print "not " unless uri_join("s", "a", "/p", "q", "f") eq "s://a/p?q#f";
print "ok 6\n";

print "not " unless uri_join("s", "a", "p", "q", "f") eq "s://a/p?q#f";
print "ok 7\n";

print "not " unless uri_join(undef, undef, "", undef, undef) eq "";
print "ok 8\n";

print "not " unless uri_join(undef, undef, "p", undef, undef) eq "p";
print "ok 9\n";

print "not " unless uri_join("s", undef, "p") eq "s:p";
print "ok 10\n";
