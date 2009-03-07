package Net::GitHub;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::Project;

does 'Net::GitHub::Role';

has 'project' => (
    is => 'rw',
    isa => 'Net::GitHub::Project',
    lazy => 1,
    default => sub {
        my $self = shift;
        returnNet::GitHub::Project->new( $self->args_to_pass );
    }
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub - Perl Interface for github.com

=head1 SYNOPSIS

    use Net::GitHub;

    # for http://github.com/fayland/perl-net-github/tree/master
    my $github = Net::GitHub->new( owner => 'fayland', project => 'perl-net-github' );
    ...

=head1 EXPORT

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
