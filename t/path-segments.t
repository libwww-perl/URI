use strict;
use warnings;

use Test::More 'no_plan';

use URI ();

{
    my $u = URI->new("http://www.example.org/a/b/c");

    is_deeply [$u->path_segments], ['', qw(a b c)], 'path_segments in list context';
    is $u->path_segments, '/a/b/c', 'path_segments in scalar context';

    is_deeply [$u->path_segments('', qw(z y x))], ['', qw(a b c)], 'set path_segments in list context';
    is $u->path_segments('/i/j/k'), '/z/y/x', 'set path_segments in scalar context';

    $u->path_segments('', qw(q r s));
    is $u->path_segments, '/q/r/s', 'set path_segments in void context';
}

{
    my $u = URI->new("http://www.example.org/abc");
    $u->path_segments('', '%', ';', '/');
    is $u->path_segments, '/%25/%3B/%2F', 'escaping special characters';
}

{
    my $u = URI->new("http://www.example.org/abc;param1;param2");
    my @ps = $u->path_segments;
    isa_ok $ps[1], 'URI::_segment';
    $u->path_segments(@ps);
    is $u->path_segments, '/abc;param1;param2', 'dealing with URI segments';
}
