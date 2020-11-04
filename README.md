[![Build Status](https://travis-ci.org/fayland/perl-net-github.svg?branch=master)](https://travis-ci.org/fayland/perl-net-github)

# NAME

Net::GitHub - Perl Interface for github.com

# SYNOPSIS

```perl
use Net::GitHub;

my $github = Net::GitHub->new(  # Net::GitHub::V3
    login => 'fayland', pass => 'secret'
);

# If you use two factor authentication you can pass in the OTP. Do
# note that OTPs expire quickly and you will need to generate an oauth
# token to do anything non-trivial.
my $github = Net::GitHub->new(
    login =>   'fayland',
    pass =>    'secret',
    otp =>     '123456',
);

# Pass api_url for GitHub Enterprise installations. Do not include a
# trailing slash
my $github = Net::GitHub->new(  # Net::GitHub::V3
    login =>   'fayland',
    pass =>    'secret',
    api_url => 'https://gits.aresweet.com/api/v3'
);

# Suggested:
# First use OAuth to create a token with user/pass. Then do:
my $github = Net::GitHub->new(  # Net::GitHub::V3
    access_token => $token
);

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
```

# DESCRIPTION

[http://github.com](http://github.com) is a popular git host.

This distribution provides easy methods to access GitHub via their APIs.

Check [http://developer.github.com/](http://developer.github.com/) for more details of the GitHub APIs.

Read [Net::GitHub::V3](https://metacpan.org/pod/Net::GitHub::V3) for API usage.

Read [Net::GitHub::V4](https://metacpan.org/pod/Net::GitHub::V4) for GitHub GraphQL API.

If you prefer object oriented way, [Pithub](https://metacpan.org/pod/Pithub) is 'There is more than one way to do it'.

## FAQ

- create access\_token for Non-Web Application

    ```perl
    my $gh = Net::GitHub::V3->new( login => 'fayland', pass => 'secret' );
    my $oauth = $gh->oauth;
    my $o = $oauth->create_authorization( {
        scopes => ['user', 'public_repo', 'repo', 'gist'], # just ['public_repo']
        note   => 'test purpose',
    } );
    print $o->{token};
    ```

    after create the token, you can use it without your password publicly written

    ```perl
    my $github = Net::GitHub->new(
        access_token => $token, # from above
    );
    ```

# Git

[http://github.com/fayland/perl-net-github/](http://github.com/fayland/perl-net-github/)

# SEE ALSO

[Pithub](https://metacpan.org/pod/Pithub)

# AUTHOR

Fayland Lam, `<fayland at gmail.com>`

Everyone who is listed in **Changes**.

# COPYRIGHT & LICENSE

Copyright 2009-2012 Fayland Lam all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
