package Net::GitHub::V1::Role;

use Moose::Role;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use JSON::Any;
use WWW::Mechanize::GZip;
use Carp qw/croak/;

# login
has 'login'  => ( is => 'rw', isa => 'Str', default => '' );
has 'password' => ( isa => 'Str', is => 'rw', default => '' );
has 'token' => ( is => 'rw', isa => 'Str', default => '' );
has 'is_signin' => ( is => 'rw', isa => 'Bool', default => 0 );

# api
has 'api_url' => ( is => 'ro', default => 'http://github.com/api/v1/json/');

has 'ua' => (
    isa     => 'WWW::Mechanize',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $m    = WWW::Mechanize::GZip->new(
			agent       => "perl-net-github $VERSION",
            cookie_jar  => {},
            stack_depth => 1,
            timeout     => 60,
        );
        return $m;
    },
);

sub get {
    my $self = shift;
    
    my $resp = $self->ua->get(@_);
    unless ( $resp->is_success ) {
        croak $resp->as_string();
    }
    return $resp->content();
}

sub submit_form {
    my $self = shift;
    
    my $resp = $self->ua->submit_form(@_);
    unless ( $resp->is_success ) {
        croak $resp->as_string();
    }
    return $resp;
}

has 'json' => (
    is => 'ro',
    isa => 'JSON::Any',
    lazy => 1,
    default => sub {
        return JSON::Any->new;
    }
);

sub signin {
    my $self = shift;
    
    return 1 if $self->is_signin;

    croak "login and password are required" unless $self->login and $self->password;
    
    my $ua = $self->ua;
    $ua->get( "https://github.com/login" );
    croak "Couldn't recognize login page!\n" unless $ua->content =~ /Login/;

    $ua->submit_form(
		with_fields   => {
			login     => $self->login,
			password  => $self->password,
		}
    );
    
    # github_user = null
    if ( $ua->content() =~ /github_user\s+\=\s+null/s ) {
        croak "Incorrect login or password." if $ua->content =~ /Login/;
        return 0;
    } else {
        $self->is_signin(1);
        return 1;
    }
}

no Moose::Role;

1;
__END__

=head1 NAME

Net::GitHub::V1::Role - Common between Net::GitHub::V1::* libs

=head1 SYNOPSIS

    package Net::GitHub::V1::XXX;
    
    use Moose;
    with 'Net::GitHub::V1::Role';

=head1 DESCRIPTION

=head1 ATTRIBUTES

=over 4

=item login

=item password

=item token

=back

=head1 METHODS

=over 4

=item ua

instance of L<WWW::Mechanize>

=item json

instance of L<JSON::Any>

=item get

=item submit_form

handled by L<WWW::Mechanize>

=item signin

login through L<https://github.com/login> by $self->ua

return 1 if success

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
