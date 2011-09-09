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

    my $github_commits = Net::GitHub::V2::Commits->new(
        owner => 'fayland',            # GitHub username/organisation
        repo  => 'perl-net-github',    # Repository name
    );

=head1 DESCRIPTION

L<http://develop.github.com/p/commits.html>

See also L<Net::GitHub> for how to create a L<Net::GitHub> object with the
appropriate attributes, then get a C<Net::GitHub::V2::Commits> object from it
easily.


=head1 METHODS

=over 4

=item branch

    my $commits = $github_commits->branch(); # default as 'master'
    my $commits = $github_commits->branch('v2');

list commits for a branch

=item file($branch, $file)

    my $commits = $github_commits->file( 'master', 'lib/Net/GitHub.pm' );
    my $commits = $github_commits->file( 'lib/Net/GitHub.pm' ); # the same as above

get all the commits that modified the file (default $branch to 'master')

=item show

    my $commit = $github_commits->show( '9bd63ae2114e3c7e4279b81ab2d8d8947ab4011d' );

get the changes introduced on a specific commit

(As usual, the SHA can be abbreviated)

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
