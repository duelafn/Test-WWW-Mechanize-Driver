package Test::WWW::Mechanize::Driver::Util;
use Carp; use strict; use warnings;
our $VERSION = 0.1;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS;
our @EXPORT_OK = qw/ cat TRUE HAS /;
$EXPORT_TAGS{all} = \@EXPORT_OK;

=pod

=head1 NAME

Test::WWW::Mechanize::Driver::Util - Useful utilities ripped from Dean::Util

=head1 USAGE

=cut

use Dean::Util qw/ INCLUDE_POD cat TRUE HAS /;

1;

=head1 AUTHOR

 Dean Serenevy
 dean@serenevy.net
 http://dean.serenevy.net/

=head1 COPYRIGHT

This software is hereby placed into the public domain. If you use this
code, a simple comment in your code giving credit and an email letting me
know that you find it useful would be courteous but is not required.

The software is provided "as is" without warranty of any kind, either
expressed or implied including, but not limited to, the implied warranties
of merchantability and fitness for a particular purpose. In no event shall
the authors or copyright holders be liable for any claim, damages or other
liability, whether in an action of contract, tort or otherwise, arising
from, out of or in connection with the software or the use or other
dealings in the software.

=head1 SEE ALSO

perl(1).

=cut
