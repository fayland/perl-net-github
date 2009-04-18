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
    my ( $self, $net_hash, $start, $end ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    my $url  = "http://github.com/$owner/$repo/network_data_chunk?nethash=$nethash";
    $url    .= "&start=$start" if defined $start;
    $url    .= "&end=$end" if defined $end;
    my $json = $self->get($url);
    return $self->json->jsonToObj($json);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V2::Network - Secret Network API

=head1 SYNOPSIS

    use Net::GitHub::V2::Network;

    my $network = Net::GitHub::V2::Network->new(
        owner => 'fayland', repo => 'perl-net-github'
    );
    my $meta = $network->meta;
    my $data_chunk = $network->data_chunk( $net_hash );;

=head1 DESCRIPTION

L<http://develop.github.com/p/network.html>

=head1 METHODS

=over 4

=item meta

=item data_chunk

    $network->data_chunk( $net_hash );
    $network->data_chunk( $net_hash, $start, $end );

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.