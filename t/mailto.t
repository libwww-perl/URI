use strict;
use warnings;

use Test::More;

use URI ();

subtest 'to() and headers() on a normal URI' => sub {
    my $u = URI->new('mailto:gisle@aas.no');
    is $u->to, 'gisle@aas.no',        'parsing normal URI sets to()';
    is $u,     'mailto:gisle@aas.no', '... and stringification works';

    my $old = $u->to('larry@wall.org');
    is $old,   'gisle@aas.no',          'to() returns old value';
    is $u->to, 'larry@wall.org',        '... and sets new value';
    is $u,     'mailto:larry@wall.org', '... and stringification works';

    $u->to("?/#");
    is $u->to, "?/#",            'to() accepts chars that need escaping';
    is $u,     'mailto:%3F/%23', '... and stringification escapes them';

    my @h = $u->headers;
    ok @h == 2 && "@h" eq "to ?/#",
        '... and headers() returns the correct values';

    $u->headers(
        to      => 'gisle@aas.no',
        cc      => 'gisle@ActiveState.com,larry@wall.org',
        Subject => 'How do you do?',
        garbage => '/;?#=&',
    );

    @h = $u->headers;
    ok @h == 8
        && "@h" eq
        'to gisle@aas.no cc gisle@ActiveState.com,larry@wall.org Subject How do you do? garbage /;?#=&',
        'setting multiple headers at once works';
    is $u->to, 'gisle@aas.no', '... and to() returns the new value';

    is $u,
        'mailto:gisle@aas.no?cc=gisle%40ActiveState.com%2Clarry%40wall.org&Subject=How+do+you+do%3F&garbage=%2F%3B%3F%23%3D%26',
        '... and stringification works';
};

subtest 'empty URI' => sub {
    my $u = URI->new("mailto:");
    $u->to("gisle");
    is $u, 'mailto:gisle', 'starting with an empty URI and setting to() works';
};

subtest 'subaddress' => sub {
    my $u = URI->new('mailto:user+detail@example.com');
    is $u->to, 'user+detail@example.com',
        'subaddress with `+` parsed correctly';
    is $u, 'mailto:user+detail@example.com', '... and stringification works';
};

subtest 'quoted local part' => sub {
    my $u = URI->new('mailto:"foo bar+baz"@example.com');
    is $u->to, '"foo bar+baz"@example.com',
        'address with quoted local part containing spaces is parsed correctly';
    is $u, 'mailto:%22foo%20bar+baz%22@example.com',
        '... and stringification works';
};

for my $recipient (
    'user@example.com',           'user+detail@example.com',
    '"foo bar+baz"@example.com',  '"foo  bar+baz"@example.com',
    '"foo, bar+baz"@example.com', '"foo%20bar+baz"@example.com',
    'user@[127.0.0.1]',           'user@[IPv6:fe80::e828:209d:20e:c0ae]',
    )
{
    subtest "round trip $recipient" => sub {
        my $u = URI->new('mailto:old@example.com?subject=hello+world');
        is $u->to($recipient), 'old@example.com',
            'setter returns old recipient';
        is $u->to, $recipient, "setter preserves $recipient";

        subtest 'serialized copy' => sub {
            my $copy = URI->new("$u");
            is $copy->to, $recipient, 'recipient survives serialization';
            my @headers = $copy->headers;
            is_deeply \@headers, [to => $recipient, subject => 'hello world'],
                'headers preserve recipient and form-encoded subject';
            $copy->headers(@headers);
            is $copy->to, $recipient, 'recipient survives headers round trip';
            is "$copy",   "$u", 'headers round trip preserves serialization';
        };
    };
}

subtest 'percent-encoded space and plus' => sub {
    my $u = URI->new('mailto:%22foo%20bar%2Bbaz%22@example.com');
    is $u->to, '"foo bar+baz"@example.com',
        'percent-encoded space and plus decode separately';
};

subtest 'lowercase encoded plus' => sub {
    my $u = URI->new('mailto:%22foo%20bar%2bbaz%22@example.com');
    is $u->to, '"foo bar+baz"@example.com', 'lowercase encoded plus is decoded';
};

subtest 'repeated recipients' => sub {
    my $u
        = URI->new(
        'mailto:first+tag@example.com?subject=hello+world&to=%22foo%20bar+baz%22@example.com'
            . '&TO=third%2Btag@example.com&to=fourth+tag@example.com');
    is $u->to,
        'first+tag@example.com,"foo bar+baz"@example.com,third+tag@example.com,fourth+tag@example.com',
        'all recipient fields retain spaces and plus signs';
    my @headers = $u->headers;
    is_deeply \@headers,
        [
        to      => 'first+tag@example.com',
        subject => 'hello world',
        to      => '"foo bar+baz"@example.com',
        TO      => 'third+tag@example.com',
        to      => 'fourth+tag@example.com',
        ],
        'headers preserve repeated and case-insensitive recipients in order';
    my $recipients = $u->to;
    $u->headers(@headers);
    is $u->to, $recipients, 'repeated recipients survive headers round trip';
    is $u->to('replacement+tag@example.com'), $recipients,
        'setter returns all previous recipients';
    is_deeply [$u->headers],
        [to => 'replacement+tag@example.com', subject => 'hello world',],
        'setter replaces all recipient fields and preserves other headers';
};

subtest 'query_form' => sub {
    my $u
        = URI->new(
              'mailto:?subject=a+b%20c%2Bd&to=%22foo%20bar+baz%22@example.com'
            . '&TO=second+tag@example.com&to');
    my @form = $u->query_form;
    is_deeply \@form,
        [
        subject => 'a b c+d',
        to      => '"foo bar+baz"@example.com',
        TO      => 'second+tag@example.com',
        to      => undef,
        ],
        'query_form handles later and repeated recipients and leaves bare values undefined';
    is scalar($u->query_form), 8, 'query_form retains scalar return behavior';
    is_deeply [
        $u->query_form(
            to      => '"new space+tag"@example.com',
            subject => 'new subject+suffix'
        )
        ],
        \@form, 'query_form setter returns previous fields';
    is_deeply [$u->query_form],
        [to => '"new space+tag"@example.com', subject => 'new subject+suffix',],
        'query_form setter round trip preserves recipient and subject';
    is $u,
        'mailto:?to=%22new%20space%2Btag%22%40example.com&subject=new+subject%2Bsuffix',
        'query_form serializes recipient spaces as %20 and preserves header form encoding';

    $u->query_form(
        [to => ['first+tag@example.com', '"second space+tag"@example.com']]);
    is_deeply [$u->query_form],
        [
        to => 'first+tag@example.com',
        to => '"second space+tag"@example.com',
        ],
        'query_form array values preserve repeated recipients';
    $u->query_form(
        {to => '"hash space+tag"@example.com', subject => 'hash subject'});
    is_deeply [$u->query_form],
        [subject => 'hash subject', to => '"hash space+tag"@example.com',],
        'query_form hash setter handles recipients after another header';
    $u->query('subject=hello+world;to=%22foo%20bar+baz%22@example.com');
    is_deeply [$u->query_form],
        [subject => 'hello world', to => '"foo bar+baz"@example.com',],
        'semicolon delimiter preserves recipient semantics';
    $u->query('subject=first&%74%6f=%22foo%20bar+baz%22@example.com');
    is_deeply [$u->query_form],
        [subject => 'first', to => '"foo bar+baz"@example.com',],
        'encoded recipient field name is recognized';

    my @old_headers = $u->headers(
        to      => '"header space+tag"@example.com',
        subject => 'header subject+suffix'
    );
    is_deeply \@old_headers,
        [to => '', subject => 'first', to => '"foo bar+baz"@example.com',],
        'headers setter returns previous decoded fields';
    is_deeply [$u->headers],
        [
        to      => '"header space+tag"@example.com',
        subject => 'header subject+suffix',
        ],
        'headers setter preserves quoted space and subject plus';
    my $before = "$u";
    my @read   = $u->headers;
    is "$u", $before, 'reading headers does not mutate URI';
    @read = $u->query_form;
    is "$u", $before, 'reading query_form does not mutate URI';
    $u->query_form(to => '"void space+tag"@example.com');
    is_deeply [$u->query_form], [to => '"void space+tag"@example.com'],
        'query_form setter works in void context';
    is scalar($u->query_form(subject => 'only subject')), 2,
        'query_form setter retains scalar return behavior';
    is_deeply [$u->query_form], [subject => 'only subject'],
        'query_form setter without recipient retains form behavior';
    is_deeply [$u->query_form([])], [subject => 'only subject'],
        'empty setter returns old fields';
    ok !defined($u->query), 'empty setter removes query';
};

subtest 'clearing recipient' => sub {
    my $u = URI->new('mailto:old+tag@example.com?subject=keep#fragment');
    $u->to('"new space+tag"@example.com');
    is $u->fragment, 'fragment', 'recipient setter retains fragment';
    $u->to(undef);
    is $u->to, '', 'undefined recipient clears recipient';
    is_deeply [$u->headers], [to => '', subject => 'keep'],
        'clearing recipient retains other headers';
};

subtest 'queries without form fields' => sub {
    my $u = URI->new('mailto:');
    is_deeply [$u->query_form], [], 'missing query has no form fields';
    $u->query('');
    is_deeply [$u->query_form], [], 'empty query has no form fields';
    $u->query('keywords+only');
    is_deeply [$u->query_form], [], 'keyword query has no form fields';
};

# RFC 5321 (4.1.3) - Address Literals

subtest 'IPv4 address literal' => sub {
    my $u = URI->new('mailto:user@[127.0.0.1]');
    is $u->to, 'user@[127.0.0.1]',        'IPv4 host name';
    is $u,     'mailto:user@[127.0.0.1]', '... and stringification works';
};

subtest 'IPv6 address literal' => sub {
    my $u = URI->new('mailto:user@[IPv6:fe80::e828:209d:20e:c0ae]');
    is $u->to, 'user@[IPv6:fe80::e828:209d:20e:c0ae]', 'IPv6 host name';
    is $u, 'mailto:user@[IPv6:fe80::e828:209d:20e:c0ae]',
        '... and stringification works';
};

done_testing();
