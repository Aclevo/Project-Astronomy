CPUS               := $(shell nproc)
CFLAGS             ?= -O2
CPPFLAGS	   ?= -I $(PWD)/$(ROOTFS)/usr/include
LD_FLAGS	   ?=
OUT                ?= out
ROOTFS             ?= $(OUT)/mnt
LDFLAGS		   += -L/$(PWD)/$(ROOTFS)/usr/lib
LDFLAGS		   += -L/$(PWD)/$(ROOTFS)/usr/lib/x86_64-linux-gnu
DOWNLOAD_DIR       ?= $(OUT)/download
SUBMAKEFILES        = $(wildcard build/*.mk)
PACKAGES            = $(SUBMAKEFILES:build/%.mk=%) 
DOWNLOAD_TARGETS    = $(PACKAGES:%=download-%)
LIBRARY_PATH 	   ?= $(PWD)/$(ROOTFS)/usr/lib:$(PWD)/$(ROOTFS)/usr/lib64:$(PWD)/$(ROOTFS)/usr/lib/x86_64-linux-gnu/
COMMON_CONFIG_FLAGS = LIBRARY_PATH="$(LIBRARY_PATH)" CXX=$(PWD)/$(TOOLS_ROOT)/bin/x86_64-linux-gnu-g++ CPP=$(PWD)/$(TOOLS_ROOT)/bin/x86_64-linux-gnu-cpp CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" LDFLAGS="$(LDFLAGS)"

.PHONY: all download-all disk symlink packages
.NOTPARALLEL: all download-all packages disk

all: $(ROOTFS) symlink download-all packages disk

download-all: $(DOWNLOAD_TARGETS) | $(ROOTFS)
packages: $(PACKAGES) | $(DOWNLOAD_TARGETS)

include $(SUBMAKEFILES)

symlink: $(ROOTFS)
	cd $(ROOTFS);\
	 ln -sf usr/bin bin;\
	 ln -sf usr/sbin sbin;\
	 ln -sf usr/lib lib;\
	 ln -sf usr/lib64 lib64

RAMDISK = $(OUT)/initrd.cpio.gz

disk: $(RAMDISK) | $(PACKAGES)

$(RAMDISK): $(ROOTFS)
	cd $(ROOTFS);\
	 fakeroot find . | fakeroot cpio -o -H newc | gzip > $(PWD)/$(RAMDISK)

run:
	qemu-system-x86_64 \
		-cpu host \
		-kernel $(LINUX_BZIMAGE) \
		-initrd  $(RAMDISK) \
		-append "LD_LIBRARY_PATH="/lib:/lib64:/lib/x86_64-linux-gnu" rdinit=/bin/bash console=ttyS0 raid=noautodetect" \
		-m 1G \
		-serial stdio \
		-display none \
		--enable-kvm

$(ROOTFS):
	mkdir -p $(ROOTFS)/usr/lib64 $(ROOTFS)/usr/lib/x86_64-linux-gnu\
		$(ROOTFS)/usr/bin $(ROOTFS)/usr/sbin $(ROOTFS)/usr/lib\
	       	$(ROOTFS)/usr/lib64 $(DOWNLOAD_DIR)
	# Missing shared objects that should be added later:
	# libz.so.1 libzstd.so.1 

