'''
deletes the duplicate files : base file and similar files numbered like filename (5).ext
choosing the file with the biggest size
'''
from glob import glob
from os import rename, path, remove

def rem_nums(file):
    name_part, ext = path.splitext(file)
    if name_part[-4:-2] == ' (' and name_part[-2].isdigit() and name_part[-1] == ')':
        rename(file, name_part[:-4] + ext)

def del_dups(file_ls):
    dups = []
    for file in file_ls:
        name_part, ext = path.splitext(file)
        similar = glob(name_part + ' (?)' + ext)
        if similar:
            dups.append([file, *similar])

    for sim in dups:
        sizes = [path.getsize(file) for file in sim]
        biggest = sim[sizes.index(max(sizes))]
        sim.remove(biggest)
        print(f'biggest is {biggest}')
        for dup in sim:
            remove(dup)
            rem_nums(biggest)

del_dups(glob('*.*'))
# for f in glob('*.*'):
#     rem_nums(f)
