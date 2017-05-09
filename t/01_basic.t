use strict;
use warnings;
use utf8;

use Test::Time::HiRes;
use Test::More;

use Time::HiRes qw/sleep usleep nanosleep clock_nanosleep time gettimeofday clock_gettime CLOCK_REALTIME/;

subtest 'should sleep and get time successfully' => sub {
    my $origin = time;

    my $sec = 123.456;
    is sleep($sec), $sec;

    my $usec = 123;
    is usleep($usec), $usec;

    my $nanosec = 456;
    is nanosleep($nanosec), $nanosec;
    is clock_nanosleep(CLOCK_REALTIME, $nanosec), $nanosec;

    my $expected = $origin + 123.456 + 123 * 1e-6 + 456 * 1e-9 + 456 * 1e-9;
    is time, $expected, 'time';
    is clock_gettime, $expected, 'clock_gettime';
};

subtest 'should gettimeofday successfully' => sub {
    my $origin = time;

    is gettimeofday, $origin, 'scalar context';

    my @sec_and_decimal = gettimeofday;
    my $sec = sprintf '%d', time;
    my $dec = sprintf('%.6g', time - $sec) * 1e6;
    is_deeply \@sec_and_decimal, [$sec, $dec], 'array context';
};

done_testing;

