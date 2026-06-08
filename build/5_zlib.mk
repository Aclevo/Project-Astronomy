zlib_VERSION      = 1.3.2
zlib_TARBALL      = zlib-$(zlib_VERSION).tar.xz
zlib_URL          = https://zlib.net/$(zlib_TARBALL)
zlib_DIR          = zlib-$(zlib_VERSION)
zlib_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --prefix=/$(PWD)/$(ROOTFS)/usr

#Alias for target
.PHONY: zlib 5_zlib download-5_zlib zlib-untar zlib-configure zlib-build zlib-install
zlib: 5_zlib

5_zlib: download-5_zlib zlib-untar zlib-configure zlib-build zlib-install

download-5_zlib: $(OUT)/.downloaded_zlib_stamp
zlib-untar: $(OUT)/.unpacked_zlib_stamp
zlib-configure: $(OUT)/.configured_zlib_stamp
zlib-build: $(OUT)/.built_zlib_stamp
zlib-install: $(OUT)/.installed_zlib_stamp

$(OUT)/.downloaded_zlib_stamp:
	wget -O $(DOWNLOAD_DIR)/$(zlib_TARBALL) $(zlib_URL)
	touch $@

$(OUT)/.unpacked_zlib_stamp: $(OUT)/.downloaded_zlib_stamp
	tar -xf $(DOWNLOAD_DIR)/$(zlib_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_zlib_stamp: $(OUT)/.unpacked_zlib_stamp
	mkdir -p $(OUT)/$(zlib_DIR)/out
	cd $(OUT)/$(zlib_DIR)/out;\
		../configure $(zlib_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_zlib_stamp: $(OUT)/.configured_zlib_stamp
	cd $(OUT)/$(zlib_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_zlib_stamp: $(OUT)/.built_zlib_stamp
	make -C $(OUT)/$(zlib_DIR)/out install
	touch $@
