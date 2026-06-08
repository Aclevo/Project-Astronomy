.PHONY: 5_bash download-5_bash bash-untar bash-configure bash-build bash-install

BASH_VERSION      = 5.3
BASH_TARBALL      = bash-$(BASH_VERSION).tar.gz
BASH_URL          = https://ftp.gnu.org/gnu/bash/$(BASH_TARBALL)
BASH_DIR          = bash-$(BASH_VERSION)
BASH_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --without-bash-malloc --host=x86_64-linux-gnu --build=$(shell $(OUT)/$(BASH_DIR)/support/config.guess) --prefix=$(PWD)/$(ROOTFS)

5_bash: download-5_bash bash-untar bash-configure bash-build bash-install

download-5_bash: $(OUT)/.downloaded_bash_stamp
bash-untar: $(OUT)/.unpacked_bash_stamp
bash-configure: $(OUT)/.configured_bash_stamp
bash-build: $(OUT)/.built_bash_stamp
bash-install: $(OUT)/.installed_bash_stamp

$(OUT)/.downloaded_bash_stamp:
	wget -O $(DOWNLOAD_DIR)/$(BASH_TARBALL) $(BASH_URL)
	touch $@

$(OUT)/.unpacked_bash_stamp: $(OUT)/.downloaded_bash_stamp
	tar -xf $(DOWNLOAD_DIR)/$(BASH_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_bash_stamp: $(OUT)/.unpacked_bash_stamp
	mkdir -p $(OUT)/$(BASH_DIR)/out
	cd $(OUT)/$(BASH_DIR)/out;\
		../configure $(BASH_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_bash_stamp: $(OUT)/.configured_bash_stamp
	cd $(OUT)/$(BASH_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_bash_stamp: $(OUT)/.built_bash_stamp
	make -C $(OUT)/$(BASH_DIR)/out install
	touch $@
