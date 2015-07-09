# Colobot: Gold Edition - music files
This reporitory contains music tracks for Colobot: Gold Edition project (https://github.com/colobot/colobot) and is an optional addition to game's data files (https://github.com/colobot/colobot-data).
It currently includes:
* Original music from Colobot game, composed by **Daniel Roux** and prepared by **CoLoRaptor** to be also as stand-alone soundtrack album in the Vorbis meta-tags (by adding titles to every track and changing queue, that would be more suited to album release). This music was taken from original game CD.
 * Track 01: "CoLoBoT Main Theme" - music011.flac
 * Track 02: "Leaving Earth - NASA Exercises" - music002.flac
 * Track 03: "The First Unknown World - Nature of Natives" - music003.flac
 * Track 04: "Crystalium - System Failure" - music004.flac
 * Track 05: "Saari's Heat" - music005.flac
 * Track 06: "Eruption" - music006.flac
 * Track 07: "Centaury - The Lost Hope" - music007.flac
 * Track 08: "Infinite Storm" - music008.flac
 * Track 09: "Terranova - Our New Home" - music009.flac
 * Track 10: "You Win!" - music012.flac
 * Track 11: "You Lose..." - music010.flac
 * Track 12: "Jazz Buzzing EasterEgg" - music013.flac
* New audio tracks, composed by **Emxx52** ([forum](http://colobot.info/forum/memberlist.php?mode=viewprofile&u=68), [GitHub](https://github.com/Emxx52))
 * "Constructive Destruction" - Constructive.flac
 * "Humanitarian" - Humanitaian.flac
 * "Humanitarian v2 - The Box" - Hv2.flac
 * "Prototype" - Prototype.flac
 * "Quite Busy" - Quite.flac
 * "Infinite Storm v2 - Being Approximately Overcharged" - Infinite.flac
 * "Proton Ame" - Proton.flac
* New main menu intro music, composed by **PiXeL** ([forum](http://colobot.info/forum/memberlist.php?mode=viewprofile&u=243))
 * Intro1.ogg
 * Intro2.ogg

# File formats and installation
This repository contains files in FLAC format. However, the game can only play OGG files, so they need to be converted first - it's done like this so we can keep high quality music available, but reduce the file size for use in Colobot data files. This is done by CMake scripts included with this repository, but they require "oggenc" to be installed in your system.

# Licensing
All music files on this reporitory are licensed under GPLv3 license.
* The rights to redistribute original music files were given to TerranovaTeam along with the source code.
* Emxx52 puts his music on our forum and allows us to distribute it with the game - [forum topic (Polish)](http://colobot.info/forum/viewtopic.php?p=3242#p3242)
* The same applies to PiXeL's intro music - [forum post (Polish)](http://colobot.info/forum/viewtopic.php?f=17&t=354&p=3505#p3505)
