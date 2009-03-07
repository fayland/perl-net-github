#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 3;
use Net::GitHub;

my $github = Net::GitHub->new( owner => 'fayland', name => 'perl-net-github' );
isa_ok($github->project, 'Net::GitHub::Project');
ok( $github->does('Net::GitHub::Role') );
ok( $github->can('search') );

1;