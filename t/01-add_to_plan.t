#!/usr/bin/perl
use strict; use warnings;
use lib qw/ t /;

use Test::More qw(no_plan);
use MyMechanize;
use Test::WWW::Mechanize::YAML;

my $tester = Test::WWW::Mechanize::YAML->new(
  mechanize => MyMechanize->new,
  add_to_plan => 3,
);


$tester->load( "t/00-basic.yml" );# 8 tests

print $tester->plan;

is( 1 + 1, 2, "I always wanted to test that" );

is( $tester->tests, 12, "test count is correct" );

$tester->run;

ok( 1, "a silly extra test" );
