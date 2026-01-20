# This Makefile is quick and dirty but it should do for now

# lower this if you want to do this more then once (as this will make your cpu toasty)
CPUS = $(nproc)

LINUX_VERSION = 6.18.6
LINUX         = linux-$(LINUX_VERSION)
LINUX_TARBALL = $(LINUX).tar.xz
LINUX_LINK    = https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)
LINUX_CONFIG  = $(LINUX)/.config

all: linux

linux: download-linux untar-linux configure-linux compile-linux # install-linux-headers install-linux

download-linux:
		if [ -f $(LINUX_TARBALL) ]; then \
                wget $(LINUX_LINK)
		fi

untar-linux:
		if [ -f $(LINUX) ]; then \
                tar -xvf $(LINUX_TARBALL)
		fi

configure-linux:
		if [ -f $(LINUX_CONFIG) ]; then \
			make -j$(CPUS) -C $(LINUX) defconfig
		fi

# For some reason this crashes my terminal
# if that ever does happen to you need to
# go into the kernel source, 
# run "$ make -j$(CPUS) -C <KERNEL SOURCE>"
# and skip "compile-linux" but hopefully
# that will be fixed soon!
compile-linux:
	make -j$(CPUS) -C $(LINUX)
