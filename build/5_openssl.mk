openssl_VERSION      = 3.5.6
openssl_TARBALL      = openssl-$(openssl_VERSION).tar.gz
openssl_URL          = https://github.com/openssl/openssl/releases/download/openssl-$(openssl_VERSION)/$(openssl_TARBALL)
openssl_DIR          = openssl-$(openssl_VERSION)
openssl_CONFIG_FLAGS = --openssldir=/$(PWD)/$(ROOTFS)/etc/ssl --libdir=lib shared zlib-dynamic $(COMMON_CONFIG_FLAGS) --prefix=/$(PWD)/$(ROOTFS)/usr

#Alias for target
.PHONY: openssl 5_openssl download-5_openssl openssl-untar openssl-configure openssl-build openssl-install
openssl: 5_openssl

5_openssl: download-5_openssl openssl-untar openssl-configure openssl-build openssl-install

download-5_openssl: $(OUT)/.downloaded_openssl_stamp
openssl-untar: $(OUT)/.unpacked_openssl_stamp
openssl-configure: $(OUT)/.configured_openssl_stamp
openssl-build: $(OUT)/.built_openssl_stamp
openssl-install: $(OUT)/.installed_openssl_stamp

$(OUT)/.downloaded_openssl_stamp:
	wget -O $(DOWNLOAD_DIR)/$(openssl_TARBALL) $(openssl_URL)
	touch $@

$(OUT)/.unpacked_openssl_stamp: $(OUT)/.downloaded_openssl_stamp
	tar -xf $(DOWNLOAD_DIR)/$(openssl_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_openssl_stamp: $(OUT)/.unpacked_openssl_stamp
	mkdir -p $(OUT)/$(openssl_DIR)/out
	cd $(OUT)/$(openssl_DIR)/out;\
		../Configure $(openssl_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_openssl_stamp: $(OUT)/.configured_openssl_stamp
	cd $(OUT)/$(openssl_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_openssl_stamp: $(OUT)/.built_openssl_stamp
	make INSTALL_LIBS= MANSUFFIX=ssl -C $(OUT)/$(openssl_DIR)/out install
	mv -v /$(PWD)/$(ROOTFS)/usr/share/doc/openssl /$(PWD)/$(ROOTFS)/usr/share/doc/openssl-$(openssl_VERSION)
	touch $@
