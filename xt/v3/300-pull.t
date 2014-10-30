#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

plan skip_all => 'Please export environment variable GITHUB_USER/GITHUB_PASS'
     unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $pull = $gh->pull_request;

ok( $gh );
ok( $pull );

$pull->set_default_user_repo('fayland', 'perl-net-github');

my @closed_pull_requests = $pull->pulls({ state => 'closed' });
for my $request (@closed_pull_requests) {
    is $request->{state}, "closed";
    ok $request->{closed_at};
    is $request->{base}{repo}{name},         "perl-net-github";
    is $request->{base}{repo}{owner}{login}, "fayland";
}

done_testing;
