#!perl -T

use Test::More tests => 7;

use_ok( 'Net::GitHub::V2' );
use_ok( 'Net::GitHub::V2::Repositories' );
use_ok( 'Net::GitHub::V2::Users' );
use_ok( 'Net::GitHub::V2::Commits' );
use_ok( 'Net::GitHub::V2::Issues' );
use_ok( 'Net::GitHub::V2::Object' );
use_ok( 'Net::GitHub::V2::Network' );

1;