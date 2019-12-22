'''
My General purpose build script
K1DV5
'''

from sys import argv
from os import chdir, remove, rename, path, startfile, environ, makedirs
from shutil import move, copy
from subprocess import run
from glob import glob
from re import sub, search
from time import sleep

# extract filename from path\to\file\filename.ext in the format filename.ext
FILE_NAME = path.basename(argv[1])
# only filename from filename.ext
NAME_PART = path.splitext(FILE_NAME)[0]
# only folder like C:\path\to\file
FOLDER = path.dirname(path.abspath(argv[1]))
# change working directory to where the file is: folder
chdir(FOLDER)
with open(FILE_NAME, 'r', encoding='utf-8') as file:
    LINE_1 = file.readline()


def pandoc(line, from_fmt):
    '''return the desired format for pandoc if any'''
    if ' -pd(' in line:
        b_ind = line.find('pd(') + len('pd(')
        e_ind = line.find(')', b_ind)
        pd_fmt = '.' + line[b_ind: e_ind]
        run(['pandoc', FILE_NAME, '-f', from_fmt, '-o', NAME_PART + pd_fmt])


def autohotkey():
    '''just run it'''
    startfile(FILE_NAME)


def html():
    startfile(FILE_NAME)


def cython():
    '''if a cython section exists in the file, cythonize that section. If
    it doesn't, cythonize the whole file.
    '''

    # search for embedded cython code commented HTML blocks
    with open(FILE_NAME, 'r') as file:
        embed = search(r'(?s).*# <cython>\n.*\n# </cython>.*', file.read())
    if embed:
        with open(FILE_NAME, 'r+') as file:
            original = file.read()
            # extract cython code
            cycode = sub(
                r'((?s).*# <cython>)(\n.*)(\n# </cython>.*)', r'\2', original)
            # comment the cython code
            cycomment = sub(r'(?s)\n', r'\n# ', cycode)
            # comment the cython code and insert "from .. import *" statement
            changed = sub(r'(?s)(.*)# <cython>\n.*\n# </cython>(.*)',
                          fr'\1# === {NAME_PART}_cy contents: ==={cycomment}'
                          fr'\n# ================='
                          fr'\nfrom {NAME_PART}_cy import * \2', original)
            # remove the cython option
            changed = sub(r'(?<=^# )(-cython|-cy)', '', changed)
            # save the above changes
            file.flush()
            file.write(changed)

        with open(NAME_PART + '_cy.pyx', 'w') as file:
            # save the cython code on a separate .pyx file
            file.write(cycode)
            # compile the cython code
        cmd = ['cythonize', '-i', NAME_PART + '_cy.pyx']

    else:
        # copy the file to a .pyx file
        copy(FILE_NAME, NAME_PART + '_cy.pyx')
        # compile the .pyx file to .pyd
        cmd = ['cythonize', '-i', NAME_PART + '_cy.pyx']
    run(cmd)
    # remove auxiliary files including .pyx
    for aux in glob('*.o') + glob('*.c') + glob('*.def') + glob('*.pyx'):
        remove(aux)


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

    if '-args(' in LINE_1:
        # extract arguments to be passed to the script from first line
        b_ind = LINE_1.find('-args(') + len('-args(')
        e_ind = LINE_1.find(')', b_ind)
        args = LINE_1[b_ind: e_ind].split(' ')
    else:
        args = []

    if ' -cy' in LINE_1 or ' -cython' in LINE_1:
        cython()

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
    print('$', ' '.join(cmd))
    run(cmd)


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

    with open(argv[1], 'r') as file:
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

    successful = not run([command[0], '-interaction=nonstopmode', *command[1:]]).returncode

    if successful:
        if '-py' in options:
            run(['pythontex', temp_folder+'\\'+NAME_PART])

        if '-mk' in options:
            run(['latexmk', '-pvc', '-pdf', NAME_PART])

        elif '-lmk' in options:
            run(['latexmk', '-pvc', '-lualatex', NAME_PART])

        elif '-fin' in options or '-final' in options or '-rel' in options:
            version = 'release'
            chdir(temp_folder)
            for bib in glob(FOLDER + '/*.bib') + glob(FOLDER + '/**/*.bib'):
                try:
                    copy(bib, path.basename(bib))
                except FileNotFoundError:
                    print('HOHO')
            run(['bibtex', NAME_PART])
            chdir(FOLDER)
            run(command)
            run(command)
        elif '-beta' in options:
            version = 'beta'
            run(command)
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
        pandoc(LINE_1, 'latex')
        startfile(new_name + '.pdf')


def markdown():
    run(['pandoc', FILE_NAME, '-o', NAME_PART + '.htm'])
    startfile(NAME_PART + '.htm')
    if '-del' in LINE_1:
        sleep(1.5)
        remove(NAME_PART + '.htm')


def pweave():
    '''-pdf or -cont to typeset the output after weaving
    -pd({type}) to convert the tex file to {type}
    '''

    successful = not run(['pweave', NAME_PART + '.texw']).returncode

    if successful:
        post_fixes = {'_{}': '',
                      '\\mathrm{m \\, N}': '\\mathrm{N \\, m}',
                      '^{1.0}': ''}
        with open(NAME_PART + '.tex', 'r') as file:
            not_fixed = file.read()
        fixed = not_fixed
        for wrng, rght in post_fixes.items():
            fixed = fixed.replace(wrng, rght)
        with open(NAME_PART + '.tex', 'w') as file:
            file.write(fixed)

        pandoc(LINE_1, 'latex')
        if ' -pdf' in LINE_1 or ' -cont' in LINE_1:
            run(['python', argv[0], FOLDER + '\\' + NAME_PART + '.tex'])


def cpp():
    '''just run it (compile and run)'''

    successful = run(['cl', FILE_NAME]).returncode
    if successful:
        run('.\\' + NAME_PART + '.exe', shell=True)


def javascript():
    '''just run it'''

    if ' -i' in LINE_1:
        run(['node', '-i', FILE_NAME])
    else:
        run(['node', FILE_NAME])


def main():
    '''main function'''

    if '-{' in LINE_1:
        b_ind = LINE_1.find('-{') + len('-{')
        e_ind = LINE_1.find('}', b_ind)
        commands = LINE_1[b_ind: e_ind].replace('%f', FILE_NAME).replace('%n', NAME_PART).split('|')
        returncode = 0
        for command in commands:
            print(f'$ {command}')
            returncode = run(command.strip(), shell=True).returncode
            if returncode:
                print('\nPREVIOUS COMMAND EXITED WITH ' + str(returncode))
                break
    elif FILE_NAME.endswith('.py'):
        python()
    elif FILE_NAME.endswith('.tex'):
        latex()
    elif FILE_NAME.endswith('.texw'):
        pweave()
    elif FILE_NAME.endswith('.cpp'):
        cpp()
    elif FILE_NAME.endswith('.ahk'):
        autohotkey()
    elif FILE_NAME.endswith('.htm') or FILE_NAME.endswith('html'):
        html()
    elif FILE_NAME.endswith('.md') or FILE_NAME.endswith('.pmd'):
        markdown()
    elif FILE_NAME.endswith('.js'):
        javascript()


if __name__ == '__main__':
    main()
