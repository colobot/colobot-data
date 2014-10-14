# Colobot Data Files

This repository contains the data files for the Colobot project (https://github.com/colobot/colobot).
It currently includes:
* mission files
* textures
* model files
* sounds and music
* ai scripts
* in-game help
* some documents describing the formats
* conversion scripts and tools for packaging

# Installation

CMake project files in main and data repositories are integrated and when invoked during compilation,
produce output files to be installed. As of 0.1.2-alpha, the generated files are different from source
files. Consequently, running the game with data files directly from this source repository is not supported.
Please see the [INSTALL.md](https://github.com/colobot/colobot/blob/master/INSTALL.md) instructions
in main repository for details.

Some details of how data file translation is achieved can be found in
[README.i18n.md](https://github.com/colobot/colobot-data/blob/master/README.i18n.md) file.

# License

The source code contained here was released by Epsitec -- the original
creator of the game -- on open source (GPLv3) license. The code was
given and the rights granted specifically to ICC community in
March 2012. Since then, we have been modifying the code and working on
our goals. For more info, see [README.md in the main repository](https://github.com/colobot/colobot/blob/master/README.md)
