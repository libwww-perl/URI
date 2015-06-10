use strict;
use warnings;

use utf8;
use Test::More tests => 7;
use URI::_idna;

is URI::_idna::encode("www.example.com"), "www.example.com";
is URI::_idna::decode("www.example.com"), "www.example.com";
is URI::_idna::encode("www.example.com."), "www.example.com.";
is URI::_idna::decode("www.example.com."), "www.example.com.";
is URI::_idna::encode("Bücher.ch"), "xn--bcher-kva.ch";
is URI::_idna::decode("xn--bcher-kva.ch"), "bücher.ch";
is URI::_idna::decode("xn--bcher-KVA.ch"), "bücher.ch";
