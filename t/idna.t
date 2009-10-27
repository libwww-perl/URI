#!perl -w

use strict;
use utf8;
use Test::More tests => 6;
use URI::_idna;

is URI::_idna::encode("www.example.com"), "www.example.com";
is URI::_idna::decode("www.example.com"), "www.example.com";
is URI::_idna::encode("www.example.com."), "www.example.com.";
is URI::_idna::decode("www.example.com."), "www.example.com.";
is URI::_idna::encode("Bücher.ch"), "xn--bcher-kva.ch";
is URI::_idna::decode("xn--bcher-kva.ch"), "bücher.ch";
