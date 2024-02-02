#!perl

use strict;
use warnings;

use URI;
use Test::More tests => 24;

{
  ok my $guri = URI->new( 'geo:54.786989,-2.344214' ), 'created';
  isa_ok $guri, 'URI::geo';
  is $guri->scheme,    'geo',                     'scheme';
  is $guri->opaque,    '54.786989,-2.344214',     'opaque';
  is $guri->path,      '54.786989,-2.344214',     'path';
  is $guri->fragment,   undef,                    'fragment';
  is $guri->latitude,  54.786989,                 'latitude';
  is $guri->longitude, -2.344214,                 'longitude';
  is $guri->altitude,  undef,                     'altitude';
  is $guri->as_string, 'geo:54.786989,-2.344214', 'stringify';
  $guri->altitude( 120 );
  is $guri->altitude, 120, 'altitude set';
  is $guri->as_string, 'geo:54.786989,-2.344214,120',
   'stringify w/ alt';
  $guri->latitude( 55.167469 );
  $guri->longitude( -1.700663 );
  is $guri->as_string, 'geo:55.167469,-1.700663,120',
   'stringify updated w/ alt';
}

{
  ok my $guri = URI->new( 'geo:55.167469,-1.700663,120' ), 'created';
  my @loc = $guri->location;
  is_deeply [@loc], [ 55.167469, -1.700663, 120 ], 'got location';
}

{
  ok my $guri = URI->new( 'geo:-33,30' ), 'created';
  my @loc = $guri->location;
  is_deeply [@loc], [ -33, 30, undef ], 'got location';
}

{
  ok my $guri = URI->new( 'geo:-33,30,12.3;crs=wgs84;u=12' ), 'created';
  my @loc = $guri->location;
  is_deeply [@loc], [ -33, 30, 12.3 ], 'got location';
  is $guri->crs,         'wgs84', 'crs';
  is $guri->uncertainty, 12,      'u';

}

{
  eval { URI->new( 'geo:1' ) };
  like $@, qr/Badly formed/, 'error ok';
}

{
  ok( URI->new( 'geo:55,1' )->eq( URI->new( 'geo:55,1' ) ), 'eq 1' );
  ok( URI->new( 'geo:90,1' )->eq( URI->new( 'geo:90,2' ) ), 'eq 2' );
}

# vim:ts=2:sw=2:et:ft=perl

