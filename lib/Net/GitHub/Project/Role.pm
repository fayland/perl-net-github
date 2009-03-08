package Net::GitHub::Project::Role;

use Moose::Role;

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

# http://github.com/fayland/perl-net-github/tree/master
has 'owner' => ( isa => 'Str', is => 'rw' );
has 'name'  => ( isa => 'Str', is => 'rw' );

sub args_to_pass {
    my $self = shift;
    my $ret;
    foreach my $col ('owner', 'name' ) {
        $ret->{$col} = $self->$col;
    }
    return $ret;
}

no Moose::Role;

1;
__END__
