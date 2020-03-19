package Net::GitHub::V3::Query;

our $VERSION = '0.97';
our $AUTHORITY = 'cpan:FAYLAND';

use URI;
use JSON::MaybeXS;
use MIME::Base64;
use LWP::UserAgent;
use HTTP::Request;
use Carp qw/croak/;
use URI::Escape;
use Types::Standard qw(Int Str Bool InstanceOf Object HashRef);
use Cache::LRU;

use Scalar::Util qw(looks_like_number);

use Net::GitHub::V3::ResultSet;

use Moo::Role;

# configurable args

# Authentication
has 'login'  => ( is => 'rw', isa => Str, predicate => 'has_login' );
has 'pass'  => ( is => 'rw', isa => Str, predicate => 'has_pass' );
has 'otp'  => ( is => 'rw', isa => Str, predicate => 'has_otp' );
has 'access_token' => ( is => 'rw', isa => Str, predicate => 'has_access_token' );

# return raw unparsed JSON
has 'raw_string' => (is => 'rw', isa => Bool, default => 0);
has 'raw_response' => (is => 'rw', isa => Bool, default => 0);

has 'api_url' => (is => 'ro', default => 'https://api.github.com');
has 'api_throttle' => ( is => 'rw', isa => Bool, default => 1 );

has 'upload_url' => (is => 'ro', default => 'https://uploads.github.com');

# pagination
has 'next_url'  => ( is => 'rw', isa => Str, predicate => 'has_next_page',  clearer => 'clear_next_url' );
has 'last_url'  => ( is => 'rw', isa => Str, predicate => 'has_last_page',  clearer => 'clear_last_url' );
has 'first_url' => ( is => 'rw', isa => Str, predicate => 'has_first_page', clearer => 'clear_first_url' );
has 'prev_url'  => ( is => 'rw', isa => Str, predicate => 'has_prev_page',  clearer => 'clear_prev_url' );
has 'per_page'  => ( is => 'rw', isa => Str, default => 100 );
has 'total_pages'  => ( is => 'rw', isa => Str, default => 0 );

# deprecation
has 'deprecation_url' => ( is => 'rw', isa => Str );
has 'alternate_url'   => ( is => 'rw', isa => Str );

# Error handle
has 'RaiseError' => ( is => 'rw', isa => Bool, default => 1 );

# Rate limits
# has 'rate_limit'           => ( is => 'rw', isa => Int, default => sub { shift->update_rate_limit('rate_limit') } );
# has 'rate_limit_remaining' => ( is => 'rw', isa => Int, default => sub { shift->update_rate_limit('rate_limit_remaining') } );
# has 'rate_limit_reset'     => ( is => 'rw', isa => Str, default => sub { shift->update_rate_limit('rate_limit_reset') } );
has 'rate_limit'           => ( is => 'rw', isa => Int, default => sub { 0 } );
has 'rate_limit_remaining' => ( is => 'rw', isa => Int, default => sub { 0 } );
has 'rate_limit_reset'     => ( is => 'rw', isa => Str, default => sub { 0 } );

# optional
has 'u'  => (is => 'rw', isa => Str);
has 'repo' => (is => 'rw', isa => Str);

# accept version
has 'accept_version' => (is => 'rw', isa => Str, default => '');

has 'is_main_module' => (is => 'ro', isa => Bool, default => 0);

sub update_rate_limit {
    my ( $self, $what ) = @_;

    # If someone calls rate_limit before an API query happens, force these fields to update before giving back a response.
    # Per github: Accessing this endpoint does not count against your REST API rate limit.
    # https://developer.github.com/v3/rate_limit/
    my $content = $self->query('/rate_limit');

    return $self->{$what};
}

sub set_default_user_repo {
    my ($self, $user, $repo) = @_;

    $self->u($user);
    $self->repo($repo);

    # need apply to all sub modules
    if ($self->is_main_module) {
        if ($self->is_repos_init) {
            $self->repos->u($user); $self->repos->repo($repo);
        }
        if ($self->is_issue_init) {
            $self->issue->u($user); $self->issue->repo($repo);
        }
        if ($self->is_pull_request_init) {
            $self->pull_request->u($user); $self->pull_request->repo($repo);
        }
        if ($self->is_git_data_init) {
            $self->git_data->u($user); $self->git_data->repo($repo);
        }
    }

    return $self;
}

sub args_to_pass {
    my $self = shift;
    my $ret;
    foreach my $col ('login', 'pass', 'otp', 'access_token', 'raw_string', 'raw_response', 'api_url', 'api_throttle', 'u', 'repo', 'next_url', 'last_url', 'first_url', 'prev_url', 'per_page', 'ua') {
        my $v = $self->$col;
        $ret->{$col} = $v if defined $v;
    }
    return $ret;
}

has 'ua' => (
    isa     => InstanceOf['LWP::UserAgent'],
    is      => 'ro',
    lazy    => 1,
    default => sub {
        LWP::UserAgent->new(
            agent       => "perl-net-github/$VERSION",
            cookie_jar  => {},
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

# per-page pagination

has 'result_sets' => (
  isa => HashRef,
  is => 'ro',
  default => sub { {} },
);

sub next {
    my $self = shift;
    my ($url) = @_;
    my $result_set;
    $result_set = $self->result_sets->{$url}  or  do {
        $result_set = Net::GitHub::V3::ResultSet->new( url => $url );
        $self->result_sets->{$url} = $result_set;
    };
    my $results    = $result_set->results;
    my $cursor     = $result_set->cursor;
    if ( $cursor > $#$results ) {
        return if $result_set->done;
        my $next_url = $result_set->next_url || $result_set->url;
        my $new_result = $self->query($next_url);
        $result_set->results(ref $new_result eq 'ARRAY' ?
                                 $new_result :
                                 [$new_result]
        );
        $result_set->cursor(0);
        if ($self->has_next_page) {
            $result_set->next_url($self->next_url);
        }
        else {
            $result_set->done(1);
        }
    }
    my $result = $result_set->results->[$result_set->cursor];
    $result_set->cursor($result_set->cursor + 1);
    return $result;
}


sub close {
    my $self = shift;
    my ($url) = @_;
    delete $self->result_sets->{$url};
    return;
}


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
    my $data = shift @args;

    my $ua = $self->ua;

    ## always go with login:pass or access_token (for private repos)
    if ($self->has_access_token) {
        $ua->default_header('Authorization', "token " . $self->access_token);
    } elsif ($self->has_login and $self->has_pass) {
        my $auth_basic = $self->login . ':' . $self->pass;
        $ua->default_header('Authorization', 'Basic ' . encode_base64($auth_basic));
        if ($self->has_otp) {
            $ua->default_header('X-GitHub-OTP', $self->otp);
        }
    }

    $url = $self->api_url . $url unless $url =~ /^https\:/;
    if ($request_method eq 'GET') {
        if ($url !~ /per_page=\d/) {
            ## auto add per_page in url for GET no matter it supports or not
            my $uri = URI->new($url);
            my %query_form = $uri->query_form;
            $query_form{per_page} ||= $self->per_page;
            $uri->query_form(%query_form);
            $url = $uri->as_string;
        }
    }

    print STDERR ">>> $request_method $url\n" if $ENV{NG_DEBUG};
    my $req = HTTP::Request->new( $request_method, $url );
    $req->accept_decodable;
    if ($data) {
        my $json = $self->json->encode($data);
        print STDERR ">>> $json\n" if $ENV{NG_DEBUG} and $ENV{NG_DEBUG} > 1;
        $req->content($json);
    }
    $req->header( 'Content-Length' => length $req->content );

    # if preview API, specify a custom media type to Accept header
    # https://developer.github.com/v3/media/
    $req->header( 'Accept' => sprintf("application/vnd.github.%s.param+json", $self->accept_version) )
        if $self->accept_version;

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

    if ( $self->RaiseError ) {
        # check for 'Client Errors'
        if (not $res->is_success and ref $data eq 'HASH' and exists $data->{message}) {
            my $message = $data->{message};

            # Include any additional error information that was returned by the API
            if (exists $data->{errors}) {
                $message .= ': '.join(' - ',
                                     map { $_->{message} }
                                     grep { exists $_->{message} }
                                     @{ $data->{errors} });
            }
            croak $message;
        }
    }

    $self->_clear_pagination;
    if ($res->header('link')) {
        my @rel_strs = split ',', $res->header('link');
        $self->_extract_link_url(\@rel_strs);
    }

    ## be smarter
    if (wantarray) {
        return @$data if ref $data eq 'ARRAY';
        return %$data if ref $data eq 'HASH';
    }

    return $data;
}

sub set_next_page {
    my ($self, $page) = @_;

    if( ! looks_like_number($page) ){
	    croak "Trying to set_next_page to $page, and not a number\n";
    }

    if( $page > $self->total_page && $page > 0 ){
	    return 0;
    }

    my $temp_url = $self->next_url;
    $temp_url =~ s/([&?])page=[0-9]+([&?]*)/$1page=$page$2/;

    $self->next_url( $temp_url );

    return 1;
}

sub next_page {
    my $self = shift;
    return $self->query($self->next_url);
}

sub prev_page {
    my $self = shift;
    return $self->query($self->prev_url);
}

sub first_page {
    my $self = shift;
    return $self->query($self->first_url);
}

sub last_page {
    my $self = shift;
    return $self->query($self->last_url);
}

sub _clear_pagination {
    my $self = shift;
    foreach my $page (qw/first last prev next/) {
        my $clearer = 'clear_' . $page . '_url';
        $self->$clearer;
    }
    return 1;
}

sub _extract_link_url {
    my ($self, $raw_strs) = @_;
    foreach my $str (@$raw_strs) {
        my ($link_url, $rel) = split ';', $str;

        $link_url =~ s/^\s*//;
        $link_url =~ s/^<//;
        $link_url =~ s/>$//;

        if( $rel =~ m/rel="(next|last|first|prev|deprecation|alternate)"/ ){
            $rel = $1;
        }
        elsif( $rel=~ m/rel="(.*?)"/ ){
            warn "Unexpected link rel='$1' in '$str'";
            next;
        }
        else {
            warn "Unable to process link rel in '$str'";
            next;
        }

        if( $rel eq 'deprecation' ){
            warn "Deprecation warning: $link_url\n";
        }

        my $url_attr = $rel . "_url";
        $self->$url_attr($link_url);

        # Grab, and expose, some additional header information
	if( $rel eq "last" ){
	    $link_url =~ /[\&?]page=([0-9]*)[\&?]*/;
	    $self->total_pages( $1 );
	}
    }

    return 1;
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

## build methods on fly
sub __build_methods {
    my $package = shift;
    my %methods = @_;

    foreach my $m (keys %methods) {
        my $v = $methods{$m};
        my $url = $v->{url};
        my $method = $v->{method} || 'GET';
        my $args = $v->{args} || 0; # args for ->query
        my $check_status = $v->{check_status};
        my $is_u_repo = $v->{is_u_repo}; # need auto shift u/repo
        my $preview_version = $v->{preview};
        my $paginate = $v->{paginate};

        # count how much %s inside u
        my $n = 0; while ($url =~ /\%s/g) { $n++ }

        no strict 'refs';
        no warnings 'once';
        *{"${package}::${m}"} = sub {
            my $self = shift;

            ## if is_u_repo, both ($user, $repo, @args) or (@args) should be supported
            if ( ($is_u_repo or index($url, '/repos/%s/%s') > -1) and @_ < $n + $args) {
                unshift @_, ($self->u, $self->repo);
            }

            # make url, replace %s with real args
            my @uargs = splice(@_, 0, $n);
            my $u = sprintf($url, @uargs);

            # if preview API, set preview version
            $self->accept_version($preview_version) if $preview_version;

            # args for json data POST
            my @qargs = $args ? splice(@_, 0, $args) : ();
            if ($check_status) { # need check Response Status
                my $old_raw_response = $self->raw_response;
                $self->raw_response(1); # need check header
                my $res = $self->query($method, $u, @qargs);
                $self->raw_response($old_raw_response);
                return index($res->header('Status'), $check_status) > -1 ? 1 : 0;
            } else {
                return $self->query($method, $u, @qargs);
            }
        };
        if ($paginate) {
            # Add methods next... and close...
            # Make method names singular (next_comments to next_comment)
            $m =~ s/s$//;
            my $m_name = ref $paginate ? $paginate->{name} : $m;
            *{"${package}::next_${m_name}"} = sub {
                my $self = shift;

                # count how much %s inside u
                my $n = 0; while ($url =~ /\%s/g) { $n++ }

                ## if is_u_repo, both ($user, $repo, @args) or (@args) should be supported
                if ( ($is_u_repo or index($url, '/repos/%s/%s') > -1) and @_ < $n + $args) {
                    unshift @_, ($self->u, $self->repo);
                }

                # make url, replace %s with real args
                my @uargs = map { defined $_ ? $_ : '' } splice(@_, 0, $n);
                my $u = sprintf($url, @uargs);

                # if preview API, set preview version
                $self->accept_version($preview_version) if $preview_version;

                return $self->next($u);
            };
            *{"${package}::close_${m_name}"} = sub {
                my $self = shift;

                # count how much %s inside u
                my $n = 0; while ($url =~ /\%s/g) { $n++ }

                ## if is_u_repo, both ($user, $repo, @args) or (@args) should be supported
                if ( ($is_u_repo or index($url, '/repos/%s/%s') > -1) and @_ < $n + $args) {
                    unshift @_, ($self->u, $self->repo);
                }

                # make url, replace %s with real args
                my @uargs = splice(@_, 0, $n);
                my $u = sprintf($url, @uargs);

                # if preview API, set preview version
                $self->accept_version($preview_version) if $preview_version;

                $self->close($u);
            };
        }
    }
}

no Moo::Role;

1;
__END__

=head1 NAME

Net::GitHub::V3::Query - Base Query role for Net::GitHub::V3

=head1 SYNOPSIS

    package Net::GitHub::V3::XXX;

    use Moo;
    with 'Net::GitHub::V3::Query';

=head1 DESCRIPTION

set Authentication and call API

=head2 ATTRIBUTES

=over 4

=item login

=item pass

=item access_token

Either set access_token from OAuth or login:pass for Basic Authentication

L<http://developer.github.com/>

=item raw_string

=item raw_response

=item api_throttle

API throttling is enabled by default, set api_throttle to 0 to disable it.

=item rate_limit

The maximum number of queries allowed per hour. 60 for anonymous users and
5,000 for authenticated users.

=item rate_limit_remaining

The number of requests remaining in the current rate limit window.

=item rate_limit_reset

The time the current rate limit resets in UTC epoch seconds.

=item update_rate_limit

Query the /rate_limit API (for free) to update the cached values for rate_limit, rate_limit_remaining, rate_limit_reset

=item last_page

Denotes the index of the last page in the pagination

=item RaiseError

=back

=head2 METHODS

=over 4

=item query

Refer L<Net::GitHub::V3>

=item next_page

Calls C<query> with C<next_url>. See L<Net::GitHub::V3>

=item prev_page

Calls C<query> with C<prev_url>. See L<Net::GitHub::V3>

=item first_page

Calls C<query> with C<first_url>. See L<Net::GitHub::V3>

=item last_page

Calls C<query> with C<last_url>. See L<Net::GitHub::V3>

=item set_next_page

Adjusts next_url to be a new url in the pagination space
I.E. you are jumping to a new index in the pagination

=item result_sets

For internal use by the item-per-item pagination: This is a store of
the state(s) for the pagination.  Each entry maps the initial URL of a
GitHub query to a L<Net::GitHub::V3::ResultSet> object.

=item next($url)

Returns the next item for the query which started at $url, or undef if
there are no more items.

=item close($url)

Terminates the item-per-item pagination for the query which started at
$url.


=back

=head3 NG_DEBUG

export NG_DEBUG=1 to view the request URL

NG_DEBUG > 1 to view request/response string

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
