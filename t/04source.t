#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 2;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;

use Net::GitHub::Project::Source;

# mock data
my $filec1 = "$Bin/mockdata/commits.json";
my $c1 = read_file($filec1);

my $mock = Test::MockModule->new('Net::GitHub::Role');
$mock->mock(
    'fetch',
    sub {
    	( undef, my $uri ) = @_;
    	if ( $uri eq 'http://github.com/api/v1/json/fayland/perl-net-github/commits/master' ) {
    		return $c1;
    	}
    }
);


my $src = Net::GitHub::Project::Source->new( owner => 'fayland', name => 'perl-net-github' );
is scalar @{$src->commits}, 13;
is_deeply $src->commits->[-6], {
    'committer' => {
                     'email' => 'fayland@gmail.com',
                     'name' => 'fayland'
                   },
    'tree' => '9cb5e1e5e5e37b472e9128bb5154666cdde9442e',
    'url' => 'http://github.com/fayland/perl-net-github/commit/725d3f6e8094e533f768710ce96504f7e2b67420',
    'committed_date' => '2009-03-06T19:58:31-08:00',
    'id' => '725d3f6e8094e533f768710ce96504f7e2b67420',
    'author' => {
                  'email' => 'fayland@gmail.com',
                  'name' => 'fayland'
                },
    'authored_date' => '2009-03-06T19:58:31-08:00',
    'parents' => [
                   {
                     'id' => '6cbc313c0af11ef73245e0569801c4151063cc5c'
                   }
                 ],
    'message' => 'update ma'
};

1;