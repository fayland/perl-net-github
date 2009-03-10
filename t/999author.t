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

my $wiki = Net::GitHub::Project::Wiki->new(
    owner => 'fayland',
    name  => 'perl-net-github',
    login => 'fayland',
    password => $ENV{TEST_NET_GITHUB_PASS}
);

$wiki->new_page('Test2', 'FROM 999author.t');

ok 1;

1;
