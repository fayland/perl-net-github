#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

plan skip_all => 'Please export environment variable GITHUB_USER/GITHUB_PASS'
     unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $gist = $gh->gist;

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok($gist);

my $g = $gist->create( {
      "description" => "the description for this gist",
      "public" => \1,
      "files"  =>  {
        "file1.txt" => {
            "content" => "String file contents"
        }
      }
    } );
ok $g->{id};
ok $g->{public};
is $g->{description}, "the description for this gist";
is $g->{files}{"file1.txt"}{content}, "String file contents";

done_testing;

1;
