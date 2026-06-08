xz_VERSION      = 5.8.3
xz_TARBALL      = xz-$(xz_VERSION).tar.xz
xz_URL          = https://github.com/tukaani-project/xz/releases/download/v$(xz_VERSION)/$(xz_TARBALL)
xz_DIR          = xz-$(xz_VERSION)
xz_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --prefix=/$(PWD)/$(ROOTFS)/usr --build=$(shell $(PWD)/$(OUT)/$(xz_DIR)/build-aux/config.guess) --disable-static  --docdir=/$(PWD)/$(ROOTFS)/usr/share/doc/$(xz_DIR)

#Alias for target
.PHONY: xz 5_xz download-5_xz xz-untar xz-configure xz-build xz-install
xz: 5_xz

5_xz: download-5_xz xz-untar xz-configure xz-build xz-install

download-5_xz: $(OUT)/.downloaded_xz_stamp
xz-untar: $(OUT)/.unpacked_xz_stamp
xz-configure: $(OUT)/.configured_xz_stamp
xz-build: $(OUT)/.built_xz_stamp
xz-install: $(OUT)/.installed_xz_stamp

$(OUT)/.downloaded_xz_stamp:
	wget -O $(DOWNLOAD_DIR)/$(xz_TARBALL) $(xz_URL)
	touch $@

$(OUT)/.unpacked_xz_stamp: $(OUT)/.downloaded_xz_stamp
	tar -xf $(DOWNLOAD_DIR)/$(xz_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_xz_stamp: $(OUT)/.unpacked_xz_stamp
	mkdir -p $(OUT)/$(xz_DIR)/out
	cd $(OUT)/$(xz_DIR)/out;\
		../configure $(xz_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_xz_stamp: $(OUT)/.configured_xz_stamp
	cd $(OUT)/$(xz_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_xz_stamp: $(OUT)/.built_xz_stamp
	make -C $(OUT)/$(xz_DIR)/out install
	rm -v $(ROOTFS)/usr/lib/liblzma.la
	touch $@
