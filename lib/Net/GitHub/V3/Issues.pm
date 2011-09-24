package Net::GitHub::V3::Issues;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

has 'user'  => (is => 'rw', isa => 'Str');
has 'repos' => (is => 'rw', isa => 'Str');

sub issues {
    my $self = shift;
    my $args = @_ % 2 ? shift : { @_ };
    
    my @p;
    foreach my $p (qw/filter state labels sort direction since/) {
        push @p, "$p=" . $arg->{$p} if exists $args->{$p};
    }
    my $u = '/issues';
    $u .= '?' . join('&', @p) if @p;
    return $self->query($u);
}

sub repos_issues {
    my $self = shift;
    
    if (@_ < 2) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my $user  = shift @_;
    my $repos = shift @_;
    
    my @p;
    foreach my $p (qw/milestone state assignee mentioned labels sort direction since/) {
        push @p, "$p=" . $arg->{$p} if exists $args->{$p};
    }
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues';
    $u .= '?' . join('&', @p) if @p;
    return $self->query($u);
}

sub issue {
    my $self = shift;
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $cid) = @_;
    
    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . uri_escape($cid);
    return $self->query($u);
}

sub create_issue {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $issue) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues';
    return $self->query('POST', $u, $issue);
}

sub update_issue {
    my $self = shift;
    
    if (@_ == 1) {
        unshift @_, $self->repos;
        unshift @_, $self->user;
    }
    my ($user, $repos, $issue_id, $new_issue) = @_;

    my $u = "/repos/" . uri_escape($user) . "/" . uri_escape($repos) . '/issues/' . uri_escape($issue_id);
    return $self->query('PATCH', $u, $new_issue);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::Issues - GitHub Issues API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $issue = $gh->issue;

=head1 DESCRIPTION

=head2 METHODS

=head3 Issues

L<http://developer.github.com/v3/issues/>

=over 4

=item issues

    my @issues = $issue->issues();
    my @issues = $issue->issues(filter => 'assigned', state => 'open');

=back

<B>SET user/repos before call methods below</B>

    $issue->user('fayland');
    $issue->repos('perl-net-github');
    my @issues = $issue->repos_issues;

    # or you can always pass them as the arguments
    my @issues = $issue->repos_issues($user, $repos);

=over 4

=item repos_issues

    # don't be confused
    my @issues = $issue->repos_issues;
    my @issues = $issue->repos_issues($user, $repos);
    my @issues = $issue->repos_issues(state => 'open');
    my @issues = $issue->repos_issues( { state => 'open' } );
    my @issues = $issue->repos_issues($user, $repos, state => 'open');
    my @issues = $issue->repos_issues($user, $repos, { state => 'open' } );

=item issue

    my $issue = $issue->issue($issue_id);

=item create_issue

    my $isu = $issue->create_issue( {
        "title" => "Found a bug",
        "body" => "I'm having a problem with this.",
        "assignee" => "octocat",
        "milestone" => 1,
        "labels" => [
            "Label1",
            "Label2"
        ]
    } );

=item update_issue

    my $isu = $issue->update_issue( $issue_id, {
        state => 'closed'
    } );

=back

=head3 Issue Comments API

L<http://developer.github.com/v3/issues/comments/

=over 4

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
