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

use utf8;
use Encode;

my $x = $gh->repos->create({
    name => "Foo-Bar-Baz",
    description => encode_utf8("Testing ünicode descriptions"),
});
print Dumper(\$x);

1;