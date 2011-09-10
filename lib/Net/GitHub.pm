package Net::GitHub;

use Any::Moose;

our $VERSION = '0.30';
our $AUTHORITY = 'cpan:FAYLAND';

sub new {
    my $class = shift;
    my $params = $class->BUILDARGS(@_);

    my $obj;
    if ( exists $params->{version} and $params->{version} == 1 ) {
        require Net::GitHub::V1;
        return Net::GitHub::V1->new($params);
    } else {
        require Net::GitHub::V2;
        return Net::GitHub::V2->new($params);
    }

    #return $class->meta->new_object( __INSTANCE__ => $obj, @_,);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
__END__

=head1 NAME

Net::GitHub - Perl Interface for github.com

=head1 SYNOPSIS

    use Net::GitHub;

    my $github = Net::GitHub->new(  # Net::GitHub::V2, default
        owner => 'fayland', repo => 'perl-net-github'
    );

    # DEPERCATED, for backwards
    my $github = Net::GitHub->new(  # Net::GitHub::V1
        version => 1,
        owner => 'fayland', name => 'perl-net-github'
    );

=head1 DESCRIPTION

L<http://github.com> is a popular git host.

This distribution provides easy methods to access GitHub via their APIs.

See L<http://develop.github.com/p/general.html> for details of the GitHub APIs
this distribution uses.

Please feel free to fork L<http://github.com/fayland/perl-net-github/tree/master>, fix or contribute some code. :)

Read L<Net::GitHub::V2> for more details.

    use Net::GitHub;

    my $github = Net::GitHub->new(  # Net::GitHub::V2, default
        owner => 'fayland', repo  => 'perl-net-github',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
    );

    # L<Net::GitHub::V2::Repositories>
    $github->repos->create( 'sandbox3', 'Sandbox desc', 'http://fayland.org/', 1 );
    $github->repos->show();

    # L<Net::GitHub::V2::Users>
    my $followers = $github->user->followers();
    $github->user->update( name => 'Fayland Lam' );

    # L<Net::GitHub::V2::Commits>
    my $commits = $github->commit->branch();
    my $commits = $github->commit->file( 'master', 'lib/Net/GitHub.pm' );
    my $co_detail = $github->commit->show( $sha1 );

    # L<Net::GitHub::V2::Issues>
    my $issues = $github->issue->list('open');
    my $issue  = $github->issue->open( 'Bug title', 'Bug detail' );
    $github->issue->close( $number );

    # L<Net::GitHub::V2::Object>
    my $tree = $github->obj_tree( $tree_sha1 );
    my $blob = $github->obj_blob( $tree_sha1, 'lib/Net/GitHub.pm' );
    my $raw  = $github->obj_raw( $sha1 );

    # L<Net::GitHub::V2::Network>
    $github->network_meta;
    $github->network_data_chunk( $net_hash );
    
    # L<Net::GitHub::V2::Organizations>
    $github->organization->organizations('github');
    $github->organization->teams('PerlChina');

=head1 Git URL

L<http://github.com/fayland/perl-net-github/tree/master>

=head1 SEE ALSO

L<Any::Moose>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009-2011 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
