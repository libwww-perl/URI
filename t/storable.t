#!perl -w

eval {
    require Storable;
    print "1..3\n";
};
if ($@) {
    print "1..0\n";
    exit;
}

system($^X, "-Mblib", "t/storable-test.pl", "store");
system($^X, "-Mblib", "t/storable-test.pl", "retrieve");

unlink('urls.sto');
