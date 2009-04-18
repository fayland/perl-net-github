package Net::GitHub::V2::Commits;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::Role';

sub branch {
    my ( $self, $owner, $repo, $branch ) = @_;
    $branch ||= 'master';
    return $self->get_json_to_obj( "commits/list/$owner/$repo/$branch" );
}

sub file {
    my ( $self, $owner, $repo, $branch, $path ) = @_;
    return $self->get_json_to_obj( "commits/list/$owner/$repo/$branch/$path" );
}

sub show {
    my ( $self, $owner, $repo, $sha1 ) = @_;
    return $self->get_json_to_obj( "commits/show/$owner/$repo/$sha1" );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Commits - GitHub Commits API

=head1 SYNOPSIS

    use Net::GitHub::Commits;

    my $repos = Net::GitHub::Commits->new();


=head1 DESCRIPTION

L<http://develop.github.com/p/commits.html>

=head1 METHODS


=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.