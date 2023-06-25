import os
import time
import subprocess
import sys
import urllib
import re
import requests
import ctypes
import subprocess
from clint.textui import progress

def downloadPak(url, file):
    data = requests.get(url, stream=True)
    with open(file, 'wb') as download:
        length = int(data.headers.get('content-length'))
        for chunk in progress.bar(data.iter_content(chunk_size = 1024), expected_size=(length / 1024) + 1):
            if chunk:
                download.write(chunk)
                download.flush()
                
def CheckVersion():
    cfg = open('Version.cfg', 'r').read()
    version = re.sub("Version ", "", cfg)
    version = re.sub("\nModule 0\x00", "", version)
    return int(version)
    
def CheckServerVersion():
    request = urllib.request.Request(url = "https://play.luminousdn.com/GX/PatchInfoServer.cfg", headers = {'User-Agent': 'Mozilla/5.0'})
    cfg = urllib.request.urlopen(request).read().decode("ASCII")
    version = re.sub("Version ", "", cfg)
    return int(version)

def Check():
    if int(CheckVersion()) == int(CheckServerVersion()):
        ctypes.windll.user32.MessageBoxW(None, "Client is already in the Latest Version", "DNPatchDownloader", 0)
        Run()
    elif int(CheckVersion()) > int(CheckServerVersion()):
        ctypes.windll.user32.MessageBoxW(None, "Please reinstall the client!", "DNPatchDownloader", 0)
        exit(1)

def Run():
    subprocess.Popen(r"dnlauncher.exe")
    exit(0)

def main():
    #rerun program as administrator
    if ctypes.windll.shell32.IsUserAnAdmin():
        pass
    else:
        ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, __file__, None, 1)
        exit(0)

    url = "https://play.luminousdn.com/GX/"
    ClientPatch = CheckVersion()
    ServerPatch = CheckServerVersion()
    
    Check()
    
    for i in range(int(ClientPatch), int(ServerPatch) + 1):
        ClientPatchLength = len(str(ClientPatch))
        ServerPatchLength = len(str(ServerPatch))
        
        if ClientPatchLength == 1 or ServerPatchLength == 1:
            url = f'{url}0000000{i}/Patch0000000{i}.pak'
            file = f'Patch0000000{i}.pak'
        elif ClientPatchLength == 2 or ServerPatchLength == 2:
            url = f'{url}000000{i}/Patch000000{i}.pak'
            file = f'Patch000000{i}.pak'
        elif ClientPatchLength == 3 or ServerPatchLength == 3:
            url = f'{url}00000{i}/Patch00000{i}.pak'
            file = f'Patch00000{i}.pak'
        elif ClientPatchLength == 4 or ServerPatchLength == 4:
            url = f'{url}0000{i}/Patch0000{i}.pak'
            file = f'Patch0000{i}.pak'
        
        downloadPak(url, file)
        print(f'Downloaded Patch {i}')

    Run()

if __name__ == '__main__':
    main()