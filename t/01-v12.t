#!perl -T

use Test::More tests => 2;

use Net::GitHub;

my $v2 = Net::GitHub->new(
    version => 2, # optional, default as 2
    owner => 'fayland', repo => 'perl-net-github'
);

diag( $v2->api_url );
ok(1);
#ok( $v2->can('repos') );

my $v1 = Net::GitHub->new(
    version =>1, # optional, default as 2
    owner => 'fayland', repo => 'perl-net-github'
);

diag( $v1->api_url );
ok(1);
#ok( $v1->can('search') );
