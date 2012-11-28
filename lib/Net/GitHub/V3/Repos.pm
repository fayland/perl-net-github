package Net::GitHub::V3::Repos;

use Any::Moose;

our $VERSION = '0.50';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;
use HTTP::Request::Common qw(POST);

with 'Net::GitHub::V3::Query';

sub list {
    my ( $self, $type ) = @_;
    $type ||= 'all';
    my $u = '/user/repos';
    $u .= '?type=' . $type if $type ne 'all';
    return $self->query($u);
}

sub list_user {
    my ($self, $user, $type) = @_;
    $user ||= $self->u;
    $type ||= 'all';
    my $u = "/users/" . uri_escape($user) . "/repos";
    $u .= '?type=' . $type if $type ne 'all';
    return $self->query($u);
}

sub list_org {
    my ($self, $org, $type) = @_;
    $type ||= 'all';
    my $u = "/orgs/" . uri_escape($org) . "/repos";
    $u .= '?type=' . $type if $type ne 'all';
    return $self->query($u);
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

## build methods on fly
my %__methods = (

    get => { url => "/repos/%s/%s" },
    update => { url => "/repos/%s/%s", method => 'PATCH', args => 1 },
    contributors => { url => "/repos/%s/%s/contributors" },
    languages => { url => "/repos/%s/%s/languages" },
    teams     => { url => "/repos/%s/%s/teams" },
    tags      => { url => "/repos/%s/%s/tags" },
    branches  => { url => "/repos/%s/%s/branches" },

    # http://developer.github.com/v3/repos/collaborators/
    collaborators       => { url => "/repos/%s/%s/collaborators" },
    is_collaborator     => { url => "/repos/%s/%s/collaborators/%s", check_status => 204 },
    add_collaborator    => { url => "/repos/%s/%s/collaborators/%s", method => 'PUT', check_status => 204 },
    delete_collaborator => { url => "/repos/%s/%s/collaborators/%s", method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/repos/commits/
    commits  => { url => "/repos/%s/%s/commits" },
    commit   => { url => "/repos/%s/%s/commits/%s" },
    comments => { url => "/repos/%s/%s/comments" },
    comment  => { url => "/repos/%s/%s/comments/%s" },
    commit_comments => { url => "/repos/%s/%s/commits/%s/comments" },
    create_comment => { url => "/repos/%s/%s/commits/%s/comments", method => 'POST', args => 1 },
    update_comment => { url => "/repos/%s/%s/comments/%s", method => 'PATCH', args => 1 },
    delete_comment => { url => "/repos/%s/%s/comments/%s", method => 'DELETE', check_status => 204 },
    compare_commits => { url => "/repos/%s/%s/compare/%s...%s" },

    # http://developer.github.com/v3/repos/contents/
    readme => { url => "/repos/%s/%s/readme" },
    get_content => { url => "/repos/%s/%s/contents/%s" },

    # http://developer.github.com/v3/repos/downloads/
    downloads => { url => "/repos/%s/%s/downloads" },
    download  => { url => "/repos/%s/%s/downloads/%s" },
    delete_download => { url => "/repos/%s/%s/downloads/%s", method => 'DELETE', check_status => 204 },

    forks => { url => "/repos/%s/%s/forks" },

    # http://developer.github.com/v3/repos/keys/
    keys => { url => "/repos/%s/%s/keys" },
    key  => { url => "/repos/%s/%s/keys/%s" },
    create_key => { url => "/repos/%s/%s/keys", method => 'POST', args => 1 },
    update_key => { url => "/repos/%s/%s/keys/%s", method => 'PATCH', check_status => 204, args => 1 },
    delete_key => { url => "/repos/%s/%s/keys/%s", method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/repos/watching/
    watchers => { url => "/repos/%s/%s/watchers" },
    is_watching => { url => "/user/watched/%s/%s", is_u_repo => 1, check_status => 204 },
    watch   => { url => "/user/watched/%s/%s", is_u_repo => 1, method => 'PUT', check_status => 204 },
    unwatch => { url => "/user/watched/%s/%s", is_u_repo => 1, method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/repos/hooks/
    hooks => { url => "/repos/%s/%s/hooks" },
    hook  => { url => "/repos/%s/%s/hooks/%s" },
    delete_hook => { url => "/repos/%s/%s/hooks/%s", method => 'DELETE', check_status => 204 },
    test_hook   => { url => "/repos/%s/%s/hooks/%s/test", method => 'POST', check_status => 204 },
    create_hook => { url => "/repos/%s/%s/hooks", method => 'POST',  args => 1 },
    update_hook => { url => "/repos/%s/%s/hooks/%s", method => 'PATCH', args => 1 },

    # http://developer.github.com/v3/repos/merging/
    merges => { url => "/repos/%s/%s/merges", method => 'POST', args => 1 },

    # http://developer.github.com/v3/repos/statuses/
    list_statuses => { url => "/repos/%s/%s/statuses/%s" },
    create_status => { url => "/repos/%s/%s/statuses/%s", method => 'POST', args => 1 },
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

no Any::Moose;
__PACKAGE__->meta->make_immutable;

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

=item list_user

=item list_org

    my @rp = $repos->list; # or my $rp = $repos->list;
    my @rp = $repos->list('private');
    my @rp = $repos->list_user('c9s');
    my @rp = $repos->list_user('c9s', 'member');
    my @rp = $repos->list_org('perlchina');
    my @rp = $repos->list_org('perlchina', 'public');

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

=back

=head3 Repo Collaborators API

L<http://developer.github.com/v3/repos/collaborators/>

=over 4

=item collaborators

=item is_collaborator

=item add_collaborator

=item delete_collaborator

    my @collaborators = $repos->collaborators;
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
    my $commit  = $repos->commit($sha);

=item comments

=item commit_comments

=item create_comment

=item comment

=item update_comment

=item delete_comment

    my @comments = $repos->comments;
    my @comments = $repos->commit_comments($sha);
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

=head3 Downloads

L<http://developer.github.com/v3/repos/downloads/>

=over 4

=item downloads

=item download

=item delete_download

    my @downloads = $repos->downloads;
    my $download  = $repos->download($download_id);
    my $st = $repos->delete_download($download_id);

=item create_download

=item upload_download

    my $download = $repos->create_download( {
        "name" => "new_file.jpg",
        "size" => 114034,
        "description" => "Latest release",
        "content_type" => "text/plain"
    } );
    my $st = $repos->upload_download($download, "/path/to/new_file.jpg");

    # or batch it
    my $st = $repos->create_download( {
        "name" => "new_file.jpg",
        "size" => 114034,
        "description" => "Latest release",
        "content_type" => "text/plain",
        file => '/path/to/new_file.jpg',
    } );

=back

=head3 Forks API

L<http://developer.github.com/v3/repos/forks/>

=over 4

=item forks

=item create_fork

    my @forks = $repos->forks;
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

=head3 Hooks API

L<http://developer.github.com/v3/repos/hooks/>

=over 4

=item hooks

=item hook

=item create_hook

=item update_hook

=item test_hook

=item delete_hook

    my @hooks = $repos->hooks;
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

    my @statuses = $repos->list_statuses($sha1);

=item create_status

    my $status = $repos->create_status( {
        "state" => "success",
        "target_url" => "https://example.com/build/status",
        "description" => "The build succeeded!"
    } );

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>