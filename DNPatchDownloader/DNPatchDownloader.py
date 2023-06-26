import os
import time
import subprocess
import sys
import urllib
import re
import requests
import ctypes
import subprocess
# from clint.textui import progress
from rich.progress import Progress

#############################################################
#                      UNITS MAPPING                        #
#############################################################

UNITS_MAPPING = [
    (1<<50, ' PB'),
    (1<<40, ' TB'),
    (1<<30, ' GB'),
    (1<<20, ' MB'),
    (1<<10, ' KB'),
    (1, (' byte', ' bytes')),
]

def BytesFormatter(bytes, units=UNITS_MAPPING):
    for factor, suffix in units:
        if bytes >= factor:
            break
    amount = int(bytes / factor)

    if isinstance(suffix, tuple):
        singular, multiple = suffix
        if amount == 1:
            suffix = singular
        else:
            suffix = multiple
    return str(amount) + suffix


# Version 1
# def downloadPak(url, file):
#     data = requests.get(url, stream=True)
#     with open(file, 'wb') as download:
#         length = int(data.headers.get('content-length'))
#         for chunk in progress.bar(data.iter_content(chunk_size = 1024), expected_size=(length / 1024) + 1):
#             if chunk:
#                 download.write(chunk)
#                 download.flush()

# Version 2
# def downloadPak(url, file, description = ""):
#     response = requests.get(url, stream=True)
#     length = int(response.headers.get('content-length'))
#     size = 0

#     with open(file, 'wb') as download:

#         progress = Progress()
#         task = progress.add_task(description, total = length)
#         progress.start()
        
#         for data in response.iter_content(chunk_size = 4096):
#             size += len(data)
#             download.write(data)
#             progress.update(task, completed = size)

#         progress.stop()

# Version 2.1
def downloadPak(url, file, description = ""):
    response = requests.get(url, stream=True)
    length = int(response.headers.get('content-length'))
    size = 0

    with open(file, 'wb') as download:

        progress = Progress()
        task = progress.add_task("[cyan]{task.description}", total = length, completed = size)
        progress.start()
        
        #for data in response.iter_content(chunk_size = 4096):
        for data in response.iter_content(chunk_size = 1024):
            size += len(data)
            download.write(data)
            progress.update(task, completed = size, description = f"{description} " + BytesFormatter(size) + " / " + BytesFormatter(length))
            
        progress.stop()
                
def CheckVersion():
    cfg = open('Version.cfg', 'r').read()
    version = re.sub("Version ", "", cfg)
    version = re.sub("\nModule 0\x00", "", version)
    return int(version)
    
def CheckServerVersion():
    request = urllib.request.Request(url = "{ your url }PatchInfoServer.cfg", headers = {'User-Agent': 'Mozilla/5.0'})
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

def Admin():
    #rerun program as administrator
    if ctypes.windll.shell32.IsUserAnAdmin():
        pass
    else:
        ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, __file__, None, 1)
        exit(0)

def main():
    Admin()

    url = "{ your url }"
    ClientPatch = CheckVersion()
    ServerPatch = CheckServerVersion()
    
    Check()
    
    for i in range(int(ClientPatch), int(ServerPatch) + 1):
        ClientPatchLength = len(str(ClientPatch))
        ServerPatchLength = len(str(ServerPatch))
        
        if ClientPatchLength == 1 or ServerPatchLength == 1:
            urlFile = f'{url}0000000{i}/Patch0000000{i}.pak'
            file = f'Patch0000000{i}.pak'
        elif ClientPatchLength == 2 or ServerPatchLength == 2:
            urlFile = f'{url}000000{i}/Patch000000{i}.pak'
            file = f'Patch000000{i}.pak'
        elif ClientPatchLength == 3 or ServerPatchLength == 3:
            urlFile = f'{url}00000{i}/Patch00000{i}.pak'
            file = f'Patch00000{i}.pak'
        elif ClientPatchLength == 4 or ServerPatchLength == 4:
            urlFile = f'{url}0000{i}/Patch0000{i}.pak'
            file = f'Patch0000{i}.pak'
        
        downloadPak(urlFile, file, f"Patch {i}")

    Run()

if __name__ == '__main__':
    main()
