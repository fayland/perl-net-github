package Net::GitHub::Project;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::Project::Source;

does 'Net::GitHub::Role';

# git://github.com/fayland/perl-net-github.git
has 'public_clone_url' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return 'git://github.com/' . $self->owner . '/' . $self->project . '.git';
    }
);
# git@github.com:fayland/perl-net-github.git
has 'your_clone_url' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return 'git@github.com:' . $self->owner . '/' . $self->project . '.git';
    }
);

has 'source' => (
    is => 'ro',
    isa => 'Net::GitHub::Project::Source',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::Project::Source->new( $self->args_to_pass );
    }
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Project - GitHub project

=head1 SYNOPSIS

    use Net::GitHub;

    # for http://github.com/fayland/perl-net-github/tree/master
    my $prj = Net::GitHub::Project->new( owner => 'fayland', name => 'perl-net-github' );
    print $prj->public_clone_url;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item public_clone_url

Public Clone URL

=item your_clone_url

Your Clone URL

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.