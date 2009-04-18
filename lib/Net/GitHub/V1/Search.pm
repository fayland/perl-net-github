package Net::GitHub::V1::Search;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V1::Role';

sub search {
    my ( $self, $word ) = @_;
    
    my $url = $self->api_url . 'search/' . uri_escape($word);
    my $json = $self->get($url);
    my $data = $self->json->jsonToObj($json);
    return $data;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V1::Search - GitHub Search

=head1 SYNOPSIS

    use Net::GitHub::V1::Search;

    my $search = Net::GitHub::V1::Search->new();
    my $result = $search->search('fayland');
    foreach my $repos ( @{ $result->{repositories} } ) {
        print "$repos->{description}\n";
    }

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item search

use L<http://github.com/guides/the-github-api> to get JSON result

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.