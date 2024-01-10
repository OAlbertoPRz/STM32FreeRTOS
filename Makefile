# Target
TARGET = main

# Binary 
BINARY = $(TARGET).elf

# Compiler
COMPILER = arm-none-eabi
CC = $(COMPILER)-gcc
AS= $(COMPILER)-as
GDB= $(COMPILER)-gdb

# Linker File
LINKER_FILE = $(DRIVERS_DIR)/STM32CubeF4/Projects/STM32446E-Nucleo/Templates/STM32CubeIDE/STM32F446RETX_FLASH.ld
LDFLAGS = -T $(LINKER_FILE) -u _printf_float

# Programmer
PROGRAMMER = openocd
PROGRAMMER_FLAGS = -f interface/stlink.cfg -f target/stm32f4x.cfg

# Folders path
DRIVERS_DIR = $(PWD)/Drivers
BIN_DIR = $(PWD)/Core/Bin
OBJ_DIR = $(PWD)/Core/Obj
SRC_DIR = $(PWD)/Core/Src
INC_DIR = $(PWD)/Core/Inc

# Include Files Directories
CMSIS_INC_DIR = $(DRIVERS_DIR)/cmsis_device_f4/Include
HAL_INC_DIR = $(DRIVERS_DIR)/stm32f4xx_hal_driver/Inc
FREERTOS_ARCH_DIR = $(DRIVERS_DIR)/FreeRTOS/FreeRTOS/Source/portable/GCC/ARM_CM4F
FREERTOS_INC_DIR = $(DRIVERS_DIR)/FreeRTOS/FreeRTOS/Source/Include

# Source Files Directories
STARTUP_DIR = $(DRIVERS_DIR)/STM32CubeF4/Projects/STM32446E-Nucleo/Templates/STM32CubeIDE/Example/Startup
SYSTEM_UTILITIES_DIR = $(DRIVERS_DIR)/STM32CubeF4/Projects/STM32446E-Nucleo/Templates/STM32CubeIDE/Example/User
CMSIS_TEMPLATES_DIR = $(DRIVERS_DIR)/cmsis_device_f4/Source/Templates
CMSIS_ARCH_DIR = $(DRIVERS_DIR)/cmsis_device_f4/Source/Templates/gcc
HAL_SRC_DIR = $(DRIVERS_DIR)/stm32f4xx_hal_driver/Src
FREERTOS_MEMMANG_DIR = $(DRIVERS_DIR)/FreeRTOS/FreeRTOS/Source/portable/MemMang
FREERTOS_SRC_DIR = $(DRIVERS_DIR)/FreeRTOS/FreeRTOS/Source


# Compiler flags
CFLAGS= \
		-mcpu=cortex-m4 -mthumb --specs=nano.specs \
		-mfloat-abi=hard -mfpu=fpv4-sp-d16 \
		-std=c11

# CPP flags (Only header files)
CPPFLAGS= \
			-DSTM32F446xx \
			-I$(INC_DIR) \
			-I$(CMSIS_INC_DIR) \
			-I$(HAL_INC_DIR) \
			-I$(FREERTOS_ARCH_DIR) \
			-I$(FREERTOS_INC_DIR) \



# Compilation Source flags (Only source files)
CSRCFLAGS= \
			-I$(SRC_DIR) \
			-I$(STARTUP_DIR) \
			-I$(SYSTEM_UTILITIES_DIR) \
			-I$(CMSIS_TEMPLATES_DIR) \
			-I$(CMSIS_ARCH_DIR)
			-I$(HAL_SRC_DIR) \
			-I$(FREERTOS_MEMMANG_DIR) \
			-I$(FREERTOS_SRC_DIR)

# Source Code Collection
SRC= $(wildcard $(SRC_DIR)/*.c)
STARTUP= $(wildcard $(STARTUP_DIR)/*.s)
UTILITIES = $(wildcard $(SYSTEM_UTILITIES_DIR)/*.c)
CMSIS_TEMPLATES= $(wildcard $(CMSIS_TEMPLATES_DIR)/*.s)
CMSIS_ARCH= $(wildcard $(CMSIS_ARCH_DIR)/*.c)
HAL= $(wildcard $(HAL_SRC_DIR)/*.c)
FREERTOS= $(wildcard $(FREERTOS_SRC_DIR)/*.c)
FREERTOS_ARCH= $(wildcard $(FREERTOS_ARCH_DIR)/*.c)
FREERTOS_MEMMANG= $(wildcard $(FREERTOS_MEMMANG_DIR)/*.c)

# Generation of Object Files into Obj folder
SRC_OBJ = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRC))
STARTUP_OBJ = $(patsubst $(STARTUP_DIR)/%.s, $(OBJ_DIR)/%.o, $(STARTUP))
UTILITIES_OBJ = $(patsubst $(SYSTEM_UTILITIES_DIR)/%.c, $(OBJ_DIR)/%.o, $(UTILITIES))
CMSIS_TEMPLATES_OBJ = $(patsubst $(CMSIS_TEMPLATES_DIR)/%.s, $(OBJ_DIR)/%.o, $(CMSIS_TEMPLATES))
CMSIS_ARCH_OBJ = $(patsubst $(CMSIS_ARCH_DIR)/%.c, $(OBJ_DIR)/%.o, $(CMSIS_ARCH))
HAL_OBJ = $(patsubst $(HAL_SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(HAL))
FREERTOS_OBJ = $(patsubst $(FREERTOS_SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(FREERTOS))
FREERTOS_ARCH_OBJ = $(patsubst $(FREERTOS_ARCH_DIR)/%.c, $(OBJ_DIR)/%.o, $(FREERTOS_ARCH))
FREERTOS_MEMMANG_OBJ = $(patsubst $(FREERTOS_MEMMANG_DIR)/%.c, $(OBJ_DIR)/%.o, $(FREERTOS_MEMMANG))

# Object Files command
OBJ= \
		$(SRC_OBJ) \
		$(STARTUP_OBJ) \
		$(UTILITIES_OBJ) \
		$(CMSIS_TEMPLATES_OBJ) \
		$(CMSIS_ARCH_OBJ) \
		$(HAL_OBJ) \
		$(FREERTOS_OBJ) \
		$(FREERTOS_ARCH_OBJ) \
		$(FREERTOS_MEMMANG_OBJ)


########################################################################################################
#									MAKEFILE RULES													   #
########################################################################################################

# Rule to generate the binary (.elf)
build: makedir $(BIN_DIR)/$(BINARY)

$(BIN_DIR)/$(BINARY) : $(OBJ)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -o $@

# Rules to generate file .o file from .c files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(STARTUP_DIR)/%.s
	$(AS) -mcpu=cortex-m4 -o $@ $<

$(OBJ_DIR)/%.o: $(SYSTEM_UTILITIES_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(CMSIS_TEMPLATES_DIR)/%.s
	$(AS) -mcpu=cortex-m4 -o $@ $<

$(OBJ_DIR)/%.o: $(CMSIS_ARCH_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(HAL_SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(FREERTOS_SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(INC_DIRS) -c $< -o $@

$(OBJ_DIR)/%.o: $(FREERTOS_ARCH_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(INC_DIRS) -c $< -o $@

$(OBJ_DIR)/%.o: $(FREERTOS_MEMMANG_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(INC_DIRS) -c $< -o $@

# Rule to generate build folder
makedir:
	mkdir -p $(OBJ_DIR)
	mkdir -p $(BIN_DIR)
	clear

# Rule to reset all files created
reset:
	rm -rf $(OBJ_DIR)/*
	rm -rf $(BIN_DIR)/*

# Rule to clean TARGET.elf
cleanbin:
	rm -rf $(BIN_DIR)/BINARY

# Rule to clean TARGET.o
cleanobj:
	rm -rf $(OBJ_DIR)/$(TARGET).o

# Rule for flashing STM32 board
flash: $(BIN_DIR)/$(BINARY)
	$(PROGRAMMER) $(PROGRAMMER_FLAGS) -c "program $(BIN_DIR)/$(BINARY) verify reset exit"

.PHONY: clean