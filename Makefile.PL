use inc::Module::Install;

name     'Net-GitHub';
all_from 'lib/Net/GitHub.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

repository 'https://github.com/fayland/perl-net-github';

requires 'MIME::Base64';
requires 'URI';
requires 'URI::Escape';
requires 'Moo';
requires 'Types::Standard';
requires 'JSON::MaybeXS';
# requires 'JSON::XS'; # avoid "Couldn't find a JSON package. Need XS, JSON, or DWIW"
#
requires 'LWP::UserAgent';
requires 'HTTP::Request';
requires 'LWP::Protocol::https';

test_requires 'Test::More';
tests('t/*.t t/*/*.t');

auto_install;

WriteAll;

