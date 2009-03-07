package Net::GitHub::Project;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::Project::Source;

does 'Net::GitHub::Role';


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
