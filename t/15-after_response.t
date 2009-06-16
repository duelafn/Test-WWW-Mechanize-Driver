#!/usr/bin/perl
#
# Test after_response feature:
#   * perform extra tests in after_response
#   * tests dynamic SKIP
#
use strict; use warnings;
use lib qw/ t /;

use MyMechanize;
use Test::WWW::Mechanize::Driver;

my $page_count = 0;
my $tester = Test::WWW::Mechanize::Driver->new(
  mechanize => MyMechanize->new,
  after_response => sub {
    my ($mech, $opt) = @_;
    $page_count++;
    isa_ok( $mech, 'MyMechanize', "first arg is Mechanize object" );
    is( ref($opt), 'HASH',        "second arg is options hash" );

    if ($$opt{my_skip_opt}) {
      $$opt{SKIP} = 'Skip tests due to "my_skip_opt" option';
    }
  },
  after_response_tests => 2,
  add_to_plan => 1,
);
$tester->mechanize->my_mech_load_files( glob("t/webpages/*.yml") );
$tester->run;

my $pages_expected = $tester->test_groups;
is( $pages_expected, $page_count,  'after_response called for each page' );
