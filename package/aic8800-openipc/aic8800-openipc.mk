################################################################################
#
# aic8800-openipc
#
################################################################################

AIC8800_OPENIPC_SITE = $(call github,openipc,aic8800,$(AIC8800_OPENIPC_VERSION))
AIC8800_OPENIPC_VERSION = HEAD

AIC8800_OPENIPC_LICENSE = GPL-2.0

ifeq ($(BR2_PACKAGE_AIC8800_OPENIPC_FIRMWARE_D80),y)
AIC8800_OPENIPC_D80_FILES = aic_powerlimit_8800d80.txt aic_userconfig_8800d80.txt \
	calibmode_8800d80.bin fmacfw_8800d80_u02.bin fw_adid_8800d80_u02.bin \
	fw_patch_8800d80_u02.bin fw_patch_8800d80_u02_ext0.bin \
	fw_patch_table_8800d80_u02.bin lmacfw_rf_8800d80_u02.bin

define AIC8800_OPENIPC_INSTALL_D80_FIRMWARE
	$(INSTALL) -d $(TARGET_DIR)/lib/firmware/aic8800D80
	$(INSTALL) -m 0644 -t $(TARGET_DIR)/lib/firmware/aic8800D80 \
		$(addprefix $(@D)/fw/aic8800D80/,$(AIC8800_OPENIPC_D80_FILES))
endef
AIC8800_OPENIPC_POST_INSTALL_TARGET_HOOKS += AIC8800_OPENIPC_INSTALL_D80_FIRMWARE
endif

$(eval $(kernel-module))
$(eval $(generic-package))
