package Net::GitHub::V3::Events;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

## build methods on fly
my %__methods = (

    events => { url => '/events' },
    repos_events => { url => "/repos/%s/%s/events" },
    issues_events => { url => "/repos/%s/%s/issues/events" },
    networks_events => { url => "/networks/%s/%s/events" },
    orgs_events => { url => "/orgs/%s/events" },

    user_received_events => { url => "/users/%s/received_events" },
    user_public_received_events => { url => "/users/%s/received_events/public" },

    user_events => { url => "/users/%s/events" },
    user_public_events => { url => "/users/%s/events/public" },

    user_orgs_events => { url => "/users/%s/events/orgs/%s" },

);
__build_methods(__PACKAGE__, %__methods);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

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

L<http://developer.github.com/v3/events/>

=over 4

=item events

    my @events = $event->events();

=item repos_events

=item issues_events

=item networks_events

    my @events = $event->repos_events($user, $repo);
    my @events = $event->issues_events($user, $repo);
    my @events = $event->networks_events($user, $repo);

=item orgs_events

    my @events = $event->orgs_events($org);

=item user_received_events

=item user_public_received_events

=item user_events

=item user_public_events

    my @events = $event->user_received_events($user);
    my @events = $event->user_public_received_events($user);
    my @events = $event->user_events($user);
    my @events = $event->user_public_events($user);

=item user_orgs_events

    my @events = $event->user_orgs_events($user, $org);

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
