package Net::GitHub::V3::Issues;

use Any::Moose;

our $VERSION = '0.47';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub issues {
    my $self = shift;
    my $args = @_ % 2 ? shift : { @_ };

    my @p;
    foreach my $p (qw/filter state labels sort direction since/) {
        push @p, "$p=" . $args->{$p} if exists $args->{$p};
    }
    my $u = '/issues';
    $u .= '?' . join('&', @p) if @p;
    return $self->query($u);
}

sub repos_issues {
    my $self = shift;

    if (@_ < 2) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $args) = @_;

    my @p;
    foreach my $p (qw/milestone state assignee mentioned labels sort direction since/) {
        push @p, "$p=" . $args->{$p} if exists $args->{$p};
    }
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues';
    $u .= '?' . join('&', @p) if @p;
    return $self->query($u);
}

## build methods on fly
my %__methods = (

    issue => { url => "/repos/%s/%s/issues/%s" },
    create_issue => { url => "/repos/%s/%s/issues", method => 'POST', args => 1 },
    update_issue => { url => "/repos/%s/%s/issues/%s", method => 'PATCH', args => 1 },

    ## http://developer.github.com/v3/issues/comments/
    comments => { url => "/repos/%s/%s/issues/%s/comments" },
    comment  => { url => "/repos/%s/%s/issues/comments/%s" },
    create_comment => { url => "/repos/%s/%s/issues/%s/comments", method => 'POST',  args => 1 },
    update_comment => { url => "/repos/%s/%s/issues/comments/%s", method => 'PATCH', args => 1 },
    delete_comment => { url => "/repos/%s/%s/issues/comments/%s", method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/issues/events/
    events => { url => "/repos/%s/%s/issues/%s/events" },
    repos_events => { url => "/repos/%s/%s/issues/events" },
    event => { url => "/repos/%s/%s/issues/events/%s" },

    # http://developer.github.com/v3/issues/labels/
    labels => { url => "/repos/%s/%s/labels" },
    label  => { url => "/repos/%s/%s/labels/%s" },
    create_label => { url => "/repos/%s/%s/labels", method => 'POST', args => 1 },
    update_label => { url => "/repos/%s/%s/labels/%s", method => 'PATCH', args => 1 },
    delete_label => { url => "/repos/%s/%s/labels/%s", method => 'DELETE', check_status => 204 },
    issue_labels => { url => "/repos/%s/%s/issues/%s/labels" },
    create_issue_label  => { url => "/repos/%s/%s/issues/%s/labels", method => 'POST', args => 1 },
    delete_issue_label  => { url => "/repos/%s/%s/issues/%s/labels/%s", method => 'DELETE', check_status => 204 },
    replace_issue_label => { url => "/repos/%s/%s/issues/%s/labels", method => 'PUT', args => 1 },
    delete_issue_labels => { url => "/repos/%s/%s/issues/%s/labels", method => 'DELETE', check_status => 204 },
    milestone_labels => { url => "/repos/%s/%s/milestones/%s/labels" },

    # http://developer.github.com/v3/issues/milestones/
    milestone  => { url => "/repos/%s/%s/milestones/%s" },
    create_milestone => { url => "/repos/%s/%s/milestones", method => 'POST',  args => 1 },
    update_milestone => { url => "/repos/%s/%s/milestones/%s", method => 'PATCH', args => 1 },
    delete_milestone => { url => "/repos/%s/%s/milestones/%s", method => 'DELETE', check_status => 204 },

);
__build_methods(__PACKAGE__, %__methods);

## http://developer.github.com/v3/issues/milestones/
sub milestones {
    my $self = shift;

    if (@_ < 3) {
        unshift @_, $self->repo;
        unshift @_, $self->u;
    }
    my ($user, $repos, $args) = @_;

    my @p;
    foreach my $p (qw/state sort direction/) {
        push @p, "$p=" . $args->{$p} if exists $args->{$p};
    }
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/milestones';
    $u .= '?' . join('&', @p) if @p;
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

B<To ease the keyboard, we provied two ways to call any method which starts with :user/:repo>

1. SET user/repo before call methods below

    $gh->set_default_user_repo('fayland', 'perl-net-github'); # take effects for all $gh->
    $issue->set_default_user_repo('fayland', 'perl-net-github'); # only take effect to $gh->issue
    my @issues = $repos->issues;

2. If it is just for once, we can pass :user, :repo before any arguments

    my @issues = $issue->repos_issues($user, $repo);

=over 4

=item repos_issues

    my @issues = $issue->repos_issues;
    my @issues = $issue->repos_issues($user, $repos);
    my @issues = $issue->repos_issues( { state => 'open' } );
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

L<http://developer.github.com/v3/issues/comments/>

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
    my $comment = $issue->update_comment($comment_id, {
        "body" => "Nice change"
    });
    my $st = $issue->delete_comment($comment_id);

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

=head3 Issue Milestones API

L<http://developer.github.com/v3/issues/milestones/>

=over 4

=item milestones

=item milestone

=item create_milestone

=item update_milestone

=item delete_milestone

    my @milestones = $issue->milestones;
    my @milestones = $issue->milestones( { state => 'open' } );
    my $milestone  = $issue->milestone($milestone_id);
    my $milestone  = $issue->create_milestone( {
        "title" => "String",
        "state" => "open",
        "description" => "String",
    } );
    my $milestone  = $issue->update_milestone( $milestone_id, {
        title => 'New Title'
    } );
    my $st = $issue->delete_milestone($milestone_id);

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
