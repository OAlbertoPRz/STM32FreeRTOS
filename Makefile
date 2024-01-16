# Target
TARGET = demo
# Project
PROJECT= Demo

# Binary 
BINARY = $(TARGET).elf

# Compiler
COMPILER = arm-none-eabi
CC = $(COMPILER)-gcc
AS= $(COMPILER)-as
GDB= $(COMPILER)-gdb

# Programmer
PROGRAMMER = openocd
PROGRAMMER_FLAGS = -f interface/stlink.cfg -f target/stm32f4x.cfg

# Folders path
DRIVERS_DIR = $(PWD)/Drivers
BIN_DIR = $(PWD)/Core/Bin
OBJ_DIR = $(PWD)/Core/Obj
SRC_DIR = $(PWD)/Core/Src/$(PROJECT)
INC_DIR = $(PWD)/Core/Inc/
PROJECT_DIR = $(PWD)/Core/Inc/$(PROJECT)


# Linker File
STM32_TEMPLATES_DIR = $(DRIVERS_DIR)/STM32CubeF4/Projects/STM32446E-Nucleo/Templates/STM32CubeIDE# 					Has the linker file
LINKER_FILE = $(STM32_TEMPLATES_DIR)/STM32F446RETX_FLASH.ld
LDFLAGS = -T $(LINKER_FILE) -u _printf_float


# Include files directories
CMSIS_CORE_DIR = $(DRIVERS_DIR)/CMSIS/CMSIS/Core/Include
CMSIS_STM_INC_DIR = $(DRIVERS_DIR)/CMSIS/ST/STM32F4/Include
FREERTOS_INC_DIR = $(FREERTOS_SOURCE_DIR)/include
FREERTOS_PORT_DIR = $(FREERTOS_SOURCE_DIR)/portable/GCC/ARM_CM4F# 													Also has source code included
HAL_INC_DIR = $(DRIVERS_DIR)/HAL/Inc


# Source files directories
CMSIS_SYSTEM_DIR = $(DRIVERS_DIR)/CMSIS/ST/STM32F4/Source/Templates
#CMSIS_STARTUP_DIR = $(CMSIS_SYSTEM_DIR)/gcc# 															May be used or not depending the performace
FREERTOS_SOURCE_DIR = $(DRIVERS_DIR)/FreeRTOS/Source
FREERTOS_MEMMANG_DIR = $(FREERTOS_SOURCE_DIR)/portable/MemMang
HAL_SOURCE_DIR = $(DRIVERS_DIR)/HAL/Src
STM32_STARTUP_DIR = $(STM32_TEMPLATES_DIR)/Example/Startup# 											May be used or not depending the performace
STM32_UTILITIES_DIR = $(STM32_TEMPLATES_DIR)/Example/User


# Compiler flags
CFLAGS= \
		-mcpu=cortex-m4 -mthumb --specs=nano.specs \
		-mfloat-abi=hard -mfpu=fpv4-sp-d16 \
		-std=c11

# CPP flags (Only header files)
CPPFLAGS= \
			-DSTM32F446xx \
			-I$(CMSIS_CORE_DIR) \
			-I$(CMSIS_STM_INC_DIR) \
			-I$(FREERTOS_INC_DIR) \
			-I$(FREERTOS_PORT_DIR) \
			-I$(HAL_INC_DIR) \
			-I$(INC_DIR) \
			-I$(PROJECT_DIR)


# Compilation Source flags (Only source files)
# (STM32_STARTUP_DIR) May not be correct one
CSRCFLAGS= \
			-I$(SRC_DIR) \
			-I$(CMSIS_SYSTEM_DIR) \
			-I$(FREERTOS_SOURCE_DIR) \
			-I$(FREERTOS_MEMMANG_DIR) \
			-I$(HAL_SOURCE_DIR) \
			-I$(STM32_STARTUP_DIR) \
			-I$(STM32_UTILITIES_DIR)


# Source Code Collection
SRC= $(wildcard $(SRC_DIR)/*.c)
CMSIS_SYSTEM = $(wildcard $(CMSIS_SYSTEM_DIR)/*.c)
FREERTOS_SOURCE = $(wildcard $(FREERTOS_SOURCE_DIR)/*.c)
FREERTOS_MEMMANG = $(wildcard $(FREERTOS_MEMMANG_DIR)/*.c)
FREERTOS_PORT = $(wildcard $(FREERTOS_PORT_DIR)/*.c)
HAL_SOURCE = $(wildcard $(HAL_SOURCE_DIR)/*.c)
STM32_STARTUP = $(wildcard $(STM32_STARTUP_DIR)/*.s)
STM32_UTILITIES = $(wildcard $(STM32_UTILITIES_DIR)/*.c)


# Generation of Object Files into Obj folder
SRC_OBJ = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRC))
CMSIS_SYSTEM_OBJ = $(patsubst $(CMSIS_SYSTEM_DIR)/%.c, $(OBJ_DIR)/%.o, $(CMSIS_SYSTEM))
FREERTOS_SOURCE_OBJ = $(patsubst $(FREERTOS_SOURCE_DIR)/%.c, $(OBJ_DIR)/%.o, $(FREERTOS_SOURCE))
FREERTOS_MEMMANG_OBJ = $(patsubst $(FREERTOS_MEMMANG_DIR)/%.c, $(OBJ_DIR)/%.o, $(FREERTOS_MEMMANG))
FREERTOS_PORT_OBJ = $(patsubst $(FREERTOS_PORT_DIR)/%.c, $(OBJ_DIR)/%.o, $(FREERTOS_PORT))
HAL_SOURCE_OBJ = $(patsubst $(HAL_SOURCE_DIR)/%.c, $(OBJ_DIR)/%.o, $(HAL_SOURCE))
STM32_STARTUP_OBJ = $(patsubst $(STM32_STARTUP_DIR)/%.s, $(OBJ_DIR)/%.o, $(STM32_STARTUP))
STM32_UTILITIES_OBJ = $(patsubst $(STM32_UTILITIES_DIR)/%.c, $(OBJ_DIR)/%.o, $(STM32_UTILITIES))


# Object Files command
OBJ= \
		$(SRC_OBJ) \
		$(CMSIS_SYSTEM_OBJ) \
		$(FREERTOS_SOURCE_OBJ) \
		$(FREERTOS_MEMMANG_OBJ) \
		$(FREERTOS_PORT_OBJ) \
		$(HAL_SOURCE_OBJ) \
		$(STM32_STARTUP_OBJ) \
		$(STM32_UTILITIES_OBJ)


########################################################################################################
#									MAKEFILE RULES													   #
########################################################################################################
all: build flash

# Rule to generate the binary (.elf)
build: makedir $(BIN_DIR)/$(BINARY)

$(BIN_DIR)/$(BINARY) : $(OBJ)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -o $@


# Rules to generate file .o file from .c files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(CMSIS_SYSTEM_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(FREERTOS_SOURCE_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(FREERTOS_MEMMANG_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(FREERTOS_PORT_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(HAL_SOURCE_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(STM32_UTILITIES_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(STM32_STARTUP_DIR)/%.s
	$(AS) -mcpu=cortex-m4 -o $@ $<


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
clean:
	rm -rf $(BIN_DIR)/$(BINARY)

# Rule to clean TARGET.o
objclean:
	rm -rf $(OBJ_DIR)/$(TARGET).o

# Rule for flashing STM32 board
flash: $(BIN_DIR)/$(BINARY)
	$(PROGRAMMER) $(PROGRAMMER_FLAGS) -c "program $(BIN_DIR)/$(BINARY) verify reset exit"

.PHONY: clean
