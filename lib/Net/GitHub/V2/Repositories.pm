package Net::GitHub::V2::Repositories;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::Role';

sub search {
    my ( $self, $word ) = @_;
    
    my $url = $self->api_url . 'repos/search/' . uri_escape($word);
    my $json = $self->get($url);
    my $data = $self->json->jsonToObj($json);
    return $data;
}

sub show {
    my ( $self, $owner, $repo ) = @_;
    
    my $url = $self->api_url . 'repos/show/' . $owner . '/' . $repo;
    my $json = $self->get($url);
    my $data = $self->json->jsonToObj($json);
    return $data;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Repositories - GitHub Repositories API

=head1 SYNOPSIS

    use Net::GitHub::Repositories;

    my $repos = Net::GitHub::Repositories->new();
    my $result = $repos->search('fayland');
    foreach my $repos ( @{ $result->{repositories} } ) {
        print "$repos->{description}\n";
    }

=head1 DESCRIPTION

=head1 METHODS


=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.