#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

plan skip_all => 'Please export environment variable GITHUB_USER/GITHUB_PASS'
     unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $repos = $gh->repos;

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok( $gh );
ok( $repos );

my @p = $repos->list;
ok(@p > 3, 'more than 3 repos');

=pod

$repos->set_default_user_repo('fayland', 'perl-net-github');
my $hook = $repos->create_hook( {
  "name" => "web",
  "active" => 'true',
  "config" => {
    "url" => "http://something.com/webhook"
  }
} );
use Data::Dumper;
diag(Dumper(\$hook));
my @hooks = $repos->hooks;
is(@hooks, 1);
my $st = $repos->delete_hook($hook->{id});
is($st, 1);

=cut

done_testing;

1;