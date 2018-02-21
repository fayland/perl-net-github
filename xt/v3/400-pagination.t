#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

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


# More pagination...
# -- Submodule Net::GitHub::V3::Events
my $event = $gh->event;

# ---- Public events
my $next_event = $event->next_event;
is(ref $next_event,'HASH');
$event->close_event;

# ---- Events for a repository
my $next_repos_event = $event->next_repos_event;
is(ref $next_repos_event,'HASH');
is($next_repos_event->{repo}{name},'fayland/perl-net-github');
$event->close_repos_event;

# ---- Just checking whether the functions are correctly defined
foreach my $function (qw(repos_event issues_event networks_event
                     orgs_event
                     user_received_event user_public_received_event
                     user_event user_public_event
                     user_orgs_event
                )) {
    foreach my $action (qw(next close)) {
        my $method = "${action}_${function}";
        ok($event->can($method),"Events::$method is defined");
    }
}


# -- Submodule Net::GitHub::V3::Gists
my $gist = $gh->gist;
foreach my $function (qw(gist
                         public_gist starred_gist
                         comment
                    )) {
    foreach my $action (qw(next close)) {
        my $method = "${action}_${function}";
        ok($gist->can($method),"Gists::$method is defined");
    }
}

is(scalar keys %{$gist->result_sets}, 0, 'All result sets are closed');


# -- Submodule Net::GitHub::V3::Orgs
my $org = $gh->org;
foreach my $function (qw(org
                         member owner_member no_2fa_member
                         public_member
                         outside_collaborator
                         team team_member team_maintainer team_repo
                    )) {
    foreach my $action (qw(next close)) {
        my $method = "${action}_${function}";
        ok($org->can($method),"Orgs::$method is defined");
    }
}
is(scalar keys %{$org->result_sets}, 0, 'All result sets are closed');


# -- Submodule Net::GitHub::V3::PullRequests
my $pull_request = $gh->pull_request;

# Find the PR which caused all this
my $first_pr = $pull_request->next_pull(
    { head => 'HaraldJoerg:auto-pagination'}
);
is($first_pr->{number},86,'PR identified');

# Find a particular commit message
my $message_found = 0;
while (my $commit = $pull_request->next_commit($first_pr->{number})) {
    next unless $commit->{commit}{message} =~ /^Initial patch/;
    $message_found = 1;
}
ok($message_found,'Iterating through commit messages');
$pull_request->close_commit($first_pr->{number});

my $second_pr = $pull_request->next_pull(
    { head => 'HaraldJoerg:auto-pagination'}
);
ok(! $second_pr,'Only one PR in this selection');
$pull_request->close_pull(
    { head => 'HaraldJoerg:auto-pagination'}
);

foreach my $function (qw(file
                         comment
                         reviewer
                    )) {
    foreach my $action (qw(next close)) {
        my $method = "${action}_${function}";
        ok($pull_request->can($method),"PullRequests::$method is defined");
    }
}
is(scalar keys %{$pull_request->result_sets}, 0, 'All result sets are closed');


# -- Submodule Net::GitHub::V3::Repos
my $repos = $gh->repos;

my $repo_found = 0;
# -- this has been disabled: It works, but takes many API requests.
# while (my $r = $repos->next_repo()) {
#     if ($r->{name}  eq  'perl-net-github') {
#         $repo_found = 1;
#         last;
#     }
# }
# ok($repo_found,"'perl-net-github' is listed under repos");
# $repos->close_repo;

$repo_found =  0;
while (my $r = $repos->next_user_repo('fayland')) {
    if ($r->{name}  eq  'perl-net-github') {
        $repo_found = 1;
        last;
    }
}
ok($repo_found,"'perl-net-github' is listed under fayland's repos");
$repos->close_user_repo('fayland');

# -- this has been disabled: I don't know a stable repository
#    associated with an organisation
# $repo_found = 0;
# while (my $r = $repos->next_org_repo('perlchina','public')) {
#     if ($r->{name}  eq  'perl-net-gitgub') {
#         $repo_found = 1;
#         last;
#     }
# }
# ok($repo_found,"'perl-net-github' is listed under perlchina's public repos");
# $repos->close_org_repo('perlchina','public');

# This should grab three fairly recent commits
my $selection = { since => '2018-01-01T00:00:00',
                  until => '2018-01-07T00:00:00',
                };
my @commits = ();
while (my $commit = $repos->next_commit($selection)) {
    push @commits,$commit;
}
is(scalar @commits,3,"Three commits on 05-06 Jan 2018");
$repos->close_commit($selection);

foreach my $function (qw(comment commit_comment
                         download
                         release release_asset
                         fork
                         deployment key
                         subscriber watcher
                         hook
                         status deployment_status
                    )) {
    foreach my $action (qw(next close)) {
        my $method = "${action}_${function}";
        ok($repos->can($method),"Repos::$method is defined");
    }
}
is(scalar keys %{$repos->result_sets}, 0, 'All result sets are closed');


# -- Submodule Net::GitHub::V3::Users
my $user = $gh->user;

foreach my $function (qw(follower following
                         email
                         key
                    )) {
    foreach my $action (qw(next close)) {
        my $method = "${action}_${function}";
        ok($user->can($method),"Users::$method is defined");
    }
}
is(scalar keys %{$user->result_sets}, 0, 'All result sets are closed');

done_testing;
