# Locale::Po4a::ColobotLevels -- Convert Colobot levels
#
# This program is free software; you may redistribute it and/or modify it
# under the terms of GPLv3.
#

use Locale::Po4a::TransTractor qw(process new);
use Locale::Po4a::Common;

package Locale::Po4a::Colobotlevel;

use 5.006;
use strict;
use warnings;

require Exporter;

use vars qw(@ISA @EXPORT $AUTOLOAD);
@ISA = qw(Locale::Po4a::TransTractor);
@EXPORT = qw();

my $debug=0;

sub initialize {}


sub parse {
    my $self=shift;
    my ($line,$line_source);
    my $language_char;

    LINE:
    ($line,$line_source)=$self->shiftline();

    while (defined($line)) {
        chomp($line);

        if ($line =~ /^(Title|Resume|ScriptName)/) {
            # Text before the first dot
            $line =~ m/(^[^"\r\n]*)\./;
            my $type = $1;

            # One char just after the .
            $line =~ m/\.(.)/;
            my $E = $1;
            if (not $language_char) {
                # Take this one-char only once
                $language_char = $self->translate($E, '', 'One-char language identifier');
            }

            # The text between .E and first quote
            $line =~ m/\.$E([^\r\n"]*?)(text|resume)="([^\r\n"]*?)"([^\r\n"]*)((text|resume)="([^\r\n"]*?)"([^\r\n"]*))?$/;
            my $spacing_1 = $1;
            my $subtype_1 = $2;
            my $quoted_1  = $3;
            my $spacing_2 = $4;
            my $secondpart = $5;
            my $subtype_2 = $6;
            my $quoted_2  = $7;
            my $spacing_3 = $8;

            my $code;

            # levels/<category>/chapterXXX/chaptertitle.txt
            if ($line_source =~ m#^.*/levels/([^/]*)/chapter([0-9]{3})/chaptertitle\.txt.*$#) {
                $code = $1.".".$2; # e.g. challenges.001
            }
            # levels/<category>/chapterXXX/levelYYY/scene.txt
            elsif ($line_source =~ m#^.*/levels/[^/]*/chapter([0-9]{3})/level([0-9]{3})/scene\.txt.*$#) {
                $code = $1.".".$2.".".$3; # e.g. challenges.001.002
            }
            # fallback case
            else {
                $line_source =~ m#^.*/([^/]*)$#;
                $code = $1;
            }

            my $par_1 = $self->translate($code.":".$quoted_1, $line_source, $type."-".$subtype_1);
            $par_1 =~ s/^\D*\d*://;
            if ($secondpart) {
                my $par_2 = $self->translate($code.":".$quoted_2, $line_source, $type."-".$subtype_2);
                $par_2 =~ s/^\D*\d*://;

                # This is awkward, but works
                $spacing_2 = $spacing_2.$subtype_2.'="'.$par_2.'"'.$spacing_3;
            }
            $par_1 =~ s/\n/\\n/g;
            $spacing_2 =~ s/\n/\\n/g;

            # Now push the result
            $self->pushline($type.'.'.$language_char.$spacing_1.$subtype_1.'="'.$par_1.'"'.$spacing_2."\n");
        }
        else {
            $self->pushline("$line\n");
        }
        # Reinit the loop
        ($line,$line_source)=$self->shiftline();
    }
}

1;
__END__
