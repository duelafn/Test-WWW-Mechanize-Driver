#!/usr/bin/perl
use strict; use warnings;
use lib qw/ t /;

use Test::More tests => 10;
use MyMechanize;
use Test::WWW::Mechanize::YAML;

my $tester = Test::WWW::Mechanize::YAML->new(
  mechanize => MyMechanize->new,
  disable_plan => 1,
);

ok( $tester->load( "t/00-basic.yml" ), "loading the tests" );# 8 tests
is( $tester->tests, 8, "test count is correct" );
$tester->run;
