.DEFAULT_GOAL := all

SUBDIRS = \
  blinker01 \
  blinker02 \
  uart01

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
