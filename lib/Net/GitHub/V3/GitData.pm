package Net::GitHub::V3::GitData;

use Any::Moose;

our $VERSION = '0.40';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

## build methods on fly
my %__methods = (
    
);
__build_methods(__PACKAGE__, %__methods);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V3::GitData - GitHub Git DB API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $user = $gh->git_data;

=head1 DESCRIPTION

=head2 METHODS

=head3 Orgs

L<http://developer.github.com/v3/git/>

=over 4

=item 

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>