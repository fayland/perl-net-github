use strict;
use warnings;

use Test::More tests => 2;
use FindBin qw/$Bin/;
use Net::GitHub::V2::Issues;
use Test::MockModule;
use File::Slurp;

my $issue = Net::GitHub::V2::Issues->new(
    owner => 'fayland',
    repo  => 'perl-net-github'
);

my $has_comments = "$Bin/mockdata/70-issues-comments.html";
my $no_comments  = "$Bin/mockdata/70-issues-comments_zero.html";

my $mock = Test::MockModule->new('Net::GitHub::V2::Issues');
$mock->mock(
    'get',
    sub {
        my ( $self, $url ) = @_;
        return read_file($has_comments) if $url =~ /1$/;
        return read_file($no_comments)  if $url =~ /2$/;
    }
);

my $comments = $issue->comments(1);

is_deeply(
    $comments,
    [
        {
            id      => 15860,
            author  => 'sunnavy',
            date    => '2009/06/07 01:25:22 -0700',
            content => '1st comment',
        },
        {
            id      => 16373,
            author  => 'sunnavy',
            date    => '2009/06/08 18:28:42 -0700',
            content => '2nd comment',
        }
    ],
    '2 comments'
);

$comments = $issue->comments(2);
is_deeply( $comments, [], '0 comments' );
