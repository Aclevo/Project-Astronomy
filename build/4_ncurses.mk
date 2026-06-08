.PHONY: 4_ncurses download-4_ncurses ncurses-untar ncurses-configure ncurses-build ncurses-install

ncurses_VERSION      = 6.6
ncurses_TARBALL      = ncurses-$(ncurses_VERSION).tar.gz
ncurses_URL          = https://invisible-mirror.net/archives/ncurses/$(ncurses_TARBALL)
ncurses_DIR          = ncurses-$(ncurses_VERSION)
ncurses_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --disable-widec --disable-libtool-version --with-termlib --with-manpage-format=normal --with-shared --without-normal --disable-stripping --without-debug --with-cxx-shared --without-ada --prefix=/$(PWD)/$(ROOTFS) --host=x86_64-linux-gnu --build=$(shell /$(PWD)/$(OUT)/$(ncurses_DIR)/config.guess)

4_ncurses: download-4_ncurses ncurses-untar ncurses-configure ncurses-build ncurses-install

download-4_ncurses: $(OUT)/.downloaded_ncurses_stamp
ncurses-untar: $(OUT)/.unpacked_ncurses_stamp
ncurses-configure: $(OUT)/.configured_ncurses_stamp
ncurses-build: $(OUT)/.built_ncurses_stamp
ncurses-install: $(OUT)/.installed_ncurses_stamp

$(OUT)/.downloaded_ncurses_stamp:
	wget -O $(DOWNLOAD_DIR)/$(ncurses_TARBALL) $(ncurses_URL)
	touch $@

$(OUT)/.unpacked_ncurses_stamp: $(OUT)/.downloaded_ncurses_stamp
	tar -xf $(DOWNLOAD_DIR)/$(ncurses_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_ncurses_stamp: $(OUT)/.unpacked_ncurses_stamp
	mkdir -p $(OUT)/$(ncurses_DIR)/out
	cd $(OUT)/$(ncurses_DIR)/out;\
		../configure $(ncurses_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_ncurses_stamp: $(OUT)/.configured_ncurses_stamp
	cd $(OUT)/$(ncurses_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_ncurses_stamp: $(OUT)/.built_ncurses_stamp
	make -C $(OUT)/$(ncurses_DIR)/out install
	#ln -sv libncursesw.so $(PWD)/$(ROOTFS)/usr/lib/libncurses.so
	touch $@
