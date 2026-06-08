.PHONY: gcc download-gcc gcc-untar gcc-configure gcc-build gcc-install

gcc_VERSION      = 16.1.0
gcc_TARBALL      = gcc-$(gcc_VERSION).tar.xz
gcc_URL          = https://ftp.mpi-inf.mpg.de/mirrors/gnu/mirror/gcc.gnu.org/pub/gcc/releases/gcc-$(gcc_VERSION)/$(gcc_TARBALL)
gcc_DIR          = gcc-$(gcc_VERSION)

gcc_CONFIG_FLAGS = --disable-multilib --target=x86_64-linux-gnu --prefix=$(PWD)/$(TOOLS_ROOT) CFLAGS="$(TOOLS_CFLAGS)" --enable-languages=c,c++

gcc: download-gcc gcc-untar gcc-configure gcc-build gcc-install

download-gcc: $(OUT)/.downloaded_gcc_stamp
gcc-untar: $(OUT)/.unpacked_gcc_stamp
gcc-configure: $(OUT)/.configured_gcc_stamp
gcc-build: $(OUT)/.built_gcc_stamp
gcc-install: $(OUT)/.installed_gcc_stamp

$(OUT)/.downloaded_gcc_stamp:
	wget -O $(DOWNLOAD_DIR)/$(gcc_TARBALL) $(gcc_URL)
	touch $@

$(OUT)/.unpacked_gcc_stamp: $(OUT)/.downloaded_gcc_stamp
	tar -xf $(DOWNLOAD_DIR)/$(gcc_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_gcc_stamp: $(OUT)/.unpacked_gcc_stamp
	mkdir -p $(OUT)/$(gcc_DIR)/out
	cd $(OUT)/$(gcc_DIR)/out ;\
		../configure $(gcc_CONFIG_FLAGS) ;\
		mkdir gas/doc -p
	touch $@

$(OUT)/.built_gcc_stamp: $(OUT)/.configured_gcc_stamp
	cd $(OUT)/$(gcc_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_gcc_stamp: $(OUT)/.built_gcc_stamp
	make -C $(OUT)/$(gcc_DIR)/out install
	touch $@
