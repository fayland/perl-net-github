#!perl -T

use Test::More tests => 6;

use Net::GitHub;

my $v2 = Net::GitHub->new(
    version => 2, # optional, default as 2
    owner => 'fayland', repo => 'perl-net-github'
);
ok( $v2->can('repos') );
ok( ! $v2->can('search') );
is $v2->api_url, 'http://github.com/api/v2/json/';

my $v1 = Net::GitHub->new(
    version => 1,
    owner => 'fayland', name => 'perl-net-github'
);

ok( $v1->can('search') );
ok( ! $v1->can('repos') );
is $v1->api_url, 'http://github.com/api/v1/json/';
