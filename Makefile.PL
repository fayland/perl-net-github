use inc::Module::Install;

name     'Net-GitHub';
all_from 'lib/Net/GitHub.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

require 'Moose';
require 'WWW::Mechanize';

build_requires 'Test::More';

auto_install;

WriteAll;

