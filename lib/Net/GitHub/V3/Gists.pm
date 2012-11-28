package Net::GitHub::V3::Gists;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub gists {
    my ( $self, $user ) = @_;

    my $u = $user ? "/users/" . uri_escape($user) . '/gists' : '/gists';
    return $self->query($u);
}

## build methods on fly
my %__methods = (
    public_gists  => { url => "/gists/public" },
    starred_gists => { url => "/gists/starred" },
    gist => { url => "/gists/%s" },
    create => { url => "/gists", method => "POST", args => 1 },
    update => { url => "/gists/%s", method => "PATCH", args => 1 },
    star   => { url => "/gists/%s/star", method => "PUT", check_status => 204 },
    unstar => { url => "/gists/%s/star", method => "DELETE", check_status => 204 },
    is_starred => { url => "/gists/%s/star", method => "GET", check_status => 204 },
    fork => { url => "/gists/%s/fork", method => "POST" },
    delete => { url => "/gists/%s", method => "DELETE", check_status => 204 },

    # http://developer.github.com/v3/gists/comments/
    comments => { url => "/gists/%s/comments" },
    comment  => { url => "/gists/%s/comments/%s" },
    create_comment => { url => "/gists/%s/comments", method => 'POST',  args => 1 },
    update_comment => { url => "/gists/%s/comments/%s", method => 'PATCH', args => 1 },
    delete_comment => { url => "/gists/%s/comments/%s", method => 'DELETE', check_status => 204 },
);
__build_methods(__PACKAGE__, %__methods);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::Gists - GitHub Gists API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $gist = $gh->gist;

=head1 DESCRIPTION

=head2 METHODS

=head3 Git Data

L<http://developer.github.com/v3/gists/>

=over 4

=item gists

    my @gists = $gist->gists;
    my @gists = $gist->gists('nothingmuch');

=item public_gists

=item starred_gists

    my @gists = $gist->public_gists;
    my @gists = $gist->starred_gists;

=item gist

    my $gist = $gist->gist($gist_id);

=item create

    my $gist = $gist->create( {
      "description" => "the description for this gist",
      "public" => 'true',
      "files"  =>  {
        "file1.txt" => {
            "content" => "String file contents"
        }
      }
    } );

=item update

    my $g = $gist->update( $gist_id, {
        description => "edited desc"
    } );

=item star

=item unstar

=item is_starred

    my $st = $gist->star($gist_id);
    my $st = $gist->unstar($gist_id);
    my $st = $gist->is_starred($gist_id);

=item fork

=item delete

    my $g  = $gist->fork($gist_id);
    my $st = $gist->delete($gist_id);

=back

=head3 Gist Comments API

L<http://developer.github.com/v3/gists/comments/>

=over 4

=item comments

=item comment

=item create_comment

=item update_comment

=item delete_comment

    my @comments = $gist->comments();
    my $comment  = $gist->comment($comment_id);
    my $comment  = $gist->create_comment($gist_id, {
        "body" => "a new comment"
    });
    my $comment = $gist->update_comment($gist_id, $comment_id, {
        "body" => "Nice change"
    });
    my $st = $gist->delete_comment($gist_id, $comment_id);

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>