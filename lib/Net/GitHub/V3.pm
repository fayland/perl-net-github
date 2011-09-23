package Net::GitHub::V3;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::V3::Query';

use Net::GitHub::V3::Users;

has 'users' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Users',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Users->new( $self->args_to_pass );
    },
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3 - Github API v3

=head1 SYNOPSIS

Prefer:

    use Net::GitHub;
    my $github = Net::GitHub->new(
        version => 3,
        user => 'fayland', pass => 'mypass',
        # or
        # access_token => $oauth_token
    );

Or:

    use Net::GitHub::V3;
    my $github = Net::GitHub::V3->new(
        user => 'fayland', pass => 'mypass',
        # or
        # access_token => $oauth_token
    );

=head1 DESCRIPTION

L<http://develop.github.com/>

=head2 ATTRIBUTES

=head3 Authentication

There are two ways to authenticate through GitHub API v3:

For those B<(authentication required)>, you must set login and token (in L<https://github.com/account>). If no login and token are provided, your B<.gitconfig> will be loaded: if the github.user and github.token keys are defined, they will be used.

    my $github = Net::GitHub::V3->new(
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

    my $github = Net::GitHub::V3->new(
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

L<Net::GitHub::V3::Repositories>

=head2 user

    my $followers = $github->user->followers();
    $github->user->update( name => 'Fayland Lam' );

L<Net::GitHub::V3::Users>

=head2 commit

    my $commits = $github->commit->branch();
    my $commits = $github->commit->file( 'master', 'lib/Net/GitHub.pm' );
    my $co_detail = $github->commit->show( $sha1 );

L<Net::GitHub::V3::Commits>

=head2 issue

    my $issues = $github->issue->list('open');
    my $issue  = $github->issue->open( 'Bug title', 'Bug detail' );
    $github->issue->close( $number );

L<Net::GitHub::V3::Issues>

=head2 object

    my $tree = $github->obj_tree( $tree_sha1 ); # alias object->tree
    my $blob = $github->obj_blob( $tree_sha1, 'lib/Net/GitHub.pm' ); # alias object->blob
    my $raw  = $github->obj_raw( $sha1 ); # alias object->raw

L<Net::GitHub::V3::Object>

=head2 network

    $github->network_meta; # alias ->network->network_meta
    $github->network_data_chunk( $net_hash ); # alias network->network_data_chunk

L<Net::GitHub::V3::Network>

=head2 organization

    my $organization = $github->organization->organizations('github');
    my $teams = $github->organization->teams('PerlChina');

L<Net::GitHub::V3::Organizations>    

=head2 pull_request

    my $pull = $github->pull_request->pull_request();

L<Net::GitHub::V3::PullRequest>

=head1 SEE ALSO

L<Any::Moose>, L<Pithub>

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
