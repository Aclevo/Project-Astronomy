libselinux_VERSION      = 3.10
libselinux_TARBALL      = libselinux-$(libselinux_VERSION).tar.gz
libselinux_URL          = https://github.com/SELinuxProject/selinux/releases/download/$(libselinux_VERSION)/$(libselinux_TARBALL)
libselinux_DIR          = libselinux-$(libselinux_VERSION)
libselinux_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --prefix=/$(PWD)/$(ROOTFS)

#Alias for target
.PHONY: libselinux 5_libselinux download-5_libselinux libselinux-untar libselinux-configure libselinux-build libselinux-install
libselinux: 5_libselinux

5_libselinux: download-5_libselinux libselinux-untar libselinux-install

download-5_libselinux: $(OUT)/.downloaded_libselinux_stamp
libselinux-untar: $(OUT)/.unpacked_libselinux_stamp
libselinux-configure: $(OUT)/.configured_libselinux_stamp
libselinux-install: $(OUT)/.installed_libselinux_stamp

$(OUT)/.downloaded_libselinux_stamp:
	wget -O $(DOWNLOAD_DIR)/$(libselinux_TARBALL) $(libselinux_URL)
	touch $@

$(OUT)/.unpacked_libselinux_stamp: $(OUT)/.downloaded_libselinux_stamp
	tar -xf $(DOWNLOAD_DIR)/$(libselinux_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.installed_libselinux_stamp: $(OUT)/.unpacked_libselinux_stamp
	make -C $(OUT)/$(libselinux_DIR) DESTDIR=$(PWD)/$(ROOTFS) install
	touch $@
