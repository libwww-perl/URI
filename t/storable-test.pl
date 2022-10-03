use strict;
use warnings;
use Storable qw( retrieve store );

if (@ARGV && $ARGV[0] eq "store") {
    require URI;
    require URI::URL;
    my $a = {
        u => new URI('http://search.cpan.org/'),
    };
    print "# store\n";
    store [URI->new("http://search.cpan.org")], 'urls.sto';
} else {
    require Test::More;
    Test::More->import(tests => 3);
    note("retrieve");
    my $a = retrieve 'urls.sto';
    my $u = $a->[0];
    #use Data::Dumper; print Dumper($a);

    is($u, "http://search.cpan.org");

    is($u->scheme, "http");

    is(ref($u), "URI::http");
}
