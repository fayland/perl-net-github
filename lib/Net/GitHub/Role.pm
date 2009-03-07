package Net::GitHub::Role;

use Moose::Role;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use WWW::Mechanize;
use Carp qw/croak/;

# http://github.com/fayland/perl-net-github/tree/master
has 'owner' => ( isa => 'Str', is => 'rw' );
has 'name'  => ( isa => 'Str', is => 'rw' );

# login
has 'email' => ( isa => 'Str', is => 'rw', default => '' );
has 'password' => ( isa => 'Str', is => 'rw', default => '' );

sub args_to_pass {
    my $self = shift;
    my $ret;
    foreach my $col ('owner', 'name', 'email', 'password' ) {
        $ret->{$col} = $self->$col;
    }
    return $ret;
}

has 'ua' => (
    isa     => 'WWW::Mechanize',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $m    = WWW::Mechanize->new(
			agent       => 'perl-net-github',
            cookie_jar  => {},
            stack_depth => 1,
            timeout     => 60,
        );
        return $m;
    }
);

sub get {
    my ( $self, $url) = @_;

    $self->ua->get($url);
    if ( ! $self->ua->success() ) {
        croak 'Server threw an error '
          . $self->ua->response->status_line . ' for '
          . $url;
    } else {
        return $self->ua->content;
    }
}


no Moose::Role;

1;
__END__

=head1 NAME

Net::GitHub::Role - Common between Net::GitHub::* libs

=head1 SYNOPSIS

    package Net::GitHub::XXX;
    
    use Moose;
    with 'Net::GitHub::Role';

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item owner

'fayland' of http://github.com/fayland/perl-net-github/tree/master

=item name

'perl-net-github' of http://github.com/fayland/perl-net-github/tree/master

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.