#!/usr/bin/perl
use strict; use warnings;
use lib qw/ lib t /;

use Test::More tests => 11;
use MyMechanize;
use Test::WWW::Mechanize::Driver;

my $tester = Test::WWW::Mechanize::Driver->new(
  mechanize => MyMechanize->new,
  no_plan => 1,
);
$tester->mechanize->my_mech_load_files( glob("t/webpages/*.yml") );

is( $tester->load( "t/05-basic.yml" ), 8, "loading 8 tests" );
is( $tester->tests, 8, "test count is correct" );
is( $tester->test_groups, 3, "number of test groups is correct" );
$tester->run;
