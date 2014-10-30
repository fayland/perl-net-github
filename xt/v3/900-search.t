#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;
use Data::Dumper;

my $gh = Net::GitHub::V3->new();
my $search = $gh->search;

ok( $gh );
ok( $search );

my %issues = $search->issues({
    q => 'state:closed repo:fayland/perl-net-github',
});

cmp_ok $issues{total_count}, ">", 10;

my $items = $issues{items};
for my $item (@$items) {
    ok $item->{id};
    is $item->{state}, "closed";
    ok $item->{closed_at};
}

done_testing;

1;
