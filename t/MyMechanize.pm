package MyMechanize;
use strict; use warnings;
use base qw/WWW::Mechanize/;
require YAML;

# a shared cache (over all Mech objects) will work just fine
my %cache;

# $x->my_mech_load_files( @files )
#
# fill (global) cache with data from given files
sub my_mech_load_files {
  my $x = shift;
  for (@_) {
    my ($meta, $res) = YAML::LoadFile($_) || die "YAML Load Error";
    $$meta{response} = $res;

    $$meta{uri} = [$$meta{uri}] unless ref($$meta{uri});

    # many uris may refer to the same cached page
    $cache{$_} = $meta for @{$$meta{uri}};
  }
}


sub _make_request {
  my $x = shift;
  my $req = shift;
  my $uri = $req->uri;

  die "Request uri '$uri' does not exist in cache\n" unless exists $cache{$uri};
  return HTTP::Response->parse( $cache{$uri}{response} );
}


1;
