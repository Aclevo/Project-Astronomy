.PHONY: 2_glibc download-2_glibc glibc-untar glibc-configure glibc-build glibc-install

GLIBC_VERSION      = 2.43
GLIBC_TARBALL      = glibc-$(GLIBC_VERSION).tar.xz
GLIBC_URL          = https://ftp.gnu.org/gnu/glibc/$(GLIBC_TARBALL)
GLIBC_DIR          = glibc-$(GLIBC_VERSION)
GLIBC_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --prefix=$(PWD)/$(ROOTFS)

2_glibc: download-2_glibc glibc-untar glibc-configure glibc-build glibc-install

download-2_glibc: $(OUT)/.downloaded_glibc_stamp
glibc-untar: $(OUT)/.unpacked_glibc_stamp
glibc-configure: $(OUT)/.configured_glibc_stamp
glibc-build: $(OUT)/.built_glibc_stamp
glibc-install: $(OUT)/.installed_glibc_stamp

$(OUT)/.downloaded_glibc_stamp:
	wget -O $(DOWNLOAD_DIR)/$(GLIBC_TARBALL) $(GLIBC_URL)
	touch $@

$(OUT)/.unpacked_glibc_stamp: $(OUT)/.downloaded_glibc_stamp
	tar -xf $(DOWNLOAD_DIR)/$(GLIBC_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_glibc_stamp: $(OUT)/.unpacked_glibc_stamp
	mkdir -p $(OUT)/$(GLIBC_DIR)/out
	cd $(OUT)/$(GLIBC_DIR)/out;\
		../configure $(GLIBC_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_glibc_stamp: $(OUT)/.configured_glibc_stamp
	cd $(OUT)/$(GLIBC_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_glibc_stamp: $(OUT)/.built_glibc_stamp
	make -C $(OUT)/$(GLIBC_DIR)/out install
	cp $(ROOTFS)/lib/ld-linux-x86-64.so.2 $(ROOTFS)/lib64/ld-linux-x86-64.so.2
	touch $@
