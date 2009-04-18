package Net::GitHub::V1::User;

use Moose;

our $VERSION = '0.04';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::V1::Role';

has 'username' => ( is => 'ro', required => 1, isa => 'Str' );

has '__user' => (
    is => 'rw', isa => 'Net::GitHub::V1::UserObj', lazy_build => 1,
    handles => [qw/name repositories blog location email company/],
);
sub _build___user {
    my $self = shift;
    
    my $url = $self->api_url . $self->username;
    my $json = $self->get($url);
    my $data = $self->json->jsonToObj($json);
    return Net::GitHub::V1::UserObj->new($data->{user});
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
    Net::GitHub::V1::UserObj;

use Moose;

has 'name' => ( is => 'rw' );
has 'repositories' => (
    is => 'rw', isa => 'ArrayRef'
);
has 'blog' => ( is => 'rw' );
has 'email' => ( is => 'rw' );
has 'location' => ( is => 'rw' );
has 'company' => ( is => 'rw' );

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V1::User - GitHub User

=head1 SYNOPSIS

    use Net::GitHub::V1::User;

    my $user = Net::GitHub::V1::User->new( 'fayland' );
    foreach my $repos ( @{ $user->repositories} ) {
        print "$repos->{owner} + $repos->{name}\n";
    }

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item name

=item email

=item blog

=item company

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