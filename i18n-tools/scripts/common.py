import errno
import io
import os
import polib

"""
   Conversion functions to avoid mixed \ and / path separators under Windows
"""
def convert_input_path(slash_path):
    if not slash_path:
        return None
    return slash_path.replace('/', os.sep)

def convert_output_path(system_path):
    if not system_path:
        return None
    return system_path.replace(os.sep, '/')

"""
    Works like shell's "mkdir -p" and also behaves nicely if given None argument
"""
def nice_mkdir(path):
    if path is None:
        return

    try:
        os.makedirs(path)
    except OSError as exc:
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

"""
    Works as os.path.join, but behaves nicely if given None argument
"""
def nice_path_join(*paths):
    for path in paths:
        if path is None:
            return None

    return os.path.join(*paths)

"""
    Wrapper class over POFile, acting as translation template file

    It actually hold two POFile instances:
        previous_catalog is the content of PO file read from disk
        current_catalog is created empty and filled with entries from input files

    Once all processing is done, the content of previous_catalog is merged with current_catalog
    and the result is saved to disk.
"""
class TemplateFile:
    def __init__(self, file_name):
        self.file_name = file_name
        self.dir_name = os.path.dirname(file_name)
        self.language = 'en'
        self.current_catalog = polib.POFile(wrapwidth = 0)
        if os.path.exists(file_name):
            self.previous_catalog = polib.pofile(file_name, wrapwidth = 0)
        else:
            self.previous_catalog = polib.POFile(wrapwidth = 0)

    """
        Wrapper over inserting template file entry
        If entry does not exist, it is created;
         otherwise it is modified to indicate multiple occurrences
    """
    def insert_entry(self, text, occurrence, type_comment):
        entry = self.current_catalog.find(text)
        relative_file_name = convert_output_path(os.path.relpath(occurrence.file_name, self.dir_name))
        occurrence = (relative_file_name, occurrence.line_number)
        if entry:
            entry.comment = self._merge_comment(entry.comment, type_comment)
            if occurrence not in entry.occurrences:
                entry.occurrences.append(occurrence)
        else:
            comment = 'type: ' + type_comment
            new_entry = polib.POEntry(msgid = text,
                                      comment = comment,
                                      occurrences = [occurrence],
                                      flags = ['no-wrap'])

            self.current_catalog.append(new_entry)

    def _merge_comment(self, previous_comment, type_comment):
        new_comment = previous_comment

        previous_types = previous_comment.replace('type: ', '')
        previous_types_list = previous_types.split(', ')

        if type_comment not in previous_types_list:
            new_comment += ', ' + type_comment

        return new_comment

    """
        Merges previous_catalog with current_catalog and saved the result to disk
    """
    def merge_and_save(self):
        self.previous_catalog.merge(self.current_catalog)
        for x in self.previous_catalog.obsolete_entries():
            self.previous_catalog.remove(x)
        self.previous_catalog.save(self.file_name, newline='\n')

"""
    Wrapper class over POFile, acting as language translation file
"""
class LanguageFile:
    def __init__(self, file_name):
        self.file_name = file_name
         # get language from file name e.g. "/foo/de.po" -> "de"
        (self.language, _) = os.path.splitext(os.path.basename(file_name))
        if os.path.exists(file_name):
            self.catalog = polib.pofile(file_name, wrapwidth = 0)
        else:
            self.catalog = polib.POFile(wrapwidth = 0)

    """
        Return single language character e.g. "de" -> "D"
    """
    def language_char(self):
        if self.language == 'pt':
            return 'B';
        else:
            return self.language[0].upper()

    """
        Try to translate given text; if not found among translations,
        return the original
    """
    def translate(self, text):
        entry = self.catalog.find(text)
        if entry and entry.msgstr != '':
            return entry.msgstr
        return text

    """
        Merges entries with current_catalog from template file and saves the result to disk
    """
    def merge_and_save(self, template_file):
        self.catalog.merge(template_file.current_catalog)
        for x in self.catalog.obsolete_entries():
            self.catalog.remove(x)
        self.catalog.save(self.file_name, newline='\n')

"""
    Locates the translation files in po_dir
"""
def find_translation_file_names(po_dir):
    pot_file_name = os.path.join(po_dir, 'translations.pot') # default
    po_file_names = []
    for file_name in os.listdir(po_dir):
        if file_name.endswith('.pot'):
            pot_file_name = os.path.join(po_dir, file_name)
        elif file_name.endswith('.po'):
            po_file_names.append(os.path.join(po_dir, file_name))

    return (pot_file_name, po_file_names)

"""
    Creates template and language files by reading po_dir
"""
def create_template_and_language_files(po_dir):
    (pot_file_name, po_file_names) = find_translation_file_names(po_dir)

    template_file = TemplateFile(pot_file_name)
    language_files = []
    for po_file_name in po_file_names:
        language_files.append(LanguageFile(po_file_name))

    return (template_file, language_files)

"""
    Structure representing occurrence of text
"""
class Occurrence:
    def __init__(self, file_name, line_number):
        self.file_name = file_name
        self.line_number = line_number

"""
    Structure representing line read from input file
"""
class InputLine:
    def __init__(self, text, occurrence):
        self.text = text
        self.occurrence = occurrence


"""
    Base class for single translation process,
    translating one input file into one output file

    It provides wrapper code for reading consecutive lines of text and saving the result
"""
class TranslationJob:
    def __init__(self, **kwargs):
        self._input_line_counter = 0
        self._input_file_name = kwargs['input_file']
        self._input_file = None

        self._output_file_name = kwargs['output_file']
        self._output_file = None

    """
        Launch translation process
        Actual processing is done in process_file() function which must be implemented by subclasses
    """
    def run(self):
        try:
            self._open_files()
            self.process_file()
        finally:
            self._close_files()

    def _open_files(self):
        self._input_file = io.open(self._input_file_name, 'r', encoding='utf-8', newline='\n')
        if self._output_file_name:
            self._output_file = io.open(self._output_file_name, 'w', encoding='utf-8', newline='\n')

    def _close_files(self):
        self._input_file.close()
        if self._output_file:
            self._output_file.close()

    """
        Return next line, occurrene pair from input file or None if at end of input
    """
    def read_input_line(self):
        line = self._input_file.readline()
        if line == '':
            return None

        self._input_line_counter += 1
        return InputLine(line.rstrip('\n'), Occurrence(self._input_file_name, self._input_line_counter))

    """
        Write line to output file, if present
    """
    def write_output_line(self, line):
        if self._output_file:
            self._output_file.write(line + '\n')

    def get_input_file_name(self):
        return self._input_file_name

    def get_output_file_name(self):
        return self._output_file_name
