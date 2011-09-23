#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

BAIL_OUT('Please export environment variable GITHUB_USER/GITHUB_PASS') unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $repos = $gh->repos;

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok( $gh );
ok( $repos );

my @p = $repos->list;
ok(@p > 3, 'more than 3 repos');

done_testing;

1;