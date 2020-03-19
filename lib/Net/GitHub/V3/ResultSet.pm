package Net::GitHub::V3::ResultSet;

our $VERSION = '0.98';
our $AUTHORITY = 'cpan:FAYLAND';

use Types::Standard qw(Int Str ArrayRef Bool);
use Moo;

has 'url'      => ( is => 'rw', isa => Str,      required => 1);
has 'results'  => ( is => 'rw', isa => ArrayRef, default => sub { [] } );
has 'cursor'   => ( is => 'rw', isa => Int,      default => 0 );
has 'done'     => ( is => 'rw', isa => Bool,     default => 0 );
has 'next_url' => ( is => 'rw', isa => Str );

no Moo;

1;
__END__

=head1 NAME

Net::GitHub::V3::ResultSet - GitHub query iteration helper

=head1 SYNOPSIS

For use by the role L<Net::GitHub::V3::Query>:

    use Net::GitHub::V3::ResultSet;

    $result_set = Net::GitHub::V3::ResultSet->new( url => $url );
    ...

=head1 DESCRIPTION

Objects in this class store the current status of a GitHub query while
the user iterates over individual items.  This happens behind the
scenes, users of Net::GitHub::V3 don't need to know about this class.

Each of the V3 submodules holds one of these objects for every
different pageable query which it handles.

The attributes have the following function:

=over 4

=item url

Required for creating the object: This is the URL where a pageable
GitHub query starts, and this URL will be used to identify the
pagination when retrieving the next object, and also for the first
call to the GitHub API.

=item results

An array reference holding the current page as retrieved by the most
recent call to the GitHub API.

=item cursor

An integer pointing to the "next" position within the current page
from which the next method will fetch an item.

=item done

A boolean indicating that there's no more item to be fetched from the
API: The current results are the last.

=item next_url

The url from which more results can be fetched.  Will be empty if
there are no more pages.

=back

=cut

