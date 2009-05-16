package Net::GitHub::V2::Users;

use Moose;

our $VERSION = '0.15';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::NoRepo';

sub search {
    my ( $self, $word ) = @_;
    
    return $self->get_json_to_obj( 'user/search/' . uri_escape($word), 'users' );
}

sub show {
    my ( $self, $owner ) = @_;
    
    $owner ||= $self->owner;
    
    return $self->get_json_to_obj( "user/show/$owner", 'user' );
}

sub update {
    my ( $self, %up ) = @_;
    
    my $user = $self->owner;
    
    # with format values[key] = value
    my @values;
    foreach my $key ( keys %up ) {
        push @values, ( "values[$key]", $up{$key} );
    }
    
    return $self->get_json_to_obj_authed( "user/show/$user", @values, 'user' );
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

# the same as Net::GitHub::V2::Repositories sub list
sub list {
    my ( $self, $owner ) = @_;

    $owner ||= $self->owner;
    return $self->get_json_to_obj( "repos/show/$owner", 'repositories' );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V2::Users - GitHub Users API

=head1 SYNOPSIS

    use Net::GitHub::V2::Users;

    my $user = Net::GitHub::V2::Users->new(
        owner => 'fayland'
    );

=head1 DESCRIPTION

L<http://develop.github.com/p/users.html>

For those B<(authentication required)> below, you must set login and token (in L<https://github.com/account>)

    my $user = Net::GitHub::V2::Users->new(
        owner => 'fayland',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
    );

=head1 METHODS

=over 4

=item search

    my $results = $user->search( 'fayland' );

user searching

=item list

    my $repositories = $user->list(); # show the owner in ->new
    my $repositories = $user->list('nothingmuch');
    
list out all the repositories for a user

=item show

    my $uinfo = $user->show(); # owner in ->new
    my $uinfo = $user->show( 'nothingmuch' );

get extended information on user

=item update

    $user->update(
        name  => 'Another Name',
        email => 'Another@email.com',
    );

update your users information (authentication required)

possible keys: name, email, blog, company, location

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
