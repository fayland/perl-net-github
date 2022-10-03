package Net::GitHub::V3::PullRequests;

use Moo;

our $VERSION = '1.05';
our $AUTHORITY = 'cpan:FAYLAND';

use URI;
use URI::Escape;

with 'Net::GitHub::V3::Query';

sub pulls {
    my $self = shift;

    return $self->query($self->_pulls_arg2url(@_));
}

sub next_pull {
    my $self = shift;

    return $self->next($self->_pulls_arg2url(@_));
}

sub close_pull {
    my $self = shift;

    return $self->close($self->_pulls_arg2url(@_));
}

sub _pulls_arg2url {
    my $self = shift @_;
    my $args = pop @_;

    my ($user, $repos) = ($self->u, $self->repo);
    if (scalar(@_) >= 2) {
        ($user, $repos) = @_;
    }

    my $uri = URI->new('/repos/' . uri_escape($user) . '/' . uri_escape($repos) . '/pulls');
    $uri->query_form($args);
    return $uri->as_string;
}

## build methods on fly
my %__methods = (

    pull => { url => "/repos/%s/%s/pulls/%s" },

    create_pull => { url => "/repos/%s/%s/pulls", method => "POST", args => 1 },
    update_pull => { url => "/repos/%s/%s/pulls/%s", method => "PATCH", args => 1 },

    commits => { url => "/repos/%s/%s/pulls/%s/commits", paginate => 1 },
    files => { url => "/repos/%s/%s/pulls/%s/files", paginate => 1 },
    is_merged => { url => "/repos/%s/%s/pulls/%s/merge", check_status => 204 },
    merge => { url => "/repos/%s/%s/pulls/%s/merge", method => "PUT" },

    # http://developer.github.com/v3/pulls/comments/
    comments => { url => "/repos/%s/%s/pulls/%s/comments", paginate => 1 },
    comment  => { url => "/repos/%s/%s/pulls/comments/%s" },
    create_comment => { url => "/repos/%s/%s/pulls/%s/comments", method => 'POST',  args => 1 },
    update_comment => { url => "/repos/%s/%s/pulls/comments/%s", method => 'PATCH', args => 1 },
    delete_comment => { url => "/repos/%s/%s/pulls/comments/%s", method => 'DELETE', check_status => 204 },

    # http://developer.github.com/v3/pulls/reviews/
    reviews => { url => "/repos/%s/%s/pulls/%s/reviews", paginate => 1 },
    review  => { url => "/repos/%s/%s/pulls/%s/reviews/%s" },
    create_review => { url => "/repos/%s/%s/pulls/%s/reviews", method => 'POST',  args => 1 },
    delete_review => { url => "/repos/%s/%s/pulls/%s/reviews/%s", method => 'DELETE' },
    update_review => { url => "/repos/%s/%s/pulls/%s/reviews/%s", method => 'PUT', args => 1 },

    # https://developer.github.com/v3/pulls/review_requests/
    reviewers => { url => "/repos/%s/%s/pulls/%s/requested_reviewers", paginate => 1 },
    add_reviewers => { url => "/repos/%s/%s/pulls/%s/requested_reviewers", method => 'POST', args => 1 },
    delete_reviewers => { url => "/repos/%s/%s/pulls/%s/requested_reviewers", method => 'DELETE', check_status => 204, args => 1 },
);
__build_methods(__PACKAGE__, %__methods);

no Moo;

1;
__END__

=head1 NAME

Net::GitHub::V3::PullRequests - GitHub Pull Requests API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $pull_request = $gh->pull_request;

=head1 DESCRIPTION

B<To ease the keyboard, we provied two ways to call any method which starts with :user/:repo>

1. SET user/repos before call methods below

    $gh->set_default_user_repo('fayland', 'perl-net-github'); # take effects for all $gh->
    $pull_request->set_default_user_repo('fayland', 'perl-net-github'); # only take effect to $gh->pull_request
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
    while (my $pr = $pull_request->next_pull( { state => 'open' } )) { ...; }

=item pull

    my $pull  = $pull_request->pull($pull_number);

=item create_pull

=item update_pull

    my $pull = $pull_request->create_pull( {
        "title" => "Amazing new feature",
        "body" => "Please pull this in!",
        "head" => "octocat:new-feature",
        "base" => "master"
    } );
    my $pull = $pull_request->update_pull( $pull_number, $new_pull_data );

=item commits

=item files

    my @commits = $pull_request->commits($pull_number);
    my @files   = $pull_request->files($pull_number);
    while (my $commit = $pull_request->next_commit($pull_number)) { ...; }
    while (my $file = $pull_request->next_file($pull_number)) { ...; }


=item is_merged

=item merge

    my $is_merged = $pull_request->is_merged($pull_number);
    my $result    = $pull_request->merge($pull_number);

=back

=head3 Pull Request Comments API

L<http://developer.github.com/v3/pulls/comments/>

=over 4

=item comments

=item comment

=item create_comment

=item update_comment

=item delete_comment

    my @comments = $pull_request->comments($pull_number);
    while (my $comment = $pull_request->next_comment($pull_number)) { ...; }
    my $comment  = $pull_request->comment($comment_id);
    my $comment  = $pull_request->create_comment($pull_number, {
        "body" => "a new comment",
        commit_id => '586fe4be94c32248043b344e99fa15c72b40d1c2',
        path => 'test',
        position => 1,
    });
    my $comment = $pull_request->update_comment($comment_id, {
        "body" => "Nice change"
    });
    my $st = $pull_request->delete_comment($comment_id);

=back

=head3 Pull Request Reviews API

L<http://developer.github.com/v3/pulls/reviews/>

=over 4

=item reviews

=item review

=item create_review

=item update_review

=item delete_review

    my @reviews = $pull_request->reviews($pull_number);
    while (my $review = $pull_request->next_review($pull_number)) { ...; }
    my $review  = $pull_request->review($review_id);
    my $review  = $pull_request->create_review($pull_number, {
        "body" => "a new review",
        commit_id => '586fe4be94c32248043b344e99fa15c72b40d1c2',
        event => 'APPROVE',
    });
    my $review = $pull_request->update_review($review_id, {
        "body" => "Nice change"
    });
    my $st = $pull_request->delete_review($review_id);

=back

=head3 Pull Request Review API

L<https://developer.github.com/v3/pulls/review_requests/>

=over 4

=item reviewers

=item add_reviewers

=item delete_reviewers

    my @reviewers = $pull_request->reviewers($pull_number);
    my $result = $pull_request->add_reviewers($pull_number, {
        reviewers => [$user1, $user2],
        team_reviewers => [$team1],
    );
    my $result = $pull_request->delete_reviewers($pull_number, {
        reviewers => [$user1, $user2],
        team_reviewers => [$team1],
    );

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
