package Regexp::Common2::Strings;

use 5.20.0;
use strict;
use warnings;
no  warnings 'syntax';

use feature  'signatures';
no  warnings 'experimental::signatures';

our $VERSION = '2016070501';

use Regexp::Common2 qw [pattern];

my %styles = (
    quoted   =>   [q {"'`}, undef, q {\\}],
    m4       =>   [q {`},   q {'}, undef],
);

sub make_delimited (%args) {
    my @patterns;

    my @todo;

    if (defined $args {-style}) {
        foreach my $style (split /,\s*/ => $args {-style}) {
            if (my $triplet = $styles {$style}) {
                push @todo => $triplet;
            }
            else {
                require Carp;
                my $name = $args {-Name};
                Carp::carp ("Ignoring unknown style '-style' when " .
                            "constructing a $name pattern");
            }
        }
    }

    #
    # If the -style parameter doesn't work out, use the other parameters,
    # including the defaults.
    #
    unless (@todo) {
        my $delimiters    = $args {-delimeters};
        my $esc           = $args {-esc}         // "";
        my $cdelimiters   = $args {-cdelimiters} // "";
        push @todo => [$delimiters, $cdelimiters, $esc];
    }

    foreach my $triplet (@todo) {
        my ($delimiters, $cdelimiters, $esc) = @$triplet;

        $cdelimiters      = $delimiters unless length $delimiters;

        my $l_delimiters  = length $delimiters;
        my $l_esc         = length $esc;
        my $l_cdelimiters = length $cdelimiters;

        #
        # Normalize length
        #
        if ($l_esc && $l_esc < $l_delimiters) {
            $esc .= substr ($esc, -1) x ($l_delimiters - $l_esc);
            $l_esc = $l_delimiters;
        }
        if (!$l_cdelimiters) {
            $cdelimiters = $delimiters;
            $l_cdelimiters = $l_delimiters;
        }
        elsif ($l_cdelimiters < $l_delimiters) {
            $cdelimiters .= substr ($cdelimiters, -1) x
                                   ($l_delimiters - $l_cdelimiters);
            $l_cdelimiters = $l_delimiters;
        }

        foreach my $index (0 .. ($l_delimiters - 1)) {
            my $o = quotemeta substr   ($delimiters, $index, 1);
            my $c = quotemeta substr  ($cdelimiters, $index, 1);
            my $e = $l_esc ? quotemeta substr ($esc, $index, 1) : "";

            if ($e eq "") {
                #
                # Not escaped
                #
                push @patterns =>
                     "(?k<odelimiter>:$o)[^$c]*(?k<cdelimiter>:$c)";
            }
            elsif ($e eq $c) {
                ...
            }
            else {
                push @patterns =>
                     "(?k<odelimiter>:$o)"                        .
                     "(?k<string>:[^$e$c]*(?:$e(?s:.)[^$e$o]*)*)" .
                     "(?k<cdelimiter>:$c)";
            }
        }
    }
    local $" = "|";
    "(?k<delimited>:(?|@patterns))";
}

pattern "string::delimited",
        -config  => {
            -delimeters  => q {"'`},
            -esc         => q {\\},
            -cdelimiters => undef,
            -style       => undef,
        },
        -pattern => \&make_delimited,
;


1;

__END__

=head1 NAME

Regexp::Common2::Strings - Abstract

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

=head1 TODO

=head1 SEE ALSO

=head1 DEVELOPMENT

The current sources of this module are found on github,
L<< git://github.com/Abigail/Regexp-Common2-Strings.git >>.

=head1 AUTHOR

Abigail, L<< mailto:cpan@abigail.be >>.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2016 by Abigail.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),   
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=head1 INSTALLATION

To install this module, run, after unpacking the tar-ball, the 
following commands:

   perl Makefile.PL
   make
   make test
   make install

=cut
