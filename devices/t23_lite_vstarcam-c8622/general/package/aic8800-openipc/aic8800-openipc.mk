################################################################################
#
# aic8800-openipc
#
################################################################################

# Device override: pin HEAD to a full SHA and ship the AIC8800DC firmware,
# which the stock package leaves in the source tree. The driver falls back
# to /lib/firmware when no aic_fw_path module parameter is given.
AIC8800_OPENIPC_SITE = $(call github,openipc,aic8800,$(AIC8800_OPENIPC_VERSION))
AIC8800_OPENIPC_VERSION = 0e218ed686ee04a3006bb142ca70450dfa72f4d2

AIC8800_OPENIPC_LICENSE = GPL-2.0

define AIC8800_OPENIPC_INSTALL_FW
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/lib/firmware/aic8800DC
	$(INSTALL) -m 0644 $(@D)/fw/aic8800DC/* $(TARGET_DIR)/lib/firmware/aic8800DC/
endef
AIC8800_OPENIPC_POST_INSTALL_TARGET_HOOKS += AIC8800_OPENIPC_INSTALL_FW

$(eval $(kernel-module))
$(eval $(generic-package))
