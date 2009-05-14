package Net::GitHub::V2::Object;

use Moose;

our $VERSION = '0.07';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::HasRepo';

sub tree {
    my ( $self, $tree_sha1 ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "tree/show/$owner/$repo/$tree_sha1", 'tree' );
}

sub blob {
    my ( $self, $tree_sha1, $path ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "blob/show/$owner/$repo/$tree_sha1/$path", 'blob' );
}

sub raw {
    my ( $self, $sha1 ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get( "blob/show/$owner/$repo/$sha1" );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V2::Object - Git Object API

=head1 SYNOPSIS

    use Net::GitHub::V2::Object;

    my $obj = Net::GitHub::V2::Object->new(
        owner => 'fayland', repo => 'perl-net-github'
    );

=head1 DESCRIPTION

L<http://develop.github.com/p/object.html>

=head1 METHODS

=over 4

=item tree

    my $tree = $obj->tree( $tree_sha1 );

get the contents of a tree by tree sha

=item blob

    my $blob = $obj->blob( $tree_sha1, 'lib/Net/GitHub.pm' );

get the data about a blob by tree sha and path

=item raw

    my $raw = $obj->raw( $sha1 );

get the contents of a blob (can be tree, file or commits)

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
