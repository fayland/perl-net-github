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

my $st = $wiki->edit_or_new('TestPage2', "FROM 999author.t\n\n\nLine 2\n\n LLLL 3");
diag("return $st");

ok 1;

1;
