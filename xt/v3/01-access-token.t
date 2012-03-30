#!/usr/bin/env perl

use Test::More;
use Net::GitHub;

plan skip_all => 'Please export environment variable GITHUB_ACCESS_TOKEN' unless $ENV{GITHUB_ACCESS_TOKEN};

my $gh = Net::GitHub->new( access_token => $ENV{GITHUB_ACCESS_TOKEN});

diag( 'Using access_token = ' . $ENV{GITHUB_ACCESS_TOKEN} );

ok( $gh );
my $data = $gh->user->show();

ok( $data );
ok( $data->{id} );
ok( $data->{gravatar_id} );
ok( $data->{email} );
ok( $data->{login} );
ok( $data->{name} );

done_testing;

1;