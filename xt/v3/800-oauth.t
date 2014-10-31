#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

plan skip_all => 'Please export environment variable GITHUB_USER/GITHUB_PASS'
     unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $oauth = $gh->oauth;

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok($oauth);

my $o = $oauth->create_authorization( {
    scopes => ['user', 'public_repo', 'repo', 'gist'],
    note   => 'test purpose',
} );
ok $o->{id};
is_deeply $o->{scopes}, ['user', 'public_repo', 'repo', 'gist'];
is $o->{note}, "test purpose";

my $auth = $oauth->authorization($o->{id});
is $auth->{id}, $o->{id};

$oauth->delete_authorization($o->{id});
ok !$oauth->authorization($o->{id});

done_testing;
