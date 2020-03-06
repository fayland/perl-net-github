package Net::GitHub::V3::Events;

use Moo;

our $VERSION = '0.96';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

## build methods on fly
my %__methods = (

    events => { url => '/events', paginate => 1 },
    repos_events => { url => "/repos/%s/%s/events", paginate => 1 },
    issues_events => { url => "/repos/%s/%s/issues/events", paginate => 1 },
    networks_events => { url => "/networks/%s/%s/events", paginate => 1 },
    orgs_events => { url => "/orgs/%s/events", paginate => 1 },

    user_received_events => { url => "/users/%s/received_events", paginate => 1 },
    user_public_received_events => { url => "/users/%s/received_events/public", paginate => 1 },

    user_events => { url => "/users/%s/events", paginate => 1 },
    user_public_events => { url => "/users/%s/events/public", paginate => 1 },

    user_orgs_events => { url => "/users/%s/events/orgs/%s", paginate => 1 },

);
__build_methods(__PACKAGE__, %__methods);

no Moo;

1;
__END__

=head1 NAME

Net::GitHub::V3::Events - GitHub Events API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $event = $gh->event;

=head1 DESCRIPTION

=head2 METHODS

=head3 Events

L<http://developer.github.com/v3/activity/events/>

=over 4

=item events

    my @events = $event->events();
    while (my $ne = $event->next_event) { ...; }

=item repos_events

=item issues_events

=item networks_events

    my @events = $event->repos_events($user, $repo);
    my @events = $event->issues_events($user, $repo);
    my @events = $event->networks_events($user, $repo);
    while (my $ur_event = $event->next_repos_event($user,$repo) { ...; }
    while (my $ur_event = $event->next_issues_event($user,$repo) { ...; }
    while (my $ur_event = $event->next_networks_event($user,$repo) { ...; }

=item orgs_events

    my @events = $event->orgs_events($org);
    while (my $org_event = $event->next_orgs_event) { ...; }

=item user_received_events

=item user_public_received_events

=item user_events

=item user_public_events

    my @events = $event->user_received_events($user);
    my @events = $event->user_public_received_events($user);
    my @events = $event->user_events($user);
    my @events = $event->user_public_events($user);
    while (my $u_event = $event->next_user_received_event) { ...; }
    while (my $u_event = $event->next_user_public_received_event) { ...; }
    while (my $u_event = $event->next_user_event) { ...; }
    while (my $u_event = $event->next_user_public_event) { ...; }

=item user_orgs_events

    my @events = $event->user_orgs_events($user, $org);
    while (my $o_event = $event->next_org_event) { ...; }

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
