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

my %data = $search->issues({
    q => 'state:open repo:fayland/perl-net-github',
});
diag Dumper(\$data{items});

#%data = $search->repositories('perl-net-github');
#diag Dumper(\$data{items});

#%data = $search->users('fayland');
#diag Dumper(\$data{items});

done_testing;

1;