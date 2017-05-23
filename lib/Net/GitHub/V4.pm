package Net::GitHub::V4;

use Moo;

our $VERSION = '0.87';
our $AUTHORITY = 'cpan:FAYLAND';

use URI;
use JSON::MaybeXS;
use MIME::Base64;
use LWP::UserAgent;
use HTTP::Request;
use Carp qw/croak/;
use URI::Escape;
use Types::Standard qw(Int Str Bool InstanceOf Object);
use Cache::LRU;

# configurable args

# Authentication
has 'access_token' => ( is => 'rw', isa => Str, required => 1 );

# return raw unparsed JSON
has 'raw_string' => (is => 'rw', isa => Bool, default => 0);
has 'raw_response' => (is => 'rw', isa => Bool, default => 0);

has 'api_url' => (is => 'ro', default => 'https://api.github.com/graphql');
has 'api_throttle' => ( is => 'rw', isa => Bool, default => 1 );

# Rate limits
has 'rate_limit' => ( is => 'rw', isa => Int, default => 0 );
has 'rate_limit_remaining' => ( is => 'rw', isa => Int, default => 0 );
has 'rate_limit_reset' => ( is => 'rw', isa => Str, default => 0 );

has 'ua' => (
    isa     => InstanceOf['LWP::UserAgent'],
    is      => 'ro',
    lazy    => 1,
    default => sub {
        LWP::UserAgent->new(
            agent       => "perl-net-github/$VERSION",
            keep_alive  => 4,
            timeout     => 60,
        );
    },
);

has 'json' => (
    is => 'ro',
    isa => Object, # InstanceOf['JSON::MaybeXS'],
    lazy => 1,
    default => sub {
        return JSON::MaybeXS->new( utf8 => 1 );
    }
);

has 'cache' => (
  isa => InstanceOf['Cache::LRU'],
  is => 'rw',
  lazy => 1,
  default => sub {
    Cache::LRU->new(
      size => 200
    );
  }
);

sub query {
    my ($self, $iql) = @_;

    my $ua = $self->ua;

    $ua->default_header('Authorization', "bearer " . $self->access_token);

    my $data = { query => "query $iql" };
    my $json = $self->json->encode($data);

    print STDERR ">>> POST {$self->api_url}\n" if $ENV{NG_DEBUG};
    print STDERR ">>> $json\n" if $ENV{NG_DEBUG} and $ENV{NG_DEBUG} > 1;
    my $req = HTTP::Request->new( 'POST', $self->api_url );
    $req->accept_decodable;
    $req->content($json);
    $req->header( 'Content-Length' => length $req->content );

    my $res = $self->_make_request($req);

    # get the rate limit information from the http response headers
    $self->rate_limit( $res->header('x-ratelimit-limit') );
    $self->rate_limit_remaining( $res->header('x-ratelimit-remaining') );
    $self->rate_limit_reset( $res->header('x-ratelimit-reset') );

    # Slow down if we're approaching the rate limit
    # By the way GitHub mistakes days for minutes in their documentation --
    # the rate limit is per minute, not per day.
    if ( $self->api_throttle ) {
        sleep 2 if (($self->rate_limit_remaining || 0)
            < ($self->rate_limit || 60) / 2);
    }

    print STDERR "<<< " . $res->decoded_content . "\n" if $ENV{NG_DEBUG} and $ENV{NG_DEBUG} > 1;
    return $res if $self->raw_response;
    return $res->decoded_content if $self->raw_string;

    if ($res->header('Content-Type') and $res->header('Content-Type') =~ 'application/json') {
        my $json = $res->decoded_content;
        $data = eval { $self->json->decode($json) };
        unless ($data) {
            # We tolerate bad JSON for errors,
            # otherwise we just rethrow the JSON parsing problem.
            die unless $res->is_error;
            $data = { message => $res->message };
        }
    } else {
        $data = { message => $res->message };
    }

    ## be smarter
    if (wantarray) {
        return @$data if ref $data eq 'ARRAY';
        return %$data if ref $data eq 'HASH';
    }

    return $data;
}

sub _make_request {
  my($self, $req) = @_;

  my $cached_res = $self->_get_shared_cache($req->uri);

  if ($cached_res) {
    $req->header("If-None-Match" => $cached_res->header("ETag"));
    my $res = $self->ua->request($req);

    if ($res->code == 304) {
      return $cached_res;
    }

    $self->_set_shared_cache($req->uri, $res);

    return $res;
  } else {
    my $res = $self->ua->request($req);
    $self->_set_shared_cache( $req->uri, $res);
    return $res;
  }
}

sub _get_shared_cache {
  my ($self, $uri) = @_;
  return $self->cache->get($uri);
}

sub _set_shared_cache {
  my($self, $uri, $response) = @_;
  $self->cache->set($uri, $response);
}

no Moo;

1;
__END__

=head1 NAME

Net::GitHub::V4 - GitHub GraphQL API

=head1 SYNOPSIS

    use Net::GitHub::V4;
    my $gh = Net::GitHub::V4->new(
        access_token => $oauth_token
    );

    my $data = $gh->query(<<IQL);
{
  repository(owner: "octocat", name: "Hello-World") {
    pullRequests(last: 10) {
      edges {
        node {
          number
          mergeable
        }
      }
    }
  }
}
IQL

=head1 DESCRIPTION

L<https://developer.github.com/v4/>

=head2 ATTRIBUTES

=head3 Authentication

=over 4

=item access_token

    my $gh = Net::GitHub::V4->new( access_token => $ENV{GITHUB_ACCESS_TOKEN} );

=back

=head3 raw_response

    my $gh = Net::GitHub::V4->new(
        # login/pass or access_token
        raw_response => 1
    );

return raw L<HTTP::Response> object

=head3 raw_string

    my $gh = Net::GitHub::V4->new(
        # login/pass or access_token
        raw_string => 1
    );

return L<HTTP::Response> response content as string

=head3 api_throttle

    my $gh = Net::GitHub::V4->new(
        # login/pass or access_token
        api_throttle => 0
    );

To disable call rate limiting (e.g. if your account is whitelisted), set B<api_throttle> to 0.

=head3 ua

To set the proxy for ua, you can do something like following

    $gh->ua->proxy('https', 'socks://127.0.0.1:9050');

$gh->ua is an instance of L<LWP::UserAgent>

=head2 METHODS

=head3 query($method, $url, $data)

    my $data = $gh->query(<<IQL);
{
  repository(owner: "octocat", name: "Hello-World") {
    pullRequests(last: 10) {
      edges {
        node {
          number
          mergeable
        }
      }
    }
  }
}
IQL

GitHub GraphQL API

=head1 SEE ALSO

L<Pithub>

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
