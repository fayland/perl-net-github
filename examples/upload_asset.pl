#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Net::GitHub::V3;
use Data::Dumper;

die unless ( ($ENV{GITHUB_USER} and $ENV{GITHUB_PASS}) or $ENV{GITHUB_ACCESS_TOKEN} );

# either user+pass or token
my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
# my $gh = Net::GitHub->new( access_token => $ENV{GITHUB_ACCESS_TOKEN});
my $repos = $gh->repos;

$repos->set_default_user_repo('fayland', 'perl-net-github');

my @releases = $repos->releases();
my $release = @releases ? $releases[0] : '';
unless ($release) {
    $release = $repos->create_release({
        "tag_name" => "test_upload",
        "target_commitish" => "master",
        "name" => "test_upload",
        "body" => "test upload release",
    });
}

print Dumper(\$release);

my $rand = rand();
my $asset = $repos->upload_asset($release->{id}, "$rand.txt", 'text/plain', scalar(localtime()));

print Dumper(\$asset);

1;