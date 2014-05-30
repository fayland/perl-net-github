package Net::GitHub::V3::PullRequests;

use Moo;

our $VERSION = '0.63';
our $AUTHORITY = 'cpan:FAYLAND';

use URI;
use URI::Escape;

with 'Net::GitHub::V3::Query';

sub pulls {
    my $self = shift @_;
    my $args = pop @_;

    my ($user, $repos) = ($self->u, $self->repo);
    if (scalar(@_) >= 2) {
        ($user, $repos) = @_;
    }

    my $uri = URI->new('/repos/' . uri_escape($user) . '/' . uri_escape($repos) . '/pulls');
    $uri->query_form($args);
    return $self->query($uri->as_string);
}

## build methods on fly
my %__methods = (

    pull => { url => "/repos/%s/%s/pulls/%s" },

    create_pull => { url => "/repos/%s/%s/pulls", method => "POST", args => 1 },
    update_pull => { url => "/repos/%s/%s/pulls/%s", method => "PATCH", args => 1 },

    commits => { url => "/repos/%s/%s/pulls/%s/commits" },
    files => { url => "/repos/%s/%s/pulls/%s/files" },
    is_merged => { url => "/repos/%s/%s/pulls/%s/merge", check_status => 204 },
    merge => { url => "/repos/%s/%s/pulls/%s/merge", method => "PUT" },

    # http://developer.github.com/v3/pulls/comments/
    comments => { url => "/repos/%s/%s/pulls/%s/comments" },
    comment  => { url => "/repos/%s/%s/pulls/comments/%s" },
    create_comment => { url => "/repos/%s/%s/pulls/%s/comments", method => 'POST',  args => 1 },
    update_comment => { url => "/repos/%s/%s/pulls/comments/%s", method => 'PATCH', args => 1 },
    delete_comment => { url => "/repos/%s/%s/pulls/comments/%s", method => 'DELETE', check_status => 204 },

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

L<http://developer.github.com/v3/pulls/comments/>

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

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
