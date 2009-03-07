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

=head1 NAME

Net::GitHub::Project::Source - GitHub project Source Section

=head1 SYNOPSIS

    use Net::GitHub::Project::Source;

    my $src = Net::GitHub::Project::Source->new(
        owner => 'fayland', name => 'perl-net-github'
    );
    
    # get all commits
    my @commits = $src->commits;
    foreach my $c ( @commits ) {
        my $commit = $src->commit( $c->{id} );
    }

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item commits

recent commits

=item commit($id)

a detailed single commit

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.