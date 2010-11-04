package Net::GitHub::V2::HasRepo;

use Any::Moose 'Role';

our $VERSION = '0.14';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::V2::NoRepo' => { -excludes => [ 'args_to_pass' ] };;

# repo stuff
has 'repo'  => ( isa => 'Str', is => 'ro', required => 1 );

sub args_to_pass {
    my $self = shift;
    my $ret;
    foreach my $col ('owner', 'repo', 'login', 'token') {
        $ret->{$col} = $self->$col if defined $self->$col;
    }
    return $ret;
}

no Any::Moose;

1;
__END__

=head1 NAME

Net::GitHub::V2::HasRepo - Role for Net::GitHub::V2 for classes that use repos

=head1 SYNOPSIS

    package Net::GitHub::V2::XXX;
    
    use Any::Moose;
    with 'Net::GitHub::V2::HasRepo';

=head1 DESCRIPTION

=head1 ATTRIBUTES

Same as L<Net::GitHub::V2::NoRepo>, with the following:

=over 4

=item repo

A repo name.

=back

=head1 METHODS

Same as L<Net::GitHub::V2::NoRepo>, expect C<args_to_pass>.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

Chris Nehren C<< apeiron@cpan.org >> refactored Net::GitHub::V2::Role to be
smarter about requiring a repo.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
