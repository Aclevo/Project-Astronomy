attr_VERSION      = 2.5.2
attr_TARBALL      = attr-$(attr_VERSION).tar.xz
attr_URL          = https://download-mirror.savannah.gnu.org/releases/attr/$(attr_TARBALL)
attr_DIR          = attr-$(attr_VERSION)
attr_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --disable-static --prefix=/$(PWD)/$(ROOTFS)/usr --sysconfdir=/$(PWD)/$(ROOTFS)/etc

#Alias for target
.PHONY: attr 4_attr download-4_attr attr-untar attr-configure attr-build attr-install
attr: 4_attr

4_attr: download-4_attr attr-untar attr-configure attr-build attr-install

download-4_attr: $(OUT)/.downloaded_attr_stamp
attr-untar: $(OUT)/.unpacked_attr_stamp
attr-configure: $(OUT)/.configured_attr_stamp
attr-build: $(OUT)/.built_attr_stamp
attr-install: $(OUT)/.installed_attr_stamp

$(OUT)/.downloaded_attr_stamp:
	wget -O $(DOWNLOAD_DIR)/$(attr_TARBALL) $(attr_URL)
	touch $@

$(OUT)/.unpacked_attr_stamp: $(OUT)/.downloaded_attr_stamp
	tar -xf $(DOWNLOAD_DIR)/$(attr_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_attr_stamp: $(OUT)/.unpacked_attr_stamp
	mkdir -p $(OUT)/$(attr_DIR)/out
	cd $(OUT)/$(attr_DIR)/out;\
		../configure $(attr_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_attr_stamp: $(OUT)/.configured_attr_stamp
	cd $(OUT)/$(attr_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_attr_stamp: $(OUT)/.built_attr_stamp
	make -C $(OUT)/$(attr_DIR)/out install
	touch $@
