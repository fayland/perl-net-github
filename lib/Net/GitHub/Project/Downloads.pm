package Net::GitHub::Project::Downloads;

use Moose;

our $VERSION = '0.04';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::Role';
with 'Net::GitHub::Project::Role';

has 'downloads' => (
    is => 'rw',
    isa => 'ArrayRef',
    lazy_build => 1
);
sub _build_downloads {
    my $self = shift;
    
    my $content = $self->get( $self->project_url . 'downloads' );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Project::Downloads - GitHub Project Downloads Section

=head1 SYNOPSIS

    use Net::GitHub::Project::Downloads;

    my $dl = Net::GitHub::Project::Downloads->new(
        owner => 'fayland', name => 'perl-net-github'
    );


=head1 DESCRIPTION

=head1 METHODS

=over 4

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.