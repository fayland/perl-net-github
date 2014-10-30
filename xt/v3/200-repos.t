#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

my $gh = Net::GitHub::V3->new;
my $repos = $gh->repos;

ok( $gh );
ok( $repos );

my @p = $repos->list_user('fayland');
cmp_ok(@p, ">", 3, 'more than 3 repos');

my $rp = $repos->get('fayland', 'perl-net-github');
is $rp->{name},         "perl-net-github";
is $rp->{owner}{login}, "fayland" or diag explain $rp;


=pod

$repos->set_default_user_repo('fayland', 'perl-net-github');
my @commits = $repos->commits({
    author => 'jibsheet'
});
use Data::Dumper;
print Dumper(\@commits);

=cut

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
