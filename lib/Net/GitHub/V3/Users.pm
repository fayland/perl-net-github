package Net::GitHub::V3::Users;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub show {
    my ( $self, $user ) = @_;
    
    if ($user) {
        return $self->query("/users/" . uri_escape($user));
    } else {
        return $self->query('/user');
    }
}

sub update {
    my $self = shift;
    my $data = @_ % 2 ? shift @_ : { @_ };
    
    return $self->query('PATCH', '/user', $data);
}

sub followers {
    my ( $self ) = @_;
    
    my $user = $self->owner;
    
    return $self->get_json_to_obj( "/user/show/$user/followers", 'users' );
}
sub following {
    my ( $self ) = @_;
    
    my $user = $self->owner;
    
    return $self->get_json_to_obj( "/user/show/$user/following", 'users' );
}
sub follow {
    my ( $self, $user ) = @_;
    return $self->get_json_to_obj_authed( "/user/follow/$user", 'users' );
}
sub unfollow {
    my ( $self, $user ) = @_;
    return $self->get_json_to_obj_authed( "/user/unfollow/$user", 'users' );
}

sub pub_keys {
    my ( $self ) = @_;
    return $self->get_json_to_obj_authed( "/user/keys", 'public_keys' );
}
sub add_pub_key {
    my ( $self, $name, $key ) = @_;
    return $self->get_json_to_obj_authed( "/user/key/add",
        name => $name,
        key  => $key,
        'public_keys'
    );
}
sub remove_pub_key {
    my ( $self, $id ) = @_;
    return $self->get_json_to_obj_authed( "/user/key/remove ",
        id => $id,
        'public_keys'
    );
}

sub emails {
    my ( $self ) = @_;
    return $self->get_json_to_obj_authed( "/user/emails", 'emails' );
}
sub add_email {
    my ( $self, $email ) = @_;
    return $self->get_json_to_obj_authed( "/user/email/add",
        email => $email,
        'emails'
    );
}
sub remove_email {
    my ( $self, $email ) = @_;
    return $self->get_json_to_obj_authed( "/user/email/remove",
        email => $email,
        'emails'
    );
}

# the same as Net::GitHub::V3::Repositories sub list
sub list {
    my ( $self, $owner ) = @_;

    $owner ||= $self->owner;
    return $self->get_json_to_obj( "repos/show/$owner", 'repositories' );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::Users - GitHub Users API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $user = $gh->users->show('nothingmuch');

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item show

    my $uinfo = $user->show(); # /user
    my $uinfo = $user->show( 'nothingmuch' ); # /users/:user

=item update

    $user->update(
        bio  => 'another Perl programmer and Father',
    );

=item followers

=item following

    my $followers = $user->followers; # owner in ->new
    my $following = $user->following;

=item follow

=item unfollow

    $user->follow( 'nothingmuch' );
    $user->unfollow( 'nothingmuch' );

follow or unfollow users (authentication required)

=item pub_keys

=item add_pub_key

=item remove_pub_key

    $user->add_pub_key( 'keyname', $key );
    my $pub_keys = $user->pub_keys;
    $user->remove_pub_key( $key_id ); # from $pub_keys

Public Key Management (authentication required)

=item emails

=item add_email

=item remove_email

    $user->add_email( 'another@email.com' );
    my $emails = $user->emails;
    $user->remove_email( 'another@email.com' );

Email Address Management (authentication required)

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
