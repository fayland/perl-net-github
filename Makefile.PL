use inc::Module::Install;

name     'Net-GitHub';
all_from 'lib/Net/GitHub.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

repository 'http://github.com/fayland/perl-net-github/tree/master';

requires 'MIME::Base64';
requires 'URI::Escape';
requires 'Any::Moose';
requires 'Crypt::SSLeay';
requires 'WWW::Mechanize::GZip';
requires 'JSON::Any';
requires 'HTML::TreeBuilder';

build_requires 'Test::More';
test_requires 'Test::MockModule';
test_requires 'File::Slurp';
tests('t/*.t t/*/*.t');

auto_install;

WriteAll;

