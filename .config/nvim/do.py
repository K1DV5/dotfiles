# $ export FOO=111 && echo $FOO
'''
My General purpose build script
K1DV5
'''

import os
import sys
from glob import glob
from json import load
from os import chdir, environ, getcwd, makedirs, path, remove, rename
from shutil import copy, move
from subprocess import call, run
from time import sleep

use_shell = False

def open_file(filename):
    if sys.platform == "win32":
        os.startfile(filename)
    else:
        opener = "open" if sys.platform == "darwin" else "xdg-open"
        call([opener, filename])

def _exec_cmd(cmd, shell=use_shell):
    '''
    color print the command and execute it
    return the exitcode
    '''
    print('$', cmd)
    try:
        return run(cmd, shell=shell).returncode
    except KeyboardInterrupt:
        return 1


# convert to absolute path
if not path.isabs(sys.argv[1]):
    sys.argv[1] = path.abspath(path.join('.', sys.argv[1]))
CURDIR = path.abspath(getcwd())  # current folder
# extract filename from path\to\file\filename.ext in the format filename.ext
FILE_NAME = path.basename(sys.argv[1])
# only filename from filename.ext
NAME_PART = path.splitext(FILE_NAME)[0]
# only folder like C:\path\to\file
FOLDER = path.dirname(path.abspath(sys.argv[1]))
# change working directory to where the file is: folder
chdir(FOLDER)
with open(FILE_NAME, 'r', encoding='utf-8') as file:
    LINE_1 = file.readline().strip()
    if ' ' in LINE_1:
        LINE_1 = LINE_1.split(' ', 1)[1]


def autohotkey():
    '''just run it'''
    open_file(FILE_NAME)


def html():
    open_file(FILE_NAME)


def python():
    '''if the file is a python script, in the first line comment, write:
    -i or -inter or -interactive to run file as "python -i [ file ]"
    -ipy or -ipython to run file as "ipython -i [ file ]"
    -args([ args ]) to run file as "python [ file ] [ args ]"
    -exe to create executable using cython (experimental)
    -cy or -cython to create cython extensions:
        if there is a portion of the file between <cython> and </cython>
          only that portion will be commented out and it will be imported
          as a cython extension
        if there is no region delimiter, the whole file will be converted
    '''
    if '-(' in LINE_1:
        # extract arguments to be passed to the script from first line
        b_ind = LINE_1.find('-(') + len('-(')
        e_ind = LINE_1.find(')', b_ind)
        args = LINE_1[b_ind: e_ind].split(' ')
    else:
        args = []

    if ' -ip' in LINE_1 or ' -ipy' in LINE_1 or ' -ipython' in LINE_1:
        cmd = ['ipython', '-i', FILE_NAME] + args
    elif ' -i' in LINE_1 or ' -inter' in LINE_1 or ' -interact' in LINE_1:
        cmd = ['python', '-i', FILE_NAME] + args
    elif ' -pdb' in LINE_1:
        cmd = ['python', '-m', 'pdb', FILE_NAME] + args
    elif ' -doc' in LINE_1 or ' -docal' in LINE_1:
        cmd = ['docal', FILE_NAME] + args
    elif ' -d' in LINE_1:
        cmd = ['ipython', '-c', '%run -d ' + FILE_NAME] + args
    else:
        cmd = ['python', FILE_NAME] + args
    return _exec_cmd(cmd)


def latex():
    '''
    write:
    -lua or -luatex or -lualatex to run as "lualatex {file}"
    -xe or -xetex or -xelatex to run as "xelatex {file}"
    default engine: pdflatex
    -beta to typeset twice
    -rel, -fin or -final to typeset, run bibtex and typeset twice
    default run: once
    -py if using pythontex
    '''

    with open(sys.argv[1], 'r') as file:
        options = file.readline()
    if '-lua' in options or '-luatex' in options or '-lualatex' in options:
        engine = 'lualatex'
    elif '-xe' in options or '-xetex' in options or '-xelatex' in options:
        engine = 'xelatex'
    else:
        engine = 'pdflatex'

    temp_folder = path.join(environ['TMP'], '.latexTmp')
    makedirs(temp_folder, exist_ok=True)

    command = [engine, '-output-directory=' + temp_folder, NAME_PART]
    if ' -se' in options:
        command.insert(-1, '--shell-escape')

    successful = not _exec_cmd([command[0], '-interaction=nonstopmode', *command[1:]])

    if successful:
        if '-py' in options:
            _exec_cmd(['pythontex', temp_folder+'\\'+NAME_PART])

        if '-mk' in options:
            _exec_cmd(['latexmk', '-pvc', '-pdf', NAME_PART])

        elif '-lmk' in options:
            _exec_cmd(['latexmk', '-pvc', '-lualatex', NAME_PART])

        elif '-fin' in options or '-final' in options or '-rel' in options:
            version = 'release'
            chdir(temp_folder)
            for bib in glob(FOLDER + '/*.bib') + glob(FOLDER + '/**/*.bib'):
                try:
                    copy(bib, path.basename(bib))
                except FileNotFoundError:
                    print('HOHO')
            _exec_cmd(['bibtex', NAME_PART])
            chdir(FOLDER)
            _exec_cmd(command)
            _exec_cmd(command)
        elif '-beta' in options:
            version = 'beta'
            _exec_cmd(command)
        else:
            version = 'alpha'

        move(temp_folder + '/' + NAME_PART + '.pdf', NAME_PART+'.pdf')
        for pdf in glob(NAME_PART + '-*.pdf'):
            try:
                remove(pdf)
            except FileNotFoundError:
                pass
        from datetime import datetime
        new_name = NAME_PART + '-' + datetime.today().strftime('%Y%m%d%a') \
            + '-' + version
        rename(NAME_PART + '.pdf', new_name + '.pdf')
        open_file(new_name + '.pdf')


def markdown():
    css = 'D:/Documents/Code/.res/pandoc.css'
    _exec_cmd(['pandoc', FILE_NAME, '-o', NAME_PART + '.htm', '--standalone', '-c', css])
    open_file(NAME_PART + '.htm')
    if '-del' in LINE_1:
        sleep(1.5)
        remove(NAME_PART + '.htm')


def cpp():
    '''just run it (compile and run)'''

    successful = _exec_cmd(['cl', FILE_NAME])
    if successful:
        _exec_cmd('.\\' + NAME_PART + '.exe')


def javascript():
    '''detect the existence of a package.json and npm run ... else with node'''
    package = glob(CURDIR + '/package.json')
    if package:
        with open(package[0]) as file:
            scripts = list(load(file)['scripts'])
        prompt, letters = f'[{scripts[0]}]', {}
        for cmd in scripts[1:] + ['node']:
            for i, let in enumerate(cmd):
                if let not in letters:
                    letters[let] = cmd
                    prompt += f' {cmd[:i]}({let}){cmd[i+1:]}'
                    break
        script = letters.get(input(prompt)[0], scripts[0])
        cmd = ['node', FILE_NAME] if script == 'node' else ['npm', 'run', script]
    elif ' -i' in LINE_1:
        cmd = ['node', '-i', FILE_NAME]
    else:
        cmd = ['node', FILE_NAME]
    _exec_cmd(cmd)


def generic():
    cmd = LINE_1[1:].replace('%f', FILE_NAME).replace('%n', NAME_PART).strip()
    return _exec_cmd(cmd, True)


def main():
    '''main function'''

    returncode = 0
    extension = path.splitext(FILE_NAME)[1]
    if LINE_1.startswith('$'):
        returncode = generic()
    elif extension == '.py':
        returncode = python()
    elif extension == '.tex':
        latex()
    elif extension == '.cpp':
        cpp()
    elif extension == '.ahk':
        autohotkey()
    elif extension == '.htm' or extension == 'html':
        html()
    elif extension == '.md' or extension == '.pmd':
        markdown()
    elif extension in ['.js', '.jsx', '.svelte']:
        javascript()

    exit(returncode)


if __name__ == '__main__':
    main()
