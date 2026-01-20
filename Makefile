# This Makefile is quick and dirty but it should do for now

# lower this if you want to do this more then once (as this will make your cpu toasty)
CPUS = $(nproc)

LINUX_VERSION = 6.18.6
LINUX         = linux-$(LINUX_VERSION)
LINUX_TARBALL = $(LINUX).tar.xz
LINUX_LINK    = https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)

all: linux

linux: download-linux untar-linux configure-linux compile-linux # install-linux-headers install-linux

download-linux:
	wget $(LINUX_LINK)

untar-linux:
	tar -xvf $(LINUX_TARBALL)

configure-linux:
	make -j$(CPUS) -C $(LINUX) defconfig

# for some reason this crashes my terminal
compile-linux:
	make -j$(CPUS) -C $(LINUX)
