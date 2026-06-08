readline_VERSION      = 8.3
readline_TARBALL      = readline-$(readline_VERSION).tar.gz
readline_URL          = https://mirrors.liquidweb.com/gnu/readline/$(readline_TARBALL)
readline_DIR          = readline-$(readline_VERSION)
readline_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --prefix=/$(PWD)/$(ROOTFS)/usr/ --with-curses --disable-static
readline_MAKE_FLAGS  = SHLIB_LIBS="-lncursesw"

#Alias for target
.PHONY: readline 5_readline download-5_readline readline-untar readline-configure readline-build readline-install
readline: 5_readline

5_readline: download-5_readline readline-untar readline-configure readline-build readline-install

download-5_readline: $(OUT)/.downloaded_readline_stamp
readline-untar: $(OUT)/.unpacked_readline_stamp
readline-configure: $(OUT)/.configured_readline_stamp
readline-build: $(OUT)/.built_readline_stamp
readline-install: $(OUT)/.installed_readline_stamp

$(OUT)/.downloaded_readline_stamp:
	wget -O $(DOWNLOAD_DIR)/$(readline_TARBALL) $(readline_URL)
	touch $@

$(OUT)/.unpacked_readline_stamp: $(OUT)/.downloaded_readline_stamp
	tar -xf $(DOWNLOAD_DIR)/$(readline_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_readline_stamp: $(OUT)/.unpacked_readline_stamp
	mkdir -p $(OUT)/$(readline_DIR)/out
	cd $(OUT)/$(readline_DIR)/out;\
		sed -i '/MV.*old/d' ../Makefile.in;\
		sed -i '/{OLDSUFF}/c:' ../support/shlib-install;\
		sed -i 's/-Wl,-rpath,[^ ]*//' ../support/shobj-conf;\
		sed -e '270a\
			else\
				chars_avail = 1;'\
			-e '288i\
			result = -1;' \
			-i.orig ../input.c;\
		../configure $(readline_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_readline_stamp: $(OUT)/.configured_readline_stamp
	cd $(OUT)/$(readline_DIR)/out;\
		make $(readline_MAKE_FLAGS)
	touch $@

$(OUT)/.installed_readline_stamp: $(OUT)/.built_readline_stamp
	make -C $(OUT)/$(readline_DIR)/out install
	touch $@
