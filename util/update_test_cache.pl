#!/usr/bin/perl
use strict; use warnings;

# Utility script to create/update test caches so that test suite can run
# without an active internet connection (and without relying on active
# webpages containing any particular content).
#
# You should not need this script.

use YAML;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new;

update_file($ua, $_) for @ARGV;

# Cached webpage yaml streams consist of two documents:
#
# 1. metadata (will be preserved by this script)
# 2. HTTP::Response string
#
# The purpose of this script is to update HTTP::Response portion


# update_file( LWP_Agent, filename )
#
# Replaces second YAML data document (in filename) with updated version of
# the web page. Preserves all formatting of metadata (first) document. Any
# other documents in the stream are killed!
sub update_file {
  my ($ua, $file) = @_;
  my $file_info = load_file($file);
  my $meta = $$file_info{meta};

  die "No 'request' attribute in '$file'\n" unless $$meta{request};

  $$meta{request} = [GET => $$meta{request}] unless ref $$meta{request};
  my $req = HTTP::Request->new( @{$$meta{request}} );
  my $res = $ua->request($req);

  # We may want some failures in the tests, but we will still warn if the
  # request was not a success.
  warn "File '$file' returned status ".($res->status_line)."\n" unless $res->is_success;

  dump_file( $file_info, $res );
}

# load_file( filename )
#
# Load and split, creates hashref:
#
#   file: the filename
#   meta: parsed metadata in file
#   meta_text: string form of metadata
sub load_file {
  my $file = shift;
  my $data = cat($file);
  my ($meta, $res) = split /^--- \|$/m, $data;
  die "Invalid file '$file', missing page\n" unless $res;

  my %data = ( meta_text => $meta, file => $file );
  $data{meta} = Load $meta;
  die "Invalid metadata in file '$file'\n" unless $data{meta};
  return \%data;
}

# dump_file( file_info_hashref, HTTP_response )
#
# dumps metadata and HTTP::Response info to file
sub dump_file {
  my ($data, $res) = @_;
  fprint( $$data{file}, $$data{meta_text}, "--- |\n", $res->as_string );
}

# cat( filename )
#
# slurp file
sub cat {
  my $f = shift;
  open my $F, "<", $f or die "Can't open $f for reading: $!";
  local $/ = undef;
  my $x = <$F>;
  close $F;
  return $x;
}

# fprint( filename, @data )
#
# prints data to file, overwriting if necessary
sub fprint {
  my $f = shift;
  open my $F, ">", $f or die "Can't open $f for writing: $!";
  print $F @_;
  close $F;
}
