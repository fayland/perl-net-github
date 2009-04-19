package Net::GitHub::V2;

use Moose;

our $VERSION = '0.07';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::V2::Repositories;
use Net::GitHub::V2::Users;
use Net::GitHub::V2::Commits;
use Net::GitHub::V2::Issues;
use Net::GitHub::V2::Object;
use Net::GitHub::V2::Network;

with 'Net::GitHub::V2::Role';

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

no Moose;
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

For those B<(authentication required)>, you must set login and token (in L<https://github.com/account>)

    my $github = Net::GitHub::V2->new(
        owner => 'fayland', repo => 'perl-net-github',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
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

L<Net::GitHub::Network>

=head1 SEE ALSO

L<Moose>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
