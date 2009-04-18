package Net::GitHub;

use Moose;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

has 'version' => ( isa => 'Int', is => 'ro', default => 2 );

has '_obj' => (
    is   => 'ro',
    isa  => 'Object',
    lazy => 1,
    default => sub {
        my $self = shift;
        if ( $self->version == 1 ) {
            require Net::GitHub::V1;
            return Net::GitHub::V1->new(@_);
        } else {
            require Net::GitHub::V2;
            return Net::GitHub::V2->new(@_);
        }
    },
    handles => ['api_url']
);


=pod

    handles => sub {
        my ( $self, $meta ) = @_;
        if ( $meta->get_attribute('version') == 1 ) {
            return map { $_ => $_ } ('project', 'user', 'search');
        } else {
            return map { $_ => $_ } ('repos', 'user', 'commit', 'issue',
                                     'object', 'obj_tree', 'obj_blob', 'obj_raw',
                                     'network', 'network_meta', 'network_data_chunk');
        }
    }

);

=cut

no Moose;
__PACKAGE__->meta->make_immutable;

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

Please feel free to fork L<http://github.com/fayland/perl-net-github/tree/master>, fix or contribute some code. :)

Read L<Net::GitHub::V2> for more details.

    use Net::GitHub;

    my $github = Net::GitHub->new(  # Net::GitHub::V2, default
        owner => 'fayland', repo  => 'perl-net-github',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
    );
    
    $github->repos->create( 'sandbox3', 'Sandbox desc', 'http://fayland.org/', 1 );
    $github->repos->show();
    
    my $followers = $github->user->followers();
    $github->user->update( name => 'Fayland Lam' );
    
    my $commits = $github->commit->branch();
    my $commits = $github->commit->file( 'master', 'lib/Net/GitHub.pm' );
    my $co_detail = $github->commit->show( $sha1 );
    
    my $issues = $github->issue->list('open');
    my $issue  = $github->issue->open( 'Bug title', 'Bug detail' );
    $github->issue->close( $number );
    
    my $tree = $github->obj_tree( $tree_sha1 );
    my $blob = $github->obj_blob( $tree_sha1, 'lib/Net/GitHub.pm' );
    my $raw  = $github->obj_raw( $sha1 );
    
    $github->network_meta;
    $github->network_data_chunk( $net_hash );

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
