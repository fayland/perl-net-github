#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Net::GitHub;
use Data::Dumper;

my $github = Net::GitHub->new(
    owner => $ENV{github_login}, repo => 'perl-net-github',
    login => $ENV{github_login}, token => $ENV{github_token}
);

my $organization = $github->organization;
my $o;



# get 'github' organization info
$o = $organization->organizations('PerlChina');
print Dumper(\$o);

=pod

# update org
$o = $organization->update('PerlChina', blog => 'http://planet.perlchina.org/', location => 'China');
print Dumper(\$o);

$o = $organization->organizations; # my organizations
print Dumper(\$o);

# get user user_organizations
$o = $organization->user_organizations('technoweenie');
print Dumper(\$o);

$o = $organization->public_repositories('github');
print Dumper(\$o);

$o = $organization->public_members('github');
print Dumper(\$o);

$o = $organization->teams('PerlChina');
print Dumper(\$o);

$o = $organization->create_team('PerlChina',
    name => 'fayland',
    permission => 'admin',
    repo_names => ['PerlChina/sandbox']
);
print Dumper(\$o);

$o = $organization->team(30544);
print Dumper(\$o);

$o = $organization->update_team(30544,
    name => 'test',
    permission => 'push',
    repo_names => ['PerlChina/sandbox']
);
print Dumper(\$o);

$o = $organization->add_team_member(30544, 'fayland');
print Dumper(\$o);

$o = $organization->team_members(30544);
print Dumper(\$o);

$o = $organization->remove_team_member(30544, 'fayland');
print Dumper(\$o);

$o = $organization->add_team_repositories(30544, 'PerlChina/sandbox');
print Dumper(\$o);

$o = $organization->team_repositories(30544);
print Dumper(\$o);

$o = $organization->remove_team_repositories(30544, 'PerlChina/sandbox');
print Dumper(\$o);

=cut

1;