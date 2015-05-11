import os

from translate_level import LevelTranslationJob
from common import nice_mkdir, nice_path_join

"""
    Create jobs for chaptertile files translation

    Assumes that input_dir has structure like so:
        ${input_dir}/dir1/chaptertitle.txt
        ...
        ${input_dir}/dirN/chaptertitle.txt

    The output files will be saved in:
        ${input_dir}/dir1/chaptertitle.txt
        ...
        ${input_dir}/dirN/chaptertitle.txt

    The actual translation is done using the same jobs as level files
"""
def create_chaptertitles_translation_jobs(input_dir, output_dir, template_file, language_files):
    translation_jobs = []

    for subdirectory in sorted(os.listdir(input_dir)):
        input_subdirectory = os.path.join(input_dir, subdirectory)
        if not os.path.isdir(input_subdirectory):
            continue

        input_file = os.path.join(input_subdirectory, 'chaptertitle.txt')
        if not os.path.isfile(input_file):
            continue

        output_subdirectory = nice_path_join(output_dir, subdirectory)
        nice_mkdir(output_subdirectory)

        translation_jobs.append(LevelTranslationJob(
            input_file     = input_file,
            output_file    = nice_path_join(output_subdirectory, 'chaptertitle.txt'),
            template_file  = template_file,
            language_files = language_files))

    return translation_jobs
