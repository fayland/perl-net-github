package Net::GitHub::V3::Repos;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;
use HTTP::Request::Common qw(POST);

with 'Net::GitHub::V3::Query';

has 'user'  => (is => 'rw', isa => 'Str');
has 'repos' => (is => 'rw', isa => 'Str');

sub list {
    my ( $self, $type ) = @_;
    $type ||= 'all';
    my $u = '/user/repos';
    $u .= '?type=' . $type if $type ne 'all';
    return $self->query($u);
}

sub list_user {
    my ($self, $user, $type) = @_;
    $user ||= $self->user;
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

sub get {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos));
}

sub update {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $new_repos) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos);
    return $self->query('PATCH', $u, $new_repos);
}

sub contributors {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/contributors');
}
sub languages {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/languages');
}
sub teams {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/teams');
}
sub tags {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/tags');
}
sub branches {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/branches');
}

## http://developer.github.com/v3/repos/collaborators/

sub collaborators {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/collaborators');
}

sub is_collaborator {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $collaborator) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/collaborators/' . uri_escape($collaborator);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query($u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub add_collaborator {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $collaborator) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/collaborators/' . uri_escape($collaborator);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('PUT', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}
sub delete_collaborator {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $collaborator) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/collaborators/' . uri_escape($collaborator);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

## http://developer.github.com/v3/repos/commits/

sub commits {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/commits');
}

sub commit {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $sha1) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/commits/' . uri_escape($sha1);
    return $self->query($u);
}

sub comments {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/comments');
}
sub commit_comments {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $sha1) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/commits/' . uri_escape($sha1) . '/comments';
    return $self->query($u);
}
sub create_comment {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $sha1, $comment) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/commits/' . uri_escape($sha1) . '/comments';
    return $self->query('POST', $u, $comment);
}
sub comment {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/comments/' . uri_escape($cid);
    return $self->query($u);
}
sub update_comment {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid, $comment) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/comments/' . uri_escape($cid);
    return $self->query('PATCH', $u, $comment);
}

sub delete_comment {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/comments/' . uri_escape($cid);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub compare_commits {
    my $self = shift;
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $base, $head) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/compare/' . uri_escape($base) . '...' . uri_escape($head);
    return $self->query($u);
}

## http://developer.github.com/v3/repos/downloads/

sub downloads {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/downloads');
}
sub download {
    my $self = shift;
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/downloads/' . uri_escape($cid);
    return $self->query($u);
}

sub delete_download {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/downloads/' . uri_escape($cid);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub create_download {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
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
        unshift @_, $self->repos;
        unshift @_, $self->user;
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
    my $request = POST $result->{s3_url}, %data;
    my $res = $self->ua->request($request);
    return $res->code == 201 ? 1 : 0;
}

## http://developer.github.com/v3/repos/forks/

sub forks {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/forks');
}

sub create_fork {
    my $self = shift;
    
    if (@_ < 2) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $org) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/forks';
    $u .= '?org=' . $org if defined $org;
    return $self->query('POST', $u);
}

## http://developer.github.com/v3/repos/keys/

sub keys {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/forks');
}
sub key {
    my $self = shift;
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/keys/' . uri_escape($cid);
    return $self->query($u);
}
sub create_key {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $title, $key ) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/keys';

    unless (ref $title eq 'HASH') { # title can be a hashref
        $title = {
            title => $title,
            key => $key
        }
    }
    return $self->query('POST', $u, $title);
        
}
sub update_key {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $key_id, $new_key) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/keys/' . uri_escape($key_id);
    return $self->query('PATCH', $u, $new_key);
}
sub delete_key {
    my $self = shift;
    
    if (@_ < 2) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $key_id) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/keys/' . uri_escape($key_id);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

## http://developer.github.com/v3/repos/watching/

sub watchers {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/watchers');
}

sub watched {
    my ($self, $user) = @_;
    
    if ($user) {
        return $self->query('/users/' . uri_escape($user). '/watched');
    } else {
        return $self->query('/user/watched');
    }
}

sub is_watching {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    
    # /user/watched/:user/:repo
    my $u = "/user/watched/" . uri_escape($user) . "/" . uri_escape($repos);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query($u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub watch {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    
    my $u = "/user/watched/" . uri_escape($user) . "/" . uri_escape($repos);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('PUT', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}
sub unwatch {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    
    my $u = "/user/watched/" . uri_escape($user) . "/" . uri_escape($repos);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
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
    
    # set user/repos for simple calls
    $repos->user('fayland');
    $repos->repos('perl-net-github');
    my @contributors = $repos->contributors; # don't need pass user and repos
    

=head1 DESCRIPTION

=head2 METHODS

=head3 Repos

L<http://developer.github.com/v3/repos/>

=over 4

=item list

=item list_user

=item list_org

    my $rp = $repos->list; # or my @rp = $repos->list;
    my $rp = $repos->list('private');
    my $rp = $repos->list_user('c9s');
    my $rp = $repos->list_user('c9s', 'member');
    my $rp = $repos->list_org('perlchina');
    my $rp = $repos->list_org('perlchina', 'public');

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

<B>SET user/repos before call methods below</B>

    $repos->user('fayland');
    $repos->repos('perl-net-github');

=over 4

=item update

    $repos->update({ homepage => 'https://metacpan.org/module/Net::GitHub' });

=item contributors

=item languages

=item teams

=item tags

=item contributors

    my $contributors = $repos->contributors;
    my $languages = $repos->languages;
    my $teams = $repos->teams;
    my $tags = $repos->tags;
    my $branches = $repos->branches;

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
    $repos->create_key( 'title', $key );
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

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
