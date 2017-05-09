package Test::Time::HiRes;

use 5.008001;
use strict;
use warnings;
no warnings qw/redefine/;

our $VERSION = '0.01';

use Time::HiRes ();
use Test::More;

my $is_active;
my $time = Time::HiRes::time;

sub is_active {
    return $is_active;
}

sub import {
    my ($class, %opts) = @_;

    activate();

    my $init_time = $opts{time};
    if (defined $init_time) {
        $time = $init_time;
    }

    my $orig_sleep = \&Time::HiRes::sleep;
    *Time::HiRes::sleep = sub (;@) {
        if ($is_active) {
            my $sec = shift || 0;
            note "Sleep $sec sec";
            $time += $sec;
            return $sec;
        }

        return $orig_sleep->(@_);
    };

    my $orig_usleep = \&Time::HiRes::usleep;
    *Time::HiRes::usleep = sub ($) {
        if ($is_active) {
            my $usec = shift || 0;
            note "Sleep $usec usec";
            $time += $usec * 1e-6;
            return $usec;
        }

        return $orig_usleep->(@_);
    };

    my $orig_nanosleep = \&Time::HiRes::nanosleep;
    *Time::HiRes::nanosleep = sub ($) {
        if ($is_active) {
            my $nanosec = shift || 0;
            note "Sleep $nanosec nanosec";
            $time += $nanosec * 1e-9;
            return $nanosec;
        }

        return $orig_nanosleep->(@_);
    };

    my $orig_clock_nanosleep = \&Time::HiRes::clock_nanosleep;
    *Time::HiRes::clock_nanosleep = sub ($$;$) {
        if ($is_active) {
            my ($which, $nanosec) = @_;
            $nanosec ||= 0;
            note "Sleep $nanosec clock nanosec";
            $time += $nanosec * 0.000000001;
            return $nanosec;
        }

        return $orig_clock_nanosleep->(@_);
    };

    my $orig_time = \&Time::HiRes::time;
    *Time::HiRes::time = sub () {
        if ($is_active) {
            return $time;
        }

        return $orig_time->();
    };

    my $orig_gettimeofday = \&Time::HiRes::gettimeofday;
    *Time::HiRes::gettimeofday = sub () {
        if ($is_active) {
            if (wantarray) {
                my $sec = sprintf '%d', $time;
                my $dec = sprintf '%.6g', $time - $sec;
                return ($sec, $dec * 1000000);
            }

            return $time;
        }

        return $orig_gettimeofday->();
    };

    my $orig_clock_gettime = \&Time::HiRes::clock_gettime;
    *Time::HiRes::clock_gettime = sub (;$) {
        if ($is_active) {
            return $time;
        }

        return $orig_clock_gettime->(@_);
    };
}

sub unimport {
    deactivate();
}

sub activate {
    $is_active = 1;
}

sub deactivate {
    $is_active = 0;
}

1;

__END__

=encoding utf-8

=head1 NAME

Test::Time::HiRes - It's new $module

=head1 SYNOPSIS

    use Test::Time::HiRes;

=head1 DESCRIPTION

Test::Time::HiRes is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

