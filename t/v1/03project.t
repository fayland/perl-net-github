#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 14;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;

use Net::GitHub::V1::Project;

# mock data
my $filec1 = "$Bin/mockdata/user.json";
my $c1 = read_file($filec1);

my $mock = Test::MockModule->new('Net::GitHub::V1::User');
$mock->mock( 'get', sub {
	( undef, my $url ) = @_;
	if ( $url eq 'http://github.com/api/v1/json/fayland' ) {
		return $c1;
	}
} );

my $prj = Net::GitHub::V1::Project->new( owner => 'fayland', name => 'perl-net-github' );

# test Info
is $prj->public_clone_url, 'git://github.com/fayland/perl-net-github.git';
is $prj->your_clone_url, 'git@github.com:fayland/perl-net-github.git';
isa_ok( $prj->owner_user, 'Net::GitHub::V1::User' );
is $prj->info_from_owner_user->{url}, "http://github.com/fayland/perl-net-github";
is $prj->description, "Perl interface to GitHub";
is $prj->homepage, "http://search.cpan.org/dist/Net-GitHub/";

# test Source
my $prj2 = Net::GitHub::V1::Project->new( 'fayland', 'perl-net-github' );
ok( $prj2->can('commits') );
ok( $prj2->can('commit') );

# test downloads
ok( $prj2->can('downloads') );

# test Wiki
isa_ok( $prj->wiki, 'Net::GitHub::V1::Project::Wiki' );

# test Net::GitHub::V1::Project::Role
ok( $prj->does('Net::GitHub::V1::Role') );
ok( $prj->does('Net::GitHub::V1::Project::Role') );

is $prj->project_url, 'http://github.com/fayland/perl-net-github/';
is $prj->project_api_url, 'http://github.com/api/v1/json/fayland/perl-net-github/';

1;