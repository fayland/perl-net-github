package Net::GitHub::V3::Orgs;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub orgs {
    my ( $self, $user ) = @_;
    
    my $u = $user ? "/users/" . uri_escape($user) . '/orgs' : '/user/orgs';
    return $self->query($u);
}

## build methods on fly
my %__methods = (
    org => { url => "/orgs/%s" },
    update_org => { url => "/orgs/%s", method => 'PATCH', args => 1 },
    # Members
    members   => { url => "/orgs/%s/members" },
    is_member => { url => "/orgs/%s/members/%s", check_status => 204 },
    delete_member => { url => "/orgs/%s/members/%s", method => 'DELETE', check_status => 204 },
    public_members => { url => "/orgs/%s/public_members" },
    is_public_member => { url => "/orgs/%s/public_members/%s", check_status => 204 },
    publicize_member => { url => "/orgs/%s/public_members/%s", method => 'PUT', check_status => 204 },
    conceal_member => { url => "/orgs/%s/public_members/%s", method => 'DELETE', check_status => 204 },
    # Org Teams API
    teams => { url => "/orgs/%s/teams" },
    team  => { url => "/teams/%s" },
    create_team => { url => "/orgs/%s/teams", method => 'POST', args => 1 },
    update_team => { url => "/teams/%s", method => 'PATCH', args => 1 },
    delete_team => { url => "/teams/%s", method => 'DELETE', check_status => 204 },
    team_members => { url => "/teams/%s/members" },
    is_team_member  => { url => "/teams/%s/members/%s", check_status => 204 },
    add_team_member => { url => "/teams/%s/members/%s", method => 'PUT', check_status => 204 },
    delete_team_member => { url => "/teams/%s/members/%s", method => 'DELETE', check_status => 204 },
    team_repos => { url => "/teams/%s/repos" },
    is_team_repos  => { url => "/teams/%s/repos/%s", check_status => 204 },
    add_team_repos => { url => "/teams/%s/repos/%s", method => 'PUT', check_status => 204 },
    delete_team_repos => { url => "/teams/%s/repos/%s", method => 'DELETE', check_status => 204 },
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
    my $org = $gh->org;

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

=head3 Members

L<http://developer.github.com/v3/orgs/members/>

=over 4

=item members

=item is_member

=item delete_member

    my @members = $org->members('perlchina');
    my $is_member = $org->is_member('perlchina', 'fayland');
    my $st = $org->delete_member('perlchina', 'fayland');

=item public_members

=item is_public_member

=item publicize_member

=item conceal_member

    my @members = $org->public_members('perlchina');
    my $is_public_member = $org->is_public_member('perlchina', 'fayland');
    my $st = $org->publicize_member('perlchina', 'fayland');
    my $st = $org->conceal_member('perlchina', 'fayland');

=back

=head3 Org Teams API

L<http://developer.github.com/v3/orgs/teams/>

=over 4

=item teams

=item team

=item create_team

=item update_team

=item delete_team

    my @teams = $org->teams('perlchina');
    my $team  = $org->team($team_id);
    my $team  = $org->create_team('perlchina', {
        "name" => "new team"
    });
    my $team  = $org->update_team($team_id, {
        name => "new team name"
    });
    my $st = $org->delete_team($team_id);
    
=item team_members

=item is_team_member

=item add_team_member

=item delete_team_member

    my @members = $org->team_members($team_id);
    my $is_team_member = $org->is_team_member($team_id, 'fayland');
    my $st = $org->add_team_member($team_id, 'fayland');
    my $st = $org->delete_team_member($team_id, 'fayland');

=item team_repos

=item is_team_repos

=item add_team_repos

=item delete_item_repos

    my @repos = $org->team_repos($team_id);
    my $is_team_repos = $org->is_team_repos($team_id, 'Hello-World');
    my $st = $org->add_team_repos($team_id, 'Hello-World');
    my $st = $org->delete_team_repos($team_id, 'Hello-World');

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>