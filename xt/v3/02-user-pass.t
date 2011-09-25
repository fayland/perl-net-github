#!/usr/bin/env perl

use Test::More;
use Net::GitHub::V3;

plan skip_all => 'Please export environment variable GITHUB_USER/GITHUB_PASS'
     unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok( $gh );
my $data = $gh->user->show();

ok( $data );
ok( $data->{id} );
ok( $data->{gravatar_id} );
ok( $data->{email} );
ok( $data->{login} );
ok( $data->{name} );

done_testing;

1;