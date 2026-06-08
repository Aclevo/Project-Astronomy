libxcrypt_VERSION      = 4.5.2
libxcrypt_TARBALL      = libxcrypt-$(libxcrypt_VERSION).tar.xz
libxcrypt_URL          = https://github.com/besser82/libxcrypt/releases/download/v$(libxcrypt_VERSION)/$(libxcrypt_TARBALL)
libxcrypt_DIR          = libxcrypt-$(libxcrypt_VERSION)
libxcrypt_CONFIG_FLAGS = --disable-static --enable-hashes=strong,glibc --disable-failure-tokens --enable-obsolete-api=glibc $(COMMON_CONFIG_FLAGS) --prefix=/$(PWD)/$(ROOTFS)

.PHONY: libxcrypt 5_libxcrypt download-5_libxcrypt libxcrypt-untar libxcrypt-configure libxcrypt-build libxcrypt-install
libxcrypt: 5_libxcrypt

5_libxcrypt: download-5_libxcrypt libxcrypt-untar libxcrypt-configure libxcrypt-build libxcrypt-install

download-5_libxcrypt: $(OUT)/.downloaded_libxcrypt_stamp
libxcrypt-untar: $(OUT)/.unpacked_libxcrypt_stamp
libxcrypt-configure: $(OUT)/.configured_libxcrypt_stamp
libxcrypt-build: $(OUT)/.built_libxcrypt_stamp
libxcrypt-install: $(OUT)/.installed_libxcrypt_stamp

$(OUT)/.downloaded_libxcrypt_stamp:
	wget -O $(DOWNLOAD_DIR)/$(libxcrypt_TARBALL) $(libxcrypt_URL)
	touch $@

$(OUT)/.unpacked_libxcrypt_stamp: $(OUT)/.downloaded_libxcrypt_stamp
	tar -xf $(DOWNLOAD_DIR)/$(libxcrypt_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_libxcrypt_stamp: $(OUT)/.unpacked_libxcrypt_stamp
	mkdir -p $(OUT)/$(libxcrypt_DIR)/out
	cd $(OUT)/$(libxcrypt_DIR)/out;\
		../configure $(libxcrypt_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_libxcrypt_stamp: $(OUT)/.configured_libxcrypt_stamp
	cd $(OUT)/$(libxcrypt_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_libxcrypt_stamp: $(OUT)/.built_libxcrypt_stamp
	make -C $(OUT)/$(libxcrypt_DIR)/out install
	touch $@
