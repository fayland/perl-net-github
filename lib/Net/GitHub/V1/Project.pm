package Net::GitHub::V1::Project;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::V1::Project::Info;
use Net::GitHub::V1::Project::Source;
use Net::GitHub::V1::Project::Downloads;
use Net::GitHub::V1::Project::Wiki;

with 'Net::GitHub::V1::Role';
with 'Net::GitHub::V1::Project::Role';

has 'info' => (
    is => 'ro',
    isa => 'Net::GitHub::V1::Project::Info',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V1::Project::Info->new( $self->args_to_pass );
    },
    handles => [qw/description homepage public_clone_url your_clone_url
                owner_user info_from_owner_user/],
);

has 'source' => (
    is => 'ro',
    isa => 'Net::GitHub::V1::Project::Source',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V1::Project::Source->new( $self->args_to_pass );
    },
    handles => [qw/commits commit/],
);

has '_downloads' => (
    is => 'ro',
    isa => 'Net::GitHub::V1::Project::Downloads',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V1::Project::Downloads->new( $self->args_to_pass );
    },
    handles => [qw/downloads/],
);

has 'wiki' => (
    is => 'ro',
    isa => 'Net::GitHub::V1::Project::Wiki',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V1::Project::Wiki->new( $self->args_to_pass );
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

Net::GitHub::V1::Project - GitHub Project (Repository) (V1)

=head1 SYNOPSIS

    use Net::GitHub::V1::Project;

    # for http://github.com/fayland/perl-net-github/tree/master
    my $prj = Net::GitHub::V1::Project->new( owner => 'fayland', name => 'perl-net-github' );
    # or
    my $prj2 = Net::GitHub::V1::Project->new( 'fayland', 'perl-net-github' );
    
    # Net::GitHub::V1::Project::Info
    print $prj->description;
    print $prj->public_clone_url;
    
    # Net::GitHub::V1::Project::Source
    my @commits = $prj->commits;
    foreach my $c ( @commits ) {
        my $commit = $prj->commit( $c->{id} );
    }
    
    # Net::GitHub::V1::Project::Downloads
    my @downloads = $prj->downloads;
    
    # Net::GitHub::V1::Project::Wiki
    $prj->signin( 'login', 'password' );
    $prj->wiki->new_page( 'PageTitle', "Page Content\n\nLine 2\n" );

=head1 DESCRIPTION

=head1 PARTS

=head2 Net::GitHub::V1::Project::Info

handled by L<Net::GitHub::V1::Project::Info>

=over 4

=item description

=item homepage

=item public_clone_url

Public Clone URL

=item your_clone_url

Your Clone URL

=item owner_user

instance of L<Net::GitHub::V1::User> for $self->owner

=item info_from_owner_user

the repos I<HASHREF> from $self->owner_user->repositories which matches the owner and name.

=back

=head2 Net::GitHub::V1::Project::Source

handled by L<Net::GitHub::V1::Project::Source>

=over 4

=item commits

=item commit

=back

=head2 Net::GitHub::V1::Project::Downloads

handled by L<Net::GitHub::V1::Project::Downloads>

=over 4

=item downloads

=back

=head2 Net::GitHub::V1::Project::Wiki

instance of L<Net::GitHub::V1::Project::Wiki>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.