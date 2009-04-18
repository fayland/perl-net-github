package Net::GitHub::V2::Issues;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::V2::Role';

sub list {
    my ( $self, $state ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "issues/list/$owner/$repo/$state", 'issues' );
}

sub view {
    my ( $self, $id ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "issues/show/$owner/$repo/$id", 'issue' );
}

sub open {
    my ( $self, $title, $body ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/open/$owner/$repo",
        title => $title,
        body  => $body,
        'issue'
    );
}
sub close {
    my ( $self, $id ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/close/$owner/$repo/$id", 'issue' );
}
sub reopen {
    my ( $self, $id ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/reopen/$owner/$repo/$id", 'issue' );
}

sub edit {
    my ( $self, $id, $title, $body ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/edit/$owner/$repo/$id",
        title => $title,
        body  => $body
    );
}

sub add_label {
    my ( $self, $id, $label ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/label/add/$owner/$repo/$label/$id", 'labels' );
}
sub remove_label {
    my ( $self, $id, $label ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/label/remove/$owner/$repo/$label/$id", 'labels' );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V2::Issues - GitHub Issues API

=head1 SYNOPSIS

    use Net::GitHub::V2::Issues;

    my $issue = Net::GitHub::V2::Issues->new(
        owner => 'fayland', repo => 'perl-net-github'
    );

=head1 DESCRIPTION

L<http://develop.github.com/p/issues.html>

For those B<(authentication required)> below, you must set login and token (in L<https://github.com/account>

    my $issue = Net::GitHub::V2::Issues->new(
        owner => 'fayland', repo => 'perl-net-github',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
    );

=head1 METHODS

=over 4

=item list

    my $issues = $issue->list('open');
    my $issues = $issue->list('closed');

see a list of issues for a project

=item view

    my $iss = $issue->view( $issues->[0]->{number} );

get data on an individual issue by number

=item open

    my $iss = $issue->open( 'Bug title', 'Bug detail' );

open a new issue on a project (authentication required)

=item close

=item reopen

    $issue->close( $number );
    $issue->reopen( $number );

close or reopen an issue (authentication required)

=item edit

    $issue->edit( $number, 'New bug title', 'New bug detail' );

edit an existing issue (authentication required)

=item add_label

=item remove_label

    my $labels = $issue->add_label( $number, 'testing' );
    my $labels = $issue->remove_label( $number, $label );

add/remove a label (authentication required)

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.