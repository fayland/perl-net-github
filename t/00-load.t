#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Net::GitHub' );
}

diag( "Testing Net::GitHub $Net::GitHub::VERSION, Perl $], $^X" );
