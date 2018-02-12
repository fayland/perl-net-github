#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;
use Net::GitHub::V3::Iterator;

# For this test we are using the repository of Net::GitHub itself.
# We filter for "all" states to make sure that the test doesn't fail
# if at some time there are not enough open issues!
# This test makes two API calls.

plan skip_all => 'Please export environment variable GITHUB_USER/GITHUB_PASS'
     unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER},
                               pass => $ENV{GITHUB_PASS});
diag( 'Using user = ' . $ENV{GITHUB_USER} );

$gh->set_default_user_repo('fayland', 'perl-net-github');
$gh->per_page(2);
my $issue = $gh->issue;

ok( $gh );
ok( $issue );
my $result;

# Testing the guts, checking result set internals to see whether a
# HTTP request has been performed

my $url   = '/repos/fayland/perl-net-github/issues?state=all';
$result = $issue->next($url);
ok($result);
is($issue->result_sets->{$url}->cursor,1,"First  result of first  page");
diag $result->{title};

$result = $issue->next($url);
ok($result);
is($issue->result_sets->{$url}->cursor,2,"Second result of first  page");
diag $result->{title};

$result = $issue->next($url);
ok($result);
is($issue->result_sets->{$url}->cursor,1,"First result of second page");
diag $result->{title};

$issue->close($url);

# Now testing with the "official" pagination interfaces.
# We use the *closed* issues of perl-net-github because they should be
# rather stable, keeping the tests valid.
#
# We iterate through the issues until we have a defined title, then
# through the comments for this issue until we have a defined author.

$issue->per_page(100); # Keep API usage back to normal

my $issue_found = '';
my $search_title = 'rate limit headers';
my $search_author = 'fayland';
my $search_body = "ty, new version uploaded. Thanks\n";

my $issue_count = 0;
ISSUE:
while ( my $closed_issue =  $issue->next_repos_issue({state => 'closed'}) ) {
    if ($closed_issue->{title} ne $search_title) {
        $issue_count++;
        next ISSUE;
    }
    $issue_found = $issue_count;
    pass("Issue '$search_title' found after $issue_found iterations");
    my $issue_number = $closed_issue->{number};

    my $comment_found = 0;
  COMMENT:
    while ( my $comment = $issue->next_comment($issue_number) ) {
        next COMMENT unless $comment->{user}{login} eq $search_author;
        $comment_found = 1;
        is($comment->{body},$search_body);
    }
    $issue->close_comment($issue_number);
    ok($comment_found,"Comment by '$search_author' found");

    my $event_found = 0;
  EVENT:
    while ( my $event = $issue->next_event($issue_number) ) {
        next EVENT unless $event->{event} eq 'closed';
        $event_found = 1;
        is($event->{actor}{login},$search_author,
           "'$search_author' closed this issue");
    }
    ok($event_found);
    $issue->close_event($issue_number);
    last ISSUE;
}

if (! $issue_found) {
    fail("Issue not found, no tests for comments, events etc.");
}

$issue->close_repos_issue({state => 'closed'});

done_testing;
