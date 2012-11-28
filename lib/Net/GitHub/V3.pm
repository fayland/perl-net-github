package Net::GitHub::V3;

use Any::Moose;

our $VERSION = '0.49';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::V3::Query';

use Net::GitHub::V3::Users;
use Net::GitHub::V3::Repos;
use Net::GitHub::V3::Issues;
use Net::GitHub::V3::PullRequests;
use Net::GitHub::V3::Orgs;
use Net::GitHub::V3::GitData;
use Net::GitHub::V3::Gists;
use Net::GitHub::V3::OAuth;
use Net::GitHub::V3::Events;
use Net::GitHub::V3::Search;

has '+is_main_module' => (default => 1);

has 'user' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Users',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Users->new( $self->args_to_pass );
    },
);

has 'org' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Orgs',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Orgs->new( $self->args_to_pass );
    },
);

has 'gist' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Gists',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Gists->new( $self->args_to_pass );
    },
);

has 'repos' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Repos',
    lazy => 1,
    predicate => 'is_repos_init',
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Repos->new( $self->args_to_pass );
    },
);

has 'issue' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Issues',
    lazy => 1,
    predicate => 'is_issue_init',
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Issues->new( $self->args_to_pass );
    },
);

has 'pull_request' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::PullRequests',
    lazy => 1,
    predicate => 'is_pull_request_init',
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::PullRequests->new( $self->args_to_pass );
    },
);

has 'git_data' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::GitData',
    lazy => 1,
    predicate => 'is_git_data_init',
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::GitData->new( $self->args_to_pass );
    },
);

has 'oauth' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::OAuth',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::OAuth->new( $self->args_to_pass );
    },
);

has 'event' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Events',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Events->new( $self->args_to_pass );
    },
);

has 'search' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Search',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Search->new( $self->args_to_pass );
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
    my $gh = Net::GitHub->new(
        version => 3,
        login => 'fayland', pass => 'mypass',
        # or
        # access_token => $oauth_token
    );

Or:

    use Net::GitHub::V3;
    my $gh = Net::GitHub::V3->new(
        login => 'fayland', pass => 'mypass',
        # or
        # access_token => $oauth_token
    );

=head1 DESCRIPTION

L<http://develop.github.com/>

=head2 ATTRIBUTES

=head3 Authentication

There are two ways to authenticate through GitHub API v3:

=over 4

=item login/pass

    my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS} );

=item access_token

    my $gh = Net::GitHub->new( access_token => $ENV{GITHUB_ACCESS_TOKEN} );

=back

=head3 raw_response

    my $gh = Net::GitHub->new(
        # login/pass or access_token
        raw_response => 1
    );

return raw L<HTTP::Response> object

=head3 raw_string

    my $gh = Net::GitHub->new(
        # login/pass or access_token
        raw_string => 1
    );

return L<HTTP::Response> response content as string

=head3 api_throttle

    my $gh = Net::GitHub->new(
        # login/pass or access_token
        api_throttle => 0
    );

To disable call rate limiting (e.g. if your account is whitelisted), set B<api_throttle> to 0.

=head3 RaiseError

By default, error responses are propagated to the user as they are received
from the API. By switching B<RaiseError> on you can make the be turned into
exceptions instead, so that you don't have to check for error response after
every call.

=head3 next_url, last_url, prev_url, first_url

Any methods which return multiple results I<may> be paginated. After performing
a query you should check to see if there are more results. These attributes will
be reset for each query.

The predicates to check these attributes are C<has_next_page>, C<has_last_page>,
C<has_prev_page> and C<has_first_page>.

See Github's documentation: L<http://developer.github.com/v3/#pagination>

The C<per_page> parameter mentioned in their docs is B<NOT> supported by this module.

  my @issues = $gh->issue->repos_issues;
  while ($gh->issue->has_next_page) {
      push @issues, $gh->issue->query($gh->issue->next_url);
      ## OR ##
      push @issues, $gh->issue->next_page);
  }

=head2 METHODS

=head3 query($method, $url, $data)

    my $data = $gh->query('/user');
    $gh->query('PATCH', '/user', $data);
    $gh->query('DELETE', '/user/emails', [ 'myemail@somewhere.com' ]);

query API directly

=head3 next_page

When the results have been paginated, C<next_page> is sugar for the common case
of iterating through all the pages in order. It simply calls C<query> with the C<next_url>.

=head3 set_default_user_repo

    $gh->set_default_user_repo('fayland', 'perl-net-github'); # take effects for all $gh->
    $gh->repos->set_default_user_repo('fayland', 'perl-net-github'); # take effects on $gh->repos

B<To ease the keyboard, we provided two ways to call any method which starts with :user/:repo>

1. SET user/repos before call methods below

    $gh->set_default_user_repo('fayland', 'perl-net-github');
    my @contributors = $gh->repos->contributors;

2. If it is just for once, we can pass :user, :repo before any arguments

    my @contributors = $repos->contributors($user, $repo);

=head2 MODULES

=head3 user

    my $user = $gh->user->show('nothingmuch');
    $gh->user->update( bio => 'Just Another Perl Programmer' );

L<Net::GitHub::V3::Users>

=head3 repos

    my @repos = $gh->repos->list;
    my $rp = $gh->repos->create( {
        "name" => "Hello-World",
        "description" => "This is your first repo",
        "homepage" => "https://github.com"
    } );

L<Net::GitHub::V3::Repos>

=head3 issue

    my @issues = $gh->issue->issues();
    my $issue  = $gh->issue->issue($issue_id);

L<Net::GitHub::V3::Issues>

=head3 pull_request

    my @pulls = $gh->pull_request->pulls();

L<Net::GitHub::V3::PullRequests>

=head3 org

    my @orgs   = $gh->org->orgs;

L<Net::GitHub::V3::Orgs>

=head3 git_data

L<Net::GitHub::V3::GitData>

=head3 gist

L<Net::GitHub::V3::Gists>

=head3 oauth

L<Net::GitHub::V3::OAuth>

=head3 event

L<Net::GitHub::V3::Events>

=head3 search

L<Net::GitHub::V3::Search>

=head1 SEE ALSO

L<Any::Moose>, L<Pithub>

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
