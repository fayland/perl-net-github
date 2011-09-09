package Net::GitHub::V2::Commits;

use Any::Moose;

our $VERSION = '0.13';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::HasRepo';

sub branch {
    my ( $self, $branch ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    $branch ||= 'master';
    return $self->get_json_to_obj( "commits/list/$owner/$repo/$branch", 'commits' );
}

sub file {
    my ( $self, $branch, $path ) = @_;
    
    unless ( $path ) {
        $path = $branch;
        $branch = 'master';
    }

    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "commits/list/$owner/$repo/$branch/$path", 'commits' );
}

sub show {
    my ( $self, $sha1 ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "commits/show/$owner/$repo/$sha1", 'commit' );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V2::Commits - GitHub Commits API

=head1 SYNOPSIS

    use Net::GitHub::V2::Commits;

    my $commit = Net::GitHub::V2::Commits->new(
        owner => 'projectowner',   # GitHub username/organisation
        repo  => 'repo-name',      # Repository name
    );

=head1 DESCRIPTION

L<http://develop.github.com/p/commits.html>

=head1 METHODS

=over 4

=item branch

    my $commits = $commit->branch(); # default as 'master'
    my $commits = $commit->branch('v2');

list commits for a branch

=item file($branch, $file)

    my $commits = $commit->file( 'master', 'lib/Net/GitHub.pm' );
    my $commits = $commit->file( 'lib/Net/GitHub.pm' ); # the same as above

get all the commits that modified the file (default $branch to 'master')

=item show

    my $co_detail = $commit->show( '0e2e9d452f807f4b7138ae707e84577c10891d0c' );

get the changes introduced on a specific commit

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
