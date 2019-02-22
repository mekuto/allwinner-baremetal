include ../config.mk

BOARD = allwinner-h3

TAG = $(BOARD)-$(PROJECT)
BIN_FILE = $(TAG).bin
LIST_FILE = $(TAG).list
SREC_FILE = $(TAG).srec
ELF_FILE = $(TAG).elf
CMD_FILE = $(TAG).cmd
SCR_FILE = $(TAG).scr

CC = $(TOOLCHAIN)/bin/arm-eabi-gcc
AS = $(TOOLCHAIN)/bin/arm-eabi-as
OBJDUMP = $(TOOLCHAIN)/bin/arm-eabi-objdump
OBJCOPY = $(TOOLCHAIN)/bin/arm-eabi-objcopy
LD = $(TOOLCHAIN)/bin/arm-eabi-ld

CFLAGS = -Wall -O2 -nostdlib -nostartfiles -ffreestanding

LDSCRIPT ?= ../_common/$(BOARD).ld

.DEFAULT_GOAL := all

.PHONY: clean
clean:
	rm -f $(OBJECTS) $(BIN_FILE) $(LIST_FILE) $(SREC_FILE) $(ELF_FILE) $(SCR_FILE) $(CMD_FILE)

$(ELF_FILE): $(LDSCRIPT) $(OBJECTS)
	@echo LD $<
	$(LD) $(OBJECTS) -T $(LDSCRIPT) -o $@

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
	@$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	@echo AS $< $(ARMGNU)
	@$(AS) $< -march=armv7a -mfpu=vfp -o $@

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
