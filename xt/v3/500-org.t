#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

BAIL_OUT('Please export environment variable GITHUB_USER/GITHUB_PASS') unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $org = $gh->org;

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok( $gh );
ok( $org );

my $o = $org->org('perlchina'); # PerlChina
ok($o);
is($o->{'billing_email'}, 'perlchina@googlegroups.com');

$o = $org->update_org('perlchina', { name => 'PerlChina' });
ok($o);
is($o->{name}, 'PerlChina');

done_testing;

1;