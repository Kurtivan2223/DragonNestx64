import sys
import os

args = sys.argv

for parent,_,filenames in os.walk(args[1]):
    for name in filenames:
        if name.endswith('.act'):
            f = open(os.path.join(parent, name), 'rb')
            data = f.read(6)
            f.close()
            if(data == b'Eterni'):
                newpath = "\\\\".join(parent.replace(args[1], args[2]).split("\\"))
                if(not os.path.exists(newpath)):
                    os.makedirs(newpath)
                print(os.path.join(parent), name)
                os.system('start /wait 010Editor.exe ' + os.path.join(parent, name) + ' -template:actV6.bt -script:act6to5.1sc:(' + newpath + '\\\\' + name + ') -noui -nowarnings')