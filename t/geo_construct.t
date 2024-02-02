#!perl

use strict;
use warnings;

use URI::geo;
use Test::More;
use Data::Dumper;

package Pointy;

sub new {
  my ( $class, $lat, $lon, $alt ) = @_;
  return bless { lat => $lat, lon => $lon, alt => $alt }, $class;
}

sub lat { shift->{lat} }
sub lon { shift->{lon} }
sub alt { shift->{alt} }

package Pointy::Point;

our @ISA = qw( Pointy );

sub latlong {
  my $self = shift;
  return $self->{lat}, $self->{lon};
}

package main;

my @case = (
  {
    name => 'Simple',
    args => [ 54.786989, -2.344214 ],
    lat  => 54.786989,
    lon  => -2.344214,
    alt  => undef,
  },
  {
    name => 'Simple w/ alt',
    args => [ 54.786989, -2.344214, 120 ],
    lat  => 54.786989,
    lon  => -2.344214,
    alt  => 120,
  },
  {
    name => 'Array',
    args => [ [ 54.786989, -2.344214 ] ],
    lat  => 54.786989,
    lon  => -2.344214,
    alt  => undef,
  },
  {
    name => 'Hash, short names',
    args => [ { lat => 54.786989, lon => -2.344214 } ],
    lat  => 54.786989,
    lon  => -2.344214,
    alt  => undef,
  },
  {
    name => 'Hash, long names',
    args => [
      {
        latitude  => 54.786989,
        longitude => -2.344214,
        elevation => 3
      }
    ],
    lat => 54.786989,
    lon => -2.344214,
    alt => 3,
  },
  {
    name => 'Point object',
    args => [ new Pointy( 54.786989, -2.344214, 3 ) ],
    lat  => 54.786989,
    lon  => -2.344214,
    alt  => 3,
  },
  {
    name => 'Point object',
    args => [ new Pointy::Point( 54.786989, -2.344214 ) ],
    lat  => 54.786989,
    lon  => -2.344214,
    alt  => undef,
  },
  {
    name => 'URI::geo object',
    args => [ new URI::geo( 54.786989, -2.344214, 99 ) ],
    lat  => 54.786989,
    lon  => -2.344214,
    alt  => 99,
  },
);

plan tests => @case * 5;

for my $case ( @case ) {
  my ( $name, $args, $lat, $lon, $alt )
   = @{$case}{ 'name', 'args', 'lat', 'lon', 'alt' };

  ok my $guri = URI::geo->new( @$args ), "$name: created";
  is $guri->scheme, 'geo', "$name: scheme";
  is $guri->latitude,  $lat, "$name: latitude";
  is $guri->longitude, $lon, "$name: longitude";
  is $guri->altitude,  $alt, "$name: altitude";
}

# vim:ts=2:sw=2:et:ft=perl

