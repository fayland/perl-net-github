package Net::GitHub::V2;

use Moose;

our $VERSION = '0.05';
our $AUTHORITY = 'cpan:FAYLAND';

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

=head1 SEE ALSO

L<Moose>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
