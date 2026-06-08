.PHONY: binutils download-binutils binutils-untar binutils-configure binutils-build binutils-install

binutils_VERSION      = 2.44.90
binutils_TARBALL      = binutils-$(binutils_VERSION).tar.xz
binutils_URL          = https://sourceware.org/pub/binutils/snapshots/$(binutils_TARBALL)
binutils_DIR          = binutils-$(binutils_VERSION)
binutils_CONFIG_FLAGS = --target=x86_64-linux-gnu --prefix=/$(PWD)/$(TOOLS_ROOT) CFLAGS="$(TOOLS_CFLAGS)"

binutils: download-binutils binutils-untar binutils-configure binutils-build binutils-install

download-binutils: $(OUT)/.downloaded_binutils_stamp
binutils-untar: $(OUT)/.unpacked_binutils_stamp
binutils-configure: $(OUT)/.configured_binutils_stamp
binutils-build: $(OUT)/.built_binutils_stamp
binutils-install: $(OUT)/.installed_binutils_stamp

$(OUT)/.downloaded_binutils_stamp:
	wget -O $(DOWNLOAD_DIR)/$(binutils_TARBALL) $(binutils_URL)
	touch $@

$(OUT)/.unpacked_binutils_stamp: $(OUT)/.downloaded_binutils_stamp
	tar -xf $(DOWNLOAD_DIR)/$(binutils_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_binutils_stamp: $(OUT)/.unpacked_binutils_stamp
	mkdir -p $(OUT)/$(binutils_DIR)/out
	cd $(OUT)/$(binutils_DIR)/out ;\
		../configure $(binutils_CONFIG_FLAGS) ;\
		mkdir gas/doc -p
	touch $@

$(OUT)/.built_binutils_stamp: $(OUT)/.configured_binutils_stamp
	cd $(OUT)/$(binutils_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_binutils_stamp: $(OUT)/.built_binutils_stamp
	make -C $(OUT)/$(binutils_DIR)/out install
	touch $@
