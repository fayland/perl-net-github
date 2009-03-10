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
    my %fields = (
        'wiki[title]' => $page_title,
        'wiki[body]'  => $page_content,
    );
    $self->form_with_fields(keys %fields);
    # set action="/fayland/perl-net-github/wikis"
    $self->current_form->action("/" . $self->owner . "/" . $self->name . "/wikis");
    $mech->set_fields( %fields );
    my $resp = $self->click( 'commit' );
    
    unless ( $resp->is_success ) {
        croak $resp->as_string();
    }
    
    return 1;
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