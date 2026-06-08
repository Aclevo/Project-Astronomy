.PHONY: 4_coreutils download-4_coreutils coreutils-untar coreutils-configure coreutils-build coreutils-install

COREUTILS_VERSION ?= 9.11
COREUTILS_TARBALL  = coreutils-$(COREUTILS_VERSION).tar.xz
COREUTILS_URL      = https://ftp.gnu.org/gnu/coreutils/$(COREUTILS_TARBALL)
COREUTILS          = coreutils-$(COREUTILS_VERSION)
COREUTILS_FLAGS   ?= $(COMMON_CONFIG_FLAGS) --build=$(shell $(OUT)/$(COREUTILS)/build-aux/config.guess) --enable-install-program=hostname --enable-no-install-program=kill,uptime --host=x86_64-linux-gnu --prefix=$(PWD)/$(ROOTFS)

4_coreutils: download-4_coreutils coreutils-untar coreutils-configure coreutils-build coreutils-install

download-4_coreutils: $(OUT)/.downloaded_coreutils_stamp
coreutils-untar: $(OUT)/.unpacked_coreutils_stamp
coreutils-configure: $(OUT)/.configured_coreutils_stamp
coreutils-build: $(OUT)/.built_coreutils_stamp
coreutils-install: $(OUT)/.installed_coreutils_stamp

$(OUT)/.downloaded_coreutils_stamp:
	wget -O $(DOWNLOAD_DIR)/$(COREUTILS_TARBALL) $(COREUTILS_URL)
	touch $@

$(OUT)/.unpacked_coreutils_stamp: $(OUT)/.downloaded_coreutils_stamp
	tar -xf $(DOWNLOAD_DIR)/$(COREUTILS_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_coreutils_stamp: $(OUT)/.unpacked_coreutils_stamp
	mkdir -p $(OUT)/$(COREUTILS)/out
	cd $(OUT)/$(COREUTILS)/out;\
		../configure $(COREUTILS_FLAGS)
	touch $@

$(OUT)/.built_coreutils_stamp: $(OUT)/.configured_coreutils_stamp
	cd $(OUT)/$(COREUTILS)/out;\
		make
	touch $@

$(OUT)/.installed_coreutils_stamp: $(OUT)/.built_coreutils_stamp
	make -C $(OUT)/$(COREUTILS)/out install
	mv -v $(PWD)/$(ROOTFS)/usr/bin/chroot $(PWD)/$(ROOTFS)/usr/sbin
	mkdir -pv $(PWD)/$(ROOTFS)/usr/share/man/man8
	touch $@
