import requests
import os
import time
try:
	import clint
except ImportError:
	print("Installing required module: clint\n")
	os.system("python pip install clint")

from clint.textui import progress

def downloadPak(url, file):
    data = requests.get(url, stream=True)
    with open(file, 'wb') as download:
        length = int(data.headers.get('content-length'))
        for chunk in progress.bar(data.iter_content(chunk_size = 1024), expected_size=(length / 1024) + 1):
            if chunk:
                download.write(chunk)
                download.flush()

def downloadMD5(url, file):
    data = requests.get(url, stream=True)
    with open(file, 'wb') as download:
        length = int(data.headers.get('content-length'))
        for chunk in progress.bar(data.iter_content(chunk_size = 1024), expected_size=(length / 1024) + 1):
            if chunk:
                download.write(chunk)
                download.flush()

def downloadTxt(url, file):
    data = requests.get(url, stream=True)
    with open(file, 'wb') as download:
        length = int(data.headers.get('content-length'))
        for chunk in progress.bar(data.iter_content(chunk_size = 1024), expected_size=(length / 1024) + 1):
            if chunk:
                download.write(chunk)
                download.flush()

def main():
    print("Choose Patch Server\n\n[1]Sea\n[2]SDO(Chinese)\n[3]KR(Korea)\n[4]JP(Japan)\n[5]Custom\n\n")
    option = input(": ")
    
    if option == '1':
        url = "http://patchsea.dragonnest.com/Game/DragonNest/Patch/"
    elif option == '2':
        url = "https://lzg.jijiagames.com/dn/ReleaseBuild/Patch/"
    elif option == '3':
        url = "http://patchkr.dragonnest.com/Patch/"
    elif option == '4':
        url = "http://patchjp.dragonnest.com/Game/Patch/"
    elif option == '5':
        url = input("Enter URL: ")
    else:
        print("[Error] There is no such option! Please try again...")
        main()
        
    num = input("Download Patch Starting From: ")
    num2 = input("Up to: ")
    print('\n')
    
    for i in range(int(num), int(num2) + 1):
        num_len = len(num)
        num2_len = len(num2)
        
        if num_len == 1 or num2_len == 1:
            directory = f'0000000{i}'
            url_pak = f'{url}0000000{i}/Patch0000000{i}.pak'
            file_pak = f'0000000{i}\\Patch0000000{i}.pak'
            url_md5 = f'{url}0000000{i}/Patch0000000{i}.pak.MD5'
            file_md5 = f'0000000{i}\\Patch0000000{i}.pak.MD5'
            url_txt = f'{url}0000000{i}/Patch0000000{i}.txt'
            file_txt = f'0000000{i}\\Patch0000000{i}.txt'
        elif num_len == 2 or num2_len == 2:
            directory = f'000000{i}'
            url_pak = f'{url}000000{i}/Patch000000{i}.pak'
            file_pak = f'000000{i}\\Patch000000{i}.pak'
            url_md5 = f'{url}000000{i}/Patch000000{i}.pak.MD5'
            file_md5 = f'000000{i}\\Patch000000{i}.pak.MD5'
            url_txt = f'{url}000000{i}/Patch000000{i}.txt'
            file_txt = f'000000{i}\\Patch000000{i}.txt'
        elif num_len == 3 or num2_len == 3:
            directory = f'00000{i}'
            url_pak = f'{url}00000{i}/Patch00000{i}.pak'
            file_pak = f'00000{i}\\Patch00000{i}.pak'
            url_md5 = f'{url}00000{i}/Patch00000{i}.pak.MD5'
            file_md5 = f'00000{i}\\Patch00000{i}.pak.MD5'
            url_txt = f'{url}00000{i}/Patch00000{i}.txt'
            file_txt = f'00000{i}\\Patch00000{i}.txt'
        elif num_len == 4 or num2_len == 4:
            directory = f'0000{i}'
            url_pak = f'{url}0000{i}/Patch0000{i}.pak'
            file_pak = f'0000{i}\\Patch0000{i}.pak'
            url_md5 = f'{url}0000{i}/Patch0000{i}.pak.MD5'
            file_md5 = f'0000{i}\\Patch0000{i}.pak.MD5'
            url_txt = f'{url}0000{i}/Patch0000{i}.txt'
            file_txt = f'0000{i}\\Patch0000{i}.txt'
        
        os.mkdir(directory)
        print(f'Directory {directory} created')
        
        downloadPak(url_pak, file_pak)
        print(f'Downloaded Patch00000{i}.pak')
        downloadMD5(url_md5, file_md5)
        print(f'Downloaded Patch00000{i}.pak.MD5')
        downloadTxt(url_txt, file_txt)
        print(f'Downloaded Patch00000{i}.txt')
        print('\n\n')

if __name__ == '__main__':
    main()
