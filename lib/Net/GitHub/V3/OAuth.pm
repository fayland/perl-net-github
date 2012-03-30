package Net::GitHub::V3::OAuth;

use Any::Moose;

our $VERSION = '0.43';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

## build methods on fly
my %__methods = (

    authorizations => { url => "/authorizations" },

    get_authorization => { url => "/authorizations/%s" },
    authorization => { url => "/authorizations/%s" },

    create_authorization => { url => "/authorizations", method => "POST", args => 1 },
    update_authorization => { url => "/authorizations/%s", method => "PATCH", args => 1 },
    delete_authorization => { url => "/authorizations/%s", method => "DELETE", check_status => 204 },

);
__build_methods(__PACKAGE__, %__methods);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::OAuth - GitHub OAuth API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $oauth = $gh->oauth;

=head2 DESCRIPTION

For Web Application Flow, we suggest to use L<Net::OAuth>.

For Non-Web Application Flow, read the L<Net::GitHub> FAQ.

=head2 METHODS

=head3 OAuth

L<http://developer.github.com/v3/oauth/>

=over 4

=item authorizations

    my @authorizations = $oauth->authorizations();

=item authorization

    my $authorization  = $oauth->authorization($authorization_id);

=item create_authorization

=item update_authorization

    my $oauth = $oauth->create_authorization( {
        scopes => ['public_repo'],
        note   => 'admin script',
    } );
    my $oauth = $oauth->update_authorization( $authorization_id, $new_authorization_data );

=item delete

    my $is_deleted = $oauth->delete_authorization($authorization_id);

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
