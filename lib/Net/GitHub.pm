package Net::GitHub;

use Moose;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::Role';

has 'project' => (
    is => 'rw',
    isa => 'Net::GitHub::Project',
    lazy => 1,
    default => sub {
        my $self = shift;
        require Net::GitHub::Project;
        return Net::GitHub::Project->new( $self->args_to_pass );
    }
);

has '_search' => (
    is => 'rw',
    isa => 'Net::GitHub::Search',
    lazy => 1,
    default => sub {
        require Net::GitHub::Search;
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
    my $github = Net::GitHub->new( owner => 'fayland', name => 'perl-net-github' );
    
    # project
    print $github->project->public_clone_url;
    print Dumper(\$github->project->commits);

=head1 DESCRIPTION

L<http://github.com> is a popular git host.

Please feel free to fork L<http://github.com/fayland/perl-net-github/tree/master>, fix or contribute some code. :)

=head1 METHODS

=head2 $github->project

instance of L<Net::GitHub::Project>

=head2 $github->search

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
