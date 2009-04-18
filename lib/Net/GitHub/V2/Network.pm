package Net::GitHub::V2::Network;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::Role';

sub network_meta {
    my ( $self, $owner, $repo ) = @_;
    
    my $url  = "http://github.com/$owner/$repo/network_meta";
    my $json = $self->get($url);
    return $self->json->jsonToObj($json);
}

sub network_data_chunk {
    my ( $self, $owner, $repo, $net_hash ) = @_;
    
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

    my $repos = Net::GitHub::Network->new();


=head1 DESCRIPTION

L<http://develop.github.com/p/network.html>

=head1 METHODS


=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.