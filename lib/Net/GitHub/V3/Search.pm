package Net::GitHub::V3::Search;

use Moo;

our $VERSION = '0.68';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub repositories {
    my ( $self, $args ) = @_;

    # for old
    unless (ref($args) eq 'HASH') {
        $args = { q => $args };
    }

    my $uri = URI->new('/search/repositories');
    $uri->query_form($args);

    my $url = $uri->as_string;
    $url =~ s/%3A/:/g;
    $url =~ s/%2B/+/g;

    return $self->query($url);
}

sub code {
    my ( $self, $args ) = @_;

    # for old
    unless (ref($args) eq 'HASH') {
        $args = { q => $args };
    }

    my $uri = URI->new('/search/code');
    $uri->query_form($args);
    return $self->query($uri->as_string);
}

sub issues {
    my ( $self, $args ) = @_;

    # for old
    unless (ref($args) eq 'HASH') {
        $args = { q => $args };
    }

    my $uri = URI->new('/search/issues');
    $uri->query_form($args);
    return $self->query($uri->as_string);
}

sub users {
    my ( $self, $args ) = @_;

    # for old
    unless (ref($args) eq 'HASH') {
        $args = { q => $args };
    }

    my $uri = URI->new('/search/users');
    $uri->query_form($args);
    return $self->query($uri->as_string);
}

## DEPERCATED
sub repos {
    (shift)->repositories(@_);
}
sub user {
    (shift)->repositories(@_);
}

no Moo;

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

    my %data = $search->issues({
        q => 'state:open repo:fayland/perl-net-github',
        sort  => 'created',
        order => 'asc',
    });
    print Dumper(\$data{items});

=item repositories

    my %data = $search->repositories({
        q => 'perl',
        sort  => 'stars',
        order => 'desc',
    });
    print Dumper(\$data{items});

=item code

    my %data = $search->code({
        q => 'addClass in:file language:js repo:jquery/jquery'
    });
    print Dumper(\$data{items});

=item users

    my %data = $search->users({
        q => 'perl',
        sort  => 'followers',
        order => 'desc',
    });
    print Dumper(\$data{users});

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
