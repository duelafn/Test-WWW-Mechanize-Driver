#!/usr/bin/perl
use strict; use warnings;
use lib qw/ t /;

use Test::More;
use MyMechanize;
use Test::WWW::Mechanize::Driver;

my $tester = Test::WWW::Mechanize::Driver->new(
  mechanize => MyMechanize->new,
  add_to_plan => 3,
  first_test => 3,
  load => "t/05-basic.yml", # 8 tests
);

plan tests => 12;

is( 1 + 1, 2, "I always wanted to test that" );

is( $tester->tests, 12, "test count is correct" );

$tester->run;

ok( 1, "a silly extra test" );
