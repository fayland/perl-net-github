package Net::GitHub::V3::GitData;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

## build methods on fly
my %__methods = (
    blob => { url => "/repos/%s/%s/git/blobs/%s" },
    create_blob => { url => "/repos/%s/%s/git/blobs", method => 'POST', args => 1 },
    
    commit => { url => "/repos/%s/%s/git/commits/%s" },
    create_commit => { url => "/repos/%s/%s/git/commits", method => 'POST', args => 1 },

    tree => { url => "/repos/%s/%s/git/trees/%s" },
    trees => { url => "/repos/%s/%s/git/trees/%s?recursive=1" },
    create_tree => { url => "/repos/%s/%s/git/trees", method => 'POST', args => 1 },
    
    refs => { url => "/repos/%s/%s/git/refs" },
    ref  => { url => "/repos/%s/%s/git/refs/%s" },
    create_ref => { url => "/repos/%s/%s/git/refs", method => 'POST', args => 1 },
    update_ref => { url => "repos/%s/%s/git/refs/%s", method => 'PATCH', args => 1 },
    
    tag => { url => "/repos/%s/%s/git/tags/%s" },
    create_tag => { url => "/repos/%s/%s/git/tags", method => 'POST', args => 1 },
    
);
__build_methods(__PACKAGE__, %__methods);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::GitData - GitHub Git DB API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $git_data = $gh->git_data;

=head1 DESCRIPTION

B<To ease the keyboard, we provied two ways to call any method which starts with :user/:repo>

1. SET user/repos before call methods below

    $gh->set_default_user_repo('fayland', 'perl-net-github'); # take effects for all $gh->
    $git_data->set_default_user_repo('fayland', 'perl-net-github'); # only take effect to $gh->pull_request
    my $blob = $git_data->blob($sha);

2. If it is just for once, we can pass :user, :repo before any arguments

    my $blob = $git_data->blob($user, $repo, $sha);

=head2 METHODS

=head3 Git Data

L<http://developer.github.com/v3/git/>

=head3 Blob

=over 4

=item blob

    my $blob = $git_data->blob('5a1faac3ad54da26be60970ddbbdfbf6b08fdc57');

=item create_blob

    my $result = $git_data->create_blob( {
        content => $content,
        encoding => 'utf-8',
    } );

=back

=head3 Commits

L<http://developer.github.com/v3/git/commits/>

=over 4

=item commit

    my $commit = $git_data->commit('5a1faac3ad54da26be60970ddbbdfbf6b08fdc57');
    
=item create_commit

=back

=head3 Refs

L<http://developer.github.com/v3/git/refs/>

=over 4

=item refs

=item ref

=item create_ref

=item update_ref

    my @refs = $git_data->refs;
    my $ref  = $git_data->ref($ref_id);
    my $ref  = $git_data->create_ref($ref_data);
    my $ref  = $git_data->update_ref($ref_id, $ref_data);

=back

=head3 Tags

L<http://developer.github.com/v3/git/tags/>

=over 4

=item tag

=item create_tag

    my $tag = $git_data->tag($sha);
    my $tag = $git_data->create_tag($tag_data);

=back

=head3

L<http://developer.github.com/v3/git/trees/>

=over 4

=item tree

=item trees

=item create_tree

    my $tree = $git_data->tree($sha);
    my $trees = $git_data->trees($sha);
    my $tree = $git_data->create_tree($tree_data);

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
