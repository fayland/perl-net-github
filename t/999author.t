#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

BEGIN {
    plan skip_all => "Author tests" unless $ENV{TEST_NET_GITHUB};
    plan tests => 1;
};

use Net::GitHub::Project::Wiki;
use Data::Dumper;

my $github = Net::GitHub::Project::Wiki->new(
    owner => 'fayland',
    name  => 'perl-net-github',
    login => 'fayland',
    password => $ENV{TEST_NET_GITHUB_PASS}
);

new_page

ok 1;

1;