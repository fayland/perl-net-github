#!perl -T

use Test::More tests => 2;

use Net::GitHub;

my $v2 = Net::GitHub->new(
    version => 2, # optional, default as 2
    owner => 'fayland', repo => 'perl-net-github'
);
ok( $v2->can('repos') );

my $v1 = Net::GitHub->new(
    version => 1,
    owner => 'fayland', name => 'perl-net-github'
);

ok( $v1->can('search') );
