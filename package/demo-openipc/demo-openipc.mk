################################################################################
#
# demo-openipc | updated 2022.09.13
#
################################################################################

DEMO_OPENIPC_LICENSE = MIT
DEMO_OPENIPC_LICENSE_FILES = LICENSE

define DEMO_OPENIPC_EXTRACT_CMDS
	cp -avr $(DEMO_OPENIPC_PKGDIR)/src/* $(@D)/
endef

define DEMO_OPENIPC_BUILD_CMDS
	(cd $(@D); $(TARGET_CC) -s demo-openipc.c -o demo-openipc)
endef

define DEMO_OPENIPC_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -d $(TARGET_DIR)/usr/bin
	install -m 0755 -D $(@D)/demo-openipc $(TARGET_DIR)/usr/bin/demo-openipc
endef

$(eval $(generic-package))
