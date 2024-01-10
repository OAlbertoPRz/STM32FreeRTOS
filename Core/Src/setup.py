import subprocess
import os
import glob

CMSIS_URL= "https://github.com/STMicroelectronics/cmsis_device_f4"
CMSIS_NAME= "cmsis_device_f4"

SMTCUBE_URL = "https://github.com/STMicroelectronics/STM32CubeF4"
SMTCUBE_NAME = "STM32CubeF4"

FREERTOS_URL = "https://github.com/FreeRTOS/FreeRTOS"
FREERTOS_NAME = "FreeRTOS"

HAL_URL = "https://github.com/STMicroelectronics/stm32f4xx_hal_driver"
HAL_NAME = "stm32f4xx_hal_driver"

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


def get_new_subfolder(new_dir_name):
    current_url = get_current_folder()
    new_url = current_url + "/" + new_dir_name
    os.chdir(new_url)


def get_current_folder():
    return os.getcwd()


def clone_sparse_repo(repo_url, repo_name):
    """
    Summary: Clones a vanilla without folders repository in its last version
    Author: Alberto Perez
    Date: 1/5/2024
    """
    subprocess.run(['git', 'clone', '--depth', '1','--branch', 'master',
        '--filter=blob:none', '--sparse', repo_url])
    get_new_subfolder(repo_name)
    

def clone_CMSIS_Driver(cmsis_url, cmsis_name):
    """
    Summary: Clones only the required from the CMSIS Drivers
    Author: Alberto Perez
    Date: 1/5/2024
    """
    if not os.path.exists(cmsis_name):
        clone_sparse_repo(cmsis_url, cmsis_name)
        subprocess.run(["git", "sparse-checkout", "init", "--cone"])
        subprocess.run(["git", "sparse-checkout", "set", "Include",  "Source/Templates/gcc"])
        get_new_subfolder("Include")
        files_to_remove = [file for file in glob.glob('*') if file not in ['stm32f4xx.h', 'system_stm32f4xx.h', 'stm32f446xx.h']]
        subprocess.run (["rm", "-rf"] + files_to_remove)
        get_new_subfolder("../Source/Templates/gcc")
        files_to_remove = [file for file in glob.glob('*') if file not in ['startup_stm32f446xx.s']]
        subprocess.run (["rm", "-rf"] + files_to_remove)
    else:
        print('CMSIS Driver already included...\n')


def clone_STMCube_Drivers(STMCube_url, STMCube_name):
    """
    Summary: Clones only the required from the STMCube Drivers
    Author: Alberto Perez
    Date: 1/9/2024
    """
    if not os.path.exists(STMCube_name):
        clone_sparse_repo(STMCube_url, STMCube_name)
        subprocess.run(["git", "sparse-checkout", "init", "--cone"])
        subprocess.run(["git", "sparse-checkout", "set", "Projects/STM32446E-Nucleo/Templates/STM32CubeIDE/Example/Startup",
                        "Projects/STM32446E-Nucleo/Templates/STM32CubeIDE/Example/User"])
    else:
        print('STMCube Drivers already included...\n')


def clone_FreeRTOS_Drivers(Free_RTOS_url, Free_RTOS_name):
    """
    Summary: Clones only the required from the STMCube Drivers
    Author: Alberto Perez
    Date: 1/9/2024
    """
    if not os.path.exists(Free_RTOS_name):
        subprocess.run(["git", "clone", "--recursive", Free_RTOS_url])
        get_new_subfolder(Free_RTOS_name)
        subprocess.run(["rm", "-rf", "FreeRTOS-Plus"])
    else:
        print('FreeRTOS Drivers already included...\n')


def clone_STMHAL_Drivers(Hal_url, Hal_name):
    """
    Summary: Clones only the required from the STMCube Drivers
    Author: Alberto Perez
    Date: 1/9/2024
    """
    if not os.path.exists(Hal_name):
        clone_sparse_repo(Hal_url, Hal_name)
        subprocess.run(["git", "sparse-checkout", "init", "--cone"])
        subprocess.run(["git", "sparse-checkout", "set", "Inc", "Src"])
    else:
        print('STMHAL Drivers already included...\n')


if __name__ == "__main__":
    original_dir = os.getcwd() 
    
    # Creates a new Drivers Folder
    create_drivers_folder()
    os.chdir(original_dir + '/../../Drivers')
    drivers_dir = os.getcwd()
    
    # Clone CMSIS Drivers
    clone_CMSIS_Driver(CMSIS_URL, CMSIS_NAME)
    os.chdir(drivers_dir)

    #Clone STM32 HAL Drivers
    clone_STMHAL_Drivers(HAL_URL, HAL_NAME)
    os.chdir(drivers_dir)

    # Clone SMTCube Drivers
    clone_STMCube_Drivers(SMTCUBE_URL, SMTCUBE_NAME)
    os.chdir(drivers_dir)

    # Clone FreeRTOS Drivers
    clone_FreeRTOS_Drivers(FREERTOS_URL, FREERTOS_NAME)
    os.chdir(drivers_dir)
