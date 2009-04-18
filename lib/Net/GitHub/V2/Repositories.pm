package Net::GitHub::V2::Repositories;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::Role';

sub search {
    my ( $self, $word ) = @_;
    
    return $self->get_json_to_obj( 'repos/search/' . uri_escape($word) );
}

sub show {
    my ( $self, $owner, $repo ) = @_;
    
    $owner ||= $self->owner;
    $repo  ||= $self->repo;
    
    return $self->get_json_to_obj( "repos/show/$owner/$repo" );
}

sub list {
    my ( $self, $owner ) = @_;
    
    $owner ||= $self->owner;
    
    return $self->get_json_to_obj( "repos/show/$owner" );
}

sub watch {
    my ( $self ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/watch/$owner/$repo" );
}
sub unwatch {
    my ( $self ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/unwatch/$owner/$repo" );
}

sub fork {
    my ( $self ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/fork/$owner/$repo" );
}

sub create {
    my ( $self, $name, $desc, $homepage, $is_public ) = @_;
    
    return $self->get_json_to_obj_authed( 'repos/create',
        name => $name,
        description => $desc,
        homepage => $homepage,
        public => $is_public
    );
}

sub delete {
    my ( $self, $opts ) = @_;
    
    my $repo  = $self->repo;
    
    my $delete_token = $self->get_json_to_obj_authed( "repos/delete/$repo" );
    if ( $opts->{confirm} ) {
        return $self->get_json_to_obj_authed( "repos/delete/$repo",
            delete_token => $delete_token
        );
    } else {
        return $delete_token;
    }
}

sub set_private {
    my ( $self ) = @_;
    
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/set/private/$repo" );
}
sub set_public {
    my ( $self ) = @_;
    
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/set/public/$repo" );
}

sub deploy_keys {
    my ( $self ) = @_;
    
    my $repo = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/keys/$repo" );
}
sub add_deploy_key {
    my ( $self, $title, $key ) = @_;
    
    my $repo = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/key/$repo/add",
        title => $title,
        key   => $key
    );
}
sub remove_deploy_key {
    my ( $self, $id ) = @_;
    
    my $repo = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/key/$repo/remove",
        id => $id,
    );
}

sub collaborators {
    my ( $self ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/show/$owner/$repo/collaborators" );
}
sub add_collaborator {
    my ( $self, $user ) = @_;
    
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/collaborators/$repo/add/$user" );
}
sub remove_collaborator {
    my ( $self, $user ) = @_;
    
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "repos/collaborators/$repo/remove/$user" );
}

sub network {
    my ( $self ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "repos/show/$owner/$repo/network" );
}

sub tags {
    my ( $self ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "repos/show/$owner/$repo/tags" );
}
sub branches {
    my ( $self ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "repos/show/$owner/$repo/branches" );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Repositories - GitHub Repositories API

=head1 SYNOPSIS

    use Net::GitHub::Repositories;

    my $repos = Net::GitHub::Repositories->new(
        owner => 'fayland', repo => 'perl-net-github'
    );

=head1 DESCRIPTION

L<http://develop.github.com/p/repo.html>

For those B<(authentication required)> below, you must set login and token (in L<https://github.com/account>

    my $repos = Net::GitHub::Repositories->new(
        owner => 'fayland', repo => 'perl-net-github',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
    );

=head1 METHODS

=over 4

=item search

    my $results = $repos->search('net-github');

Search Repositories

=item show

    my $repos_in_detail = $repos->show(); # show the owner+repo in ->new
    my $repos_in_detail = $repos->show('fayland', 'foorum'); # another
    
To look at more in-depth information for a repository

=item list

    my $repositories = $repos->list(); # show the owner in ->new
    my $repositories = $repos->list('nothingmuch');
    
list out all the repositories for a user

=item watch

=item unwatch

    $repos->watch();
    $repos->unwatch();

watch and unwatch repositories (authentication required)

=item fork

    $repos->fork();

fork a repository (authentication required)

=item create

    my $rep = $repos->create( $name, $desc, $homepage, $is_public );

create a new repository (authentication required). $name are required. like 'perl-net-github'

=item delete

    $repos->delete(); # just return delete_token
    $repos->delete( { confirm => 1 } ); # delete the repository

delete a repository (authentication required)

=item set_private

=item set_public

    $repos->set_private();
    $repos->set_public();

set a public repository private or make a private repo public (authentication required)

=item deploy_keys

=item add_deploy_key

=item remove_deploy_key

    $repos->add_deploy_key( 'title', $key );
    my $pub_keys = $repos->deploy_keys();
    $repos->remove_deploy_key( $pub_keys->public_keys->[0]->{id} );

list, add and remove your deploy keys (authentication required)

=item collaborators

=item add_collaborator

=item remove_collaborator

    my $collaborators = $repos->collaborators();
    $repos->add_collaborator( 'steven' );
    $repos->remove_collaborator( 'steven' );

list, add and remove the collaborators on your project (authentication required)

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.