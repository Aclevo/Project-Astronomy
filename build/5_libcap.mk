libcap_VERSION      = 2.78
libcap_TARBALL      = libcap-$(libcap_VERSION).tar.gz
libcap_URL          = https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/$(libcap_TARBALL)
libcap_DIR          = libcap-$(libcap_VERSION)
libcap_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --prefix=/$(PWD)/$(ROOTFS)

#Alias for target
.PHONY: libcap 5_libcap download-5_libcap libcap-untar libcap-configure libcap-build libcap-install
libcap: 5_libcap

5_libcap: download-5_libcap libcap-untar libcap-build libcap-install

download-5_libcap: $(OUT)/.downloaded_libcap_stamp
libcap-untar: $(OUT)/.unpacked_libcap_stamp
libcap-configure: $(OUT)/.configured_libcap_stamp
libcap-build: $(OUT)/.built_libcap_stamp
libcap-install: $(OUT)/.installed_libcap_stamp

$(OUT)/.downloaded_libcap_stamp:
	wget -O $(DOWNLOAD_DIR)/$(libcap_TARBALL) $(libcap_URL)
	touch $@

$(OUT)/.unpacked_libcap_stamp: $(OUT)/.downloaded_libcap_stamp
	tar -xf $(DOWNLOAD_DIR)/$(libcap_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.built_libcap_stamp: $(OUT)/.unpacked_libcap_stamp
	cd $(OUT)/$(libcap_DIR);\
		make
	touch $@

$(OUT)/.installed_libcap_stamp: $(OUT)/.built_libcap_stamp
	make DESTDIR=$(PWD)/$(ROOTFS)/usr -C $(OUT)/$(libcap_DIR) install
	touch $@
