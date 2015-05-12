import os
import re

from translate_help import HelpTranslationJob
from common import TranslationJob, nice_mkdir, nice_path_join

class LevelTranslationJob(TranslationJob):
    def __init__(self, **kwargs):
        TranslationJob.__init__(self, **kwargs)
        self.template_file = kwargs['template_file']
        self.language_files = kwargs['language_files']
        self.line_buffer = None

    def process_file(self):
        while True:
            line = self.read_input_line()
            if not line:
                break

            # English version is always written
            self.write_output_line(line.text)

            match = re.match(r'^(Title|Resume|ScriptName)\.E(.*)', line.text)
            if match:
                for language_file in self.language_files:
                    self.add_translated_line(match, line.occurrence, language_file)

    def add_translated_line(self, command_match, occurrence, language_file):
        command = command_match.group(1)
        arguments = command_match.group(2)

        translated_arguments = arguments
        for attribute_match in re.finditer('(text|resume)="([^"]*)"', arguments):
            whole_attribute_match = attribute_match.group(0)
            attribute = attribute_match.group(1)
            text = attribute_match.group(2)

            self.template_file.insert_entry(text, occurrence, command + '-' + attribute)

            translated_arguments = translated_arguments.replace(
                whole_attribute_match,
                u'{0}="{1}"'.format(attribute, language_file.translate(text)))

        self.write_output_line(u'{0}.{1}{2}'.format(
                command,
                language_file.language_char(),
                translated_arguments))


"""
    Create jobs for chapter translation

    Assumes that input_dir has structure like so:
        ${input_dir}/scene.txt
        ${input_dir}/help/help_file1.txt
        ...
        ${input_dir}/help/help_fileN.txt

    The output files will be saved in:
        ${output_dir}/scene.txt
        ${output_dir}/help/help_file1.${language_char1}.txt
        ...
        ${output_dir}/help/help_fileN.${language_charM}.txt
"""
def create_level_translation_jobs(input_dir, output_dir, template_file, language_files):
    translation_jobs = []

    input_file = os.path.join(input_dir, 'scene.txt')
    translation_jobs.append(LevelTranslationJob(
        input_file     = input_file,
        output_file    = nice_path_join(output_dir, 'scene.txt'),
        template_file  = template_file,
        language_files = language_files))

    input_help_dir = os.path.join(input_dir, 'help')
    if os.path.isdir(input_help_dir):
        output_help_dir = nice_path_join(output_dir, 'help')
        nice_mkdir(output_help_dir)

        language_files_list = []
        if len(language_files) > 0:
            language_files_list = language_files
        else:
            # We need at least one dummy language file to create any jobs
            language_files_list = [None]

        for language_file in language_files_list:
            for help_file in sorted(os.listdir(input_help_dir)):
                if language_file:
                    translated_help_file = help_file.replace('.E.txt', '.{0}.txt'.format(language_file.language_char()))

                translation_jobs.append(HelpTranslationJob(
                    input_file    = os.path.join(input_help_dir, help_file),
                    output_file   = nice_path_join(output_help_dir, translated_help_file),
                    template_file = template_file,
                    language_file = language_file))

    return translation_jobs
