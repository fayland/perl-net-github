package Net::GitHub::V2::PullRequest;

use Any::Moose;

our $VERSION = '0.20';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::V2::HasRepo';

sub pull_request {
    my ( $self, %params ) = @_;

    my $owner = $self->owner;
    my $repo  = $self->repo;

    $params{base} ||= 'master';
    $params{head} ||= $self->login . ':master';
    unless (exists $params{issue}) {
        $params{title} ||= '';
        $params{body}  ||= '';
    }

    %params = map { ("pull[$_]" => $params{$_}) }
                  grep { /^(?:base|head|title|body|issue)$/ }
                       keys %params;

    return $self->get_json_to_obj_authed( "pulls/$owner/$repo", %params, 'pull' );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
=head1 NAME

Net::GitHub::V2::PullRequest - GitHub Pull Request API

=head1 SYNOPSIS

    use Net::GitHub::V2::PullRequest;

    my $pulls = Net::GitHub::V2::PullRequest->new(
        owner => 'fayland', repo => 'perl-net-github'
    );

=head1 DESCRIPTION

L<http://develop.github.com/p/pulls.html>

For those B<(authentication required)> below, you must set login and token (in L<https://github.com/account>

    my $pulls = Net::GitHub::V2::PullRequest->new(
        owner => 'fayland', repo => 'perl-net-github',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
    );

=head1 METHODS

=over 4

=item pull_request

    my $pull = $pulls->pull_request(
        base  => 'master',
        head  => 'someone:master',
        title => 'fix',
        body  => 'fix this bug',
    );

Create a pull request (authentication required). The request will be made on
C<< <owner>/<base> >> to pull in changes in C<head>. C<base> defaults to
C<master>, and C<head> defaults to C<< <login>:master >>.

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

Jesse Luehrs C<doy at tozt dot net>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
