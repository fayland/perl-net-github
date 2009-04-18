package Net::GitHub::V2;

use Moose;

our $VERSION = '0.05';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::V2::Repositories;
use Net::GitHub::V2::Commits;
use Net::GitHub::V2::Network;
use Net::GitHub::V2::Users;
use Net::GitHub::V2::Object;
use Net::GitHub::V2::Issues;

with 'Net::GitHub::V2::Role';

has 'network' => (
    is => 'rw',
    isa => 'Net::GitHub::V2::Network',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V2::Network->new( $self->args_to_pass );
    },
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V2 - Perl Interface for github.com (V2)

=head1 SYNOPSIS

    use Net::GitHub::V2;

    # for http://github.com/fayland/perl-net-github/tree/master
    my $github = Net::GitHub::V2->new();
    

=head1 DESCRIPTION

=head1 METHODS

=head2 network

    $github->network->meta;
    $github->network->data_chunk( $net_hash );

L<Net::GitHub::Network>

=head1 SEE ALSO

L<Moose>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
