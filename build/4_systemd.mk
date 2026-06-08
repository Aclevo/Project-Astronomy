SYSTEMD_FLAGS=--prefix=$(PWD)/$(ROOTFS)/usr --buildtype=release -D default-dnssec=no -D firstboot=false -D install-tests=false -D ldconfig=false -D sysusers=false -D rpmmacrosdir=no -D homed=disabled -D man=disabled -D mode=release -D pamconfdir=no -D dev-kvm-mode=0660 -D nobody-group=nogroup -D sysupdate=disabled -D ukify=disabled -D docdir=$(PWD)/$(ROOTFS)/usr/share/doc/systemd-259.1 -D optimization=2;
.PHONY: 4_systemd download-systemd systemd-untar systemd-build

4_systemd: download-4_systemd systemd-untar systemd-build

download-4_systemd: $(OUT)/.downloaded_systemd_stamp
systemd-untar: $(OUT)/.unpacked_systemd_stamp
systemd-build: $(OUT)/.built_systemd_stamp

$(OUT)/.downloaded_systemd_stamp:
	cd $(DOWNLOAD_DIR);\
	if [ ! -f v259.tar.gz ]; then \
		wget https://github.com/systemd/systemd/archive/refs/tags/v259.tar.gz; \
	fi
	touch $@

$(OUT)/.unpacked_systemd_stamp:
	cd $(OUT);\
	if [ ! -d systemd-259 ]; then \
		tar -xvf download/v259.tar.gz; \
	fi
	touch $@

$(OUT)/.built_systemd_stamp:
	mkdir -p $(OUT)/systemd-259/build
	cd $(OUT)/systemd-259/build;\
	 sed -e 's/GROUP="render"/GROUP="video"/' \
	  -e 's/GROUP="sgx", //' \
	  -i rules.d/50-udev-default.rules.in;\
	 $(COMMON_CONFIG_FLAGS) meson setup .. -D buildtype=release ;\
	 ninja;\
	 DESTDIR=$(PWD)/$(ROOTFS) ninja install
	echo 'NAME="Celestial"'>$(PWD)/$(ROOTFS)/os-release
	touch $@


