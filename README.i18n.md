# Colobot data translation

The translation of Colobot level titles, level hierarchy and help files
is managed through [gettext](https://www.gnu.org/software/gettext/).

## Level scene description files

Level scene description files have english headers that are used in the
Colobot interface to describe the levels. Level scene description files
are levels/$level/scene.txt and translations are handled in the
level-specific po/ directory: levels/$levels/po/. The .pot file is the
source translation file, the *.po files are the translations.

## Help files

Helpfiles are divided in two categories:
* Generic helpfiles, about the game, the objects, the syntax, etc. These
  are stored in help/ , in four sub-categories: generic, bots, object
  and bots.
* Level-specific helpfiles, about the level, instructions, example
  programs, etc. These are stored in levels/$level/help/.

Helpfiles have their source in english, always stored in the E/
subdirectory. To ensure retro-compatibility, existing translations have
not been integrated in the gettext-based translation mechanisms and are
stored in their respective one-character directories. New translations
snd updates to existing ones should really use the gettext-based
translation.

## Colobot syntax

Colobot parses a specific syntax to enable some formatting in the game
interface.

To ease translation, this syntax is transformed into a pseudo-HTML
syntax in the gettext files.

Here is the table of transformations and their meanings:

<table>
 <thead>
  <tr>
    <td>Transformed label</td>
    <td>Colobot native label</td>
    <td>Description</td>
  </tr>
 </thead>
 <tbody>
  <tr>
    <td><tt>&lt;button $buttonID/&gt;</tt></td>
    <td><tt>\button $buttonID;</tt></td>
    <td>Indicates a UI button. <tt>$buttonID</tt> is a number</td>
  </tr>
  <tr>
    <td><tt>&lt;key $keyCode/&gt;</tt></td>
    <td><tt>\key $keyCode;</tt></td>
    <td>Indicates a keyboard key. <tt>$keyCode</tt> is a code, such as <tt>action</tt></td>
  </tr>
  <tr>
    <td><tt>&lt;format $formatID&gt;Formatted text&lt;/format&gt;</tt></td>
    <td><tt>\$formatID;Formatted text\norm;</tt></td>
    <td>Changes text formatting in the marker. <tt>$formatID</tt> can be <tt>const</tt>, <tt>type</tt>, <tt>token</tt> or <tt>key</tt>.</td>
  </tr>
  <tr>
    <td><tt>&lt;$formatID/&gt;</tt></td>
    <td><tt>\$formatID;</tt></td>
    <td>Toggle text formatting. <tt>$formatID</tt> can be <tt>const</tt>, <tt>type</tt>, <tt>token</tt>, <tt>key</tt> or <tt>norm</tt>.</td>
  </tr>
  <tr>
    <td><tt>&lt;a $link&gt;Link text&lt;/a&gt;</tt></td>
    <td><tt>\l;Link text\u $link;</tt></td>
    <td>Direct hyper-link. <tt>$link</tt> can be direct or in a category (such as <tt>cbot\abstime</tt>)</td>
  </tr>
  <tr>
    <td><tt>&lt;a $linkcat|$link&gt;Link text&lt;/a&gt;</tt></td>
    <td><tt>\l;Link text\u $linkcat\$link;</tt></td>
    <td>In-category hyper-link, <tt>linkcat</tt> can only be <tt>cbot</tt>, <tt>bots</tt> or <tt>object</tt>.</td>
  </tr>
  <tr>
    <td><tt>&lt;code&gt;CBot code&lt;/code&gt;</tt></td>
    <td><tt>\c;CBot code\n;</tt></td>
    <td>Code formatting</td>
  </tr>
  <tr>
    <td><tt>&lt;s/&gt;</tt></td>
    <td><tt>\s;</tt></td>
    <td>Typewriter line indicator (usually verbatim code)</td>
  </tr>
  <tr>
    <td><tt>&lt;t/&gt;</tt></td>
    <td><tt>\t;</tt></td>
    <td>Title line indicator</td>
  </tr>
  <tr>
    <td><tt>&lt;b/&gt;</tt></td>
    <td><tt>\b;</tt></td>
    <td>Subtitle line indicator</td>
  </tr>
  <tr>
    <td><tt>&lt;c/&gt;</tt></td>
    <td><tt>\c;</tt></td>
    <td>Typewriter formatting toggle</td>
  </tr>
  <tr>
    <td><tt>&lt;n/&gt;</tt></td>
    <td><tt>\n;</tt></td>
    <td>Normal formatting toggle</td>
 </tbody>
</table>

