#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 4;
use Net::GitHub;

my $github = Net::GitHub->new();
isa_ok($github->project(owner => 'fayland', name => 'perl-net-github'), 'Net::GitHub::Project');
isa_ok($github->user(username => 'fayland'), 'Net::GitHub::User');
ok( $github->does('Net::GitHub::Role') );
ok( $github->can('search') );

1;