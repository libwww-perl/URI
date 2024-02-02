#!perl

use strict;
use warnings;

use URI::geo;
use Test::More;

eval { require Geo::Point };

plan skip_all => 'Needs Geo::Point' if $@;
plan tests => 5;

ok my $pt = Geo::Point->latlong( 48.208333, 16.372778 ), 'point';
ok my $guri = URI::geo->new( $pt ), 'uri';

is $guri->latitude,  48.208333, 'latitude';
is $guri->longitude, 16.372778, 'longitude';
is $guri->altitude,  undef,     'altitude';

# vim:ts=2:sw=2:et:ft=perl

