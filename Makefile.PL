use inc::Module::Install;

name     'Net-GitHub';
all_from 'lib/Net/GitHub.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

repository 'https://github.com/fayland/perl-net-github';

requires 'MIME::Base64';
requires 'URI';
requires 'URI::Escape';
requires 'Any::Moose';
requires 'Crypt::SSLeay';
requires 'WWW::Mechanize::GZip';
requires 'JSON::Any';
requires 'JSON::XS'; # avoid "Couldn't find a JSON package. Need XS, JSON, or DWIW"
requires 'HTML::TreeBuilder';
requires 'HTTP::Request::Common';

build_requires 'Test::More';
test_requires 'Test::MockModule';
test_requires 'File::Slurp';
tests('t/*.t t/*/*.t');

auto_install;

WriteAll;

