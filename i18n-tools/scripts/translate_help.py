import os
import re

from common import TranslationJob, nice_mkdir, nice_path_join

"""
    Types of input lines
"""
TYPE_WHITESPACE = 1 # whitespace only
TYPE_HEADER     = 2 # header (beginning with \b or \t)
TYPE_BULLET     = 3 # bullet point
TYPE_IMAGE      = 4 # image (beginning with \image)
TYPE_CODE       = 5 # code (beginning with \s;)
TYPE_PLAIN      = 6 # plain text

class HelpTranslationJob(TranslationJob):
    def __init__(self, **kwargs):
        TranslationJob.__init__(self, **kwargs)
        self.template_file = kwargs['template_file']
        self.language_file = kwargs['language_file']
        self.line_buffer = None

    def process_file(self):
        while True:
            (paragraph, paragraph_type) = self.read_input_paragraph()
            if not paragraph:
                break

            if paragraph_type == TYPE_WHITESPACE:
                self.process_whitespace(paragraph[0])
            elif paragraph_type == TYPE_HEADER:
                self.process_header(paragraph[0])
            elif paragraph_type == TYPE_BULLET:
                self.process_bullet(paragraph[0])
            elif paragraph_type == TYPE_IMAGE:
                self.process_image(paragraph[0])
            elif paragraph_type == TYPE_CODE:
                self.process_code(paragraph)
            elif paragraph_type == TYPE_PLAIN:
                self.process_plain(paragraph)

    """
        Read one or more lines of input with same line type and return the list as paragraph
        Exception is types which are processed as single lines, giving only paragraph with one line
    """
    def read_input_paragraph(self):
        paragraph = None
        paragraph_type = None
        while True:
            line = None
            line_type = None
            if self.line_buffer:
                (line, line_type) = self.line_buffer
                self.line_buffer = None
            else:
                line = self.read_input_line()
                if line:
                    line_type = self.check_line_type(line.text)

            if not line:
                break

            if not paragraph_type:
                paragraph_type = line_type

            if paragraph_type == line_type:
                if not paragraph:
                    paragraph = []
                paragraph.append(line)
            else:
                self.line_buffer = (line, line_type)
                break

            if line_type in [TYPE_WHITESPACE, TYPE_HEADER, TYPE_BULLET, TYPE_IMAGE]:
                break

        return (paragraph, paragraph_type)

    def check_line_type(self, line):
        if re.match(r'^\s*$', line) or re.match(r'^\\[nctr];$', line):
            return TYPE_WHITESPACE
        elif re.match(r'^\\[bt];', line):
            return TYPE_HEADER
        elif re.match(r'^\s*([0-9]\)|[o-])', line):
            return TYPE_BULLET
        elif re.match(r'^\\image.*;$', line):
            return TYPE_IMAGE
        elif re.match(r'^\\s;', line):
            return TYPE_CODE
        else:
            return TYPE_PLAIN

    def process_whitespace(self, line):
        self.write_output_line(line.text)

    def process_header(self, line):
        match = re.match(r'^(\\[bt];)(.*)', line.text)
        header_type = match.group(1)
        header_text = match.group(2)
        translated_header_text = self.translate_text(header_text, line.occurrence, header_type + ' header')
        self.write_output_line(header_type + translated_header_text)

    def process_bullet(self, line):
        match = re.match(r'^(\s*)([0-9]\)|[o-])(\s*)(.*)', line.text)
        spacing_before_bullet = match.group(1)
        bullet_point          = match.group(2)
        spacing_after_bullet  = match.group(3)
        text                  = match.group(4)
        translated_text = self.translate_text(
            text, line.occurrence, "Bullet: '{0}'".format(bullet_point))
        self.write_output_line(spacing_before_bullet + bullet_point + spacing_after_bullet + translated_text)

    def process_image(self, line):
        match = re.match(r'^(\\image )(.*)( \d* \d*;)$', line.text)
        image_command = match.group(1)
        image_source = match.group(2)
        image_coords = match.group(3)
        translated_image_source = self.translate_text(image_source, line.occurrence, 'Image filename')
        self.write_output_line(image_command + translated_image_source + image_coords)

    def process_code(self, paragraph):
        text_lines = []
        for line in paragraph:
            match = re.match(r'^\\s;(.*)', line.text)
            code_line = match.group(1)
            text_lines.append(code_line)

        joined_text_lines = '\n'.join(text_lines)
        translated_text_lines = self.translate_text(joined_text_lines, paragraph[0].occurrence, 'Source code')
        for line in translated_text_lines.split('\n'):
            self.write_output_line(r'\s;' + line)

    def process_plain(self, paragraph):
        text_lines = []
        for line in paragraph:
            text_lines.append(line.text)

        joined_text_lines = '\n'.join(text_lines)
        translated_text_lines = self.translate_text(joined_text_lines, paragraph[0].occurrence, 'Plain text')
        for line in translated_text_lines.split('\n'):
            self.write_output_line(line)

    def translate_text(self, text, occurrence, type_comment):
        converted_text = convert_escape_syntax_to_tag_syntax(text)
        self.template_file.insert_entry(converted_text, occurrence, type_comment)

        if not self.language_file:
            return text

        translated_text = self.language_file.translate(converted_text)
        return convert_tag_syntax_to_escape_syntax(translated_text)

def convert_escape_syntax_to_tag_syntax(text):
    # Replace \button $id; as pseudo xHTML <button $id/> tags
    text = re.sub(r'\\(button|key) ([^;]*?);', r'<\1 \2/>', text)
    # Put \const;Code\norm; sequences into pseudo-HTML <format const> tags
    text = re.sub(r'\\(const|type|token|key);([^\\;]*?)\\norm;', r'<format \1>\2</format>', text)
    # Transform CBot links \l;text\u target; into pseudo-HTML <a target>text</a>
    text = re.sub(r'\\l;(.*?)\\u (.*?);', r'<a \2>\1</a>', text)
    # Cleanup pseudo-html targets separated by \\ to have a single character |
    text = re.sub(r'<a (.*?)\\(.*?)>', r'<a \1|\2>', text)
    # Replace remnants of \const; \type; \token, \norm; or \key; as pseudo xHTML <const/> tags
    text = re.sub(r'\\(const|type|token|norm|key);', r'<\1/>', text)
    # Put \c;Code\n; sequences into pseudo-HTML <code> tags
    text = re.sub(r'\\c;([^\\;]*?)\\n;', r'<code>\1</code>', text)
    # Replace remnants of \s; \c; \b; or \n; as pseudo xHTML <s/> tags
    text = re.sub(r'\\([scbn]);', r'<\1/>', text)
    return text

def convert_tag_syntax_to_escape_syntax(text):
    # Invert the replace remnants of \s; \c; \b; or \n; as pseudo xHTML <s/> tags
    text = re.sub(r'<([scbn])/>', r'\\\1;', text)
    # Invert the put of \c;Code\n; sequences into pseudo-HTML <code> tags
    text = re.sub(r'<code>([^\\;]*?)</code>', r'\\c;\1\\n;', text)
    # Invert the replace remnants of \const; \type; \token or \norm; as pseudo xHTML <const/> tags
    text = re.sub(r'<(const|type|token|norm|key)/>', r'\\\1;', text)
    # Invert the cleanup of pseudo-html targets separated by \\ to have a single character |
    text = re.sub(r'<a (.*?)\|(.*?)>', r'<a \1\\\2>', text)
    # Invert the transform of CBot links \l;text\u target; into pseudo-HTML <a target>text</a>
    text = re.sub(r'<a (.*?)>(.*?)</a>', r'\\l;\2\\u \1;', text)
    # Invert the put \const;Code\norm; sequences into pseudo-HTML <format const> tags
    text = re.sub(r'<format (const|type|token|key)>([^\\;]*?)</format>', r'\\\1;\2\\norm;', text)
    # Invert the replace of \button $id; as pseudo xHTML <button $id/> tags
    text = re.sub(r'<(button|key) (.*?)/>', r'\\\1 \2;', text)
    return text

"""
    Create jobs for help translation

    Assumes that input_dir has structure like so:
        ${input_dir}/E/help_file1.txt
        ...
        ${input_dir}/E/help_fileN.txt

    The output files will be saved in:
        ${output_dir}/${language_char1}/${install_subdir}/help_file1.txt
        ...
        ${output_dir}/${language_charM}/${install_subdir}/help_fileN.txt
"""
def create_help_translation_jobs(input_dir, output_dir, install_subdir, template_file, language_files):
    translation_jobs = []

    e_dir = os.path.join(input_dir, 'E')
    input_files = sorted(os.listdir(e_dir))

    if not install_subdir:
        install_subdir = ''

    language_files_list = []
    if len(language_files) > 0:
        language_files_list = language_files
    else:
        # We need at least one dummy language file to create any jobs
        language_files_list = [None]

    for language_file in language_files_list:
        output_translation_dir = None
        if language_file:
            output_translation_dir = nice_path_join(output_dir, language_file.language_char(), install_subdir)
            nice_mkdir(output_translation_dir)

        for input_file in input_files:
            translation_jobs.append(HelpTranslationJob(
                input_file    = os.path.join(e_dir, input_file),
                output_file   = nice_path_join(output_translation_dir, input_file),
                template_file = template_file,
                language_file = language_file))

    return translation_jobs
