#!/usr/bin/env python

import argparse
import os
import sys

from common import create_template_and_language_files, nice_mkdir
from translate_help import create_help_translation_jobs
from translate_level import create_level_translation_jobs
from translate_chaptertitles import create_chaptertitles_translation_jobs

def parse_args():
    parser = argparse.ArgumentParser(description = 'Generate translations of Colobot data files')

    parser.add_argument('--mode',
                        choices  = ['generate', 'print_files'],
                        required = True,
                        help     = 'Mode of operation: run generation process or only print input and output files')
    parser.add_argument('--type',
                        choices  = ['help', 'level', 'chaptertitles'],
                        required = True,
                        help     = 'Type of translation: help file or level file')
    parser.add_argument('--input_dir',
                        required = True,
                        help     = 'Input file(s) or directory to translate')
    parser.add_argument('--po_dir',
                        required = True,
                        help     = 'Translations directory (with *.pot and *.po files)')
    parser.add_argument('--output_dir',
                        help = 'Output directory for translated files')
    parser.add_argument('--output_subdir',
                        help = 'Install subdirectory (only for help files)')
    parser.add_argument('--signal_file',
                        help = 'Signal file to indicate successful operation')

    return parser.parse_args()

def preprocess_args(args):
    if not os.path.isdir(args.input_dir):
        sys.stderr.write('Expected existing input directory!\n')
        sys.exit(1)

    if not os.path.isdir(args.po_dir):
        sys.stderr.write('Expected existing translations directory!\n')
        sys.exit(1)

    if args.output_dir:
        nice_mkdir(args.output_dir)

def create_translation_jobs(args, template_file, language_files):
    translation_jobs = []

    if args.type == 'help':
        translation_jobs = create_help_translation_jobs(args.input_dir,
                                                        args.output_dir,
                                                        args.output_subdir,
                                                        template_file,
                                                        language_files)
    elif args.type == 'level':
        translation_jobs = create_level_translation_jobs(args.input_dir,
                                                        args.output_dir,
                                                        template_file,
                                                        language_files)
    elif args.type == 'chaptertitles':
        translation_jobs = create_chaptertitles_translation_jobs(args.input_dir,
                                                                 args.output_dir,
                                                                 template_file,
                                                                 language_files)

    return translation_jobs

def print_files(translation_jobs):
    input_files = []
    output_files = []
    for translation_job in translation_jobs:
        input_files.append(translation_job.get_input_file_name())
        output_files.append(translation_job.get_output_file_name())

    sys.stdout.write(';'.join(input_files))
    sys.stdout.write('\n')
    sys.stdout.write(';'.join(output_files))

def generate_translations(translation_jobs, template_file, language_files):
    for translation_job in translation_jobs:
        translation_job.run()

    template_file.merge_and_save()
    for language_file in language_files:
        language_file.merge_and_save(template_file)

def save_signalfile(signal_file_name):
    if signal_file_name:
        nice_mkdir(os.path.dirname(signal_file_name))
        with open(signal_file_name, 'w') as signal_file:
            signal_file.close()

def main():
    args = parse_args()
    preprocess_args(args)

    (template_file, language_files) = create_template_and_language_files(args.po_dir)
    translation_jobs = create_translation_jobs(args, template_file, language_files)

    if args.mode == 'print_files':
        print_files(translation_jobs)

    elif args.mode == 'generate':
        generate_translations(translation_jobs, template_file, language_files)

    save_signalfile(args.signal_file)

if __name__ == '__main__':
    main()
