package Net::GitHub::Project::Creator;

use Moose;

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::Role';

# check http://github.com/blog/170-token-authentication


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::Project::Creator - GitHub project Creator

=head1 SYNOPSIS

    use Net::GitHub::Project::Creator;

    my $src = Net::GitHub::Project::Creator->new(
        
    );

=head1 DESCRIPTION

if username and token is provided, we try something like L<http://github.com/blog/170-token-authentication>

or else, we try something like L<Git::Github::Creator>

=head1 METHODS

=over 4

=back

=head1 SEE ALSO

L<Git::Github::Creator>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.