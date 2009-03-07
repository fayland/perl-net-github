package Net::GitHub::Project::Source;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

does 'Net::GitHub::Role';


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
