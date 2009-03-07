use inc::Module::Install;

name     'Net-GitHub';
all_from 'lib/Net/GitHub.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

require 'Data::Dumper';
require 'Moose' => '0.57';
require 'Crypt::SSLeay';
require 'LWP::Simple';
require 'WWW::Mechanize';
require 'JSON::Any';
require 'HTML::TokeParser::Simple';

build_requires 'Test::More';
test_requires 'Test::MockModule';
test_requires 'File::Slurp';

auto_install;

WriteAll;

