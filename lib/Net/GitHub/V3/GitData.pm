package Net::GitHub::V3::GitData;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

## build methods on fly
my %__methods = (
    blob => { url => "/repos/%s/%s/git/blobs/%s", is_u_repo => 1 },
    create_blob => { url => "/repos/%s/%s/git/blobs", is_u_repo => 1, method => 'POST', args => 1 },
    commit => { url => "/repos/%s/%s/git/commits/%s", is_u_repo => 1 },
    create_commit => { url => "/repos/%s/%s/git/commits", is_u_repo => 1, method => 'POST', args => 1 },
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

=head3 Orgs

L<http://developer.github.com/v3/git/>

=over 4

=item blob

    my $blob = $git_data->blob('5a1faac3ad54da26be60970ddbbdfbf6b08fdc57');

=item create_blob

    my $result = $git_data->create_blob( {
        content => $content,
        encoding => 'utf-8',
    } );

=item commit

    my $commit = $git_data->commit('5a1faac3ad');

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>