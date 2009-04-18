package Net::GitHub::V2::Users;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::Role';

sub search {
    my ( $self, $word ) = @_;
    
    return $self->get_json_to_obj( 'user/search/' . uri_escape($word) );
}

sub show {
    my ( $self, $user ) = @_;
    
    return $self->get_json_to_obj( "user/show/$user" );
}

sub update {
    my $self = shift;
    my $user = shift;
    return $self->get_json_to_obj_authed( "user/$user", @_ );
}

sub followers {
    my ( $self, $user ) = @_;
    return $self->get_json_to_obj( "/user/show/$user/followers" );
}
sub follow {
    my ( $self, $user ) = @_;
    return $self->get_json_to_obj_authed( "/user/follow/$user" );
}
sub unfollow {
    my ( $self, $user ) = @_;
    return $self->get_json_to_obj_authed( "/user/unfollow/$user" );
}

sub pub_keys {
    my ( $self ) = @_;
    return $self->get_json_to_obj_authed( "/user/keys" );
}
sub add_pub_key {
    my ( $self, $name, $key ) = @_;
    return $self->get_json_to_obj_authed( "/user/key/add",
        name => $name,
        key  => $key
    );
}
sub remove_pub_key {
    my ( $self, $id ) = @_;
    return $self->get_json_to_obj_authed( "/user/key/remove ",
        id => $id,
    );
}

sub emails {
    my ( $self ) = @_;
    return $self->get_json_to_obj_authed( "/user/emails" );
}
sub add_email {
    my ( $self, $email ) = @_;
    return $self->get_json_to_obj_authed( "/user/email/add",
        email => $email,
    );
}
sub remove_pub_key {
    my ( $self, $id ) = @_;
    return $self->get_json_to_obj_authed( "/user/email/remove ",
        id => $id,
    );
} 

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Users - GitHub Users API

=head1 SYNOPSIS

    use Net::GitHub::Users;

    my $repos = Net::GitHub::Users->new();


=head1 DESCRIPTION

L<http://develop.github.com/p/users.html>

=head1 METHODS


=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.