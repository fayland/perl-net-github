package Net::GitHub::Project::Wiki;

use Moose;

our $VERSION = '0.04';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::Role';
with 'Net::GitHub::Project::Role';

sub new_page {
    my ( $self, $page_title, $page_content ) = @_;
    
    $self->signin();
    
    # get http://github.com/fayland/perl-net-github/wikis/new
    $self->get( $self->project_url . 'wikis/new' );
    my $resp = $self->submit_form(
        with_fields => {
            'wiki[title]' => $page_title,
            'wiki[body]'  => $page_content,
        },
        button => 'commit'
    );

    unless ( $resp->is_success ) {
        croak $resp->as_string();
    }

    my $match = lc($page_title);
    if ( $resp->content =~ /\/$match/ ) {
        return 1;
    } else {
        return 0;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Project::Wiki - GitHub Project Wiki Section

=head1 SYNOPSIS

    use Net::GitHub::Project::Wiki;

    my $wiki = Net::GitHub::Project::Wiki->new(
        owner => 'fayland', name => 'perl-net-github'
    );


=head1 DESCRIPTION

=head1 METHODS

=over 4

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
