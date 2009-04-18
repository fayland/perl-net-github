package Net::GitHub::V2::Repositories;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::Role';

sub search {
    my ( $self, $word ) = @_;
    
    return $self->get_json_to_obj( 'repos/search/' . uri_escape($word) );
}

sub show {
    my ( $self, $owner, $repo ) = @_;
    
    return $self->get_json_to_obj( "repos/show/$owner/$repo" );
}

sub list {
    my ( $self, $owner ) = @_;
    
    return $self->get_json_to_obj( "repos/show/$owner" );
}

sub watch {
    my ( $self, $owner, $repo ) = @_;
    
    return $self->get_json_to_obj_authed( "repos/watch/$owner/$repo" );
}
sub unwatch {
    my ( $self, $owner, $repo ) = @_;
    
    return $self->get_json_to_obj_authed( "repos/unwatch/$owner/$repo" );
}

sub fork {
    my ( $self, $owner, $repo ) = @_;
    
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
    my ( $self, $repo ) = @_;
    return $self->get_json_to_obj_authed( "repos/delete/$repo" );
}

sub set_private {
    my ( $self, $repo ) = @_;
    return $self->get_json_to_obj_authed( "repos/set/private/$repo" );
}
sub set_private {
    my ( $self, $repo ) = @_;
    return $self->get_json_to_obj_authed( "repos/set/public/$repo" );
}

sub deploy_keys {
    my ( $self, $repo ) = @_;
    return $self->get_json_to_obj_authed( "repos/keys/$repo" );
}
sub add_deploy_key {
    my ( $self, $repo, $title, $key ) = @_;
    
    return $self->get_json_to_obj_authed( "repos/key/$repo/add",
        title => $title,
        key   => $key
    );
}
sub remove_deploy_key {
    my ( $self, $repo, $id ) = @_;
    
    return $self->get_json_to_obj_authed( "repos/key/$repo/remove",
        id => $id,
    );
}

sub collaborators {
    my ( $self, $owner, $repo ) = @_;
    return $self->get_json_to_obj_authed( "repos/show/$owner/$repo/collaborators" );
}
sub add_collaborator {
    my ( $self, $repo, $user ) = @_;
    return $self->get_json_to_obj_authed( "repos/collaborators/$repo/add/$user" );
}
sub remove_collaborator {
    my ( $self, $repo, $user ) = @_;
    return $self->get_json_to_obj_authed( "repos/collaborators/$repo/remove/$user" );
}

sub network {
    my ( $self, $owner, $repo ) = @_;
    return $self->get_json_to_obj( "repos/show/$owner/$repo/network" );
}

sub tags {
    my ( $self, $owner, $repo ) = @_;
    return $self->get_json_to_obj( "repos/show/$owner/$repo/tags" );
}
sub branches {
    my ( $self, $owner, $repo ) = @_;
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

    my $repos = Net::GitHub::Repositories->new();


=head1 DESCRIPTION

L<http://develop.github.com/p/repo.html>

=head1 METHODS


=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.