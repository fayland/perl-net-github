package Net::GitHub::V2;

use Any::Moose;

our $VERSION = '0.08';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::V2::Repositories;
use Net::GitHub::V2::Users;
use Net::GitHub::V2::Commits;
use Net::GitHub::V2::Issues;
use Net::GitHub::V2::Object;
use Net::GitHub::V2::Network;
use Net::GitHub::V2::Organizations;
use Net::GitHub::V2::PullRequest;

with 'Net::GitHub::V2::HasRepo';

has 'repos' => (
    is => 'rw',
    isa => 'Net::GitHub::V2::Repositories',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V2::Repositories->new( $self->args_to_pass );
    },
);

has 'user' => (
    is => 'rw',
    isa => 'Net::GitHub::V2::Users',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V2::Users->new( $self->args_to_pass );
    },
);

has 'commit' => (
    is => 'rw',
    isa => 'Net::GitHub::V2::Commits',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V2::Commits->new( $self->args_to_pass );
    },
);

has 'issue' => (
    is => 'rw',
    isa => 'Net::GitHub::V2::Issues',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V2::Issues->new( $self->args_to_pass );
    },
);

has 'object' => (
    is => 'rw',
    isa => 'Net::GitHub::V2::Object',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V2::Object->new( $self->args_to_pass );
    },
    handles => {
        obj_tree => 'tree',
        obj_blob => 'blob',
        obj_raw  => 'raw',
    }
);

has 'network' => (
    is => 'rw',
    isa => 'Net::GitHub::V2::Network',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V2::Network->new( $self->args_to_pass );
    },
    handles => ['network_meta', 'network_data_chunk']
);

has 'organization' => (
    is => 'rw',
    isa => 'Net::GitHub::V2::Organizations',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V2::Organizations->new( $self->args_to_pass );
    },
);

has 'pull_request' => (
    is => 'rw',
    isa => 'Net::GitHub::V2::PullRequest',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V2::PullRequest->new( $self->args_to_pass );
    },
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V2 - Perl Interface for github.com (V2)

=head1 SYNOPSIS

Prefer:

    use Net::GitHub;

    my $github = Net::GitHub->new(
        version => 2, # optional, default as 2
        owner => 'fayland', repo => 'perl-net-github'
    );

Or:

    use Net::GitHub::V2;

    # for http://github.com/fayland/perl-net-github/tree/master
    my $github = Net::GitHub::V2->new( owner => 'fayland', repo => 'perl-net-github' );

=head1 DESCRIPTION

L<http://develop.github.com/>

For those B<(authentication required)>, you must set login and token (in L<https://github.com/account>). If no login and token are provided, your B<.gitconfig> will be loaded: if the github.user and github.token keys are defined, they will be used.

    my $github = Net::GitHub::V2->new(
        owner => 'fayland', repo => 'perl-net-github',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
    );

If you want to work with private repo, you can set B<always_Authorization>.

To disable call rate limiting (e.g. if your account is whitelisted), set
B<api_throttle> to 0.

By default, error responses are propagated to the user as they are received
from the API. By switching B<throw_errors> on you can make the be turned into
exceptions instead, so that you don't have to check for error response after
every call.

    my $github = Net::GitHub::V2->new(
        owner => 'fayland', repo => 'perl-net-github',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
        always_Authorization => 1,
        api_throttle => 0,
        throw_errors => 0,
    );

=head1 METHODS

=head2 repos

    $github->repos->create( 'sandbox3', 'Sandbox desc', 'http://fayland.org/', 1 );
    $github->repos->show();

L<Net::GitHub::V2::Repositories>

=head2 user

    my $followers = $github->user->followers();
    $github->user->update( name => 'Fayland Lam' );

L<Net::GitHub::V2::Users>

=head2 commit

    my $commits = $github->commit->branch();
    my $commits = $github->commit->file( 'master', 'lib/Net/GitHub.pm' );
    my $co_detail = $github->commit->show( $sha1 );

L<Net::GitHub::V2::Commits>

=head2 issue

    my $issues = $github->issue->list('open');
    my $issue  = $github->issue->open( 'Bug title', 'Bug detail' );
    $github->issue->close( $number );

L<Net::GitHub::V2::Issues>

=head2 object

    my $tree = $github->obj_tree( $tree_sha1 ); # alias object->tree
    my $blob = $github->obj_blob( $tree_sha1, 'lib/Net/GitHub.pm' ); # alias object->blob
    my $raw  = $github->obj_raw( $sha1 ); # alias object->raw

L<Net::GitHub::V2::Object>

=head2 network

    $github->network_meta; # alias ->network->network_meta
    $github->network_data_chunk( $net_hash ); # alias network->network_data_chunk

L<Net::GitHub::V2::Network>

=head2 organization

    my $organization = $github->organization->organizations('github');
    my $teams = $github->organization->teams('PerlChina');

L<Net::GitHub::V2::Organizations>    

=head2 pull_request

    my $pull = $github->pull_request->pull_request();

L<Net::GitHub::V2::PullRequest>

=head1 SEE ALSO

L<Any::Moose>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

More on Changes

=head1 COPYRIGHT & LICENSE

Copyright 2009-2011 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
