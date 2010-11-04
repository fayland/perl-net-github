#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 4;
use Net::GitHub::V1;

my $github = Net::GitHub::V1->new();
isa_ok($github->project(owner => 'fayland', name => 'perl-net-github'), 'Net::GitHub::V1::Project');
isa_ok($github->user(username => 'fayland'), 'Net::GitHub::V1::User');
ok( $github->does('Net::GitHub::V1::Role') );
ok( $github->can('search') );

1;
