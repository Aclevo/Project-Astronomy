# Quick and dirty Makefile for building Linux kernel
CPUS := $(shell nproc)

LINUX_VERSION = 6.18.6
LINUX         = linux-$(LINUX_VERSION)
LINUX_TARBALL = $(LINUX).tar.xz
LINUX_LINK    = https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)
LINUX_BZIMAGE = $(LINUX)/arch/x86_64/boot/bzImage

all: linux littleinit build-initramfs

linux: download-linux untar-linux configure-linux compile-linux

download-linux:
	if [ ! -f $(LINUX_TARBALL) ]; then \
		wget $(LINUX_LINK); \
	fi

untar-linux:
	if [ ! -d $(LINUX) ]; then \
		tar -xvf $(LINUX_TARBALL); \
	fi

configure-linux:
	make -j$(CPUS) -C $(LINUX) defconfig

# For some reason this crashes my terminal
# if that ever does happen to you need to
# go into the kernel source,
# run "$ make -j$(CPUS) -C <KERNEL SOURCE>"
# and skip "compile-linux" but hopefully
# that will be fixed soon!
compile-linux:
	make -j$(CPUS) -C $(LINUX)

LITTLEINIT_VERSION  =	
LITTLEINIT          = littleinit-main
LITTLEINIT_TARBALL  = main.zip
LITTLEINIT_LINK     = https://github.com/GNUfault/littleinit/archive/refs/heads/$(LITTLEINIT_TARBALL)
LITTLEINIT_BUILDDIR = $(LITTLEINIT)/build

littleinit: download-littleinit untar-littleinit configure-littleinit compile-littleinit

download-littleinit:
	if [ ! -f $(LITTLEINIT_TARBALL) ]; then \
		wget $(LITTLEINIT_LINK); \
	fi

untar-littleinit:
	if [ ! -d $(LITTLEINIT) ]; then \
		unzip $(LITTLEINIT_TARBALL); \
	fi

configure-littleinit:
	mkdir -p $(LITTLEINIT_BUILDDIR)
	cmake -S $(LITTLEINIT) -B $(LITTLEINIT_BUILDDIR)

compile-littleinit:
	make -j$(CPUS) -C $(LITTLEINIT_BUILDDIR)

LITTLEINIT_INIT = $(LITTLEINIT_BUILDDIR)/init
INITRAMFS       = initramfs.cpio.gz

build-initramfs:
	echo $(LITTLEINIT_INIT) | cpio -o -H newc | gzip > $(INITRAMFS)

run:
	qemu-system-x86_64 -kernel $(LINUX_BZIMAGE) -initrd $(INITRAMFS) -append "init=/init"
