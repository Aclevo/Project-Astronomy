# Quick and dirty Makefile for building Linux kernel
CPUS := $(shell nproc)

LINUX_VERSION = 6.18.6
LINUX         = linux-$(LINUX_VERSION)
LINUX_TARBALL = $(LINUX).tar.xz
LINUX_LINK    = https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)
LINUX_BZIMAGE = $(LINUX)/arch/x86_64/boot/bzImage

all: linux initramfs-util-linux build-initramfs

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

UTIL-LINUX_VERSION = 2.41.3
UTIL-LINUX         = util-linux-2.41.3
UTIL-LINUX_TARBALL = $(UTIL-LINUX).tar.xz
UTIL-LINUX_LINK    = https://www.kernel.org/pub/linux/utils/util-linux/v2.41/$(LITTLEINIT_TARBALL)

initramfs-util-linux: download-util-linux untar-util-linux configure-initramfs-util-linux compile-util-linux

download-util-linux:
	if [ ! -f $(UTIL-LINUX_TARBALL) ]; then \
		wget $(UTIL-LINUX_LINK); \
	fi

untar-util-linux:
	if [ ! -d $(UTIL-LINUX) ]; then \
		tar -xvf $(UTIL-LINUX_TARBALL); \
	fi

configure-initramfs-util-linux:
	cd ./configure --disable-all-programs --enable-mount --enable-fsck --enable-switch_root --enable-libmount --enable-libblkid

compile-util-linux:
	make -j$(CPUS) -C $(UTIL-LINUX)

INITRAMFS = initramfs.cpio.gz

build-initramfs:
	cd $(UTIL-LINUX) && \
	find . | cpio -o -H newc | gzip > ../$(INITRAMFS)

run:
	qemu-system-x86_64 -kernel $(LINUX_BZIMAGE) -initrd $(INITRAMFS) -append "init=/init console=ttyS0" -nographic
