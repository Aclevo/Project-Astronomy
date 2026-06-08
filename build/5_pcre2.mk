# Sample pcre2. Can be copied with a different name to add a new pcre2.
# After copying, replace everything here from 'pcre2' to another pcre2 name.
# Modify the variables below this line. Targets "pcre2" and
# "download-pcre2" should match the file name of pcre2, so make sure the
# variable FILENAME is set correctly


pcre2_VERSION      = 10.47
pcre2_TARBALL      = pcre2-$(pcre2_VERSION).tar.gz
pcre2_URL          = https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$(pcre2_VERSION)/$(pcre2_TARBALL)
pcre2_DIR          = pcre2-$(pcre2_VERSION)
pcre2_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --prefix=/$(PWD)/$(ROOTFS)

#Alias for target
.PHONY: pcre2 5_pcre2 download-5_pcre2 pcre2-untar pcre2-configure pcre2-build pcre2-install
pcre2: 5_pcre2

5_pcre2: download-5_pcre2 pcre2-untar pcre2-configure pcre2-build pcre2-install

download-5_pcre2: $(OUT)/.downloaded_pcre2_stamp
pcre2-untar: $(OUT)/.unpacked_pcre2_stamp
pcre2-configure: $(OUT)/.configured_pcre2_stamp
pcre2-build: $(OUT)/.built_pcre2_stamp
pcre2-install: $(OUT)/.installed_pcre2_stamp

$(OUT)/.downloaded_pcre2_stamp:
	wget -O $(DOWNLOAD_DIR)/$(pcre2_TARBALL) $(pcre2_URL)
	touch $@

$(OUT)/.unpacked_pcre2_stamp: $(OUT)/.downloaded_pcre2_stamp
	tar -xf $(DOWNLOAD_DIR)/$(pcre2_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_pcre2_stamp: $(OUT)/.unpacked_pcre2_stamp
	mkdir -p $(OUT)/$(pcre2_DIR)/out
	cd $(OUT)/$(pcre2_DIR)/out;\
		../configure $(pcre2_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_pcre2_stamp: $(OUT)/.configured_pcre2_stamp
	cd $(OUT)/$(pcre2_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_pcre2_stamp: $(OUT)/.built_pcre2_stamp
	make -C $(OUT)/$(pcre2_DIR)/out install
	touch $@
