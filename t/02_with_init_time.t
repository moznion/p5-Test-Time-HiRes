use strict;
use warnings;
use utf8;

use Test::Time::HiRes time => 0;
use Test::More;

use Time::HiRes qw/sleep time/;

subtest 'should work with init time' => sub {
    sleep 123;
    is time, 123;
};

done_testing;

