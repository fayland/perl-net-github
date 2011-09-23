package Net::GitHub::V3::Query;

use Any::Moose 'Role';

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI;
use JSON::Any;
use WWW::Mechanize;
use MIME::Base64;
use HTTP::Request;
use HTTP::Request::Common ();
use Carp qw/croak/;

# configurable args

# Authentication
has 'user'  => ( is => 'rw', isa => 'Str', predicate => 'has_user' );
has 'token' => ( is => 'rw', isa => 'Str', predicate => 'has_token' );
has 'pass'  => ( is => 'rw', isa => 'Str', predicate => 'has_pass' );
has 'access_token' => ( is => 'rw', isa => 'Str', predicate => 'has_access_token' );

# return raw unparsed JSON
has 'raw' => (is => 'rw', isa => 'Bool', default => 0);
has 'raw_json' => (is => 'rw', isa => 'Bool', default => 0);

has 'api_url' => (is => 'ro', default => 'https://api.github.com');
has 'api_throttle' => ( is => 'rw', isa => 'Bool', default => 1 );

# Error handle
has 'RaiseError' => ( is => 'rw', isa => 'Bool', default => 1 );

sub args_to_pass {
    my $self = shift;
    my $ret;
    foreach my $col ('user', 'pass', 'token', 'access_token', 'raw', 'raw_json', 'api_url', 'api_throttle') {
        $ret->{$col} = $self->$col;
    }
    return $ret;
}

has 'ua' => (
    isa     => 'WWW::Mechanize',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return WWW::Mechanize->new(
            agent       => "perl-net-github $VERSION",
            cookie_jar  => {},
            stack_depth => 1,
            autocheck   => 0,
            keep_alive  => 4,
            timeout     => 60,
        );
    },
);

has 'json' => (
    is => 'ro',
    isa => 'JSON::Any',
    lazy => 1,
    default => sub {
        return JSON::Any->new;
    }
);

sub query {
    my $self = shift;
    
    # fix ARGV, not sure if it's the good idea
    my @args = @_;
    if (@args == 1) {
        unshift @args, 'GET'; # method by default
    } elsif (@args > 1 and not (grep { $args[0] eq $_ } ('GET', 'POST', 'PUT', 'PATCH', 'HEAD', 'DELETE')) ) {
        unshift @args, 'POST'; # if POST content
    }
    my $request_method = shift @args;
    my $url = shift @args;

    my $ua = $self->ua;

    ## always go with user:pass or access_token (for private repos)
    if ($self->has_access_token) {
        $ua->default_header('Authorization', "token " . $self->access_token);
    } elsif ($self->has_user and $self->has_pass) {
        my $auth_basic = $self->user . ':' . $self->pass;
        $ua->default_header('Authorization', 'Basic ' . encode_base64($auth_basic));
    } elsif ($self->has_user and $self->has_token) { # I'm not sure if it still works, it's not documented
        # "schacon/token:6ef8395fecf207165f1a82178ae1b984"
        my $auth_basic = $self->user . '/token:' . $self->token;
        $ua->default_header('Authorization', 'Basic ' . encode_base64($auth_basic));
    }

    $url = $self->api_url . $url unless $url =~ /^https\:/;
    
    my $req = $request_method eq 'DELETE' ? HTTP::Request::Common::DELETE( $url, [ @_ ] ) :
              $request_method eq 'HEAD'   ? HTTP::Request::Common::HEAD( $url, [ @_ ] ) :
              $request_method eq 'PUT'    ? HTTP::Request::Common::PUT( $url, [ @_ ] ) :
              $request_method eq 'POST'   ? HTTP::Request::Common::POST( $url, [ @_ ] ) :
              $request_method eq 'PATCH'  ? HTTP::Request::Common::PUT( $url, [ @_ ] ) : 
                                            HTTP::Request::Common::GET( $url );

    if ($request_method eq 'PATCH') {
        $req->metohd('PATCH'); # is it working?!
    }

    my $res = $ua->request($req);

    # Slow down if we're approaching the rate limit
    # By the way GitHub mistakes days for minutes in their documentation --
    # the rate limit is per minute, not per day.
    if ( $self->api_throttle ) {
        sleep 2 if (($res->header('x-ratelimit-remaining') || 0)
            < ($res->header('x-ratelimit-limit') || 60) / 2);
    }

    return $res if $self->raw;
    return $res->content if $self->raw_json;
    
    my $json = $res->content;
    my $data = eval { $self->json->jsonToObj($json) };
    unless ($data) {
        # We tolerate bad JSON for errors,
        # otherwise we just rethrow the JSON parsing problem.
        die unless $res->is_error;
        $data = { message => $res->message };
    }

    if ( $self->RaiseError ) {
        croak $data->{message} if exists $data->{message}; # for 'Client Errors'
    }

    return $data;
}

sub load_git_config { ## please call to set, it's not loaded by default anymore
    my ($self) = @_;
    
    return if $self->has_user and $self->has_token;
    
    # Gitconfig Fallback
    eval { require Config::GitLike::Git; };
    return if $@;

    my $c = Config::GitLike::Git->new();
    $c->load;
    my $user  = $c->get(key => 'github.user');
    my $token = $c->get(key => 'github.token');
    if ($user && $token) {
        $self->user($user);
        $self->token($token);
    }
}

no Any::Moose;

1;
__END__

=head1 NAME

Net::GitHub::V3::Query - Base Query role for Net::GitHub::V3

=head1 SYNOPSIS

    package Net::GitHub::V3::XXX;

    use Any::Moose;
    with 'Net::GitHub::V3::Query';

=head1 DESCRIPTION

set Authentication and call API

=head2 ATTRIBUTES

=over 4

=item user

=item pass

=item access_token

either set access_token from OAuth or user:pass for Basic Authentication

L<http://developer.github.com/>

=back

=head2 METHODS

=over 4

=item query

Refer L<Net::GitHub::V3>

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>