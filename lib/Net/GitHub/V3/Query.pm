package Net::GitHub::V3::Query;

use Any::Moose 'Role';

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI;
use JSON::Any;
use WWW::Mechanize::GZip;
use MIME::Base64;
use HTTP::Request;
use Carp qw/croak/;
use URI::Escape;

# configurable args

# Authentication
has 'login'  => ( is => 'rw', isa => 'Str', predicate => 'has_login' );
has 'pass'  => ( is => 'rw', isa => 'Str', predicate => 'has_pass' );
has 'access_token' => ( is => 'rw', isa => 'Str', predicate => 'has_access_token' );

# return raw unparsed JSON
has 'raw_string' => (is => 'rw', isa => 'Bool', default => 0);
has 'raw_response' => (is => 'rw', isa => 'Bool', default => 0);

has 'api_url' => (is => 'ro', default => 'https://api.github.com');
has 'api_throttle' => ( is => 'rw', isa => 'Bool', default => 1 );

# pagination
has 'next_url'  => ( is => 'rw', isa => 'Str', predicate => 'has_next_page',  clearer => 'clear_next_url' );
has 'last_url'  => ( is => 'rw', isa => 'Str', predicate => 'has_last_page',  clearer => 'clear_last_url' );
has 'first_url' => ( is => 'rw', isa => 'Str', predicate => 'has_first_page', clearer => 'clear_first_url' );
has 'prev_url'  => ( is => 'rw', isa => 'Str', predicate => 'has_prev_page',  clearer => 'clear_prev_url' );

# Error handle
has 'RaiseError' => ( is => 'rw', isa => 'Bool', default => 1 );

# optional
has 'u'  => (is => 'rw', isa => 'Str');
has 'repo' => (is => 'rw', isa => 'Str');

has 'is_main_module' => (is => 'ro', isa => 'Bool', default => 0);
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
    foreach my $col ('login', 'pass', 'access_token', 'raw_string', 'raw_response', 'api_url', 'api_throttle', 'u', 'repo') {
        my $v = $self->$col;
        $ret->{$col} = $v if defined $v;
    }
    return $ret;
}

has 'ua' => (
    isa     => 'WWW::Mechanize::GZip',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return WWW::Mechanize::GZip->new(
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
        return JSON::Any->new( utf8 => 1 );
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
    my $data = shift @args;

    my $ua = $self->ua;

    ## always go with login:pass or access_token (for private repos)
    if ($self->has_access_token) {
        $ua->default_header('Authorization', "token " . $self->access_token);
    } elsif ($self->has_login and $self->has_pass) {
        my $auth_basic = $self->login . ':' . $self->pass;
        $ua->default_header('Authorization', 'Basic ' . encode_base64($auth_basic));
    }

    $url = $self->api_url . $url unless $url =~ /^https\:/;

    my $req = HTTP::Request->new( $request_method, $url );
    if ($data) {
        my $json = $self->json->objToJson($data);
        $req->content($json);
    }
    $req->header( 'Content-Length' => length $req->content );

    my $res = $ua->request($req);

    # Slow down if we're approaching the rate limit
    # By the way GitHub mistakes days for minutes in their documentation --
    # the rate limit is per minute, not per day.
    if ( $self->api_throttle ) {
        sleep 2 if (($res->header('x-ratelimit-remaining') || 0)
            < ($res->header('x-ratelimit-limit') || 60) / 2);
    }

    return $ua->res if $self->raw_response;
    return $ua->content if $self->raw_string;

    if ($res->header('Content-Type') and $res->header('Content-Type') =~ 'application/json') {
        my $json = $ua->content;
        $data = eval { $self->json->jsonToObj($json) };
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
        croak $data->{message} if not $ua->success and ref $data eq 'HASH' and exists $data->{message}; # for 'Client Errors'
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

sub next_page {
    my $self = shift;
    return $self->query($self->next_url);
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

        $rel =~ m/rel="(next|last|first|prev)"/;
        $rel = $1;

        my $url_attr = $rel . "_url";
        $self->$url_attr($link_url);
    }

    return 1;
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

        $package->meta->add_method( $m => sub {
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
        } );
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

=item login

=item pass

=item access_token

either set access_token from OAuth or login:pass for Basic Authentication

L<http://developer.github.com/>

=item raw_string

=item raw_response

=item api_throttle

=item RaiseError

=back

=head2 METHODS

=over 4

=item query

Refer L<Net::GitHub::V3>

=item next_page

Calls C<query> with C<next_url>. See L<Net::GitHub::V3>

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>