use strict;
use warnings;

use Test::More tests => 37;

use URI ();
my $u = URI->new("", "http");
my @q;

# For tests using array object
{
    package
        Foo::Bar::Array;
    sub new
    {
        my $this = shift( @_ );
        return( bless( ( @_ == 1 && ref( $_[0] || '' ) eq 'ARRAY' ) ? shift( @_ ) : [@_] => ( ref( $this ) || $this ) ) );
    }

    package
        Foo::Bar::Stringy;
    push( @Foo::Bar::Stringy::ISA, 'Foo::Bar::Array' );
    use overload (
        '""' => '_as_string',
    );
    sub _as_string
    {
        my $self = shift;
        local $" = '_hello_';
        return( "@$self" );
    }
}

$u->query_form(a => 3, b => 4);
is $u, "?a=3&b=4";

$u->query_form(a => undef);
is $u, "?a";

$u->query_form("a[=&+#] " => " [=&+#]");
is $u, "?a%5B%3D%26%2B%23%5D+=+%5B%3D%26%2B%23%5D";

@q = $u->query_form;
is join(":", @q), "a[=&+#] : [=&+#]";

@q = $u->query_keywords;
ok !@q;

$u->query_keywords("a", "b");
is $u, "?a+b";

$u->query_keywords(" ", "+", "=", "[", "]");
is $u, "?%20+%2B+%3D+%5B+%5D";

@q = $u->query_keywords;
is join(":", @q), " :+:=:[:]";

@q = $u->query_form;
ok !@q;

$u->query(" +?=#");
is $u, "?%20+?=%23";

$u->query_keywords([qw(a b)]);
is $u, "?a+b";

# Same, but using array object
$u->query_keywords(Foo::Bar::Array->new([qw(a b)]));
is $u, "?a+b";

# Same, but using a stringifyable array object
$u->query_keywords(Foo::Bar::Stringy->new([qw(a b)]));
is $u, "?a_hello_b";

$u->query_keywords([]);
is $u, "";

# Same, but using array object
$u->query_keywords(Foo::Bar::Array->new([]));
is $u, "";

# Same, but using a stringifyable array object
$u->query_keywords(Foo::Bar::Stringy->new([]));
is $u, "?";

$u->query_form({ a => 1, b => 2 });
ok $u eq "?a=1&b=2" || $u eq "?b=2&a=1";

$u->query_form([ a => 1, b => 2 ]);
is $u, "?a=1&b=2";

# Same, but using array object
$u->query_form(Foo::Bar::Array->new([ a => 1, b => 2 ]));
is $u, "?a=1&b=2";

$u->query_form({});
is $u, "";

$u->query_form([a => [1..4]]);
is $u, "?a=1&a=2&a=3&a=4";

# Same, but using array object
$u->query_form(Foo::Bar::Array->new([a => [1..4]]));
is $u, "?a=1&a=2&a=3&a=4";

$u->query_form([]);
is $u, "";

# Same, but using array object
$u->query_form(Foo::Bar::Array->new([]));
is $u, "";

# Same, but using a strngifyable array object
$u->query_form(Foo::Bar::Stringy->new([]));
is $u, "";

$u->query_form(a => { foo => 1 });
ok "$u" =~ /^\?a=HASH\(/;

$u->query_form(a => 1, b => 2, ';');
is $u, "?a=1;b=2";

$u->query_form(a => 1, c => 2);
is $u, "?a=1;c=2";

$u->query_form(a => 1, c => 2, '&');
is $u, "?a=1&c=2";

$u->query_form([a => 1, b => 2], ';');
is $u, "?a=1;b=2";

# Same, but using array object
$u->query_form(Foo::Bar::Array->new([a => 1, b => 2]), ';');
is $u, "?a=1;b=2";

# Same, but using a stringifyable array object
$u->query_form("c" => Foo::Bar::Stringy->new([a => 1, b => 2]), "d" => "e", ';');
is $u, "?c=a_hello_1_hello_b_hello_2;d=e";

$u->query_form([]);
{
    local $URI::DEFAULT_QUERY_FORM_DELIMITER = ';';
    $u->query_form(a => 1, b => 2);
}
is $u, "?a=1;b=2";

# Same, but using array object
$u->query_form(Foo::Bar::Array->new([]));
{
    local $URI::DEFAULT_QUERY_FORM_DELIMITER = ';';
    $u->query_form(a => 1, b => 2);
}
is $u, "?a=1;b=2";

$u->query('a&b=2');
@q = $u->query_form;
is join(":", map { defined($_) ? $_ : '' } @q), "a::b:2";
ok !defined($q[1]);

$u->query_form(@q);
is $u,'?a&b=2';
