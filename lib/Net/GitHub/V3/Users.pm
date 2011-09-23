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

sub emails {
    (shift)->query('/user/emails');
}
sub add_email {
    (shift)->query( 'POST', '/user/emails', [ @_ ] );
}
sub remove_email {
    (shift)->query( 'DELETE', '/user/emails', [ @_ ] );
}

sub followers {
    my ($self, $user) = @_;
    if ($user) {
        return $self->query("/users/" . uri_escape($user) . '/followers');
    } else {
        return $self->query('/user/followers');
    }
}
sub following {
    my ($self, $user) = @_;
    if ($user) {
        return $self->query("/users/" . uri_escape($user) . '/following');
    } else {
        return $self->query('following');
    }
}
sub is_following {
    my ($self, $user) = @_;
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('/user/following/' . uri_escape($user));
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}
sub follow {
    my ( $self, $user ) = @_;
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('PUT', '/user/following/' . uri_escape($user));
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}
sub unfollow {
    my ( $self, $user ) = @_;
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', '/user/following/' . uri_escape($user));
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub keys {
    (shift)->query('/user/keys');
}
sub key {
    my ($self, $key_id) = @_;
    return $self->query('/user/keys/' . uri_escape($key_id));
}
sub create_key {
    my ( $self, $title, $key ) = @_;
    unless (ref $title eq 'HASH') { # title can be a hashref
        $title = {
            title => $title,
            key => $key
        }
    }
    return $self->query('POST', '/user/keys', $title);
        
}
sub update_key {
    my ($self, $key_id, $new_key) = @_;
    return $self->query('PATCH', '/user/keys/' . uri_escape($key_id), $new_key);
}
sub delete_key {
    my ( $self, $id ) = @_;
    return $self->query('DELETE', '/user/keys/' . uri_escape($id));
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
    my $user = $gh->user->show('nothingmuch');

=head1 DESCRIPTION

=head2 METHODS

=head3 Users

L<http://developer.github.com/v3/users/>

=over 4

=item show

    my $uinfo = $user->show(); # /user
    my $uinfo = $user->show( 'nothingmuch' ); # /users/:user

=item update

    $user->update(
        bio  => 'another Perl programmer and Father',
    );
=back

=head3 Emails

L<http://developer.github.com/v3/users/emails/>

=over 4

=item emails

=item add_email

=item remove_email

    $user->add_email( 'another@email.com' );
    $user->add_email( 'batch1@email.com', 'batch2@email.com' );
    my $emails = $user->emails;
    $user->remove_email( 'another@email.com' );
    $user->remove_email( 'batch1@email.com', 'batch2@email.com' );

=back

=head3 Followers

L<http://developer.github.com/v3/users/followers/>

=over 4

=item followers

=item following

    my $followers = $user->followers;
    my $followers = $user->followers($user);
    my $following = $user->following;
    my $following = $user->following($user);

=item is_following

    my $is_following = $user->is_following($user);

=item follow

=item unfollow

    $user->follow( 'nothingmuch' );
    $user->unfollow( 'nothingmuch' );

=back

=head3 Keys

L<http://developer.github.com/v3/users/keys/>

=over 4

=item keys

=item key

=item create_key

=item update_key

=item delete_key

    my $keys = $user->keys;
    my $key  = $user->key($key_id); # get key
    $user->create_key( 'title', $key );
    $user->update_key($key_id, {
        title => $title,
        key   => $key
    });
    $user->delete_key($key_id);

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
