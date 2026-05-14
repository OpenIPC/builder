################################################################################
#
# waybeam-venc
#
################################################################################

WAYBEAM_VENC_VERSION = 3d0332a3b6780c2ef5439161105f430907a04034
WAYBEAM_VENC_SITE = https://github.com/snokvist/waybeam_venc
WAYBEAM_VENC_SITE_METHOD = git
WAYBEAM_VENC_LICENSE = MIT
WAYBEAM_VENC_LICENSE_FILES = LICENSE

define WAYBEAM_VENC_BUILD_CMDS
	$(MAKE) -C $(@D) build \
		SOC_BUILD=star6e \
		CC_BIN=$(TARGET_CC) \
		STAR6E_CC="$(TARGET_CC)" \
		HOST_CC="$(HOSTCC)"
endef

define WAYBEAM_VENC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/out/star6e/waybeam $(TARGET_DIR)/usr/bin/waybeam
	$(INSTALL) -D -m 0755 $(@D)/init.d/S95waybeam $(TARGET_DIR)/etc/init.d/S95waybeam
	$(INSTALL) -D -m 0644 $(WAYBEAM_VENC_PKGDIR)/files/waybeam.json $(TARGET_DIR)/etc/waybeam.json
endef

$(eval $(generic-package))
