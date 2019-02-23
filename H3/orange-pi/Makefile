include config.mk

SUBDIRS = \
  blinker03 \
  uart01 \
  uart02

ifeq ($(BOARD_VARIANT),NANO_PI)
SUBDIRS += \
  blinker01 \
  blinker02
endif

.DEFAULT_GOAL := all

.PHONY: all
all:
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ && ) true

.PHONY: install
install:
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ && ) true

.PHONY: clean
clean:
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ && ) true
	@echo cleaning lib-h3 library
	@$(MAKE) -C _common/rpidmx512/lib-h3 -f Makefile.H3 clean >/dev/null
