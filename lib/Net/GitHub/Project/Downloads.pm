package Net::GitHub::Project::Downloads;

use Moose;

our $VERSION = '0.05';
our $AUTHORITY = 'cpan:FAYLAND';

use HTML::TreeBuilder;

with 'Net::GitHub::Role';
with 'Net::GitHub::Project::Role';

has 'downloads' => (
    is => 'rw',
    isa => 'ArrayRef',
    auto_deref => 1,
    lazy_build => 1,
);
sub _build_downloads {
    my $self = shift;
    
    my @downloads;
    my $content = $self->get( $self->project_url . 'downloads' );
    
    my $tree = HTML::TreeBuilder->new;
    $tree->parse_content($content);
    $tree->elementify;

    my @trs = $tree->look_down( '_tag', 'tr', 'id', qr/^download_\d+$/ );
    foreach my $_tr ( @trs ) {
        my @tds = $_tr->find_by_tag_name('td');

        my $a = $tds[1]->find_by_tag_name('a');
        my $url = $a->attr('href');
        my $filename = $a->content_array_ref->[0];
        
        my $description = $tds[2]->content_array_ref->[0];
        my $date = $tds[3]->content_array_ref->[0];
        my $size = $tds[4]->content_array_ref->[0];
        
        push @downloads, {
            url => $url,
            filename => $filename,
            description => $description,
            date => $date,
            size => $size,
        };
    }
    
    $tree = $tree->delete;
    
    return \@downloads;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Project::Downloads - GitHub Project Downloads Section

=head1 SYNOPSIS

    use Net::GitHub::Project::Downloads;

    my $dl = Net::GitHub::Project::Downloads->new(
        owner => 'fayland', name => 'perl-net-github'
    );
    
    my @downloads = $dl->downloads;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item downloads

    foreach my $download ( @downloads ) {
        print $download->{filename}, $download->{url},
              $download->{description},
              $download->{date}, $download->{size}, "\n";
    }

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.