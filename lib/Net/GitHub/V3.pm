package Net::GitHub::V3;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::V3::Query';

use Net::GitHub::V3::Users;

has 'user' => (
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
        login => 'fayland', pass => 'mypass',
        # or
        # access_token => $oauth_token
    );

Or:

    use Net::GitHub::V3;
    my $github = Net::GitHub::V3->new(
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
        raw_string => 1
    );

return raw response

=head3 raw_string

    my $gh = Net::GitHub->new(
        # login/pass or access_token
        raw_string => 1
    );
    
return response content as string

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

=head1 SEE ALSO

L<Any::Moose>, L<Pithub>

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
