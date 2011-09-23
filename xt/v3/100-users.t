#!/usr/bin/env perl

use Test::More;
use Net::GitHub::V3;

BAIL_OUT('Please export environment variable GITHUB_USER/GITHUB_PASS') unless $ENV{GITHUB_USER} and $ENV{GITHUB_PASS};

my $gh = Net::GitHub::V3->new( login => $ENV{GITHUB_USER}, pass => $ENV{GITHUB_PASS});
my $users = $gh->users;

diag( 'Using user = ' . $ENV{GITHUB_USER} );

ok( $gh );
ok( $users );

diag( 'Updating ..' );
my $bio = 'another Perl programmer and Father';
my $uu = $users->update( bio => $bio );
is($uu->{bio}, $bio);

sleep 1;
my $u = $users->show();
is($u->{bio}, $bio);
is_deeply($u, $uu);

diag("follow/unfollow");
my $f = 'c9s';
my $is_following = $user->is_following($f);
if ($is_following) {
    diag("unfollow then follow");
    my $following = $user->unfollow($f);
    ok( not (grep { $_->{login} eq $f } @$following }) );
    $following = $user->follow($f);
    ok( (grep { $_->{login} eq $f } @$following }) );
} else {
    diag("follow then unfollow");
    my $following = $user->follow($f);
    ok( (grep { $_->{login} eq $f } @$following }) );
    $following = $user->unfollow($f);
    ok( not (grep { $_->{login} eq $f } @$following }) );
}

done_testing;

1;