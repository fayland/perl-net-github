#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

BEGIN {
    plan skip_all => "Author tests" unless $ENV{TEST_NET_GITHUB};
    plan tests => 1;
};

use Net::GitHub;
use Data::Dumper;

my $github = Net::GitHub->new( owner => 'fayland', name => 'perl-net-github', debug => 1 );

#my $c = $github->get('http://github.com/api/v1/json/fayland/perl-net-github/commit/725d3f6e8094e533f768710ce96504f7e2b67420');
#diag Dumper(\$c);

ok 1;

1;