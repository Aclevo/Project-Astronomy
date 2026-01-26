# Quick and dirty Makefile for building Linux kernel
CPUS := $(shell nproc)

LINUX_VERSION = 6.18.6
LINUX         = linux-$(LINUX_VERSION)
LINUX_TARBALL = $(LINUX).tar.xz
LINUX_LINK    = https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)
LINUX_BZIMAGE = $(LINUX)/arch/x86_64/boot/bzImage

all: disk linux systemd symlink detach-rootfs.img

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

systemd:
	if [ ! -f v259.tar.gz ]; then \
		wget https://github.com/systemd/systemd/archive/refs/tags/v259.tar.gz; \
	fi

	if [ ! -f systemd-259 ]; then \
		tar -xvf v259.tar.gz; \
	fi

	meson setup ./systemd-259/build ./systemd-259 -D buildtype=release -D optimization=2
	ninja -C ./systemd-259/build
	sudo DESTDIR=/mnt ninja -C ./systemd-259/build install

symlink:
	sudo ln -s /mnt/usr/bin /mnt/bin
	sudo ln -s /mnt/usr/sbin /mnt/sbin
	sudo ln -s /mnt/usr/lib /mnt/lib
	sudo ln -s /mnt/usr/lib64 /mnt/lib64

DISK      = rootfs.img
DISK_SIZE = 16G

disk: format-$(DISK) mount-$(DISK)

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

unmount-$(DISK):
	sync
	sudo umount /mnt

detach-$(DISK): unmount-$(DISK)
	sudo losetup -d /dev/loop0

run:
	qemu-system-x86_64 -kernel $(LINUX_BZIMAGE) -hda rootfs.img -append "init=/lib/systemd/systemd root=/dev/sda1 console=ttyS0" -nographic
