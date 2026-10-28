use strict;
use warnings;

use Test::More;

use URI ();

subtest q{to() and headers() on a normal URI} => sub {
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
    ok @h == 2 && "@h" eq q{to ?/#},
        q{... and headers() returns the correct values};

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

subtest q{empty URI} => sub {
    my $u = URI->new(q{mailto:});
    $u->to("gisle");
    is $u, 'mailto:gisle', 'starting with an empty URI and setting to() works';
};

subtest q{subaddress} => sub {
    my $u = URI->new(q{mailto:user+detail@example.com});
    is $u->to, q{user+detail@example.com},
        q{subaddress with `+` parsed correctly};
    is $u, 'mailto:user+detail@example.com', '... and stringification works';
};

subtest q{quoted local part} => sub {
    my $u = URI->new(q{mailto:"foo bar+baz"@example.com});
    is $u->to, '"foo bar+baz"@example.com',
        'address with quoted local part containing spaces is parsed correctly';
    is $u, 'mailto:%22foo%20bar+baz%22@example.com',
        '... and stringification works';
};

for my $recipient (
    q{user@example.com},           q{user+detail@example.com},
    q{"foo bar+baz"@example.com},  q{"foo  bar+baz"@example.com},
    q{"foo, bar+baz"@example.com}, q{"foo%20bar+baz"@example.com},
    q{user@[127.0.0.1]},           q{user@[IPv6:fe80::e828:209d:20e:c0ae]},
    q{"foo&bar"@example.com},      q{"foo;bar"@example.com},
    q{"foo=bar"@example.com},      q{"foo\\"bar"@example.com},
    )
{
    subtest "round trip $recipient" => sub {
        my $u = URI->new(q{mailto:old@example.com?subject=hello+world});
        is $u->to($recipient), q{old@example.com},
            q{setter returns old recipient};
        is $u->to, $recipient, "setter preserves $recipient";

        subtest q{serialized copy} => sub {
            my $copy = URI->new("$u");
            is $copy->to, $recipient, q{recipient survives serialization};
            my @headers = $copy->headers;
            is_deeply \@headers, [to => $recipient, subject => q{hello world}],
                q{headers preserve recipient and form-encoded subject};
            $copy->headers(@headers);
            is $copy->to, $recipient, q{recipient survives headers round trip};
            is "$copy",   "$u", q{headers round trip preserves serialization};
        };
    };
}

subtest q{recipient cannot inject headers} => sub {
    my $u = URI->new(q{mailto:});
    $u->to(q{a@example.com&bcc=evil@example.com;cc=evil@example.com});
    is $u,
        q{mailto:a@example.com%26bcc%3Devil@example.com%3Bcc%3Devil@example.com},
        q{header delimiters in recipient are escaped};

    subtest q{serialized copy} => sub {
        my $copy = URI->new("$u");
        is_deeply [$copy->headers],
            [to => q{a@example.com&bcc=evil@example.com;cc=evil@example.com}],
            q{no extra headers after reparsing};
    };
};

subtest q{equals sign in recipient is escaped} => sub {
    my $u = URI->new(q{mailto:});
    $u->to(q{"foo=bar"@example.com});
    is $u, q{mailto:%22foo%3Dbar%22@example.com},
        q{= is percent-encoded per RFC 6068 section 2};
};

subtest q{percent sign in recipient is escaped} => sub {
    my $u = URI->new(q{mailto:});
    $u->to(q{"100%"@example.com});
    is $u,     q{mailto:%22100%25%22@example.com}, q{% is percent-encoded};
    is $u->to, q{"100%"@example.com},              q{... and decodes back};
};

subtest q{percent-encoded space and plus} => sub {
    my $u = URI->new(q{mailto:%22foo%20bar%2Bbaz%22@example.com});
    is $u->to, q{"foo bar+baz"@example.com},
        q{percent-encoded space and plus decode separately};
};

subtest q{lowercase encoded plus} => sub {
    my $u = URI->new(q{mailto:%22foo%20bar%2bbaz%22@example.com});
    is $u->to, q{"foo bar+baz"@example.com},
        q{lowercase encoded plus is decoded};
};

subtest q{repeated recipients} => sub {
    my $u
        = URI->new(
        q{mailto:first+tag@example.com?subject=hello+world&to=%22foo%20bar+baz%22@example.com}
            . q{&TO=third%2Btag@example.com&to=fourth+tag@example.com});
    is $u->to,
        q{first+tag@example.com,"foo bar+baz"@example.com,third+tag@example.com,fourth+tag@example.com},
        q{all recipient fields retain spaces and plus signs};
    my @headers = $u->headers;
    is_deeply \@headers,
        [
        to      => q{first+tag@example.com},
        subject => q{hello world},
        to      => q{"foo bar+baz"@example.com},
        TO      => q{third+tag@example.com},
        to      => q{fourth+tag@example.com},
        ],
        q{headers preserve repeated and case-insensitive recipients in order};
    my $recipients = $u->to;
    $u->headers(@headers);
    is $u->to, $recipients, q{repeated recipients survive headers round trip};
    is $u->to(q{replacement+tag@example.com}), $recipients,
        q{setter returns all previous recipients};
    is_deeply [$u->headers],
        [to => q{replacement+tag@example.com}, subject => q{hello world},],
        q{setter replaces all recipient fields and preserves other headers};
};

subtest q{query_form getter} => sub {
    my $u
        = URI->new(
              q{mailto:?subject=a+b%20c%2Bd&to=%22foo%20bar+baz%22@example.com}
            . q{&TO=second+tag@example.com&to});
    is_deeply [$u->query_form],
        [
        subject => q{a b c+d},
        to      => q{"foo bar+baz"@example.com},
        TO      => q{second+tag@example.com},
        to      => undef,
        ],
        q{query_form handles later and repeated recipients and leaves bare values undefined};
};

subtest q{query_form setter} => sub {
    my $u = URI->new(q{mailto:?subject=a+b&to=%22foo%20bar+baz%22@example.com});
    is_deeply [
        $u->query_form(
            to      => q{"new space+tag"@example.com},
            subject => q{new subject+suffix}
        )
        ],
        [subject => q{a b}, to => q{"foo bar+baz"@example.com}],
        q{query_form setter returns previous fields};
    is_deeply [$u->query_form],
        [
        to      => q{"new space+tag"@example.com},
        subject => q{new subject+suffix},
        ],
        q{query_form setter round trip preserves recipient and subject};
    is $u,
        q{mailto:?to=%22new%20space%2Btag%22%40example.com&subject=new+subject%2Bsuffix},
        q{query_form serializes recipient spaces as %20 and preserves header form encoding};
};

subtest q{query_form setter with uppercase TO} => sub {
    my $u = URI->new(q{mailto:});
    $u->query_form(TO => q{"a b+c"@example.com});
    is $u, q{mailto:?TO=%22a%20b%2Bc%22%40example.com},
        q{uppercase recipient field serializes spaces as %20};
    is_deeply [$u->query_form], [TO => q{"a b+c"@example.com}],
        q{... and round trips};
};

subtest q{query_form array setter} => sub {
    my $u = URI->new(q{mailto:});
    $u->query_form(
        [to => [q{first+tag@example.com}, q{"second space+tag"@example.com}]]);
    is_deeply [$u->query_form],
        [
        to => q{first+tag@example.com},
        to => q{"second space+tag"@example.com},
        ],
        q{query_form array values preserve repeated recipients};
};

subtest q{query_form hash setter} => sub {
    my $u = URI->new(q{mailto:});
    $u->query_form(
        {to => q{"hash space+tag"@example.com}, subject => q{hash subject}});
    is_deeply [$u->query_form],
        [subject => q{hash subject}, to => q{"hash space+tag"@example.com},],
        q{query_form hash setter handles recipients after another header};
};

subtest q{query_form with semicolon delimiter} => sub {
    my $u = URI->new(
        q{mailto:?subject=hello+world;to=%22foo%20bar+baz%22@example.com});
    is_deeply [$u->query_form],
        [subject => q{hello world}, to => q{"foo bar+baz"@example.com},],
        q{semicolon delimiter preserves recipient semantics};
};

subtest q{query_form with empty segments} => sub {
    my $u = URI->new(q{mailto:?subject=x&&to=%22a%20b+c%22@example.com&});
    is_deeply [$u->query_form],
        [subject => q{x}, q{} => undef, to => q{"a b+c"@example.com}],
        q{empty and trailing segments do not misalign recipients};

    $u = URI->new(q{mailto:?&to=a+b@example.com;;subject=y});
    is_deeply [$u->query_form],
        [
        q{}     => undef,
        to      => q{a+b@example.com},
        q{}     => undef,
        subject => q{y},
        ],
        q{leading and doubled delimiters do not misalign recipients};
};

subtest q{query_form with encoded recipient field name} => sub {
    my $u = URI->new(
        q{mailto:?subject=first&%74%6f=%22foo%20bar+baz%22@example.com});
    is_deeply [$u->query_form],
        [subject => q{first}, to => q{"foo bar+baz"@example.com},],
        q{encoded recipient field name is recognized};

    my @old_headers = $u->headers(
        to      => q{"header space+tag"@example.com},
        subject => q{header subject+suffix}
    );
    is_deeply \@old_headers,
        [to => q{}, subject => q{first}, to => q{"foo bar+baz"@example.com},],
        q{headers setter returns previous decoded fields};
    is_deeply [$u->headers],
        [
        to      => q{"header space+tag"@example.com},
        subject => q{header subject+suffix},
        ],
        q{headers setter preserves quoted space and subject plus};
};

subtest q{reading does not mutate} => sub {
    my $u
        = URI->new(
        q{mailto:%22header%20space+tag%22@example.com?subject=header+subject%2Bsuffix}
        );
    my $before = "$u";
    my @read   = $u->headers;
    is "$u", $before, q{reading headers does not mutate URI};
    @read = $u->query_form;
    is "$u", $before, q{reading query_form does not mutate URI};
};

subtest q{query_form setter in void context} => sub {
    my $u = URI->new(q{mailto:?subject=x});
    $u->query_form(to => q{"void space+tag"@example.com});
    is_deeply [$u->query_form], [to => q{"void space+tag"@example.com}],
        q{query_form setter works in void context};
};

subtest q{query_form setter without recipient} => sub {
    my $u = URI->new(q{mailto:});
    $u->query_form(subject => q{only subject});
    is_deeply [$u->query_form], [subject => q{only subject}],
        q{query_form setter without recipient retains form behavior};
    is_deeply [$u->query_form([])], [subject => q{only subject}],
        q{empty setter returns old fields};
    ok !defined($u->query), q{empty setter removes query};
};

subtest q{clearing recipient} => sub {
    my $u = URI->new(q{mailto:old+tag@example.com?subject=keep#fragment});
    $u->to(q{"new space+tag"@example.com});
    is $u->fragment, q{fragment}, q{recipient setter retains fragment};
    $u->to(undef);
    is $u->to, q{}, q{undefined recipient clears recipient};
    is_deeply [$u->headers], [to => q{}, subject => q{keep}],
        q{clearing recipient retains other headers};
};

subtest q{queries without form fields} => sub {
    my $u = URI->new(q{mailto:});
    is_deeply [$u->query_form], [], q{missing query has no form fields};
    $u->query(q{});
    is_deeply [$u->query_form], [], q{empty query has no form fields};
    $u->query(q{keywords+only});
    is_deeply [$u->query_form], [], q{keyword query has no form fields};
};

# RFC 5321 (4.1.3) - Address Literals

subtest q{IPv4 address literal} => sub {
    my $u = URI->new(q{mailto:user@[127.0.0.1]});
    is $u->to, 'user@[127.0.0.1]',        'IPv4 host name';
    is $u,     'mailto:user@[127.0.0.1]', '... and stringification works';
};

subtest q{IPv6 address literal} => sub {
    my $u = URI->new(q{mailto:user@[IPv6:fe80::e828:209d:20e:c0ae]});
    is $u->to, q{user@[IPv6:fe80::e828:209d:20e:c0ae]}, q{IPv6 host name};
    is $u, 'mailto:user@[IPv6:fe80::e828:209d:20e:c0ae]',
        '... and stringification works';
};

done_testing();
