#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common2::Strings;
use Regexp::Common2 qw [RE];


my $pat   = RE 'string::delimited', -esc => "!;>";
my $pat_k = RE 'string::delimited', -esc => "!;>",  -Keep => 1;

my $test  = Test::Regexp:: -> new -> init (
                pattern      => $pat,
                keep_pattern => $pat_k,
                name         => "string::delimited, -esc => '!;>'",
);

foreach my $delim (q {"}, q {'}, q {`}) {
    my $type = $delim eq q {"} ? "double quoted"
             : $delim eq q {'} ? "single quoted"
             :                   "backtick quoted";
    my $esc  = $delim eq q {"} ? "!"
             : $delim eq q {'} ? ";"
             :                   ">";

    $test -> match (qq {${delim}foo${delim}},
                    [[delimited  => qq {${delim}foo${delim}}],
                     [odelimiter => $delim],
                     [string     => qq {foo}],
                     [cdelimiter => $delim]],
                    test => "Simple $type string");

    $test -> match (qq {${delim}${delim}},
                    [[delimited  => qq {${delim}${delim}}],
                     [odelimiter => $delim],
                     [string     => qq {}],
                     [cdelimiter => $delim]],
                    test => "Empty $type string");

    $test -> match (qq {${delim} ${delim}},
                    [[delimited  => qq {${delim} ${delim}}],
                     [odelimiter => $delim],
                     [string     => qq { }],
                     [cdelimiter => $delim]],
                    test => "\u$type string with white space");

    $test -> match (qq {${delim}one\ntwo${delim}},
                    [[delimited  => qq {${delim}one\ntwo${delim}}],
                     [odelimiter => $delim],
                     [string     => qq {one\ntwo}],
                     [cdelimiter => $delim]],
                    test => "\u$type string with newline");

    $test -> match (qq {${delim}A\x{E1}${delim}},
                    [[delimited  => qq {${delim}A\x{E1}${delim}}],
                     [odelimiter => $delim],
                     [string     => qq {A\x{E1}}],
                     [cdelimiter => $delim]],
                    test => "\u$type string with Latin-1 char");

    #
    # Test escapes
    #

    $test -> match (qq {${delim}foo${esc} bar${delim}},
                    [[delimited  => qq {${delim}foo${esc} bar${delim}}],
                     [odelimiter => $delim],
                     [string     => qq {foo${esc} bar}],
                     [cdelimiter => $delim]],
                    test => "\u$type string with an escape");

    $test -> match (qq {${delim}${esc}${esc}${delim}},
                    [[delimited  => qq {${delim}${esc}${esc}${delim}}],
                     [odelimiter => $delim],
                     [string     => qq {${esc}${esc}}],
                     [cdelimiter => $delim]],
                    test => "\u$type string with only an escaped escape");

    $test -> match (qq {${delim}Escape the ${esc}${delim}. ${delim}},
                    [[delimited  => qq {${delim}Escape the ${esc}${delim}. } .
                                    qq {${delim}}],
                     [odelimiter => $delim],
                     [string     => qq {Escape the ${esc}${delim}. }],
                     [cdelimiter => $delim]],
                    test => "\u$type string with an escaped delimiter");


    #
    # Failures
    #

    $test -> no_match (qq {${delim}Some text},
                       reason => "No closing delimiter for $type string");
    $test -> no_match (qq {Some text${delim}},
                       reason => "No opening delimiter for $type string");
    $test -> no_match (qq {${delim}Some${delim}text${delim}},
                       reason => "Unescaped delimiter in string");
    $test -> no_match (qq {${delim}Some text${delim}?},
                       reason => "Garbage after closing delimiter");
    $test -> no_match (qq { ${delim}Some text${delim}},
                       reason => "Garbage before opening delimiter");
    $test -> no_match (qq {${delim}Some text ${esc}${delim}},
                       reason => "Closing delimiter was escaped");

    my $other_delimiter = $delim eq q {"} ? q {'} : q {"};
    $test -> no_match (qq {${delim}Some text${other_delimiter}},
                       reason => "Mismatched delimiters");

    my $other_esc       = $delim eq q {"} ? q {>} : q {!};
    $test -> no_match (qq {${delim}Escape the ${other_esc}${delim}. ${delim}},
                       reason => "Using an incorrect escape character");
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
