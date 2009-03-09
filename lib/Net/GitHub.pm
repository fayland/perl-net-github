package Net::GitHub;

use Moose;

our $VERSION = '0.04';
our $AUTHORITY = 'cpan:FAYLAND';

use Net::GitHub::Project;
use Net::GitHub::User;
use Net::GitHub::Search;

with 'Net::GitHub::Role';

sub project {
    my $self = shift;
    return Net::GitHub::Project->new( @_ );
}

sub user {
    my $self = shift;
    return Net::GitHub::User->new( @_ );
}

has '_search' => (
    is => 'rw',
    isa => 'Net::GitHub::Search',
    lazy => 1,
    default => sub {
        return Net::GitHub::Search->new();
    },
    handles => ['search'],
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub - Perl Interface for github.com

=head1 SYNOPSIS

    use Net::GitHub;

    # for http://github.com/fayland/perl-net-github/tree/master
    my $github = Net::GitHub->new();
    
    # project
    my $project = $github->project( owner => 'fayland', name => 'perl-net-github' );
    print $project->public_clone_url;
    print Dumper(\$project->commits);
    
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

=head1 ALPHA WARNING

Net::GitHub is still in its infancy. backwards compatibility is not yet guaranteed.

=head1 METHODS

=head2 project

    $github->project( owner => 'fayland', name => 'perl-net-github' );
    $github->project( 'fayland', 'perl-net-github' );

instance of L<Net::GitHub::Project>

=head2 user

    $github->user( 'fayland' );

instance of L<Net::GitHub::User>

=head2 search

    $github->search('fayland');

handled by L<Net::GitHub::Search>

=head1 Git URL

L<http://github.com/fayland/perl-net-github/tree/master>

=head1 SEE ALSO

L<Moose>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
