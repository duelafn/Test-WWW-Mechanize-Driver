package Test::WWW::Mechanize::Driver;
use Carp; use strict; use warnings;
use Test::WWW::Mechanize::Driver::YAMLLoader;
use Test::WWW::Mechanize::Driver::Util qw/ cat TRUE HAS /;
use Test::Builder;
use List::Util qw/sum/;
my $Test = Test::Builder->new;
our $VERSION = 0.5;
our $TODO;

=pod

=head1 NAME

Test::WWW::Mechanize::Driver - Drive Test::WWW::Mechanize Object Using YAML Configuration Files

=head1 SYNOPSIS

 use strict; use warnings;
 use Test::WWW::Mechanize::Driver;
 Test::WWW::Mechanize::Driver->new(
   load => [ glob( "t/*.yaml" ) ]
 )->run;


 use strict; use warnings;
 use Test::WWW::Mechanize::Driver;
 Test::WWW::Mechanize::Driver->new->run; # runs basename($0)*.{yaml.yml,dat}

=head1 DESCRIPTION

Write Test::WWW::Mechanize tests in YAML. This module will load the tests
make a plan and run the tests. Supports every-page tests, SKIP, TODO, and
any object supporting the Test::WWW::Mechanize interface.

=head1 USAGE

=head3 new

=over 4

=item mechanize

Override default mechanize object. The default object is:

 Test::WWW::Mechanize->new(cookie_jar => {})

=item no_plan

When true, calling C<-E<gt>run> will not print a test plan.

=item loader

Name of loader package or object with C<package-E<gt>load( $file )> method.
Defaults to C<Test::WWW::Mechanize::Driver::YAMLLoader>.

=back

=cut

sub new {
  my $class = shift;
  my %x = @_;
  # Create object so that "require YAML" happens early on
  $x{loader} ||= Test::WWW::Mechanize::Driver::YAMLLoader->new;
  bless \%x, $class;
}

=head3 load

 $x->load( @yaml_test_filenames )

Load additional tests.

=cut

sub load {
  my $x = shift;
  push @{$$x{load}}, @_;
  my $t = $x->tests;
  $x->_load;
  $x->tests - $t;
}

=head3 tests

Calculate number of tests currently loaded

=cut

sub tests {
  my $x = shift;
  return 0 unless $$x{groups};
  my $tests = sum(map 0+@{$$_{actions}}, @{$$x{groups}});
  $tests += 1 * @{$$x{groups}};
  return $tests;
}

=head3 run

Run each group of tests

=cut

sub run {
  my $x = shift;
  die "No test groups!" unless $$x{groups};
  $x->_run_group( $_ ) for @{$$x{groups}};
}

=head3 mechanize

Return or construct mechanize object

=cut

sub mechanize {
  my $x = shift;
  $$x{mechanize} ||= Test::WWW::Mechanize->new(cookie_jar => {});
}


=head3 _run_group

Run a group of tests

=cut

sub _run_group {
  my ($x, $group) = @_;

  if ($$group{SKIP}) {
    $Test->skip($$group{SKIP}) for "get", @{$$group{actions}};
    return;
  }

  local $TODO = $$group{TODO};
  $x->mechanize->get_ok( $$group{uri}, $x->_test_label("get $$group{uri}", @{$$group{id}}) );
  $x->_run_test( $group, $_ ) for @{$$group{actions}};
}

=head3 _run_test

Run an individual test

=cut

sub _run_test {
  my ($x, $group, $test) = @_;

  if ($$test{sub}) {
    return $$test{sub}->();
  }

  my $t = $$test{name};
  $x->mechanize->$t( @{$$test{args}} );
}

=head3 _load

 $x->_load()

Open test file and attempt to load each contained document. Each testfile
is loaded only once.

=cut

sub _load {
  my $x = shift;
  return unless $$x{load};

  for my $file (@{$$x{load}}) {
    next if $$x{_loaded}{$file}++;
    $x->_clear_local_config;
    my @docs = eval { $$x{loader}->load( $file ) };
    die "While parsing test file '$file':\n$@" if $@;

    my $document = 1;
    $x->_load_doc( $_, [$file, $document++] ) for @docs;
  }
}

=head3 _load_doc

Determine document type and hand off to appropriate loaders.

=cut

sub _load_doc {
  my ($x, $doc, $id) = @_;

  if (!ref($doc)) {
    return 1;
  }

  elsif ('HASH' eq ref($doc)) {
    $x->_push_local_config($doc);
  }

  elsif ('ARRAY' eq ref($doc)) {
    my $test = 1;
    $x->_load_group($_, [@$id, $test++]) for @$doc;
  }

  else {
    die "Unknown document type ".ref($doc);
  }
}

=head3 _load_test

Actually perform test "loading". As tests are loaded the they are:

 * canonicalized: all tests moved to actions array with one test per entry
 * tallied: tallies are kept in the master object
 * tagged: the test's location in the file is inserted into the test hash

=cut

our %config_options = map +($_,1),
qw/

method
uri
url

/;

our %scalar_tests = map +($_,1),
qw/
    title_is title_like title_unlike
    base_is base_like base_unlike
    content_is content_contains content_lacks content_like content_unlike
    page_links_content_like page_links_content_unlike
    links_ok
/;

our %aliases =
qw/
    is          content_is
    contains    content_contains
    lacks       content_lacks
    like        content_like
    unlike      content_unlike
/;

our %bool_tests = map +($_,1), qw/ page_links_ok /;
our %hash_tests = map +($_,1), qw/ submit_form_ok stuff_inputs /;
our %mech_action = map +($_,1),
qw/
    get put reload back follow_link form_number form_name
    form_with_fields field select set_fields set_visible tick untick
    click click_button submit submit_form add_header delete_header
    save_content dump_links dump_images dump_forms dump_all redirect_ok
    request credentials
/;

sub _load_group {
  my ($x, $group, $id) = @_;

  # We're all about convenience here, I want to be able to perform simple
  # contains tests without setting up an "actions" sequence. To do that, we
  # need to munge the group hash a bit.
  my @keys = keys %$group;
  my @actions;
  for (@keys) {
    # the actual "sctions" element, pushed to end of actions array so it
    # happens after the toplevel actions.
    if ($_ eq 'actions') { push @actions, @{delete $$group{actions}} }

    # leave internal configuration options where they are
    elsif (TRUE \%config_options, $_) { next; }

    # Put anything that looks like a test action on the front of the action list.
    elsif (TRUE( \%scalar_tests, $_ )
        or TRUE( \%bool_tests, $_ )
        or TRUE( \%hash_tests, $_ )
        or TRUE( \%mech_action, $_ )
        or TRUE( \%aliases, $_ )
        or $x->mechanize->can($_)
          ) { unshift @actions, { name => $_, args => delete $$group{$_}, _transplant => 1 } }

    # anything else is considered a custom config value and will be
    # preserved in the top level group hash.
  }

  # accept misspellings
  $$group{uri} ||= delete $$group{url};

  $$group{id} = $id;
  $$group{actions} = $x->_prepare_actions( $group, \@actions, $id );
  push @{$$x{groups}}, $group;
}

=head3 _prepare_actions

 $x->_prepare_actions( group_hashref, actions_arrayref, id_arrayref )

Prepare array of actions by:

 * expanding argument lists
 * insert get_ok tests

=cut

sub _prepare_actions {
  my ($x, $group, $actions, $id) = @_;
  my @expanded;

  my $action = 1;
  for my $a (@$actions) {
    $$a{name} = $aliases{$$a{name}} if HAS( \%aliases, $$a{name} );

    # Handle Template variables!
    # my ($mech, %o, $t) = expand_tmpl(@_);

    # RECURSE!
    # if ($$a{name} eq 'actions') { }

    push @expanded, $x->_expand_tests($group, $a, [@$id, $action++])
  }

  return \@expanded;
}

sub _test_label {
  my ($x, $name, $file, $doc, $group, @id) = @_;
  local $" = '.';
  "$name: file $file, doc $doc, group $group, test @id"
}

sub _expand_tests {
  my ($x, $group, $action, $id) = @_;
  my $name = $$action{name};
  my $args = $$action{args};
  my $test = 'a';

  # SCALAR TESTS
  if (TRUE( \%scalar_tests, $name )) {
    return map
      +{ %$action, args => [(($name =~ /_like$/) ? qr/$_/ : $_), $x->_test_label($name, @$id, $test)], id => [@$id, $test++] },
        ('ARRAY' eq ref($args)) ? @$args : $args;
  }

  # HASH TESTS
  if (TRUE( \%hash_tests, $name )) {
    my @tests;
    $$action{id} = [@$id, $test++];
    $$action{args} = [$$action{args}, $x->_test_label($name, @{$$action{id}})];
    push @tests, $action;
    push @tests, $x->_every_get_test([@$id, $test++]) if $$x{every_get};
    return @tests;
  }

  # BOOLEAN TESTS
  if (TRUE( \%bool_tests, $name )) {
    $$action{id} = $id;
    $$action{args} = [ $x->_test_label($name, @$id) ];
    return $action;
  }

  # MECHANIZE ACTIONS
  if (TRUE( \%mech_action, $name )) {
    $$action{id} = $id;
    $$action{sub} = sub {
      $x->mechanize->$name( ('ARRAY' eq ref($args)) ? @$args
                          : ('HASH'  eq ref($args)) ? %$args
                          : $args
                          );
      # plain mechanize actions don't report "ok". Force a passing test
      # since we take an action spot.
      local $Test::Builder::Level = $Test::Builder::Level + 2;
      $Test->ok(1, "$name mechanize action");
    };
    return $action;
  }
}




=head3 _clear_local_config

Configs local to a series of test documents are cleared after each file is
loaded.

=cut

sub _clear_local_config {
  my $x = shift;
  $$x{_local_config} = {};
}

=head3 _push_local_config

Merge a new configuration into the local configuration. called for each
hash document in a test configuration file.

=cut

sub _push_local_config {
  my ($x, $config) = @_;
  $$x{_local_config} = $config;
}





1;

=head1 AUTHOR

The original version of this code written by Dean Serenevy while under
contract with National Financial Management who graciously allowed me to
release it to the public.

 Dean Serenevy
 dean@serenevy.net
 http://dean.serenevy.net/

=head1 LICENSE

This software is hereby placed into the public domain. If you use this
code, a simple comment in your code giving credit and an email letting
me know that you find it useful would be courteous but is not required.

The software is provided "as is" without warranty of any kind, either
expressed or implied including, but not limited to, the implied warranties
of merchantability and fitness for a particular purpose. In no event shall
the authors or copyright holders be liable for any claim, damages or other
liability, whether in an action of contract, tort or otherwise, arising
from, out of or in connection with the software or the use or other
dealings in the software.

=head1 SEE ALSO

L<WWW::Mechanize>, L<Test::WWW::Mechanize>

=cut
