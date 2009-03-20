use inc::Module::Install;

name     'Net-GitHub';
all_from 'lib/Net/GitHub.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

repository 'http://github.com/fayland/perl-net-github/tree/master';

requires 'URI::Escape';
requires 'Moose' => '0.57';
requires 'Crypt::SSLeay';
requires 'WWW::Mechanize::GZip';
requires 'JSON::Any';
requires 'HTML::TreeBuilder';

build_requires 'Test::More';
test_requires 'Test::MockModule';
test_requires 'File::Slurp';

auto_install;

WriteAll;

