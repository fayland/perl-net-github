#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V4;

plan skip_all => 'Please export environment variable GITHUB_ACCESS_TOKEN' unless $ENV{GITHUB_ACCESS_TOKEN};

my $gh = Net::GitHub::V4->new(
    access_token => $ENV{GITHUB_ACCESS_TOKEN}
);
my $data = $gh->query(<<IQL);
{
  repository(owner: "octocat", name: "Hello-World") {
    pullRequests(last: 10) {
      edges {
        node {
          number
          mergeable
        }
      }
    }
  }
}
IQL

use Data::Dumper;
diag Dumper(\$data);

ok($data->{data}->{repository}->{pullRequests});

done_testing;
