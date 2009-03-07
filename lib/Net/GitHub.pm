package Net::GitHub;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

does 'Net::GitHub::Role';


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub - Perl Interface for github.com

=head1 SYNOPSIS

    use Net::GitHub;

    my $foo = Net::GitHub->new( username => 'fayland', project => 'perl-net-github' );
    ...

=head1 EXPORT

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
