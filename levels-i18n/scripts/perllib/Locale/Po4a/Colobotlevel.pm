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
    my ($line,$ref);
    my $parE;

    LINE:
    ($line,$ref)=$self->shiftline();

    while (defined($line)) {
        chomp($line);

        if ($line =~ /^(Title|Resume|ScriptName)/) {
            # Text before the first dot
            $line =~ m/(^[^"\r\n]*)\./;
            my $type = $1;

            # One char just after the .
            $line =~ m/\.(.)/;
            my $E = $1;
            if( not $parE ) {
                # Take this one-char only once
                $parE = $self->translate($E, '', 'One-char language identifier');
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
            $ref =~ m#^(.*)/(.*)\.txt.*$#;
            my $code;
            if( $2 eq 'scene' ) {
                $code = $1;
            } else {
                $code = $2;
            }
            my $par_1 = $self->translate($code.":".$quoted_1, $ref, $type."-".$subtype_1);
            $par_1 =~ s/^\D*\d*://;
            if( $secondpart ) {
                my $par_2 = $self->translate($code.":".$quoted_2, $ref, $type."-".$subtype_2);
                $par_2 =~ s/^\D*\d*://;

                # This is awkward, but works
                $spacing_2 = $spacing_2.$subtype_2.'="'.$par_2.'"'.$spacing_3;
            }
            $par_1 =~ s/\n/\\n/g;
            $spacing_2 =~ s/\n/\\n/g;

            # Now push the result
            $self->pushline($type.'.'.$parE.$spacing_1.$subtype_1.'="'.$par_1.'"'.$spacing_2."\n");
        }
        else
        {
            $self->pushline("$line\n");
        }
        # Reinit the loop
        ($line,$ref)=$self->shiftline();
    }
}

1;
__END__
