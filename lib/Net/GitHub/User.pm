package Net::GitHub::User;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::Role';

has 'username' => ( is => 'ro', required => 1, isa => 'Str' );

has '__user' => ( is => 'rw', isa => 'HashRef', lazy_build => 1 );
sub _build__user {
    my $self = shift;
    
    my $url = $self->api_url . $self->username;
    my $json = $self->get($url);
    my $user = $self->json->jsonToObj($json);
    return $user;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::User - GitHub user

=head1 SYNOPSIS

    use Net::GitHub::User;

    my $user = Net::GitHub::User->new( username => 'fayland' );

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item 

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.