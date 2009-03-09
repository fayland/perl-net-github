package Net::GitHub::Role;

use Moose::Role;

our $VERSION = '0.03';
our $AUTHORITY = 'cpan:FAYLAND';

use JSON::Any;
use WWW::Mechanize;
use Carp qw/croak/;
use Data::Dumper;

has 'debug' => ( is => 'rw', isa => 'Str', default => 0 );

# login
has 'email' => ( isa => 'Str', is => 'rw', default => '' );
has 'password' => ( isa => 'Str', is => 'rw', default => '' );
has 'login'  => ( is => 'rw', isa => 'Str', default => '' );
has 'token' => ( is => 'rw', isa => 'Str', default => '' );

# api
has 'api_url' => ( is => 'ro', default => 'http://github.com/api/v1/json/');

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
has 'json' => (
    is => 'ro',
    isa => 'JSON::Any',
    lazy => 1,
    default => sub {
        return JSON::Any->new;
    }
);

sub get {
    my ( $self, $url ) = @_;

    $self->ua->get($url);
    if ( ! $self->ua->success() ) {
        croak 'Server threw an error '
          . $self->ua->response->status_line . ' for '
          . $url;
    } else {
#        open(my $fh, '>', '/home/fayland/git/perl-net-github/t/mockdata/single_commit.json');
#        print $fh $self->ua->content;
#        close($fh);
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

=head1 ATTRIBUTES

=over 4

=item email

=item password

=item login

=item token

=back

=head1 METHODS

=over 4

=item ua

instance of L<WWW::Mechanize>

=item json

instance of L<JSON::Any>

=item get

wrap ua->get with success check

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.