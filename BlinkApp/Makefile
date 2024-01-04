CC=arm-none-eabi-gcc
CFLAGS=-mcpu=cortex-m4 -mthumb --specs=nano.specs
CPPFLAGS=-DSTM32F446xx \
				 -I$(PWD)/../CMSIS/Device/ST/STM32F4/Include \
				 -I$(PWD)/../CMSIS/CMSIS/Core/Include

LINKER_FILE=linker_script.ld
LDFLAGS=-T $(LINKER_FILE) -u _printf_float

BINARY = simple_blink.elf

PROGRAMMER = openocd
PROGRAMMER_FLAGS = -f interface/stlink.cfg -f target/stm32f4x.cfg

all: $(BINARY)

$(BINARY): SimpleBlink.o Startup.o system_stm32f4xx.o Syscalls.o Usart.o
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -o $(BINARY)

SimpleBlink.o: SimpleBlink.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -c

Startup.o: Startup.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -c

system_stm32f4xx.o: $(PWD)/../CMSIS/Device/ST/STM32F4/Source/Templates/system_stm32f4xx.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -c

Syscalls.o: Syscalls.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -c

Usart.o: Usart.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -c

.PHONY: clean
clean:
	rm -f *.o *.elf

flash: $(BINARY)
	$(PROGRAMMER) $(PROGRAMMER_FLAGS) -c "program $(BINARY) verify reset exit"