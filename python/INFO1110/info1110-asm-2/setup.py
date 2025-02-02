'''
Write your solution for 6. PIAT: Check Setup here.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''
import sys
import os
import shutil
from datetime import datetime


def current_time():
    current_time = datetime.now()
    formatted_time = current_time.strftime("%d %b %Y %H:%M:%S")
    return formatted_time


def installation(master: str, timestamp: str) -> list:
    install_lst = []
    install_lst.append(f"{timestamp} Start installation process.")
    install_lst.append(f"{timestamp} Extracting paths in configuration file.")
    directory_path = os.listdir(master)
    i = 0
    while i < len(directory_path):
        if directory_path[i] == 'config.txt':
            path = f"{master}{directory_path[i]}"
            with open(path, 'r') as configuration:
                find_folder = configuration.read().split()
                j = 0
                s = 0
                count = 0
                folder_lst = []
                file_lst = []
                while j < len(find_folder):
                    find_files = False
                    # find line start and end with "/"
                    if find_folder[j].strip().startswith('/') and find_folder[j].strip().endswith('/'):
                        folder_line = find_folder[j]
                        count += 1
                        folder_lst.append(folder_line)
                        find_files = True
                        s += 1
                        files_in_folder = []
                    while find_files and s < len(find_folder):
                        if find_folder[s].strip().startswith('./'):
                            # remove "./"
                            file_line = find_folder[s].replace("./", "")
                            files_in_folder.append(file_line)
                        else:
                            break
                        s += 1
                    file_lst.append(files_in_folder)
                    j += 1
        i += 1
    new_file_lst = []
    g = 0
    while g < len(file_lst):
        sublst = file_lst[g]
        r = 0
        found = False
        while r < len(new_file_lst):
            if new_file_lst[r] == sublst:
                found = True
                break
            r += 1
        if not found:
            new_file_lst.append(sublst)
        g += 1
    install_lst.append(f"Total directories to create: {count}")
    install_lst.append(f"{timestamp} Create new directories.")
    k = 0
    while k < len(folder_lst):
        if os.path.exists(folder_lst[k]):
            install_lst.append(
                f"{folder_lst[k]} exists. Skip directory creation.")
        else:
            install_lst.append(f"{folder_lst[k]} is created successfully.")
            os.mkdir(folder_lst[k])
        k += 1
    install_lst.append(
        f"{timestamp} Extracting paths of all files in {master}.")
    '''
    retrieve the contents in current directory path as a string, 
    a list of subdirectories in the current directory and 
    a list of filenames in the current directory and 
    assisgn to a list variable master_content
    '''
    master_content = next(os.walk(master))
    # sort in ascending order
    folder_name = sorted(master_content[1])
    t = 0
    file_path = []
    while t < len(folder_name):
        # combine two paths into a new path
        file_path.append(os.path.join(master_content[0], folder_name[t]))
        t += 1
    y = 0
    folder_content = []
    while y < len(file_path):
        folder_content.append(next(os.walk(file_path[y])))
        y += 1
    files = []
    p = 0
    while p < len(folder_content):
        files.append(folder_content[p][2])
        files[p] = sorted(files[p])
        m = 0
        while m < len(files[p]):
            origin_file = files[p][m]
            if str(origin_file).endswith(".txt"):
                install_lst.append(f"Found: {file_path[p]}/{origin_file}")
            m += 1
        p += 1
    install_lst.append(f"{timestamp}  Create new files.")
    h = 0
    while h < len(folder_lst):
        folder_path = folder_lst[h]
        q = 0
        create_path = []
        while q < len(new_file_lst[h]):
            file_folder = new_file_lst[h][q]
            install_lst.append(f"Creating file: {folder_path}{file_folder}")
            create_path.append(f"{folder_path}{file_folder}")
            with open(f"{folder_path}{file_folder}", 'a') as install_files:
                install_files.close()
            q += 1
        h += 1
    install_lst.append(f"{timestamp} Copying files.")
    f = 0
    while f < len(folder_lst):
        # split folder name and path
        new_path, new_folder = os.path.split(folder_lst[f].rstrip('/'))
        old_path, old_folder = os.path.split(file_path[f].rstrip('/'))
        l = 0
        while l < len(new_file_lst[f]):
            file_name = new_file_lst[f][l]
            install_lst.append(f"Locating: {file_name}")
            if os.path.exists(f"{old_path}/{new_folder}/{file_name}"):
                install_lst.append(
                    f"Original path: {old_path}/{new_folder}/{file_name}")
                install_lst.append(
                    f"Destination path: {new_path}/{new_folder}/{file_name}")
                shutil.copyfile(f"{old_path}/{new_folder}/{file_name}",
                                f"{new_path}/{new_folder}/{file_name}")
                install = True
            else:
                install_lst.append(
                    f"Original path: {old_path}/{new_folder}/{file_name} is not found.")
                install = False
            l += 1
        f += 1
    if install:
        install_lst.append(f"{timestamp}  Installation complete.")
    else:
        install_lst.append("Installation error...")
    return install_lst


def verification(master: str, timestamp: str) -> list:
    verify_lst = []
    verify_lst.append(f"{timestamp} Start verification process.")
    verify_lst.append(f"{timestamp} Extracting paths in configuration file.")
    directory_check = os.listdir(master)
    a = 0
    while a < len(directory_check):
        if directory_check[a] == 'config.txt':
            path = f"{master}{directory_check[a]}"
            with open(path, 'r') as configuration:
                find_foldername_in_config = configuration.read().split()
                b = 0
                c = 0
                count = 0
                check_folder_lst = []
                check_file_lst = []
                while b < len(find_foldername_in_config):
                    find_files = False
                    if find_foldername_in_config[b].strip().startswith('/') and find_foldername_in_config[b].strip().endswith('/'):
                        check_folder_line = find_foldername_in_config[b]
                        count += 1
                        check_folder_lst.append(check_folder_line)
                        find_files = True
                        c += 1

                        folder_files = []
                    while find_files and c < len(find_foldername_in_config):
                        if find_foldername_in_config[c].strip().startswith('./'):
                            check_file_line = find_foldername_in_config[c].replace(
                                "./", "")
                            folder_files.append(check_file_line)
                        else:
                            break
                        c += 1
                    check_file_lst.append(folder_files)
                    b += 1
        a += 1
    new_check_file_lst = []
    d = 0
    while d < len(check_file_lst):
        sublst = check_file_lst[d]
        e = 0
        found = False
        while e < len(new_check_file_lst):
            if new_check_file_lst[e] == sublst:
                found = True
                break
            e += 1
        if not found:
            new_check_file_lst.append(sublst)
        d += 1
    verify_lst.append(f"Total directories to check: {count}")
    verify_lst.append(f"{timestamp} Checking if directories exists.")
    f = 0
    while f < len(check_folder_lst):
        if os.path.exists(check_folder_lst[f]):
            verify_lst.append(f"{check_folder_lst[f]} is found!")
        f += 1
    g = 0
    new_files_path = []
    while g < len(check_folder_lst):
        new_folder_path = check_folder_lst[g]
        h = 0
        while h < len(new_check_file_lst[g]):
            file_in_folder = new_check_file_lst[g][h]
            new_files_path.append(f"{new_folder_path}{file_in_folder}")
            h += 1
        g += 1
    verify_lst.append(f"{timestamp} Extracting files in configuration file.")
    i = 0
    num = 0
    while i < len(new_files_path):
        verify_lst.append(f"File to check: {new_files_path[i]}")
        num += 1
        i += 1
    verify_lst.append(f"Total files to check: {num}")
    verify_lst.append(f"{timestamp} Checking if files exists.")
    j = 0
    while j < len(new_files_path):
        if os.path.isfile(new_files_path[j]) is True:
            verify_lst.append(f"{new_files_path[j]} found!")
        j += 1
    verify_lst.append(f"{timestamp} Check contents with master copy.")
    check_master_content = next(os.walk(master))
    folder_name = sorted(check_master_content[1])
    k = 0
    old_path = []
    while k < len(folder_name):
        old_path.append(os.path.join(check_master_content[0], folder_name[k]))
        k += 1
    l = 0
    folder_content = []
    while l < len(old_path):
        folder_content.append(next(os.walk(old_path[l])))
        l += 1
    files = []
    m = 0
    file_num = 0
    while m < len(folder_content):
        files.append(folder_content[m][2])
        files[m] = sorted(files[m])
        n = 0
        while n < len(files[m]):
            origin_file = files[m][n]
            if str(origin_file).endswith(".txt") and file_num < len(new_files_path):
                old_files_path = f"{old_path[m]}/{origin_file}"
                with open(old_files_path, 'r') as old_file, open(new_files_path[file_num], 'r') as new_file:
                    old_line = old_file.readline().strip()
                    new_line = new_file.readline().strip()
                    p = 0
                    while old_line or new_line:
                        if old_line == new_line:
                            check = True
                        else:
                            check = False
                            break
                        p += 1
                        old_line = old_file.readline().strip()
                        new_line = new_file.readline().strip()
                    if check is True:
                        verify_lst.append(
                            f"{new_files_path[file_num]} is same as {old_files_path}: True")
                        file_num += 1
                        n += 1
                        continue
                    else:
                        q = 0
                        with open(old_files_path, 'r') as old_file, open(new_files_path[file_num], 'r') as new_file:
                            old_lines = old_file.read().lower().strip().split()
                            new_lines = new_file.read().lower().strip().split()
                        while q < p:
                            verify_lst.append(
                                f"File name: {new_files_path[file_num]}, {new_lines[q]}, {old_lines[q]}")
                            q += 1
                        if new_line != old_line:
                            verify_lst.append(
                                f"File name: {new_files_path[file_num]}, {new_line}, {old_line}")
                            verify_lst.append("Abnormalities detected...")
                            return verify_lst
            break
        m += 1
    verify_lst.append(f"{timestamp}  Verification complete.")
    return verify_lst


def logging(logs: list, date: str, time: str) -> None:
    current_path = os.getcwd()
    store_file_path = f"{current_path}/logs/{date}"
    if not os.path.exists(store_file_path):
        os.makedirs(store_file_path)
    with open(f"{store_file_path}/{time}.txt", 'w') as log_file:
        o = 0
        while o < len(logs):
            log_file.write(f"{logs[o]}\n")
            o += 1


def main(master: str, flags: str, timestamp: str):
    dt = datetime.strptime(timestamp, "%d %b %Y %H:%M:%S")
    date_str = dt.strftime('%Y-%b-%d')
    time_str = dt.strftime('%H_%M_%S')
    if flags == '-i':
        install = installation(master, timestamp)
        i = 0
        while i < len(install):
            print(install[i])
            i += 1
    elif flags == '-v':
        verify = verification(master, timestamp)
        j = 0
        while j < len(verify):
            print(verify[j])
            j += 1
    elif flags == '-vl' or flags == '-lv':
        k = 0
        verify = verification(master, timestamp)
        while k < len(verify):
            print(verify[k])
            k += 1
        logging(verify, date_str, time_str)
    elif flags == '-il' or flags == '-li':
        x = 0
        install = installation(master, timestamp)
        while x < len(install):
            print(install[x])
            x += 1
        logging(install, date_str, time_str)
    else:
        if len(set(flags)) != len(flags):
            sys.stderr.write("Invalid flag. Each character must be unique.\n")
        elif flags[0] != '-':
            sys.stderr.write("Invalid flag. Flag must start with '-'.\n")
        elif flags == '-iv' or flags == '-vi':
            sys.stderr.write(
                "Invalid flag. Choose verify or install process not both.\n")
        elif flags == '-l':
            sys.stderr.write(
                "Invalid flag. Log can only run with install or verify.\n")
        else:
            sys.stderr.write(
                "Invalid flag. Character must be a combination of 'v' or 'i' and 'l'.\n")


if __name__ == "__main__":
    # assign command line to a variable
    content = sys.argv
    master_loc = content[1]
    # check path exists or not
    if os.path.exists(master_loc):
        if len(content) >= 3:
            flags = content[2]
        elif len(content) < 3:
            flags = '-il'
        # function includes command-line arguments
        main(master_loc, flags, current_time())
    else:
        # stderr: standard error stream to report an error
        sys.stderr.write("Invalid master directory.\n")

