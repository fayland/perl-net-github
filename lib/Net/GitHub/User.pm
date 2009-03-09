package Net::GitHub::User;

use Moose;

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::Role';

has 'username' => ( is => 'ro', required => 1, isa => 'Str' );

has '__user' => (
    is => 'rw', isa => 'Net::GitHub::UserObj', lazy_build => 1,
    handles => [qw/name repositories blog login location/],
);
sub _build___user {
    my $self = shift;
    
    my $url = $self->api_url . $self->username;
    my $json = $self->get($url);
    my $data = $self->json->jsonToObj($json);
    return Net::GitHub::UserObj->new($data->{user});
}

sub BUILDARGS {
    my $class = shift;

    if ( @_ == 1 && ! ref $_[0] ) {
        return { username => $_[0] };
    } else {
        return $class->SUPER::BUILDARGS(@_);
    }
}

package     # hide from PAUSE
    Net::GitHub::UserObj;

use Moose;

has 'name' => ( is => 'rw' );
has 'repositories' => (
    is => 'rw', isa => 'ArrayRef'
);
has 'blog' => ( is => 'rw' );
has 'login' => ( is => 'rw' );
has 'location' => ( is => 'rw' );

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::User - GitHub user

=head1 SYNOPSIS

    use Net::GitHub::User;

    my $user = Net::GitHub::User->new( 'fayland' );
    foreach my $repos ( @{ $user->repositories} ) {
        print "$repos->{owner} + $repos->{name}\n";
    }

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item name

=item blog

=item login

=item location

=item repositories

ArrayRef

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.