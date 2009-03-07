#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

BEGIN {
    plan skip_all => "Author tests" unless $ENV{TEST_NET_GITHUB};
    plan tests => 1;
};

use Net::GitHub;

my $github = Net::GitHub->new( owner => 'fayland', name => 'perl-net-github', debug => 1 );

ok 1;

1;