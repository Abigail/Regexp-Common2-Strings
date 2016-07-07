#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use feature  'signatures';
no  warnings 'experimental::signatures';

use Test::More 0.88;
use Test::Regexp;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common2::Strings;
use Regexp::Common2 qw [RE];

sub mk_test ($delims) {
    my $pat   = RE 'string::delimited' => -delimeters => $delims;
    my $pat_k = RE 'string::delimited' => -delimeters => $delims, -Keep => 1;

    my $test  = Test::Regexp:: -> new -> init (
                    pattern      => $pat,
                    keep_pattern => $pat_k,
                    name         => "string::delimited, " .
                                    "-delimiters => '$delims'",
    );

    return $test;
}

foreach my $delim (qw [! , -], "\n") {
    my $test = mk_test $delim;

    $test -> match ("${delim}${delim}",
                    [[delimited  => "${delim}${delim}"],
                     [odelimiter => "${delim}"],
                     [string     => ""],
                     [cdelimiter => "${delim}"]],
                    test => "Empty string");

    $test -> match ("${delim}Lorem ipsum dolor sit amet${delim}",
                    [[delimited  => "${delim}Lorem ipsum dolor " .
                                    "sit amet${delim}"],
                     [odelimiter => "${delim}"],
                     [string     => "Lorem ipsum dolor sit amet"],
                     [cdelimiter => "${delim}"]],
                    test => "Regular string");

    if ($delim ne "\n") {
        $test -> match ("${delim}Lorem\nipsum\ndolor\nsit\namet${delim}",
                    [[delimited  => "${delim}Lorem\nipsum\ndolor\n" .
                                    "sit\namet${delim}"],
                     [odelimiter => "${delim}"],
                     [string     => "Lorem\nipsum\ndolor\nsit\namet"],
                     [cdelimiter => "${delim}"]],
                    test => "String with newlines");
    }

    $test -> match ("${delim}Lorem \\${delim} ipsum${delim}",
                    [[delimited  => "${delim}Lorem \\${delim} ipsum${delim}"],
                     [odelimiter =>  $delim],
                     [string     => "Lorem \\${delim} ipsum"],
                     [cdelimiter =>  $delim]],
                    test => "Escaped delimiter");

    $test -> match ("${delim}Lorem ipsum\\\\${delim}",
                    [[delimited  => "${delim}Lorem ipsum\\\\${delim}"],
                     [odelimiter =>  $delim],
                     [string     => "Lorem ipsum\\\\"],
                     [cdelimiter =>  $delim]],
                    test => "Escaped escape before delimiter");

    $test -> no_match ("${delim}",
                       reason => "Only a delimiter");
    $test -> no_match ("${delim}Lorem ipsum",
                       reason => "No closing delimiter");
    $test -> no_match ("Lorem ipsum${delim}",
                       reason => "No opening delimiter");
    $test -> no_match ("${delim}Lorem ${delim} ipsum${delim}",
                       reason => "Delimiter inside string");
    $test -> no_match ("${delim}Lorem ipsum\\${delim}",
                       reason => "Closing delimiter is escaped");
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
