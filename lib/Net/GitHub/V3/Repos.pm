package Net::GitHub::V3::Repos;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

has 'user'  => (is => 'rw', isa => 'Str');
has 'repos' => (is => 'rw', isa => 'Str');

sub list {
    my ( $self, $type ) = @_;
    $type ||= 'all';
    my $u = '/user/repos';
    $u .= '?type=' . $type if $type ne 'all';
    return $self->query($u);
}

sub list_user {
    my ($self, $user, $type) = @_;
    $user ||= $self->user;
    $type ||= 'all';
    my $u = "/users/" . uri_escape($user) . "/repos";
    $u .= '?type=' . $type if $type ne 'all';
    return $self->query($u);
}

sub list_org {
    my ($self, $org, $type) = @_;
    $type ||= 'all';
    my $u = "/orgs/" . uri_escape($org) . "/repos";
    $u .= '?type=' . $type if $type ne 'all';
    return $self->query($u);
}

sub create {
    my ( $self, $data ) = @_;

    my $u = '/user/repos';
    if (exists $data->{org}) {
        my $o = delete $data->{org};
        $u = "/orgs/" . uri_escape($o) . "/repos";
    }

    return $self->query('POST', $u, $data);
}

sub get {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos));
}

sub update {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $new_repos) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos);
    return $self->query('PATCH', $u, $new_repos);
}

sub contributors {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/contributors');
}
sub languages {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/languages');
}
sub teams {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/teams');
}
sub tags {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/tags');
}
sub branches {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/branches');
}

## http://developer.github.com/v3/repos/collaborators/

sub collaborators {
    my ($self, $user, $repos) = @_;
    $user ||= $self->user; $repos ||= $self->repos;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/collaborators');
}

sub is_collaborator {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $collaborator) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/collaborators/' . uri_escape($collaborator);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query($u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

sub add_collaborator {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $collaborator) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/collaborators/' . uri_escape($collaborator);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('PUT', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}
sub delete_collaborator {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $collaborator) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/collaborators/' . uri_escape($collaborator);
    
    my $old_raw_response = $self->raw_response;
    $self->raw_response(1); # need check header
    my $res = $self->query('DELETE', $u);
    $self->raw_response($old_raw_response);
    return $res->header('Status') =~ /204/ ? 1 : 0;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::Repos - GitHub Repos API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $repos = $gh->repos;
    
    # set user/repos for simple calls
    $repos->user('fayland');
    $repos->repos('perl-net-github');
    my @contributors = $repos->contributors; # don't need pass user and repos
    

=head1 DESCRIPTION

=head2 METHODS

=head3 Repos

L<http://developer.github.com/v3/repos/>

=over 4

=item list

=item list_user

=item list_org

    my $rp = $repos->list; # or my @rp = $repos->list;
    my $rp = $repos->list('private');
    my $rp = $repos->list_user('c9s');
    my $rp = $repos->list_user('c9s', 'member');
    my $rp = $repos->list_org('perlchina');
    my $rp = $repos->list_org('perlchina', 'public');

=item create

    # create for yourself
    my $rp = $repos->create( {
        "name" => "Hello-World",
        "description" => "This is your first repo",
        "homepage" => "https://github.com"
    } );
    # create for organization
    my $rp = $repos->create( {
        "org"  => "perlchina", ## the organization
        "name" => "Hello-World",
        "description" => "This is your first repo",
        "homepage" => "https://github.com"
    } );

=item get

    my $rp = $repos->get('fayland', 'perl-net-github');

=back

<B>SET user/repos before call methods below</B>

    $repos->user('fayland');
    $repos->repos('perl-net-github');

=over 4

=item update

    $repos->update({ homepage => 'https://metacpan.org/module/Net::GitHub' });

=item contributors

=item languages

=item teams

=item tags

=item contributors

    my $contributors = $repos->contributors;
    my $languages = $repos->languages;
    my $teams = $repos->teams;
    my $tags = $repos->tags;
    my $branches = $repos->branches;

=back

=head3 Repo Collaborators API

L<http://developer.github.com/v3/repos/collaborators/>

=over 4

=item collaborators

=item is_collaborator

=item add_collaborator

=item delete_collaborator

    my @collaborators = $repos->collaborators;
    my $is = $repos->is_collaborator('fayland');
    $repos->add_collaborator('fayland');
    $repos->delete_collaborator('fayland');

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
