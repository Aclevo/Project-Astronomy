# Sample package. Can be copied with a different name to add a new package.
# After copying, replace everything here from 'package' to another package name.
# Modify the variables below this line. Targets "package" and
# "download-package" should match the file name of package, so repace every word
# FILENAME with the filename of current script


package_VERSION      = 1.0
package_TARBALL      = package-$(package_VERSION).tar.gz
package_URL          = https://example.com/$(package_TARBALL)
package_DIR          = package-$(package_VERSION)
package_CONFIG_FLAGS = $(COMMON_CONFIG_FLAGS) --prefix=/$(PWD)/$(ROOTFS)/usr

#Alias for target
.PHONY: package FILENAME download-FILENAME package-untar package-configure package-build package-install
package: FILENAME

FILENAME: download-FILENAME package-untar package-configure package-build package-install

download-FILENAME: $(OUT)/.downloaded_package_stamp
package-untar: $(OUT)/.unpacked_package_stamp
package-configure: $(OUT)/.configured_package_stamp
package-build: $(OUT)/.built_package_stamp
package-install: $(OUT)/.installed_package_stamp

$(OUT)/.downloaded_package_stamp:
	wget -O $(DOWNLOAD_DIR)/$(package_TARBALL) $(package_URL)
	touch $@

$(OUT)/.unpacked_package_stamp: $(OUT)/.downloaded_package_stamp
	tar -xf $(DOWNLOAD_DIR)/$(package_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_package_stamp: $(OUT)/.unpacked_package_stamp
	mkdir -p $(OUT)/$(package_DIR)/out
	cd $(OUT)/$(package_DIR)/out;\
		../configure $(package_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_package_stamp: $(OUT)/.configured_package_stamp
	cd $(OUT)/$(package_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_package_stamp: $(OUT)/.built_package_stamp
	make -C $(OUT)/$(package_DIR)/out install
	touch $@
