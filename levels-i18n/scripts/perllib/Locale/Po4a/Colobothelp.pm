# Locale::Po4a::Colobothelp -- Convert Colobot help files
#
# This program is free software; you may redistribute it and/or modify it
# under the terms of GPLv3.
#

use Locale::Po4a::TransTractor qw(process new);
use Locale::Po4a::Common;
use Locale::Po4a::Text;

package Locale::Po4a::Colobothelp;

use 5.006;
use strict;
use warnings;

require Exporter;

use vars qw(@ISA @EXPORT $AUTOLOAD);
@ISA = qw(Locale::Po4a::TransTractor);
@EXPORT = qw();

my @comments = ();

sub initialize {}

sub parse {
    my $self = shift;
    my ($line,$ref);
    my $paragraph="";
    my $wrapped_mode = 1;
    my $s_mode = 0;
    my $expect_header = 1;
    my $end_of_paragraph = 0;
    ($line,$ref)=$self->shiftline();
    while (defined($line)) {
        chomp($line);
        $self->{ref}="$ref";
        ($paragraph,$wrapped_mode,$s_mode,$expect_header,$end_of_paragraph) = parse_colobothelp($self,$line,$ref,$paragraph,$wrapped_mode,$s_mode,$expect_header,$end_of_paragraph);
        if ($end_of_paragraph) {
            do_paragraph($self,offlink($paragraph),$wrapped_mode);
            $paragraph="";
            $wrapped_mode = 1;
            $end_of_paragraph = 0;
        }
        ($line,$ref)=$self->shiftline();
    }
    if (length $paragraph) {
        $paragraph =~ s/\n$//;
        do_paragraph($self,$paragraph,$wrapped_mode);
        $self->pushline("\n");
    }
}

sub parse_colobothelp {
    my ($self,$line,$ref,$paragraph,$wrapped_mode,$s_mode,$expect_header,$end_of_paragraph) = @_;

    if (($s_mode == 1) and ($line !~ /^\\s;/)) {
       # Process the end of \s; blocks
       $s_mode = 0;
       # substr removes the last superfluous \n
       my $s_block = onlink($self->translate(substr(offlink($paragraph),0,-1),$ref,"\\s; block (usually verbatim code)"));
       $s_block =~ s/(\n|^)/$1\\s;/g;
       $self->pushline($s_block."\n");
       $paragraph="";
       $wrapped_mode = 0;
    }

    if (    $line =~ /^\s*$/
         or $line =~ m/^\\[nctr];$/) {
        # Break paragraphs on lines containing only spaces or any of \n; \c; \t; \r; (alone)

        # Drop the latest EOL to avoid having it in the translation
        my $dropped_eol = ($paragraph =~ s/\n$//);
        do_paragraph($self,$paragraph,$wrapped_mode);
        $self->pushline("\n") if $dropped_eol; # Therefore only add it back if it was removed
        $paragraph="";
        $wrapped_mode = 0;
        $self->pushline($line."\n");
    } elsif ($line =~ s/^(\\s;)//) {
        # Lines starting with \s; are special (yellow-background, usually code-block)
        # Break paragraph before them
        if($s_mode == 0) {
            $s_mode = 1;
            my $dropped_eol = ($paragraph =~ s/\n$//);
            do_paragraph($self,$paragraph,$wrapped_mode);
            $self->pushline("\n") if $dropped_eol; # Therefore only add it back if it was removed
            $paragraph="";
            $wrapped_mode = 0;
        }
        $paragraph .= $line."\n";
    } elsif ($line =~ s/^(\\[bt];)//) {
        # Break paragraphs on \b; or \t; headers
        do_paragraph($self,$paragraph,$wrapped_mode);
        $paragraph="";
        $wrapped_mode = 1;

        $self->pushline($1.onlink($self->translate(offlink($line),$ref,"$1 header")."\n"));
    } elsif ($line =~ /^\\image (.*) (\d*) (\d*);$/) {
        # Discard lines with \image name lx ly; tags
        do_paragraph($self,$paragraph,$wrapped_mode);
        $paragraph="";
        $wrapped_mode = 1;

        $self->pushline("\\image ".$self->translate($1,$ref,'Image filename')." $2 $3;\n");
    } elsif (   $line =~ /^=+$/
             or $line =~ /^_+$/
             or $line =~ /^-+$/) {
        $wrapped_mode = 0;
        $paragraph .= $line."\n";
        do_paragraph($self,$paragraph,$wrapped_mode);
        $paragraph="";
        $wrapped_mode = 1;
    } elsif ($line =~ s/^(\s*)([0-9]\)|[o-])(\s*)//) {
        # Break paragraphs on lines starting with either number + parenthesis or any of o- + space
        do_paragraph($self,$paragraph,$wrapped_mode);
        $paragraph="";
        $wrapped_mode = 1;

        $self->pushline("$1$2$3".onlink($self->translate(offlink($line),$ref,"Bullet: '$2'")."\n"));
    } else {
        # All paragraphs are non-wrap paragraphs by default
        $wrapped_mode = 0;
        undef $self->{bullet};
        undef $self->{indent};
        $paragraph .= $line."\n";
    }
    return ($paragraph,$wrapped_mode,$s_mode,$expect_header,$end_of_paragraph);
}

sub offlink {
  my ($paragraph) = @_;
  # Replace \button $id; as pseudo xHTML <button $id/> tags
  $paragraph =~ s#\\(button|key) ([^;]*?);#<$1 $2/>#g;
  # Put \const;Code\norm; sequences into pseudo-HTML <format const> tags
  $paragraph =~ s#\\(const|type|token|key);([^\\;]*?)\\norm;#<format $1>$2</format>#g;
  # Transform CBot links \l;text\u target; into pseudo-HTML <a target>text</a>
  $paragraph =~ s#\\l;(.*?)\\u ([^;]*?);#<a $2>$1</a>#g;
  # Cleanup pseudo-html targets separated by \\ to have a single character |
  $paragraph =~ s#<a (.*?)\\(.*?)>#<a $1|$2>#g;
  # Replace remnants of \const; \type; \token or \norm; as pseudo xHTML <const/> tags
  $paragraph =~ s#\\(const|type|token|norm|key);#<$1/>#g;
  # Put \c;Code\n; sequences into pseudo-HTML <code> tags
  $paragraph =~ s#\\c;([^\\;]*?)\\n;#<code>$1</code>#g;
  # Replace remnants of \s; \c; \b; or \n; as pseudo xHTML <s/> tags
  $paragraph =~ s#\\([scbn]);#<$1/>#g;
  return ($paragraph);
}

sub onlink {
  my ($paragraph) = @_;
  # Invert the replace remnants of \s; \c; \b; or \n; as pseudo xHTML <s/> tagsyy
  $paragraph =~ s#<([scbn])/>#\\$1;#g;
  # Inverse the put of \c;Code\n; sequences into pseudo-HTML <code> tags
  $paragraph =~ s#<code>([^\\;]*?)</code>#\\c;$1\\n;#g;
  # Invert the replace remnants of \const; \type; \token or \norm; as pseudo xHTML <const/> tags
  $paragraph =~ s#<(const|type|token|norm|key)/>#\\$1;#g;
  # Inverse of the cleanup of pseudo-html targets separated by \\ to have a single character |
  $paragraph =~ s#<a (.*?)\|(.*?)>#<a $1\\$2>#g;
  # Inverse of the transform of CBot links \l;text\u target; into pseudo-HTML <a target>text</a>
  $paragraph =~ s#<a (.*?)>(.*?)</a>#\\l;$2\\u $1;#g;
  # Invert the put \const;Code\norm; sequences into pseudo-HTML <format const> tags
  $paragraph =~ s#<format (const|type|token|key)>([^\\;]*?)</format>#\\$1;$2\\norm;#g;
  # Invert the replace of \button $id; as pseudo xHTML <button $id/> tags
  $paragraph =~ s#<(button|key) ([^;]*?)/>#\\$1 $2;#g;
  return ($paragraph);
}

sub do_paragraph {
    my ($self, $paragraph, $wrap) = (shift, shift, shift);
    my $type = shift || $self->{type} || "Plain text";
    return if ($paragraph eq "");

    my $end = "";
    if ($wrap) {
        $paragraph =~ s/^(.*?)(\n*)$/$1/s;
        $end = $2 || "";
    }
    my $t = onlink($self->translate(offlink($paragraph),
                             $self->{ref},
                             $type,
                             "wrap" => $wrap));
    if (defined $self->{bullet}) {
        my $bullet = $self->{bullet};
        my $indent1 = $self->{indent};
        my $indent2 = $indent1.(' ' x length($bullet));
        $t =~ s/^/$indent1$bullet/s;
        $t =~ s/\n(.)/\n$indent2$1/sg;
    }
    $self->pushline( $t.$end );
}

1;
__END__
