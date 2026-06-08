zstd_VERSION      = 1.5.7
zstd_TARBALL      = zstd-$(zstd_VERSION).tar.gz
zstd_URL          = https://github.com/facebook/zstd/releases/download/v$(zstd_VERSION)/$(zstd_TARBALL)
zstd_DIR          = zstd-$(zstd_VERSION)
zstd_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) prefix=/$(PWD)/$(ROOTFS)/usr

#Alias for target
.PHONY: zstd 5_zstd download-5_zstd zstd-untar zstd-configure zstd-build zstd-install
zstd: 5_zstd

5_zstd: download-5_zstd zstd-untar zstd-build zstd-install

download-5_zstd: $(OUT)/.downloaded_zstd_stamp
zstd-untar: $(OUT)/.unpacked_zstd_stamp
zstd-configure: $(OUT)/.configured_zstd_stamp
zstd-build: $(OUT)/.built_zstd_stamp
zstd-install: $(OUT)/.installed_zstd_stamp

$(OUT)/.downloaded_zstd_stamp:
	wget -O $(DOWNLOAD_DIR)/$(zstd_TARBALL) $(zstd_URL)
	touch $@

$(OUT)/.unpacked_zstd_stamp: $(OUT)/.downloaded_zstd_stamp
	tar -xf $(DOWNLOAD_DIR)/$(zstd_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.built_zstd_stamp: $(OUT)/.unpacked_zstd_stamp
	cd $(OUT)/$(zstd_DIR);\
		$(COMMON_CONFIG_FLAGS) make
	touch $@

$(OUT)/.installed_zstd_stamp: $(OUT)/.built_zstd_stamp
	make -C $(OUT)/$(zstd_DIR) $(zstd_CONFIG_FLAGS) install
	rm $(ROOTFS)/usr/lib/libzstd.a
	touch $@
