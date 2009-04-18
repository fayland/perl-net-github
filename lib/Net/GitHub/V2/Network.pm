package Net::GitHub::V2::Network;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::Role';

sub meta {
    my ( $self ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    my $url  = "http://github.com/$owner/$repo/network_meta";
    my $json = $self->get($url);
    return $self->json->jsonToObj($json);
}

sub data_chunk {
    my ( $self, $net_hash ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    my $url  = "http://github.com/$owner/$repo/network_data_chunk?nethash=$nethash";
    my $json = $self->get($url);
    return $self->json->jsonToObj($json);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Network - Secret Network API

=head1 SYNOPSIS

    use Net::GitHub::Network;

    my $network = Net::GitHub::Network->new( owner => 'fayland', repo => 'perl-net-github' );
    my $meta = $network->meta;
    my $data_chunk = $network->data_chunk( $net_hash );;

=head1 DESCRIPTION

L<http://develop.github.com/p/network.html>

=head1 METHODS

=head2 meta

=head2 data_chunk

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.