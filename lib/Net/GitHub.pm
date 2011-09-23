package Net::GitHub;

use Any::Moose;

our $VERSION = '0.40_01';
our $AUTHORITY = 'cpan:FAYLAND';

sub new {
    my $class = shift;
    my $params = $class->BUILDARGS(@_);

    my $obj;
    if ( exists $params->{version} and $params->{version} == 2 ) {
        require Net::GitHub::V2;
        return Net::GitHub::V2->new($params);
    } else {
        require Net::GitHub::V3;
        return Net::GitHub::V3->new($params);
    }

    #return $class->meta->new_object( __INSTANCE__ => $obj, @_,);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
__END__

=head1 NAME

Net::GitHub - Perl Interface for github.com

=head1 SYNOPSIS

    use Net::GitHub;

    my $github = Net::GitHub->new(); # default to Net::GitHub::V3

    # for backwards
    my $github = Net::GitHub->new(  # Net::GitHub::V2
        version => 2,
        owner => 'fayland', name => 'perl-net-github'
    );

=head1 DESCRIPTION

L<http://github.com> is a popular git host.

This distribution provides easy methods to access GitHub via their APIs.

Check L<http://developer.github.com/> for more details of the GitHub APIs.

Read L<Net::GitHub::V3> for API usage.

If you prefer object oriented way, L<Pithub> is 'There is more than one way to do it'.

=head1 Git

L<http://github.com/fayland/perl-net-github/>

=head1 SEE ALSO

L<Any::Moose>, L<Pithub>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

Everyone who is listed in B<Changes>.

=head1 COPYRIGHT & LICENSE

Copyright 2009-2011 Fayland Lam all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
