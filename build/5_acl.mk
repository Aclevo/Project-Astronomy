acl_VERSION      = 2.3.2
acl_TARBALL      = acl-$(acl_VERSION).tar.xz
acl_URL          = https://download-mirror.savannah.gnu.org/releases/acl/$(acl_TARBALL)
acl_DIR          = acl-$(acl_VERSION)
acl_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --disable-static --libexecdir=/$(PWD)/$(ROOTFS)/usr/lib --docdir=/$(PWD)/$(ROOTFS)/usr/share/doc/acl-$(acl_VERSION) --prefix=/$(PWD)/$(ROOTFS)/usr
#Alias for target
.PHONY: acl 5_acl download-5_acl acl-untar acl-configure acl-build acl-install
acl: 5_acl

5_acl: download-5_acl acl-untar acl-configure acl-build acl-install

download-5_acl: $(OUT)/.downloaded_acl_stamp
acl-untar: $(OUT)/.unpacked_acl_stamp
acl-configure: $(OUT)/.configured_acl_stamp
acl-build: $(OUT)/.built_acl_stamp
acl-install: $(OUT)/.installed_acl_stamp

$(OUT)/.downloaded_acl_stamp:
	wget -O $(DOWNLOAD_DIR)/$(acl_TARBALL) $(acl_URL)
	touch $@

$(OUT)/.unpacked_acl_stamp: $(OUT)/.downloaded_acl_stamp
	tar -xf $(DOWNLOAD_DIR)/$(acl_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_acl_stamp: $(OUT)/.unpacked_acl_stamp
	mkdir -p $(OUT)/$(acl_DIR)/out
	cd $(OUT)/$(acl_DIR)/out;\
		../configure $(acl_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_acl_stamp: $(OUT)/.configured_acl_stamp
	cd $(OUT)/$(acl_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_acl_stamp: $(OUT)/.built_acl_stamp
	make -C $(OUT)/$(acl_DIR)/out install
	touch $@
