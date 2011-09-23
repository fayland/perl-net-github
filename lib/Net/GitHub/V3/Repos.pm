package Net::GitHub::V3::Repos;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub list {
    my ( $self, $type ) = @_;
    $type ||= 'all';
    my $u = '/user/repos';
    $u .= '?type=' . $type if $type ne 'all';
    return $self->query($u);
}

sub list_user {
    my ($self, $user, $type) = @_;
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
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos));
}

sub update {
    my ($self, $user, $repos, $new_repos) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos);
    return $self->query('PATCH', $u, $new_repos);
}

sub contributors {
    my ($self, $user, $repos) = @_;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/contributors');
}
sub languages {
    my ($self, $user, $repos) = @_;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/languages');
}
sub teams {
    my ($self, $user, $repos) = @_;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/teams');
}
sub tags {
    my ($self, $user, $repos) = @_;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/tags');
}
sub branches {
    my ($self, $user, $repos) = @_;
    return $self->query("/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/branches');
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

=head1 DESCRIPTION

=head2 METHODS

=head3 Repos

L<http://developer.github.com/v3/repos/>

=over 4

=item list

=item list_user

=item list_org

    my $rp = $repos->list;
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

=item update

    my $rp = $repos->get('fayland', 'perl-net-github');
    $repos->update('fayland', 'perl-net-github', { homepage => 'https://metacpan.org/module/Net::GitHub' });

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

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
