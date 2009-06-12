package Net::GitHub::V1::Project::Wiki;

use Any::Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V1::Role';
with 'Net::GitHub::V1::Project::Role';

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

    return ( $resp->content =~ /$page_title/s ) ? 1 : 0;
}

sub edit_page {
    my ( $self, $old_title, $new_content ) = @_;
    
    $self->signin();
    
    # http://github.com/fayland/perl-net-github/wikis/testpage/edit
    $old_title = lc($old_title);
    my $c = $self->get( $self->project_url . 'wikis/' . uri_escape($old_title) . '/edit' );
    return 0 unless $c =~ /wiki\[body\]/s;
    my $resp = $self->submit_form(
        with_fields => {
            'wiki[body]'  => $new_content,
        },
        button => 'commit'
    );

    unless ( $resp->is_success ) {
        croak $resp->as_string();
    }
    return 1;
}

sub edit_or_new {
    my $self = shift;
    my ( $page_title, $page_content ) = @_;
    
    # http://wiki.github.com/fayland/perl-net-github/testpage2
    my $wiki_url = 'http://wiki.github.com/' . 
        $self->owner . '/' . $self->name . '/' . uri_escape($page_title);
    my $resp = $self->ua->get( $wiki_url );
    if ( $resp->code == 404 ) {
        return $self->new_page(@_);
    } else {
        return $self->edit_page(@_);
    }
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V1::Project::Wiki - GitHub Project Wiki Section (V1)

=head1 SYNOPSIS

    use Net::GitHub::V1::Project::Wiki;

    my $wiki = Net::GitHub::V1::Project::Wiki->new(
        owner => 'fayland', name => 'perl-net-github',
        login => 'fayland', password => 'passmein', # your real login/password
    );
    
    $wiki->new_page( 'PageTitle', "Page Content\n\nLine 2\n" );
    $wiki->edit_page( 'PageTitle', "New Page Content\n\nLine 2\n" );
    $wiki->edit_or_new( 'PageTitle', "Page Content\n\nLine 2\n" );

=head1 DESCRIPTION

=head1 B<login> required

For the following "B<login> required", it means:

you must specify the login and password in B<new>

    my $wiki = Net::GitHub::V1::Project::Wiki->new(
        owner => 'fayland', name => 'perl-net-github',
        login => 'fayland', password => 'passmein', # your real login/password
    );

OR you must call B<signin> before the I<method>

    $wiki->signin( 'login', 'password' );

=head1 METHODS

=over 4

=item new_page

    $wiki->new_page( 'PageTitle', "Page Content\n\nLine 2\n" );

return 1 if page is created successfully.

B<login> required.

=item edit_page

    $wiki->edit_page( 'PageTitle', "New Page Content\n\nLine 2\n" );

return 1 if page is updated successfully.

B<login> required.

=item edit_or_new

    $wiki->edit_or_new( 'PageTitle', "Page Content\n\nLine 2\n" );

fallback to new_page if page is not created yet, or else, fallback to edit_page.

B<login> required.

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
