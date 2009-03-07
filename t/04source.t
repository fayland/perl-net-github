#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 3;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;

use Net::GitHub::Project::Source;

# mock data
my $filec1 = "$Bin/mockdata/commits.json";
my $c1 = read_file($filec1);
my $filec2 = "$Bin/mockdata/single_commit.json";
my $c2 = read_file($filec2);

my $mock = Test::MockModule->new('Net::GitHub::Project::Source');
$mock->mock( 'get', sub {
	( undef, my $url ) = @_;
	if ( $url eq 'http://github.com/api/v1/json/fayland/perl-net-github/commits/master' ) {
		return $c1;
	} elsif ( $url eq 'http://github.com/api/v1/json/fayland/perl-net-github/commit/725d3f6e8094e533f768710ce96504f7e2b67420' ) {
	    return $c2;
	}
} );


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

my $commit = $src->commit('725d3f6e8094e533f768710ce96504f7e2b67420');
is_deeply $commit, {
   'tree' => '9cb5e1e5e5e37b472e9128bb5154666cdde9442e',
   'added' => [],
   'author' => {
                 'email' => 'fayland@gmail.com',
                 'name' => 'fayland'
               },
   'modified' => [
                   {
                     'filename' => 'Makefile.PL',
                     'diff' => "@@ -5,8 +5,10 @@ all_from 'lib/Net/GitHub.pm';\n author   'Fayland Lam <fayland\@gmail.com>';\n license  'perl';\n \n-require 'Moose';\n+require 'Moose' => '0.57';\n+require 'Crypt::SSLeay';\n require 'WWW::Mechanize';\n+require 'HTML::TokeParser::Simple';\n \n build_requires 'Test::More';\n ",
                   }
                 ],
   'message' => 'update ma',
   'committer' => {
                    'email' => 'fayland@gmail.com',
                    'name' => 'fayland'
                  },
   'removed' => [],
   'url' => 'http://github.com/fayland/perl-net-github/commit/725d3f6e8094e533f768710ce96504f7e2b67420',
   'committed_date' => '2009-03-06T19:58:31-08:00',
   'id' => '725d3f6e8094e533f768710ce96504f7e2b67420',
   'authored_date' => '2009-03-06T19:58:31-08:00',
   'parents' => [
                  {
                    'id' => '6cbc313c0af11ef73245e0569801c4151063cc5c'
                  }
                ]
};

1;