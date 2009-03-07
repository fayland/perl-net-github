package Net::GitHub::Repository::Source;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

has 'username' => ( isa => 'Str', is => 'ro', required => 1 );
has 'password' => ( isa => 'Str', is => 'rw' );
has 'project'  => ( isa => 'Str', is => 'ro', required => 1 );


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
