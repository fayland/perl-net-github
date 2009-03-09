package Net::GitHub::Project::Info;

use Moose;

our $VERSION = '0.04';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::User; # get Rrepository description/homepage

with 'Net::GitHub::Role';
with 'Net::GitHub::Project::Role';

has 'public_clone_url' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        # git://github.com/fayland/perl-net-github.git
        return 'git://github.com/' . $self->owner . '/' . $self->name . '.git';
    }
);

has 'your_clone_url' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        # git@github.com:fayland/perl-net-github.git
        return 'git@github.com:' . $self->owner . '/' . $self->name . '.git';
    }
);

has 'owner_user' => (
    is => 'rw',
    lazy => 1,
    default => sub {
        return Net::GitHub::User->new( shift->owner );
    }
);
has 'info_from_owner_user' => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $repositories = $self->owner_user->repositories;
        foreach my $repos ( @$repositories ) {
            return $repos
                if ( $repos->{owner} eq $self->owner
                 and $repos->{name} eq $self->name );
        }
        return {};
    },
);

# from owner user
has 'description' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return $self->info_from_owner_user->{description}
            if exists $self->info_from_owner_user->{description};
    },
);
has 'homepage' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return $self->info_from_owner_user->{homepage}
            if exists $self->info_from_owner_user->{homepage};
    },
);

has 'watcher_num' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return $self->info_from_owner_user->{watchers}
            if exists $self->info_from_owner_user->{watchers};
    },
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Project::Info - GitHub Project Info Section

=head1 SYNOPSIS

    use Net::GitHub::Project::Info;

    my $dl = Net::GitHub::Project::Info->new(
        owner => 'fayland', name => 'perl-net-github'
    );


=head1 DESCRIPTION

=head1 ATTRIBUTES

=over 4

=item description

=item homepage

=item public_clone_url

Public Clone URL

=item your_clone_url

Your Clone URL

=item owner_user

instance of L<Net::GitHub::User> for $self->owner

=item watcher_num

How many people watch this project?

=item info_from_owner_user

the repos I<HASHREF> from $self->owner_user->repositories which matches the owner and name.

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.