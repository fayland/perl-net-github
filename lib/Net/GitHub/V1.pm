package Net::GitHub::V1;

use Any::Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::V1::Project;
use Net::GitHub::V1::User;
use Net::GitHub::V1::Search;

with 'Net::GitHub::V1::Role';

sub project {
    my $self = shift;
    return Net::GitHub::V1::Project->new( @_ );
}

sub user {
    my $self = shift;
    return Net::GitHub::V1::User->new( @_ );
}

has '_search' => (
    is => 'rw',
    isa => 'Net::GitHub::V1::Search',
    lazy => 1,
    default => sub {
        return Net::GitHub::V1::Search->new();
    },
    handles => ['search'],
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V1 - (DEPERCATED, use V2) Perl Interface for github.com (V1)

=head1 SYNOPSIS

    use Net::GitHub::V1;

    # for http://github.com/fayland/perl-net-github/tree/master
    my $github = Net::GitHub::V1->new();
    
    # project
    my $prj = $github->project( owner => 'fayland', name => 'perl-net-github' );
    print $prj->description;
    print $prj->public_clone_url;
    my @commits = $prj->commits;
    foreach my $c ( @commits ) {
        my $commit = $prj->commit( $c->{id} );
    }
    my @downloads = $prj->downloads;
    $prj->signin( 'login', 'password' );
    $prj->wiki->new_page( 'PageTitle', "Page Content\n\nLine 2\n" );
    
    # user
    my $user = $github->user( 'fayland' );
    foreach my $repos ( @{ $user->repositories} ) {
        print "$repos->{owner} + $repos->{name}\n";
    }
    
    # search
    my $result = $github->search( 'fayland' );

=head1 DESCRIPTION

L<http://github.com> is a popular git host.

Please feel free to fork L<http://github.com/fayland/perl-net-github/tree/master>, fix or contribute some code. :)

=head1 METHODS

=head2 project

    $github->project( owner => 'fayland', name => 'perl-net-github' );
    $github->project( 'fayland', 'perl-net-github' );

instance of L<Net::GitHub::V1::Project>

=head2 user

    $github->user( 'fayland' );

instance of L<Net::GitHub::V1::User>

=head2 search

    $github->search('fayland');

handled by L<Net::GitHub::V1::Search>

=head1 Git URL

L<http://github.com/fayland/perl-net-github/tree/master>

=head1 SEE ALSO

L<Any::Moose>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
