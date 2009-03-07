package Net::GitHub::Role;

use Moose::Role;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use WWW::Mechanize;
use Carp qw/croak/;

# http://github.com/fayland/perl-net-github/tree/master
has 'owner' => ( isa => 'Str', is => 'rw' );
has 'project'  => ( isa => 'Str', is => 'rw' );

# login
has 'email' => ( isa => 'Str', is => 'rw' );
has 'password' => ( isa => 'Str', is => 'rw' );

sub args_to_pass {
    my $self = shift;
    my $ret;
    foreach my $col ('owner', 'project', 'email', 'password' ) {
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
