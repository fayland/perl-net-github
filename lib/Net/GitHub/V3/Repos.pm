package Net::GitHub::V3::Repos;

use Moo;

our $VERSION = '1.05';
our $AUTHORITY = 'cpan:FAYLAND';

use Carp;
use URI::Escape;
use URI;
use HTTP::Request::Common qw(POST);

with 'Net::GitHub::V3::Query';

sub list {
    my ( $self, $args ) = @_;

    return $self->query(_repos_arg2url($args));
}


sub next_repo {
    my ( $self, $args ) = @_;

    return $self->next(_repos_arg2url($args));
}

sub close_repo {
    my ( $self, $args ) = @_;

    return $self->close(_repos_arg2url($args));
}

sub _repos_arg2url {
    my ($args) = @_;

    # for old
    unless (ref($args) eq 'HASH') {
        $args = { type => $args };
    }

    my $uri = URI->new('/user/repos');
    $uri->query_form($args);
    return $uri->as_string;
}


sub list_all {
    my ( $self, $since ) = @_;

    return $self->query(_all_repos_arg2url($since));
}

sub next_all_repo {
    my ( $self, $since ) = @_;

    return $self->next(_all_repos_arg2url($since));
}

sub close_all_repo {
    my ( $self, $since ) = @_;

    return $self->close(_all_repos_arg2url($since));
}

sub _all_repos_arg2url {
    my ( $since ) = @_;
    $since ||= 'first';
    my $u = '/repositories';
    $u .= '?since=' . $since if $since ne 'first';
    return $u;
}

sub list_user {
    my $self = shift;

    return $self->query($self->_user_repos_arg2url(@_));
}

sub next_user_repo {
    my $self = shift;

    return $self->next($self->_user_repos_arg2url(@_));
}

sub close_user_repo {
    my $self = shift;

    return $self->close($self->_user_repos_arg2url(@_));
}

sub _user_repos_arg2url {
    my ($self, $user, $args) = @_;
    $user ||= $self->u;

    # for old
    unless (ref($args) eq 'HASH') {
        $args = { type => $args };
    }

    my $uri = URI->new("/users/" . uri_escape($user) . "/repos");
    $uri->query_form($args);
    return $uri->as_string;
}

sub list_org {
    my $self = shift;

    return $self->query($self->_org_repos_arg2url(@_));
}

sub next_org_repo {
    my $self = shift;

    return $self->next($self->_org_repos_arg2url(@_));
}

sub close_org_repo {
    my $self = shift;

    return $self->close($self->_org_repos_arg2url(@_));
}

sub _org_repos_arg2url {
    my ($self, $org, $type) = @_;
    $type ||= 'all';
    my $u = "/orgs/" . uri_escape($org) . "/repos";
    $u .= '?type=' . $type if $type ne 'all';
    return $u;
}


sub create {
    my ( $self, $data ) = @_;

    my $u = '/user/repos';
    if (exists $data->{org}) {
        my $o = delete $data->{org};
        $u = "/orgs/" . uri_escape($o) . "/repos";
    }

    return $self->query('POST', $u, $data);
}

sub upload_asset {
    my $self = shift;
    unshift @_, $self->u, $self->repo if @_ < 5;
    my ($user, $repos, $release_id, $name, $content_type, $file_content) = @_;

    my $ua = $self->ua;
    my $url = $self->upload_url . "/repos/$user/$repos/releases/$release_id/assets?name=" . uri_escape($name);
    my $req = HTTP::Request->new( 'POST', $url );
    $req->accept_decodable;
    $req->content($file_content);
    $req->header( 'Content-Type', $content_type );

    my $res = $ua->request($req);

    my $data;
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

    return wantarray ? %$data : $data;
}

sub commits {
    my $self = shift;

    return $self->query($self->_commits_arg2url(@_));
}

sub next_commit {
    my $self = shift;

    return $self->next($self->_commits_arg2url(@_));
}

sub close_commit {
    my $self = shift;

    return $self->close($self->_commits_arg2url(@_));
}

sub _commits_arg2url {
    my $self = shift;
    if (@_ < 2) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $args) = @_;

    my $uri = URI->new("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/commits');
    $uri->query_form($args);
    return $uri->as_string;
}



sub list_deployments {
    my $self = shift;

    return $self->query($self->deployments_arg2url(@_));
}

sub next_deployment {
    my $self = shift;

    return $self->next($self->deployments_arg2url(@_));
}

sub close_deployment {
    my $self = shift;

    return $self->close($self->deployments_arg2url(@_));
}

sub _deployments_arg2url {
    my $self = shift;
    if (@_ < 2) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $args) = @_;

    my $uri = URI->new("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/deployments');
    $uri->query_form($args);
    return $uri->as_string;
}


## build methods on fly
my %__methods = (

    get => { url => "/repos/%s/%s" },
    update => { url => "/repos/%s/%s", method => 'PATCH', args => 1 },
    contributors => { url => "/repos/%s/%s/contributors", paginate => 1 },
    languages => { url => "/repos/%s/%s/languages" },
    teams     => { url => "/repos/%s/%s/teams", paginate => 1 },
    tags      => { url => "/repos/%s/%s/tags", paginate => 1 },
    branches  => { url => "/repos/%s/%s/branches", paginate => 1 },
    branch => { url => "/repos/%s/%s/branches/%s" },
    delete => { url => "/repos/%s/%s", method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/repos/collaborators/
    collaborators       => { url => "/repos/%s/%s/collaborators", paginate => 1 },
    is_collaborator     => { url => "/repos/%s/%s/collaborators/%s", check_status => 204 },
    add_collaborator    => { url => "/repos/%s/%s/collaborators/%s", method => 'PUT', check_status => 204 },
    delete_collaborator => { url => "/repos/%s/%s/collaborators/%s", method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/repos/commits/
    commit   => { url => "/repos/%s/%s/commits/%s" },
    comments => { url => "/repos/%s/%s/comments", paginate => 1 },
    comment  => { url => "/repos/%s/%s/comments/%s" },
    commit_comments => { url => "/repos/%s/%s/commits/%s/comments", paginate => 1 },
    create_comment => { url => "/repos/%s/%s/commits/%s/comments", method => 'POST', args => 1 },
    update_comment => { url => "/repos/%s/%s/comments/%s", method => 'PATCH', args => 1 },
    delete_comment => { url => "/repos/%s/%s/comments/%s", method => 'DELETE', check_status => 204 },
    compare_commits => { url => "/repos/%s/%s/compare/%s...%s" },

    # http://developer.github.com/v3/repos/contents/
    readme => { url => "/repos/%s/%s/readme" },
    get_content => { url => "/repos/:owner/:repo/contents/:path", v => 2 },

    # http://developer.github.com/v3/repos/downloads/
    downloads => { url => "/repos/%s/%s/downloads", paginate => 1 },
    download  => { url => "/repos/%s/%s/downloads/%s" },
    delete_download => { url => "/repos/%s/%s/downloads/%s", method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/repos/releases/
    releases => { url => "/repos/%s/%s/releases", paginate => 1 },
    release  => { url => "/repos/%s/%s/releases/%s" },
    create_release => { url => "/repos/%s/%s/releases", method => 'POST', args => 1 },
    update_release => { url => "/repos/%s/%s/releases/%s", method => 'PATCH', args => 1 },
    delete_release => { url => "/repos/%s/%s/releases/%s", method => 'DELETE', check_status => 204 },

    release_assets => { url => "/repos/%s/%s/releases/%s/assets", paginate => 1 },
    release_asset => { url => "/repos/%s/%s/releases/%s/assets/%s" },
    update_release_asset => { url => "/repos/%s/%s/releases/%s/assets/%s", method => 'PATCH', args => 1 },
    delete_release_asset => { url => "/repos/%s/%s/releases/%s/assets/%s", method => 'DELETE', check_status => 204 },

    forks => { url => "/repos/%s/%s/forks", paginate => 1 },

    # http://developer.github.com/v3/repos/keys/
    keys => { url => "/repos/%s/%s/keys", paginate => 1 },
    key  => { url => "/repos/%s/%s/keys/%s" },
    create_key => { url => "/repos/%s/%s/keys", method => 'POST', args => 1 },
    update_key => { url => "/repos/%s/%s/keys/%s", method => 'PATCH', check_status => 204, args => 1 },
    delete_key => { url => "/repos/%s/%s/keys/%s", method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/repos/watching/
    watchers => { url => "/repos/%s/%s/watchers", paginate => 1 },
    is_watching => { url => "/user/watched/%s/%s", is_u_repo => 1, check_status => 204 },
    watch   => { url => "/user/watched/%s/%s", is_u_repo => 1, method => 'PUT', check_status => 204 },
    unwatch => { url => "/user/watched/%s/%s", is_u_repo => 1, method => 'DELETE', check_status => 204 },

    subscribers   => { url => "/repos/%s/%s/subscribers", paginate => 1 },
    subscription  => { url => "/repos/%s/%s/subscription" },
    is_subscribed => { url => "/repos/%s/%s/subscription", check_status => 200 },
    subscribe     => { url => "/repos/%s/%s/subscription", method => 'PUT',
        check_status => 200, args => 1 },
    unsubscribe   => { url => "/repos/%s/%s/subscription", method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/repos/hooks/
    hooks => { url => "/repos/%s/%s/hooks", paginate => 1 },
    hook  => { url => "/repos/%s/%s/hooks/%s" },
    delete_hook => { url => "/repos/%s/%s/hooks/%s", method => 'DELETE', check_status => 204 },
    test_hook   => { url => "/repos/%s/%s/hooks/%s/test", method => 'POST', check_status => 204 },
    create_hook => { url => "/repos/%s/%s/hooks", method => 'POST',  args => 1 },
    update_hook => { url => "/repos/%s/%s/hooks/%s", method => 'PATCH', args => 1 },

    # http://developer.github.com/v3/repos/merging/
    merges => { url => "/repos/%s/%s/merges", method => 'POST', args => 1 },

    # http://developer.github.com/v3/repos/statuses/
    list_statuses => { url => "/repos/%s/%s/statuses/%s", paginate => { name => 'status' } },
    create_status => { url => "/repos/%s/%s/statuses/%s", method => 'POST', args => 1 },

    # https://developer.github.com/v3/repos/deployments
    create_deployment => { url => "/repos/%s/%s/deployments", method => 'POST', args => 1 },
    create_deployment_status => { url => "/repos/%s/%s/deployments/%s/statuses", method => 'POST', args => 1},
    list_deployment_statuses => { url => "/repos/%s/%s/deployments/%s/statuses", method => 'GET', paginate => { name => 'deployment_status' } },

    contributor_stats => { url => "/repos/%s/%s/stats/contributors", method => 'GET'},
    commit_activity => { url => "/repos/%s/%s/stats/commit_activity", method => 'GET'},
    code_frequency => { url => "/repos/%s/%s/stats/code_frequency", method => 'GET'},
    participation => { url => "/repos/%s/%s/stats/participation", method => 'GET'},
    punch_card => { url => "/repos/%s/%s/stats/punch_card", method => 'GET'},

    # https://docs.github.com/en/rest/branches/branch-protection
    branch_protection => { url => "/repos/%s/%s/branches/%s/protection", method => 'GET'},
    delete_branch_protection => { url => "/repos/%s/%s/branches/%s/protection", method => 'DELETE', check_status => 204 },
    update_branch_protection => { url => "/repos/%s/%s/branches/%s/protection", method => 'PUT', args => 1 },
);
__build_methods(__PACKAGE__, %__methods);

sub create_download {
    my $self = shift;

    if (@_ == 1) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $download) = @_;

    my $file = delete $download->{file};

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/downloads';
    my $d = $self->query('POST', $u, $download);
    if (defined $file) {
        return $self->upload_download($d, $file);
    } else {
        return $d;
    }
}

sub upload_download {
    my $self = shift;

    if (@_ < 3) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $download, $file) = @_;

    # must successful on create_download
    return 0 unless exists $download->{s3_url};

    ## POST form-data
    my %data = (
        Content_Type => 'form-data',
        Content      => [
            'key'                   => $download->{path},
            'acl'                   => $download->{acl},
            'success_action_status' => 201,
            'Filename'              => $download->{name},
            'AWSAccessKeyId'        => $download->{accesskeyid},
            'Policy'                => $download->{policy},
            'Signature'             => $download->{signature},
            'Content-Type'          => $download->{mime_type},
            'file'                  => [ $file ],
        ],
    );
    my $request = POST $download->{s3_url}, %data;
    my $res = $self->ua->request($request);
    return $res->code == 201 ? 1 : 0;
}

## http://developer.github.com/v3/repos/forks/
sub create_fork {
    my $self = shift;

    if (@_ < 2) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $org) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/forks';
    $u .= '?org=' . $org if defined $org;
    return $self->query('POST', $u);
}

## http://developer.github.com/v3/repos/watching/
sub watched {
    my ($self, $user) = @_;

    my $u = $user ? '/users/' . uri_escape($user). '/watched' : '/user/watched';
    return $self->query($u);
}

no Moo;

1;
__END__

=head1 NAME

Net::GitHub::V3::Repos - GitHub Repos API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $repos = $gh->repos;

    # set :user/:repo for simple calls
    $repos->set_default_user_repo('fayland', 'perl-net-github');
    my @contributors = $repos->contributors; # don't need pass user and repos


=head1 DESCRIPTION

=head2 METHODS

=head3 Repos

L<http://developer.github.com/v3/repos/>

=over 4

=item list

=item list_all

    # All public repositories on Github
    my @rp = $repos->list_all;
    # starting at id 500
    my @rp = $repos->list_all(500);

=item list_user

=item list_org

    my @rp = $repos->list; # or my $rp = $repos->list;
    my @rp = $repos->list({
        type => 'private'
        sort => 'updated'
    });
    my @rp = $repos->list_user('c9s');
    my @rp = $repos->list_user('c9s', {
        type => 'member'
    });
    my @rp = $repos->list_org('perlchina');
    my @rp = $repos->list_org('perlchina', 'public');

=item next_repo, next_all_repo, next_user_repo, next_org_repo

    # Iterate over your repositories
    while (my $repo = $repos->next_repo) { ...; }
    # Iterate over all public repositories
    while (my $repo = $repos->next_all_repo(500)) { ...; }
    # Iterate over repositories of another user
    while (my $repo = $repos->next_user_repo('c9s')) { ...; }
    # Iterate over repositories of an organisation
    while (my $repo = $repos->next_org_repo('perlchina','public')) { ...; }

=item create

    # create for yourself
    my $rp = $repos->create( {
        "name" => "Hello-World",
        "description" => "This is your first repo",
        "homepage" => "https://github.com"
    } );
    # create for organization
    my $rp = $repos->create( {
        "org"  => "perlchina", ## the organization
        "name" => "Hello-World",
        "description" => "This is your first repo",
        "homepage" => "https://github.com"
    } );

=item get

    my $rp = $repos->get('fayland', 'perl-net-github');

=back

B<To ease the keyboard, we provied two ways to call any method which starts with :user/:repo>

1. SET user/repos before call methods below

    $gh->set_default_user_repo('fayland', 'perl-net-github'); # take effects for all $gh->
    $repos->set_default_user_repo('fayland', 'perl-net-github'); # only take effect to $gh->repos
    my @contributors = $repos->contributors;

2. If it is just for once, we can pass :user, :repo before any arguments

    my @contributors = $repos->contributors($user, $repo);

=over 4

=item update

    $repos->update({ homepage => 'https://metacpan.org/module/Net::GitHub' });

=item delete

    $repos->delete();

=item contributors

=item languages

=item teams

=item tags

=item contributors

    my @contributors = $repos->contributors;
    my @languages = $repos->languages;
    my @teams = $repos->teams;
    my @tags = $repos->tags;
    my @branches = $repos->branches;
    my $branch = $repos->branch('master');
    while (my $contributor = $repos->next_contributor) { ...; }
    while (my $team = $repos->next_team) { ... ; }
    while (my $tags = $repos->next_tag) { ... ; }

=back

=head3 Repo Collaborators API

L<http://developer.github.com/v3/repos/collaborators/>

=over 4

=item collaborators

=item is_collaborator

=item add_collaborator

=item delete_collaborator

    my @collaborators = $repos->collaborators;
    while (my $collaborator = $repos->next_collaborator) { ...; }
    my $is = $repos->is_collaborator('fayland');
    $repos->add_collaborator('fayland');
    $repos->delete_collaborator('fayland');

=back

=head3 Commits API

L<http://developer.github.com/v3/repos/commits/>

=over 4

=item commits

=item commit

    my @commits = $repos->commits;
    my @commits = $repos->commits({
        author => 'fayland'
    });
    my $commit  = $repos->commit($sha);
    while (my $commit = $repos->next_commit({...})) { ...; }

=item comments

=item commit_comments

=item create_comment

=item comment

=item update_comment

=item delete_comment

    my @comments = $repos->comments;
    while (my $comment = $repos->next_comment) { ...; }
    my @comments = $repos->commit_comments($sha);
    while (my $comment = $repos->next_commit_comment($sha)) { ...; }
    my $comment  = $repos->create_comment($sha, {
        "body" => "Nice change",
        "commit_id" => "6dcb09b5b57875f334f61aebed695e2e4193db5e",
        "line" => 1,
        "path" => "file1.txt",
        "position" => 4
    });
    my $comment = $repos->comment($comment_id);
    my $comment = $repos->update_comment($comment_id, {
        "body" => "Nice change"
    });
    my $st = $repos->delete_comment($comment_id);

=item compare_commits

    my $diffs = $repos->compare_commits($base, $head);

=back

=head3 Forks API

L<http://developer.github.com/v3/repos/forks/>

=over 4

=item forks

=item create_fork

    my @forks = $repos->forks;
    while (my $fork = $repos->next_fork) { ...; }
    my $fork = $repos->create_fork;
    my $fork = $repos->create_fork($org);

=back

=head3 Repos Deploy Keys API

L<http://developer.github.com/v3/repos/keys/>

=over 4

=item keys

=item key

=item create_key

=item update_key

=item delete_key

    my @keys = $repos->keys;
    while (my $key = $repos->next_key) { ...; }
    my $key  = $repos->key($key_id); # get key
    $repos->create_key( {
        title => 'title',
        key   => $key
    } );
    $repos->update_key($key_id, {
        title => $title,
        key   => $key
    });
    $repos->delete_key($key_id);

=back

=head3 Repo Watching API

L<http://developer.github.com/v3/repos/watching/>

=over 4

=item watchers

    my @watchers = $repos->watchers;
    while (my $watcher = $repos->next_watcher) { ...; }

=item watched

    my @repos = $repos->watched; # what I watched
    my @repos = $repos->watched('c9s');

=item is_watching

    my $is_watching = $repos->is_watching;
    my $is_watching = $repos->is_watching('fayland', 'perl-net-github');

=item watch

=item unwatch

    my $st = $repos->watch();
    my $st = $repos->watch('fayland', 'perl-net-github');
    my $st = $repos->unwatch();
    my $st = $repos->unwatch('fayland', 'perl-net-github');

=back

=head3 Subscriptions

Github changed the ideas of Watchers (stars) and Subscriptions (new watchers).

    https://github.com/blog/1204-notifications-stars

The Watchers code in this module predates the terminology change, so the new
Watcher methods use the GitHub 'subscription' terminology.

=over 4

=item subscribers

Returns a list of subscriber data hashes.

=item next_subscriber

Returns the next subscriber in the list, or undef if there are no more subscribers.

=item is_subscribed

Returns true or false if you are subscribed

    $repos->is_subscribed();
    $repos->is_subscribed('fayland','perl-net-github');

=item subscription

Returns more information about your subscription to a repo.
is_subscribed is a shortcut to calling this and checking for
subscribed => 1.

=item subscribe

Required argument telling github if you want to subscribe or if you want
to ignore mentions. If you want to change from subscribed to ignores you
need to unsubscribe first.

    $repos->subscribe('fayland','perl-net-github', { subscribed => 1 })
    $repos->subscribe('fayland','perl-net-github', { ignored => 1 })

=item unsubscribe

    $repos->unsubscribe('fayland','perl-net-github');

=back

=head3 Hooks API

L<http://developer.github.com/v3/repos/hooks/>

=over 4

=item hooks

=item next_hook

=item hook

=item create_hook

=item update_hook

=item test_hook

=item delete_hook

    my @hooks = $repos->hooks;
    while (my $hook = $repos->next_hook) { ...; }
    my $hook  = $repos->hook($hook_id);
    my $hook  = $repos->create_hook($hook_hash);
    my $hook  = $repos->update_hook($hook_id, $new_hook_hash);
    my $st    = $repos->test_hook($hook_id);
    my $st    = $repos->delete_hook($hook_id);

=back

=head3 Repo Merging API

L<http://developer.github.com/v3/repos/merging/>

=over 4

=item merges

    my $status = $repos->merges( {
        "base" => "master",
        "head" => "cool_feature",
        "commit_message" => "Shipped cool_feature!"
    } );

=back

=head3 Repo Statuses API

L<http://developer.github.com/v3/repos/statuses/>

=over 4

=item list_statuses

    $gh->set_default_user_repo('fayland', 'perl-net-github');
    my @statuses = $repos->lists_statuses($sha);

Or:

    my @statuses = $repos->list_statuses('fayland', 'perl-net-github', $sha);

=item next_status

    while (my $status = $repos->next_status($sha)) { ...; }

=item create_status

    $gh->set_default_user_repo('fayland', 'perl-net-github');
    my %payload = {
        "state"       => "success",
        "target_url"  => "https://example.com/build/status",
        "description" => "The build succeeded!",
        "context"     => "build/status"
    };
    my $status = $repos->create_status($sha, %payload);

Or:

    my %payload = {
        "state"       => "success",
        "target_url"  => "https://example.com/build/status",
        "description" => "The build succeeded!",
        "context"     => "build/status"
    };
    my $status = $repos->create_status(
        'fayland', 'perl-net-github', $sha, %payload
    );

=back

=head3 Repo Releases API

L<http://developer.github.com/v3/repos/releases/>

=over 4

=item releases

    my @releases = $repos->releases();
    while (my $release = $repos->next_release) { ...; }

=item release

    my $release = $repos->release($release_id);

=item create_release

    my $release = $repos->create_release({
      "tag_name" => "v1.0.0",
      "target_commitish" => "master",
      "name" => "v1.0.0",
      "body" => "Description of the release",
      "draft" => \1,
    });

=item update_release

    my $release = $repos->update_release($release_id, {
      "tag_name" => "v1.0.0",
      "target_commitish" => "master",
      "name" => "v1.0.0",
      "body" => "Description of the release",
    });

=item delete_release

    $repos->delete_release($release_id);

=item release_assets

    my @release_assets = $repos->release_assets($release_id);
    while (my $asset = $repos->next_release_asset($release_id)) { ...; }

=item upload_asset

    my $asset = $repos->upload_asset($release_id, $name, $content_type, $file_content);

Check examples/upload_asset.pl for a working example.

=item release_asset

    my $release_asset = $repos->release_asset($release_id, $asset_id);

=item update_release_asset

    my $release_asset = $repos->update_release_asset($release_id, $asset_id, {
        name" => "foo-1.0.0-osx.zip",
        "label" => "Mac binary"
    });

=item delete_release_asset

    my $ok = $repos->delete_release_asset($release_id, $asset_id);

=back

=head3 Contents API

L<https://developer.github.com/v3/repos/contents/>

=over 4

=item get_content

Gets the contents of a file or directory in a repository.
Specify the file path or directory in $path.
If you omit $path, you will receive the contents of all files in the repository.

    my $response = $repos->get_content( $owner, $repo, $path )
        or
        $repos->get_content(
            { owner => $owner,  repo => $repo, path => $path },
         )
        or
        $repos->get_content(
            { owner => $owner,  repo => $repo, path => $path },
            { ref => 'feature-branch' }
         )

=back

=head3 Repo Deployment API

L<http://developer.github.com/v3/repos/deployments/>

=over 4

=item list_deployments

    my $response = $repos->list_deployments( $owner, $repo, {
        'ref' => 'feature-branch',
    });

=item next_deployment

    while (my $deployment = $repos->next_deployment( $owner, $repo, {
        'ref' => 'feature-branch',
    }) { ...; }

=item create_deployment

    my $response = $repos->create_deployment( $owner, $repo, {
      "ref" => 'feature-branch',
      "description" => "deploying my new feature",
    });

=item list_deployment_statuses

    my $response = $repos->list_deployment_statuses( $owner, $repo, $deployment_id );

=item next_deployment_status

    while (my $status = next_deployment_status($o,$r,$id)) { ...; }

=item create_deployment_status

    my $response = $repos->create_deployment_status( $owner, $repo, $deployment_id, {
        "state": "success",
        "target_url": "https://example.com/deployment/42/output",
        "description": "Deployment finished successfully."
    });

=back

=head3 Repo Statistics API

L<http://developer.github.com/v3/repos/statistics/>

=over 4

=item contributor stats

=item commit activity

=item code frequency

=item participation

=item punch card

    my $contributor_stats   = $repos->contributor_stats($owner, $repo);
    my $commit_activity     = $repos->commit_activity($owner, $repo);
    my $code_freq           = $repos->code_frequency($owner, $repo);
    my $participation       = $repos->participation($owner, $repo);
    my $punch_card          = $repos->punch_card($owner, $repo);

=back

=head3 Branch Protection API

L<https://docs.github.com/en/rest/branches/branch-protection>

=over 4

=item branch_protection

    my $protection = $repos->branch_protection('fayland', 'perl-net-github', 'master');

=item delete_branch_protection

    $repos->delete_branch_protection('fayland', 'perl-net-github', 'master');

=item update_branch_protection

    $repos->update_branch_protection('fayland', 'perl-net-github', 'master', {
        allow_deletions => \0,
        allow_force_pushes => \0,
        block_creations => \1,
        enforce_admins => \1,
        required_conversation_resolution => \1,
        required_linear_history => \0,
        required_pull_request_reviews => {
            dismiss_stale_reviews => \1,
            require_code_owner_reviews => \1,
            required_approving_review_count => 2,
        },
        required_status_checks => {
            strict => \1,
            contexts => []
        },
        restrictions => undef,
    });

=back 

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
