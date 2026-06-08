.PHONY: 3_linux linux-nocompile download-3_linux untar-linux configure-linux compile-linux

LINUX_VERSION = 6.18.6
LINUX         = linux-$(LINUX_VERSION)
LINUX_TARBALL = $(LINUX).tar.xz
LINUX_LINK    = https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)
LINUX_BZIMAGE = $(OUT)/$(LINUX)/arch/x86_64/boot/bzImage

3_linux: download-3_linux untar-linux configure-linux compile-linux


download-3_linux: $(OUT)/.downloaded_linux_stamp
untar-linux: $(OUT)/.unpacked_linux_stamp
configure-linux: $(OUT)/.configured_linux_stamp
compile-linux:  $(OUT)/.compiled_linux_stamp

$(OUT)/.downloaded_linux_stamp:
	wget -O $(DOWNLOAD_DIR)/$(LINUX_TARBALL) $(LINUX_LINK)
	touch $@

$(OUT)/.unpacked_linux_stamp: $(OUT)/.downloaded_linux_stamp
	tar -xf $(DOWNLOAD_DIR)/$(LINUX_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_linux_stamp: $(OUT)/.unpacked_linux_stamp
	make -C $(OUT)/$(LINUX) defconfig
	touch $@

$(OUT)/.compiled_linux_stamp: $(OUT)/.configured_linux_stamp
	make -C $(OUT)/$(LINUX) 2>&1 | tee $(OUT)/kernel-build.log
	touch $@
