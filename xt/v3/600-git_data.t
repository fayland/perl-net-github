#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

plan skip_all => 'Please export environment variable GITHUB_USER/GITHUB_PASS'
     unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $git_data = $gh->git_data;

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok( $gh );
ok( $git_data );

$git_data->set_default_user_repo('fayland', 'perl-net-github');
my $blob = $git_data->blob('5a1faac3ad54da26be60970ddbbdfbf6b08fdc57');
ok($blob);

my $commit = $git_data->commit('5a1faac3ad54da26be60970ddbbdfbf6b08fdc57');
ok($commit);

done_testing;

1;