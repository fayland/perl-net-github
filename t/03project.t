#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 2;
use Net::GitHub::Project;

my $prj = Net::GitHub::Project->new( owner => 'fayland', name => 'perl-net-github' );
is $prj->public_clone_url, 'git://github.com/fayland/perl-net-github.git';
is $prj->your_clone_url, 'git@github.com:fayland/perl-net-github.git';

1;