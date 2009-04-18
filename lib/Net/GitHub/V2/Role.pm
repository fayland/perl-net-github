package Net::GitHub::V2::Role;

use Moose::Role;

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:FAYLAND';

use JSON::Any;
use WWW::Mechanize::GZip;
use Carp qw/croak/;

# repo stuff
has 'owner' => ( isa => 'Str', is => 'ro', required => 1 );
has 'repo'  => ( isa => 'Str', is => 'ro', required => 1 );

# login
has 'login'  => ( is => 'rw', isa => 'Str', default => '' );
has 'token' => ( is => 'rw', isa => 'Str', default => '' );

# api
has 'api_url' => ( is => 'ro', default => 'http://github.com/api/v2/json/');

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
    croak $resp->as_string() unless ( $resp->is_success );
    return $resp->content();
}

has 'json' => (
    is => 'ro',
    isa => 'JSON::Any',
    lazy => 1,
    default => sub {
        return JSON::Any->new;
    }
);

sub get_json_to_obj {
    my ( $self, $pending_url, $key ) = @_;
    
    my $url  = $self->api_url . $pending_url;
    my $json = $self->get($url);
    my $data = $self->json->jsonToObj($json);
    
    return $data->{$key} if ( $key and exists $data->{$key} );
    return $data;
}

sub get_json_to_obj_authed {
    my $self = shift;
    my $pending_url = shift;
    
    croak 'login and token are required' unless ( $self->login and $self->token );
    
    my $url  = $self->api_url . $pending_url;
    
    my $key; # return $key from json obj
    if ( scalar @_ % 2 ) {
        $key = pop @_;
    }
    
    require HTTP::Request::Common;
    my $res = $self->ua->request(
        HTTP::Request::Common::POST( $url, [
            'login' => $self->login,
            'token' => $self->token,
            @_,
        ] ),
    );
    croak $res->as_string() unless ( $res->is_success );
    
    my $json = $res->content();
    my $data = $self->json->jsonToObj($json);
    
    return $data->{$key} if ( $key and exists $data->{$key} );
    return $data;
}

sub args_to_pass {
    my $self = shift;
    my $ret;
    foreach my $col ('owner', 'repo' ) {
        $ret->{$col} = $self->$col;
    }
    return $ret;
}

no Moose::Role;

1;
__END__

=head1 NAME

Net::GitHub::V2::Role - Common between Net::GitHub::V2::* libs

=head1 SYNOPSIS

    package Net::GitHub::V2::XXX;
    
    use Moose;
    with 'Net::GitHub::V2::Role';

=head1 DESCRIPTION

=head1 ATTRIBUTES

=over 4

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

handled by L<WWW::Mechanize>

=item get_json_to_obj

=item get_json_to_obj_authed

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
