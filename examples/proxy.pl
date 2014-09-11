#!/usr/bin/env perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Net::GitHub::V3;
use Data::Dumper;

my $gh = Net::GitHub::V3->new();
my $search = $gh->search;
$gh->ua->proxy('https', 'socks://127.0.0.1:9050');

my %data = $search->repositories({
    q => 'perl',
    per_page => 100,
});
map { print $_->{url} . "\n" } @{$data{items}};

1;