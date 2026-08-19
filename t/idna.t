use strict;
use warnings;

use utf8;
use Test::More;
use URI::_idna ();

is URI::_idna::encode("www.example.com"),  "www.example.com";
is URI::_idna::decode("www.example.com"),  "www.example.com";
is URI::_idna::encode("www.example.com."), "www.example.com.";
is URI::_idna::decode("www.example.com."), "www.example.com.";
is URI::_idna::encode("Bücher.ch"),        "xn--bcher-kva.ch";
is URI::_idna::decode("xn--bcher-kva.ch"), "bücher.ch";
is URI::_idna::decode("xn--bcher-KVA.ch"), "bücher.ch";

# nameprep must NFC-normalize a label before punycode encoding: a non-NFC
# label otherwise encodes to a non-standard A-label that a security check and
# the eventual fetch can disagree about.
is URI::_idna::encode(chr(0x0958) . chr(0x093E)), "xn--11b2fg",
    "precomposed Devanagari sequence is NFC-normalized before encoding";

# The correct (NFC) A-label decodes and re-encodes back to itself.
is URI::_idna::encode(URI::_idna::decode("xn--11b2fg")), "xn--11b2fg",
    "NFC A-label round-trips through decode/encode";

# The non-normalized precomposed A-label for the same name must be rejected
# rather than silently decoded, so it can never stand in for the NFC host.
my $exception = do {
    local $@;
    eval { URI::_idna::decode("xn--72b5c") };
    $@;
};
like $exception, qr/does not round-trip/,
    "non-NFC A-label is rejected on decode";

done_testing;
