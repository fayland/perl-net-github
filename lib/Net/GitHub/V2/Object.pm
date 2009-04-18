package Net::GitHub::V2::Object;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V2::Role';

sub tree {
    my ( $self, $owner, $repo, $tree_sha1 ) = @_;
    return $self->get_json_to_obj( "tree/show/$owner/$repo/$tree_sha1" );
}

sub blob {
    my ( $self, $owner, $repo, $tree_sha1, $path ) = @_;
    return $self->get_json_to_obj( "blob/show/$owner/$repo/$tree_sha1/$path" );
}

sub raw {
    my ( $self, $owner, $repo, $tree_sha1 ) = @_;
    return $self->get( "blob/show/$owner/$repo/$tree_sha1" );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Object - Git Object API

=head1 SYNOPSIS

    use Net::GitHub::Object;

    my $repos = Net::GitHub::Object->new();


=head1 DESCRIPTION

L<http://develop.github.com/p/object.html>

=head1 METHODS


=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.