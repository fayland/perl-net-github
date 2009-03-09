package Net::GitHub::Project::Source;

use Moose;

our $VERSION = '0.04';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::Role';
with 'Net::GitHub::Project::Role';

sub commits {
    my ( $self, $branch_name ) = @_;
    
    $branch_name ||= 'master';
    
    my $url = $self->project_api_url . "commits/$branch_name";
    my $json = $self->get($url);
    my $commits = $self->json->jsonToObj($json);
    return $commits->{commits};
}

sub commit {
    my ( $self, $id ) = @_;
    
    my $url = $self->project_api_url . "commit/$id";
    my $json = $self->get($url);
    my $commits = $self->json->jsonToObj($json);
    return $commits->{"commit"};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Project::Source - GitHub Project Source Section

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

    $src->commits;
    $src->commits( 'talks' );

recent commits of a branch, default as 'master'.

if you need a branch other than 'master' (like http://github.com/nothingmuch/kiokudb/tree/talks), you need pass 'talks' in.

=item commit($id)

a detailed single commit

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.