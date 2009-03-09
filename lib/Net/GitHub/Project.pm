package Net::GitHub::Project;

use Moose;

our $VERSION = '0.04';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::Project::Info;
use Net::GitHub::Project::Source;
use Net::GitHub::Project::Downloads;
use Net::GitHub::Project::Wiki;

with 'Net::GitHub::Role';
with 'Net::GitHub::Project::Role';

has 'info' => (
    is => 'ro',
    isa => 'Net::GitHub::Project::Info',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::Project::Info->new( $self->args_to_pass );
    },
    handles => [qw/description homepage public_clone_url your_clone_url
                owner_user info_from_owner_user/],
);

has 'source' => (
    is => 'ro',
    isa => 'Net::GitHub::Project::Source',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::Project::Source->new( $self->args_to_pass );
    },
    handles => [qw/commits commit/],
);

has '_downloads' => (
    is => 'ro',
    isa => 'Net::GitHub::Project::Downloads',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::Project::Downloads->new( $self->args_to_pass );
    },
    handles => [qw/downloads/],
);

has 'wiki' => (
    is => 'ro',
    isa => 'Net::GitHub::Project::Wiki',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::Project::Wiki->new( $self->args_to_pass );
    },
);

sub BUILDARGS {
    my $class = shift;

    if ( scalar @_ == 2 ) {
        return { owner => $_[0], name => $_[1] };
    } else {
        return $class->SUPER::BUILDARGS(@_);
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Project - GitHub Project (Repository)

=head1 SYNOPSIS

    use Net::GitHub::Project;

    # for http://github.com/fayland/perl-net-github/tree/master
    my $prj = Net::GitHub::Project->new( owner => 'fayland', name => 'perl-net-github' );
    # or
    # my $prj = Net::GitHub::Project->new( 'fayland', 'perl-net-github' );
    print $prj->public_clone_url;
    print Dumper(\$prj->commits);

=head1 DESCRIPTION

=head1 PARTS

=head2 Net::GitHub::Project::Info

handled by L<Net::GitHub::Project::Info>

=over 4

=item description

=item homepage

=item public_clone_url

Public Clone URL

=item your_clone_url

Your Clone URL

=item owner_user

instance of L<Net::GitHub::User> for $self->owner

=item info_from_owner_user

the repos I<HASHREF> from $self->owner_user->repositories which matches the owner and name.

=back

=head2 Net::GitHub::Project::Source

handled by L<Net::GitHub::Project::Source>

=over 4

=item commits

=item commit

=back

=head2 Net::GitHub::Project::Downloads

handled by L<Net::GitHub::Project::Downloads>

=over 4

=item downloads

=back

=head2 Net::GitHub::Project::Wiki

instance of L<Net::GitHub::Project::Wiki>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.