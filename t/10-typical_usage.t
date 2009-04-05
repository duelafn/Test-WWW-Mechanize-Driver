#!/usr/bin/perl
use strict; use warnings;
use lib qw/ t /;

use MyMechanize;
use Test::WWW::Mechanize::Driver;

my $tester = Test::WWW::Mechanize::Driver->new(
  mechanize => MyMechanize->new,
  load => [ glob("t/10-typical_usage*.yml") ],
);

$tester->run;
