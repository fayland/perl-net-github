package Net::GitHub;

use Any::Moose;

our $VERSION = '0.46';
our $AUTHORITY = 'cpan:FAYLAND';

sub new {
    my $class = shift;
    my $params = $class->BUILDARGS(@_);

    my $obj;
    if ( exists $params->{version} and $params->{version} == 2 ) {
        warn "Github will terminate API v1 and API v2 in 1 month on May 1st, 2012\n";
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

    # default to v3
    my $github = Net::GitHub->new(  # Net::GitHub::V3
        login => 'fayland', pass => 'secret'
    );

    #Pass api_url for GitHub Enterprise installations
    my $github = Net::GitHub->new(  # Net::GitHub::V3
        login => 'fayland', pass => 'secret',  api_url => 'https://gits.aresweet.com/api/v3'
    );


    # suggested
    # use OAuth to create token with user/pass
    my $github = Net::GitHub->new(  # Net::GitHub::V3
        access_token => $token
    );

    # for backwards, NOTE: Github will terminate API v1 and API v2 in 1 month on May 1st, 2012
    my $github = Net::GitHub->new(
        version => 2,
        owner => 'fayland', name => 'perl-net-github'
    );

    # for V3
    # L<Net::GitHub::V3::Users>
    my $user = $github->user->show('nothingmuch');
    $github->user->update( bio => 'Just Another Perl Programmer' );

    # L<Net::GitHub::V3::Repos>
    my @repos = $github->repos->list;
    my $rp = $github->repos->create( {
        "name" => "Hello-World",
        "description" => "This is your first repo",
        "homepage" => "https://github.com"
    } );

=head1 DESCRIPTION

L<http://github.com> is a popular git host.

This distribution provides easy methods to access GitHub via their APIs.

Check L<http://developer.github.com/> for more details of the GitHub APIs.

Read L<Net::GitHub::V3> for API usage.

If you prefer object oriented way, L<Pithub> is 'There is more than one way to do it'.

=head2 FAQ

=over 4

=item * create access_token for Non-Web Application

    my $gh = Net::GitHub::V3->new( login => 'fayland', pass => 'secret' );
    my $oauth = $gh->oauth;
    my $o = $oauth->create_authorization( {
        scopes => ['user', 'public_repo', 'repo', 'gist'], # just ['public_repo']
        note   => 'test purpose',
    } );
    print $o->{token};

after create the token, you can use it without your password publicly written

    my $github = Net::GitHub->new(
        access_token => $token, # from above
    );

=back

=head1 Git

L<http://github.com/fayland/perl-net-github/>

=head1 SEE ALSO

L<Any::Moose>, L<Pithub>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

Everyone who is listed in B<Changes>.

=head1 COPYRIGHT & LICENSE

Copyright 2009-2012 Fayland Lam all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
