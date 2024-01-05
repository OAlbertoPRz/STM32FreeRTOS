# Binary 
BINARY = main.elf

# Folders path
DRIVERS_DIR = $(PWD)/Drivers
BIN_DIR = $(PWD)/Bin
OBJ_DIR = $(PWD)/Obj
SRC_DIR = $(PWD)/Core/Src
INC_DIR = $(PWD)/Core/Inc
STARTUP_DIR = $(PWD)/Core/Startup

HAL_SRC_DIR = $(DRIVERS_DIR)/stm32f4xx_hal_driver/Src
HAL_INC_DIR = $(DRIVERS_DIR)/stm32f4xx_hal_driver/Inc

# Get all .c in the Hal Directory
HAL_SRCS := $(wildcard $(HAL_SRC_DIR)/*.c)

# Generates all the object files into a object directory
OBJS := $(patsubst $(SRC_DIR)/%.c $(HAL_SRCS) ,$(OBJ_DIR)/%.o,$(HAL_SRCS))

# Compiler
COMPILER = arm-none-eabi
CC = $(COMPILER)-gcc

# Compiler flags
CFLAGS=-mcpu=cortex-m4 -mthumb --specs=nano.specs

# CPP flags
CPPFLAGS=-DSTM32F446xx \
				 -I$(DRIVERS_DIR)/CMSIS/Device/ST/STM32F4/Include \
				 -I$(DRIVERS_DIR)/CMSIS/CMSIS/Core/Include \
				 



# Programmer
PROGRAMMER = openocd
PROGRAMMER_FLAGS = -f interface/stlink.cfg -f target/stm32f4x.cfg


all: $(BINARY)

$(BINARY): $(OBJS)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -o $(BINARY)

$(OBJ_DIR)/main.o: $(SRC_DIR)/main.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -c

$(OBJ_DIR)/startup.o: $(STARTUP_DIR)/sartup_stm32f4xx.s
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -c

$(OBJ_DIR)/system_stm32f4xx.o: $(STARTUP_DIR)/system_stm32f4xx.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -c

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) -I$(HAL_INC_DIR) -c $< -o $@