#!/usr/bin/env perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Net::GitHub::V3;
use Data::Dumper;

my $gh = Net::GitHub::V3->new();
my $search = $gh->search;

my %data = $search->repositories('perl');
map { print $_->{url} . "\n" } @{$data{items}};

while ($search->has_next_page) {
    sleep 12; # 5 queries max per minute
    %data = $search->next_page;
    map { print $_->{url} . "\n" } @{$data{items}};
}

1;