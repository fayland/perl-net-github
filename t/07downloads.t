#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 4;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;

use Net::GitHub::Project::Downloads;

# mock data
my $filec1 = "$Bin/mockdata/downloads.html";
my $c1 = read_file($filec1);

my $mock = Test::MockModule->new('Net::GitHub::Project::Downloads');
$mock->mock( 'get', sub {
	( undef, my $url ) = @_;
	if ( $url eq 'http://github.com/fayland/perl-net-github/downloads' ) {
		return $c1;
	}
} );

my $dl = Net::GitHub::Project::Downloads->new( owner => 'fayland', name => 'perl-net-github' );
my @downloads = $dl->downloads;
is scalar @downloads, 2;
is $downloads[0]->{url}, 'http://cloud.github.com/downloads/fayland/perl-net-github/Net-GitHub-0.03.tar.gz';
is $downloads[1]->{date}, '2009-03-07';
is $downloads[1]->{size}, '25KB';

1;