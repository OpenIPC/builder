################################################################################
#
# gc6153
#
################################################################################

GC6153_SITE_METHOD = local
GC6153_SITE = $(GC6153_PKGDIR)/src

define GC6153_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) -Os -Wall -o $(@D)/gc6153 $(@D)/gc6153.c
endef

define GC6153_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/gc6153 $(TARGET_DIR)/usr/sbin/gc6153
	cp -a $(GC6153_PKGDIR)/files/. $(TARGET_DIR)/
endef

$(eval $(generic-package))
