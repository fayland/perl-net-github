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

my %data = $search->issues('fayland', 'perl-net-github', 'closed', 'milestone');
diag Dumper(\$data{issues});

#%data = $search->repos('perl-net-github');
#diag Dumper(\$data{repositories});

#%data = $search->user('fayland');
#diag Dumper(\$data{users});

%data = $search->email('fayland@gmail.com');
diag Dumper(\$data{user});


done_testing;

1;