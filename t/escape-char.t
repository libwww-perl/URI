use strict;
use warnings;

# see https://rt.cpan.org/Ticket/Display.html?id=96941

use Test::More;
use URI;

TODO: {
    my $str = "http://foo/\xE9";
    utf8::upgrade($str);
    my $uri = URI->new($str);

    local $TODO = 'URI::Escape::escape_char misunderstands utf8';

    # http://foo/%C3%A9
    is("$uri", 'http://foo/%E9', 'correctly created a URI from a utf8-upgraded string');
}

{
    my $str = "http://foo/\xE9";
    utf8::downgrade($str);
    my $uri = URI->new($str);

    # http://foo/%E9
    is("$uri", 'http://foo/%E9', 'correctly created a URI from a utf8-downgrade string');
}

done_testing;
