#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Net::GitHub::V3;

plan skip_all => 'Please export environment variable GITHUB_USER/GITHUB_PASS'
     unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $user = $gh->user;

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok( $gh );
ok( $user );

SKIP: {
    skip 'Resource not accessible by integration', 4 if $ENV{AUTOMATED_TESTING};

    # Remember the original value of bio
    my $ou = $user->show();
    my $obio = $ou->{bio};

    diag( 'Updating ..' );
    my $bio = 'Testing Net::GitHub - please come back in a minute';
    my $uu = $user->update( bio => $bio );
    is($uu->{bio}, $bio);

    sleep 1;
    my $u = $user->show();
    is($u->{bio}, $bio);
    delete $u->{updated_at}; delete $uu->{updated_at};
    is_deeply($u, $uu);

    # Restore bio
    my $ru = $user->update( bio => $obio );
    is($ru->{bio},$obio,"Value of user's Bio restored");

}

=pod

diag("Testing follow/unfollow");
my $f = 'c9s';
my $is_following = $user->is_following($f);
if ($is_following) {
    diag("unfollow then follow");
    my $ok = $user->unfollow($f);
    ok($ok);
    $ok = $user->follow($f);
    ok($ok);

    my $following = $user->following;
    ok( (grep { $_->{login} eq $f } @$following ) );
} else {
    diag("follow then unfollow");
    my $ok = $user->follow($f);
    ok($ok);

    my $following = $user->following;
    ok( (grep { $_->{login} eq $f } @$following ) );

    $ok = $user->unfollow($f);
    ok($ok);
}

=cut

done_testing;
