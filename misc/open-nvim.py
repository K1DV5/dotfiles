from pynvim import attach
from sys import argv
from subprocess import run

serv_path = "C:/Users/Kidus III/Documents/Code/.res/open-nvim-server" 
try:
    with open(serv_path) as file:
        nvim = attach('socket', path=file.read().strip())
    nvim.command(':call win_gotoid(1000)')
    nvim.command(':e ' + argv[1])
except:
    pass
