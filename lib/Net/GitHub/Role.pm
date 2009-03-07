package Net::GitHub::Role;

use Moose::Role;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use WWW::Mechanize;

has 'username' => ( isa => 'Str', is => 'ro', required => 1 );
has 'project'  => ( isa => 'Str', is => 'ro', required => 1 );

has 'email' => ( isa => 'Str', is => 'rw' );
has 'password' => ( isa => 'Str', is => 'rw' );


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

no Moose::Role;

1;
__END__
