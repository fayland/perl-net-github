package Net::GitHub::V2::Organizations;

use Any::Moose;

our $VERSION = '0.24';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::NoRepo';

sub organizations {
    my ( $self, $org ) = @_;
    
    if ($org) {
        return $self->get_json_to_obj( 'organizations/' . uri_escape($org), 'organization' );
    } else {
        return $self->get_json_to_obj_authed( 'organizations', 'organizations' );
    }
}

sub user_organizations {
    my ( $self, $owner ) = @_;
    
    $owner ||= $self->owner;
    
    return $self->get_json_to_obj( "user/show/$owner/organizations", 'organizations' );
}

sub update {
    my ( $self, $org, %up ) = @_;

    # with format organization[key] = value
    my @values;
    foreach my $key ( keys %up ) {
        push @values, ( "organization[$key]", $up{$key} );
    }
    
    my $url = $self->api_url_https . 'organizations/' . uri_escape($org);
    return $self->get_json_to_obj_authed( $url, @values, 'organization' );
}

sub repositories {
    my ( $self ) = @_;
    
    return $self->get_json_to_obj_authed( 'organizations/repositories', 'repositories' );
}

sub public_repositories {
    my ( $self, $org ) = @_;

    return $self->get_json_to_obj( "organizations/$org/public_repositories", 'repositories' );
}

sub public_members {
    my ( $self, $org ) = @_;

    return $self->get_json_to_obj( "organizations/$org/public_members", 'users' );
}

### Team API

sub teams {
    my ( $self, $org ) = @_;

    return $self->get_json_to_obj_authed( "organizations/$org/teams", 'teams' );
}

sub create_team {
    my ($self, $org, %teams) = @_;
    
    # with format team[key] = value
    my @values;
    foreach my $key ( keys %teams ) {
        if ($key eq 'repo_names') {
            foreach my $v (@{ $teams{$key} }) {
                push @values, ( "team[$key][]", $v );
            }
        } else {
            push @values, ( "team[$key]", $teams{$key} );
        }
    }
    
    my $url = $self->api_url_https . 'organizations/' . uri_escape($org) . '/teams';
    return $self->get_json_to_obj_authed( $url, @values, 'teams' );
}

sub team {
    my ( $self, $team_id ) = @_;

    return $self->get_json_to_obj_authed( "teams/$team_id", 'team' );
}

sub update_team {
    my ( $self, $team_id, %teams ) = @_;
    
    # with format team[key] = value
    my @values;
    foreach my $key ( keys %teams ) {
        if ($key eq 'repo_names') {
            foreach my $v (@{ $teams{$key} }) {
                push @values, ( "team[$key][]", $v );
            }
        } else {
            push @values, ( "team[$key]", $teams{$key} );
        }
    }
    
    my $url = $self->api_url_https . "teams/$team_id";
    return $self->get_json_to_obj_authed( $url, @values, 'team' );
}

sub delete_team {
    my ( $self, $team_id ) = @_;
    
    return $self->get_json_to_obj_authed_DELETE( "teams/$team_id" );
}

sub team_members {
    my ( $self, $team_id ) = @_;

    return $self->get_json_to_obj_authed( "teams/$team_id/members", 'users' );
}

sub add_team_member {
    my ( $self, $team_id, $user ) = @_;
    
    my @values= ('name', $user);
    my $url = $self->api_url_https . "teams/$team_id/members";
    return $self->get_json_to_obj_authed( $url, @values, 'users' );
}

sub remove_team_member {
    my ( $self, $team_id, $user ) = @_;
    
    my $url = $self->api_url_https . "teams/$team_id/members?name=" . uri_escape($user);
    return $self->get_json_to_obj_authed_DELETE( $url, 'users' );
}

sub team_repositories {
    my ( $self, $team_id ) = @_;

    return $self->get_json_to_obj_authed( "teams/$team_id/repositories", 'repositories' );
}

sub add_team_repositories {
    my ( $self, $team_id, $repo ) = @_;
    
    my @values= ('name', $repo);
    my $url = $self->api_url_https . "teams/$team_id/repositories";
    return $self->get_json_to_obj_authed( $url, @values, 'repositories' );
}

sub remove_team_repositories {
    my ( $self, $team_id, $repo ) = @_;
    
    my $url = $self->api_url_https . "teams/$team_id/repositories?name=" . uri_escape($repo);
    return $self->get_json_to_obj_authed_DELETE( $url, 'repositories' );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V2::Organizations - GitHub Organizations API

=head1 SYNOPSIS

    use Net::GitHub::V2::Organizations;

    my $organization = Net::GitHub::V2::Organizations->new(
        owner => 'fayland'
    );

=head1 DESCRIPTION

L<http://develop.github.com/p/orgs.html>

For those B<(authentication required)> below, you must set login and token (in L<https://github.com/account>)

    my $user = Net::GitHub::V2::Organizations->new(
        owner => 'fayland',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
    );

=head1 METHODS

=over 4

=item organizations

    my $o = $organization->organizations('github');
    my $o_arrayref = $organization->organizations; # my organizations

=item update

    $organization->update('PerlChina', blog => 'http://planet.perlchina.org/', location => 'China');
    
=item user_organizations

    my $o_arrayref = $organization->user_organizations('technoweenie');

=item repositories

    my $repositories = $organization->repositories;

=item public_repositories

    my $repositories = $organization->public_repositories('github');

=item public_members

    my $users = $organization->public_members('github');

=item teams

    my $teams = $organization->teams('github');

=item create_team

    $organization->create_team('PerlChina',
        name => 'test',
        permission => 'admin',
        repo_names => ['PerlChina/sandbox']
    );

=item update_team

    $organization->update_team($team_id,
        name => 'test',
        permission => 'push',
        repo_names => ['PerlChina/sandbox']
    );

=item delete_team

    $organization->delete_team($team_id);

=item team_members

    my $users = $organization->team_members($team_id);

=item add_team_member

    $organization->add_team_member($team_id, $user);

=item remove_team_member

    $organization->remove_team_member($team_id, $user);

=item team_repositories

    my $team_repositories = $organization->team_repositories($team_id);

=item add_team_repositories

    $organization->add_team_repositories($team_id, "$org/$respo");

=item remove_team_repositories

    $organization->remove_team_repositories($team_id, "$org/$respo");

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
