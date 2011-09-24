package Net::GitHub::V3::Issues;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

has 'user'  => (is => 'rw', isa => 'Str');
has 'repos' => (is => 'rw', isa => 'Str');

sub issues {
    my $self = shift;
    my $args = @_ % 2 ? shift : { @_ };
    
    my @p;
    foreach my $p (qw/filter state labels sort direction since/) {
        push @p, "$p=" . $arg->{$p} if exists $args->{$p};
    }
    my $u = '/issues';
    $u .= '?' . join('&', @p) if @p;
    return $self->query($u);
}

sub repos_issues {
    my $self = shift;
    
    if (@_ < 2) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my $user  = shift @_;
    my $repos = shift @_;
    
    my @p;
    foreach my $p (qw/milestone state assignee mentioned labels sort direction since/) {
        push @p, "$p=" . $arg->{$p} if exists $args->{$p};
    }
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues';
    $u .= '?' . join('&', @p) if @p;
    return $self->query($u);
}

sub issue {
    my $self = shift;
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . uri_escape($cid);
    return $self->query($u);
}

sub create_issue {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $issue) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues';
    return $self->query('POST', $u, $issue);
}

sub update_issue {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $issue_id, $new_issue) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . uri_escape($issue_id);
    return $self->query('PATCH', $u, $new_issue);
}

## http://developer.github.com/v3/issues/comments/

sub comments {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $issue_id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . uri_escape($issue_id) . '/comments';
    return $self->query($u);
}
sub comment {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/comments/' . uri_escape($cid);
    return $self->query($u);
}
sub create_comment {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $issue_id, $comment) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . uri_escape($issue_id) . '/comments';
    return $self->query('POST', $u, $comment);
}

sub update_comment {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid, $comment) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/comments/' . uri_escape($cid);
    return $self->query('PATCH', $u, $comment);
}

sub delete_comment {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/comments/' . uri_escape($cid);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

## http://developer.github.com/v3/issues/events/

sub events {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $issue_id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . uri_escape($issue_id) . '/events';
    return $self->query($u);
}

sub repos_events {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/events');
}

sub event {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $issue_id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/events/' . uri_escape($issue_id);
    return $self->query($u);
}

## http://developer.github.com/v3/issues/labels/

sub labels {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/labels');
}
sub label {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/labels/' . uri_escape($id);
    return $self->query($u);
}
sub create_label {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $label) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/labels';
    return $self->query('POST', $u, $label);
}
sub update_label {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $id, $label) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/labels/' . uri_escape($id);
    return $self->query('PATCH', $u, $label);
}
sub delete_label {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $id) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/labels/' . uri_escape($id);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub issue_labels {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . $id . '/labels';
    return $self->query($u);
}

sub create_issue_label {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $id, $labels) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . $id . '/labels';
    return $self->query('POST', $u, $label);
}

sub delete_issue_label {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $id, $label_id) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . $id . '/labels' . $label_id;
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub replace_issue_label {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $id, $labels) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . $id . '/labels';
    return $self->query('PUT', $u, $label);
}

sub delete_issue_labels {
    my $self = shift;
    
    if (@_ < 3) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $id) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . $id . '/labels';
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub milestone_labels {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $id) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/milestones/' . $id . '/labels';
    return $self->query($u);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::Issues - GitHub Issues API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $issue = $gh->issue;

=head1 DESCRIPTION

=head2 METHODS

=head3 Issues

L<http://developer.github.com/v3/issues/>

=over 4

=item issues

    my @issues = $issue->issues();
    my @issues = $issue->issues(filter => 'assigned', state => 'open');

=back

<B>SET user/repos before call methods below</B>

    $issue->user('fayland');
    $issue->repos('perl-net-github');
    my @issues = $issue->repos_issues;

    # or you can always pass them as the arguments
    my @issues = $issue->repos_issues($user, $repos);

=over 4

=item repos_issues

    # don't be confused
    my @issues = $issue->repos_issues;
    my @issues = $issue->repos_issues($user, $repos);
    my @issues = $issue->repos_issues(state => 'open');
    my @issues = $issue->repos_issues( { state => 'open' } );
    my @issues = $issue->repos_issues($user, $repos, state => 'open');
    my @issues = $issue->repos_issues($user, $repos, { state => 'open' } );

=item issue

    my $issue = $issue->issue($issue_id);

=item create_issue

    my $isu = $issue->create_issue( {
        "title" => "Found a bug",
        "body" => "I'm having a problem with this.",
        "assignee" => "octocat",
        "milestone" => 1,
        "labels" => [
            "Label1",
            "Label2"
        ]
    } );

=item update_issue

    my $isu = $issue->update_issue( $issue_id, {
        state => 'closed'
    } );

=back

=head3 Issue Comments API

L<http://developer.github.com/v3/issues/comments/

=over 4

=item comments

=item comment

=item create_comment

=item update_comment

=item delete_comment

    my @comments = $issue->comments($issue_id);
    my $comment  = $issue->comment($comment_id);
    my $comment  = $issue->create_comment($issue_id, {
        "body" => "a new comment"
    });
    my $comment = $repos->update_comment($comment_id, {
        "body" => "Nice change"
    });
    my $st = $repos->delete_comment($comment_id);

=back

=head3 Issue Event API

L<http://developer.github.com/v3/issues/events/>

=over 4

=item events

=item repos_events

    my @events = $issue->events($issue_id);
    my @events = $issue->repos_events;
    my $event  = $issue->event($event_id);

=back

=head3 Issue Labels API

L<http://developer.github.com/v3/issues/labels/>

=over 4

=item labels

=item label

=item create_label

=item update_label

=item delete_label

    my @labels = $issue->labels;
    my $label  = $issue->label($label_id);
    my $label  = $issue->create_label( {
        "name" => "API",
        "color" => "FFFFFF"
    } );
    my $label  = $issue->update_label( $label_id, {
        "name" => "bugs",
        "color" => "000000"
    } );
    my $st = $issue->delete_label($label_id);

=item issue_labels

=item create_issue_label

=item delete_issue_label

=item replace_issue_label

=item delete_issue_labels

=item milestone_labels

    my @labels = $issue->issue_label($issue_id);
    my @labels = $issue->create_issue_label($issue_id, ['New Label']);
    my $st = $issue->delete_issue_label($issue_id, $label_id);
    my @labels = $issue->replace_issue_label($issue_id, ['New Label']);
    my $st = $issue->delete_issue_labels($issue_id);
    my @lbales = $issue->milestone_labels($milestone_id);

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
