package Net::GitHub::V3::Search;

use Any::Moose;

our $VERSION = '0.49';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

## build methods on fly
my %__methods = (

    issues => { url => '/legacy/issues/search/%s/%s/%s/%s', is_u_repo => 1 },
    repos  => { url => '/legacy/repos/search/%s' },
    user   => { url => '/legacy/user/search/%s' },
    email  => { url => '/legacy/user/email/%s' },

);
__build_methods(__PACKAGE__, %__methods);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::Search - GitHub Search API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $search = $gh->search;

=head1 DESCRIPTION

=head2 METHODS

=head3 Search

L<http://developer.github.com/v3/search/>

=over 4

=item issues

    my %data = $search->issues('fayland', 'perl-net-github', 'closed', 'milestone');
    print Dumper(\$data{issues});

=item repos

    my %data = $search->repos('perl-net-github');
    print Dumper(\$data{repositories});

=item user

    my %data = $search->user('fayland');
    print Dumper(\$data{users});

=item email

    my %data = $search->email('fayland@gmail.com');
    print Dumper(\$data{user});

=item

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
