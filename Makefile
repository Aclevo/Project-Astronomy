# Quick and dirty Makefile for building Linux kernel
CPUS := $(shell nproc)

LINUX_VERSION = 6.18.6
LINUX         = linux-$(LINUX_VERSION)
LINUX_TARBALL = $(LINUX).tar.xz
LINUX_LINK    = https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)
LINUX_BZIMAGE = $(LINUX)/arch/x86_64/boot/bzImage

all: disk linux openrc populate-rootfs.img

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

openrc:
	if [ ! -f 0.63.tar.gz ]; then \
		wget https://github.com/OpenRC/openrc/archive/refs/tags/0.63.tar.gz; \
	fi

	if [ ! -f openrc-0.63 ]; then \
		tar -xvf 0.63.tar.gz; \
	fi

	cd openrc-0.63 && \
	meson setup build

	ninja -C openrc-0.63/build

	DESTDIR=../../root ninja -C openrc-0.63/build install

DISK      = rootfs.img
DISK_SIZE = 16G

disk: $(DISK) format-$(DISK)

$(DISK):
	qemu-img create -f raw $(DISK) $(DISK_SIZE)

setup-$(DISK): $(DISK)
	sudo losetup -fP $(DISK)

format-$(DISK): setup-$(DISK)
	sudo parted -s /dev/loop0 mklabel gpt
	sudo parted -s /dev/loop0 mkpart primary ext4 0% 100%
	yes | sudo mkfs.ext4 /dev/loop0p1

mount-$(DISK): setup-$(DISK)
	sudo mount /dev/loop0p1 /mnt

populate-$(DISK):
	sudo cp -r root/* /mnt

run:
	qemu-system-x86_64 -kernel $(LINUX_BZIMAGE) -append "root=/dev/sda1 init=/sbin/openrc-init console=ttyS0" -drive file=$(DISK),format=raw,index=0,media=disk -nographic
