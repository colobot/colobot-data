#!/usr/bin/env python3
# coding=utf-8

import logging
import argparse
import os
import json
import subprocess
import binascii
from PIL import Image
from io import BytesIO
import shutil
import re

import metafile

logging.basicConfig(format='[%(levelname)s] %(message)s', level=logging.DEBUG)

def is_valid_directory(arg):
    if not os.path.isdir(arg):
        raise argparse.ArgumentTypeError('The directory {} does not exist!'.format(arg))
    else:
        return os.path.abspath(arg)

parser = argparse.ArgumentParser(description='Convert legacy EPSITEC data directory structure to Gold Edition format')
parser.add_argument('source', type=is_valid_directory, help='Source directory to process, likely an EPSITEC game install directory')
parser.add_argument('target', type=is_valid_directory, help='Target directory to put processed files in')
parser.add_argument('--gametype', help='Game type (default: autodetect)')
parser.add_argument('--enckey', help='Data files encryption key to use. One of: {} or an arbitrary hex string (default: full)'.format(', '.join(metafile.enckeys.keys())), default='full')
parser.add_argument('--source-encoding', dest='source_encoding', help='Source text file encoding. ISO-8859-2 for Polish, ISO-8859-1 for French, others have not been tested (default: ISO-8859-2)', default='ISO-8859-2') # TODO: Test this

args = parser.parse_args()
logging.info("Starting data structure converter")
logging.info("Source dir: {}".format(args.source))
logging.info("Target dir: {}".format(args.target))

def get_metadata(filepath):
    if type(filepath) is not list:
        filepath = [filepath]
    s = subprocess.Popen(['exiftool', '-G', '-j', '-sort'] + filepath, stdout=subprocess.PIPE)
    s = s.stdout.read()
    s = s.decode('utf-8').rstrip('\r\n')
    return json.loads(s)

game_type = args.gametype
if not game_type:
    logging.info("Checking game type")
    exe_files = [os.path.join(args.source, f) for f in os.listdir(args.source) if os.path.splitext(f)[1] == '.exe']
    exe_metadata = get_metadata(exe_files)
    game_exe = []
    for exe in exe_metadata:
        if not 'EXE:OriginalFileName' in exe:
            continue
        logging.info("Checking {}".format(exe['SourceFile']))
        for m in ['OriginalFileName', 'InternalName', 'CompanyName', 'LegalCopyright', 'TimeStamp']:
            logging.info("    {}: {}".format(m, exe['EXE:'+m]))
        game_exe.append(exe)
    if len(game_exe) == 0:
        raise Exception("No game EXE found")
    if len(game_exe) > 1:
        raise Exception("Multiple game EXE found")
    game_exe = game_exe[0]
    logging.info("Using {} as game EXE".format(game_exe['SourceFile']))
    game_type = os.path.splitext(game_exe['EXE:OriginalFileName'])[0]
logging.info("Game type is {}".format(game_type))

logging.info("Using metafile encryption key: {}".format(args.enckey))
enckey = None
if args.enckey in metafile.enckeys:
    enckey = metafile.enckeys[args.enckey]
else:
    enckey = bytearray(binascii.unhexlify(args.enckey))
logging.debug("Key: {}".format(binascii.hexlify(enckey)))

logging.info("Extracting data files")
logging.debug("Making metafile target dirs")
os.mkdir(os.path.join(args.target, "textures"))
os.mkdir(os.path.join(args.target, "textures", "interface"))
os.mkdir(os.path.join(args.target, "textures", "objects"))
os.mkdir(os.path.join(args.target, "models"))
os.mkdir(os.path.join(args.target, "sounds"))
logging.debug("Extracting files")
# TODO: Fix object textures location
dat_files = [os.path.join(args.source, f) for f in os.listdir(args.source) if os.path.splitext(f)[1] == '.dat']
for dat in dat_files:
    logging.info("Extracting {}".format(dat))
    texture_stitch = {}
    with metafile.Metafile(dat, 'rb', enckey) as mf:
        for file in mf.file_list():
            logging.info("Extract file {}".format(file.name))
            name, ext = os.path.splitext(file.name)
            if ext == ".tga":
                targetdir = "textures"
                if name == "map" or re.match("shadow..", name):
                    logging.debug("Ignoring {}".format(file.name))
                    continue
                if re.match("text.*", name):
                    logging.debug("Rename '{}' to 'effect03'".format(name))
                    name = "effect03"
                if name == 'manta':
                    logging.debug("Rename '{}' to 'intro1'".format(name))
                    name = "intro1"
                if name == 'colobot':
                    logging.debug("Rename '{}' to 'intro2'".format(name))
                    name = "intro2"
                if re.match('epsitec.', name):
                    logging.debug("Rename '{}' to 'intro3'".format(name))
                    name = "intro3"
                if re.match('intro.', name) or re.match('button.', name) or name == 'mouse':
                    targetdir = os.path.join(targetdir, "interface")
                name = name.lower()
                image = Image.open(BytesIO(mf.read_file(file)))
                m = re.match('(gener.)([abcd])', name)
                if m:
                    name = 'generico'
                    targetdir = os.path.join(targetdir, "interface")
                else:
                    m = re.match('(inter01)([abcd])', name)
                    if m:
                        name = 'interface'
                        targetdir = os.path.join(targetdir, "interface")
                tgt_path = os.path.join(args.target, targetdir, name+".png")
                if m:
                    logging.info("Store {} for stitching later into {}".format(m.group(0), name))
                    if not tgt_path in texture_stitch:
                        texture_stitch[tgt_path] = {}
                    texture_stitch[tgt_path][m.group(2)] = image
                else:
                    image.save(tgt_path, "PNG")
            elif ext == ".mod":
                with open(os.path.join(args.target, "models", file.name), 'wb') as file2:
                    file2.write(mf.read_file(file))
            elif ext == ".wav":
                with open(os.path.join(args.target, "sounds", file.name), 'wb') as file2:
                    file2.write(mf.read_file(file))
    for tgt_path, images in texture_stitch.items():
        logging.info("Stitching image {}".format(os.path.basename(tgt_path)))
        width, height = images['a'].size
        result = Image.new('RGB', (width*2, height*2))
        result.paste(im=images['a'], box=(0, 0))
        result.paste(im=images['b'], box=(width, 0))
        result.paste(im=images['c'], box=(0, height))
        result.paste(im=images['d'], box=(width, height))
        result.save(tgt_path, "PNG")

def copytxt(source, target, filter=None):
    if not filter:
        filter = (lambda x: x)
    with open(source, 'r', encoding=args.source_encoding) as f1:
        with open(target, 'w', encoding='UTF-8') as f2:
            for line in f1:
                f2.write(filter(line.replace("\x9c", "ś").replace("š", "ą").strip("\r\n"))+"\n")

logging.info("Copy scripts")
os.mkdir(os.path.join(args.target, "ai"))
for file in os.listdir(os.path.join(args.source, "script")):
    if os.path.isdir(os.path.join(args.source, "script", file)):
        logging.warn("Skip '{}' as it is a directory".format(file))
        continue
    logging.debug(file)
    copytxt(os.path.join(args.source, "script", file), os.path.join(args.target, "ai", file.lower()))

logging.info("Copy diagrams")
os.mkdir(os.path.join(args.target, "icons"))
for file in os.listdir(os.path.join(args.source, "diagram")):
    if os.path.isdir(os.path.join(args.source, "diagram", file)):
        logging.warn("Skip '{}' as it is a directory".format(file))
        continue
    logging.debug(file)
    name, ext = os.path.splitext(file)
    image = Image.open(os.path.join(args.source, "diagram", file))
    image.save(os.path.join(args.target, "icons", name+".png"), "PNG")

#if game_type != "buzzingcars":
helproot = os.path.join(args.source, "help")
if os.path.isdir(helproot):
    logging.debug("Copy help")
    os.mkdir(os.path.join(args.target, "help"))
    helptgt = os.path.join(args.target, "help", "E")
    os.mkdir(helptgt)
    for curroot, subdirs, files in os.walk(helproot):
        curroot = os.path.relpath(curroot, helproot)
        for subdir in subdirs:
            os.mkdir(os.path.join(helptgt, curroot, subdir.lower()))
        for file in files:
            copytxt(os.path.join(helproot, curroot, file), os.path.join(helptgt, curroot, file.lower()))
    for lng in ['P', 'F', 'D', 'R']:
        os.symlink(os.path.join(args.target, "help", "E"), os.path.join(args.target, "help", lng))

logging.info("Copy res/relief textures")
for file in os.listdir(os.path.join(args.source, "textures")):
    if os.path.isdir(os.path.join(args.source, "textures", file)):
        logging.warn("Skip '{}' as it is a directory".format(file))
        continue
    logging.debug(file)
    name, ext = os.path.splitext(file)
    if ext == ".ico":
        continue # wtf
    image = Image.open(os.path.join(args.source, "textures", file))
    name = name.lower()
    image.save(os.path.join(args.target, "textures", name+".png"), "PNG")

logging.info("Copy scenes")
def update_scene(line):
    return line.replace("Ambiant", "Ambient").replace("ambiant", "ambient").replace("Frontsize", "Foreground").replace("Global", "Level").replace(".tga", ".png").replace(".bmp", ".png").replace("textures\\", "").replace("diagram\\", "../icons/")
os.mkdir(os.path.join(args.target, "levels"))
os.mkdir(os.path.join(args.target, "levels", "other"))
for file in os.listdir(os.path.join(args.source, "scene")):
    if os.path.isdir(os.path.join(args.source, "scene", file)):
        logging.warn("Skip '{}' as it is a directory".format(file))
        continue
    logging.debug(file)
    m = re.match("(.+?)([0-9]{3}).txt", file)
    if not m or m.group(1) in ['win', 'lost', 'perso', 'car', 'teenw']:
        copytxt(os.path.join(args.source, "scene", file), os.path.join(args.target, "levels", "other", file), filter=update_scene)
    else:
        if not os.path.isdir(os.path.join(args.target, "levels", m.group(1))):
            os.mkdir(os.path.join(args.target, "levels", m.group(1)))
        num = int(m.group(2))
        if game_type == "buzzingcars":
            chap = num // 10
            rank = num % 10
        else:
            chap = num // 100
            rank = num % 100
        if not os.path.isdir(os.path.join(args.target, "levels", m.group(1), "chapter%03d" % chap)):
            os.mkdir(os.path.join(args.target, "levels", m.group(1), "chapter%03d" % chap))
        if rank == 0:
            copytxt(os.path.join(args.source, "scene", file), os.path.join(args.target, "levels", m.group(1), "chapter%03d" % chap, "chaptertitle.txt"), filter=update_scene)
        else:
            if not os.path.isdir(os.path.join(args.target, "levels", m.group(1), "chapter%03d" % chap, "level%03d" % rank)):
                os.mkdir(os.path.join(args.target, "levels", m.group(1), "chapter%03d" % chap, "level%03d" % rank))
            copytxt(os.path.join(args.source, "scene", file), os.path.join(args.target, "levels", m.group(1), "chapter%03d" % chap, "level%03d" % rank, "scene.txt"), filter=update_scene)
linkmap = {
    'scene': 'missions',
    'free': 'freemissions',
    'train': 'exercises' if not os.path.isdir(os.path.join(args.target, "levels", 'teen')) else 'missions',
    'defi': 'challenges',
    'teen': 'freemissions'
}
for k,v in linkmap.items():
    if os.path.isdir(os.path.join(args.target, "levels", k)):
        os.symlink(os.path.join(args.target, "levels", k), os.path.join(args.target, "levels", v))

logging.info("Import Gold Edition fonts")
shutil.copytree(os.path.join("..", "fonts"), os.path.join(args.target, "fonts"))

logging.info("Done!")
