#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 4;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;

use Net::GitHub::User;

# mock data
my $filec1 = "$Bin/mockdata/user.json";
my $c1 = read_file($filec1);

my $mock = Test::MockModule->new('Net::GitHub::User');
$mock->mock( 'get', sub {
	( undef, my $url ) = @_;
	if ( $url eq 'http://github.com/api/v1/json/fayland' ) {
		return $c1;
	}
} );

my $user = Net::GitHub::User->new( username => 'fayland' );
is $user->full_name, "Fayland Lam";
is $user->blog, "http://www.fayland.org/";
is $user->location, "China";
is $user->repositories->[0]->{url}, 'http://github.com/fayland/fayland';

1;