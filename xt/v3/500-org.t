#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

plan skip_all => 'Please export environment variable GITHUB_USER/GITHUB_PASS'
     unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $org = $gh->org;

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok( $gh );
ok( $org );

=pod

my $o = $org->org('perlchina'); # PerlChina
ok($o);
is($o->{'billing_email'}, 'perlchina@googlegroups.com');

$o = $org->update_org('perlchina', { name => 'PerlChina' });
ok($o);
is($o->{name}, 'PerlChina');

=cut

my $is_member = $org->is_member('perlchina', 'fayland');
is($is_member, 1);
$is_member = $org->is_member('perlchina', 'nothingmuch');
is($is_member, 0);

done_testing;

1;