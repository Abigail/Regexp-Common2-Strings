#!/usr/bin/perl

use 5.006;

use strict;
use warnings;
no  warnings 'syntax';

use ExtUtils::MakeMaker;

my  $PACKAGE      =  'Regexp::Common2::Strings';

my  $LIB_FILE     =  "lib/$PACKAGE.pm";
    $LIB_FILE     =~  s!::!/!g;
my  $LOCAL_ADDR   =  'cpan';
my  $DOMAIN       =  'abigail.be';
my  $REPO         =   $PACKAGE;
    $REPO         =~  s!::!-!g;
my  $REPO_HOST    =  'github.com';
my  $ME           =  'Abigail';
my  $REPOSITORY   =  "git://$REPO_HOST/$ME/$REPO.git";

my  @tests        = qw [t/*.t];

my %args = (
    NAME                 =>  $PACKAGE,
    VERSION_FROM         =>  $LIB_FILE,
    ABSTRACT_FROM        =>  $LIB_FILE,
    PREREQ_PM            => {
        'strict'             =>  0,
        'warnings'           =>  0,
    },
    MIN_PERL_VERSION     =>   5.020,
    AUTHOR               =>  "$ME <$LOCAL_ADDR\@$DOMAIN>",
    LICENSE              =>  'mit',
    META_MERGE           => {
       "meta-spec"       => {version => 2},
        prereqs          => {
            configure        => {
                requires         => {
                    'ExtUtils::MakeMaker'   =>  0,
                    'strict'                =>  0,
                    'warnings'              =>  0,
                },
            },
            runtime          => {
                requires         => {
                    'strict'                =>  0,
                    'warnings'              =>  0,
                    'Regexp::Common2'       =>  0,
                },
            },
            test             => {
                requires         => {
                    'strict'                =>  0,
                    'warnings'              =>  0,
                    'Regexp::Common2'       =>  0,
                    'Test::More'            =>  0.88,
                    'Test::Regexp'          =>  0,
                },
                recommends   => {
                    'Test::NoWarnings'      =>  0,
                },
            },
        },
        resources        => {
            repository   => $REPOSITORY,
        },
        keywords         => [qw [ ]],
    },
    test                 => {
        TESTS                => $^O eq 'MSWin32'
                                ? "@{[map {glob} @tests]}" : "@tests"
    },
);


my %filter = (
    MIN_PERL_VERSION     => '6.48',
    LICENSE              => '6.48',
    META_MERGE           => '6.46',
    AUTHOR               => '6.07',
    ABSTRACT_FROM        => '6.07',
);

delete $args {$_} for grep {defined $filter {$_} &&
                            $ExtUtils::MakeMaker::VERSION lt $filter {$_}}
                            keys %args;


WriteMakefile %args;

__END__
