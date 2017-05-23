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
query {
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

# $data = $gh->query(<<IQL);
# mutation AddCommentToIssue {
#   addComment(input:{subjectId:"MDU6SXNzdWUyMzA0ODQ2Mjg=", body:"A shiny new comment! :tada:"}) {
#     commentEdge {
#       cursor
#     }
#     subject {
#       id
#     }
#     timelineEdge {
#       cursor
#     }
#   }
# }
# IQL
# diag Dumper(\$data);

$data = $gh->query(<<'IQL', { number_of_repos => 3 });
query($number_of_repos:Int!) {
  viewer {
    name
     repositories(last: $number_of_repos) {
       nodes {
         name
       }
     }
   }
}
IQL
diag Dumper(\$data);

done_testing;
