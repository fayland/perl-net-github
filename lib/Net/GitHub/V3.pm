package Net::GitHub::V3;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::V3::Query';

use Net::GitHub::V3::Users;
use Net::GitHub::V3::Repos;
use Net::GitHub::V3::Issues;
use Net::GitHub::V3::PullRequests;

has 'user' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Users',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Users->new( $self->args_to_pass );
    },
);

has 'repos' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Repos',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Repos->new( $self->args_to_pass );
    },
);

has 'issue' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::Issues',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::Issues->new( $self->args_to_pass );
    },
);

has 'pull_request' => (
    is => 'rw',
    isa => 'Net::GitHub::V3::PullRequests',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Net::GitHub::V3::PullRequests->new( $self->args_to_pass );
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
        login => 'fayland', pass => 'mypass',
        # or
        # access_token => $oauth_token
        
        # optional
        user => 'fayland', repos => 'perl-net-github',
    );

Or:

    use Net::GitHub::V3;
    my $github = Net::GitHub::V3->new(
        login => 'fayland', pass => 'mypass',
        # or
        # access_token => $oauth_token
        
        # optional
        user => 'fayland', repos => 'perl-net-github',
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

=head2 Modules

=head3 user

    my $user = $github->user->show('nothingmuch');
    $github->user->update( bio => 'Just Another Perl Programmer' );

L<Net::GitHub::V3::Users>

=head2 repos

    my @repos = $github->repos->list;
    my $rp = $github->repos->create( {
        "name" => "Hello-World",
        "description" => "This is your first repo",
        "homepage" => "https://github.com"
    } );

L<Net::GitHub::V3::Repos>

=head2 issue

    my @issues = $github->issue->issues();
    my $issue  = $github->issue->issue($issue_id);

L<Net::GitHub::V3::Issues>

=head2 pull_request

L<Net::GitHub::V3::PullRequests>

=head2 query($method, $url, $data)

    my $data = $github->query('/user');
    $github->query('PATCH', '/user', $data);
    $github->query('DELETE', '/user/emails', [ 'myemail@somewhere.com' ]);

query API directly

=head1 SEE ALSO

L<Any::Moose>, L<Pithub>

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
