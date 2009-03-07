use inc::Module::Install;

name     'Net-GitHub';
all_from 'lib/Net/GitHub.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

require 'Moose' => '0.57';
require 'Crypt::SSLeay';
require 'WWW::Mechanize';
require 'HTML::TokeParser::Simple';

build_requires 'Test::More';
test_requires 'Test::MockModule';

auto_install;

WriteAll;

