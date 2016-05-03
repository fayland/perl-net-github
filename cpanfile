requires 'MIME::Base64';
requires 'URI';
requires 'URI::Escape';
requires 'Moo';
requires 'Types::Standard';
requires 'JSON::MaybeXS';
requires 'Cache::LRU';
# requires 'JSON::XS'; # avoid "Couldn't find a JSON package. Need XS, JSON, or DWIW"
requires 'LWP::UserAgent';
requires 'HTTP::Request';
requires 'LWP::Protocol::https';

test_requires 'Test::More';