package Net::GitHub::V3::PullRequests;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub pulls {
    my $self = @_;
    
    if (@_ < 3) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $args) = @_;
    
    my @p;
    foreach my $p (qw/state/) {
        push @p, "$p=" . $args->{$p} if exists $args->{$p};
    }
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls';
    $u .= '?' . join('&', @p) if @p;
    return $self->query($u);
}

sub pull {
    my $self = @_;
    
    if (@_ < 3) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/' . $id;
    return $self->query($u);
}

sub create_pull {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $pull) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls';
    return $self->query('POST', $u, $pull);
}

sub update_pull {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $id, $pull) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/' . uri_escape($id);
    return $self->query('PATCH', $u, $pull);
}

sub commits {
    my $self = @_;
    
    if (@_ < 3) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/' . $id . '/commits';
    return $self->query($u);
}

sub files {
    my $self = @_;
    
    if (@_ < 3) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/' . $id . '/files';
    return $self->query($u);
}

sub is_merged {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/' . $id . '/merge';
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query($u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub merge {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/' . $id . '/merge';
    return $self->query('PUT', $u);
}

## http://developer.github.com/v3/pulls/comments/

sub comments {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $pull_id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/' . uri_escape($pull_id) . '/comments';
    return $self->query($u);
}
sub comment {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/comments/' . uri_escape($cid);
    return $self->query($u);
}
sub create_comment {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $pull_id, $comment) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/' . uri_escape($pull_id) . '/comments';
    return $self->query('POST', $u, $comment);
}

sub update_comment {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $cid, $comment) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/comments/' . uri_escape($cid);
    return $self->query('PATCH', $u, $comment);
}

sub delete_comment {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/pulls/comments/' . uri_escape($cid);
    
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

Net::GitHub::V3::PullRequests - GitHub Pull Requests API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $pull_request = $gh->pull_request;

=head1 DESCRIPTION

<B>To ease the keyboard, we provied two ways to call any method which starts with :user/:repo</B>

1. SET user/repos before call methods below

    $pull_request->set_default_user_repo('fayland', 'perl-net-github');
    my @pulls = $pull_request->pulls();

2. If it is just for once, we can pass :user, :repo before any arguments

    my @pulls = $pull_request->pulls($user, $repo);

=head2 METHODS

=head3 Pull Requets

L<http://developer.github.com/v3/pulls/>

=over 4

=item pulls

    my @pulls = $pull_request->pulls();
    my @pulls = $pull_request->pulls( { state => 'open' } );

=item pull

    my $pull  = $pull_request->pull($pull_id);

=item create_pull

=item update_pull

    my $pull = $pull_request->create_pull( {
        "title" => "Amazing new feature",
        "body" => "Please pull this in!",
        "head" => "octocat:new-feature",
        "base" => "master"
    } );
    my $pull = $pull_request->update_pull( $pull_id, $new_pull_data );

=item commits

=item files

    my @commits = $pull_request->commits($pull_id);
    my @files   = $pull_request->files($pull_id);

=item is_merged

=item merge

    my $is_merged = $pull_request->is_merged($pull_id);
    my $result    = $pull_request->merge($pull_id);

=back

=head3 Pull Request Comments API

L<http://developer.github.com/v3/pulls/comments//

=over 4

=item comments

=item comment

=item create_comment

=item update_comment

=item delete_comment

    my @comments = $pull_request->comments($pull_id);
    my $comment  = $pull_request->comment($comment_id);
    my $comment  = $pull_request->create_comment($pull_id, {
        "body" => "a new comment"
    });
    my $comment = $pull_request->update_comment($comment_id, {
        "body" => "Nice change"
    });
    my $st = $pull_request->delete_comment($comment_id);

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
