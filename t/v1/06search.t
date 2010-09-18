#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 3;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;

use Net::GitHub::V1::Search;

# mock data
my $filec1 = "$Bin/mockdata/search.json";
my $c1 = read_file($filec1);

my $mock = Test::MockModule->new('Net::GitHub::V1::Search');
$mock->mock( 'get', sub {
    ( undef, my $url ) = @_;
    if ( $url eq 'http://github.com/api/v1/json/search/fayland' ) {
        return $c1;
    }
} );

my $search = Net::GitHub::V1::Search->new();
my $ret = $search->search('fayland');
is $ret->{repositories}->[0]->{name}, "fayland";
is $ret->{repositories}->[0]->{username}, "fayland";
is $ret->{repositories}->[0]->{created}, "2008-08-29T03:56:39Z";

1;
