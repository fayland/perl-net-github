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
    
    my $url = $self->api_url . $self->owner . '/' . $self->name . '/commits/master';
    my $json = $self->get($url);
    my $commits = $self->json->jsonToObj($json);
    return $commits->{commits};
}

sub commit {
    my ( $self, $id ) = @_;
    
    my $url = $self->api_url . $self->owner . '/' . $self->name . "/commit/$id";
    my $json = $self->get($url);
    my $commits = $self->json->jsonToObj($json);
    return $commits->{"commit"};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
