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


my $pat   = RE 'string::delimited', -esc => q {"'`};
my $pat_k = RE 'string::delimited', -esc => q {"'`},  -Keep => 1;

my $test  = Test::Regexp:: -> new -> init (
                pattern      => $pat,
                keep_pattern => $pat_k,
                name         => "string::delimited, close delimiter as escape",
);

foreach my $delim (q {"}, q {'}, q {`}) {
    my $type = $delim eq q {"} ? "double quoted"
             : $delim eq q {'} ? "single quoted"
             :                   "backtick quoted";

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
    # Test escapes (only doubling of closing delimiter allowed)
    #

    $test -> match (qq {${delim}foo ${delim}${delim} bar${delim}},
                    [[delimited  => qq {${delim}foo ${delim}${delim} } .
                                    qq {bar${delim}}],
                     [odelimiter => $delim],
                     [string     => qq {foo ${delim}${delim} bar}],
                     [cdelimiter => $delim]],
                    test => "\u$type string with an escape");

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
    $test -> no_match (qq {${delim}Some text ${delim}${delim}},
                       reason => "Closing delimiter was escaped");

}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
