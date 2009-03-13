package Test::WWW::Mechanize::YAML;
use Carp; use strict; use warnings;
our $VERSION = 0.5;


=pod

=head1 NAME

Test::WWW::Mechanize::YAML - Drive Test::WWW::Mechanize Object Using YAML Configuration Files

=head1 SYNOPSIS

 use strict;
 use Test::WWW::Mechanize::YAML;

=head1 DESCRIPTION

Write Test::WWW::Mechanize tests in YAML. This module will load the tests
make a plan and run the tests. Supports every-page tests, SKIP, TODO, and
any object supporting the Test::WWW::Mechanize interface.

=head1 USAGE

=cut




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
