from docal import eqn, cal
import keyboard as kb
import re
from tkinter import Tk
from time import sleep

DICT = {}
exec('from math import *', DICT)

GREEK = {
    'α': 'alpha',
    'β': 'beta',
    'γ': 'gamma',
    'η': 'eta',
    'ρ': 'rho',
    'θ': 'theta',
}

def type_it(eq_in):

    eq = eq_in.strip()
    print('  >', eq)
    patt = re.compile(r'\{.*?\}')
    cals = patt.finditer(eq)
    eq = patt.sub('T0E0M0P0C0A0L', eq)
    if 'T0E0M0P0C0A0L' not in eq and eq_in.endswith('!'):
        if eq[:-1]:
            output_eq = cal(eq[:-1], div_symbol='/', working_dict=DICT)
        else:
            output_eq = ''
    else:
        output_eq = eqn(eq, surr=False, div_symbol='/').strip()
        for c in cals:
            output_eq = re.sub(r'\\mathrm\s*\{\s*T0E0M0P0C0A0L\s*\}',
                               cal(c.group(0)[1:-1].strip(), div_symbol='/', working_dict=DICT).replace('\\', '\\\\'),
                               output_eq, 1)
    # remove environments
    output_eq = re.sub(
        r'\\(begin|end)\{(align|split|equation)\}', '', output_eq)
    # for matrices
    output_eq = re.sub(r'\\begin\{matrix\}(.*?)\\end\{matrix\}', '\\1', output_eq).replace('\\\\', '@') 
    # change brackets and ...
    output_eq = output_eq.replace('{', '(').replace('}', ')').replace(
        '\n', ' ').replace('\\,', '')
    # function name in " "
    output_eq = re.sub(r'\\operatorname\s*\(\s*(\w+)\s*\)', '"\\1"', output_eq)
    # mathrm by " "
    output_eq = re.sub(r'\\(mathrm|text) *\((.*?)\)', '"\\2"', output_eq)
    # remove some unnecessary ( )
    output_eq = re.sub(r'\(([ "\\]*\w*?[ "]*)\)', ' \\1', output_eq)
    if '&=' in output_eq:
        output_eq = '\\eqarray(' + output_eq.replace("\\\\ ", "@") + ')'
    # slash by /
    output_eq = re.sub(r'\s*\\slash\s*', '/', output_eq)
    # remove unnecessary spaces
    output_eq = re.sub('\\s*\\(', '(', output_eq)
    output_eq = re.sub('/\\s*', '/', output_eq)
    output_eq = re.sub('\\s*\\^\\s*', '^', output_eq)
    output_eq = re.sub(' +|\\*', ' ', output_eq).replace('\\mathrm', '')

    kb.press_and_release('alt+=')
    sleep(0.3)
    kb.write(output_eq + '   ')
    kb.press_and_release('alt+=')
    # # mark
    # kb.release('ctrl')
    # kb.press_and_release('numlock, home, shift+end, numlock, ctrl+c, right')
    # # get clipboard
    # r = Tk()
    # r.withdraw()
    # now = r.clipboard_get()
    # # print(repr(now))
    # # print(repr(now), '\b'*(len(now) - len(now.rstrip())))
    # # return
    # kb.write('\b'*(len(now) - len(now.rstrip())))
    # kb.press_and_release('alt+=')
    # kb.write(' ')




def replace_lx():

    # mark
    kb.release('ctrl')
    kb.press_and_release('numlock, home, shift+end, numlock')
    # copy
    kb.press_and_release('ctrl+c')
    # get clipboard
    r = Tk()
    r.withdraw()
    input_line = r.clipboard_get()
    right_spaces = len(input_line) - len(input_line.rstrip())
    input_l = input_line.strip()
    ls = input_l.split('  ')
    main_part = ls[-1]
    if len(ls) == 1:
        kb.press_and_release('ctrl+x')
    else:
        kb.press_and_release('right')
        kb.write('\b'*(1 + len(main_part) + right_spaces))
    input_eq = main_part.strip().replace('^', '**')
    input_eq = re.sub(r'(?<=[0-9])( ?[a-df-zA-Z_])', '*\\1', input_eq)
    input_eq = re.sub(r'(?<=[a-zA-Z0-9_]) (?=\d)', '**', input_eq)
    for letter, repl in GREEK.items():
        input_eq = input_eq.replace(letter, repl)
    eqns = input_eq.split('\n')
    try:
        type_it(eqns[0])
        for eq in eqns[1:]:
            kb.press_and_release('enter')
            type_it(eq)
    except Exception as ex:
        print(ex)

    kb.release('ctrl')


kb.add_hotkey('ctrl+space', replace_lx)
print('running...')
kb.wait()
