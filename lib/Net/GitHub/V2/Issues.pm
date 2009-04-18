package Net::GitHub::V2::Issues;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::Role';

sub list {
    my ( $self, $owner, $repo, $state ) = @_;
    return $self->get_json_to_obj( "issues/list/$owner/$repo/$state" );
}

sub view {
    my ( $self, $owner, $repo, $id ) = @_;
    return $self->get_json_to_obj( "issues/show/$owner/$repo/$id" );
}

sub open {
    my ( $self, $owner, $repo, $title, $body ) = @_;
    return $self->get_json_to_obj_authed( "issues/open/$owner/$repo",
        title => $title,
        body  => $body
    );
}
sub close {
    my ( $self, $owner, $repo, $id ) = @_;
    return $self->get_json_to_obj_authed( "issues/close/$owner/$repo/$id" );
}
sub reopen {
    my ( $self, $owner, $repo, $id ) = @_;
    return $self->get_json_to_obj_authed( "issues/reopen/$owner/$repo/$id" );
}

sub edit {
    my ( $self, $owner, $repo, $id, $title, $body ) = @_;
    return $self->get_json_to_obj_authed( "issues/edit/$owner/$repo/$id",
        title => $title,
        body  => $body
    );
}

sub add_label {
    my ( $self, $owner, $repo, $id, $label ) = @_;
    return $self->get_json_to_obj_authed( "issues/label/add/$owner/$repo/$label/$id" );
}
sub remove_label {
    my ( $self, $owner, $repo, $id, $label ) = @_;
    return $self->get_json_to_obj_authed( "issues/label/remove/$owner/$repo/$label/$id" );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Issues - GitHub Issues API

=head1 SYNOPSIS

    use Net::GitHub::Issues;

    my $repos = Net::GitHub::Issues->new();


=head1 DESCRIPTION

L<http://develop.github.com/p/issues.html>

=head1 METHODS


=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.