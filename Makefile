#enable only project built with command below
# scons mode=debug mcu=f4 hse=8000000 float=hard

vpath %.h include
vpath %.hpp include

#change it to your stm32plus path
STM32PLUSPATH=../../../InstallDir/stm32plus/stm32plus
LIBPATH=$(STM32PLUSPATH)/lib/build/debug-f4-8000000-hard/libstm32plus-debug-f4-8000000-hard.a
CXX=arm-none-eabi-g++
CC=arm-none-eabi-gcc
AS=arm-none-eabi-as
SIZE=arm-none-eabi-size
OBJDUMP=arm-none-eabi-objdump
OBJCOPY=arm-none-eabi-objcopy
CFLAGS=-Wall -Werror -ffunction-sections -fdata-sections -fno-exceptions -mthumb -gdwarf-2 -pipe -DHSE_VALUE=8000000 -mcpu=cortex-m4 -DSTM32PLUS_F4 -mfloat-abi=hard -O0 -g3
CXXFLAGS=-Wextra -pedantic-errors -fno-rtti -std=gnu++11 -fno-threadsafe-statics -Wall -Werror -ffunction-sections -fdata-sections -fno-exceptions -mthumb -gdwarf-2 -pipe -DHSE_VALUE=8000000 -mcpu=cortex-m4 -DSTM32PLUS_F4 -mfloat-abi=hard -O0 -g3
CPPFLAGS=-I$(STM32PLUSPATH)/lib/include -I$(STM32PLUSPATH)/lib/include/stl -I$(STM32PLUSPATH)/lib -Iinclude
ASFLAGS=-mcpu=cortex-m4
LDFLAGS=-Xlinker --gc-sections -mthumb -g3 -gdwarf-2 -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -Tsrc/Linker.ld -Wl,-wrap,__aeabi_unwind_cpp_pr0 -Wl,-wrap,__aeabi_unwind_cpp_pr1 -Wl,-wrap,__aeabi_unwind_cpp_pr2
SIZEFLAGS=--format=berkeley
#elf filename
PROG=build/prog
#source codes
SRCS_C=$(wildcard src/*.c)
SRCS_CPP=$(wildcard src/*.cpp)
SRCS_ASM=$(wildcard src/*.asm)
OBJS_C=$(patsubst src/%.c,build/%.o,$(SRCS_C) )
OBJS_CPP=$(patsubst src/%.cpp,build/%.o,$(SRCS_CPP) )
OBJS_ASM=$(patsubst src/%.asm,build/%.o,$(SRCS_ASM) )
OBJS=$(OBJS_C) $(OBJS_CPP) $(OBJS_ASM)
DEPS_C=$(patsubst src/%.c,build/%.d,$(SRCS_C) )
DEPS_CPP=$(patsubst src/%.cpp,build/%.d,$(SRCS_CPP) )
DEPS=$(DEPS_C) $(DEPS_CPP)

.PHONY: all clean
all: $(PROG).elf $(PROG).size $(PROG).lst $(PROG).hex $(PROG).bin
	@echo Make Complete!
-include $(DEPS)
$(PROG).elf: $(OBJS)
	$(CXX) -o $@ $(LDFLAGS) $^ $(LIBPATH)
$(PROG).size: $(PROG).elf 
	$(SIZE) $(SIZEFLAGS) $< | tee $@ 
$(PROG).lst: $(PROG).elf
	$(OBJDUMP) -h -S $< > $@
$(PROG).hex: $(PROG).elf 
	$(OBJCOPY) -O ihex $< $@
$(PROG).bin: $(PROG).elf 
	$(OBJCOPY) -O binary $< $@
build/System.o: src/System.c 
	$(CC) -MMD -MP -MF $(patsubst src/%.c,build/%.d,$<) -o $@ -c $(CFLAGS) $(CPPFLAGS) $<
build/Startup.o: src/Startup.asm
	$(AS) $(ASFLAGS) -o $@ $<
build/%.o: src/%.cpp 
	$(CXX) -MMD -MP -MF $(patsubst src/%.cpp,build/%.d,$<) -o $@ -c $(CXXFLAGS) $(CPPFLAGS) $<
clean:
	$(RM) build/*.o build/*.d build/*.elf build/*.size build/*.lst build/*.hex build/*.bin

