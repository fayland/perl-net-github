package Net::GitHub::V3::Orgs;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub orgs {
    my ( $self, $user ) = @_;
    
    if ($user) {
        return $self->query("/users/" . uri_escape($user) . '/orgs');
    } else {
        return $self->query('/user/orgs');
    }
}

## build methods on fly
my %__methods = (
    'org' => {
        url => "/orgs/%s",
    },
    'update_org' => {
        url  => "/orgs/%s",
        method => 'PATCH',
        args => 1
    },
    
);
__build_methods(__PACKAGE__, %__methods);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::Orgs - GitHub Orgs API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $user = $gh->org;

=head1 DESCRIPTION

=head2 METHODS

=head3 Orgs

L<http://developer.github.com/v3/orgs/>

=over 4

=item orgs

    my @orgs = $org->orgs(); # /user/org
    my @orgs = $org->orgs( 'nothingmuch' ); # /users/:user/org

=item org

    my $org  = $org->org('perlchina');

=item update_org

    my $org  = $org->update_org($org_name, { name => 'new org name' });

=back


=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>