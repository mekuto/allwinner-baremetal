include ../config.mk

BOARD = allwinner-h3

TAG = $(BOARD)-$(PROJECT)
BIN_FILE = $(TAG).bin
LIST_FILE = $(TAG).list
SREC_FILE = $(TAG).srec
ELF_FILE = $(TAG).elf
CMD_FILE = $(TAG).cmd
SCR_FILE = $(TAG).scr

CC = $(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)gcc
AS = $(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)as
OBJDUMP = $(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)objdump
OBJCOPY = $(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)objcopy
LD = $(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)ld

CPUFLAGS += -mfpu=neon-vfpv4 -march=armv7-a -mfloat-abi=hard
ARCHFLAGS += -mtune=cortex-a7 -mhard-float

CFLAGS += $(CPUFLAGS) $(ARCHFLAGS) -Wall -O2 -nostdlib -nostartfiles -ffreestanding
AFLAGS += $(CPUFLAGS)

LDSCRIPT ?= ../_common/$(BOARD).ld

ifdef USES_LIB_H3
LIBS += \
  -L ../_common/rpidmx512/lib-h3/lib_h3 -lh3

LIBS_FILES += \
  ../_common/rpidmx512/lib-h3/lib_h3/libh3.a

INCLUDES += \
  -I ../_common/rpidmx512/lib-h3/include \
  -I ../_common/rpidmx512/lib-h3/include/board
endif

.DEFAULT_GOAL := all

.PHONY: clean
clean:
	rm -f $(OBJECTS) $(BIN_FILE) $(LIST_FILE) $(SREC_FILE) $(ELF_FILE) $(SCR_FILE) $(CMD_FILE)

$(ELF_FILE): $(LDSCRIPT) $(OBJECTS) $(LIBS_FILES)
	@echo LD $<
	@$(LD) $(OBJECTS) $(LIBS) -T $(LDSCRIPT) -o $@

$(CMD_FILE):
	@echo $@
	@/bin/echo -e "setenv image $(PXE_DIR)/$(TAG).bin\ntftpboot 0x42000000 $(PXE_SERVER):\$${image};go 0x42000000" >$(CMD_FILE)

.PHONY: all
all: $(ELF_FILE) $(BIN_FILE) $(LIST_FILE) $(SREC_FILE)

.PHONY: install
install: $(BIN_FILE) $(SCR_FILE)
	scp $(SCR_FILE) $(PXE_DEST)/$(PXE_DIR)/
	scp $(BIN_FILE) $(PXE_DEST)/$(PXE_DIR)/$(TAG).bin

%.o: %.c
	@echo CC $<
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

%.o: %.s
	@echo AS $<
	@$(AS) $< $(AFLAGS) -o $@

%.list: %.elf
	@echo LIST $<
	@$(OBJDUMP) -D $< > $@

%.srec: %.elf
	@echo SREC $<
	@$(OBJCOPY) --srec-forceS3 $< -O srec $@

%.bin: %.elf
	@echo BIN $<
	@$(OBJCOPY) $< -O binary $@

%.scr: %.cmd
	@echo SCR $<
	@mkimage -C none -A arm -T script -d $< $@ >/dev/null

# lib-h3
../_common/rpidmx512/lib-h3/lib_h3/libh3.a:
	@echo compiling lib-h3 library
	@$(MAKE) -C ../_common/rpidmx512/lib-h3 -f Makefile.H3 PREFIX=$(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX) all >/dev/null

# Linux kernel style according to https://www.gnu.org/software/indent/manual/indent.html
linux_style = -nbad -bap -nbc -bbo -hnl -br -brs -c33 -cd33 -ncdb -ce -ci4 -cli0 \
  -d0 -di1 -nfc1 -i8 -ip0 -l80 -lp -npcs -nprs -npsl -sai -saf -saw -ncs -nsc \
  -sob -nfca -cp33 -ss -ts8 -il1
.PHONY: format
format:
	indent $(linux_style) *.c
