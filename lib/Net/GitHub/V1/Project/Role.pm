package Net::GitHub::V1::Project::Role;

use Moose::Role;

our $VERSION = '0.04';
our $AUTHORITY = 'cpan:FAYLAND';

# http://github.com/fayland/perl-net-github/tree/master
has 'owner' => ( isa => 'Str', is => 'rw', required => 1 );
has 'name'  => ( isa => 'Str', is => 'rw', required => 1 );

# url
has 'project_url' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        return 'http://github.com/' . $self->owner . '/' . $self->name . '/';
    },
);
has 'project_api_url' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        return 'http://github.com/api/v1/json/' . $self->owner . '/' . $self->name . '/';
    },
);

sub args_to_pass {
    my $self = shift;
    my $ret;
    foreach my $col ('owner', 'name' ) {
        $ret->{$col} = $self->$col;
    }
    return $ret;
}

no Moose::Role;

1;
__END__

=head1 NAME

Net::GitHub::V1::Project::Role - Common between Net::GitHub::V1::Project::* libs

=head1 SYNOPSIS

    package Net::GitHub::V1::Project::XXX;
    
    use Moose;
    with 'Net::GitHub::V1::Project::Role';

=head1 DESCRIPTION

=head1 ATTRIBUTES

=over 4

=item owner

'fayland' of http://github.com/fayland/perl-net-github/tree/master

=item name

'perl-net-github' of http://github.com/fayland/perl-net-github/tree/master

=item project_url

like I<http://github.com/fayland/perl-net-github/>

=item project_api_url

like I<http://github.com/api/v1/json/fayland/perl-net-github/>

=back

=head1 METHODS

=over 4

=item args_to_pass

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.