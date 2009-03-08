package Net::GitHub::Project::Role;

use Moose::Role;

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

# http://github.com/fayland/perl-net-github/tree/master
has 'owner' => ( isa => 'Str', is => 'rw' );
has 'name'  => ( isa => 'Str', is => 'rw' );

sub args_to_pass {
    my $self = shift;
    my $ret;
    foreach my $col ('owner', 'name' ) {
        $ret->{$col} = $self->$col;
    }
    return $ret;
}

no Moose::Role;

1;
__END__

=head1 NAME

Net::GitHub::Project::Role - Common between Net::GitHub::Project::* libs

=head1 SYNOPSIS

    package Net::GitHub::Project::XXX;
    
    use Moose;
    with 'Net::GitHub::Project::Role';

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item owner

'fayland' of http://github.com/fayland/perl-net-github/tree/master

=item name

'perl-net-github' of http://github.com/fayland/perl-net-github/tree/master

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.