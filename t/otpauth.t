#!perl

use strict;
use warnings;

use URI;
use Test::More tests => 90;

{
  my $uri = URI->new( 'otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example' );
  ok $uri,                                                                          "created $uri";
  isa_ok $uri, 'URI::otpauth';
  is $uri->type(),    'totp',                                                       'type';
  is $uri->label(),   'Example:alice@google.com',                                   'label';
  is $uri->issuer(),  'Example',                                                    'issuer';
  is $uri->secret(),  'Hello!' . (chr 0xDE) . (chr 0xAD) . (chr 0xBE) . (chr 0xEF), 'secret';
  is $uri->counter(),   undef,                                                      'counter';
  is $uri->algorithm(), 'SHA1',                                                     'algorithm';
  is $uri->digits(),  6,                                                            'digits';
  is $uri->period(),  30,                                                           'period';
  is $uri->fragment(),   undef,                                                     'fragment';
  my $new_secret = 'this_is_really secret!';
  $uri->secret($new_secret);
  my $new_uri = URI->new( "$uri" );
  ok $new_uri,                                                                          "created $new_uri";
  isa_ok $new_uri, 'URI::otpauth';
  unlike $new_uri, qr/secret=$new_secret/,                                              'no clear text secret';
  is $new_uri->type(),    'totp',                                                       'type';
  is $new_uri->label(),   'Example:alice@google.com',                                   'label';
  is $new_uri->account_name(),  'alice@google.com',                                     'account_name';
  is $new_uri->issuer(),  'Example',                                                    'issuer';
  is $new_uri->secret(),  $new_secret,                                                  'secret';
  is $new_uri->counter(),   undef,                                                      'counter';
  is $new_uri->algorithm(), 'SHA1',                                                     'algorithm';
  is $new_uri->digits(),  6,                                                            'digits';
  is $new_uri->period(),  30,                                                           'period';
  is $new_uri->fragment(),   undef,                                                     'fragment';
  my $next_uri = URI->new( 'otpauth://totp/alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example&digits=8&algorithm=SHA256' );
  ok $next_uri,                                                                          "created $next_uri";
  isa_ok $next_uri, 'URI::otpauth';
  is $next_uri->type(),    'totp',                                                       'type';
  is $next_uri->label(),   'Example:alice@google.com',                                   'label';
  is $next_uri->account_name(),  'alice@google.com',                                     'account_name';
  is $next_uri->issuer(),  'Example',                                                    'issuer';
  is $next_uri->secret(),  'Hello!' . (chr 0xDE) . (chr 0xAD) . (chr 0xBE) . (chr 0xEF), 'secret';
  is $next_uri->counter(),   undef,                                                      'counter';
  is $next_uri->algorithm(), 'SHA256',                                                   'algorithm';
  is $next_uri->digits(),  8,                                                            'digits';
  is $next_uri->period(),  30,                                                           'period';
  is $next_uri->fragment(),   undef,                                                     'fragment';
  my $issuer_uri = URI->new( 'otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP' );
  ok $issuer_uri,                                                                          "created $issuer_uri";
  isa_ok $issuer_uri, 'URI::otpauth';
  is $issuer_uri->type(),    'totp',                                                       'type';
  is $issuer_uri->label(),   'Example:alice@google.com',                                   'label';
  is $issuer_uri->account_name(),  'alice@google.com',                                     'account_name';
  is $issuer_uri->issuer(),  'Example',                                                    'issuer';
  is $issuer_uri->secret(),  'Hello!' . (chr 0xDE) . (chr 0xAD) . (chr 0xBE) . (chr 0xEF), 'secret';
  is $issuer_uri->counter(),   undef,                                                      'counter';
  is $issuer_uri->algorithm(), 'SHA1',                                                     'algorithm';
  is $issuer_uri->digits(),  6,                                                            'digits';
  is $issuer_uri->period(),  30,                                                           'period';
  is $issuer_uri->fragment(),   undef,                                                     'fragment';
  my $issuer2_uri = URI->new( 'otpauth://hotp/Example2:alice@google.com?&issuer=Example2&counter=23&period=15' );
  ok $issuer2_uri,                                                                          "created $issuer2_uri";
  isa_ok $issuer2_uri, 'URI::otpauth';
  is $issuer2_uri->type(),    'hotp',                                                       'type';
  is $issuer2_uri->label(),   'Example2:alice@google.com',                                  'label';
  is $issuer2_uri->issuer(),  'Example2',                                                   'issuer';
  is $issuer2_uri->secret(),   undef,                                                       'secret';
  is $issuer2_uri->counter(),   23,                                                      'counter';
  is $issuer2_uri->algorithm(), 'SHA1',                                                     'algorithm';
  is $issuer2_uri->digits(),  6,                                                            'digits';
  is $issuer2_uri->period(),  15,                                                           'period';
  is $issuer2_uri->fragment(),   undef,                                                     'fragment';
}

# vim:ts=2:sw=2:et:ft=perl

my @case = (
  {
    name => 'Hotp',
    args => { secret => "topsecret", type => 'hotp', issuer => 'Foo', counter => 6, account_name => 'bob@example.com' },
    secret  => "topsecret",
    type => 'hotp',
    issuer => 'Foo',
    account_name => 'bob@example.com',
    counter => 6,
    algorithm => 'SHA1',
    period => 30,
  },
  {
    name => 'Only Account Name',
    args => { secret => "justabunchofstuff", account_name => 'alice@example.org', algorithm => 'SHA512', period => 7 },
    secret  => "justabunchofstuff",
    type => 'totp',
    issuer => undef,
    account_name => 'alice@example.org',
    counter => undef,
    algorithm => 'SHA512',
    period => 7,
  },
  {
    name => 'Only mandatory',
    args => { secret => "justabunchofstuff" },
    secret  => "justabunchofstuff",
    type => 'totp',
    issuer => undef,
    account_name => undef,
    counter => undef,
    algorithm => 'SHA1',
    period => 30,
  },
);

for my $case ( @case ) {
  my ( $name, $args, $secret, $type, $issuer, $account_name, $counter, $algorithm, $period, $frag )
   = @{$case}{ qw(name args secret type issuer account_name counter algorithm period frag) };

  my $uri = URI::otpauth->new( %$args );
  ok $uri, "created $uri";
  is $uri->scheme(), 'otpauth', "$name: scheme";
  is $uri->type(),  $type, "$name: type";
  is $uri->authority(),  $type, "$name: authority";
  is $uri->secret(), $secret, "$name: secret";
  is $uri->issuer(),  $issuer, "$name: issuer";
  if (defined $issuer) {
    is $uri->label(),  (join q[:], $issuer, $account_name), "$name: label";
  }
  is $uri->algorithm(), $algorithm, "$name: algorithm";
  is $uri->counter(),  $counter, "$name: counter";
  is $uri->period(),  $period, "$name: period";
}

eval {
  URI::otpauth->new( type => 'totp' );
};
like $@, qr/^secret is a mandatory parameter for URI::otpauth/,   "missing secret";
my $doc1_uri = URI->new( 'otpauth://totp/Example:alice@google.com?secret=NFZS25DINFZV643VOAZXELLTGNRXEM3UH4&issuer=Example' );
my $doc2_uri = URI::otpauth->new( type => 'totp', issuer => 'Example', account_name => 'alice@google.com', secret => 'is-this_sup3r-s3cr3t?' );
is "$doc1_uri", "$doc2_uri", "$doc1_uri: matches";

is $doc1_uri->type(), $doc2_uri->authority(), "type and authority match";
