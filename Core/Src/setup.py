import subprocess
import os
import glob

CMSIS_URL= "https://github.com/STMicroelectronics/cmsis_device_f4"
CMSIS_NAME= "cmsis_device_f4"



def create_drivers_folder():
    """
    Summary: Creates a new folder into the repository
    Author: Alberto Perez
    Date: 1/5/2024
    """
    if not os.path.exists('./../../Drivers'):
        print('Creating a new folder Drivers..\n\n')
        os.makedirs('./../../Drivers')
    else:
        print('Drivers Folder already exist...\n')


def clone_sparse_repo(repo_url, repo_name):
    """
    Summary: Clones a vanilla without folders repository in its last version
    Author: Alberto Perez
    Date: 1/5/2024
    """
    subprocess.run(['git', 'clone', '--depth', '1','--branch', 'master',
        '--filter=blob:none', '--sparse', repo_url])
    get_new_subfolder(repo_name)
    

def clone_cmsis_library(cmsis_url, cmsis_name):
    """
    Summary: Clones only the required from the cmsis library
    Author: Alberto Perez
    Date: 1/5/2024
    """
    if not os.path.exists(cmsis_name):
        clone_sparse_repo(cmsis_url, cmsis_name)
        subprocess.run(["git", "sparse-checkout", "init", "--cone"])
        subprocess.run(["git", "sparse-checkout", "set", "Include"])
        get_new_subfolder("Include")
        files_to_remove = [file for file in glob.glob('*') if file not in ['stm32f4xx.h', 'system_stm32f4xx.h', 'stm32f446xx.h']]
        subprocess.run (["rm", "-rf"] + files_to_remove)
    else:
        print('CMSIS Driver already included...\n')


def get_new_subfolder(new_dir_name):
    current_url = get_current_folder()
    new_url = current_url + "/" + new_dir_name
    os.chdir(new_url)


def get_current_folder():
    return os.getcwd()


if __name__ == "__main__":

    original_dir = os.getcwd() 
    
    # Creates a new Drivers Folder
    create_drivers_folder()
    os.chdir(original_dir + '/../../Drivers')
    drivers_dir = os.getcwd()
    
    # Clone CMSIS Driver
    clone_cmsis_library(CMSIS_URL, CMSIS_NAME)
    os.chdir(drivers_dir)