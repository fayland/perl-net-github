package Net::GitHub::Project::Source;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::Role';

has 'commits' => (
    is  => 'rw',
    isa => 'ArrayRef',
    lazy_build => 1,
);
sub _build_commits {
    my $self = shift;
    
    my $url = 'http://github.com/api/v1/json/' . $self->owner . '/' . $self->name . '/commits/master';
    my $json = $self->get($url);
    my $commits = $self->json->jsonToObj($json);
    return $commits->{commits};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
